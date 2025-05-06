local pd <const> = playdate
local gfx <const> = playdate.graphics
-- StateManager to track game states
StateManager = {
    currentState = "idle",
    states = { "idle", "casting", "fishing", "reeling" }
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

function StateManager:update()
    -- Logic to handle state-specific updates can go here
end

function pd.update()
    StateManager:update()
end