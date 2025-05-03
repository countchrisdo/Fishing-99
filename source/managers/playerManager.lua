local pd <const> = playdate
local gfx <const> = playdate.graphics

-- import "managers/stateManager"

PlayerManager = {}
-- PlayerManager to handle fishing hook and player states

function PlayerManager:initialize()
    self.playerState = "idle"
    self.hookState = "idle"
    self.hookPosition = { x = 100, y = 50 }
    self.playerPosition = { x = 10, y = 20 }
    self.hookInventory = {}
end
function PlayerManager:setState(newState)
    self.playerState = newState
    print("Player state changed to:", newState)
end
function PlayerManager:getState()
    return self.playerState
end
function PlayerManager:moveHook(x, y)
    self.hookPosition.x = x
    self.hookPosition.y = y
    print("Hook moved to:", x, y)
end
function PlayerManager:addToHook(fish)
    table.insert(self.hookInventory, fish)
    print("Item added to hook:", fish)
end
function PlayerManager:removeFromInventory(fish)
    for i, v in ipairs(self.hookInventory) do
        if v == fish then
            table.remove(self.hookInventory, i)
            print("Item removed from hook:", fish)
            return
        end
    end
    print("Item not found in hook:", item)
end
function PlayerManager:draw()
    -- Draw player
    gfx.drawRect(self.playerPosition.x, self.playerPosition.y, 20, 20)
    -- Draw hook
    gfx.drawRect(self.hookPosition.x, self.hookPosition.y, 5, 25)
    -- draw fishing line
    gfx.drawLine(self.playerPosition.x + 10, self.playerPosition.y + 20, self.hookPosition.x + 2.5, self.hookPosition.y)
end

function PlayerManager:drawInventory()
    -- Draw inventory items
    for i, fish in ipairs(self.hookInventory) do
        gfx.drawText(fish, 10, 10 + (i - 1) * 10)
    end
end
function PlayerManager:update()
    if StateManager.currentState == "idle" then
        if pd.buttonIsPressed(pd.kButtonA) then
            StateManager:setState("casting")
            print("Casting hook...")
        end
    elseif StateManager.currentState == "casting" then
        self:handleInput()
    end
end
function PlayerManager:handleInput()
    -- Handle player input for movement and actions
    if pd.buttonIsPressed(pd.kButtonUp) then
        self:moveHook(self.hookPosition.x, self.hookPosition.y - 1)
    elseif pd.buttonIsPressed(pd.kButtonDown) then
        self:moveHook(self.hookPosition.x, self.hookPosition.y + 1)
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self:moveHook(self.hookPosition.x - 1, self.hookPosition.y)
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self:moveHook(self.hookPosition.x + 1, self.hookPosition.y)
    end
end
function PlayerManager:reset()
    -- Reset player state and position
    self.playerState = "idle"
    self.playerPosition = { x = 0, y = 0 }
    self.playerInventory = {}
    print("Player reset to initial state.")
end
-- function PlayerManager:saveState()
--     -- Save player state to a file or database
--     local state = {
--         playerState = self.playerState,
--         playerPosition = self.playerPosition,
--         playerInventory = self.playerInventory
--     }
--     -- Save logic goes here
--     print("Player state saved.")
-- end
-- function PlayerManager:loadState()
--     -- Load player state from a file or database
--     -- Load logic goes here
--     print("Player state loaded.")
-- end