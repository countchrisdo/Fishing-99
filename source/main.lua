local pd <const> = playdate
local gfx <const> = playdate.graphics

import "managers/stateManager"
import "managers/storeManager"
import "managers/UIManager"
import "managers/mainMenu"
import "managers/playerManager"
import "managers/cameraManager"
import "managers/fishManager"
import "managers/worldManager"
import "managers/soundManager"

import "data/CONSTS"

function LoadToMenu()
    print("Running: LoadToMenu() in main.lua")
    StateManager:setState("main menu")
    CameraManager:initialize()
    UIManager:initialize()
    MainMenu:initialize()
    SoundManager:initialize()
end

function LoadToGame()
    print("Running: LoadToGame() in main.lua")
    gfx.sprite.removeAll()
    gfx.clear()

    StateManager:setState("idle")
    PlayerManager:initialize()
    CameraManager:initialize()
    FishManager:initialize()
    UIManager:initialize()
    ShoppingMenu:initialize()
    SoundManager:initialize()
end

LoadToMenu()
-- LoadToGame()

-- not playing yet to test sfx, remember to renable BGMswitch too
-- SoundManager:playBGM()

-- One day you need to clean up this of an update loop
function pd.update()
    gfx.clear()
    -- gfx.sprite.update()
    WorldManager:update()
    pd.timer.updateTimers()

    PlayerManager:update()
    FishManager:update()
    CameraManager:update()
    UIManager:update()
    MainMenu:update()
    ShoppingMenu:update()
end

-- Communitcation with Console
function pd.serialMessageReceived(message)
    print("Message received:", message)
    if message == "cast" then
        StateManager:setState("casting")
        SoundManager:playSound("cast", 1)
        SoundManager:playSound("reel", 2)
        print("Casting hook...")
    elseif message == "reel" then
        StateManager:setState("reeling")
        SoundManager:playSound("reel", 2)
        print("Reeling in fish...")
    elseif message == "catch" then
        SoundManager:playSound("catch", 1)
        local fish = FishManager:getRandomFish()
        PlayerManager.hookInventory[#PlayerManager.hookInventory + 1] = fish
        print("Fish caught:", fish)
    else
        print("Unknown Command")
    end
end