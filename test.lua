-- Variables
local games = {
    [7346416636] = {
        premium = "https://raw.githubusercontent.com/Makxuz1/hub_scripts.lua/main/PremP.lua",
        free = "https://raw.githubusercontent.com/Makxuz1/hub_scripts.lua/main/FreeP.lua"
    },
    [7313915417] = ""
}

-- URL de Pastebin que contiene la lista de UserIDs premium
local pastebinURL = "https://pastebin.com/raw/PASTEBIN_ID_HERE"  -- Reemplaza PASTEBIN_ID_HERE con el ID real de tu Pastebin

-- Define the _77ProtectFunction macro
local function _77ProtectFunction(protectedFunctions)
    local originalEnv = getfenv(2)
    local newEnv = {}
    
    for k, v in pairs(originalEnv) do
        newEnv[k] = v
    end
    
    for _, func in ipairs(protectedFunctions) do
        newEnv[func] = function()
            warn("[xyuzx3-HUB] Attempted to call a protected function: " .. func)
        end
    end
    
    setfenv(2, newEnv)
end

-- Function to get the list of premium UserIDs from Pastebin
local function getPremiumUserIDs()
    local success, response = pcall(function()
        return game:HttpGet(pastebinURL)
    end)

    if success and response then
        local userIDs = {}
        for userID in response:gmatch("%d+") do
            table.insert(userIDs, tonumber(userID))
        end
        return userIDs
    else
        warn("[xyuzx3-HUB] Error fetching the list of premium UserIDs from Pastebin.")
        return {}  -- Return an empty table in case of an error.
    end
end

-- Function to calculate the hash of a string
local function calculateHash(content)
    local sha1 = require("sha1")
    return sha1(content)
end

-- Function to get the content of a URL and calculate its hash
local function getURLContentWithHash(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success and response then
        local hash = calculateHash(response)
        return response, hash
    else
        warn("[xyuzx3-HUB] Error fetching content from URL: " .. url)
        return nil, nil
    end
end

-- Function to check the integrity of the script
local function checkIntegrity(url, expectedHash)
    local content, hash = getURLContentWithHash(url)
    if content and hash == expectedHash then
        return true
    else
        warn("[xyuzx3-HUB] Script integrity check failed.")
        return false
    end
end

-- Define expected hashes for premium and free scripts
local expectedPremiumScriptHash = "EXPECTED_HASH_FOR_PREMIUM_SCRIPT"
local expectedFreeScriptHash = "EXPECTED_HASH_FOR_FREE_SCRIPT"

-- Function to get the UserID of the current user in Roblox
local function getUserID()
    local player = game.Players.LocalPlayer
    if player then
        return player.UserId
    end
end

-- Get the UserID of the current user
local userID = getUserID()

-- Get the list of premium UserIDs from Pastebin
local premiumUserIDs = getPremiumUserIDs()

-- Main Code
if _G.xyuzx3 ~= nil then
    error("[xyuzx3-HUB] Already executed previously!")
end

_G.xyuzx3 = true

if _G.credits then
    if userID and table.find(premiumUserIDs, userID) and games[game.PlaceId] ~= nil then
        print("Loading premium version...")
        local scriptURL = games[game.PlaceId].premium

        if checkIntegrity(scriptURL, expectedPremiumScriptHash) then
            local success, scriptCode = pcall(function()
                return game:HttpGet(scriptURL)
            end)
        
            if success and scriptCode then
                local scriptFunction = secureLoadString(scriptCode)
                local success, errorMsg = pcall(scriptFunction)
                if not success then
                    error("[xyuzx3-HUB] Error executing the premium script: " .. errorMsg)
                end
            else
                error("[xyuzx3-HUB] Unable to fetch the premium script from URL: " .. scriptURL)
            end
        end
    elseif games[game.PlaceId] ~= nil then
        print("Loading free version...")
        local scriptURL = games[game.PlaceId].free

        if checkIntegrity(scriptURL, expectedFreeScriptHash) then
            local success, scriptCode = pcall(function()
                return game:HttpGet(scriptURL)
            end)

            if success and scriptCode then
                local scriptFunction = secureLoadString(scriptCode)
                local success, errorMsg = pcall(scriptFunction)
                if not success then
                    error("[xyuzx3-HUB] Error executing the free script: " .. errorMsg)
                end
            else
                error("[xyuzx3-HUB] Unable to fetch the free script from URL: " .. scriptURL)
            end
        end
    elseif not userID or not table.find(premiumUserIDs, userID) then
        print("You are not a premium user. Free features are available.")
    else
        error("[xyuzx3-HUB] Unsupported game.")
    end
else
    error("[xyuzx3-HUB] Script cannot be executed without credits.")
end
