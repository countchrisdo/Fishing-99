local pd <const> = playdate
local gfx <const> = playdate.graphics

FishData = {
    {
        name = "Bass",
        value = 10,
        depthRange = { min = 0, max = 200 },
        spritePath = "assets/sprites/fish"
    },
    {
        name = "Tuna",
        value = 20,
        depthRange = { min = 100, max = 400 },
        spritePath = "assets/sprites/fish"
    },
    {
        name = "Boot",
        value = 1,
        depthRange = { min = 50, max = 300 },
        spritePath = "assets/sprites/fish"
    },
    {
        name = "Golden Fish",
        value = 100,
        depthRange = { min = 300, max = 1000 },
        spritePath = "assets/sprites/fish"
    }
}

-- Function to get fish data
function FishData:getFishByDepth(depth)
    local availableFish = {}
    for _, fish in ipairs(self) do
        if depth >= fish.depthRange.min and depth <= fish.depthRange.max then
            table.insert(availableFish, fish)
        end
    end
    return availableFish
end