local pd <const> = playdate
local gfx <const> = playdate.graphics

CameraManager = {
    cameraSpeed = 2, -- Speed of camera movement
    WaterY = 64, -- Initial water level
    cameraPosition = { x = 0, y = 0 }
}
print("CameraManager Loaded")
print(CameraManager.cameraPosition.y)

-- CameraManager to handle camera positioning and movement
function CameraManager:initialize()
    self.cameraPosition.x = 0
    self.cameraPosition.y = 0
end

function CameraManager:moveCamera(depth)
    -- This function will be called by PlayerManager to adjust the camera based on hook depth
    self.cameraPosition.y = depth
end

function CameraManager:draw()
    -- if not self.cameraPosition.y then
    --     self.cameraPosition.y = 0
    -- end

    gfx.pushContext()
    gfx.setDrawOffset(0, -self.cameraPosition.y)  -- Adjust y offset based on camera position
    -- Draw the game world here
    gfx.sprite.update()
    PlayerManager:draw()
    if StateManager:getState() ~= "shopping" and StateManager:getState() ~= "main menu" then
        gfx.drawLine(0, 64+self.WaterY, MaxWidth, 64+self.WaterY) -- Water surface line
    end
    gfx.popContext()
end

function CameraManager:update()
    -- if the player is not in the store or main menu, update the water level
    
    self.WaterY = 32 + math.sin(playdate.getCurrentTimeMilliseconds() / 500) * 3

    self:draw()
end

