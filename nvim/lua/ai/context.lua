local util = require('ai.util')

local M = {}

local CONTEXT_LINES = 15

local function read_file(path)
    local abs = util.to_absolute(path)

    if vim.fn.filereadable(abs) == 0 then
        return nil, 'file not found: ' .. path
    end

    return table.concat(vim.fn.readfile(abs), '\n'), nil
end

local function run_grep(query)
    local cmd = { 'rg', '--vimgrep', '--smart-case', '--hidden', '-g', '!.git', query }
    local result = vim.system(cmd, { cwd = util.project_root(), text = true }):wait()

    if result.code ~= 0 and result.code ~= 1 then
        return nil, 'rg failed: ' .. (result.stderr or '')
    end

    local matches = {}
    for line in (result.stdout or ''):gmatch('[^\n]+') do
        local path, lnum, _, text = line:match('^(.-):(%d+):(%d+):(.*)$')
        if path then
            table.insert(matches, { path = path, line = tonumber(lnum), text = text })
        end
    end

    return matches, nil
end

local function snippet_for(match)
    local abs = util.to_absolute(match.path)

    if vim.fn.filereadable(abs) == 0 then
        return nil, 'file not found: ' .. match.path
    end

    local all_lines = vim.fn.readfile(abs)
    local start_line = math.max(1, match.line - CONTEXT_LINES)
    local end_line = math.min(#all_lines, match.line + CONTEXT_LINES)
    local snippet_lines = vim.list_slice(all_lines, start_line, end_line)

    local header = string.format('%s:%d-%d', match.path, start_line, end_line)
    return header .. '\n' .. table.concat(snippet_lines, '\n'), nil
end

M.resolve = function(req, on_result)
    if req.kind == 'file' then
        local content, err = read_file(req.path)
        if err then
            on_result(nil, err)
            return
        end
        on_result(content, nil, { kind = 'file', path = req.path })
        return
    end

    if req.kind ~= 'grep' then
        on_result(nil, 'unknown context_request kind: ' .. tostring(req.kind))
        return
    end

    local matches, err = run_grep(req.query)
    if err then
        on_result(nil, err)
        return
    end

    if #matches == 0 then
        on_result(nil, 'no matches found for: ' .. req.query)
        return
    end

    if #matches == 1 then
        local content, snippet_err = snippet_for(matches[1])
        if snippet_err then
            on_result(nil, snippet_err)
            return
        end
        on_result(content, nil, { kind = 'grep', path = matches[1].path, line = matches[1].line })
        return
    end

    local labels = {}
    for _, m in ipairs(matches) do
        table.insert(labels, string.format('%s:%d: %s', m.path, m.line, vim.trim(m.text)))
    end

    vim.ui.select(labels, { prompt = 'Multiple matches for "' .. req.query .. '" — pick one:' }, function(_, idx)
        if not idx then
            on_result(nil, 'user cancelled context selection for: ' .. req.query)
            return
        end

        local content, snippet_err = snippet_for(matches[idx])
        if snippet_err then
            on_result(nil, snippet_err)
            return
        end
        on_result(content, nil, { kind = 'grep', path = matches[idx].path, line = matches[idx].line })
    end)
end

return M
