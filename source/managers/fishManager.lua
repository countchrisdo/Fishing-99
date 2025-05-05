local pd <const> = playdate
local gfx <const> = playdate.graphics
-- import timer 
import "CoreLibs/timer"
import "CoreLibs/sprites"

import "managers/stateManager"
import "managers/cameraManager"
import "managers/playerManager"
import "data/FishData"

FishManager = {}

-- FishManager to handle fish data and interactions
function FishManager:initialize()
    self.fishData = FishData
    self.activeFish = {} -- List of spawned fish
    self.spawnInterval = 2000 -- Time in milliseconds between fish spawns
    self.lastSpawnTime = 0
    print("FishManager initialized")
end

function FishManager:spawnFish(depth)
    print("Checking if fish can spawn at depth:", depth)
    local availableFish = self.fishData:getFishByDepth(depth)
    if #availableFish == 0 then
        print("No fish available at this depth.")
        return
    end
    print("Fish available at this depth:", #availableFish)

    if #availableFish > 0 then
        local fish = availableFish[math.random(#availableFish)]
        local fishImage = gfx.image.new(fish.spritePath)
        if not fishImage then
            print("Error: Failed to load fish sprite image at path:", fish.spritePath)
            return
        end

        local fishSprite = gfx.sprite.new(fishImage)
        fishSprite:setCenter(0.5, 0.5)

        -- gfx.pushContext()
        -- gfx.setDrawOffset(0, -CameraManager.cameraPosition.y)
        fishSprite:moveTo(0, CameraManager.cameraPosition.y + math.random(64, 128))
        fishSprite:add()
        -- gfx.popContext()

        fish.ID = math.random(1, 1000) -- Unique ID for the fish
        print("Spawned fish:", fish.name .. " With ID:", fish.ID)

        table.insert(self.activeFish, {
            sprite = fishSprite,
            data = fish,
            speed = math.random(1, 3)
        })
        print("activeFish Number:", #self.activeFish)
    end
end

function FishManager:checkCollisionHook(hookX, hookY)
    if self.activeFish then
        for i = #self.activeFish, 1, -1 do
            local fish = self.activeFish[i]
            local fishX, fishY = fish.sprite:getPosition()

            -- Simple collision detection
            if math.abs(fishX - hookX) < 10 and math.abs(fishY - hookY) < 10 then
                self.currentFish = fish.data
                fish.sprite:remove()
                table.insert(PlayerManager.hookInventory, fish.data)
                table.remove(self.activeFish, i)
                print("Caught fish:", fish.data.name)
                break
            end
        end
    end
end

function FishManager:draw()

end

function FishManager:update()
    local currentTime = playdate.getCurrentTimeMilliseconds()

    -- Spawn fish at intervals
    if currentTime - self.lastSpawnTime > self.spawnInterval then
        self:spawnFish(PlayerManager.depth)
        self.lastSpawnTime = currentTime
    end

    -- Update active fish
    self:updateFish()
end

function FishManager:updateFish()
    for i = #self.activeFish, 1, -1 do
        local fish = self.activeFish[i]
            local x, y = fish.sprite:getPosition()
            fish.sprite:moveTo(x + fish.speed, y)

        -- Remove fish if it goes off-screen
        if x > 400 or x < 0 then
            fish.sprite:remove()
            table.remove(self.activeFish, i)
        end
    end
end

function FishManager:reset()
    self.activeFish = nil
end

function FishManager:getFishByDepth(depth)
    return self.fishData:getFishByDepth(depth)
end