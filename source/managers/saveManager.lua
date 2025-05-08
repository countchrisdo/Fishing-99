local pd <const> = playdate

SaveManager = {}

-- Save player data
function SaveManager:savePlayerData(playerData)
    local success, errorMessage = pd.datastore.write(playerData, "save", true)
    if success then
        print("Player data saved successfully.")
    else
        print("Error saving player data:", errorMessage)
    end
end

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