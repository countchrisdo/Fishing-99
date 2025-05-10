local pd <const> = playdate
local gfx <const> = playdate.graphics

StateManager = {
    currentState = "main menu", --Set this to idle to skip the main menu
    states = { "main menu", "idle", "shopping", "casting", "fishing", "reeling" },
}

-- Idle: player is ready to cast the fishing line
-- Casting: player is casting the fishing line
-- Shopping: player is in the shop to buy items
-- Fishing: player can now move the hook to collide with a fish to catch it
-- Reeling: player hit the max number of fish on the hook [hookInventorymax] and is reeling them in to reset to idle state


-- Todo: Implement entry/exit hooks for each state if needed
function StateManager:setState(newState)
    if table.indexOfElement(self.states, newState) then
        self.currentState = newState
        SoundManager:switchBGM(newState)
        print("State changed to:", newState)
    else
        print("Invalid state:", newState)
    end
end

function StateManager:getState()
    return self.currentState
end