-- Install plugins
require("lazy").setup({
    -- Git
    'tpope/vim-fugitive',

    -- Copilot, for fun
    'github/copilot.vim',

    -- Color schemes
    {
        'rebelot/kanagawa.nvim',
        config = function()
            vim.cmd('colorscheme kanagawa')
        end,
        -- For the lighter days of dark colorschemes
        -- 'olimorris/onedarkpro.nvim',
        -- config = function()
        -- vim.cmd('colorscheme onedark')
        -- end,
    },

    -- Zen mode
    {
        'folke/zen-mode.nvim',
    },

    -- Fuzzy Finder
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },

    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
    },

    {
        'ThePrimeagen/harpoon',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },

    -- Treesitter interface
    {
        'nvim-treesitter/nvim-treesitter',
        cmd = 'TSUpdate',
    },

    {
        'stevearc/aerial.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
    },

    -- Quick commenting
    'preservim/nerdcommenter',

    -- LSP
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            -- LSP Server auto-install
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'L3MON4D3/LuaSnip' },     -- Required
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-nvim-lua' },
            { 'hrsh7th/cmp-nvim-lsp-signature-help' },

            -- Make Neovim conf editing better
            { 'folke/neodev.nvim' },
        }
    },

    -- Debugger
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'leoluz/nvim-dap-go',
            'rcarriga/nvim-dap-ui',
            'nvim-telescope/telescope-dap.nvim',
            -- 'theHamsta/nvim-dap-virtual-text'
        },
    },
})
