-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local stringFormat = string.format

local lexer = ProbablyEngine.lexer

local identifiers = {}

local function register(identifier, tbl)
  if identifiers[identifier] then error('Identifier already exists: ' .. identifier) end

  identifiers[identifier] = tbl
end

local function unregister(identifier)
  if not identifiers[identifier] then error('Invalid Identifier') end

  identifiers[identifier] = nil
end

local function get(identifier)
  if not identifiers[identifier] then error('Invalid Identifier') end

  return identifiers[identifier]
end

local NewSymbol = {}
function NewSymbol.__call(t, k)
  return setmetatable(k or {}, t)
end

local function Symbol(prototype)
  if not prototype.lbp then
    prototype.lbp = 0
  end
  prototype.__index = prototype
  function prototype.__tostring(self)
    if self.id == ',' then
      return '(,)'
    end

    if self.id == 'Number' or self.id == 'Constant' or self.id == 'Identifier' then
      return stringFormat('(%s %s)', self.id, tostring(self.value) or 'None')
    end

    if self.id == 'Args' then
      local arguments = ''
      for i = 1, #self.value do
        arguments = arguments .. stringFormat(' %s', tostring(self.value[i]))
      end
      return stringFormat('(%s%s)', self.id, arguments or 'None')
    end

    return stringFormat('(%s %s %s)', self.id, tostring(self.first) or 'None', tostring(self.second) or 'None')
  end
  function prototype:led(left, expression)
    self.first = left
    self.second = expression(self.lbp)
    return self
  end
  function prototype:eval(action)
    local first = self.first and self.first:evaluate(action) or nil
    local second = self.second and self.second:evaluate(action) or nil

    if type(first) == 'function' then first = first(self.first.self) end
    if type(second) == 'function' then second = second(self.second.self) end

    if first and first.__call then first = first.__call(first) end
    if second and second.__call then second = second.__call(second) end

    return first, second
  end
  return setmetatable(prototype, NewSymbol)
end

local symbol = {}

local Number = Symbol({ id = 'Number' })
function Number:nud(expression)
  return self
end
function Number:evaluate()
  return self.value
end

local Constant = Symbol({ id = 'Constant' })
function Constant:nud(expression)
  return self
end
function Constant:evaluate()
  if self.value == 'true' then return true
  elseif self.value == 'false' then return false
  elseif self.value == 'nil' then return nil end
end

local Identifier = Symbol({ id = 'Identifier' })
function Identifier:nud(expression)
  return self
end
function Identifier:evaluate()
  if self.search then
    if identifiers['unit'].validate(self.value) then
      self.class = 'identifier'
      return identifiers['unit'].get(self.value)
    elseif identifiers[self.value] then
      self.class = 'identifier'
      return identifiers[self.value]
    elseif _G[self.value] then
      self.class = 'global'
      return _G[self.value]
    end
  else
    self.class = 'string'
    return self.value
  end
end

local Library = Symbol({ id = '@' })
function Library:nud(expression)
  return self
end
function Library:evaluate()
  print('TODO: Library')
end

local Period = Symbol({ id = '.', lbp = 150 })
function Period:led(left, expression, verify, token)
  if left.id ~= 'Identifier' and left.id ~= '(' and left.id ~= '.' then
    error('Expected an Identifier or a ( not a > ' .. left.id .. ' <')
  end
  self.first = left
  self.second = token
  verify()
  return self
end
function Period:evaluate(action)
  if not self.first.search then
    self.first.search = true
  end

  local first = self.first:evaluate(action)
  local second = self.second:evaluate(action)

  if type(first) == 'function' then first = first(self.first.self) end
  if type(second) == 'function' then second = second(self.second.self) end

  if first == nil then
    return false
  end

  if not first then
    return false
  end

  if first[second] then
    self.self = first
    return first[second]
  end

  return nil
end

local Comma = Symbol({ id = ',' })
function Comma:nud()
  return self
end

local Args = Symbol({ id = 'Args' })

