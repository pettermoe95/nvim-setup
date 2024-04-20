return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		local mason = require("mason")

		local mason_lspconfig = require("mason-lspconfig")

		mason.setup({})
		local mason_registry = require("mason-registry")
		local ts_plugin_path = mason_registry.get_package("vue-language-server"):get_install_path()
			.. "/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin"

		local servers = {
			tsserver = {
				init_options = {
					plugins = {
						{
							name = "@vue/typescript-plugin",
							location = ts_plugin_path,
							-- If .vue file cannot be recognized in either js or ts file try to add `typescript` and `javascript` in languages table.
							languages = { "vue" },
						},
					},
				},
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
			},
			pyright = {},
			html = {},
			cssls = {},
			lua_ls = {},
			dockerls = {},
			docker_compose_language_service = {},
			helm_ls = {},
			sqlls = {},
			volar = {},
		}

		mason_lspconfig.setup({
			ensure_installed = vim.tbl_keys(servers),
		})
	end,
}
