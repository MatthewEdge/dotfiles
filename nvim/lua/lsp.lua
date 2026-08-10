-- Enable built-in autocomplete
vim.opt.completeopt = "menu,menuone,noselect,popup" -- ensure native popup menu
vim.o.autocomplete = true

-- Enable LSP keybinds on LspAttach only
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp_completion', { clear = true }),
    callback = function (ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client ~= nil and client:supports_method("textDocument/completion") then
            -- Or: to trigger manually with <C-x><C-o> if autotrigger = false
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end

        local nmap = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = ev.buf, remap = false, desc = desc })
        end

        -- Explicitly set keymaps to keep them consistent
        nmap('K', vim.lsp.buf.hover, 'Signature hover')
        nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
        nmap('<leader>gi', vim.lsp.buf.implementation, 'Goto Impl')
        nmap('<leader>gd', vim.lsp.buf.definition, 'Goto Impl')
        nmap('<leader>gr', vim.lsp.buf.references, 'Goto References')
        -- nmap('<leader>gr', require('telescope.builtin').lsp_references, 'Goto References')
        nmap('<leader>go', vim.lsp.buf.type_definition, 'Goto type def')
        nmap('<leader>rn', vim.lsp.buf.rename, 'Rename symbol under cursor')
        nmap('<leader>ca', vim.lsp.buf.code_action, 'Code Actions like auto-fix')
        nmap('<leader>dn', vim.diagnostic.open_float, 'Open Diagnostic float')
        nmap('[d', vim.diagnostic.goto_next, 'Next diagnostic')
        nmap(']d', vim.diagnostic.goto_prev, 'Prev diagnostic')

        -- If, for some reason, autoformat is off
        nmap('<leader>fb', vim.lsp.buf.format, 'Manual format')
    end
})

local home_dir = os.getenv('HOME')

-- Register Mason for LSP install within nvim
-- require('mason').setup()

-- LSP Server config
vim.lsp.config('gopls', {
    cmd = {'gopls'},
    filetypes = {'go', 'gomod', 'gosum', 'gowork', 'gotmpl'},
    root_markers = {'go.mod', '.git'},
    settings = {
        gopls = {
            semanticTokens = true,
            -- gofumpt = false, -- false by default. Turn on if it goes crazy
            usePlaceholders = true,
            analyses = {
                ST1000 = false,     -- package docs recommendation
                QF1001 = true,      -- DeMorgan's Law check
                QF1006 = true,      -- TODO: lifting break condition into infinite for loop
                QF1011 = true,      -- omit redundant type info
                S1008 = true,       -- Simplify boolean returns using if blocks
                S1011 = true,       -- single append for slice concat
                S1025 = true,       -- Unnecessary Sprintf() usage
                SA1014 = true,      -- Non-pointer args to Unmarshal/Decode
                SA1015 = true,      -- time.Tick Go1.23 update
                SA1017 = true,      -- os.Notify should be buffered channel
                SA1029 = true,      -- Context key type hint
                SA4010 = true,      -- Append result never used
                SA4017 = true,      -- pointless function return discarded
                SA4023 = true,      -- interface comparison to nil mistake
                SA4031 = true,      -- never-nil == nil check
                SA5000 = true,      -- assignment to nil map
                SA5007 = true,      -- infinite recursion
                SA5010 = true,      -- Impossible type assertion for interfaces
                SA6000 = true,      -- Recommend regex.Compile
                SA6001 = true,      -- map of bytes optimization
                SA6002 = true,      -- sync.Pool allocation check
                SA9001 = true,      -- defers don't run in loops when expected
                SA9005 = true,      -- Attempt to marshal an un-marshallable object
                SA9008 = true,      -- Type assertion else-branch mistake
                ST1003 = true,      -- effective package naming
                ST1005 = true,      -- error string formatting
                ST1008 = true,      -- errors should be returned last in funcs
                ST1013 = true,      -- TODO prefer http constants for status codes
                ST1016 = true,      -- consistent receiver names
                ST1020 = true,      -- exported function documentation convention
                ST1021 = true,      -- exported type documentation convention
                ST1023 = true,      -- redundant variable type info
                appendclipped = true,   -- suggest slices.Concat
                unusedparams = true,
                shadow = true,
                fillstruct = true,
                modernize = true,
                unusedfunc = true,
                hostport = true,
                gofix = true,
                slicesdelete = true,    -- recommend slices.Delete over old append trick
                fieldalignment = true,  -- TODO may be too noisy but handy
            },
            staticcheck = true,
            vulncheck = 'Imports',
        },
    },
})
vim.lsp.enable('gopls')

-- golangci-lint continues to be slow and doesn't
-- respect local configs
-- vim.lsp.config('golangci_lint_ls', {
    -- cmd = {'golangci-lint'},
    -- filetypes = {'go', 'gomod'},
-- })
-- vim.lsp.enable('golangci_lint_ls')

vim.lsp.config('pyright', {
    filetypes = {'python'},
})
vim.lsp.enable('pyright')

    -- htmx = {},
vim.lsp.config('marksman', {
    filetypes = {'markdown'},
})
vim.lsp.enable('marksman')

vim.lsp.config('lua_ls', {
    filetypes = {'lua'},
    root_markers = {'.luarc.json', '.git'},
    settings = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    }
})
vim.lsp.enable('lua_ls')

vim.lsp.config('zls', {
    cmd = {home_dir .. '/zig-0.14.1/zls'},
    settings = {
        -- semantic_tokens = 'partial',
        zig_exe_path = home_dir .. '/zig-0.14.1',
    },
})
vim.lsp.enable('zls')

vim.lsp.config('ols', {
    cmd = {home_dir .. '/odin/ols/ols'},
    filetypes = {'odin'},
    root_markers = {'.git'},
    init_options = {
        checker_args = "-strict-style",
        -- enable_document_symbols = true,
        -- enable_hover = true,
        -- enable_snippets = true,
        -- enable_references = true,
        collections = {
            -- { name = "shared", path = home_dir .. '/odin-lib' }
        },
    },
})
vim.lsp.enable('ols')

-- Diagnostics window config
-- TODO do we like virtual_text?
vim.diagnostic.config({
    severity_sort = true,
    update_in_insert = false,
    float = {
        border = 'rounded',
        source = 'if_many',
    },
    underline = true,
    virtual_text = true,
    -- TODO signs need changing?
    -- signs = {
        -- text = {
            -- [vim.diagnostic.severity.ERROR] = 'E',
            -- [vim.diagnostic.severity.WARN] = 'W',
            -- [vim.diagnostic.severity.INFO] = 'I',
            -- [vim.diagnostic.severity.HINT] = 'H',
        -- },
    -- },
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

-- Zig setup
-- vim.g.zig_fmt_parse_errors = 0
-- vim.g.zig_fmt_autosave = 0
-- vim.api.nvim_create_autocmd('BufWritePre', {
    -- pattern = {"*.zig", "*.zon"},
    -- callback = function()
        -- vim.lsp.buf.format()

        -- vim.lsp.buf.code_action({
            -- context = { only = { 'source.organizeImports' }},
            -- apply = true,
        -- })
    -- end
-- })
