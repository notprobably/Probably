-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local actions = {
  { 'stopCasting', '^!' },
  { 'item', '^#' },
  { 'macro', '^/.*' },
  { 'spell', { '^[%w:!\',"%- ]*' } },
}

local rules = {
  { 'space', '^%s+' },
  { 'library', '^@' },
  { 'constant', { '^true', '^false', '^nil' } },
  { 'logic', { '^and', '^or' } },
  { 'string', { '^"[^"]+"', '^\'[^\']+\'' } },
  { 'identifier', '^[_%a][_%w:!\'%- ]*' },
  { 'number', { '^%d+%.?%d*', '^%d+%.?%d*' } },
  { 'openParen', '^%(' },
  { 'closeParen', '^%)' },

  { 'openBracket', '^%[' },
  { 'closeBracket', '^%]' },
  { 'math', { '^%*', '^/', '^%-', '^%+', '^%%' } },
  { 'comparator', { '^>=', '^>', '^<=', '^<', '^==', '^=', '^!=', '~=' } },
  { 'not', '^!' },
  { 'period', '^%.' },
  { 'comma', '^%,' }
}

local tokenTables = {
  action = actions,
  rule = rules
}

local function parse(string, tokens, ignore)
  if not tokens then error('Missing the Token Table') end
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
      local token, patterns = tokens[i][1], tokens[i][2]

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

          table.insert(list, { token, sub })
          
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
