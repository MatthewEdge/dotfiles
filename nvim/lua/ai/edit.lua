local chat = require('ai.chat')
local util = require('ai.util')

local M = {}

local function file_context(bufnr, selection)
    local ctx = {
        file = util.to_relative(vim.api.nvim_buf_get_name(bufnr)),
        content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n'),
    }
    if selection then
        ctx.selection = selection
    end
    return ctx
end

M.ask_selection = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local start_line = vim.api.nvim_buf_get_mark(bufnr, '<')[1]
    local end_line = vim.api.nvim_buf_get_mark(bufnr, '>')[1]

    vim.ui.input({ prompt = 'Ask about selection: ' }, function(instruction)
        if not instruction or vim.trim(instruction) == '' then
            return
        end

        chat.ask(instruction, file_context(bufnr, { start_line = start_line, end_line = end_line }))
    end)
end

M.ask_file = function()
    local bufnr = vim.api.nvim_get_current_buf()

    vim.ui.input({ prompt = 'Ask about file: ' }, function(instruction)
        if not instruction or vim.trim(instruction) == '' then
            return
        end

        chat.ask(instruction, file_context(bufnr, nil))
    end)
end

vim.keymap.set('v', '<leader>ae', M.ask_selection, { desc = 'Ask AI about selection' })
vim.keymap.set('n', '<leader>ae', M.ask_file, { desc = 'Ask AI about file' })

return M
