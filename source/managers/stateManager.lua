local pd <const> = playdate
local gfx <const> = playdate.graphics
-- StateManager to track game states
StateManager = {
    currentState = "idle",
    states = { "idle", "casting", "fishing", "reeling" }
}

function StateManager:setState(newState)
    if table.indexOfElement(self.states, newState) then
        self.currentState = newState
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
    if self.currentState == "idle" then
        -- Handle idle state logic
    elseif self.currentState == "casting" then
        -- Handle casting state logic
    end
end

function pd.update()
    StateManager:update()
end