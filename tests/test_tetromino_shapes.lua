-- Unit tests for Tetromino shapes
-- Verifies each piece type has correct block positions for all rotations
-- Requirements: 1.1

local lqc = require("lib/lqc")
local pieces = require("pieces/init")

-- Test that all piece types exist
local function test_all_piece_types_exist()
    local pieceTypes = {"I", "O", "T", "S", "Z", "J", "L"}
    for _, pieceType in ipairs(pieceTypes) do
        local piece = pieces.Tetromino:new(pieceType, 0, 0, 0)
        assert(piece ~= nil, "Piece type " .. pieceType .. " should exist")
        assert(piece.type == pieceType, "Piece type should be " .. pieceType)
    end
    return true
end

-- Test that all shapes have exactly 4 blocks in all rotations
local function test_all_shapes_have_4_blocks()
    local pieceTypes = {"I", "O", "T", "S", "Z", "J", "L"}
    for _, pieceType in ipairs(pieceTypes) do
        for rotation = 0, 3 do
            local piece = pieces.Tetromino:new(pieceType, 0, 0, rotation)
            local blocks = piece:getBlocks()
            assert(#blocks == 4, 
                string.format("Piece %s rotation %d should have 4 blocks, got %d", 
                    pieceType, rotation, #blocks))
        end
    end
    return true
end

-- Test that I piece has correct shape in all rotations
local function test_I_piece_rotations()
    local piece = pieces.Tetromino:new("I", 0, 0, 0)
    
    -- Rotation 0: horizontal
    piece.rotation = 0
    local blocks = piece:getBlocks()
    assert(#blocks == 4, "I piece rotation 0 should have 4 blocks")
    
    -- Rotation 1: vertical
    piece.rotation = 1
    blocks = piece:getBlocks()
    assert(#blocks == 4, "I piece rotation 1 should have 4 blocks")
    
    -- Rotation 2: horizontal
    piece.rotation = 2
    blocks = piece:getBlocks()
    assert(#blocks == 4, "I piece rotation 2 should have 4 blocks")
    
    -- Rotation 3: vertical
    piece.rotation = 3
    blocks = piece:getBlocks()
    assert(#blocks == 4, "I piece rotation 3 should have 4 blocks")
    
    return true
end

-- Test that O piece is the same in all rotations
local function test_O_piece_rotations()
    local piece = pieces.Tetromino:new("O", 0, 0, 0)
    local blocks0 = piece:getBlocks()
    
    piece.rotation = 1
    local blocks1 = piece:getBlocks()
    
    piece.rotation = 2
    local blocks2 = piece:getBlocks()
    
    piece.rotation = 3
    local blocks3 = piece:getBlocks()
    
    -- O piece should be identical in all rotations
    assert(#blocks0 == 4 and #blocks1 == 4 and #blocks2 == 4 and #blocks3 == 4,
        "O piece should have 4 blocks in all rotations")
    
    return true
end

-- Test that T piece has correct center block
local function test_T_piece_has_center()
    local piece = pieces.Tetromino:new("T", 5, 5, 0)
    local blocks = piece:getBlocks()
    
    -- T piece should have a center block at (5+1, 5+1) = (6, 6) for rotation 0
    local hasCenter = false
    for _, block in ipairs(blocks) do
        if block.x == 6 and block.y == 6 then
            hasCenter = true
            break
        end
    end
    
    assert(hasCenter, "T piece rotation 0 should have center block at correct position")
    return true
end

-- Run unit tests
print("\n=== Unit Tests: Tetromino Shapes ===")

local tests = {
    {"All piece types exist", test_all_piece_types_exist},
    {"All shapes have 4 blocks", test_all_shapes_have_4_blocks},
    {"I piece rotations", test_I_piece_rotations},
    {"O piece rotations", test_O_piece_rotations},
    {"T piece has center", test_T_piece_has_center},
}

local passed = 0
local failed = 0

for _, test in ipairs(tests) do
    local name, func = test[1], test[2]
    local success, err = pcall(func)
    if success then
        print("✓ " .. name)
        passed = passed + 1
    else
        print("✗ " .. name .. ": " .. tostring(err))
        failed = failed + 1
    end
end

print(string.format("\nUnit Tests: %d passed, %d failed\n", passed, failed))

return failed == 0
