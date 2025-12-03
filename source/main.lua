import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

function playdate.update()
    gfx.clear()
    playdate.timer.updateTimers()
    gfx.sprite.update()
    playdate.drawFPS(0, 0)
end
