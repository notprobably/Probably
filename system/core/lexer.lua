-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local function alterGroup(string)
  return string:sub(2, -2)
end

local actions = {
  { 'stopCasting', '^!' },
  { 'item', '^#' },
  { 'macro', '^/.*' },
  { 'spell', { '^[%w:!\',"%- ]*' } },
}

local conditionals = {
  { 'space', '^%s+' },
  { 'library', '^@' },
  { 'identifier', '^[_%a][_%w]*' },
  { 'number', { '^[%+%-]?%d+%.?%d*', '^%d+%.?%d*' } },
  { 'args', { '^%([%w:!\',"%(%) ]*%)' } },
  { 'group', { '^%(.*%)' }, alterGroup },

  { 'index', { '^%[[%w:!\'," ]*%]' } },
  { 'math', { '^%*', '^/', '^%-', '^%+' } },
  { 'comparator', { '^>=', '^>', '^<=', '^<', '^==', '^=', '^!=', '~=' } },
  { 'not', '^!' },
  { 'period', '^%.' }
}

local tokenTables = {
  action = actions,
  conditional = conditionals
}

local function parse(string, tokens, ignore, limit)
  if type(tokens) == 'string' then
    if not tokenTables[tokens] then error('Unknown Token Table') end
    tokens = tokenTables[tokens]
  end

  if not ignore then ignore = { space = true } end

  local list = {}

  local index = 1
  local length = #string + 1

  while index < length do
    local found = false

    for i = 1, #tokens do
      local token, patterns, nested = tokens[i][1], tokens[i][2], tokens[i][3]

      local patternType = type(patterns)
      local loops = 1
      if patternType == 'table' then loops = #patterns end

      for j = 1, loops do
        local pattern

        if patternType == 'table' then
          pattern = patterns[j]
        elseif patternType == 'string' then
          pattern = patterns
        end

        local sI, eI = string:find(pattern, index)
        if sI then
          local sub = string:sub(sI, eI)
          index = eI + 1
          found = true

          if ignore[token] then break end

          if nested and limit and limit > 0 then
            table.insert(list, { token, parse(nested(sub), tokens, ignore, limit - 1) })
          else
            table.insert(list, { token, sub })
          end
          
          break
        end
      end
      
      if found then break end
    end

    if not found then return list, string:sub(index) end
  end

  return list
end

ProbablyEngine.lexer = {
  parse = parse
}
