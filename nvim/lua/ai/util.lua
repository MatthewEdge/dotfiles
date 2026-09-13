local M = {}

M.project_root = function()
    local root = vim.fn.system({ 'git', 'rev-parse', '--show-toplevel' })
    if vim.v.shell_error ~= 0 then
        return vim.fn.getcwd()
    end
    return vim.trim(root)
end

M.to_relative = function(path)
    local root = M.project_root()
    if path:sub(1, #root + 1) == root .. '/' then
        return path:sub(#root + 2)
    end
    return path
end

M.to_absolute = function(path)
    if path:match('^/') then
        return path
    end
    return M.project_root() .. '/' .. path
end

return M
