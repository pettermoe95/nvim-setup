-- setting the leader to space
vim.g.mapleader = " "

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- require("rust_features").setup()

-- Makes sure warnings/errors etc. always show
vim.diagnostic.config({ virtual_text = true })
vim.o.exrc = true -- allow per-project configs like .nvim.lua
vim.o.secure = true -- disable unsafe commands in those configs
