local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "managers/stateManager"
import "managers/playerManager"

MaxWidth = 400
MaxHeight = 240

UIManager = {}
-- UIManager to handle UI elements and interactions
function UIManager:initialize()
    self.WaterY = 64 -- Initial water level
end

function UIManager:drawUI()
    gfx.drawTextAligned("Current State: " .. StateManager:getState(), MaxWidth/2, 16, kTextAlignment.center)

    if StateManager:getState() == "idle" then
        gfx.drawTextAligned("Press A to cast", MaxWidth/2, MaxHeight/2, kTextAlignment.center)
    -- elseif StateManager:getState() == "casting" then
    --     return
    -- elseif StateManager:getState() == "fishing" then
    --     return
    -- elseif StateManager:getState() == "reeling" then
    --     return
    end

    if StateManager:getState() ~= "idle" then
        gfx.drawTextAligned("Depth:"..PlayerManager.depth, MaxWidth-16, 30, kTextAlignment.right)
        gfx.drawTextAligned("Fish caught: TBD/TBD", MaxWidth-16, 50, kTextAlignment.right)
        gfx.drawTextAligned("Time: TBD", MaxWidth-16, 70, kTextAlignment.right)
    end
end

function UIManager:draw()
    gfx.drawLine(0, 64+self.WaterY, MaxWidth, 64+self.WaterY) -- Water surface line
    self:drawUI()
end

function UIManager:update()
    -- Update logic for UI elements can go here
    self.WaterY = 32 + math.sin(playdate.getCurrentTimeMilliseconds() / 500) * 4 -- Example water wave effect
    self:draw()
end