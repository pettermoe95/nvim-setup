-- lua/rust_features/init.lua
local M = {}

-- Helpers --------------------------------------------------------------------

local function ra_clients()
	local list
	if vim.lsp.get_clients then
		list = vim.lsp.get_clients()
	else
		list = vim.lsp.get_active_clients()
	end
	local out = {}
	for _, c in ipairs(list or {}) do
		if c and (c.name == "rust_analyzer" or c.name == "rust-analyzer") then
			table.insert(out, c)
		end
	end
	return out
end

local function current_features(client)
	local ra = (client.config.settings or {})["rust-analyzer"] or {}
	local cargo = ra.cargo or {}
	local feats = cargo.features or {}
	local out = {}
	for _, f in ipairs(feats) do
		if type(f) == "string" then
			table.insert(out, f)
		end
	end
	return out
end

-- Add this small helper to compute extraArgs from features:
local function features_to_check_args(feats)
	local args = {}
	if feats and #feats > 0 then
		table.insert(args, "--features")
		table.insert(args, table.concat(feats, ","))
	end
	return args
end

-- Replace apply_settings_to_client with this:
local function apply_settings_to_client(client, overrides)
	local cfg = vim.deepcopy(client.config.settings or {})
	cfg["rust-analyzer"] = cfg["rust-analyzer"] or {}
	cfg["rust-analyzer"].cargo = vim.tbl_deep_extend("force", cfg["rust-analyzer"].cargo or {}, overrides or {})
	-- Keep check.extraArgs aligned if features were provided in overrides
	local feats = cfg["rust-analyzer"].cargo.features
	cfg["rust-analyzer"].check = cfg["rust-analyzer"].check or {}
	if feats then
		cfg["rust-analyzer"].check.extraArgs = features_to_check_args(feats)
	end

	if client.workspace_did_change_configuration then
		client.workspace_did_change_configuration({ settings = cfg })
	else
		client.notify("workspace/didChangeConfiguration", { settings = cfg })
	end
	client.config.settings = cfg
	client.request("rust-analyzer/reloadWorkspace", nil, function() end)
end

local function apply_features_to_client(client, features)
	local cfg = vim.deepcopy(client.config.settings or {})
	cfg["rust-analyzer"] = cfg["rust-analyzer"] or {}
	cfg["rust-analyzer"].cargo = cfg["rust-analyzer"].cargo or {}
	cfg["rust-analyzer"].cargo.features = features
	cfg["rust-analyzer"].cargo.noDefaultFeatures = cfg["rust-analyzer"].cargo.noDefaultFeatures or false
	cfg["rust-analyzer"].cargo.allFeatures = cfg["rust-analyzer"].cargo.allFeatures or false
	cfg["rust-analyzer"].check = cfg["rust-analyzer"].check or {}
	cfg["rust-analyzer"].check.extraArgs = features_to_check_args(features)

	if client.workspace_did_change_configuration then
		client.workspace_did_change_configuration({ settings = cfg })
	else
		client.notify("workspace/didChangeConfiguration", { settings = cfg })
	end
	client.config.settings = cfg

	client.request("rust-analyzer/reloadWorkspace", nil, function(err)
		if err then
			vim.notify("rust-analyzer reload failed: " .. tostring(err), vim.log.levels.ERROR)
		end
	end)
end

local function parse_lines_to_features(lines)
	local feats = {}
	local seen = {}
	for _, line in ipairs(lines) do
		local s = vim.trim((line:gsub("#.*$", ""))) -- strip comments
		if s ~= "" and not seen[s] then
			seen[s] = true
			table.insert(feats, s)
		end
	end
	return feats
end

local function project_root()
	local ok, lines = pcall(function()
		return vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })
	end)
	if ok and vim.v.shell_error == 0 and lines and #lines > 0 then
		return lines[1]
	end
	return vim.loop.cwd()
end

local function state_path()
	local root = project_root()
	return root .. "/.nvim/rust-features.txt"
end

local function load_persisted()
	local path = state_path()
	if vim.uv.fs_stat(path) then
		return vim.fn.readfile(path)
	end
	return nil
end

local function persist_lines(lines)
	local path = state_path()
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
	vim.fn.writefile(lines, path)
end

local function apply_to_all_clients(features)
	local clients = ra_clients() or {}
	if #clients == 0 then
		vim.notify("No active rust-analyzer clients; open a Rust file first.", vim.log.levels.WARN)
		return
	end
	for _, c in ipairs(clients) do
		apply_features_to_client(c, features)
	end
	vim.notify("Applied rust-analyzer cargo.features: [" .. table.concat(features, ", ") .. "]")
end

-- UI -------------------------------------------------------------------------

