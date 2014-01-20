-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

ProbablyEngine.dsl = {
  dsl = {}
}

ProbablyEngine.dsl.register = function (name, dsl)
  ProbablyEngine.dsl.dsl[name] = dsl
end

ProbablyEngine.dsl.unregister = function (name)
  ProbablyEngine.dsl.dsl[name] = nil
end

ProbablyEngine.dsl.get = function (name)
  return ProbablyEngine.dsl.dsl[name]
end
