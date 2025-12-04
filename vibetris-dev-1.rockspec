rockspec_format = "3.0"
package = "vibetris"
version = "dev-1"

source = {
   url = "git://github.com/yourusername/vibetris.git"
}

description = {
   summary = "A Vibetris implementation for the Playdate handheld console",
   detailed = [[
      A classic block-stacking game built for the Playdate console featuring:
      - Dual rotation input (crank or B button)
      - Traditional Tetris mechanics with wall kicks
      - Line clearing with visual feedback
      - Progressive difficulty scaling
      - Comprehensive test suite with property-based testing
   ]],
   homepage = "https://github.com/yourusername/vibetris",
   license = "MIT"
}

dependencies = {
   "lua >= 5.1"
}

build = {
   type = "builtin",
   modules = {
      ["game.collision"] = "source/game/collision.lua",
      ["game.init"] = "source/game/init.lua",
      ["game.manager"] = "source/game/manager.lua",
      ["game.playfield"] = "source/game/playfield.lua",
      ["game.score"] = "source/game/score.lua",
      ["game.state"] = "source/game/state.lua",
      ["input.init"] = "source/input/init.lua",
      ["pieces.init"] = "source/pieces/init.lua",
      ["rendering.init"] = "source/rendering/init.lua",
   }
}

test_dependencies = {
   "luacov >= 0.15.0"
}

test = {
   type = "command",
   command = "lua tests/run_tests.lua"
}
