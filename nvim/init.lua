-- Package manager
require('packer_init')

require('core/options')
require('core/autocmds')
require('core/keymaps')

require('plugins/nvim-cmp')
require('plugins/nvim-lspconfig')
require('plugins/nvim-treesitter')
require('plugins/nvim-telescope')

-- LSP setup
require('lsp.config')
require('lsp.go')
