-- Ensure autocomplete doesn't run in Telescope windows. It's distracting
vim.api.nvim_create_autocmd('FileType', {
    pattern = {'TelescopePrompt'},
    callback = function()
        vim.o.autocomplete = false
    end
})

local actions = require("telescope.actions")
local additional_rg_args = { "--hidden", "--glob", "!**/.git/*", "--glob", "!**/node_modules/*" }
require('telescope').setup({
    file_ignore_patterns = { "node_modules", ".obsidian" },
    defaults = {
        mappings = {
            -- makes esc not drop to normal mode and just exit
            i = {
                ["<esc>"] = actions.close,
            },
        },
    },
    pickers = {
        live_grep = { additional_args = additional_rg_args },
        find_files = {
            find_command = {
                "rg",
                "--files",
                "--hidden",
                "--glob=!**/.git/*",
                "--glob=!**/.vscode/*",
                "--glob=!**/build/*",
                "--glob=!**/dist/*",
            },
        },
    },
})

local ts = require('telescope.builtin')

vim.keymap.set('n', '<leader>pf', ts.find_files, { desc = 'Project Files' })
vim.keymap.set('n', '<leader>rg', ts.live_grep, { desc = 'RipGrep' })
vim.keymap.set('n', '<leader>fb', ts.buffers, { desc = 'Find Buffers' })
vim.keymap.set('n', '<leader>fh', ts.help_tags, { desc = 'Find Help Tags' })
vim.keymap.set('n', '<leader>km', ts.keymaps, { desc = 'Key Mappings' })
vim.keymap.set('n', '<leader>pd', ts.diagnostics, { desc = 'Project Diagnostics' })

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
