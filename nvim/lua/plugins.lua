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
        'rebelot/kanagawa.nvim',
        config = function()
            vim.cmd('colorscheme kanagawa')
        end
    }

    -- For the lighter days of dark colorschemes
    -- use {
    -- 'olimorris/onedarkpro.nvim',
    -- config = function()
    -- vim.cmd('colorscheme onedark')
    -- end
    -- }


    -- File explorer
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        requires = { 'nvim-lua/plenary.nvim' }
    }
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }

    -- Treesitter interface
    use('nvim-treesitter/nvim-treesitter', { run = 'TSUpdate' })

    -- Quick commenting
    use 'preservim/nerdcommenter'

    -- LSP
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' }, -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'L3MON4D3/LuaSnip' }, -- Required
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-nvim-lua' },
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

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)
