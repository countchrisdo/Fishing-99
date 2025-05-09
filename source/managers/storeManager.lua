-- Contains: UIManager{}, MainMenu{}
local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/timer"
import "CoreLibs/sprites"
import "CoreLibs/UI"
import"CoreLibs/nineslice"

StoreManager = {}

-- Upgrades: line length, hook capacity, bait quality
-- Ideas: Wallet size, hook speed, hook size
Upgrades = {
    lineLength = {
        id = "lineLength",
        name = "Line Length",
        description = "Fish deeper waters.",
        level = 0,
        maxLevel = 5,
        costFunction = function(level) return 50 + level * 75 end,
        apply = function(player)
            local upgradeLevel = Upgrades.lineLength.level
            print("- depthMax:apply() running upgrade: Upgrade Level" ..upgradeLevel)
            player.depthMax = player.baseDepthMax + (upgradeLevel * 100)
            print("New DepthMax: " .. player.depthMax .. " (Base " .. player.baseDepthMax .. " + Upgrade Level " .. upgradeLevel .. ")")
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
            local upgradeLevel = Upgrades.hookCapacity.level
            print("- hookCapacity:apply running Upgrade Level " ..upgradeLevel)
            player.hookInventorymax = player.baseHookInventorymax + upgradeLevel
            print("New hook capacity: " ..player.hookInventorymax .." (Base " ..player.baseHookInventorymax .." + Upgrade Level " ..upgradeLevel .. ")")
        end
    },
    baitQuality = {
        id = "baitQuality",
        name = "Bait Quality",
        description = "Better bait for better fish.",
        level = 0,
        maxLevel = 5,
        costFunction = function(level) return 50 + level * 100 end,
        apply = function(player)
            print("- baitQuality:apply() Running")
            local upgradeLevel = Upgrades.baitQuality.level
            print("Current bait quality: " .. player.baitQuality)
            player.baitQuality = player.baitQuality + (upgradeLevel * 0.5)
            print("New bait quality: " .. player.baitQuality .. " (Base + Upgrade Level " .. upgradeLevel .. " * 0.5)")
        end
    },
}

ShoppingMenu = {
    state = "inactive",
    states = { "inactive", "active"},
    page = {"shop"},
    pages = {"shop", "fishdex", "options"}
}

