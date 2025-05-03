local pd <const> = playdate
local gfx <const> = playdate.graphics

import "managers/stateManager"
import "managers/UIManager"
import "managers/playerManager"

-- Initialize managers
PlayerManager:initialize()

function pd.update()
    StateManager:update()
    gfx.clear()
    
    PlayerManager:update()
    PlayerManager:draw()
    UIManager:drawUI()
    
end
