local pd <const> = playdate
local gfx <const> = playdate.graphics

import "managers/UIManager"
import "managers/cameraManager"
import "managers/fishManager"
import "CoreLibs/sprites"

PlayerManager = {}

function PlayerManager:initialize()
    self.playerState = "idle"
    self.hookState = "idle"

    self.collisionResponse = gfx.sprite.kCollisionTypeOverlap

    self.hSprite = gfx.sprite.new(gfx.image.new("assets/sprites/hook3"))
    self.hSprite:setCollideRect(0, 0, self.hSprite:getSize())
    self.hSprite:setZIndex(Z_INDEX.PLAYER)
    self.hSprite:setTag(1)
    self.hSprite:add()

    self.pSprite = gfx.sprite.new(gfx.image.new("assets/sprites/gup2"))
    self.pSprite:setZIndex(Z_INDEX.PLAYER)
    self.pSprite:add()

    self.rSprite = gfx.sprite.new(gfx.image.new("assets/sprites/rod"))
    self.rSprite:setZIndex(Z_INDEX.FISH)
    self.rSprite:add()

    self.bSprite = gfx.sprite.new(gfx.image.new("assets/sprites/boat"))
    self.bSprite:setZIndex(Z_INDEX.FISH)
    self.bSprite:add()

    self.playerPosition = { x = 32, y = 76 }
    self.rodPosition = { x = self.playerPosition.x + 18, y = self.playerPosition.y + 2}
    self.boatPosition = { x = self.playerPosition.x + 4, y = self.playerPosition.y + 20 }
    self.hookPosition = { x = self.playerPosition.x + 36, y = self.playerPosition.y + 4 }

    self.rSprite:moveTo(self.rodPosition.x, self.rodPosition.y)
    self.hSprite:moveTo(self.hookPosition.x, self.hookPosition.y)
    self.pSprite:moveTo(self.playerPosition.x, self.playerPosition.y)
    self.bSprite:moveTo(self.boatPosition.x, self.boatPosition.y)

    self.pMoney = 0
    self.hookInventory = {}
    self.hookInventorymax = 3 -- Maximum items on the hook
    self.hookSpeed = 2
    self.depth = 0 -- Depth of the hook, can be used for camera positioning or other logic. modifyed by the crank
    self.depthMax = 1000 -- Maximum depth
end

Compendium = {
    fishList = {}
}
function Compendium:addFish(fish)
    if not self.fishList[fish.name] then
        self.fishList[fish.name] = fish
        print("New fish discovered:", fish.name)
    end
end

function Compendium:updateFishCount(fish)
    if self.fishList[fish.name] then
        self.fishList[fish.name].count = (self.fishList[fish.name].count or 0) + 1
        print("Fish count updated:", fish.name, "Count:", self.fishList[fish.name].count)
    end
end

function PlayerManager:draw()
    -- draw fishing line
    gfx.drawLine(self.rodPosition.x + 10, self.rodPosition.y - 8, self.hSprite.x, self.hSprite.y - 8)
end

function PlayerManager:update()
    if StateManager.currentState == "idle" then
        -- self.hSprite.y = self.hookPosition.y

        if pd.buttonIsPressed(pd.kButtonA) then
            StateManager:setState("casting")
            SoundManager:playSound("cast", 1)
            SoundManager:playSound("reel", 2)
            print("Casting hook...")
        end
    elseif StateManager.currentState == "casting" then
        -- Move the hook towards the center of the screen
        local targetX = MaxWidth / 2
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
        local collisions = self.hSprite:overlappingSprites()
        for i, sprite in ipairs(collisions) do
            if sprite:getTag() == 2 then -- Tag 2 = Fish
                print("Collision with fish detected!")
                local curFish = nil
                for idx = 1, #FishManager.activeFish do
                    if FishManager.activeFish[idx].sprite == sprite then
                        curFish = FishManager.activeFish[idx].data

                        if curFish.discovered == false then
                            Compendium:addFish(curFish)
                            FishManager:markDiscovered(curFish)
                            print("New Fish Discovered:", curFish.name)
                        end

                        Compendium:updateFishCount(curFish)

                        FishManager.activeFish[idx].sprite:remove()
                        table.insert(self.hookInventory, curFish)

                        table.remove(FishManager.activeFish, idx)
                        sprite:remove()
                        print("Caught fish:", curFish.name)
                        SoundManager:playSound("catch", 1)
                        break
                    end
                end
            end
        end

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
                print("Caught fish:", self.hookInventory[i].name)
                print("Caught fish value:", self.hookInventory[i].value)
                SoundManager:playSound("cash", 1)
            end
            print("Total money:", self.pMoney)
            -- SoundManager:playSound("cash", 3)
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
        self.depth = math.floor(self.depth + (crankChange / 2))

        if self.depth < 0 then
            self.depth = 0
            print("Too High, Depth adjusted to:", self.depth)
        elseif self.depth >= self.depthMax then
            self.depth = self.depthMax
            print("Too Low Depth adjusted to:", self.depth)
        else
            CameraManager:moveCamera(self.depth)
            if self.hSprite.y >= MaxHeight + self.depth then
                self.hSprite:moveTo(self.hSprite.x, MaxHeight + self.depth)
                print("Too far down, Hook adjusted to:", self.depth)
            elseif self.hSprite.y <= 0 + self.depth then
                self.hSprite:moveTo(self.hSprite.x, 0 + self.depth)
                print("Too far up, Hook adjusted to:", self.depth)
            elseif self.hSprite.x <= 0 then
                self.hSprite:moveTo(0, self.hSprite.y)
                print("Too far left, Hook adjusted to:", self.depth)
            elseif self.hSprite.x >= MaxWidth then
                self.hSprite:moveTo(MaxWidth, self.hSprite.y)
                print("Too far right, Hook adjusted to:", self.depth)
            end
            -- Clamp the hook's y position to stay towards the center of the screen
            if self.hSprite.y  < 40 + self.depth then
                self.hSprite:moveTo(self.hSprite.x, self.hSprite.y + 2)
                print("Too High! Clamping Y Position:", self.hSprite.y)
            elseif self.hSprite.y  > 200 + self.depth then
                self.hSprite:moveTo(self.hSprite.x, self.hSprite.y - 2)
                print("Too Low! Clamping Y Position:", self.hSprite.y)
            end
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