function ShoppingMenu:initialize()
    print("Gridviews initializing")

    self.spriteBG = gfx.sprite.new(UIManager.BgImg2)
    self.spriteBG:moveTo(MaxWidth / 2, MaxHeight / 2)
    self.spriteBG:setZIndex(Z_INDEX.UI - 1)

    self.gridviewShop = pd.ui.gridview.new(0, 32)
    self.gridviewDex = pd.ui.gridview.new(0, 32)
    self.upgradeKeys = {} -- Create a list of keys from the Upgrades table
    self.fishDexArr = {} -- Create a list of keys from the FishDex table
    for key in pairs(Upgrades) do
        table.insert(self.upgradeKeys, key)
    end
    print("FishDex keys:")
    for fish in pairs(FishDex.fishList) do
        table.insert(self.fishDexArr, fish)
        print("Fish: " .. fish)
    end

    local upgradesCount = #self.upgradeKeys
    -- local fishDexCount = #self.fishDexArr or 1
    local fishDexCount = 9
    self.gridviewShop:setNumberOfRows(upgradesCount)
    self.gridviewDex:setNumberOfRows(fishDexCount)
    print("GridviewShop rows: " .. upgradesCount)
    print("GridviewDex rows: " .. fishDexCount)
    self.gridviewShop:setCellPadding(2, 2, 2, 2)
    self.gridviewDex:setCellPadding(2, 2, 2, 2)

    self.gridviewShop.backgroundImage = UIManager.gridBackground
    self.gridviewDex.backgroundImage = UIManager.gridBackground
    self.gridviewShop:setContentInset(5, 5, 5, 5)
    self.gridviewDex:setContentInset(5, 5, 5, 5)
    self.gridviewShop:setSectionHeaderHeight(24)
    self.gridviewDex:setSectionHeaderHeight(24)

    self.gridviewShopSprite = gfx.sprite.new()
    self.gridviewDexSprite = gfx.sprite.new()
    self.gridviewShopSprite:setCenter(0, 0)
    self.gridviewDexSprite:setCenter(0, 0)
    self.gridviewShopSprite:moveTo(100, 16)
    self.gridviewDexSprite:moveTo(100, 16)

    -- Pre-render the gridviewShop image
    local gridviewShopImage = gfx.image.new(200, 200)
    gfx.pushContext(gridviewShopImage)
        self.gridviewShop:drawInRect(0, 0, 200, 200)
    gfx.popContext()
    self.gridviewShopSprite:setImage(gridviewShopImage)

    -- Pre-render the gridviewDex image
    local gridviewDexImage = gfx.image.new(200, 200)
    gfx.pushContext(gridviewDexImage)
        self.gridviewDex:drawInRect(0, 0, 200, 200)
    gfx.popContext()
    self.gridviewDexSprite:setImage(gridviewDexImage)

    function self.gridviewShop:drawSectionHeader(section, x, y, width, height)
        local fontHeight = gfx.getSystemFont():getHeight()
        gfx.drawTextAligned("Shop", x + width / 2, y + (height / 2 - fontHeight / 2) + 2, kTextAlignment.center)
    end
    function self.gridviewDex:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        local key = ShoppingMenu.fishDexArr[row]
        local fishName = "not set"
        if not FishDex.fishList[key] then
            print("Fish name not found for key")
            return
        end
        fishName = FishDex.fishList[key].name
        if FishDex.fishList[key].count == nil then
            FishDex.fishList[key].count = 0
        end
        local fishCount = FishDex.fishList[key].count

        local fontHeight = gfx.getSystemFont():getHeight()
        gfx.drawTextInRect(fishName .. " : +" .. fishCount, x, y + (height / 2 - fontHeight / 2) + 2, width, height, nil, nil, kTextAlignment.center)
    end
    function self.gridviewDex:drawSectionHeader(section, x, y, width, height)
        local fontHeight = gfx.getSystemFont():getHeight()
        gfx.drawTextAligned("FishDex", x + width / 2, y + (height / 2 - fontHeight / 2) + 2, kTextAlignment.center)
    end

    function self.gridviewShop:drawCell(section, row, column, selected, x, y, width, height)
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
    self.gridviewShopSprite:remove()
    self.gridviewDexSprite:remove()
    self.state = "inactive"
    self.page = "shop"
end

