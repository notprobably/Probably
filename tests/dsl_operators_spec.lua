-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local telescope = require 'telescope'

require 'probably'
require 'system/core/dsl'
require 'system/dsl/operators'

local operators = ProbablyEngine.dsl.operators

local function expression()
  return 10
end

spec('DSL', function ()
  describe('Operators', function ()
    context('Math', function ()
      it('adds', function ()
        assert_equal(operators.math.add.led(expression, 5), 15)
        assert_equal(operators.math.add.led(expression, -5), 5)
        assert_equal(operators.math.add.led(expression, 0), 10)
      end)
      it('subtracts', function ()
        assert_equal(operators.math.subtract.led(expression, 15), 5)
        assert_equal(operators.math.subtract.led(expression, -5), -15)
        assert_equal(operators.math.subtract.led(expression, 0), -10)
      end)
      it('multiplies', function ()
        assert_equal(operators.math.multiply.led(expression, 5), 50)
        assert_equal(operators.math.multiply.led(expression, -5), -50)
        assert_equal(operators.math.multiply.led(expression, 0), 0)
      end)
      it('divides', function ()
        assert_equal(operators.math.divide.led(expression, 50), 5)
        assert_equal(operators.math.divide.led(expression, 3), (3 / 10))
        assert_equal(operators.math.divide.led(expression, 0), 0)
      end)
    end)
  end)
end)
