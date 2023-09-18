-- Check if the credits match
if _G.credits == "Made By Xyuxz3" then
    -- Variables
    local games = {
        [7346416636] = {
            premium = "https://raw.githubusercontent.com/Makxuz1/hub_scripts.lua/main/PremP.lua",
            free = "https://raw.githubusercontent.com/Makxuz1/hub_scripts.lua/main/FreeP.lua"
        },
        [7313915417] = ""
    }

    -- URL of Pastebin that contains the list of premium UserIDs
    local pastebinURL = "https://pastebin.com/raw/PASTEBIN_ID_HERE"  -- Replace PASTEBIN_ID_HERE with your actual Pastebin ID

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

    -- Define a secure loadstring function
    local function secureLoadString(scriptCode)
        local success, scriptFunction = pcall(function()
            return loadstring(scriptCode)
        end)

        if success and type(scriptFunction) == "function" then
            return scriptFunction
        else
            error("[xyuzx3-HUB] Error loading the script securely.")
        end
    end

    -- Main Code
    if _G.xyuzx3 ~= nil then
        error("[xyuzx3-HUB] Already executed previously!")
    end

    _G.xyuzx3 = true

    if userID and table.find(premiumUserIDs, userID) and games[game.PlaceId] ~= nil then
        print("Loading premium version...")
        local scriptURL = games[game.PlaceId].premium
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
    elseif games[game.PlaceId] ~= nil then
        print("Loading free version...")
        local scriptURL = games[game.PlaceId].free
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
    elseif not userID or not table.find(premiumUserIDs, userID) then
        print("You are not a premium user. Free features are available.")
    else
        error("[xyuzx3-HUB] Unsupported game.")
    end
end
