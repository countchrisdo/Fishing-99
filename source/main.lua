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
import "managers/saveManager"

import "data/CONSTS"

function LoadToMenu()
    print("Running: LoadToMenu() in main.lua")
    StateManager:setState("main menu")
    CameraManager:initialize()
    UIManager:initialize()
    MainMenu:initialize()
    -- UIManager:displayNotification("Welcome to my Game!", 2000)
end

function LoadToGame()
    print("Running: LoadToGame() in main.lua")
    gfx.sprite.removeAll()
    gfx.clear()

    StateManager:setState("idle")
    FishDex:initialize()
    FishManager:initialize()
    PlayerManager:initialize()
    PlayerManager:loadState()
    CameraManager:initialize()
    UIManager:initialize()
    ShoppingMenu:initialize()
    SoundManager:initialize()
end

-- Todo: Fix that discovered fish are not saved

LoadToMenu()
-- LoadToGame()

-- not playing yet to test sfx, remember to renable BGMswitch too
SoundManager:playBGM()

function pd.gameWillTerminate()
    PlayerManager:saveState()
    SaveManager:saveUpgradeLevels()
    SaveManager:saveFishData()
end

function pd.gameWillPause()
    PlayerManager:saveState()
    SaveManager:saveUpgradeLevels()
    SaveManager:saveFishData()
end

-- Load player state on game start
PlayerManager:loadState()
SaveManager:loadUpgradeLevels()
SaveManager:loadFishData()

-- One day you need to clean up this mess of an update loop
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
-- To use this type: msg <command>
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
    elseif message == "test" then
        --Insert whatever I'm testing here
        print("Testing...")
        -- WorldManager:testTimeOfDayLogic()
    elseif message == "delete" then
        SaveManager:deleteAllSaves()
        print("Save cleared.")
        print("Game saved.")
    elseif message == "win" then
        UIManager:displayNotification("You've caught all fish!")
        print("You win!")
    else
        print("Unknown Command")
    end
end