-- lua-quickcheck implementation
-- A lightweight property-based testing library for Lua

local lqc = {}

-- Random number generator state
local seed = os.time()

function lqc.setSeed(s)
    seed = s
    math.randomseed(seed)
end

-- Initialize with current time
lqc.setSeed(seed)

-- Generator type
local Generator = {}
Generator.__index = Generator

function Generator:new(generate_fn)
    local gen = {
        generate = generate_fn
    }
    setmetatable(gen, Generator)
    return gen
end

-- Built-in generators
lqc.generators = {}

function lqc.generators.int(min, max)
    min = min or -1000
    max = max or 1000
    return Generator:new(function()
        return math.random(min, max)
    end)
end

function lqc.generators.boolean()
    return Generator:new(function()
        return math.random() > 0.5
    end)
end

function lqc.generators.choose(options)
    return Generator:new(function()
        return options[math.random(1, #options)]
    end)
end

function lqc.generators.string(min_len, max_len)
    min_len = min_len or 0
    max_len = max_len or 20
    return Generator:new(function()
        local len = math.random(min_len, max_len)
        local chars = {}
        for i = 1, len do
            chars[i] = string.char(math.random(97, 122)) -- a-z
        end
        return table.concat(chars)
    end)
end

function lqc.generators.array(element_gen, min_len, max_len)
    min_len = min_len or 0
    max_len = max_len or 10
    return Generator:new(function()
        local len = math.random(min_len, max_len)
        local arr = {}
        for i = 1, len do
            arr[i] = element_gen.generate()
        end
        return arr
    end)
end

-- Property testing
local Property = {}
Property.__index = Property

function Property:new(name, test_fn)
    local prop = {
        name = name,
        test_fn = test_fn,
        num_tests = 100
    }
    setmetatable(prop, Property)
    return prop
end

function Property:check()
    for i = 1, self.num_tests do
        local success, result = pcall(self.test_fn)
        if not success then
            return false, "Error in test: " .. tostring(result), i
        end
        if not result then
            return false, "Property failed", i
        end
    end
    return true, "Property passed", self.num_tests
end

-- Main API
function lqc.property(name, test_fn)
    return Property:new(name, test_fn)
end

function lqc.forall(generators, test_fn)
    return function()
        local values = {}
        for i, gen in ipairs(generators) do
            values[i] = gen.generate()
        end
        return test_fn(table.unpack(values))
    end
end

-- Test suite management
lqc.tests = {}

function lqc.addTest(property)
    table.insert(lqc.tests, property)
end

function lqc.runTests()
    local passed = 0
    local failed = 0
    local results = {}
    
    print("\n=== Running Property-Based Tests ===\n")
    
    for _, prop in ipairs(lqc.tests) do
        local success, message, iteration = prop:check()
        if success then
            passed = passed + 1
            print("✓ " .. prop.name .. " (" .. iteration .. " tests)")
            table.insert(results, {name = prop.name, passed = true})
        else
            failed = failed + 1
            print("✗ " .. prop.name .. " (failed at iteration " .. iteration .. ")")
            print("  " .. message)
            table.insert(results, {name = prop.name, passed = false, message = message, iteration = iteration})
        end
    end
    
    print("\n=== Test Summary ===")
    print("Passed: " .. passed)
    print("Failed: " .. failed)
    print("Total:  " .. (passed + failed))
    
    return results, failed == 0
end

return lqc
