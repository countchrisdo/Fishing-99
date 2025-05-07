local pd <const> = playdate
local gfx <const> = playdate.graphics
-- import timer 
import "CoreLibs/timer"
import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/animation"

local FISHDATA1 = import "data/FISHDATA"
local corruptedFishImg = gfx.imagetable.new("assets/sprites/fish/corrupt-table-22-20")
local corruptedFishAnim = gfx.animation.loop.new(100, corruptedFishImg, true)


FishManager = {
    FISHDATA = FISHDATA1,
    state = "inactive",
    states = { "inactive", "active" },
    activeFish = {}, -- List of spawned fish
    spawnInterval = 2000, -- milliseconds between fish spawns
    lastSpawnTime = 0,
}

function FishManager:initialize()
    self.state = "active"
end


--[[
setAnimator()
setAnimator assigns an playdate.graphics.animator to the sprite, which will cause the sprite to automatically update its position each frame while the animator is active.
animator should be a playdate.graphics.animator created using playdate.geometry.points for its start and end values.
movesWithCollisions, if provided and true will cause the sprite to move with collisions. A collision rect must be set on the sprite prior to passing true for this argument.
removeOnCollision, if provided and true will cause the animator to be removed from the sprite when a collision occurs.
]]


function FishManager:getFishByDepth(depth)
-- Returns: list of fish that can spawn at the given depth.
    local availableFish = {}
    for _, fish in ipairs(self.FISHDATA) do
        if depth >= fish.depthRange.min and depth <= fish.depthRange.max then
            table.insert(availableFish, fish)
        end
    end
    return availableFish
end

function FishManager:getRandomFish()
    -- Picks a random fish from the available fish data and returns it
    return self.FISHDATA[math.random(#self.FISHDATA)]
end

function FishManager:spawnFish(depth)
    if self.state == "inactive" then
        print("FishManager is inactive. Cannot spawn fish.")
        return
    end

    print("Checking if fish can spawn at depth:", depth)
    local availableFish = self:getFishByDepth(depth)
    if #availableFish == 0 then
        print("No fish available at this depth.")
        return
    end
    print("Fish available at this depth:", #availableFish)

    if #availableFish > 0 then
        local fish = availableFish[math.random(#availableFish)]
        local fishImage = nil
        if fish.discovered then
            print("Known Fish Spawn:", fish.name)
            fishImage = gfx.image.new(fish.spritePath)
        else
            print("Unknown Fish Spawn:", fish.name)
            fishImage = corruptedFishAnim:image()
        end


        if not fishImage then
            print("Failed to load fish image:", fish.spritePath)
            return
        end

        local fishSprite = gfx.sprite.new(fishImage)
        fishSprite.update = function()
            if fish.discovered then
                fishSprite:setImage(fishImage)
            else
                fishSprite:setImage(corruptedFishAnim:image())
            end
        end

        fishSprite:setScale(2)

        fishSprite:setCollideRect(0, 0, fishSprite:getSize())
        fishSprite:setZIndex(Z_INDEX.FISH)
        fishSprite:setTag(2)

        fishSprite:moveTo(0, CameraManager.cameraPosition.y + math.random(64, 128))
        fishSprite:add()

        table.insert(self.activeFish, {
            sprite = fishSprite,
            data = fish,
            speed = math.random(1, 3)
        })
        print("activeFish Number:", #self.activeFish)
    end
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

function FishManager:markDiscovered(curfish)
    -- Update fish data to mark it as discovered
    for i, fish in ipairs(self.FISHDATA) do
        if fish.name == curfish.name then
            fish.discovered = true
            print("Fish data updated: Discovered ", fish.name)
            break
        end
    end
end