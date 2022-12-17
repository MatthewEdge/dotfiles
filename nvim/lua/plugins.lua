-- Automatically install packer
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path
  })
  vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]


-- Install plugins
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- packer can manage itself

  -- Git
  use 'tpope/vim-fugitive'

  -- Copilot, for fun
  use 'github/copilot.vim'

  -- Color schemes
  use {
      'morhetz/gruvbox',
      as = 'gruvbox',
      config = function()
          vim.cmd('colorscheme gruvbox')
          vim.g.gruvbox_invert_selection = false
      end
  }

  -- File explorer
  use {
      'nvim-telescope/telescope.nvim', tag = '0.1.0',
      requires = { 'nvim-lua/plenary.nvim' }
  }

  -- Treesitter interface
  use('nvim-treesitter/nvim-treesitter', {run = 'TSUpdate'})

  -- Quick commenting
  use 'preservim/nerdcommenter'

  -- Formatting
  -- use {
      -- 'jose-elias-alvarez/null-ls.nvim',
      -- requires = {
          -- 'nvim-lua/plenary.nvim'
      -- },
  -- }

  -- LSP
  use {
	  'VonHeikemen/lsp-zero.nvim',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},
		  {'williamboman/mason.nvim'},
		  {'williamboman/mason-lspconfig.nvim'},

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-buffer'},
		  {'hrsh7th/cmp-path'},
		  {'saadparwaiz1/cmp_luasnip'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'hrsh7th/cmp-nvim-lua'},

		  -- Snippets
		  {'L3MON4D3/LuaSnip'},
		  {'rafamadriz/friendly-snippets'},
	  }
  }

  -- Debugger
  use {
      'mfussenegger/nvim-dap',
      requires = {
          'leoluz/nvim-dap-go',
          'rcarriga/nvim-dap-ui',
          'nvim-telescope/telescope-dap.nvim',
          -- 'theHamsta/nvim-dap-virtual-text'
      },
  }

  -- Diagnostics
  -- use {
      -- "folke/trouble.nvim",
      -- config = function()
          -- require("trouble").setup {}
      -- end
  -- }

  -- Golang
  -- use 'ray-x/go.nvim'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
