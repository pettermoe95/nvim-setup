return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      file_ignore_patterns = {
        "node_modules",
        "%.lock",
        "package%-lock.json",
        "^.git/",
        "%.env",
        -- Add any other patterns you want to ignore
      },
    },
  },
}
