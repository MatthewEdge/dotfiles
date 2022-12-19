require('nvim-treesitter.configs').setup {
    -- A list of parser names, or 'all'
    ensure_installed = {
        'bash', 'c', 'css', 'dockerfile', 'go', 'hcl', 'html', 'javascript', 'json',
        'lua', 'make', 'markdown', 'python', 'typescript', 'yaml'
    },

    auto_install = true,

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}
