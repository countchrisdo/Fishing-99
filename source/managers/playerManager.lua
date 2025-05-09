-- Contains: PlayerManager{} and FishDex{}
local pd <const> = playdate
local gfx <const> = playdate.graphics
import "CoreLibs/sprites"

PlayerManager = {
    state = "inactive",
    states = { "inactive", "active"},
    pMoney = 0,
    hookSpeed = 2,
    -- Upgrades
    depth = 0, depthMax = 200, baseDepthMax = 200,-- lineLength
    hookInventory = {}, hookInventorymax = 1, baseHookInventorymax = 1, -- hookCapacity
    baitQuality = 1, baseBaitQuality = 1,--baitQuality (multiply for fish value)
}

function PlayerManager:initialize()
    print("PlayerManager initialized")
    self.state = "active"
    self.collisionResponse = gfx.sprite.kCollisionTypeOverlap

    self.hSprite = gfx.sprite.new(gfx.image.new("assets/sprites/hook2"))
    self.hSprite:setScale(2)
    self.hSprite:setCollideRect(0, 8, 16, 10)
    self.hSprite:setZIndex(Z_INDEX.PLAYER)
    self.hSprite:setTag(1)
    self.hSprite:add()

    self.pSprite = gfx.sprite.new(gfx.image.new("assets/sprites/gup2"))
    self.pSprite:setScale(2)
    self.pSprite:setZIndex(Z_INDEX.PLAYER)
    self.pSprite:add()

    self.rSprite = gfx.sprite.new(gfx.image.new("assets/sprites/rod"))
    self.rSprite:setScale(2)
    self.rSprite:setZIndex(Z_INDEX.FISH)
    self.rSprite:add()

    self.bSprite = gfx.sprite.new(gfx.image.new("assets/sprites/boat"))
    self.bSprite:setZIndex(Z_INDEX.FISH)
    self.bSprite:setScale(2)
    self.bSprite:add()

    self.playerPosition = { x = 64, y = 56 }
    self.rodPosition = { x = self.playerPosition.x + 42, y = self.playerPosition.y + 0}
    self.boatPosition = { x = self.playerPosition.x + 4, y = self.playerPosition.y + 40 }
    self.hookPosition = { x = self.playerPosition.x + 64, y = self.playerPosition.y + -2 }

    self.rSprite:moveTo(self.rodPosition.x, self.rodPosition.y)
    self.hSprite:moveTo(self.hookPosition.x, self.hookPosition.y)
    self.pSprite:moveTo(self.playerPosition.x, self.playerPosition.y)
    self.bSprite:moveTo(self.boatPosition.x, self.boatPosition.y)

    self.depth = 0

    --Init upgrades
    self:applyUpgrades()
end

FishDex = {
    fishList = {}
}
function FishDex:addFish(fish)
    if not self.fishList[fish.name] then
        self.fishList[fish.name] = fish
        print("New fish discovered:", fish.name)
    end
end

function FishDex:updateFishCount(fish)
    if self.fishList[fish.name] then
        self.fishList[fish.name].count = (self.fishList[fish.name].count or 0) + 1
        print("Fish count updated:", fish.name, "Count:", self.fishList[fish.name].count)
    end
end

function FishDex:returnAllFish()
    return self.fishList
end



function PlayerManager:draw()
    -- draw fishing line
    if StateManager:getState() ~= "shopping" and StateManager:getState() ~= "main menu" then
        gfx.drawLine(self.rodPosition.x + 15, self.rodPosition.y - 12, self.hSprite.x, self.hSprite.y - 10)
    end
end

function PlayerManager:update()

    if StateManager.currentState == "idle" then
        if self.buttonCooldown then
            return -- Ignore input during cooldown
        end
        if pd.buttonJustPressed(pd.kButtonA) then
            print("A button pressed, casting hook...")
            StateManager:setState("casting")
            SoundManager:playSound("cast", 1)
            SoundManager:playSound("reel", 2)

            -- Set a cooldown to prevent immediate re-trigger
            self.buttonCooldown = pd.timer.new(300, function()
                self.buttonCooldown = nil
            end)
        end

        if pd.buttonJustPressed(pd.kButtonB) then
            -- Set a cooldown to prevent immediate reopening
            self.buttonCooldown = pd.timer.new(300, function()
                self.buttonCooldown = nil
            end)
            print("B button pressed, opening shopping menu...")
            StateManager:setState("shopping")
            ShoppingMenu:show()
            self.pSprite:remove()
            self.rSprite:remove()
            self.bSprite:remove()
            self.hSprite:remove()
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
            -- print("MoveCamera Called by PlayerManager at Depth:", self.depth)
        end

    elseif StateManager.currentState == "fishing" then
        self:handleInput()
        local collisions = self.hSprite:overlappingSprites()
        for i, sprite in ipairs(collisions) do
            if sprite:getTag() == 2 then -- Tag 2 = Fish
                print("Collision with fish detected!")
                local curFish = nil
                -- Add a Fishing Cooldown here?
                for idx = 1, #FishManager.activeFish do
                    if FishManager.activeFish[idx].sprite == sprite then
                        curFish = FishManager.activeFish[idx].data

                        if curFish.discovered == false then
                            FishDex:addFish(curFish)
                            FishManager:markDiscovered(curFish)
                            print("New Fish Discovered:", curFish.name)
                        end

                        FishDex:updateFishCount(curFish)

                        FishManager.activeFish[idx].sprite:remove()
                        table.insert(self.hookInventory, curFish)

                        table.remove(FishManager.activeFish, idx)
                        sprite:remove()
                        print("Caught fish:", curFish.name)
                        print("Fish value:", curFish.value)
                        UIManager:textAtFish(curFish.value * self.baitQuality, self.hSprite.x, self.hSprite.y)
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
            -- print("Depth adjusted to:", self.depth)
        else
            -- Hook has reached the player
            -- Add the value of the caught fish to the player's money
            for i = 1, #self.hookInventory do
                self.pMoney = self.pMoney + (self.hookInventory[i].value * self.baitQuality)
                print("Caught fish:", self.hookInventory[i].name)
                print("Value:", self.hookInventory[i].value * self.baitQuality)
                SoundManager:playSound("cash", 1)
            end
            print("Total money:", self.pMoney)
            -- SoundManager:playSound("cash", 1)
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

-- Upgrades
function PlayerManager:applyUpgrades()
    print("PlayerManager:applyUpgrades() called")
    for key, upgrade in pairs(Upgrades) do
        print("-", upgrade.id)
            upgrade.apply(self) -- Call the apply function for the specific upgrade
        end
    end

function PlayerManager:saveState()
    local playerData = {
        pMoney = self.pMoney,
        upgrades = {
            depthMax = self.depthMax,
            hookInventorymax = self.hookInventorymax,
            baitQuality = self.baitQuality,
        },
        fishDex = FishDex.fishList,
    }
    SaveManager:savePlayerData(playerData)
end

function PlayerManager:loadState()
    local playerData = SaveManager:loadPlayerData()
    if playerData then
        print("Player state loaded from save file.")
        self.pMoney = playerData.pMoney or self.pMoney
        self.depthMax = playerData.upgrades.depthMax or self.baseDepthMax
        self.hookInventorymax = playerData.upgrades.hookInventorymax or self.baseHookInventorymax
        self.baitQuality = playerData.upgrades.baitQuality or self.baseBaitQuality
        FishDex.fishList = playerData.fishDex or {}
        print("Player state loaded into PlayerManager.")
    end
end
