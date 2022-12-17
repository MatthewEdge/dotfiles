-- Auto-format on save for Go files
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
      vim.lsp.buf.format()
      -- goimports(500)
  end
})

function goimports(timeoutms)
    local context = { source = { organizeImports = true } }
    vim.validate { context = { context, "t", true } }

    local params = vim.lsp.util.make_range_params()
    params.context = context

    -- See the implementation of the textDocument/codeAction callback
    -- (lua/vim/lsp/handler.lua) for how to do this properly.
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
    if not result or next(result) == nil then return end
    local actions = result[1].result
    if not actions then return end
    local action = actions[1]

    -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
    -- is a CodeAction, it can have either an edit, a command or both. Edits
    -- should be executed first.
    if action.edit or type(action.command) == "table" then
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit)
      end
      if type(action.command) == "table" then
        vim.lsp.buf.execute_command(action.command)
      end
    else
      vim.lsp.buf.execute_command(action)
    end
  end

-----------------------------------------------------------
-- ray-x/go config
----------------------------------------------------------

-- require('go').setup {
    -- goimport = 'gopls',
    -- fillstruct = 'gopls',
    -- gofmt = 'gofumpt', -- default to gofumpt instead
    -- lsp_keymaps = false, -- disable default keymaps in favor of our own
    -- lsp_cfg = true,
    -- lsp_document_formatting = false, -- handled by null-ls
    -- lsp_diag_underline = false, -- TODO ??
    -- lsp_diag_signs = false, -- ?
    -- dap_debug = true, -- Enable dap debug integration
    -- dap_debug_keymap = false, -- We have our own mappings
    -- dap_debug_gui = true, -- set to true to enable dap gui, highly recommend
    -- dap_debug_vt = true, -- set to true to enable dap virtual text
    -- trouble = false,
    -- luasnip = false,
    -- icons = false,
    -- lsp_codelens = false, -- We don't, yet, use CodeLens
-- }
