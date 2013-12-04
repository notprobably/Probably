local telescope = require 'telescope'

require 'probably'
require 'system/core/lexer'

local parse = ProbablyEngine.lexer.parse

spec('Lexer', function ()
  describe('Parser', function ()
    context('Actions', function ()
      it('parse spells', function ()
        local spells = {
          'Roll', -- Normal
          'Crackling Jade Lightning', -- Multiple Words / Spaces
          'Tiger\'s Lust', -- Single Quotes
          'Invoke Xuen, the White Tiger', -- Commas
          'Transcendence: Transfer', -- Colons
          'Anti-Magic Zone', -- Dashes
          'Ravage!', -- Exclamation Mark
          '123123' -- Spell IDs
        }

        for i = 1, #spells do
          local parsed, err = parse(spells[i], 'action')
          assert_nil(err)
          assert_same(parsed, {
            { 'spell', spells[i] }
          })
        end
      end)

      it('parses stop casting prefix', function ()
        local parsed, err = parse('!Detox', 'action')
        assert_nil(err)
        assert_same(parsed, {
          { 'stopCasting', '!' },
          { 'spell', 'Detox' }
        })
      end)

      it('parses item prefix', function ()
        local parsed, err = parse('#Healthstone', 'action')
        assert_nil(err)
        assert_same(parsed, {
          { 'item', '#' },
          { 'spell', 'Healthstone' }
        })
      end)

      it('parses macro prefix', function ()
        local parsed, err = parse('!/targetlasttarget;\n/clearfocus', 'action')
        assert_nil(err)
        assert_same(parsed, {
          { 'stopCasting', '!' },
          { 'macro', '/targetlasttarget;\n/clearfocus' }
        })
      end)
    end)

    context('Conditionals', function ()
      it('ignore spaces', function ()
        local parsed, err = parse('    \n     \n    ', 'conditional')
        assert_nil(err)
        assert_same(parsed, {})
      end)

      it('parses the library prefix', function ()
        local parsed, err = parse('@coreHealing', 'conditional')
        assert_nil(err)
        assert_same(parsed, {
          { 'library', '@' },
          { 'identifier', 'coreHealing' }
        })
      end)

      it('parses identifiers', function ()
        local identifiers = {
          'player',
          'Alpha', -- Capitals
          'coreHealing',
          'SHOUT',
          '_something', -- Underscores
          'one_two_three',
          'tank1', -- Numbers
          'tank_1'
        }

        for i = 1, #identifiers do
          local parsed, err = parse(identifiers[i], 'conditional')
          assert_nil(err)
          assert_same(parsed, {
            { 'identifier', identifiers[i] }
          })
        end
      end)

      it('parses numbers', function ()
        local numbers = {
          '1',
          '1.0',
          '+1',
          '+1.0',
          '-1',
          '-1.0'
        }

        for i = 1, #numbers do
          local parsed, err = parse(numbers[i], 'conditional')
          assert_nil(err)
          assert_same(parsed, {
            { 'number', numbers[i] }
          })
        end
      end)

      it('parses arguments', function ()
        local arguments = {
          '(Death Note)',
          '(123123)',
          '(Thrill of the Hunt)',
          '(Power Word: Fortitude)',
          '(Fire!)',
          '(Kil\'jaeden\'s Cunning)',
          '(60, 4)',
          '(\'One\', "Two")',
          '(\'Aqua Bomb\')',
          '("Aqua Bomb")',
          '(Thrill (of) the Hunt)' -- Phelp's stupid idea
        }

        for i = 1, #arguments do
          local parsed, err = parse(arguments[i], 'conditional')
          assert_nil(err)
          assert_same(parsed, {
            { 'args', arguments[i] }
          })
        end
      end)

      it('parses indexes', function ()
        local indexes = {
          '[0]',
          '[test]',
          '[\'test\']',
          '["test"]',
        }

        for i = 1, #indexes do
          local parsed, err = parse(indexes[i], 'conditional')
          assert_nil(err)
          assert_same(parsed, {
            { 'index', indexes[i] }
          })
        end
      end)

      it('parses not', function ()
        local parsed, err = parse('!!', 'conditional')
        assert_nil(err)
        assert_same(parsed, {
          { 'not', '!' },
          { 'not', '!' }
        })
      end)

      it('parses math operators', function ()
        local math = {
          '*',
          '/',
          '+',
          '-'
        }

        for i = 1, #math do
          local parsed, err = parse(math[i], 'conditional')
          assert_nil(err)
          assert_same(parsed, {
            { 'math', math[i] }
          })
        end
      end)

      it('parses comparators', function ()
        local comparators = {
          '>=', '>',
          '<=', '<',
          '==','=',
          '!=', '~='
        }

        for i = 1, #comparators do
          local parsed, err = parse(comparators[i], 'conditional')
          assert_nil(err)
          assert_same(parsed, {
            { 'comparator', comparators[i] }
          })
        end
      end)

      it('parses periods', function ()
        local parsed, err = parse('...', 'conditional')
        assert_nil(err)
        assert_same(parsed, {
          { 'period', '.' },
          { 'period', '.' },
          { 'period', '.' },
        })
      end)

      it('parses nested groups', function ()
        local groups = {
          { '(5 + ( ( 1 + 2 ) * 3 ) ) / 1000', {
            { 'group', {
              { 'number', '5' }, { 'math', '+' },
              { 'group', {
                { 'group', {
                  { 'number', '1' }, { 'math', '+' }, { 'number', '2' }
                }},
                { 'math', '*' }, { 'number', '3' }
              }}
            }},
            { 'math', '/' }, { 'number', '1000' }
          }
        }}

        for i = 1, #groups do
          local parsed, err = parse(groups[i][1], 'conditional', nil, 10)
          assert_nil(err)
          assert_same(parsed, groups[i][2])
        end
      end)

      it('parses correctly', function ()
        local expected = {
          { 'player.health', {
            { 'identifier', 'player' }, { 'period' , '.' }, { 'identifier', 'health' }
          }},
          { '!player.buff(Power Word: Fortitude)', {
            { 'not', '!'},
            {'identifier', 'player' }, { 'period' , '.' }, { 'identifier', 'buff' },
            { 'args', '(Power Word: Fortitude)'}
          }},
          { 'player.buff(Blood Charge).count >= 5', {
            { 'identifier', 'player' }, { 'period' , '.' }, { 'identifier', 'buff' },
            { 'args', '(Blood Charge)'}, { 'period' , '.' }, { 'identifier', 'count' },
            { 'comparator', '>=' }, { 'number' , '5' }
          }},
          { '@coreHealing.one[\'two\'].three(four, five)', {
            { 'library', '@' }, { 'identifier', 'coreHealing' },
            { 'period' , '.' }, { 'identifier', 'one' }, { 'index' , '[\'two\']' }, 
            { 'period', '.' }, { 'identifier' , 'three' }, { 'args', '(four, five)' }
          }},
        }

        for i = 1, #expected do
          local parsed, err = parse(expected[i][1], 'conditional')
          assert_nil(err)
          assert_same(parsed, expected[i][2])
        end
      end)
    end)
  end)
end)
