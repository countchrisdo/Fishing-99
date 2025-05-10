local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/UI"


MainMenu = {}
function MainMenu:initialize()
    if StateManager:getState() == "main menu" then
        local spriteBG = gfx.sprite.new(UIManager.BgImg)
        local spriteTitle = gfx.sprite.new()
        local spriteButton = gfx.sprite.spriteWithText("Press A to start!", MaxWidth, MaxHeight)
        local spriteCredits = gfx.sprite.spriteWithText("_A Game by *CountChrisdo* \n Art by *SeeroftheNight*_", MaxWidth, MaxHeight)
        SoundManager:playSound("open", 1)

        local imageSpriteTitle = gfx.image.new(400, 240)

        -- gfx.setFontFamily(gfx.getFont(gfx.font.kVariantBold))

        -- Draw text on the image
        gfx.pushContext(imageSpriteTitle)
            gfx.drawTextAligned("Fish Fear Me: 99", MaxWidth/2, MaxHeight/2, kTextAlignment.center)
    
        gfx.popContext()

        spriteTitle:setImage(imageSpriteTitle:scaledImage(2))

        spriteBG:moveTo(MaxWidth/2, MaxHeight/2)
        spriteTitle:moveTo(MaxWidth/2, 68)
        spriteButton:moveTo(MaxWidth/2, 116)
        spriteCredits:moveTo(MaxWidth/2, 48)
        spriteBG:setZIndex(Z_INDEX.UI)
        spriteTitle:setZIndex(Z_INDEX.UI)
        spriteButton:setZIndex(Z_INDEX.UI)
        spriteCredits:setZIndex(Z_INDEX.UI)

        spriteBG:add()
        spriteTitle:add()
        spriteButton:add()
        spriteCredits:add()

        print("State = MainMenu")
        print("Main Menu initialized")
    end
end

function MainMenu:update()
    if StateManager:getState() == "main menu" then
        if self.buttonCooldown then
            return -- Ignore input during cooldown
        end

        if playdate.buttonJustPressed(playdate.kButtonA) then
            SoundManager:playSound("select", 1)
            gfx.sprite.removeAll()
            gfx.clear()
            LoadToGame()

            -- Set a cooldown to prevent immediate re-trigger
            self.buttonCooldown = pd.timer.new(300, function()
                self.buttonCooldown = nil
            end)
        end
    end
end