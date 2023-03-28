-- TODO with v2...is lsp-zero still necessary?

local lsp = require("lsp-zero").preset({})
lsp.preset("recommended")

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.ensure_installed({
    'gopls',
    'golangci_lint_ls',
    'lua_ls',
})

-- Allow altering nvim_cmp keymaps
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings() -- TODO defaults.cmp_mappings is deprecated
cmp_mappings['<C-p>'] = cmp.mapping.select_prev_item(cmp_select)
cmp_mappings['<C-n>'] = cmp.mapping.select_next_item(cmp_select)
cmp_mappings['<C-y>'] = cmp.mapping.confirm({ select = true })
cmp_mappings['<Tab>'] = nil -- disable Tab completion in favor of copilot
-- ["<C-Space>"] = cmp.mapping.complete(),

cmp.setup({
    mapping = cmp_mappings,
    -- completion = { autocomplete = false }, -- tab or ctrl-e triggers completion vs. autocomplete
    sources = {
        { name = 'nvim_lsp', keyword_length = 2 },
        { name = 'buffer',   keyword_length = 3 },
        { name = 'luasnip',  keyword_length = 3 },
        { name = 'path' },
    },
})

lsp.on_attach(function(_, bufnr)
    local nmap = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = bufnr, remap = false, desc = desc })
    end

    -- Explicitly set keymaps to keep them consistent
    nmap("K", vim.lsp.buf.hover, 'Signature hover')
    nmap("<leader>gd", vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap("<leader>gi", vim.lsp.buf.implementation, '[G]oto [I]mpl')
    -- nmap("gr", vim.lsp.buf.references, opts) -- Prefer telescope's nicer UI
    nmap("<leader>gr", require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap("<leader>go", vim.lsp.buf.type_definition, 'Goto type def')
    nmap("<leader>rr", vim.lsp.buf.rename, 'Rename symbol under cursor')
    nmap("[d", vim.diagnostic.goto_next, 'Next diagnostic')
    nmap("]d", vim.diagnostic.goto_prev, 'Prev diagnostic')

    -- If, for some reason, autoformat is off
    nmap('<leader>f', vim.lsp.buf.format, 'Manual format')

    -- ..but we like Auto-format on save
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
-- local runtime_path = vim.split(package.path, ';')
-- table.insert(runtime_path, 'lua/?.lua')
-- table.insert(runtime_path, 'lua/?/init.lua')

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

lsp.configure('golangci_lint_ls', {
    settings = {
        gopls = {
            gofumpt = true,
        },
    },
    flags = {
        debounce_text_changes = 150,
    },
})

lsp.setup()

-- TODO do we like virtual_text?
vim.diagnostic.config({
    virtual_text = true
})
