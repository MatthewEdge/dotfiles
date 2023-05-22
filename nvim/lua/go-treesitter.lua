-- Treesitter helpers for parsing Go code, taken lovingly from ray-x/go.nvim and cut down to what we need
local tsutil = require('nvim-treesitter.ts_utils')

local M = {
  query_struct = '(type_spec name:(type_identifier) @definition.struct type: (struct_type))',
  query_package = '(package_clause (package_identifier)@package.name)@package.clause',
  query_struct_id = '(type_spec name:(type_identifier) @definition.struct  (struct_type))',
  query_em_struct_id = '(field_declaration name:(field_identifier) @definition.struct (struct_type))',
  query_struct_block = [[((type_declaration (type_spec name:(type_identifier) @struct.name type: (struct_type)))@struct.declaration)]],
  -- query_type_declaration = [[((type_declaration (type_spec name:(type_identifier)@type_decl.name type:(type_identifier)@type_decl.type))@type_decl.declaration)]], -- rename to gotype so not confuse with type
  query_type_declaration = [[((type_declaration (type_spec name:(type_identifier)@type_decl.name)))]],
  query_em_struct_block = [[(field_declaration name:(field_identifier)@struct.name type: (struct_type)) @struct.declaration]],
  query_struct_block_from_id = [[(((type_spec name:(type_identifier) type: (struct_type)))@block.struct_from_id)]],
  -- query_em_struct = "(field_declaration name:(field_identifier) @definition.struct type: (struct_type))",
  query_interface_id = [[((type_declaration (type_spec name:(type_identifier) @interface.name type:(interface_type)))@interface.declaration)]],
  query_interface_method = [[((method_spec name: (field_identifier)@method.name)@interface.method.declaration)]],
  query_func = '((function_declaration name: (identifier)@function.name) @function.declaration)',
  query_method = '(method_declaration receiver: (parameter_list (parameter_declaration name:(identifier)@method.receiver.name type:(type_identifier)@method.receiver.type)) name:(field_identifier)@method.name)@method.declaration',
  query_method_name = [[((method_declaration
     receiver: (parameter_list)@method.receiver
     name: (field_identifier)@method.name
     body:(block))@method.declaration)]],
  query_method_void = [[((method_declaration
     receiver: (parameter_list
       (parameter_declaration
         name: (identifier)@method.receiver.name
         type: (pointer_type)@method.receiver.type)
       )
     name: (field_identifier)@method.name
     parameters: (parameter_list)@method.parameter
     body:(block)
  )@method.declaration)]],
  query_method_multi_ret = [[(method_declaration
     receiver: (parameter_list
       (parameter_declaration
         name: (identifier)@method.receiver.name
         type: (pointer_type)@method.receiver.type)
       )
     name: (field_identifier)@method.name
     parameters: (parameter_list)@method.parameter
     result: (parameter_list)@method.result
     body:(block)
     )@method.declaration]],
  query_method_single_ret = [[((method_declaration
     receiver: (parameter_list
       (parameter_declaration
         name: (identifier)@method.receiver.name
         type: (pointer_type)@method.receiver.type)
       )
     name: (field_identifier)@method.name
     parameters: (parameter_list)@method.parameter
     result: (type_identifier)@method.result
     body:(block)
     )@method.declaration)]],
  query_tr_method_void = [[((method_declaration
     receiver: (parameter_list
       (parameter_declaration
         name: (identifier)@method.receiver.name
         type: (type_identifier)@method.receiver.type)
       )
     name: (field_identifier)@method.name
     parameters: (parameter_list)@method.parameter
     body:(block)
  )@method.declaration)]],
  query_tr_method_multi_ret = [[((method_declaration
     receiver: (parameter_list
       (parameter_declaration
         name: (identifier)@method.receiver.name
         type: (type_identifier)@method.receiver.type)
       )
     name: (field_identifier)@method.name
     parameters: (parameter_list)@method.parameter
     result: (parameter_list)@method.result
     body:(block)
     )@method.declaration)]],
  query_tr_method_single_ret = [[((method_declaration
     receiver: (parameter_list
       (parameter_declaration
         name: (identifier)@method.receiver.name
         type: (type_identifier)@method.receiver.type)
       )
     name: (field_identifier)@method.name
     parameters: (parameter_list)@method.parameter
     result: (type_identifier)@method.result
     body:(block)
     )@method.declaration)]],

  -- Requires test_name be string.format()'d in on use
  query_test_func = [[(
    (function_declaration 
        name: (identifier) @test_name
        parameters: (parameter_list
            (parameter_declaration
                name: (identifier)
                type: (pointer_type
                    (qualified_type
                     package: (package_identifier) @_param_package
                     name: (type_identifier) @_param_name))))
    ) @testfunc
    (#match? @_param_package "testing")
    (#match? @_param_name "T")
    (#eq? @test_name "%s")
  )]],
  query_testcase_node = [[(literal_value (literal_element (literal_value .(keyed_element (literal_element (identifier)) (literal_element (interpreted_string_literal) @test.name)))))]],
  query_string_literal = [[((interpreted_string_literal) @string.value)]],
}

local function debug(...)
    -- No-op now that we have sanity
end

-- go -> treesitter keyword
local function get_name_defaults()
  return { ['func'] = 'function', ['if'] = 'if', ['else'] = 'else', ['for'] = 'for' }
end

-- Returns the line number for the given test name in the given buffer
M.get_test_line = function(bufnr, name)
    if bufnr == nil then
        print("bufnr is nil. Can't parse tree")
        return -1
    end

    local formatted = string.format(M.query_test_func, name)
    local query = vim.treesitter.query.parse("go", formatted)

    -- Fetch the root tree of the buffer for querying
    local parser = vim.treesitter.get_parser(bufnr, "go")
    local tree = parser:parse()[1]
    local root = tree:root()

    for _, node in query:iter_captures(root, bufnr, 0, -1) do
        local startRow, _, _, _ = vim.treesitter.get_node_range(node)
        return startRow
    end

    -- If we get here - no node found
    print("no line number found for test " .. name)
    return -1
end

-- Return all nodes associated to cursor location
M.nodes_at_cursor = function(query, default, bufnr, ntype)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row, col = row, col + 1
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_buf_get_option(bufnr, 'ft')
  local ns = M.get_all_nodes(query, ft, default, bufnr, row, col, ntype)
  if ns == nil then
    debug('Unable to find any nodes. place your cursor on a go symbol and try again')
    return nil
  end

  -- debug(#ns)
  local nodes_at_cursor = M.sort_nodes(M.intersect_nodes(ns, row, col))
  -- debug(row, col, vim.inspect(nodes_at_cursor):sub(1, 100))
  if nodes_at_cursor == nil or #nodes_at_cursor == 0 then
    debug('Unable to find any nodes at pos. ' .. tostring(row) .. ':' .. tostring(col))
    return nil
  end

  return nodes_at_cursor
end

M.get_struct_node_at_pos = function(bufnr)
  local query = M.query_struct_block .. ' ' .. M.query_em_struct_block
  local bufn = bufnr or vim.api.nvim_get_current_buf()
  local ns = M.nodes_at_cursor(query, get_name_defaults(), bufn)
  if ns == nil then
    debug('struct not found')
  else
    debug('struct node', ns)
    return ns[#ns]
  end
end

M.get_type_node_at_pos = function(bufnr)
  local query = M.query_type_declaration
  local bufn = bufnr or vim.api.nvim_get_current_buf()
  local ns = M.nodes_at_cursor(query, get_name_defaults(), bufn)
  if ns == nil then
    debug('type not found')
  else
    debug('type node', ns)
    return ns[#ns]
  end
end

M.get_interface_node_at_pos = function(bufnr)
  local query = M.query_interface_id

  local bufn = bufnr or vim.api.nvim_get_current_buf()
  local ns = M.nodes_at_cursor(query, get_name_defaults(), bufn)
  if ns == nil then
    debug('interface not found')
  else
    return ns[#ns]
  end
end

M.get_interface_method_node_at_pos = function(bufnr)
  local query = M.query_interface_method
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local ns = M.nodes_at_cursor(query, get_name_defaults(), bufnr)
  if ns == nil then
    debug('interface method not found')
  else
    return ns[#ns]
  end
end

M.get_func_method_node_at_pos = function(bufnr)
    local query = M.query_func .. ' ' .. M.query_method_name
    local bufn = bufnr or vim.api.nvim_get_current_buf()

    local ns = M.nodes_at_cursor(query, get_name_defaults(), bufn)
    if ns == nil then
        return nil
    end

    return ns[#ns]
end

M.get_testcase_node = function(bufnr)
    local query = M.query_testcase_node
    local bufn = bufnr or vim.api.nvim_get_current_buf()
    local ns = M.nodes_at_cursor(query, get_name_defaults(), bufn, 'name')
    if ns == nil then
        debug('test case not found')
    else
        debug('testcase node', ns[#ns])
        return ns[#ns]
    end
end

M.get_string_node = function(bufnr)
    local query = M.query_string_literal
    local bufn = bufnr or vim.api.nvim_get_current_buf()
    local ns = M.nodes_at_cursor(query, get_name_defaults(), bufn, 'value')
    if ns == nil then
        debug('struct not found')
    else
        debug('struct node', ns[#ns])
        return ns[#ns]
    end
end

M.get_import_node_at_pos = function(bufnr)
    local cur_node = tsutil.get_node_at_cursor()

    if cur_node and (cur_node:type() == 'import_spec' or cur_node:parent():type() == 'import_spec') then
        return cur_node
    end
end

-- vim.treesitter.get_node_text only for nvim > 0.9
M.get_node_text = vim.treesitter.get_node_text

M.get_module_at_pos = function(bufnr)
    local node = M.get_import_node_at_pos(bufnr)
    if node then
        local module = M.get_node_text(node, vim.api.nvim_get_current_buf())
        module = string.gsub(module, '"', '')
        return module
    end
end

M.get_package_node_at_pos = function(bufnr)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    row, col = row, col + 1
    if row > 10 then
        return
    end
    local query = M.query_package
    local bufn = bufnr or vim.api.nvim_get_current_buf()

    local ns = M.nodes_at_cursor(query, get_name_defaults(), bufn)
    if ns == nil then
        return nil
    end
    if ns == nil then
        debug('package not found')
    else
        return ns[#ns]
    end
end

M.in_func = function()
    local current_node = tsutil.get_node_at_cursor()
    if not current_node then
        return false
    end
    local expr = current_node

    while expr do
        if expr:type() == 'function_declaration' or expr:type() == 'method_declaration' then
            return true
        end
        expr = expr:parent()
    end
    return false
end

local nodes = {}
local nodestime = {}
M.get_all_nodes = function(query, lang, defaults, bufnr, pos_row, pos_col, ntype)
    debug(query, lang, defaults, pos_row, pos_col)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local key = tostring(bufnr) .. query
    local filetime = vim.fn.getftime(vim.fn.expand('%'))
    if nodes[key] ~= nil and nodestime[key] ~= nil and filetime == nodestime[key] then
        return nodes[key]
    end
    -- todo a huge number
    pos_row = pos_row or 30000
    local success, parsed_query = pcall(function()
        return vim.treesitter.query.parse(lang, query)
    end)
    if not success then
        debug('failed to parse ts query: ' .. query .. 'for ' .. lang)
        return nil
    end

    local parser = require('nvim-treesitter.parsers').get_parser(bufnr, lang)
    local root = parser:parse()[1]:root()
    local start_row, _, end_row, _ = root:range()
    local results = {}
    local node_type
    for match in require('nvim-treesitter.query').iter_prepared_matches(parsed_query, root, bufnr, start_row, end_row) do
        local sRow, sCol, eRow, eCol
        local declaration_node
        local type_node
        local type = ''
        local name = ''
        local op = ''
        debug(match)

        require('nvim-treesitter.locals').recurse_local_nodes(match, function(_, node, path)
            -- local idx = string.find(path, ".", 1, true)
            -- The query may return multiple nodes, e.g.
            -- (type_declaration (type_spec name:(type_identifier)@type_decl.name type:(type_identifier)@type_decl.type))@type_decl.declaration
            -- returns { { @type_decl.name, @type_decl.type, @type_decl.declaration} ... }
            local idx = string.find(path, '.[^.]*$') -- find last `.`
            op = string.sub(path, idx + 1, #path)
            local a1, b1, c1, d1 = vim.treesitter.get_node_range(node)
            local dbg_txt = M.get_node_text(node, bufnr) or ''
            if #dbg_txt > 100 then
                dbg_txt = string.sub(dbg_txt, 1, 100) .. '...'
            end
            type = string.sub(path, 1, idx - 1) -- e.g. struct.name, type is struct
            if type:find('type') and op == 'type' then -- type_declaration.type
                node_type = M.get_node_text(node, bufnr)
                debug('type: ' .. type)
            end

            -- stylua: ignore
            debug(
            "node ", vim.inspect(node), "\n path: " .. path .. " op: " .. op
            .. "  type: " .. type .. "\n txt: " .. dbg_txt .. "\n range: " .. tostring(a1 or 0)
            .. ":" .. tostring(b1 or 0) .. " TO " .. tostring(c1 or 0) .. ":" .. tostring(d1 or 0)
            )
            -- stylua: ignore end
            --
            -- may not handle complex node
            if op == 'name' or op == 'value' or op == 'definition' then
                debug('node name ' .. name)
                name = M.get_node_text(node, bufnr) or ''
                type_node = node
            elseif op == 'declaration' or op == 'clause' then
                declaration_node = node
                sRow, sCol, eRow, eCol =
                tsutil.get_vim_range({ vim.treesitter.get_node_range(node) }, bufnr)
            else
                debug('unknown op: ' .. op)
            end
        end)
        if declaration_node ~= nil then
            debug(name .. ' ' .. op)
            -- ulog(sRow, pos_row)
            if sRow > pos_row then
                debug(tostring(sRow) .. ' beyond ' .. tostring(pos_row))
                -- break
            end
            table.insert(results, {
                declaring_node = declaration_node,
                dim = { s = { r = sRow, c = sCol }, e = { r = eRow, c = eCol } },
                name = name,
                operator = op,
                type = node_type or type,
            })
        end
        if type_node ~= nil and ntype then
            debug('type_only')
            sRow, sCol, eRow, eCol =
            tsutil.get_vim_range({ vim.treesitter.get_node_range(type_node) }, bufnr)
            table.insert(results, {
                type_node = type_node,
                dim = { s = { r = sRow, c = sCol }, e = { r = eRow, c = eCol } },
                name = name,
                operator = op,
                type = type,
            })
        end
    end
    debug('total nodes got: ' .. tostring(#results))
    nodes[key] = results
    nodestime[key] = filetime
    return results
end

M.intersect_nodes = function(n, row, col)
    local found = {}
    for idx = 1, #n do
        local node = n[idx]
        local sRow = node.dim.s.r
        local sCol = node.dim.s.c
        local eRow = node.dim.e.r
        local eCol = node.dim.e.c

        if M.intersects(row, col, sRow, sCol, eRow, eCol) then
            table.insert(found, node)
        end
    end

    return found
end

M.intersects = function(row, col, sRow, sCol, eRow, eCol)
    if sRow > row or eRow < row then
        return false
    end

    if sRow == row and sCol > col then
        return false
    end

    if eRow == row and eCol < col then
        return false
    end

    return true
end

M.sort_nodes = function(list)
    table.sort(list, function(a, b)
        return M.count_parents(a) < M.count_parents(b)
    end)
    return list
end

M.count_parents = function(node)
    local count = 0
    local n = node.declaring_node
    while n ~= nil do
        n = n:parent()
        count = count + 1
    end
    return count
end


return M
