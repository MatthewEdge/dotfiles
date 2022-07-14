-- Plugin manager: packer.nvim
-- url: https://github.com/wbthomason/packer.nvim

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

-- Autocommand that reloads neovim whenever you save the packer_init.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost packer_init.lua source <afile> | PackerSync
  augroup end
]]


-- Install plugins
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- packer can manage itself

  -- File explorer
  use {
    'junegunn/fzf',
    requires = "junegunn/fzf.vim"
  }
  use {
      'nvim-telescope/telescope.nvim', tag = '0.1.0',
      requires = {
          'nvim-lua/plenary.nvim',
          -- 'nvim-telescope/nvim-fzf-native.nvim',
    }
  }

  -- Indent line
  -- use 'lukas-reineke/indent-blankline.nvim'

  -- Treesitter interface
  use 'nvim-treesitter/nvim-treesitter'

  -- Color schemes
  use 'morhetz/gruvbox'

  -- LSP
  use 'neovim/nvim-lspconfig'

  -- Quick commenting
  use 'preservim/nerdcommenter'

  -- Autocomplete
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
  }

  -- Git
  use 'tpope/vim-fugitive'
  use {
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup()
    end
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
