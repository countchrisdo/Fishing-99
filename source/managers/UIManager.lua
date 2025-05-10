-- This is the in game UI. The Main Menu and Store Menu are separate..
local pd <const> = playdate
local gfx <const> = playdate.graphics
-- Import Libraries
import "CoreLibs/graphics"
import "CoreLibs/timer"
import "CoreLibs/sprites"
import "CoreLibs/UI"
import "CoreLibs/nineslice"
import "CoreLibs/animation"
-- Import Managers
import "managers/stateManager"
import "managers/playerManager"

UIManager = {
    state = "inactive",
    states = { "inactive", "active"},
    BgImg = gfx.image.new("assets/sprites/menubg"),
    BgImg2 = gfx.image.new("assets/sprites/menubg2"),
    gridBackground = gfx.nineSlice.new("assets/sprites/gridbackground", 7, 7, 18, 18),
}
-- UIManager to handle UI elements and interactions
function UIManager:initialize()
    self.state = "active"
    gfx.setFontFamily(gfx.getFont(gfx.font.kVariantBold))
    print("UIManager initialized")
end

function UIManager:drawUI()
    -- gfx.drawTextAligned("Current State: " .. StateManager:getState(), MaxWidth/2, 16, kTextAlignment.center)

    if StateManager:getState() == "main menu" then
        return
    elseif StateManager:getState() == "idle" then
        gfx.drawTextAligned("Press A to cast", MaxWidth/2, MaxHeight/2, kTextAlignment.center)

        if PlayerManager.pMoney > 0 then
            gfx.drawTextAligned("Press B to shop", MaxWidth/2, MaxHeight/2 + 20, kTextAlignment.center)
        end

        gfx.drawTextAligned("Time: " ..WorldManager.formattedTime, MaxWidth-16, 30, kTextAlignment.right)
        gfx.drawTextAligned("Time of Day: " ..WorldManager.timeOfDay, MaxWidth-16, 10, kTextAlignment.right)
        gfx.drawTextAligned("Cash:"..PlayerManager.pMoney, MaxWidth-16, 50, kTextAlignment.right)
    elseif StateManager:getState() == "shopping" then
        -- gfx.drawTextAligned("Press A to buy", 16, 30, kTextAlignment.left)
        -- gfx.drawTextAligned("Press B to cancel", 16, 50, kTextAlignment.left)
        gfx.drawTextAligned("Cash:"..PlayerManager.pMoney, MaxWidth-16, 50, kTextAlignment.right)
    elseif StateManager:getState() ~= "idle" then
        gfx.drawTextAligned("Time: " ..WorldManager.formattedTime, MaxWidth-16, 30, kTextAlignment.right)

        gfx.drawTextAligned("Depth:"..PlayerManager.depth, MaxWidth-16, 50, kTextAlignment.right)
        gfx.drawTextAligned("Fish caught: " .. #PlayerManager.hookInventory .. "/" .. PlayerManager.hookInventorymax, MaxWidth-16, 70, kTextAlignment.right)
    end
end

function UIManager:textAtFish(message, x, y)
    -- Draws the value of the fish at the given coordinates
    local rndOffset = math.random(0, 16)

    local sprite = gfx.sprite.new()
    local image = gfx.image.new(200, 100)
    gfx.pushContext(image)
    -- Draw a background rectangle
        gfx.drawTextAligned(message, 100, 50, kTextAlignment.center)
    gfx.popContext()
    sprite:setImage(image)
    sprite:moveTo(x+16+rndOffset, y+rndOffset)
    sprite:setZIndex(Z_INDEX.UI)
    sprite:add()

    --remove the text after a delay
    pd.timer.new(500, function()
        sprite:remove()
    end)
end

function UIManager:displayNotification(message)
    -- Display a notification message on the screen
    local geo = playdate.geometry
    local Animator = playdate.graphics.animator

    local startPoint = geo.point.new(-MaxWidth, MaxHeight/2)
    local endPoint = geo.point.new(MaxWidth/2, MaxHeight/2)

    local yOffset = CameraManager.cameraPosition.y
    local notificationSprite = gfx.sprite.new()
    local notificationImage = gfx.image.new(MaxWidth, MaxHeight)

    local line1 = geo.lineSegment.new(startPoint.x, startPoint.y + yOffset, endPoint.x, endPoint.y + yOffset)

    local spriteAnimation = Animator.new(500, line1, pd.easingFunctions.linear)
    -- spriteAnimation.repeatCount = 1

    gfx.pushContext(notificationImage)
        -- Draw a background rectangle
        gfx.setColor(gfx.kColorBlack)
        gfx.drawTextAligned(message, notificationImage.height/2, notificationImage.height/2, kTextAlignment.left)
    gfx.popContext()

    notificationSprite:setImage(notificationImage)
    -- move towards goalY

    notificationSprite:moveTo(startPoint.x, endPoint.y + yOffset)
    notificationSprite:setZIndex(Z_INDEX.UI)
    notificationSprite:add()

    notificationSprite:setAnimator(spriteAnimation)

    -- Remove the sprite after a delay
    pd.timer.new(2000, function()
        -- Move the sprite back off the top of the screen
        notificationSprite:remove()
    end)
end

function UIManager:draw()
    self:drawUI()
end

function UIManager:update()
    -- Update logic for UI elements can go here
    self:draw() --draw is called here to ensure UI is drawn regardless of the cameraPosition
end