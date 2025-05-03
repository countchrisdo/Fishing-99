local pd <const> = playdate
local gfx <const> = playdate.graphics

-- import "managers/playerManager"
-- local hookdepth = PlayerManager.hookDepth

CameraManager = {}

-- CameraManager to handle camera positioning and movement
function CameraManager:initialize()
    self.cameraPosition = { x = 0, y = 0 }
    self.cameraSpeed = 2 -- Speed of camera movement
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
    self.cameraPosition.y = depth / 100  -- Adjust camera position based on depth, scaling to fit the screen height
end

function CameraManager:draw()
    -- Adjust drawing based on camera position
    gfx.pushContext()
    gfx.setDrawOffset(0, -self.cameraPosition.y)  -- Adjust vertical offset based on camera position
    
    -- Draw the game world here (e.g., background, player, etc.)
    PlayerManager:draw()  -- Assuming PlayerManager has a draw method
    UIManager:draw()      -- Assuming UIManager has a draw method
    
    gfx.popContext()
end

