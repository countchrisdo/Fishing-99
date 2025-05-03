local pd <const> = playdate
local gfx <const> = playdate.graphics

import "managers/stateManager"
import "managers/UIManager"
import "managers/playerManager"


-- Initialize managers
PlayerManager:initialize()
UIManager:initialize()
CameraManager:initialize()

function pd.update()
    StateManager:update()
    gfx.clear()
    
    PlayerManager:update()
    CameraManager:update()
    UIManager:update()
    
    
end
