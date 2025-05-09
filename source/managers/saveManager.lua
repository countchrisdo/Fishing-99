local pd <const> = playdate
SaveManager = {}
-- TODO: Change player saving and loading function organize playerData inside SaveManager insead of passing it from PlayerManager.

--- SAVING
-- Save player data
function SaveManager:savePlayerData(playerData)
    local success, errorMessage = pd.datastore.write(playerData, "save", true)
    if success then
        print("Player data saved successfully.")
    else
        print("Error saving player data:", errorMessage)
    end
end

-- Save Upgrade Levels
function SaveManager:saveUpgradeLevels()
    local upgradeLevels = {}
    for key, upgrade in pairs(Upgrades) do
        upgradeLevels[key] = upgrade.level
    end

    local success, errorMessage = pd.datastore.write(upgradeLevels, "upgradeLevels", true)
    if success then
        print("Upgrade levels saved successfully.")
    else
        print("Error saving upgrade levels:", errorMessage)
    end
end

--- LOADING
-- Load player data
function SaveManager:loadPlayerData()
    if pd.file.exists("save.json") then
        local data = pd.datastore.read("save")
        if data then
            print("Player data loaded successfully.")
            return data
        else
            print("Error loading player data.")
        end
    else
        print("No save file found.")
    end
    return nil
end

-- Load Upgrade Levels
function SaveManager:loadUpgradeLevels()
    if pd.file.exists("upgradeLevels.json") then
        local upgradeLevels = pd.datastore.read("upgradeLevels")
        if upgradeLevels then
            for key, level in pairs(upgradeLevels) do
                if Upgrades[key] then
                    Upgrades[key].level = level
                end
            end
            print("Upgrade levels loaded successfully.")
        else
            print("Error loading upgrade levels.")
        end
    else
        print("No upgrade levels save file found.")
    end
end

-- Delete all save data
function SaveManager:deleteAllSaves()
    local success, errorMessage = pd.datastore.delete("save")
    if success then
        print("All saves deleted successfully.")
    else
        print("Error deleting saves:", errorMessage)
    end
end
