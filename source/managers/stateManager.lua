local pd <const> = playdate
local gfx <const> = playdate.graphics

StateManager = {
    currentState = "idle",
    states = { "idle", "casting", "fishing", "reeling" },
}
-- Idle: player is ready to cast the fishing line
-- Casting: player is casting the fishing line
-- Fishing: player can now move the hook to collide with a fish to catch it
-- Reeling: player hit the max number of fish on the hook [hookInventorymax] and is reeling them in to reset to idle state


-- Todo: Implement entry/exit hooks for each state if needed
function StateManager:setState(newState)
    if table.indexOfElement(self.states, newState) then
        self.currentState = newState
        -- SoundManager:switchBGM(newState)
        print("State changed to:", newState)
    else
        print("Invalid state:", newState)
    end
end

function StateManager:getState()
    return self.currentState
end

-- Communitcation with Console
function pd.serialMessageReceived(message)
    print("Message received:", message)
    if message == "cast" then
        StateManager:setState("casting")
        SoundManager:playSound("cast", 1)
        SoundManager:playSound("reel", 2)
        print("Casting hook...")
    elseif message == "reel" then
        StateManager:setState("reeling")
        SoundManager:playSound("reel", 2)
        print("Reeling in fish...")
    elseif message == "catch" then
        SoundManager:playSound("catch", 1)
        local fish = FishManager:getRandomFish()
        PlayerManager.hookInventory[#PlayerManager.hookInventory + 1] = fish
        print("Fish caught:", fish)
    else
        print("Unknown Command")
    end
end
