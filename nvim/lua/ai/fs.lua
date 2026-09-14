-- The server has no filesystem of its own: it is an intermediary between
-- the models and this editor. Every file the model wants to read, change,
-- or search for, it asks us for. This module is the other end of that —
-- a small filesystem RPC target driven by `fs` events on the stream.
local M = {}

local root

M.root = function()
    if not root then
        local out = vim.fn.system({ 'git', 'rev-parse', '--show-toplevel' })
        root = vim.v.shell_error == 0 and vim.trim(out) or vim.fn.getcwd()
    end
    return root
end

M.relative = function(path)
    local prefix = M.root() .. '/'
    return vim.startswith(path, prefix) and path:sub(#prefix + 1) or path
end

-- resolve turns a model-supplied path into an absolute one and refuses
-- anything that escapes the project. The model is remote and the
-- filesystem is ours, so this is the trust boundary.
local function resolve(path)
    local abs = vim.fs.normalize(path:match('^/') and path or (M.root() .. '/' .. path))
    if abs ~= M.root() and not vim.startswith(abs, M.root() .. '/') then
        error('path outside project: ' .. path, 0)
    end
    return abs
end

-- Buffers are the source of truth for the whole loop: reads prefer them so
-- the model sees unsaved work, and writes land in them so nothing reaches
-- disk until you save. That makes `u` the undo for a bad edit.
local function buffer_for(abs)
    local buf = vim.fn.bufadd(abs)
    vim.fn.bufload(buf)
    return buf
end

local function text_of(buf)
    return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
end

local ops = {}

ops.read = function(req)
    local abs = resolve(req.path)
    if vim.fn.filereadable(abs) == 0 and vim.fn.bufexists(abs) == 0 then
        error('file not found: ' .. req.path, 0)
    end
    return text_of(buffer_for(abs))
end

-- write replaces lines [start_line, end_line] with `text`. Out-of-range
-- lines raise, which the model gets back as an error and can correct from.
ops.write = function(req)
    local buf = buffer_for(resolve(req.path))
    local lines = vim.split((req.text:gsub('\n$', '')), '\n', { plain = true })
    vim.api.nvim_buf_set_lines(buf, req.start_line - 1, req.end_line, false, lines)
    return string.format(
        'wrote %s:%d-%d (%d lines, unsaved)',
        req.path, req.start_line, req.end_line, #lines
    )
end

-- delete is the only irreversible op, so it is the only one that asks.
ops.delete = function(req)
    local abs = resolve(req.path)
    if vim.fn.confirm('Delete ' .. req.path .. '?', '&Yes\n&No') ~= 1 then
        error('user declined delete: ' .. req.path, 0)
    end

    vim.fn.delete(abs)
    local buf = vim.fn.bufnr(abs)
    if buf ~= -1 then
        vim.api.nvim_buf_delete(buf, { force = true })
    end
    return 'deleted ' .. req.path
end

local GREP_LIMIT = 40

-- grep returns raw `path:line:col:text` matches. The model picks what it
-- wants and follows up with a read, rather than us guessing at snippets.
ops.grep = function(req)
    local out = vim.system(
        { 'rg', '--vimgrep', '--smart-case', '--hidden', '-g', '!.git', req.query },
        { cwd = M.root(), text = true }
    ):wait()

    if out.code > 1 then
        error('rg failed: ' .. (out.stderr or ''), 0)
    end

    local matches = vim.split(vim.trim(out.stdout or ''), '\n', { plain = true, trimempty = true })
    if #matches == 0 then
        return 'no matches for: ' .. req.query
    end
    if #matches > GREP_LIMIT then
        matches = vim.list_slice(matches, 1, GREP_LIMIT)
        table.insert(matches, string.format('... truncated to %d matches', GREP_LIMIT))
    end
    return table.concat(matches, '\n')
end

-- run performs one request and returns the reply to POST back. Failures
-- come back as `ok = false` text rather than raising: the model reads the
-- error and corrects itself on the next request.
M.run = function(req)
    local op = ops[req.op]
    if not op then
        return { ok = false, content = 'unknown op: ' .. tostring(req.op) }
    end

    local ok, result = pcall(op, req)
    return { ok = ok, content = tostring(result) }
end

M.summary = function(req)
    return string.format('%s %s', req.op, req.path or req.query or '')
end

return M
