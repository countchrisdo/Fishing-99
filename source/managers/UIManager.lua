-- This is the in game UI. The Main Menu and Store Menu are separate..
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
        gfx.drawTextAligned("Cash:"..PlayerManager.pMoney, MaxWidth-16, 50, kTextAlignment.right)
    elseif StateManager:getState() == "shopping" then
        gfx.drawTextAligned("Press A to buy", 16, 30, kTextAlignment.left)
        gfx.drawTextAligned("Press B to cancel", 16, 50, kTextAlignment.left)
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