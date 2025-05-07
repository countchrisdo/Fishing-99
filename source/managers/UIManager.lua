-- Contains: UIManager{}, MainMenu{}
local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/timer"
import "CoreLibs/sprites"
import "CoreLibs/UI"
import"CoreLibs/nineslice"

import "managers/stateManager"
import "managers/playerManager"

UIManager = {
    state = "inactive",
    states = { "inactive", "active"},
    BgImg = gfx.image.new("assets/sprites/menubg"),
    gridBackground = gfx.nineSlice.new("assets/sprites/gridbackground", 7, 7, 18, 18),
}
-- UIManager to handle UI elements and interactions
function UIManager:initialize()
    self.state = "active"
    gfx.setFontFamily(gfx.getFont(gfx.font.kVariantBold))
    print("UIManager initialized")
end

MainMenu = {}
function MainMenu:initialize()
    if StateManager:getState() == "main menu" then
        local spriteBG = gfx.sprite.new(UIManager.BgImg)
        local spriteTitle = gfx.sprite.new()
        local spriteButton = gfx.sprite.spriteWithText("Press A to start", MaxWidth, MaxHeight)

        local imageSpriteTitle = gfx.image.new(400, 240)

        -- gfx.setFontFamily(gfx.getFont(gfx.font.kVariantBold))

        -- Draw text on the image
        gfx.pushContext(imageSpriteTitle)
            gfx.drawTextAligned("Main Menu", MaxWidth/2, MaxHeight/2, kTextAlignment.center)
        
        gfx.popContext()

        spriteTitle:setImage(imageSpriteTitle:scaledImage(2))

        spriteBG:moveTo(MaxWidth/2, MaxHeight/2)
        spriteTitle:moveTo(MaxWidth/2, 64)
        spriteButton:moveTo(MaxWidth/2, 170)
        spriteBG:setZIndex(Z_INDEX.UI)
        spriteTitle:setZIndex(Z_INDEX.UI)
        spriteButton:setZIndex(Z_INDEX.UI)

        spriteBG:add()
        spriteTitle:add()
        spriteButton:add()

        print("State = MainMenu")
        print("Main Menu initialized")
    end
end

function MainMenu:update()
    if StateManager:getState() == "main menu" then
        if playdate.buttonJustPressed(playdate.kButtonA) then
            print("A pressed: Starting game from main menu")
            gfx.sprite.removeAll()
            gfx.clear()
            LoadToGame()
        end
    end
end



function UIManager:drawUI()
    -- gfx.drawTextAligned("Current State: " .. StateManager:getState(), MaxWidth/2, 16, kTextAlignment.center)

    if StateManager:getState() == "main menu" then
        return
    elseif StateManager:getState() == "idle" then
        gfx.drawTextAligned("Press A to cast", MaxWidth/2, MaxHeight/2, kTextAlignment.center)
        gfx.drawTextAligned("Time: " ..WorldManager.formattedTime, MaxWidth-16, 30, kTextAlignment.right)
        gfx.drawTextAligned("Cash:"..PlayerManager.pMoney, MaxWidth-16, 50, kTextAlignment.right)
    elseif StateManager:getState() ~= "idle" then
        gfx.drawTextAligned("Time: " ..WorldManager.formattedTime, MaxWidth-16, 30, kTextAlignment.right)
        gfx.drawTextAligned("Depth:"..PlayerManager.depth, MaxWidth-16, 50, kTextAlignment.right)
        gfx.drawTextAligned("Fish caught: " .. #PlayerManager.hookInventory .. "/" .. PlayerManager.hookInventorymax, MaxWidth-16, 70, kTextAlignment.right)
    end
end

function UIManager:draw()
    self:drawUI()
end

function UIManager:update()
    -- Update logic for UI elements can go here
    self:draw() --draw is called here to ensure UI is drawn regardless of the cameraPosition
end