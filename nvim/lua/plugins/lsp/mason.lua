return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		local mason = require("mason")

		local mason_lspconfig = require("mason-lspconfig")

		mason.setup({})

		mason_lspconfig.setup({
			ensure_installed = {
				"tsserver",
				"pyright",
				"html",
				"cssls",
				"lua_ls",
				"dockerls",
				"docker_compose_language_service",
				"helm_ls",
				"sqlls",
				"volar",
			},
		})
	end,
}
