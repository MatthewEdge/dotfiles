local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
    'gopls',
    'tsserver',
    'sumneko_lua',
})

lsp.set_preferences({
    sign_icons = {},
})

-- Allow altering nvim_cmp keymaps
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings()
cmp_mappings['<C-p>'] = cmp.mapping.select_prev_item(cmp_select)
cmp_mappings['<C-n>'] = cmp.mapping.select_next_item(cmp_select)
cmp_mappings['<C-y>'] = cmp.mapping.confirm({ select = true })
cmp_mappings['<Tab>'] = nil -- disable Tab completion in favor of copilot
-- ["<C-Space>"] = cmp.mapping.complete(),

lsp.setup_nvim_cmp({
    mapping = cmp_mappings,
    -- completion = { autocomplete = false }, -- tab or ctrl-e triggers completion
    sources = {
        { name = 'nvim_lsp', keyword_length = 2 },
        { name = 'buffer', keyword_length = 3 },
        { name = 'luasnip', keyword_length = 3 },
        { name = 'path' },
    },
})

lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>gr", require('telescope.builtin').lsp_references, opts)
    vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)

    -- Auto-format on save
    vim.cmd([[
        augroup formatting
            autocmd! * <buffer>
            autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
        augroup END
    ]])

    -- Import organization for Go files
    vim.cmd([[
        augroup goimports
            autocmd! * <buffer>
            autocmd BufWritePre *.go lua OrganizeImports(1000)
        augroup END
    ]])
end)

-- organize imports
-- https://github.com/neovim/nvim-lspconfig/issues/115#issuecomment-902680058
function OrganizeImports(timeoutms)
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeoutms)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
            else
                vim.lsp.buf.execute_command(r.command)
            end
        end
    end
end

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

lsp.configure('sumneko_lua', {
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT)
                version = 'LuaJIT',
                -- Setup your lua path
                path = runtime_path,
            },
            diagnostics = {
                globals = { 'vim' },
            },
            workspace = { library = vim.api.nvim_get_runtime_file('', true) },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = { enable = false },
        },
    },
})

lsp.configure('gopls', {
    settings = {
        gopls = {
            gofumpt = true,
            -- usePlaceholders = true,
            analyses = {
                unusedparams = true,
                shadow = true,
                fillstruct = true,
            },
        },
    },
})

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})
