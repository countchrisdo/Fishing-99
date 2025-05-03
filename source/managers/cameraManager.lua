local pd <const> = playdate
local gfx <const> = playdate.graphics

-- import "managers/playerManager"
-- local hookdepth = PlayerManager.hookDepth

CameraManager = {}

-- CameraManager to handle camera positioning and movement
function CameraManager:initialize()
    self.cameraPosition = { x = 0, y = 0 }
    self.cameraSpeed = 2 -- Speed of camera movement
    self.WaterY = 64 -- Initial water level
end

function CameraManager:setPosition(x, y)
    self.cameraPosition.x = x
    self.cameraPosition.y = y
end

function CameraManager:getPosition()
    return self.cameraPosition
end

function CameraManager:moveCamera(depth)
    -- This function will be called by PlayerManager to adjust the camera based on hook depth
    self.cameraPosition.y = depth / 10  -- Adjust camera position based on depth, scaling to fit the screen height
end

function CameraManager:draw()
    gfx.pushContext()
    gfx.setDrawOffset(0, -self.cameraPosition.y)  -- Adjust y offset based on camera position
    
    -- Draw the game world here
    PlayerManager:draw()
    gfx.drawLine(0, 64+self.WaterY, MaxWidth, 64+self.WaterY) -- Water surface line
    gfx.popContext()
end

function CameraManager:update()
    self.WaterY = 32 + math.sin(playdate.getCurrentTimeMilliseconds() / 500) * 4
    self:draw()
end

