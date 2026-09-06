-- Ensure that treesitter is started for any filetype that supports it.
-- Necessary for auto-highlighting
vim.api.nvim_create_autocmd('FileType', {
    pattern = {'*'},
    callback = function ()
        local ft = vim.bo.filetype
        -- Skip empty buffers
        if ft and ft ~= "" then
            local success = pcall(function()
                vim.treesitter.start()
            end)
            if not success then
                return
            end
        end
    end
})
