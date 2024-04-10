-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Function to load database connections from a file
local function get_db_connections(file_path)
	local ok, connections = pcall(require, file_path)
	if ok then
		return connections
	else
		error("Failed to load database connections from file: " .. file_path)
	end
end
-- Load database connections from the file
vim.g.dbs = get_db_connections("config/db-connections")
local lspconfig = require("lspconfig")

lspconfig.tsserver.setup({
	init_options = {
		plugins = {
			name = "@vue/typescript-plugins",
			location = "add/to/node_modules/in/project",
			languages = { "javascript", "typescript", "vue" },
		},
	},
	filetypes = { "javascript", "typescript", "vue" },
})
