-- setting the leader to space
vim.g.mapleader = " "

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Makes sure warnings/errors etc. always show
vim.o.exrc = true -- allow per-project configs like .nvim.lua
vim.o.secure = true -- disable unsafe commands in those configs
vim.diagnostic.config({ virtual_text = true })
