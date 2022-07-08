-- Package manager
require('packer_init')

require('core/options')
require('core/autocmds')
require('core/keymaps')

require('lsp-config')

require('plugins/indent-blankline')
require('plugins/nvim-cmp')
require('plugins/nvim-lspconfig')
require('plugins/nvim-treesitter')
