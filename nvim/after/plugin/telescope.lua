-----------------------------------------------------------
-- Telescope config
----------------------------------------------------------
local actions = require("telescope.actions")
require('telescope').setup({
    file_ignore_patterns = { "node_modules", ".obsidian" },
    defaults = {
        -- affects live_grep results
        vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--files',
            '--hidden',
            '--ignore-file', '.gitignore',
            '-g',
            '!**/.git/*',
        },
        mappings = {
            -- makes esc not drop to normal mode and just exit
            i = {
                ["<esc>"] = actions.close,
            },
        },
    },
    pickers = {
        find_files = {
            find_command = {
                'rg',
                '--color=never',
                '--no-heading',
                '--with-filename',
                '--line-number',
                '--column',
                '--smart-case',
                '--files',
                '--hidden',
                '--ignore-file', '.gitignore',
                '-g',
                '!**/.git/*',
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
