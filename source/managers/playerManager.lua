-- Contains: PlayerManager{} and FishDex{}
local pd <const> = playdate
local gfx <const> = playdate.graphics
import "CoreLibs/sprites"

PlayerManager = {
    state = "inactive",
    states = { "inactive", "active"},
    allFishCaught = false,
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

-- Function to populate fishList using FishManager.FISHDATA
function FishDex:initialize()
    print("FishDex:initialize() called")
    for _, fish in ipairs(FishManager.FISHDATA) do
        -- Rememeber! fish.name is a key to find the fish table here.
        self.fishList[fish.name] = {
            value = fish.value,
            depthRange = fish.depthRange,
            spritePath = fish.spritePath,
            discovered = fish.discovered,
            spawnTime = fish.spawnTime,
            description = fish.description,
            lore = fish.lore,
            count = 0 -- Initialize count to 0
        }
    end
    printTable(FishDex.fishList)
    print("FishDex initialized with data from FishManager.FISHDATA.")
end

function FishDex:addFish(fish)
    -- This fish object is a copy of the fish object from FishManager
    -- So fish.name is a val
    print("FishDex:addFish() called with fish:", fish.name)
    if self.fishList[fish.name] then
        self.fishList[fish.name].discovered = true
        print(fish.name .. " discovered!")
        print("FishDex updated with new fish:", fish.name)
        ShoppingMenu:refreshFishDexArr()
    end
end

function FishDex:updateFishCount(fish)
    if self.fishList[fish.name] then
        self.fishList[fish.name].count += 1
        print("Fish count updated:", fish.name, "Count:", self.fishList[fish.name].count)
    end
end

function FishDex:returnAllFish()
    return self.fishList
end

function FishDex:hasCaughtAllFish()
    print("Running hasCaughtAllFish()")
    -- Check if all fish in the fishList have been discovered
    for _, fish in pairs(self.fishList) do
        print("Checking fish:", fish.name, "Discovered:", fish.discovered)
        if fish.discovered == false then
            print("Fish not discovered:", fish.name)
            return false -- At least one fish hasn't been caught
        end
    end
    print("All fish have been caught at least once.")
    return true -- All fish have been caught at least once
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
                for idx = 1, #FishManager.activeFish do
                    if FishManager.activeFish[idx].sprite == sprite then
                        curFish = FishManager.activeFish[idx].data
                        print("Fish data found:", curFish)

                        if curFish.discovered == false then
                            FishDex:addFish(curFish)
                            FishManager:markDiscovered(curFish)
                            print("New Fish Discovered:", curFish.name)
                            UIManager:textAtFish("New Fish Discovered!", self.hSprite.x, self.hSprite.y)
                        end

                        FishDex:updateFishCount(curFish)

                        -- Check if all fish have been caught
                        if not self.allFishCaught and FishDex:hasCaughtAllFish() then
                            self.allFishCaught = true
                            print("Congratulations! \n FishDex Complete!")
                            UIManager:displayNotification("Congratulations! \n FishDex Complete!")
                            -- Trigger any additional rewards or events here
                        end

                        FishManager.activeFish[idx].sprite:remove()
                        table.insert(self.hookInventory, curFish)

                        table.remove(FishManager.activeFish, idx)
                        sprite:remove()
                        print("Caught fish:", curFish.name)
                        print("Bait quality:", self.baitQuality)
                        print("Fish value:", curFish.value * self.baitQuality)
                        UIManager:textAtFish("+$"..math.floor(curFish.value * self.baitQuality), self.hSprite.x, self.hSprite.y - 32)
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
                self:setMoney(self.pMoney + (self.hookInventory[i].value * self.baitQuality))
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
        allFishCaught = self.allFishCaught,
        FishDex = FishDex,
    }
    SaveManager:savePlayerData(playerData)
end

function PlayerManager:loadState()
    print("PlayerManager:loadState() called")
    local playerData = SaveManager:loadPlayerData()
    if playerData then
        print("-playerData loaded from save file.")
        self.pMoney = playerData.pMoney or self.pMoney
        self.depthMax = playerData.upgrades.depthMax or self.baseDepthMax
        self.hookInventorymax = playerData.upgrades.hookInventorymax or self.baseHookInventorymax
        self.baitQuality = playerData.upgrades.baitQuality or self.baseBaitQuality
        self.allFishCaught = playerData.allFishCaught or self.allFishCaught
        FishDex.fishList = playerData.FishDex.fishList or FishDex.fishList
        printTable(playerData.FishDex)
        print("-playerData set into PlayerManager.")
    end
end

function PlayerManager:setMoney(amount)
    print("PlayerManager:setMoney() called with amount:", amount)
    if amount < 0 then
        print("Error: Amount cannot be negative.")
        return
    end
    if amount > 99999 then
        print("Error: Amount exceeds maximum limit.")
        return
    end
    self.pMoney = math.floor(amount)
end
