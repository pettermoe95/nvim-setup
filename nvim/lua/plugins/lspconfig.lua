return {
	"neovim/nvim-lspconfig",
	opts = {
		inlay_hints = { enabled = false },

		servers = {
			-- Kotlin (kotlin-lsp)
			kotlin_lsp = {
				root_markers = { ".kt-root-marker" },
			},

			-- TypeScript / React
			ts_ls = {},

			-- Rust
			rust_analyzer = {},
		},
	},
}
