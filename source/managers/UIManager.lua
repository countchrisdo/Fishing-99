local pd <const> = playdate
local gfx <const> = playdate.graphics

import "managers/stateManager"

UIManager = {}
-- UIManager to handle UI elements and interactions
-- function UIManager:initialize()
--     self.uiElements = {}
--     self.currentState = "idle"
-- end

function UIManager:drawUI()
    
    -- Draw UI elements based on the current state
    gfx.drawText("Current State: " .. StateManager:getState(), 10, 10)
end

-- function UIManager:update()

-- end