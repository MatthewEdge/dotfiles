-- Install plugins
require("lazy").setup({
    -- Git
    'tpope/vim-fugitive',

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

    -- Color viewer
    {
        'rrethy/vim-hexokinase',
        build = 'make hexokinase',
    },

    -- Fuzzy Finder
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
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
            { 'mason-org/mason.nvim' },
            { 'mason-org/mason-lspconfig.nvim' },

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

    -- Zig
    {
        'ziglang/zig.vim',
    },

    -- Debugger
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'nvim-neotest/nvim-nio',
            'leoluz/nvim-dap-go',
            'mfussenegger/nvim-dap-python',
            'rcarriga/nvim-dap-ui',
            'nvim-telescope/telescope-dap.nvim',
            'nvim-neotest/nvim-nio',
            -- 'theHamsta/nvim-dap-virtual-text'
        },
    },
})
