local source = {};

function source.new()
  return setmetatable({}, {__index = source})
end

function source:is_available()
  return vim.bo.filetype == "gitcommit"
end

function source:get_keyword_pattern()
  return [[\%(\k|\.\)\+]]
end

function source:get_trigger_characters()
  return {"@"}
end

function source:get_debug_name()
  return 'co-authored-by'
end

function source:_validate_options(params)
  PRINT({params = params})
  vim.validate({
    handles = {params.handles, "table"}
  })
  return params
end

function source:complete(request, callback)
  PRINT({request = request})
  local options = self:_validate_options(request.option)

  local input = string.sub(request.context.cursor_before_line, request.offset - 1)
  local prefix = string.sub(request.context.cursor_before_line, 1, request.offset - 1)

  local handles = options.handles or {}

  PRINT({
    input_length = #input,
    request_context_cursor_row = request.context.cursor.row,
    request_context_cursor_col = request.context.cursor.col,
  })

  if vim.startswith(input, '@') and (prefix == '@' or vim.endswith(prefix, ' @')) then
    local items = {}
    for _, handle in ipairs(handles) do
      local display = handle.name .. ' ' .. '<' .. handle.email .. '>'
      table.insert(items, {
        filterText = display,
        label = display,
        textEdit = {
          newText = display,
          range = {
            start = {
              line = request.context.cursor.row - 1,
              character = request.context.cursor.col - 1 - #input,
            },
            ['end'] = {
              line = request.context.cursor.row - 1,
              character = request.context.cursor.col - 1,
            }
          }
        }
      })
    end
    callback({
      items = items,
      isIncomplete = true
    })
  else
    callback({isIncomplete = true})
  end
end

return source
