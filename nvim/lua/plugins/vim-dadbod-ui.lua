return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql", "mssql" }, lazy = true },
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	init = function()
		-- Your DBUI configuration
		vim.g.db_ui_use_nerd_fonts = 1
		local keymap = vim.keymap
		keymap.set("n", "<leader>sqlt", "<Cmd>DBUIToggle<CR>", { desc = "Toggles DBUI for SQL-tree" })
		keymap.set(
			"n",
			"<leader>sqlf",
			"<Cmd>DBUIFindBuffer<CR>",
			{ desc = "Connect current buffer to a SQL connection" }
		)
	end,
}
