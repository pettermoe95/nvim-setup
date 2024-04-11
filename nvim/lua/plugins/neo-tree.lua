return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	requires = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	config = function()
		require("neo-tree").setup({})

		local keymap = vim.keymap
		keymap.set("n", "<leader>e", "<Cmd>Neotree toggle<CR>", { desc = "Toogle file explorer" })
	end,
}