function ShoppingMenu:update()
-- ShoppingMenu has become the source for multiple menus (pages)
    if self.state == "inactive" then
        return
    end

    -- Logic for any menu page

    if PlayerManager.buttonCooldown then
        return -- Ignore input during cooldown
    end

    -- Traverse the gridview
    if self.page == "shop" then
        if pd.buttonJustPressed(playdate.kButtonUp) then
            self.gridviewShop:selectPreviousRow(true)
        elseif pd.buttonJustPressed(playdate.kButtonDown) then
            self.gridviewShop:selectNextRow(true)
        end
    elseif self.page == "fishdex" then
        if pd.buttonJustPressed(playdate.kButtonUp) then
            self.gridviewDex:selectPreviousRow(true)
        elseif pd.buttonJustPressed(playdate.kButtonDown) then
            self.gridviewDex:selectNextRow(true)
        end
    end

    -- Change Menus
    -- Todo: Make this change the page programatically
    if pd.buttonJustPressed(playdate.kButtonLeft) and self.page == "shop" then
        self.gridviewShopSprite:remove()
        self.gridviewDexSprite:add()
        self.page = "fishdex"
        print("Left pressed: Changing page to fishdex")
    elseif pd.buttonJustPressed(playdate.kButtonRight) and self.page == "shop" then
        self.gridviewShopSprite:remove()
        self.gridviewDexSprite:add()
        self.page = "fishdex"
        print("Right pressed: Changing page to fishdex")
    elseif pd.buttonJustPressed(playdate.kButtonLeft) and self.page == "fishdex" then
        self.gridviewDexSprite:remove()
        self.gridviewShopSprite:add()
        self.page = "shop"
        print("Left pressed: Changing page to shop")
    elseif pd.buttonJustPressed(playdate.kButtonRight) and self.page == "fishdex" then
        self.gridviewDexSprite:remove()
        self.gridviewShopSprite:add()
        self.page = "shop"
        print("Right pressed: Changing page to shop")
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

    if pd.buttonJustPressed(playdate.kButtonA) then
        if self.page == "shop" then
            local selectedRow = self.gridviewShop:getSelectedRow()
            local selectedKey = self.upgradeKeys[selectedRow]

            local selectedUpgrade = Upgrades[selectedKey]
            if selectedUpgrade.level < selectedUpgrade.maxLevel then
                local cost = selectedUpgrade.costFunction(selectedUpgrade.level)
                if PlayerManager.pMoney >= cost then
                    PlayerManager:setMoney(PlayerManager.pMoney - cost)
                    selectedUpgrade.level = selectedUpgrade.level + 1
                    print("--------")
                    print("PURCHASE MADE: ")
                    print("Store setting " .. selectedUpgrade.name .. " to level " .. selectedUpgrade.level)
                    print("--------")
                    PlayerManager:applyUpgrades()
                else
                    print("Not enough currency to upgrade " .. selectedUpgrade.name)
                end
            else
                print(selectedUpgrade.name .. " is already at max level")
            end
        elseif self.page == "fishdex" then
            -- Logic for viewing more information on a fish would go here
                local selectedRow = self.gridviewDex:getSelectedRow()
                -- local selectedKey = self.upgradeKeys[selectedRow]
            return
        end
    end

    if self.page == "shop" then
        local gridviewImage = gfx.image.new(200,200)
        gfx.pushContext(gridviewImage)
            self.gridviewShop:drawInRect(0, 0, 200, 200)
        gfx.popContext()
        self.gridviewShopSprite:setImage(gridviewImage)
        self.gridviewShopSprite:setZIndex(Z_INDEX.UI + 1)
    elseif self.page == "fishdex" then
        local gridviewImage = gfx.image.new(200,200)
        gfx.pushContext(gridviewImage)
            self.gridviewDex:drawInRect(0, 0, 200, 200)
        gfx.popContext()
        self.gridviewDexSprite:setImage(gridviewImage)
        self.gridviewDexSprite:setZIndex(Z_INDEX.UI + 1)
    end
end

function ShoppingMenu:show()
    print("Showing menu")
    self.state = "active"
    -- The default page will be the shop
    self.page = "shop"
    self.spriteBG:add()
    self.gridviewShopSprite:add()
end

function ShoppingMenu:hide()
    print("Hiding menu")
    self.state = "inactive"
    self.spriteBG:remove()
    if self.page == "shop" then
        self.gridviewShopSprite:remove()
    elseif self.page == "fishdex" then
        self.gridviewDexSprite:remove()
    end
    -- Bring back Player Sprites
    PlayerManager.pSprite:add()
    PlayerManager.rSprite:add()
    PlayerManager.bSprite:add()
    PlayerManager.hSprite:add()

    -- Set a cooldown to prevent immediate reopening
    PlayerManager.buttonCooldown = pd.timer.new(300, function()
        PlayerManager.buttonCooldown = nil
    end)
end

function ShoppingMenu:refreshFishDexArr()
    self.fishDexArr = {} -- Reset the array
    for fish in pairs(FishDex.fishList) do
        table.insert(self.fishDexArr, fish)
    end
    self.gridviewDex:setNumberOfRows(#self.fishDexArr) -- Update the gridview row count
end

function CountTableKeys(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end