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

end

function UIManager:drawUI()
    -- gfx.drawTextAligned("Current State: " .. StateManager:getState(), MaxWidth/2, 16, kTextAlignment.center)

    if StateManager:getState() == "idle" then
        gfx.drawTextAligned("Press A to cast", MaxWidth/2, MaxHeight/2, kTextAlignment.center)
        gfx.drawTextAligned("Cash:"..PlayerManager.pMoney, MaxWidth-16, 30, kTextAlignment.right)
    end

    if StateManager:getState() ~= "idle" then
        gfx.drawTextAligned("Depth:"..PlayerManager.depth, MaxWidth-16, 30, kTextAlignment.right)
        gfx.drawTextAligned("Fish caught: " .. #PlayerManager.hookInventory .. "/" .. PlayerManager.hookInventorymax, MaxWidth-16, 50, kTextAlignment.right)
        gfx.drawTextAligned("Time: TBD", MaxWidth-16, 70, kTextAlignment.right)
    end
end

function UIManager:draw()
    
    self:drawUI()
end

function UIManager:update()
    -- Update logic for UI elements can go here
    self:draw() --draw is called here to ensure UI is drawn regardless of the cameraPosition
end