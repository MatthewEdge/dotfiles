vim.pack.add({
    -- Color scheme
    -- {src = 'https://github.com/rebelot/kanagawa.nvim'},

    -- Git helpers
    -- TODO is Git blame necessary anymore?
    {src = 'https://github.com/tpope/vim-fugitive'},

    -- Fuzzy Finder
    -- {src = 'https://github.com/nvim-lua/plenary.nvim'},
    -- {src = 'https://github.com/nvim-telescope/telescope.nvim', version = 'v0.2.1'},
    -- {src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim'},

    -- Treesitter interface - forked save for the test-runner
    -- {src = 'https://github.com/MatthewEdge/nvim-treesitter'},
    -- {src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main'},

    -- Symbol explore in Telescope
    -- {src = 'https://github.com/stevearc/aerial.nvim'},

    -- Quick commenting
    {src = 'https://github.com/preservim/nerdcommenter'},

    -- LSP server installations
    -- {src = 'https://github.com/mason-org/mason.nvim'},

    -- Debugger
    {src = 'https://github.com/mfussenegger/nvim-dap'},
    {src = 'https://github.com/nvim-neotest/nvim-nio'},
    {src = 'https://github.com/leoluz/nvim-dap-go'},
    {src = 'https://github.com/mfussenegger/nvim-dap-python'},
    {src = 'https://github.com/rcarriga/nvim-dap-ui'},
    -- {src = 'https://github.com/nvim-telescope/telescope-dap.nvim'},
})

-- Nerdcommenter
vim.g.NERDSpaceDelims = 1
vim.g.NERDTrimTrailingWhitespace = 1
