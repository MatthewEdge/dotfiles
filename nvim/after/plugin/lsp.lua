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
        -- ['<C-Space>'] = cmp.mapping.complete(),

        ['<Tab>'] = nil,
        ['<S-Tab>'] = nil,
    }),
    sources = {
        { name = 'nvim_lsp_signature_help' },
        { name = 'nvim_lsp' },
        { name = 'buffer',   keyword_length = 3 },
        { name = 'luasnip', keyword_length = 99 }, -- it's annoying that this is required
    }
})

-- LSP Servers to be installed automatically
local servers = {
    gopls = {
        settings = {
            gopls = {
                gofumpt = false, -- TODO disabled as gofumpt isn't commonly used at work
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
    -- golangci_lint_ls = {}, -- TODO currently broke itself on --output.json.path not being valid
    -- pyright = {},
    -- htmx = {},
    marksman = {},
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
    -- zls = {},
    ols = {
        init_options = {
            checker_args = "-strict-style",
            collections = {
                -- { name = "shared", path = vim.fn.expand('$HOME/odin-lib') }
            },
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
    nmap('K', vim.lsp.buf.hover, 'Signature hover')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
    nmap('<leader>gi', vim.lsp.buf.implementation, 'Goto Impl')
    nmap('<leader>gd', vim.lsp.buf.definition, 'Goto Impl')
    nmap('<leader>gr', require('telescope.builtin').lsp_references, 'Goto References')
    nmap('<leader>go', vim.lsp.buf.type_definition, 'Goto type def')
    nmap('<leader>rn', vim.lsp.buf.rename, 'Rename symbol under cursor')
    nmap('<leader>ca', vim.lsp.buf.code_action, 'Code Actions like auto-fix')
    nmap('<leader>dn', vim.diagnostic.open_float, 'Open Diagnostic float')
    nmap('[d', vim.diagnostic.goto_next, 'Next diagnostic')
    nmap(']d', vim.diagnostic.goto_prev, 'Prev diagnostic')

    -- If, for some reason, autoformat is off
    nmap('<leader>f', vim.lsp.buf.format, 'Manual format')
end

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Mason to ensure/install LSP Servers
require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = vim.tbl_keys(servers),
    automatic_installation = true,
    automatic_enable = true,
})

vim.lsp.config("*", {
    on_attach = on_attach,
    capabilities = capabilities,
})

-- TODO do we like virtual_text?
vim.diagnostic.config({
    virtual_text = true
})

-- we like Auto-format on save, generally
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = {'*.py'},
    callback = function()
        vim.lsp.buf.format()
    end
})

-- Go needs special setup for autoformat
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*.go',
    callback = function()
        local params = vim.lsp.util.make_range_params()
        params.context = {only = {"source.organizeImports"}}
        -- buf_request_sync defaults to a 1000ms timeout. Depending on your
        -- machine and codebase, you may want longer. Add an additional
        -- argument after params if you find that you have to write the file
        -- twice for changes to be saved.
        -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
        for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                    vim.lsp.util.apply_workspace_edit(r.edit, enc)
                end
            end
        end
        vim.lsp.buf.format({async = false})
    end
})
