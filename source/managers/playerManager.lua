local pd <const> = playdate
local gfx <const> = playdate.graphics

import "managers/UIManager"
import "managers/cameraManager"

PlayerManager = {
}
-- PlayerManager to handle fishing hook and player states

function PlayerManager:initialize()
    self.playerState = "idle"
    self.hookState = "idle"

    self.hSprite = nil -- Placeholder for hook sprite
    self.hookPosition = { x = 32, y = 32 }
    self.pSprite = gfx.image.new("assets/sprites/gup")
    self.playerPosition = { x = 8, y = 24 }

    self.hookInventory = {}
    self.hookInventorymax = 3 -- Maximum items on the hook
    self.hookSpeed = 2 -- Speed of the hook movement
    self.depth = 0 -- Depth of the hook, can be used for camera positioning or other logic. modifyed by the crank
    self.depthMax = 1000 -- Maximum depth
end
function PlayerManager:setState(newState)
    self.playerState = newState
    print("Player state changed to:", newState)
end
function PlayerManager:getState()
    return self.playerState
end
function PlayerManager:moveHook(x, y)
    self.hookPosition.x = x
    self.hookPosition.y = y
end

function PlayerManager:draw()
    -- Draw Player
    self.pSprite:draw(self.playerPosition.x, self.playerPosition.y) -- Draw player sprite at its position
    -- Draw Player's Boat
    gfx.drawRect(self.playerPosition.x, self.playerPosition.y + 56, 80, 32)
    if StateManager.currentState == "idle" then
        -- do nothing, player is idle
    elseif StateManager.currentState == "casting" then
        gfx.drawRect(self.hookPosition.x, self.hookPosition.y, 5, 25)
    elseif StateManager.currentState == "fishing" then
        gfx.fillRect(self.hookPosition.x, self.hookPosition.y, 5, 25)
    elseif StateManager.currentState == "reeling" then
        gfx.fillRect(self.hookPosition.x, self.hookPosition.y, 5, 25)
    end
    -- draw fishing line
    gfx.drawLine(self.playerPosition.x + 64, self.playerPosition.y + 16, self.hookPosition.x + 2.5, self.hookPosition.y)
end

function PlayerManager:update()
    if StateManager.currentState == "idle" then
        self.hookPosition.y = self.playerPosition.y
        if pd.buttonIsPressed(pd.kButtonA) then
            StateManager:setState("casting")
            print("Casting hook...")
        end
    elseif StateManager.currentState == "casting" then
        -- Move the hook towards the center of the screen
        local targetX = MaxWidth / 2 - 2.5 -- Center of the screen minus half the hook width
        local targetY = MaxHeight / 2 - 12.5 -- Center of the screen minus half the hook height

        if self.hookPosition.x < targetX then
            self.hookPosition.x = math.min(self.hookPosition.x + self.hookSpeed, targetX)
        end
        if self.hookPosition.y < targetY then
            self.hookPosition.y = math.min(self.hookPosition.y + self.hookSpeed, targetY)
        end

        -- Stop moving when the hook reaches the target position
        if self.hookPosition.x == targetX and self.hookPosition.y == targetY then
            print("Hook reached the center of the screen.")
            StateManager:setState("fishing")
        end
    elseif StateManager.currentState == "fishing" then

        self:handleInput()
        if #self.hookInventory >= self.hookInventorymax then
            -- If the hook is full, switch to reeling state
            StateManager:setState("reeling")
            print("Hook is full, reeling in...")
        end
    elseif StateManager.currentState == "reeling" then
        -- Handle reeling in the hook
        self:handleInput() -- Handle player input for moving the hook
        if self.hookPosition.y >= self.playerPosition.y + 20 then
            -- Hook has reached the player, switch back to idle state
            StateManager:setState("idle")
            print("Hook retracted, back to idle state.")
        end
    end

    -- self:draw()
    -- self:draw() is now called in the CameraManager:draw() method
end
function PlayerManager:handleInput()
    -- Handle player input for movement and actions
    if pd.buttonIsPressed(pd.kButtonUp) then
        self:moveHook(self.hookPosition.x, self.hookPosition.y - self.hookSpeed)
    elseif pd.buttonIsPressed(pd.kButtonDown) then
        self:moveHook(self.hookPosition.x, self.hookPosition.y + self.hookSpeed)
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self:moveHook(self.hookPosition.x - self.hookSpeed, self.hookPosition.y)
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self:moveHook(self.hookPosition.x + self.hookSpeed, self.hookPosition.y)
    end

    -- Handle crank input
    if pd.isCrankDocked() == false then
        local crankChange = pd.getCrankChange()
        self.depth = math.floor(self.depth + crankChange)

        if self.depth < 0 then
            self.depth = 0
            print("Too High, Depth adjusted to:", self.depth)
        elseif self.depth >= self.depthMax then
            self.depth = self.depthMax
            print("Too High Depth adjusted to:", self.depth)
        else
            print("Depth adjusted to:", self.depth)
            CameraManager:moveCamera(self.depth)
        end
    end
end
function PlayerManager:reset()
    -- Reset player state and position
    self.playerState = "idle"
    self.playerPosition = { x = 0, y = 0 }
    self.playerInventory = {}
    print("Player reset to initial state.")
end
-- function PlayerManager:saveState()
--     -- Save player state to a file or database
--     local state = {
--         playerState = self.playerState,
--         playerPosition = self.playerPosition,
--         playerInventory = self.playerInventory
--     }
--     -- Save logic goes here
--     print("Player state saved.")
-- end
-- function PlayerManager:loadState()
--     -- Load player state from a file or database
--     -- Load logic goes here
--     print("Player state loaded.")
-- end