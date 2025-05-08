local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/timer"

local MPH = 1000 * 60 * 60 -- Miliseconds per Hour (real time)
local MPM = 1000 * 60 -- Miliseconds per Minute (real time)

-- Manages the world state, including time of day and weather. 
WorldManager = {
    timeOfDay = "day",
    timesOfDay = {
        dawn = { start = 5 * MPM, stop = 6 * MPM },
        day = { start = 6 * MPM, stop = 18 * MPM },
        dusk = { start = 18 * MPM, stop = 19 * MPM},
        night = { start = 19 * MPM, stop = 5 * MPM}
    },
    currentTime = 5 * MPM, -- Current time in milliseconds
}

function WorldManager:update()
    -- Update the current time based on the time scale
    local deltaTime = pd.getCurrentTimeMilliseconds() - (self.lastUpdateTime or pd.getCurrentTimeMilliseconds())
    self.lastUpdateTime = pd.getCurrentTimeMilliseconds()

    self.currentTime = (self.currentTime + deltaTime) % (24 * MPM) -- Loop every 24 minutes (1 in-game day)

    local totalSeconds = self.currentTime / 1000
    local inGameMinutes = math.floor(totalSeconds % 60) -- Real seconds = 60 seconds (1 minute)
    local inGameHours = math.floor(totalSeconds / 60) % 24 -- Real minutes = 60 minutes (1 hour) Wrapping around 24 Minutea
    local AMPM = ""

    if inGameHours <= 12 then
        inGameHours = inGameHours
        AMPM = "AM"
    else
        inGameHours = inGameHours - 12
        AMPM = "PM"
    end

    self.formattedTime = string.format("%02d:%02d %s", inGameHours, inGameMinutes, AMPM)
    

    for timeOfDay, times in pairs(self.timesOfDay) do
        -- Check if the current time falls within the start and stop times for this time of day
        if times.start < times.stop then
            -- Normal case: start time is less than stop time
            if self.currentTime >= times.start and self.currentTime < times.stop then
                self.timeOfDay = timeOfDay
                break
            end
        else
            -- Wrap-around case: stop time is less than start time (e.g., night)
            if self.currentTime >= times.start or self.currentTime < times.stop then
                self.timeOfDay = timeOfDay
                break
            end
        end
    end
end

function WorldManager:getTimeOfDay()
    return self.timeOfDay
end

-- function WorldManager:testTimeOfDayLogic()
--     local testTimes = {
--         { time = 4 * MPM, expected = "night" },  -- Before dawn
--         { time = 5 * MPM, expected = "dawn" },  -- Start of dawn
--         { time = 5.5 * MPM, expected = "dawn" }, -- Mid-dawn
--         { time = 6 * MPM, expected = "day" },   -- Start of day
--         { time = 12 * MPM, expected = "day" },  -- Mid-day
--         { time = 0 * MPM, expected = "night" }, -- Midnight
--     }

--     for _, test in ipairs(testTimes) do
--         self.currentTime = test.time
--         self:update()
--         local result = self:getTimeOfDay()
--         print(string.format("TEST -- Time: %02d:00 or %i, Expected: %s, Got: %s", math.floor(test.time / MPM), test.time, test.expected, result))
--         assert(result == test.expected, "ALERT: Test failed for time: " .. test.time)
--     end
-- end

