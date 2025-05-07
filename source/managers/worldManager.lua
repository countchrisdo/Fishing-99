local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/timer"

local HTM = 1000 * 60 * 60 -- Hours to Milliseconds
local MTM = 1000 * 60 -- Minutes to Milliseconds

-- Manages the world state, including time of day and weather. 
WorldManager = {
    timeOfDay = "day",
    timesofDay = {
        dawn = { start = 5 * HTM, stop = 6 * HTM },
        day = { start = 6 * HTM, stop = 18 },
        dusk = { start = 18 * HTM, stop = 19 * HTM},
        night = { start = 19 * HTM, stop = 5 * HTM }
    },
    currentTime = 6 * MTM, -- Current time in milliseconds
}

function WorldManager:update()
    -- Update the current time based on the time scale
    local deltaTime = pd.getCurrentTimeMilliseconds() - (self.lastUpdateTime or pd.getCurrentTimeMilliseconds())
    self.lastUpdateTime = pd.getCurrentTimeMilliseconds()

    self.currentTime = (self.currentTime + deltaTime) % (24 * MTM) -- Loop every 24 minutes (1 in-game day)

    local totalSeconds = self.currentTime / 1000
    local inGameMinutes = math.floor(totalSeconds % 60) -- In-game minutes
    local inGameHours = math.floor(totalSeconds / 60) % 24 -- In-game hours (24-hour clock)
    local AMPM = ""

    if inGameHours <= 12 then
        inGameHours = inGameHours
        AMPM = "AM"
    else
        inGameHours = inGameHours - 12
        AMPM = "PM"
    end

    -- Format the time as HH:MM AM/PM
    self.formattedTime = string.format("%02d:%02d %s", inGameHours, inGameMinutes, AMPM)
    

    for timeOfDay, times in pairs(self.timesofDay) do
        if self.currentTime >= times.start and self.currentTime < times.stop then
            self.timeOfDay = timeOfDay
            break
        end
    end

    -- Call the draw function to update the visual representation of the world state
    self:draw()
end

function WorldManager:draw()

end

