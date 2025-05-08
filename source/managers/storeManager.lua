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

-- Upgrades
-- line length, line speed, hook capacity, boat size, 
Upgrades = {
    lineLength = {
        id = "lineLength",
        name = "Line Length",
        description = "Fish deeper waters.",
        level = 0,
        maxLevel = 5,
        costFunction = function(level) return 100 + level * 150 end,
        apply = function(player)
            player.depthMax = player.baseDepthMax + (player.upgradeLvl.depthMax * 100)
        end
    },
    hookCapacity = {
        id = "hookCapacity",
        name = "Hook Capacity",
        description = "Catch more fish per cast.",
        level = 0,
        maxLevel = 10,
        costFunction = function(level) return 50 + level * 50 end,
        apply = function(player)
            -- Debugging: Print current upgrade level
            print("Applying hook capacity upgrade")
            print("PlayerManager.upgradeLvl.hookCapacity: " .. tostring(PlayerManager.upgradeLvl.hookCapacity))

            -- Ensure the most up-to-date value is used
            local upgradeLevel = PlayerManager.upgradeLvl.hookCapacity or 0
            print("Upgrade level being applied: " .. upgradeLevel)

            -- Calculate new hook capacity
            player.hookInventorymax = player.baseHookInventorymax + upgradeLevel
            print("New hook capacity: " .. player.hookInventorymax)
            print("Calculated by Base " .. player.baseHookInventorymax .. " + upgradeLvl " .. upgradeLevel)
        end
    },
    baitQuality = {
        id = "baitQuality",
        name = "Bait Quality",
        description = "Better bait for better fish.",
        level = 0,
        maxLevel = 5,
        costFunction = function(level) return 150 + level * 175 end,
        apply = function(player)
            print("Applying bait quality upgrade")
            print("Current bait quality: " .. player.baitQuality)
            player.baitQuality = player.baitQuality + (player.upgradeLvl.baitQuality * 0.5)
            print("New bait quality: " .. player.baitQuality)
        end
    }
}

ShoppingMenu = {
    state = "inactive", --active right now for testing
    states = { "inactive", "active"},
}

function ShoppingMenu:initialize()
    print("Gridview initialized")

    self.spriteBG = gfx.sprite.new(UIManager.BgImg2)
    self.spriteBG:moveTo(MaxWidth / 2, MaxHeight / 2)
    self.spriteBG:setZIndex(Z_INDEX.UI - 1)

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
    self.gridview:setSectionHeaderHeight(24)

    self.gridviewSprite = gfx.sprite.new()
    self.gridviewSprite:setCenter(0, 0)
    self.gridviewSprite:moveTo(100, 16)

    -- Pre-render the gridview image
    local gridviewImage = gfx.image.new(200, 200)
    gfx.pushContext(gridviewImage)
        self.gridview:drawInRect(0, 0, 200, 200)
    gfx.popContext()
    self.gridviewSprite:setImage(gridviewImage)

    -- self.spriteBG:add()
    -- self.gridviewSprite:add()

    function self.gridview:drawSectionHeader(section, x, y, width, height)
        local fontHeight = gfx.getSystemFont():getHeight()
        gfx.drawTextAligned("FishDex", x + width / 2, y + (height / 2 - fontHeight / 2) + 2, kTextAlignment.center)
    end

    function self.gridview:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end

        local key = ShoppingMenu.upgradeKeys[row]
        local upgradeName = Upgrades[key].name
        local upgradeLvl = Upgrades[key].level
        local upgradeCost = Upgrades[key].costFunction(upgradeLvl)

        local fontHeight = gfx.getSystemFont():getHeight()
        gfx.drawTextInRect(upgradeName .. " : " .. upgradeLvl .. " - " .. upgradeCost, x, y + (height / 2 - fontHeight / 2) + 2, width, height, nil, nil, kTextAlignment.center)
    end

    self.spriteBG:remove()
    self.gridviewSprite:remove()
    self.state = "inactive"
end

function ShoppingMenu:update()
    if self.state == "inactive" then
        return
    end

    if PlayerManager.buttonCooldown then
        return -- Ignore input during cooldown
    end

    -- Traverse the gridview
    if pd.buttonJustPressed(playdate.kButtonUp) then
        self.gridview:selectPreviousRow(true)
    elseif pd.buttonJustPressed(playdate.kButtonDown) then
        self.gridview:selectNextRow(true)
    end

    -- Exit the menu
    if pd.buttonJustPressed(playdate.kButtonB) then
        PlayerManager.buttonCooldown = pd.timer.new(300, function()
            PlayerManager.buttonCooldown = nil
        end)

        print("B pressed: Exiting shopping menu")
        self:hide()
        StateManager:setState("idle")
    end

    -- Handle "A" button press to level up the selected upgrade
    if pd.buttonJustPressed(playdate.kButtonA) then
        local selectedRow = self.gridview:getSelectedRow()
        local selectedKey = self.upgradeKeys[selectedRow]
        local selectedUpgrade = Upgrades[selectedKey]

        if selectedUpgrade.level < selectedUpgrade.maxLevel then
            local cost = selectedUpgrade.costFunction(selectedUpgrade.level)
            if PlayerManager.pMoney >= cost then
                PlayerManager.pMoney = PlayerManager.pMoney - cost
                selectedUpgrade.level = selectedUpgrade.level + 1
                PlayerManager.upgradeLvl[selectedKey] = selectedUpgrade.level
                print("Upgraded " .. selectedUpgrade.name .. " to level " .. selectedUpgrade.level)
                print("Player upgradeLvl " .. selectedKey .. ": " .. PlayerManager.upgradeLvl[selectedKey])
                PlayerManager:applyUpgrades()
            else
                print("Not enough currency to upgrade " .. selectedUpgrade.name)
            end
        else
            print(selectedUpgrade.name .. " is already at max level")
        end
    end

    local gridviewImage = gfx.image.new(200,200)
    gfx.pushContext(gridviewImage)
        self.gridview:drawInRect(0, 0, 200, 200)
    gfx.popContext()
    self.gridviewSprite:setImage(gridviewImage)
    self.gridviewSprite:setZIndex(Z_INDEX.UI + 1) -- Set the z-index to ensure it appears above other sprites
end

function ShoppingMenu:show()
    print("Showing shopping menu")
    self.state = "active"
    self.spriteBG:add()
    self.gridviewSprite:add()
end

function ShoppingMenu:hide()
    print("Hiding shopping menu")
    self.state = "inactive"
    self.spriteBG:remove()
    self.gridviewSprite:remove()

    PlayerManager.pSprite:add()
    PlayerManager.rSprite:add()
    PlayerManager.bSprite:add()
    PlayerManager.hSprite:add()

    -- Set a cooldown to prevent immediate reopening
    PlayerManager.buttonCooldown = pd.timer.new(300, function()
        PlayerManager.buttonCooldown = nil
    end)
end

function CountTableKeys(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end