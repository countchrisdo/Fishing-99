local pd <const> = playdate
local gfx <const> = playdate.graphics

import "managers/UIManager"
import "managers/cameraManager"
import "managers/fishManager"

PlayerManager = {}

function PlayerManager:initialize()
    self.playerState = "idle"
    self.hookState = "idle"

    self.hImage = gfx.image.new("assets/sprites/hook")
    self.hSprite = gfx.sprite.new(self.hImage)
    self.hSprite:setCenter(0.5, 0.5)
    self.hSprite:setCollideRect(0, 0, self.hSprite:getSize())
    self.hSprite:setZIndex(Z_INDEX.PLAYER)
    
    self.hSprite:add()

    -- self.hookPosition = { x = 32, y = 32 }
    self.pSprite = gfx.image.new("assets/sprites/gup")
    self.playerPosition = { x = 8, y = 24 }

    self.pMoney = 0 
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

function PlayerManager:draw()
    -- Draw Player
    self.pSprite:draw(self.playerPosition.x, self.playerPosition.y) -- Draw player sprite at its position
    -- Draw Player's Boat
    gfx.drawRect(self.playerPosition.x, self.playerPosition.y + 56, 80, 32)
    if StateManager.currentState == "idle" then
        self.hSprite:moveTo(self.playerPosition.x + 64, self.playerPosition.y + 16)
    end
    -- draw fishing line
    gfx.drawLine(self.playerPosition.x + 64, self.playerPosition.y + 16, self.hSprite.x, self.hSprite.y - 16)
end

function PlayerManager:update()
    if StateManager.currentState == "idle" then
        self.hSprite.y = self.playerPosition.y
        if pd.buttonIsPressed(pd.kButtonA) then
            StateManager:setState("casting")
            SoundManager:playSound("cast", 1)
            SoundManager:playSound("reel", 2)
            print("Casting hook...")
        end
    elseif StateManager.currentState == "casting" then
        -- Move the hook towards the center of the screen
        local targetX = MaxWidth / 2 - 2.5 -- Center of the screen minus half the hook width
        local targetY = MaxHeight / 2 + 130 -- Center of the screen plus some offset

        if self.hSprite.x < targetX then
            self.hSprite:moveTo(self.hSprite.x + self.hookSpeed, self.hSprite.y)
        end
        if self.hSprite.y < targetY then
            self.hSprite:moveTo(self.hSprite.x, self.hSprite.y + self.hookSpeed)
        end

        -- Stop moving when the hook reaches the target position
        if self.hSprite.x >= targetX and self.hSprite.y >= targetY then
            print("Hook reached the center of the screen.")

            -- Play this sound when hook collides with the water
            -- SoundManager:playSound("splash", 1)

            StateManager:setState("fishing")
        end

        -- Move Depth lower
        if self.depth < 125 then
            self.depth = self.depth + 2
            CameraManager:moveCamera(self.depth)
            print("Depth adjusted to:", self.depth)
        end

    elseif StateManager.currentState == "fishing" then
        self:handleInput()
        FishManager:checkCollisionHook(self.hSprite.x, self.hSprite.y)

        if #self.hookInventory >= self.hookInventorymax then
            StateManager:setState("reeling")
            print("Hook is full, reeling in...")
        end
    elseif StateManager.currentState == "reeling" then
        self:handleInput() -- Handle player input for moving the hook
        if self.depth > 0 then
            self.depth = self.depth - 2
            self.hSprite:moveTo( self.hSprite.x, CameraManager.cameraPosition.y + 64)
            CameraManager:moveCamera(self.depth)
            print("Depth adjusted to:", self.depth)
        else
            -- Hook has reached the player
            -- Add the value of the caught fish to the player's money
            for i = 1, #self.hookInventory do
                self.pMoney = self.pMoney + self.hookInventory[i].value
                print("Caught fish value:", self.hookInventory[i].value)
            end
            print("Total money:", self.pMoney)
            SoundManager:playSound("cash", 3)
            -- Clear the hook inventory
            self.hookInventory = {}
            StateManager:setState("idle")
            print("Hook retracted, back to idle state.")
        end
    end
end

function PlayerManager:handleInput()
    -- Handle player input for movement and actions
    if pd.buttonIsPressed(pd.kButtonUp) then
        self.hSprite:moveTo(self.hSprite.x, self.hSprite.y - self.hookSpeed)
    elseif pd.buttonIsPressed(pd.kButtonDown) then
        self.hSprite:moveTo(self.hSprite.x, self.hSprite.y + self.hookSpeed)
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self.hSprite:moveTo(self.hSprite.x - self.hookSpeed, self.hSprite.y)
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self.hSprite:moveTo(self.hSprite.x + self.hookSpeed, self.hSprite.y)
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
            print("Too Low Depth adjusted to:", self.depth)
        else
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