require('nvim-treesitter.configs').setup {
    -- A list of parser names, or 'all'
    ensure_installed = {
        'bash', 'c', 'css', 'dockerfile', 'go', 'hcl', 'html', 'json',
        'lua', 'make', 'markdown', 'proto', 'python', 'typescript', 'vim',
        'yaml',
    },

    auto_install = true,

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },

    playground = {
        enable = true,
        disable = {},
        updatetime = 25,
    },
    query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = {'BufWrite', 'CursorHold'},
    },
}

-- To see Treesitter node for what's under the cursor
vim.keymap.set('n', '<space>tsn', '<cmd>TSNodeUnderCursor<cr>')
