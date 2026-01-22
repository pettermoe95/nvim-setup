return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	opts = {
		formatters_by_ft = {
			kotlin = { "ktfmt" },
		},
		formatters = {
			ktfmt = {
				command = "ktfmt",
			},
		},
	},
}
