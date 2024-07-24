FILE = ""

function RunCode(code)
  local keywords = { "set", "global", "to", "change", "by", "define", "return", "class", "if", "then", "else", "repeat", "until",
    "skip", "stop", "while", "for", "each", "in", "end" }
  local binary_operators = { "+", "-", "*", "/", "or", "and", "mod" }
  local unary_operators = { "not" }

  local functions = {
    ["debug"] = {
      ["log"] = { ["arguments"] = { "x" } },
      ["warn"] = { ["arguments"] = { "x" } },
      ["error"] = { ["arguments"] = { "x" } }
    },
    ["math"] = {
      ["random"] = { ["arguments"] = { "min", "max" } },
      ["clamp"] = { ["arguments"] = { "x", "min", "max" } },
      ["min"] = { ["arguments"] = { "x", "min" } },
      ["max"] = { ["arguments"] = { "x", "max" } },
      ["exp"] = { ["arguments"] = { "base", "exp" } },
      ["abs"] = { ["arguments"] = { "x" } },
      ["floor"] = { ["arguments"] = { "x" } },
      ["ceiling"] = { ["arguments"] = { "x" } },
      ["round"] = { ["arguments"] = { "x", "decimals" } },
      ["sqrt"] = { ["arguments"] = { "x" } },
      ["sin"] = { ["arguments"] = { "x" } },
      ["cos"] = { ["arguments"] = { "x" } },
      ["tan"] = { ["arguments"] = { "x" } },
      ["asin"] = { ["arguments"] = { "x" } },
      ["acos"] = { ["arguments"] = { "x" } },
      ["atan"] = { ["arguments"] = { "x" } },
      ["sinh"] = { ["arguments"] = { "x" } },
      ["cosh"] = { ["arguments"] = { "x" } },
      ["tanh"] = { ["arguments"] = { "x" } },
      ["ln"] = { ["arguments"] = { "x" } },
      ["log"] = { ["arguments"] = { "base", "x" } },
      ["pi"] = { ["arguments"] = {} },
      ["euler"] = { ["arguments"] = {} },
      ["rad"] = { ["arguments"] = { "x" } },
      ["deg"] = { ["arguments"] = { "x" } }
    },
    ["string"] = {
      ["join"] = { ["arguments"] = { "x", "y" } },
      ["length"] = { ["arguments"] = { "x" } },
      ["letter"] = { ["arguments"] = { "x", "pos" } },
      ["contains"] = { ["arguments"] = { "x", "pattern" } },
      ["upper"] = { ["arguments"] = { "x" } },
      ["lower"] = { ["arguments"] = { "x" } },
      ["replace"] = { ["arguments"] = { "x", "pattern", "repl", "amount" } },
      ["split"] = { ["arguments"] = { "x", "sep" } },
      ["find"] = { ["arguments"] = { "x", "pattern" } }
    },
    ["control"] = {
      ["type"] = { ["arguments"] = { "x" } },
      ["wait"] = { ["arguments"] = { "x" } },
      ["tonumber"] = { ["arguments"] = { "x" } },
      ["tostring"] = { ["arguments"] = { "x" } }
    },
    ["list"] = {
      ["item"] = { ["arguments"] = { "x", "pos" } },
      ["add"] = { ["arguments"] = { "x", "y" } },
      ["insert"] = { ["arguments"] = { "x", "y", "pos" } },
      ["length"] = { ["arguments"] = { "x" } },
      ["position"] = { ["arguments"] = { "x", "y" } },
      ["delete"] = { ["arguments"] = { "x", "pos" } },
      ["replace"] = { ["arguments"] = { "x", "pos", "repl" } },
      ["contains"] = { ["arguments"] = { "x", "y" } },
      ["clear"] = { ["arguments"] = { "x" } },
      ["concatenate"] = { ["arguments"] = { "x", "sep" } }
    },
    ["instance"] = {
      ["new"] = { ["arguments"] = { "x" } },
      ["destroy"] = { ["arguments"] = { "x" } }
    }
  }

  local classes = {}

  local scopes = {}
  local in_scopes = {}

  local global_variables = {}

  function Scopes_new()
    table.insert(in_scopes, {})
  end

  function Scopes_add(element, value)
    if not scopes[element] then
      table.insert(in_scopes[#in_scopes], element)
    end
    scopes[element] = value
  end

  function Scopes_remove()
    for i, v in pairs(in_scopes[#in_scopes]) do
      scopes[v] = nil
    end
    table.remove(in_scopes, #in_scopes)
  end

  function Clamp(value, minimum, maximum)
    if value < minimum then
      return minimum
    end
    if value > maximum then
      return maximum
    end

    return value
  end

  function EqualLists(list1, list2)
    for i, v in pairs(list1) do
      if list1[i] ~= list2[i] then
        return false
      end
    end
    return true
  end

  function GetToken(value)
    local return_value = "whitespace"
    local s, e = pcall(function()
      if Find_in_array(binary_operators, value) > 0 then
        return_value = "binary operator"
      elseif Find_in_array(unary_operators, value) > 0 then
        return_value = "unary operator"
      elseif value == "(" then
        return_value = "open parenthesis"
      elseif value == ")" then
        return_value = "close parenthesis"
      elseif value == "=" then
        return_value = "equals"
      elseif tonumber(value) then
        return_value = "number"
      elseif (string.sub(value, 1, 1) == '"' and string.sub(value, #value, #value) == '"') or (string.sub(value, 1, 1) == "'" and string.sub(value, #value, #value) == "'") then
        return_value = "string"
      elseif value == "true" or value == "false" then
        return_value = "boolean"
      elseif value == "null" or value == nil then
        return_value = "null"
      elseif Find_in_array(keywords, value) > 0 then
        return_value = "keyword"
      elseif value ~= nil and value ~= "" and value ~= "\n" and value ~= " " then
        return_value = "identifier"
      end
    end)

    return return_value
  end

  function HasEnd(value)
    if value == "if" or value == "define" or value == "class" or value == "repeat" or value == "while" or value == "for" then
      return true
    end
    return false
  end

  function Wait(seconds)
    local start = os.time()
    repeat until os.time() > start + seconds
  end

  function Find_in_array(array, value)
    for i, v in pairs(array) do
      if v == value then
        return i
      end
    end
    return 0
  end

  function Find_index_in_array(array, index)
    for i, v in pairs(array) do
      if i == index then
        return true
      end
    end
    return false
  end

  function Round(value)
    if value then
      if value - math.floor(value) < math.ceil(value) - value then
        return math.floor(value)
      else
        return math.ceil(value)
      end
    end
  end

  function RemoveMagic(char)
    if char == "(" or char == ")" or char == "." or char == "+" or char == "-" or char == "*" or char == "[" or char == "^" or char == "$" or char == "%" then
      return "%%" .. char
    else
      return char
    end
  end

  local code_chunks = {}

  local chunk = ""
  local open_string = ""

  local allowed_chars = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
  local string_index = 0
  local skip_index = 0
  for i = 1, #code do
    if skip_index == i then
      goto continue
    end

    local char = string.sub(code, i, i)

    if char == '"' and open_string == "" then
      if chunk ~= "" then
        table.insert(code_chunks, chunk)
      end
      chunk = ""

      string_index = i
      open_string = '"'
    elseif char == "'" and open_string == "" then
      if chunk ~= "" then
        table.insert(code_chunks, chunk)
      end
      chunk = ""

      string_index = i
      open_string = "'"
    end

    if char == " " or not string.find(allowed_chars, RemoveMagic(char)) then
      if open_string ~= "" then
        chunk = chunk .. char
      else
        if chunk ~= "" then
          table.insert(code_chunks, chunk)
        end
        if char ~= " " then
          table.insert(code_chunks, char)
        end
        chunk = ""
      end
    else
      if string.find(allowed_chars, RemoveMagic(char)) == 1 then
        if chunk ~= "" then
          table.insert(code_chunks, chunk)
        end
        if char ~= " " then
          table.insert(code_chunks, char)
        end
        chunk = ""

        goto continue
      end
      if open_string ~= "" then
        chunk = chunk .. char
      else
        if tonumber(char) and not tonumber(string.sub(code, i + 1, i + 1)) then
          chunk = chunk .. char
          if string.sub(code, i + 1, i + 1) == "." and tonumber(string.sub(code, i + 2, i + 2)) then
            chunk = chunk .. string.sub(code, i + 1, i + 1)
            skip_index = i + 1
          else
            table.insert(code_chunks, chunk)
            chunk = ""
          end
        else
          chunk = chunk .. char
        end
      end
    end

    if char == '"' and open_string == '"' and string_index ~= i then
      if chunk ~= "" then
        table.insert(code_chunks, chunk)
      end
      chunk = ""

      open_string = ""
    elseif char == "'" and open_string == "'" and string_index ~= i then
      if chunk ~= "" then
        table.insert(code_chunks, chunk)
      end
      chunk = ""

      open_string = ""
    end

    ::continue::
  end
  if chunk ~= "" then
    table.insert(code_chunks, chunk)
  end

  local chunk_index = 0
  while not (chunk_index > #code_chunks) do
    chunk_index = chunk_index + 1

    if chunk_index > #code_chunks then
      break
    end

    if GetToken(code_chunks[chunk_index]) == "number" then
      code_chunks[chunk_index] = tonumber(code_chunks[chunk_index])
    end
    if GetToken(code_chunks[chunk_index]) == "whitespace" then
      table.remove(code_chunks, chunk_index)
      chunk_index = chunk_index - 1
    end
  end
  if #code == 0 then
    return
  end
  
  function Parse_terms(tokens)
    local left = Parse_factors(tokens)

    if tokens[1] == "+" or tokens[1] == "-" then
      local type = "sum"
      if tokens[1] == "-" then
        type = "difference"
      end
      table.remove(tokens, 1)

      return { ["type"] = type, ["left"] = left, ["right"] = Parse_terms(tokens) }
    end

    return left
  end

  function Parse_factors(tokens)
    local left = Parse_logic(tokens)

    if tokens[1] == "*" or tokens[1] == "/" or tokens[1] == "mod" then
      local type = "product"
      if tokens[1] == "/" then
        type = "quotient"
      elseif tokens[1] == "mod" then
        type = "modulo"
      end
      table.remove(tokens, 1)

      return { ["type"] = type, ["left"] = left, ["right"] = Parse_factors(tokens) }
    end
    return left
  end

  function Parse_logic(tokens)
    local left = Parse_parentheses(tokens)

    if tokens[1] == "=" then
      table.remove(tokens, 1)

      return { ["type"] = "equality", ["left"] = left, ["right"] = Parse_logic(tokens) }
    elseif tostring(tokens[1]) .. tostring(tokens[2]) == "<=" then
      table.remove(tokens, 1)
      table.remove(tokens, 1)

      return { ["type"] = "inferior equal", ["left"] = left, ["right"] = Parse_logic(tokens) }
    elseif tostring(tokens[1]) .. tostring(tokens[2]) == ">=" then
      table.remove(tokens, 1)
      table.remove(tokens, 1)

      return { ["type"] = "superior equal", ["left"] = left, ["right"] = Parse_logic(tokens) }
    elseif tokens[1] == "<" then
      table.remove(tokens, 1)

      return { ["type"] = "inferiority", ["left"] = left, ["right"] = Parse_logic(tokens) }
    elseif tokens[1] == ">" then
      table.remove(tokens, 1)

      return { ["type"] = "superiority", ["left"] = left, ["right"] = Parse_logic(tokens) }
    elseif tokens[1] == "or" then
      table.remove(tokens, 1)

      return { ["type"] = "or gate", ["left"] = left, ["right"] = Parse_logic(tokens) }
    elseif tokens[1] == "and" then
      table.remove(tokens, 1)

      return { ["type"] = "and gate", ["left"] = left, ["right"] = Parse_logic(tokens) }
    elseif left["value"] == "not" then
      return { ["type"] = "not gate", ["right"] = Parse_logic(tokens) }
    end
    return left
  end

  function Parse_parentheses(tokens)
    if GetToken(tokens[1]) == "open parenthesis" then
      table.remove(tokens, 1)
      local terms = Parse_terms(tokens)
      if GetToken(tokens[1]) ~= "close parenthesis" then
        error("expected ')'")
      end
      
      table.remove(tokens, 1)
      return terms
    end
    return Parse_literal(tokens)
  end

  function Parse_literal(tokens)
    if #tokens == 0 then
      error("expected number, string, boolean or identifier")
    end

    local literal = tokens[1]
    table.remove(tokens, 1)

    if literal == "!" and tokens[1] == "-" and tokens[2] == "-" then
      for i = 1, 2 do
        table.remove(tokens, 1)
      end
      P_comment(tokens)
      literal = tokens[1]
      table.remove(tokens, 1)
    end

    if literal == "{" then
      local list = {}
      while tokens[1] ~= "}" do
        if tokens[1] == nil then
          error("expected }")
        end
        if GetToken(tokens[1]) ~= "identifier" and GetToken(tokens[1]) ~= "number" and GetToken(tokens[1]) ~= "string" and GetToken(tokens[1]) ~= "boolean" and GetToken(tokens[1]) ~= "null" and GetToken(tokens[1]) ~= "unary operator" and literal ~= "{" then
          error("expected number, string, boolean, identifier or unary operator")
        end
        if tokens[2] == ":" then
          local dictValue = Parse(tokens, {}, false)[1]
          table.remove(tokens, 1)

          if GetToken(tokens[1]) ~= "identifier" and GetToken(tokens[1]) ~= "number" and GetToken(tokens[1]) ~= "string" and GetToken(tokens[1]) ~= "boolean" and GetToken(tokens[1]) ~= "null" and GetToken(tokens[1]) ~= "unary operator" and literal ~= "{" then
            error("expected identifier, number, string, boolean, identifier or unary operator")
          end

          list[dictValue["value"]] = Parse(tokens, {}, false)[1]
        else
          table.insert(list, Parse(tokens, {}, false)[1])
        end

        if tokens[1] == "," then
          table.remove(tokens, 1)
        elseif tokens[1] ~= "}" then
          error("expected ',' or '}'")
        end
      end
      table.remove(tokens, 1)
      return { ["type"] = "list", ["value"] = list }
    elseif GetToken(literal) == "identifier" or GetToken(literal) == "number" or GetToken(literal) == "string" or GetToken(literal) == "boolean" or GetToken(literal) == "null" or GetToken(literal) == "unary operator" then
      if GetToken(literal) == "identifier" and GetToken(tokens[1]) == "open parenthesis" then
        table.remove(tokens, 1)

        local arguments = {}

        if GetToken(tokens[1]) ~= "close parenthesis" then
          repeat
            if GetToken(tokens[1]) ~= "identifier" and GetToken(tokens[1]) ~= "number" and GetToken(tokens[1]) ~= "string" and GetToken(tokens[1]) ~= "boolean" and GetToken(tokens[1]) ~= "null" and GetToken(tokens[1]) ~= "unary operator" and literal ~= "{" then
              error("expected number, string, boolean, identifier or unary operator")
            end
            table.insert(arguments, Parse(tokens, {}, false)[1])

            if tokens[1] ~= "," and tokens[1] ~= ")" then
              if tokens[1] ~= ")" then
                error("expected ')'")
              end
              error("expected ','")
            end
            if tokens[1] ~= ")" then
              table.remove(tokens, 1)
            end
          until GetToken(tokens[1]) ~= "identifier" and GetToken(tokens[1]) ~= "number" and GetToken(tokens[1]) ~= "string" and GetToken(tokens[1]) ~= "boolean" and GetToken(tokens[1]) ~= "null" and GetToken(tokens[1]) ~= "unary operator" and literal ~= "{" and tokens[1] ~= ","
        end

        if GetToken(tokens[1]) ~= "close parenthesis" then
          error("expected ')'")
        end
        table.remove(tokens, 1)

        return { ["type"] = GetToken(literal), ["value"] = literal, ["arguments"] = arguments }
      end

      if GetToken(literal) == "identifier" and tokens[1] == "." then
        table.remove(tokens, 1)
        return { ["type"] = GetToken(literal), ["value"] = literal, ["path"] = Parse_literal(tokens) }
      end

      return { ["type"] = GetToken(literal), ["value"] = literal }
    else
      error("expected number, string, boolean, identifier or unary operator, got '" .. literal .. "'")
    end
  end

  -- Keywords

  function P_set(tokens, global)
    if GetToken(tokens[1]) ~= "identifier" then
      error("expected identifier")
    end
    local variable_name = tokens[1]
    table.remove(tokens, 1)

    if tokens[1] ~= "to" then
      error("expected 'to'")
    end
    table.remove(tokens, 1)

    local type = "variable declaration"
    if global then
      type = "global declaration"
    end

    return { ["type"] = type, ["variable"] = variable_name, ["value"] = Parse(tokens, {}, false)[1] }
  end

  function P_change(tokens)
    if GetToken(tokens[1]) ~= "identifier" then
      error("expected identifier")
    end
    local variable_name = tokens[1]
    table.remove(tokens, 1)

    if tokens[1] ~= "by" then
      error("expected 'by'")
    end
    table.remove(tokens, 1)

    local type = "variable change"

    return { ["type"] = type, ["variable"] = variable_name, ["value"] = Parse(tokens, {}, false)[1] }
  end

  function P_define(tokens)
    if GetToken(tokens[1]) ~= "identifier" then
      error("expected identifier")
    end
    local function_name = tokens[1]
    table.remove(tokens, 1)

    if GetToken(tokens[1]) ~= "open parenthesis" then
      error("expected '('")
    end
    table.remove(tokens, 1)

    local function_arguments = {}

    if GetToken(tokens[1]) ~= "close parenthesis" then
      repeat
        if GetToken(tokens[1]) ~= "identifier" then
          error("expected identifier")
        end
        table.insert(function_arguments, tokens[1])

        table.remove(tokens, 1)
        if tokens[1] ~= "," and tokens[1] ~= ")" then
          error("expected ','")
        end
        if tokens[1] ~= ")" then
          table.remove(tokens, 1)
        end
      until GetToken(tokens[1]) ~= "identifier" and tokens[1] ~= ","
    end

    if GetToken(tokens[1]) ~= "close parenthesis" then
      error("expected ')'")
    end
    table.remove(tokens, 1)

    local inFunction = {}

    if Find_in_array(tokens, "end") == 0 then
      error("expected end")
    end

    local scope_count = 0
    local scope_index = 0
    while true do
      scope_index = scope_index + 1
      if HasEnd(tokens[scope_index]) then
        scope_count = scope_count + 1
      end
      if tokens[scope_index] == "end" then
        if scope_count == 0 then
          break
        end
        scope_count = scope_count - 1
      end
      table.insert(inFunction, tokens[scope_index])
    end

    for i = 1, #inFunction + 1 do
      table.remove(tokens, 1)
    end

    return {
      ["type"] = "function declaration",
      ["function"] = function_name,
      ["arguments"] = function_arguments,
      ["body"] = Parse(inFunction, {}, true)
    }
  end

  function P_class(tokens)
    if GetToken(tokens[1]) ~= "identifier" then
      error("expected identifier")
    end
    local class_name = tokens[1]
    table.remove(tokens, 1)

    if GetToken(tokens[1]) ~= "open parenthesis" then
      error("expected '('")
    end
    table.remove(tokens, 1)

    local class_arguments = {}

    if GetToken(tokens[1]) ~= "close parenthesis" then
      repeat
        if GetToken(tokens[1]) ~= "identifier" then
          error("expected identifier")
        end
        table.insert(class_arguments, tokens[1])

        table.remove(tokens, 1)
        if tokens[1] ~= "," and tokens[1] ~= ")" then
          error("expected ','")
        end
        if tokens[1] ~= ")" then
          table.remove(tokens, 1)
        end
      until GetToken(tokens[1]) ~= "identifier" and tokens[1] ~= ","
    end

    if GetToken(tokens[1]) ~= "close parenthesis" then
      error("expected ')'")
    end
    table.remove(tokens, 1)

    local inClass = {}

    if Find_in_array(tokens, "end") == 0 then
      error("expected end")
    end

    local scope_count = 0
    local scope_index = 0
    while true do
      scope_index = scope_index + 1
      if HasEnd(tokens[scope_index]) then
        scope_count = scope_count + 1
      end
      if tokens[scope_index] == "end" then
        if scope_count == 0 then
          break
        end
        scope_count = scope_count - 1
      end
      table.insert(inClass, tokens[scope_index])
    end

    for i = 1, #inClass + 1 do
      table.remove(tokens, 1)
    end

    return {
      ["type"] = "class declaration",
      ["class"] = class_name,
      ["arguments"] = class_arguments,
      ["body"] = Parse(inClass, {}, true)
    }
  end

  function P_if(tokens)
    local condition = Parse(tokens, {}, false)[1]
    if tokens[1] ~= "then" then
      error("expected 'then'")
    end
    table.remove(tokens, 1)

    local inStatement = {}
    local elseStatement = {}
    local elifStatement = {}
    if Find_in_array(tokens, "end") == 0 then
      error("expected end")
    end
    if Find_in_array(tokens, "else") ~= 0 then
      if Find_in_array(tokens, "else") < Find_in_array(tokens, "end") then
        local scope_count = 0
        local scope_index = 0

        local found_else = true
        while true do
          scope_index = scope_index + 1
          if HasEnd(tokens[scope_index]) then
            scope_count = scope_count + 1
          end
          if tokens[scope_index] == "else" then
            if scope_count == 0 then
              break
            end
            scope_count = scope_count - 1
          end
          if scope_index > Find_in_array(tokens, "else") then
            found_else = false
            break
          end
        end

        if found_else then
          for i = 1, scope_index - 1 do
            table.insert(inStatement, tokens[i])
          end
          for i = 1, #inStatement + 1 do
            table.remove(tokens, 1)
          end

          local scope_count = 0
          local scope_index = 0
          while true do
            scope_index = scope_index + 1
            if HasEnd(tokens[scope_index]) then
              scope_count = scope_count + 1
            end
            if tokens[scope_index] == "end" then
              if scope_count == 0 then
                break
              end
              scope_count = scope_count - 1
            end
            table.insert(elseStatement, tokens[scope_index])
          end

          for i = 1, #elseStatement + 1 do
            table.remove(tokens, 1)
          end

          return {
            ["type"] = "if statement",
            ["condition"] = condition,
            ["body"] = Parse(inStatement, {}, true),
            ["else body"] = Parse(elseStatement, {}, true)
          }
        end
      end
    elseif Find_in_array(tokens, "elif") ~= 0 then
      if Find_in_array(tokens, "elif") < Find_in_array(tokens, "end") then
        local scope_count = 0
        local scope_index = 0

        local found_elif = true
        while true do
          scope_index = scope_index + 1
          if HasEnd(tokens[scope_index]) then
            scope_count = scope_count + 1
          end
          if tokens[scope_index] == "elif" then
            if scope_count == 0 then
              break
            end
            scope_count = scope_count - 1
          end
          if scope_index > Find_in_array(tokens, "elif") then
            found_elif = false
            break
          end
        end

        if found_elif then
          for i = 1, scope_index - 1 do
            table.insert(inStatement, tokens[i])
          end
          for i = 1, #inStatement + 1 do
            table.remove(tokens, 1)
          end

          local scope_count = 0
          local scope_index = 0

          table.insert(elifStatement, "if")
          while true do
            scope_index = scope_index + 1
            if HasEnd(tokens[scope_index]) then
              scope_count = scope_count + 1
            end
            if tokens[scope_index] == "end" then
              if scope_count == 0 then
                table.insert(elifStatement, tokens[scope_index])
                break
              end
              scope_count = scope_count - 1
            end

            table.insert(elifStatement, tokens[scope_index])
          end

          for i = 1, #elifStatement - 1 do
            table.remove(tokens, 1)
          end
          
          return {
            ["type"] = "if statement",
            ["condition"] = condition,
            ["body"] = Parse(inStatement, {}, true),
            ["else body"] = Parse(elifStatement, {}, true)
          }
        end
      end
    end

    local scope_count = 0
    local scope_index = 0
    while true do
      scope_index = scope_index + 1
      if HasEnd(tokens[scope_index]) then
        scope_count = scope_count + 1
      end
      if tokens[scope_index] == "end" then
        if scope_count == 0 then
          break
        end
        scope_count = scope_count - 1
      end
      table.insert(inStatement, tokens[scope_index])
    end

    for i = 1, #inStatement + 1 do
      table.remove(tokens, 1)
    end

    return { ["type"] = "if statement", ["condition"] = condition, ["body"] = Parse(inStatement, {}, true) }
  end

  function P_repeat(tokens)
    if tokens[1] == "until" then
      table.remove(tokens, 1)

      local condition = Parse(tokens, {}, false)[1]

      local inLoop = {}
      if Find_in_array(tokens, "end") == 0 then
        error("expected end")
      end

      local scope_count = 0
      local scope_index = 0
      while true do
        scope_index = scope_index + 1
        if HasEnd(tokens[scope_index]) then
          scope_count = scope_count + 1
        end
        if tokens[scope_index] == "end" then
          if scope_count == 0 then
            break
          end
          scope_count = scope_count - 1
        end
        table.insert(inLoop, tokens[scope_index])
      end

      for i = 1, #inLoop + 1 do
        table.remove(tokens, 1)
      end

      return { ["type"] = "repeat until loop", ["condition"] = condition, ["body"] = Parse(inLoop, {}, true) }
    else
      local amount = Parse(tokens, {}, false)[1]

      local inLoop = {}
      if Find_in_array(tokens, "end") == 0 then
        error("expected end")
      end

      local scope_count = 0
      local scope_index = 0
      while true do
        scope_index = scope_index + 1
        if HasEnd(tokens[scope_index]) then
          scope_count = scope_count + 1
        end
        if tokens[scope_index] == "end" then
          if scope_count == 0 then
            break
          end
          scope_count = scope_count - 1
        end
        table.insert(inLoop, tokens[scope_index])
      end

      for i = 1, #inLoop + 1 do
        table.remove(tokens, 1)
      end


      return { ["type"] = "repeat amount loop", ["amount"] = amount, ["body"] = Parse(inLoop, {}, true) }
    end
  end

  function P_while(tokens)
    local condition = Parse(tokens, {}, false)[1]

    local inLoop = {}
    if Find_in_array(tokens, "end") == 0 then
      error("expected end")
    end

    local scope_count = 0
    local scope_index = 0
    while true do
      scope_index = scope_index + 1
      if HasEnd(tokens[scope_index]) then
        scope_count = scope_count + 1
      end
      if tokens[scope_index] == "end" then
        if scope_count == 0 then
          break
        end
        scope_count = scope_count - 1
      end
      table.insert(inLoop, tokens[scope_index])
    end

    for i = 1, #inLoop + 1 do
      table.remove(tokens, 1)
    end

    return { ["type"] = "while loop", ["condition"] = condition, ["body"] = Parse(inLoop, {}, true) }
  end

  function P_for(tokens)
    if tokens[1] ~= "each" then
      error("expected 'each'")
    end
    table.remove(tokens, 1)
    
    if GetToken(tokens[1]) ~= "identifier" then
      error("expected identifier")
    end
    local counter = Parse(tokens, {}, false)[1]

    local start
    local value
    if tokens[1] == ":" then
      table.remove(tokens, 1)
      start = Parse(tokens, {}, false)[1]
    elseif tokens[1] == "item" then
      table.remove(tokens, 1)
      if GetToken(tokens[1]) ~= "identifier" then
        error("expected identifier")
      end
      value = Parse(tokens, {}, false)[1]
    else
      start = 1
    end

    if tokens[1] ~= "in" then
      error("expected 'in'")
    end
    table.remove(tokens, 1)

    local goal = Parse(tokens, {}, false)[1]

    local inLoop = {}
    if Find_in_array(tokens, "end") == 0 then
      error("expected end")
    end

    local scope_count = 0
    local scope_index = 0
    while true do
      scope_index = scope_index + 1
      if HasEnd(tokens[scope_index]) then
        scope_count = scope_count + 1
      end
      if tokens[scope_index] == "end" then
        if scope_count == 0 then
          break
        end
        scope_count = scope_count - 1
      end
      table.insert(inLoop, tokens[scope_index])
    end

    for i = 1, #inLoop + 1 do
      table.remove(tokens, 1)
    end

    if value then
      return { ["type"] = "for loop", ["counter"] = counter, ["value"] = value, ["list"] = goal, ["body"] = Parse(inLoop, {}, true) }
    end
    return { ["type"] = "for loop", ["counter"] = counter, ["start"] = start, ["goal"] = goal, ["body"] = Parse(inLoop, {}, true) }
  end

  function P_comment(tokens)
    local inComment = {}
    if not (Find_in_array(tokens, "-") > 0 and tokens[Find_in_array(tokens, "-") + 1] == "-" and tokens[Find_in_array(tokens, "-") + 2] == "!") then
      error("expected '--!' to close comment")
    end
    repeat
      table.insert(inComment, tokens[1])
      table.remove(tokens, 1)
    until tokens[1] == "-" and tokens[2] == "-" and tokens[3] == "!"
    for i = 1, 3 do
      table.remove(tokens, 1)
    end

    return nil
  end

  -- Parsing/Interpreting

  function Parse(tokens, AST, recursion)
    if GetToken(tokens[1]) == "keyword" then
      local keyword = tokens[1]
      table.remove(tokens, 1)

      if keyword == "set" or keyword == "global" then
        table.insert(AST, P_set(tokens, keyword == "global"))
      elseif keyword == "change" then
        table.insert(AST, P_change(tokens))
      elseif keyword == "define" then
        table.insert(AST, P_define(tokens))
      elseif keyword == "class" then
        table.insert(AST, P_class(tokens))
      elseif keyword == "if" then
        table.insert(AST, P_if(tokens))
      elseif keyword == "repeat" then
        table.insert(AST, P_repeat(tokens))
      elseif keyword == "while" then
        table.insert(AST, P_while(tokens))
      elseif keyword == "for" then
        table.insert(AST, P_for(tokens))
      else
        if keyword == "return" or keyword == "skip" or keyword == "stop" then
          if keyword == "return" then
            table.insert(AST, { ["type"] = "keyword", ["keyword"] = keyword, ["value"] = Parse(tokens, {}, false)[1] })
          else
            table.insert(AST, { ["type"] = "keyword", ["keyword"] = keyword })
          end
        else
          table.insert(AST, Parse_terms(tokens))
        end
      end
    else
      if tokens[1] == "!" and tokens[2] == "-" and tokens[3] == "-" then
        for i = 1, 3 do
          table.remove(tokens, 1)
        end
        P_comment(tokens)
      else
        table.insert(AST, Parse_terms(tokens))
      end
    end
    if recursion and #tokens > 0 then
      return Parse(tokens, AST, true)
    end
    return AST
  end

  local current_path = functions
  local last_path = {}

  Scopes_new()

  local log_values = {}

  local function copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
  end

  function Interpret(node)
    local return_value = nil
    if node == nil then
      return nil
    end

    if GetToken(node) == "string" or GetToken(node) == "number" or GetToken(node) == "boolean" then
      -- String, Number or Boolean
      return node
    elseif node["type"] == "sum" then
      -- Sum
      local left = Interpret(node["left"])
      local right = Interpret(node["right"])
      if GetToken(left) ~= "number" or GetToken(right) ~= "number" then
        error("expected number")
      end

      return left + right
    elseif node["type"] == "difference" then
      -- Difference
      local left = Interpret(node["left"])
      local right = Interpret(node["right"])
      if GetToken(left) ~= "number" or GetToken(right) ~= "number" then
        error("expected number")
      end

      return Interpret(node["left"]) - Interpret(node["right"])
    elseif node["type"] == "product" then
      -- Product
      local left = Interpret(node["left"])
      local right = Interpret(node["right"])
      if GetToken(left) ~= "number" or GetToken(right) ~= "number" then
        error("expected number")
      end

      return left * right
    elseif node["type"] == "quotient" then
      -- Quotient
      local left = Interpret(node["left"])
      local right = Interpret(node["right"])
      if GetToken(left) ~= "number" or GetToken(right) ~= "number" then
        error("expected number")
      end

      return left / right
    elseif node["type"] == "equality" then
      -- Equality
      local left = Interpret(node["left"])
      local right = Interpret(node["right"])
      if GetToken(left) == "string" then
        left = string.sub(left, 2, #left - 1)
      end
      if GetToken(right) == "string" then
        right = string.sub(right, 2, #right - 1)
      end

      if GetToken(left) == "number" then
        left = tonumber(left)
      end
      if GetToken(right) == "number" then
        right = tonumber(right)
      end

      return tostring(left == right)
    elseif node["type"] == "inferior equal" then
      -- Inferior Equal
      local left = Interpret(node["left"])
      local right = Interpret(node["right"])
      if GetToken(left) ~= "number" or GetToken(right) ~= "number" then
        error("expected number")
      end

      return tostring(tonumber(left) <= tonumber(right))
    elseif node["type"] == "superior equal" then
      -- Superior Equal

      local left = Interpret(node["left"])
      local right = Interpret(node["right"])
      if GetToken(left) ~= "number" or GetToken(right) ~= "number" then
        error("expected number")
      end

      return tostring(tonumber(left) >= tonumber(right))
    elseif node["type"] == "inferiority" then
      -- Inferiority
      local left = Interpret(node["left"])
      local right = Interpret(node["right"])
      if GetToken(left) ~= "number" or GetToken(right) ~= "number" then
        error("expected number")
      end

      return tostring(tonumber(left) < tonumber(right))
    elseif node["type"] == "superiority" then
      -- Superiority
      local left = Interpret(node["left"])
      local right = Interpret(node["right"])
      if GetToken(left) ~= "number" or GetToken(right) ~= "number" then
        error("expected number")
      end

      return tostring(tonumber(left) > tonumber(right))
    elseif node["type"] == "or gate" then
      -- OR Gate
      if Interpret(node["left"]) == "true" or Interpret(node["right"]) == "true" then
        return "true"
      end
      return "false"
    elseif node["type"] == "and gate" then
      -- AND Gate
      if Interpret(node["left"]) == "true" and Interpret(node["right"]) == "true" then
        return "true"
      end
      return "false"
    elseif node["type"] == "not gate" then
      -- NOT Gate
      if Interpret(node["right"]) == "true" then
        return "false"
      end
      return "true"
    elseif node["type"] == "modulo" then
      -- Modulo
      local left = Interpret(node["left"])
      local right = Interpret(node["right"])
      if GetToken(left) ~= "number" or GetToken(right) ~= "number" then
        error("expected number")
      end

      return tostring(left % right)
    elseif node["type"] == "variable declaration" or node["type"] == "global declaration" then
      -- Variable Declaration
      if node["type"] == "variable declaration" then
        local value = Interpret(node["value"])
        if value == nil then
          Scopes_add(node["variable"], "null")
          return nil
        end

        if type(value) == "table" then
          if value["class"] then
            current_path[node["variable"]] = {
              ["arguments"] = value["arguments"],
              ["class"] = value["class"]
            }

            return nil
          end
          
          Scopes_add(node["variable"], copy(value))

          return nil
        end

        Scopes_add(node["variable"], value)
      else
        local value = Interpret(node["value"])
        if value == nil then
          global_variables[node["variable"]] = "null"
          return nil
        end
        global_variables[node["variable"]] = value
      end
    elseif node["type"] == "variable change" then
      -- Variable Change
      if global_variables[node["variable"]] then
        if GetToken(global_variables[node["variable"]]) ~= "number" then
          error("expected number")
        end
        global_variables[node["variable"]] = global_variables[node["variable"]] + Interpret(node["value"])
      elseif scopes[node["variable"]] then
        if GetToken(scopes[node["variable"]]) ~= "number" then
          error("expected number")
        end
        scopes[node["variable"]] = scopes[node["variable"]] + Interpret(node["value"])
      else
        error("trying to change variable '" .. node["variable"] .. "' never declared")
      end
    elseif node["type"] == "function declaration" then
      -- Function Declaration
      current_path[node["function"]] = {
        ["arguments"] = node["arguments"],
        ["body"] = node["body"]
      }
    elseif node["type"] == "class declaration" then
      -- Class Declaration
      classes[node["class"]] = {
        ["arguments"] = node["arguments"],
        ["class"] = node["body"]
      }
    elseif node["type"] == "if statement" then
      -- If Statement
      if Interpret(node["condition"]) == "true" then
        Scopes_new()
        for i, v in pairs(node["body"]) do
          local interpreted = Interpret(node["body"][i])
          if interpreted then
            if interpreted["type"] == "keyword" then
              if interpreted["keyword"] == "return" then
                return_value = interpreted
              end
            end
          end
        end
        Scopes_remove()

        return return_value
      elseif node["else body"] then
        Scopes_new()
        for i, v in pairs(node["else body"]) do
          local interpreted = Interpret(node["else body"][i])
          if interpreted then
            if interpreted["type"] == "keyword" then
              if interpreted["keyword"] == "return" then
                return_value = interpreted
              end
            end
          end
        end
        Scopes_remove()

        return return_value
      end
    elseif node["type"] == "repeat amount loop" then
      -- Repeat Amount Loop
      if GetToken(Interpret(node["amount"])) ~= "number" then
        error("expected number")
      end
      Scopes_new()
      if Interpret(node["amount"]) > 0 then
        for j = 1, Round(Interpret(node["amount"])) do
          for i, v in pairs(node["body"]) do
            local interpreted = Interpret(node["body"][i])
            if interpreted then
              if interpreted["type"] == "keyword" then
                if interpreted["keyword"] == "skip" then
                  break
                elseif interpreted["keyword"] == "stop" then
                  goto stop
                end
                return_value = interpreted
              end
            end
          end
        end
        ::stop::
      end
      Scopes_remove()
    elseif node["type"] == "repeat until loop" then
      -- Repeat Until Loop
      if Interpret(node["condition"]) == "false" then
        Scopes_new()
        repeat
          for i, v in pairs(node["body"]) do
            local interpreted = Interpret(node["body"][i])
            if interpreted then
              if interpreted["type"] == "keyword" then
                if interpreted["keyword"] == "skip" then
                  break
                elseif interpreted["keyword"] == "stop" then
                  goto stop
                end
                return_value = interpreted
              end
            end
          end
        until Interpret(node["condition"]) == "true"
        ::stop::
        Scopes_remove()
      end
    elseif node["type"] == "while loop" then
      -- While Loop
      if Interpret(node["condition"]) == "true" then
        Scopes_new()
        repeat
          for i, v in pairs(node["body"]) do
            local interpreted = Interpret(node["body"][i])
            if interpreted then
              if interpreted["type"] == "keyword" then
                if interpreted["keyword"] == "skip" then
                  break
                elseif interpreted["keyword"] == "stop" then
                  goto stop
                end
                return_value = interpreted
              end
            end
          end
        until Interpret(node["condition"]) == "false"
        ::stop::
        Scopes_remove()
      end
    elseif node["type"] == "for loop" then
      -- For Loop
      Scopes_new()
      if node["value"] then
        local list = Interpret(node["list"])
        if type(list) ~= "table" then
          error("expected list")
        end

        local ordered_index = {}
        local ordered_value = {}

        for i, v in pairs(list) do
          table.insert(ordered_index, i)
        end
        table.sort(ordered_index)

        for i, v in pairs(ordered_index) do
          table.insert(ordered_value, list[v])
        end
        
        for j, b in pairs(ordered_index) do
          Scopes_add(node["counter"]["value"], b)
          Scopes_add(node["value"]["value"], Interpret(ordered_value[j]))
          for i, v in pairs(node["body"]) do
            local interpreted = Interpret(node["body"][i])
            if type(interpreted) == "table" then
              if interpreted then
                if interpreted["type"] == "keyword" then
                  if interpreted["keyword"] == "skip" then
                    break
                  elseif interpreted["keyword"] == "stop" then
                    goto stop
                  end
                  return_value = interpreted
                end
              end
            end
          end
        end
      else
        Scopes_add(node["counter"]["value"], Interpret(node["start"]) - 1)
        for j = Interpret(node["start"]), Interpret(node["goal"]) do
          scopes[node["counter"]["value"]] = scopes[node["counter"]["value"]] + 1
          for i, v in pairs(node["body"]) do
            local interpreted = Interpret(node["body"][i])
            if type(interpreted) == "table" then
              if interpreted then
                if interpreted["type"] == "keyword" then
                  if interpreted["keyword"] == "skip" then
                    break
                  elseif interpreted["keyword"] == "stop" then
                    goto stop
                  end
                  return_value = interpreted
                end
              end
            end
          end
        end
      end
      ::stop::
      Scopes_remove()
    elseif node["type"] == "number" or node["type"] == "string" or node["type"] == "boolean" or node["type"] == "null" then
      -- Literal
      return node["value"]
    elseif node["type"] == "identifier" then
      -- Identifier

      if scopes[node["value"]] or global_variables[node["value"]] then
        -- Variable Call
        if node["path"] and not functions[scopes[node["value"]]] then
          error("'"..node["value"].."' is not a class")
        end

        return global_variables[node["value"]] or scopes[node["value"]]
      elseif functions[node["value"]] then
        -- Function Call

        if functions[node["value"]]["body"] then
          -- User Function
          if not node["arguments"] and #functions[node["value"]]["arguments"] ~= 0 then
            error("expected " .. #functions[node["value"]]["arguments"] .. " arguments, got 0")
          elseif node["arguments"] then
            if #functions[node["value"]]["arguments"] ~= #node["arguments"] then
              error("expected " .. #functions[node["value"]]["arguments"] .. " arguments, got " .. #node["arguments"])
            end
          end

          Scopes_new()
          for i, v in pairs(functions[node["value"]]["arguments"]) do
            Scopes_add(v, Interpret(node["arguments"][i]))
          end

          local return_value
          for i, v in pairs(functions[node["value"]]["body"]) do
            local interpreted = Interpret(functions[node["value"]]["body"][i])
            if interpreted then
              if interpreted["type"] == "keyword" then
                if interpreted["keyword"] == "return" then
                  return_value = Interpret(interpreted["value"])
                  break
                end
              end
            end
          end
          Scopes_remove()

          return return_value
        elseif functions[node["value"]]["class"] then
          -- Class
          Scopes_new()
          for i, v in pairs(functions[node["value"]]["arguments"]) do
            Scopes_add(i, v)
          end

          for i, v in pairs(functions[node["value"]]["class"]) do
            Interpret(functions[node["value"]]["class"][i])
          end

          local return_value
          if node["path"] then
            return_value = Interpret(node["path"])
          end

          for i, v in pairs(functions[node["value"]]["arguments"]) do
            functions[node["value"]]["arguments"][i] = scopes[i]
          end
          Scopes_remove()

          return return_value
        else
          -- Built-in Function
          if node["path"] then
            if not Find_index_in_array(current_path, node["value"]) then
              error("path '"..node["value"].."' does not exist")
            end
            current_path = current_path[node["value"]]
            table.insert(last_path, node["value"])
            return Interpret(node["path"])
          end
        end
      else
        if current_path[node["value"]] then
          if not node["arguments"] and #current_path[node["value"]]["arguments"] ~= 0 then
            error("expected " .. #current_path[node["value"]]["arguments"] .. " arguments, got 0")
          elseif node["arguments"] then
            if #current_path[node["value"]]["arguments"] ~= #node["arguments"] then
              error("expected " .. #current_path[node["value"]]["arguments"] .. " arguments, got " .. #node["arguments"])
            end
          end

          current_path = functions

          if EqualLists(last_path, { "debug" }) then
            -- DEBUG
            last_path = {}
            if node["value"] == "log" then
              -- Log Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) == "string" then
                table.insert(log_values, string.sub(argument1, 2, #argument1 - 1))
              else
                if argument1 == nil then
                  table.insert(log_values, "null")
                else
                  table.insert(log_values, tostring(argument1))
                end
              end

              return nil
            elseif node["value"] == "warn" then
              -- Warn Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(Interpret(node["arguments"][1])) == "string" then
                table.insert(log_values, "WARN: "..string.sub(argument1, 2, #argument1 - 1))
              else
                if argument1 == nil then
                  table.insert(log_values, "WARN: null")
                end
                table.insert(log_values, "WARN: "..tostring(argument1))
              end

              return nil
            elseif node["value"] == "error" then
              -- Error Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(Interpret(node["arguments"][1])) == "string" then
                error(string.sub(argument1, 2, #argument1 - 1))
              else
                if argument1 == nil then
                  error("null")
                end
                error(tostring(argument1))
              end

              return nil
            end
          elseif EqualLists(last_path, { "math" }) then
            -- MATH
            last_path = {}
            if node["value"] == "random" then
              -- Random Function
              local minimum = Interpret(node["arguments"][1])
              local maximum = Interpret(node["arguments"][2])
              if GetToken(minimum) ~= "number" then
                error("argument 1 isn't a number")
              end
              if GetToken(maximum) ~= "number" then
                error("argument 2 isn't a number")
              end

              return math.random(tonumber(minimum), tonumber(maximum))
            elseif node["value"] == "clamp" then
              -- Clamp Function
              local minimum = Interpret(node["arguments"][2])
              local maximum = Interpret(node["arguments"][3])
              if GetToken(minimum) ~= "number" then
                error("argument 2 isn't a number")
              end
              if GetToken(maximum) ~= "number" then
                error("argument 3 isn't a number")
              end

              if GetToken(Interpret(node["arguments"][1])) ~= "number" then
                error("argument 1 isn't a number")
              end

              return Clamp(tonumber(Interpret(node["arguments"][1])), tonumber(minimum), tonumber(maximum))
            elseif node["value"] == "min" then
              -- Minimum Function
              local argument1 = Interpret(node["arguments"][1])
              local argument2 = Interpret(node["arguments"][2])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end
              if GetToken(argument2) ~= "number" then
                error("argument 2 isn't a number")
              end

              if argument1 < argument2 then
                return argument2
              end
              return argument1
            elseif node["value"] == "max" then
              -- Maximum Function
              local argument1 = Interpret(node["arguments"][1])
              local argument2 = Interpret(node["arguments"][2])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end
              if GetToken(argument2) ~= "number" then
                error("argument 2 isn't a number")
              end

              if argument1 > argument2 then
                return argument2
              end
              return argument1
            elseif node["value"] == "exp" then
              -- Exponent Function
              local base = Interpret(node["arguments"][1])
              local exponent = Interpret(node["arguments"][2])
              if GetToken(base) ~= "number" then
                error("argument 1 isn't a number")
              end
              if GetToken(exponent) ~= "number" then
                error("argument 2 isn't a number")
              end

              return base ^ exponent
            elseif node["value"] == "abs" then
              -- Absolute Function
              local argument1 =  Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.abs(tonumber(argument1))
            elseif node["value"] == "floor" then
              -- Floor Function
              local argument1 =  Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.floor(tonumber(argument1))
            elseif node["value"] == "ceiling" then
              -- Ceiling Function
              local argument1 =  Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.ceil(tonumber(argument1))
            elseif node["value"] == "round" then
              -- Round Function
              local argument1 = Interpret(node["arguments"][1])
              local argument2 = Interpret(node["arguments"][2])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end
              if GetToken(argument2) ~= "number" then
                error("argument 2 isn't a number")
              end

              return Round(tonumber(argument1) * math.pow(10, tonumber(argument2))) / math.pow(10, tonumber(argument2))
            elseif node["value"] == "sqrt" then
              -- Square Root Function
              local argument1 =  Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.sqrt(tonumber(argument1))
            elseif node["value"] == "sin" then
              -- Sine Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.sin(math.rad(tonumber(argument1)))
            elseif node["value"] == "cos" then
              -- Cosine Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.cos(math.rad(tonumber(argument1)))
            elseif node["value"] == "tan" then
              -- Tangent Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.tan(math.rad(tonumber(argument1)))
            elseif node["value"] == "asin" then
              -- Arc Sine Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.asin(math.rad(tonumber(argument1)))
            elseif node["value"] == "acos" then
              -- Arc Cosine Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.acos(math.rad(tonumber(argument1)))
            elseif node["value"] == "atan" then
              -- Arc Tangent Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.atan(math.rad(tonumber(argument1)))
            elseif node["value"] == "sinh" then
              -- Hyperbolic Sine Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.sinh(math.rad(tonumber(argument1)))
            elseif node["value"] == "cosh" then
              -- Hyperbolic Cosine Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.cosh(math.rad(tonumber(argument1)))
            elseif node["value"] == "tanh" then
              -- Hyperbolic Tangent Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.tanh(math.rad(tonumber(argument1)))
            elseif node["value"] == "ln" then
              -- Natural Logarithm Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.log(tonumber(argument1))
            elseif node["value"] == "log" then
              -- Logarithm Function
              local argument1 = Interpret(node["arguments"][1])
              local argument2 = Interpret(node["arguments"][2])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end
              if GetToken(argument2) ~= "number" then
                error("argument 2 isn't a number")
              end

              return math.log(tonumber(argument1), tonumber(argument2))
            elseif node["value"] == "pi" then
              -- Pi Function
              return math.pi
            elseif node["value"] == "euler" then
              -- Euler Function
              return math.exp(1)
            elseif node["value"] == "rad" then
              -- Radians Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.rad(tonumber(argument1))
            elseif node["value"] == "deg" then
              -- Degrees Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("argument 1 isn't a number")
              end

              return math.deg(tonumber(argument1))
            end
          elseif EqualLists(last_path, { "string" }) then
            -- STRING
            last_path = {}
            if node["value"] == "join" then
              -- Join Function
              local argument1 = Interpret(node["arguments"][1])
              local argument2 = Interpret(node["arguments"][2])

              local string_1 = argument1
              local string_2 = argument2

              if GetToken(argument1) == "string" then
                string_1 = string.sub(argument1, 2, #argument1 - 1)
              end
              if GetToken(argument2) == "string" then
                string_2 = string.sub(argument2, 2, #argument2 - 1)
              end

              if GetToken(argument1) == "string" or GetToken(argument2) == "string" then
                return '"' .. string_1 .. string_2 .. '"'
              end

              return string_1 .. string_2
            elseif node["value"] == "length" then
              -- Length Function
              local argument1 = Interpret(node["arguments"][1])
              if type(argument1) == "table" then
                error("expected string, number or boolean")
              end
              if GetToken(argument1) == "string" then
                argument1 = string.sub(argument1, 2, #argument1 - 1)
              end

              return tostring(#tostring(argument1))
            elseif node["value"] == "letter" then
              -- Letter Function
              local argument1 = Interpret(node["arguments"][1])
              local argument2 = Interpret(node["arguments"][2])
              if GetToken(argument1) == "string" then
                argument1 = string.sub(argument1, 2, #argument1 - 1)
              end
              if GetToken(argument2) ~= "number" then
                error("expected number")
              end

              return string.sub(tostring(argument1), tonumber(argument2), tonumber(argument2))
            elseif node["value"] == "contains" then
              -- Contains Function
              local argument1 = Interpret(node["arguments"][1])
              if type(argument1) == "table" then
                error("expected string, number or boolean")
              end
              if GetToken(argument1) == "string" then
                argument1 = string.sub(argument1, 2, #argument1 - 1)
              end

              local argument2 = Interpret(node["arguments"][2])
              if GetToken(argument2) == "string" then
                argument2 = string.sub(argument2, 2, #argument2 - 1)
              end

              if string.find(argument1, argument2) then
                return "true"
              end
              return "false"
            elseif node["value"] == "upper" then
              -- Upper Function
              return string.upper(tostring(Interpret(node["arguments"][1])))
            elseif node["value"] == "lower" then
              -- Lower Function
              return string.lower(tostring(Interpret(node["arguments"][1])))
            elseif node["value"] == "replace" then
              -- Replace Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) == "string" then
                argument1 = string.sub(argument1, 2, #argument1 - 1)
              end

              local argument2 = Interpret(node["arguments"][2])
              if GetToken(argument2) == "string" then
                argument2 = string.sub(argument2, 2, #argument2 - 1)
              end

              local argument3 = Interpret(node["arguments"][3])
              if GetToken(argument3) == "string" then
                argument3 = string.sub(argument3, 2, #argument3 - 1)
              end

              local argument4 = Interpret(node["arguments"][4])
              if GetToken(argument4) ~= "number" then
                error("expected number")
              end

              return string.gsub(argument1, argument2, argument3, tonumber(argument4))
            elseif node["value"] == "split" then
              -- Split Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "string" then
                error("expected string")
              end

              local argument2 = Interpret(node["arguments"][2])
              if GetToken(argument2) ~= "string" then
                error("expected string")
              end

              argument1 = string.sub(argument1, 2, #argument1 - 1)
              
              argument2 = string.sub(argument2, 2, #argument2 - 1)
              
              local new_string = {}
              local word = ""
              for i = 1, #argument1 do
                local char = string.sub(argument1, i, i)
                if char == argument2 then
                  table.insert(new_string, {["type"] = "string", ["value"] = word})
                  word = ""
                else
                  word = word .. char
                end
              end
              if word ~= "" then
                table.insert(new_string, {["type"] = "string", ["value"] = word})
              end

              return new_string
            elseif node["value"] == "find" then
              -- Find Function
              local argument1 = Interpret(node["arguments"][1])
              if type(argument1) == "table" then
                error("expected string, number or boolean")
              end
              if GetToken(argument1) == "string" then
                argument1 = string.sub(argument1, 2, #argument1 - 1)
              end

              local argument2 = Interpret(node["arguments"][2])
              if GetToken(argument2) == "string" then
                argument2 = string.sub(argument2, 2, #argument2 - 1)
              end

              if string.find(argument1, argument2) then
                local startpos, endpos = string.find(argument1, argument2)

                return tostring(startpos)
              end
              return "null"
            end
          elseif EqualLists(last_path, { "control" }) then
            -- CONTROL
            last_path = {}
            if node["value"] == "type" then
              -- Type Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) == "number" then
                return '"number"'
              elseif GetToken(argument1) == "string" then
                return '"string"'
              elseif GetToken(argument1) == "boolean" then
                return '"boolean"'
              elseif type(argument1) == "table" then
                return '"list"'
              elseif GetToken(argument1) == "null" then
                return '"null"'
              end

              return nil
            elseif node["value"] == "wait" then
              -- Wait Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "number" then
                error("expected number")
              end

              Wait(tonumber(argument1))

              return nil
            elseif node["value"] == "tonumber" then
              -- To Number Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) == "string" then
                argument1 = string.sub(argument1, 2, #argument1 - 1)
              end

              return tonumber(argument1)
            elseif node["value"] == "tostring" then
              -- To String Function
              local argument1 = Interpret(node["arguments"][1])
              if GetToken(argument1) ~= "string" then
                argument1 = '"'..argument1..'"'
              end

              return argument1
            end
          elseif EqualLists(last_path, { "list" }) then
            -- LIST
            last_path = {}
            if node["value"] == "item" then
              -- Item Functcion
              local argument1 = Interpret(node["arguments"][1])
              if type(argument1) ~= "table" then
                error("expected list")
              end

              local argument2 = Interpret(node["arguments"][2])
              if tonumber(argument2) then
                return Interpret(argument1[tonumber(argument2)])
              end

              return Interpret(argument1[argument2])
            elseif node["value"] == "add" then
              -- Add Function
              local argument1 = Interpret(node["arguments"][1])
              if type(argument1) ~= "table" then
                error("expected list")
              end

              table.insert(argument1, Interpret(node["arguments"][2]))

              return nil
            elseif node["value"] == "insert" then
              -- Insert Function
              local argument1 = Interpret(node["arguments"][1])
              local argument3 = Interpret(node["arguments"][3])
              if type(argument1) ~= "table" then
                error("expected list")
              end

              if tonumber(argument3) then
                argument1[tonumber(argument3)] = Interpret(node["arguments"][2])

                return nil
              end
              argument1[argument3] = Interpret(node["arguments"][2])

              return nil
            elseif node["value"] == "length" then
              -- Length Function
              local argument1 = Interpret(node["arguments"][1])
              if type(argument1) ~= "table" then
                error("expected list")
              end

              return tostring(#argument1)
            elseif node["value"] == "position" then
              -- Position Function
              local argument1 = Interpret(node["arguments"][1])
              if type(argument1) ~= "table" then
                error("expected list")
              end

              return Find_in_array(argument1, Interpret(node["arguments"][2]))
            elseif node["value"] == "delete" then
              -- Delete Function
              local argument1 = Interpret(node["arguments"][1])
              local argument2 = Interpret(node["arguments"][2])
              if type(argument1) ~= "table" then
                error("expected list")
              end

              if tonumber(argument2) then
                argument1[tonumber(argument2)] = nil

                return nil
              end
              argument1[argument2] = nil

              return nil
            elseif node["value"] == "replace" then
              -- Replace Function
              local argument1 = Interpret(node["arguments"][1])
              local argument2 = Interpret(node["arguments"][2])
              if type(argument1) ~= "table" then
                error("expected list")
              end

              if argument1[argument2] == nil then
                error("position out of bounds")
              end

              if tonumber(argument2) then
                argument1[tonumber(argument2)] = Interpret(node["arguments"][3])

                return nil
              end
              argument1[argument2] = Interpret(node["arguments"][3])

              return nil
            elseif node["value"] == "contains" then
              -- Contains Function
              local argument1 = Interpret(node["arguments"][1])
              if type(argument1) ~= "table" then
                error("expected list")
              end

              for i, v in pairs(argument1) do
                if Interpret(v) == Interpret(node["arguments"][2]) then
                  return "true"
                end
              end
              return "false"
            elseif node["value"] == "clear" then
              -- Clear Function
              local argument1 = Interpret(node["arguments"][1])
              if type(argument1) ~= "table" then
                error("expected list")
              end

              for i, v in pairs(argument1) do
                argument1[i] = nil
              end

              return nil
            elseif node["value"] == "concatenate" then
              -- Concatenate Function
              local argument1 = Interpret(node["arguments"][1])
              local argument2 = Interpret(node["arguments"][2])
              if type(argument1) ~= "table" then
                error("expected list")
              end
              if GetToken(argument2) ~= "string" then
                error("expected string")
              end

              local new_list = argument1
              for i, v in pairs(new_list) do
                if GetToken(v) == "string" then
                  new_list[i] = string.sub(v, 2, #v - 1)
                end
              end

              argument2 = string.sub(argument2, 2, #argument2 - 1)
              return '"' .. table.concat(new_list, argument2) .. '"'
            end
          elseif EqualLists(last_path, { "instance" })  then
            -- INSTANCE
            last_path = {}
            if node["value"] == "new" then
              -- New Function
              if GetToken(node["arguments"][1]["value"]) ~= "identifier" then
                error("expected identifier")
              end
              local argument1 = node["arguments"][1]

              if not classes[argument1["value"]] then
                error("argument 1 isn't a class")
              end

              local class = classes[argument1["value"]]

              if not argument1["arguments"] and #class["arguments"] ~= 0 then
                error("expected " .. #class["arguments"] .. " arguments, got 0")
              elseif argument1["arguments"] then
                if #class["arguments"] ~= #argument1["arguments"] then
                  error("expected " .. #class["arguments"] .. " arguments, got " .. #argument1["arguments"])
                end
              end

              local instance = {}
              instance["class"] = class["class"]
              instance["arguments"] = {}

              for i, v in pairs(class["arguments"]) do
                instance["arguments"][v] = Interpret(argument1["arguments"][i])
              end

              return instance
            elseif node["value"] == "destroy" then
              -- Destroy Function
              if GetToken(node["arguments"][1]["value"]) ~= "identifier" then
                error("expected identifier")
              end
              local argument1 = node["arguments"][1]

              if not functions[argument1["value"]] then
                error("instance doesn't exist")
              end

              functions[argument1["value"]] = nil

              return nil
            end
          end
        end

        error("'" .. node["value"] .. "' was never declared as a variable or a function")
      end
    elseif node["type"] == "list" then
      -- List
      local list = {}
      for i, v in pairs(node["value"]) do
        table.insert(list, Interpret(v))
      end

      return list
    elseif node["type"] == "keyword" then
      -- Keyword
      return node
    end

    return return_value
  end

  local globalAST = Parse(code_chunks, {}, true)

  for i, v in pairs(globalAST) do
    Interpret(v)
  end

  for i, v in pairs(log_values) do
    print(v)
  end
end

function GetFile(filename)
  local file = io.input(filename)

  if file then
    return file:read("a")
  end
end

RunCode(GetFile(FILE))