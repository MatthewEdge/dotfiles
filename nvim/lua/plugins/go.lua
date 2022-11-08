-----------------------------------------------------------
-- ray-x/go config
----------------------------------------------------------

require('go').setup {
    goimport = 'gopls',
    fillstruct = 'gopls',
    gofmt = 'gofumpt', -- default to gofumpt instead
    lsp_keymaps = false, -- disable default keymaps in favor of our own
    lsp_cfg = true,
    lsp_on_attach = require('lsp-attach').on_attach,
    lsp_document_formatting = false, -- handled by null-ls
    lsp_diag_underline = false, -- TODO ??
    lsp_diag_signs = true, -- We like the gutter icons
    dap_debug = true,
    dap_debug_keymap = false, -- We have our own mappings
    dap_debug_gui = true, -- set to true to enable dap gui, highly recommend
    dap_debug_vt = true, -- set to true to enable dap virtual text
    trouble = false,
    luasnip = true,
    icons = false,
    lsp_codelens = false, -- We don't, yet, use CodeLens
}
