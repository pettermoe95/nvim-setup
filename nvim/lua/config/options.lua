-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Backupdir to prevent backups in git tracking
vim.opt.backup = true
vim.opt.backupdir = vim.fn.expand("~/.nvim_backup") .. "//"

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.lsp.set_log_level("WARN")

vim.api.nvim_create_autocmd("FileType", {
	pattern = "kotlin",
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.expandtab = true
	end,
})
