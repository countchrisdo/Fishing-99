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

Upgrades = {}

ShoppingMenu = {
    state = "active", --active right now for testing
    states = { "inactive", "active"},
}

function ShoppingMenu:initialize()
    -- test if I can make gridview a local variable
    self.gridview = pd.ui.gridview.new(32,32)
    self.gridview:setNumberOfColumns(8)
    self.gridview:setNumberOfRows(2, 5, 3) -- 3 different sections of row
    self.gridview:setCellPadding(2, 2, 2, 2)

    self.gridview.backgroundImage = UIManager.gridBackground
    self.gridview:setContentInset(4, 4, 4, 4)

    self.gridview:setSectionHeaderHeight(24)
    

    self.gridviewSprite = gfx.sprite.new()
    self.gridviewSprite:setCenter(0, 0)
    self.gridviewSprite:moveTo(100, 70)
    self.gridviewSprite:add()

    function self.gridview:drawSectionHeader(section, x, y, width, height)
        local fontHeight = gfx.getSystemFont():getHeight()
        gfx.drawTextAligned("Section " .. section .. "*", x + width/2, y + (height/2 - fontHeight/2) + 2, kTextAlignment.center)
    end

    function self.gridview:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.fillCircleInRect(x, y, width, height)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.drawCircleInRect(x, y, width, height)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        local cellText = tostring(row) .. ", " .. tostring(column)
        local fontHeight = gfx.getSystemFont():getHeight()
        gfx.drawTextInRect(cellText, x, y + (height/2 - fontHeight/2) + 2, width, height, nil, nil, kTextAlignment.center)
    end
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
    elseif pd.buttonJustPressed(playdate.kButtonLeft) then
        self.gridview:selectPreviousColumn(true)
    elseif pd.buttonJustPressed(playdate.kButtonRight) then
        self.gridview:selectNextColumn(true)
    end

    local gridviewImage = gfx.image.new(200,100)
    gfx.pushContext(gridviewImage)
        self.gridview:drawInRect(0, 0, 200, 100)
    gfx.popContext()
    self.gridviewSprite:setImage(gridviewImage)
    self.gridviewSprite:setZIndex(Z_INDEX.UI + 10)

    local spritelist = gfx.sprite.getAllSprites()
end

function ShoppingMenu:show()
-- add the shopping menu to the drawlist

end

function ShoppingMenu:hide()
-- remove the shopping menu from the drawlist
end