-- Configure auto-complete
local cmp = require('cmp')
local luasnip = require('luasnip') -- TODO once cmp stops requiring a snippet manager - remove this
luasnip.config.setup({})

local cmp_select = { behavior = cmp.SelectBehavior.Select }
cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    -- completion = { autocomplete = false }, -- tab or ctrl-e triggers completion vs. autocomplete
    mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        -- Allow for enter to confirm selections
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        -- ["<C-Space>"] = cmp.mapping.complete(),

        -- Disable tab completion in favor of Copilot
        ['<Tab>'] = nil,
        ['<S-Tab>'] = nil,
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip', keyword_length = 3 },
        { name = 'buffer',   keyword_length = 3 },
    }
})

-- LSP Servers to be installed automatically
local servers = {
    gopls = {
        settings = {
            gopls = {
                -- gofumpt = true, -- TODO disabled as gofumpt isn't commonly used at work
                -- usePlaceholders = true,
                analyses = {
                    unusedparams = true,
                    shadow = true,
                    fillstruct = true,
                },
                staticcheck = true,
            },
        },
    },
    golangci_lint_ls = {},
    pyright = {},
    marksman = {},
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
}

-- Needed for lua_ls for Neovim dev. Must come before lua_ls server setup
require('neodev').setup({})

-- Configuration for each LSP once attached
local on_attach = function(_, bufnr)
    local nmap = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = bufnr, remap = false, desc = desc })
    end

    -- Explicitly set keymaps to keep them consistent
    nmap("K", vim.lsp.buf.hover, 'Signature hover')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
    nmap("<leader>gd", vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap("<leader>gi", vim.lsp.buf.implementation, '[G]oto [I]mpl')
    -- nmap("gr", vim.lsp.buf.references, opts) -- Prefer telescope's nicer UI
    nmap("<leader>gr", require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap("<leader>go", vim.lsp.buf.type_definition, 'Goto type def')
    nmap("<leader>rn", vim.lsp.buf.rename, '[R]e[n]ame symbol under cursor')
    nmap("<leader>ca", vim.lsp.buf.code_action, '[C]ode [A]ctions like auto-fix')
    nmap("[d", vim.diagnostic.goto_next, 'Next diagnostic')
    nmap("]d", vim.diagnostic.goto_prev, 'Prev diagnostic')

    -- If, for some reason, autoformat is off
    nmap('<leader>f', vim.lsp.buf.format, 'Manual format')
end

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Mason to ensure/install LSP Servers
require('mason').setup()
local mason_lspconfig = require('mason-lspconfig')

mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers({
    function(server_name)
        require('lspconfig')[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
        })
    end
})


-- TODO do we like virtual_text?
vim.diagnostic.config({
    virtual_text = true
})

-- we like Auto-format on save, generally
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = {'*.go', '*.py'},
    callback = function()
        vim.lsp.buf.format()
    end
})

-- Organize imports as well for Go files
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

vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*.go',
    callback = function()
        OrganizeImports(1000)
        -- vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
    end
})
