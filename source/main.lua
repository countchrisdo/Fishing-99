local pd <const> = playdate
local gfx <const> = playdate.graphics

import "managers/stateManager"
import "managers/UIManager"
import "managers/playerManager"
-- import "managers/cameraManager"
import "managers/fishManager"


-- Initialize managers
PlayerManager:initialize()
FishManager:initialize()
UIManager:initialize()
CameraManager:initialize()


function pd.update()
    StateManager:update()
    gfx.clear()
    
    PlayerManager:update()
    FishManager:update()
    CameraManager:update()
    UIManager:update()
end
