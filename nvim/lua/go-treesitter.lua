local M = {}

local function get_root(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, 'go')
  if not ok or not parser then
    return nil
  end
  local tree = parser:parse()[1]
  return tree and tree:root()
end

local function node_at_cursor(bufnr, winid)
  return vim.treesitter.get_node({ bufnr = bufnr, winid = winid or 0 })
end

local function find_ancestor(node, types)
  while node do
    local t = node:type()
    for _, want in ipairs(types) do
      if t == want then
        return node
      end
    end
    node = node:parent()
  end
  return nil
end

M.query_test_func = [[
  (
    (function_declaration
      name: (identifier) @test_name
      parameters: (parameter_list
        (parameter_declaration
          type: (pointer_type
            (qualified_type
              package: (package_identifier) @_pkg
              name: (type_identifier) @_type))))
    ) @testfunc
    (#eq? @_pkg "testing")
    (#eq? @_type "T")
    (#eq? @test_name "%s")
  )
]]

M.get_test_line = function(bufnr, name)
  if bufnr == nil then
    vim.notify("bufnr is nil. Can't parse tree", vim.log.levels.WARN)
    return -1
  end

  local root = get_root(bufnr)
  if not root then
    return -1
  end

  local formatted = string.format(M.query_test_func, name)
  local ok, query = pcall(vim.treesitter.query.parse, 'go', formatted)
  if not ok then
    vim.notify('failed to parse test query', vim.log.levels.WARN)
    return -1
  end

  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    if query.captures[id] == 'testfunc' then
      local row = node:range()
      return row
    end
  end

  return -1
end

local function get_receiver_type(decl, bufnr)
  local recv = decl:field('receiver')[1]
  if not recv then
    return nil
  end
  for child in recv:iter_children() do
    if child:type() == 'parameter_declaration' then
      local t = child:field('type')[1]
      if t and t:type() == 'pointer_type' then
        t = t:named_child(0)
      end
      if t and t:type() == 'type_identifier' then
        return vim.treesitter.get_node_text(t, bufnr)
      end
    end
  end
  return nil
end

M.get_func_method_node_at_pos = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local cur = node_at_cursor(bufnr)
  if not cur then
    return nil
  end

  local decl = find_ancestor(cur, { 'function_declaration', 'method_declaration' })
  if not decl then
    return nil
  end

  local name_field = decl:field('name')
  local name_node = name_field and name_field[1]
  if not name_node then
    return nil
  end

  local receiver_type = nil
  if decl:type() == 'method_declaration' then
    receiver_type = get_receiver_type(decl, bufnr)
  end

  return {
    name = vim.treesitter.get_node_text(name_node, bufnr),
    node = decl,
    receiver_type = receiver_type,
  }
end

-- type_embeds reports whether type_name's struct has a field of type
-- pkg.embedded_type (embedded or named), e.g. suite.Suite for testify suites.
M.type_embeds = function(bufnr, type_name, pkg, embedded_type)
  local root = get_root(bufnr)
  if not root or not type_name then
    return false
  end

  local formatted = string.format([[
    (type_declaration
      (type_spec
        name: (type_identifier) @_name
        type: (struct_type
          (field_declaration_list
            (field_declaration
              type: (qualified_type
                package: (package_identifier) @_pkg
                name: (type_identifier) @_embed))))))
    (#eq? @_name "%s")
    (#eq? @_pkg "%s")
    (#eq? @_embed "%s")
  ]], type_name, pkg, embedded_type)

  local ok, query = pcall(vim.treesitter.query.parse, 'go', formatted)
  if not ok then
    return false
  end

  for _ in query:iter_matches(root, bufnr, 0, -1) do
    return true
  end
  return false
end

local function walk(node, fn)
  fn(node)
  for child in node:iter_children() do
    walk(child, fn)
  end
end

-- find_suite_run_test_name looks for a `suite.Run(t, ...)` call referencing
-- receiver_type and returns the name of the enclosing TestXxx function, since
-- that name can't reliably be derived from the suite struct's name alone.
M.find_suite_run_test_name = function(bufnr, receiver_type)
  local root = get_root(bufnr)
  if not root or not receiver_type then
    return nil
  end

  local found = nil
  walk(root, function(node)
    if found or node:type() ~= 'call_expression' then
      return
    end

    local fn_field = node:field('function')[1]
    if not fn_field or fn_field:type() ~= 'selector_expression' then
      return
    end

    local field_node = fn_field:field('field')[1]
    if not field_node or vim.treesitter.get_node_text(field_node, bufnr) ~= 'Run' then
      return
    end

    local args = node:field('arguments')[1]
    local args_text = args and vim.treesitter.get_node_text(args, bufnr) or ''
    if not args_text:match('%f[%w]' .. receiver_type .. '%f[%W]') then
      return
    end

    local outer = find_ancestor(node, { 'function_declaration' })
    local name_node = outer and outer:field('name')[1]
    if name_node then
      found = vim.treesitter.get_node_text(name_node, bufnr)
    end
  end)

  return found
end

local function get_type_decl_of_kind(bufnr, kind)
  local cur = node_at_cursor(bufnr)
  if not cur then
    return nil
  end
  local decl = find_ancestor(cur, { 'type_declaration' })
  if not decl then
    return nil
  end
  for spec in decl:iter_children() do
    if spec:type() == 'type_spec' then
      local type_field = spec:field('type')[1]
      if type_field and type_field:type() == kind then
        local name_node = spec:field('name')[1]
        return {
          name = name_node and vim.treesitter.get_node_text(name_node, bufnr),
          node = decl,
        }
      end
    end
  end
  return nil
end

M.get_struct_node_at_pos = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return get_type_decl_of_kind(bufnr, 'struct_type')
end

M.get_interface_node_at_pos = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return get_type_decl_of_kind(bufnr, 'interface_type')
end

M.get_type_node_at_pos = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local cur = node_at_cursor(bufnr)
  if not cur then
    return nil
  end
  local decl = find_ancestor(cur, { 'type_declaration' })
  if not decl then
    return nil
  end
  for spec in decl:iter_children() do
    if spec:type() == 'type_spec' then
      local name_node = spec:field('name')[1]
      return {
        name = name_node and vim.treesitter.get_node_text(name_node, bufnr),
        node = decl,
      }
    end
  end
  return nil
end

M.get_import_node_at_pos = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local cur = node_at_cursor(bufnr)
  if not cur then
    return nil
  end
  return find_ancestor(cur, { 'import_spec' })
end

M.get_module_at_pos = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local node = M.get_import_node_at_pos(bufnr)
  if not node then
    return nil
  end
  local text = vim.treesitter.get_node_text(node, bufnr)
  return (text:gsub('"', ''))
end

M.get_package_node_at_pos = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local root = get_root(bufnr)
  if not root then
    return nil
  end
  local ok, query = pcall(
    vim.treesitter.query.parse,
    'go',
    '((package_clause (package_identifier) @name) @clause)'
  )
  if not ok then
    return nil
  end
  for id, node in query:iter_captures(root, bufnr, 0, 10) do
    if query.captures[id] == 'name' then
      return { name = vim.treesitter.get_node_text(node, bufnr), node = node }
    end
  end
  return nil
end

M.in_func = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cur = node_at_cursor(bufnr)
  if not cur then
    return false
  end
  return find_ancestor(cur, { 'function_declaration', 'method_declaration' }) ~= nil
end

return M