local Add = Symbol({ id = '+', lbp = 110 })
function Add:nud(expression)
  self.first = expression(130)
  self.second = Number({ value = 0 })
  return self
end
function Add:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first + second
end
function symbol.add()
  return setmetatable({}, Add)
end

local Subtract = Symbol({ id = '-', lbp = 110 })
function Subtract:nud(expression)
  self.first = Number({ value = 0 })
  self.second = expression(130)
  return self
end
function Subtract:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first - second
end

local Multiply = Symbol({ id = '*', lbp = 120 })
function Multiply:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first * second
end

local Divide = Symbol({ id = '/', lbp = 120 })
function Divide:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end
  
  return first / second
end

local Modulus = Symbol({ id = '%', lbp = 120 })
function Modulus:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first % second
end

local LesserThan = Symbol({ id = '<', lbp = 60 })
function LesserThan:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first < second
end

local LesserThanEqual = Symbol({ id = '<=', lbp = 60 })
function LesserThanEqual:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first <= second
end

local GreaterThan = Symbol({ id = '>', lbp = 60 })
function GreaterThan:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first > second
end

local GreaterThanEqual = Symbol({ id = '>=', lbp = 60 })
function GreaterThanEqual:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first >= second
end

local Equal = Symbol({ id = '==', lbp = 60 })
function Equal:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first == second
end

local NotEqual = Symbol({ id = '~=', lbp = 60 })
function NotEqual:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first ~= second
end

