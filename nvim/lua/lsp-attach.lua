-- We're exporting the on_attach for use in other language plugins
M = {}

function M.on_attach(client, bufnr)
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end

	-- Mappings.
	local opts = { noremap = true, silent = true }

    -- Going back and forth on Telescope vs. vim.lsp variants. Needs further testing
	buf_set_keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
	-- buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
	buf_set_keymap("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
	-- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	buf_set_keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
	-- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	buf_set_keymap("n", "<leader>ca", "<cmd>Telescope lsp_code_actions<CR>", opts)
    -- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {buffer=0})
	buf_set_keymap("n", "<C-j>", "<cmd>Telescope lsp_document_symbols<CR>", opts)
    buf_set_keymap("n", "<leader>gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
	-- buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    vim.keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", {buffer=0})

    buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	buf_set_keymap("n", "<leader>rr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
	buf_set_keymap("n", "<leader>dj", '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
	buf_set_keymap("n", "<leader>dk", '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
	-- buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	-- buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
	-- buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

	-- Set autocommands conditional on server_capabilities
	-- if client.server_capabilities.document_highlight then
		-- vim.cmd([[
			-- augroup lsp_document_highlight
				-- autocmd! * <buffer>
				-- autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
				-- autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
			-- augroup END
		-- ]])
	-- end
end

return M