local function open_editor_buf()
	local bufnr = vim.api.nvim_create_buf(false, true) -- scratch
	vim.api.nvim_buf_set_name(bufnr, "[RustFeatures]") -- give it a name so :w works
	vim.bo[bufnr].buftype = "acwrite"
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].modifiable = true
	vim.bo[bufnr].filetype = "rustfeatures"
	vim.bo[bufnr].undofile = false

	-- Seed content: persisted list if any, else union of current RA features
	local seeded = load_persisted()
	if not seeded then
		local union, have = {}, {}
		for _, c in ipairs(ra_clients() or {}) do
			for _, f in ipairs(current_features(c)) do
				if not have[f] then
					have[f] = true
					table.insert(union, f)
				end
			end
		end
		seeded = (#union > 0) and union
			or {
				"# One feature per line. Lines starting with # are comments.",
				"db_tests",
			}
	end
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, seeded)

	-- Floating window
	local width = math.floor(vim.o.columns * 0.4)
	local height = math.floor(vim.o.lines * 0.5)
	local row = math.floor((vim.o.lines - height) / 3)
	local col = math.floor((vim.o.columns - width) / 2)
	local winid = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = " rust-analyzer cargo.features ",
		title_pos = "center",
	})

	-- :w -> apply + persist; no disk write attempted
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = bufnr,
		callback = function(ev)
			local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
			local feats = parse_lines_to_features(lines)
			apply_to_all_clients(feats)
			persist_lines(lines)
			vim.bo[ev.buf].modified = false
		end,
	})

	-- Keymaps:
	-- q = quit without saving (no prompt)
	vim.keymap.set("n", "q", function()
		vim.bo[bufnr].modified = false
		if vim.api.nvim_win_is_valid(winid) then
			vim.api.nvim_win_close(winid, true)
		end
	end, { buffer = bufnr, nowait = true, silent = true, desc = "Close RustFeatures" })

	-- Q = save+apply+quit
	vim.keymap.set("n", "Q", function()
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local feats = parse_lines_to_features(lines)
		apply_to_all_clients(feats)
		persist_lines(lines)
		vim.bo[bufnr].modified = false
		if vim.api.nvim_win_is_valid(winid) then
			vim.api.nvim_win_close(winid, true)
		end
	end, { buffer = bufnr, nowait = true, silent = true, desc = "Save+Close RustFeatures" })

	-- Optional: <leader>a to apply without writing
	vim.keymap.set("n", "<leader>a", function()
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local feats = parse_lines_to_features(lines)
		apply_to_all_clients(feats)
	end, { buffer = bufnr, desc = "Apply rust-analyzer features" })

	return bufnr, winid
end

-- Public API -----------------------------------------------------------------

function M.edit()
	if not ra_clients() or #ra_clients() == 0 then
		vim.notify("Open a Rust file so rust-analyzer attaches first.", vim.log.levels.WARN)
	end
	open_editor_buf()
end

function M.apply_current_buffer()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local feats = parse_lines_to_features(lines)
	apply_to_all_clients(feats)
	persist_lines(lines)
	vim.bo[buf].modified = false
end

function M.setup()
	vim.api.nvim_create_user_command("RustFeatures", function()
		M.edit()
	end, { desc = "Edit rust-analyzer Cargo features (per project, persisted)" })

	vim.api.nvim_create_user_command("RustFeaturesApply", function()
		M.apply_current_buffer()
	end, { desc = "Apply features in current buffer and persist" })

	vim.api.nvim_create_user_command("RustFeaturesAllOn", function()
		for _, c in ipairs(ra_clients()) do
			apply_settings_to_client(c, { allFeatures = true })
		end
		vim.notify("rust-analyzer: cargo.allFeatures = true")
	end, {})

	vim.api.nvim_create_user_command("RustFeaturesStatus", function()
		local cs = ra_clients()
		if #cs == 0 then
			vim.notify("RustFeatures: no rust-analyzer clients found (open a Rust file first).", vim.log.levels.WARN)
			return
		end
		local lines = { "rust-analyzer cargo settings:" }
		for _, c in ipairs(cs) do
			local ra = ((c.config.settings or {})["rust-analyzer"] or {})
			local cargo = ra.cargo or {}
			local feats = cargo.features or {}
			table.insert(
				lines,
				string.format(
					"• client #%s  features=[%s]  allFeatures=%s  noDefaultFeatures=%s",
					tostring(c.id or "?"),
					table.concat(feats, ", "),
					tostring(cargo.allFeatures or false),
					tostring(cargo.noDefaultFeatures or false)
				)
			)
		end
		vim.notify(table.concat(lines, "\n"))
	end, {})
end

return M
