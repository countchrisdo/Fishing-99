local pd <const> = playdate
local gfx <const> = playdate.graphics

import "managers/stateManager"
import "managers/UIManager"
import "managers/playerManager"
import "managers/cameraManager"
import "managers/fishManager"
import "managers/worldManager"
import "managers/soundManager"

import "data/CONSTS"


-- Initialize managers
WorldManager:initialize()
PlayerManager:initialize()
FishManager:initialize()
UIManager:initialize()
CameraManager:initialize()
SoundManager:initialize()

-- not playing yet to test sfx, remember to renable BGMswitch too
-- SoundManager:playBGM()

function pd.update()
    gfx.clear()

    WorldManager:update()
    pd.timer.updateTimers()

    PlayerManager:update()
    FishManager:update()
    CameraManager:update()
    UIManager:update()
end
