-- TODO currently accepts Tab acceptance. Should I change?
-- vim.keymap.set('i', '<C-a>', vim.fn['copilot#Accept()'])
vim.keymap.set('i', '<C-j>', '<Plug>(copilot-next)')
vim.keymap.set('i', '<C-k>', '<Plug>(copilot-previous)')
vim.keymap.set('i', '<C-|>', '<Plug>(copilot-next)')
vim.keymap.set('n', '<leader>cpt', function() ToggleCopilot() end)

vim.g.copilot_enabled = false
function ToggleCopilot()
  if vim.g.copilot_enabled then
    vim.g.copilot_enabled = false
    print("Copilot disabled")
  else
    vim.g.copilot_enabled = true
    print("Copilot enabled")
  end
end