local LeftParathesis = Symbol({ id = '(', lbp = 150 })
function LeftParathesis:led(left, expression, verify, token)
  self.first = left
  self.second = {}
  if token .id ~= ')' then
    local arg 
    while true do
      local expr, nextToken = expression()
      self.second[#self.second + 1] = expr
      if nextToken.id == ')' then
        verify(')')
        break
      end
    end
  end
  self.second = Args({ value = self.second }) 
  return self
end
function LeftParathesis:evaluate(action)
  local arguments = {}
  local argument, lastArgument
  for i = 1, #self.second.value do
    argument = self.second.value[i]
    if argument.id == 'Identifier'
       and lastArgument and lastArgument.id == 'Identifier'
       and argument.class == 'string' and lastArgument.class == 'string' then
      lastArgument.value = lastArgument.value .. ' ' .. argument.value
    else
      lastArgument = argument
      if argument.id ~= ',' then
        arguments[#arguments + 1] = argument
      end
    end
  end

  for i, a in pairs(arguments) do
    arguments[i] = arguments[i].value
  end
  
  if not self.first.search then
    self.first.search = true
  end

  local first = self.first:evaluate(action)
  if first == nil then
    return false
  end
  
  return first(self.first.self, unpack(arguments))
end
function LeftParathesis:nud(expression, verify)
  local expr = expression()
  verify(')')
  return expr
end

local RightParathesis = Symbol({ id = ')' })
function RightParathesis:nud(expression, verify)
  return self
end

local LeftBracket = Symbol({ id = '[', lbp = 150 })
function LeftBracket:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first[second]
end
function LeftBracket:nud(expression, verify)
  local expr = expression()
  verify(']')
  return expr
end

local RightBracket = Symbol({ id = ']' })
function RightBracket:nud(expression, verify)
  return self
end

local Invert = Symbol({ id = '!', lbp = 50 })
function Invert:nud(expression, verify)
  self.first = expression(self.lbp)
  self.second = nil
  return self
end
function Invert:evaluate(action)
  return not self:eval(action)
end

local And = Symbol({ id = 'And', lbp = 40 })
function And:led(left, expression)
  self.first = left
  self.second = expression(self.lbp - 1)
  return self
end
function And:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first and second
end

local Or = Symbol({ id = 'Or', lbp = 30 })
function Or:led(left, expression)
  self.first = left
  self.second = expression(self.lbp - 1)
  return self
end
function Or:evaluate(action)
  local first, second = self:eval(action)
  if not first or not second then return false end

  return first or second
end

local Null = Symbol({ id = 'Null', lbp = 0 })

local function evaluate(rule, tokens)
  local token, ok
  local tokenLength, currentToken = #tokens, 0

  local function advance()
    currentToken = currentToken + 1
    if currentToken > tokenLength then return Null() end

    local tokenType, tokenValue = tokens[currentToken][1], tokens[currentToken][2]
    if     tokenType == 'number' then return Number({ value = tonumber(tokenValue) })
    elseif tokenType == 'constant' then return Constant({ value = tokenValue })
    elseif tokenType == 'library' then return Library({ value = tokenValue })
    elseif tokenType == 'identifier' then return Identifier({ value = tokenValue:match'^%s*(.*%S)' or '' })
    elseif tokenType == 'string' then return Identifier({ value = string.sub(tokenValue, 2, -2) })
    elseif tokenType == 'period' then return Period()
    elseif tokenType == 'args' then return Args({ value = tokenValue })
    elseif tokenType == 'comma' then return Comma()
    elseif tokenType == 'logic' then
      if     tokenValue == 'and' then return And()
      elseif tokenValue == 'or' then return Or()
      end
    elseif tokenType == 'math' then
      if     tokenValue == '+' then return Add()
      elseif tokenValue == '-' then return Subtract()
      elseif tokenValue == '*' then return Multiply()
      elseif tokenValue == '/' then return Divide()
      elseif tokenValue == '%' then return Modulus()
      end
    elseif tokenType == 'comparator' then
      if     tokenValue == '>' then return GreaterThan()
      elseif tokenValue == '>=' then return GreaterThanEqual()
      elseif tokenValue == '<' then return LesserThan()
      elseif tokenValue == '<=' then return LesserThanEqual()
      elseif tokenValue == '==' then return Equal()
      elseif tokenValue == '=' then return Equal()
      elseif tokenValue == '!=' then return NotEqual()
      elseif tokenValue == '~=' then return NotEqual()
      end
    elseif tokenType == 'openBracket' then return LeftBracket()
    elseif tokenType == 'closeBracket' then return RightBracket()
    elseif tokenType == 'openParen' then return LeftParathesis()
    elseif tokenType == 'closeParen' then return RightParathesis()
    elseif tokenType == 'not' then return Invert()
    else error('Unknown Operator: ' .. tokenType)
    end
  end

  local function printFirst()
    local rule = ''
    for i = 1, currentToken - 2 do
      rule = rule .. tokens[i][2]
    end

    rule = rule .. '    >>>> ' .. tokens[currentToken - 1][2] .. ' <<<<     '

    if tokenLength > currentToken - 1 then
      for i = currentToken, tokenLength do
        rule = rule .. tokens[i][2]
      end
    end

    return rule
  end

  local function verify(expected)
    if expected then
      if type(expected) == 'string' and token.id ~= expected then
        error('Expected Token: ' .. expected .. '. Got: ' .. token.id)
      elseif type(expected) == 'table' then
        local found = false
        for i = 1, #expected do
          if token.id == expected[i] then
            found = true
            break
          end
          if not found then
            error('Expected Token: ' .. expected)
          end
        end
      end
    end
    token = advance()
    return token
  end

  local function expression(rbp)
    rbp = rbp or 0

    local t = token
    token = advance()
    ok, left = pcall(t.nud, t, expression, verify)
    if not ok then
      error('Error Processing Rule: ' .. rule .. '. Error: ' .. left .. '. Found after: ' .. printFirst())
    end

    while rbp < token.lbp do
      t = token
      token = advance()
      ok, left = pcall(t.led, t, left, expression, verify, token)
      if not ok then
        error('Error Processing Rule: ' .. rule .. '. Error: ' .. left .. '. Found after: ' .. printFirst())
      end
    end

    return left, token
  end

  token = advance()

  return expression()
end

local function parse(rule)
  local tokens, err = lexer.parse(rule, 'rule')
  if err then
    error('Could not parse: ' .. err)
  end

  return evaluate(rule, tokens)
end

ProbablyEngine.dsl.register('rules', {
  parse = parse,
  register = register,
  unregister = unregister,
  get = get
})
