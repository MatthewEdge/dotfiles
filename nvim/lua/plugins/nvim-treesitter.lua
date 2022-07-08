-----------------------------------------------------------
-- Treesitter configuration file
----------------------------------------------------------

-- Plugin: nvim-treesitter
-- url: https://github.com/nvim-treesitter/nvim-treesitter
-- See: https://github.com/nvim-treesitter/nvim-treesitter#quickstart
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
  },
  -- A list of parser names, or "all"
  ensure_installed = {
    'bash', 'c', 'cpp', 'css', 'go', 'html', 'javascript', 'json', 'lua', 'make',
    'python', 'typescript', 'vim'
  },
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
}
