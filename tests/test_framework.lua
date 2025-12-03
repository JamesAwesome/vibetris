-- Test to verify the testing framework is working correctly

local lqc = require("lib/lqc")

-- Simple property: addition is commutative
local prop1 = lqc.property("addition is commutative", 
    lqc.forall(
        {lqc.generators.int(-100, 100), lqc.generators.int(-100, 100)},
        function(a, b)
            return a + b == b + a
        end
    )
)

-- Simple property: string concatenation length
local prop2 = lqc.property("string concatenation length is sum of lengths",
    lqc.forall(
        {lqc.generators.string(0, 10), lqc.generators.string(0, 10)},
        function(s1, s2)
            local concat = s1 .. s2
            return #concat == #s1 + #s2
        end
    )
)

-- Add tests to the suite
lqc.addTest(prop1)
lqc.addTest(prop2)
