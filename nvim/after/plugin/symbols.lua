require('aerial').setup({
    on_attach = function (bufnr)
        vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', {buffer = bufnr})
        vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', {buffer = bufnr})
    end,

    layout = {},
    close_on_select = false,
})

-- Register Telescope extension
require('telescope').load_extension('aerial')
vim.keymap.set('n', '<leader>ss', require('telescope').extensions.aerial.aerial, {desc = '[S]how [S]ymbols'})
