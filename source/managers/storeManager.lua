-- Contains: UIManager{}, MainMenu{}
local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/timer"
import "CoreLibs/sprites"
import "CoreLibs/UI"
import"CoreLibs/nineslice"

StoreManager = {

}

Upgrades = {Rod = {}, Bait = {}, Lure = {}, Line = {}, Boat = {}}

ShoppingMenu = {
    state = "inactive", --active right now for testing
    states = { "inactive", "active"},
}

function ShoppingMenu:initialize()
    print("Gridview initialized")
    self.gridview = pd.ui.gridview.new(0, 32)
    self.upgradeKeys = {} -- Create a list of keys from the Upgrades table
    for key in pairs(Upgrades) do
        table.insert(self.upgradeKeys, key)
    end

    local upgradesCount = #self.upgradeKeys
    self.gridview:setNumberOfRows(upgradesCount)
    print("Gridview rows: " .. upgradesCount)
    self.gridview:setCellPadding(2, 2, 2, 2)

    self.gridview.backgroundImage = UIManager.gridBackground
    self.gridview:setContentInset(5, 5, 5, 5)

    -- self.gridview:setSectionHeaderHeight(24)

    self.gridviewSprite = gfx.sprite.new()
    self.gridviewSprite:setCenter(0, 0)
    self.gridviewSprite:moveTo(100, 70)
    self.gridviewSprite:add()

    -- function self.gridview:drawSectionHeader(section, x, y, width, height)
    --     local fontHeight = gfx.getSystemFont():getHeight()
    --     gfx.drawTextAligned("Section " .. section .. "*", x + width/2, y + (height/2 - fontHeight/2) + 2, kTextAlignment.center)
    -- end

    function self.gridview:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end

        local key = ShoppingMenu.upgradeKeys[row] -- Map the row to the corresponding key
        local upgradeName = key or "Unknown" -- Fallback in case of an invalid row
        local fontHeight = gfx.getSystemFont():getHeight()
        gfx.drawTextInRect(upgradeName, x, y + (height / 2 - fontHeight / 2) + 2, width, height, nil, nil, kTextAlignment.center)
        print("Drawing cell: " .. row .. " " .. column)
        print("Selected: " .. tostring(selected))
        print("Named " .. upgradeName)
    end

    self.state = "inactive"
end

function ShoppingMenu:update()
    if self.state == "inactive" then
        return
    end
    -- Gridview needs pd.timer.updateTimers() to work 
    -- But it is called in WorldManager:update()

    -- Traverse the gridview
    if pd.buttonJustPressed(playdate.kButtonUp) then
        self.gridview:selectPreviousRow(true)
    elseif pd.buttonJustPressed(playdate.kButtonDown) then
        self.gridview:selectNextRow(true)
    end

    -- Exit the menu
    if pd.buttonJustPressed(playdate.kButtonB) then
        print("B pressed: Exiting shopping menu")
        self:hide()
        StateManager:setState("idle")
    end

    local gridviewImage = gfx.image.new(200,100)
    gfx.pushContext(gridviewImage)
        self.gridview:drawInRect(0, 0, 200, 100)
    gfx.popContext()
    self.gridviewSprite:setImage(gridviewImage)
end

function ShoppingMenu:show()
    print("Showing shopping menu")
    self.state = "active"
    self.gridviewSprite:add()
end

function ShoppingMenu:hide()
    print("Hiding shopping menu")
    self.state = "inactive"
    self.gridviewSprite:remove()
end

function CountTableKeys(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end