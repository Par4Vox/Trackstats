-- Get the local player's name
local playerName = game:GetService("Players").LocalPlayer.Name

-- Fetch the cell number based on the player's name
local PlayerCell = getgenv().AccountNames[playerName] + 1

local request = request or httprequest or http_request
local HttpService = cloneref(game:GetService("HttpService"))
local web = "https://script.google.com"
local execid = "AKfycbzjzFVt-C2Bj4ohhdHsQ9s1IXas-my-qW0VQk3rxW3k1L-1neEiHVeeo0u8N3w-iG2K/exec"
local updateUrl = web .. "/macros/s/" .. execid

local Player = game:GetService("Players").LocalPlayer
-- Function to update Google Sheet
local function updateGoogleSheet(cell, value)
    local success, response =
        pcall(
        function()
            return request(
                {
                    Url = updateUrl,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/x-www-form-urlencoded"
                    },
                    Body = "cell=" .. HttpService:UrlEncode(cell) .. "&value=" .. HttpService:UrlEncode(value)
                }
            )
        end
    )
end

local Cell = tostring(PlayerCell)
local timer = 0

local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%02d:%02d", minutes, remainingSeconds)
end

local timer = 0 -- Initialize the timer variable
local updateInterval = 60 -- Update interval in seconds
local lastUpdateTime = tick() -- Get the current time in seconds since the epoch

local function StartTimer()
    while true do
        timer = timer + 1
        local currentTime = tick()
        
        -- Check if it's time to update the Google Sheet
        if currentTime - lastUpdateTime >= updateInterval then
            lastUpdateTime = currentTime -- Update the last update time
            updateGoogleSheet("E" .. Cell, formatTime(timer)) -- Update timer cell
        end
            
        wait(1) -- Wait for 1 second before the next increment
    end
end


local function SendUserInfo()
    updateGoogleSheet("A" .. Cell, Player.Name) -- Name
    updateGoogleSheet("B" .. Cell, Player.UserId) -- User Id
    updateGoogleSheet("F" .. Cell, game.PlaceId) -- PlaceId
end

-- Function to handle PlaceId-specific logic
local function checkPlaceId()
    if game.PlaceId == 11424731604 then
        local Timers = Player.PlayerGui.ImpelDownUI.Info.Timers
        updateGoogleSheet("C" .. Cell, "Waiting For Game to Start")

        Timers.ChildAdded:Connect(
            function(child)
                if child:FindFirstChild("Inner") then
                    task.wait(3)
                    local floorText = child:FindFirstChild("Inner").Floor.Text
                    updateGoogleSheet("C" .. Cell, floorText) -- Update Google Sheet Cell C with floorText
                end
            end
        )
    else
        updateGoogleSheet("C" .. Cell, "Not in Impel") -- Update Cell C when not in Impel
    end
end

local function Mode()
    if game.PlaceId == 11424731604 then
        updateGoogleSheet("D" .. Cell, "Waiting For Mode")
        game:GetService("Players").LocalPlayer.leaderstats.Lives.Changed:Connect(function()
            local Lives = game:GetService("Players").LocalPlayer.leaderstats.Lives

            if Lives.Value == 2 then
                updateGoogleSheet("D" .. Cell, "Nightmare+") -- Update Cell C when not in Impel
            else
                updateGoogleSheet("D" .. Cell, "Normal") -- Update Cell C when not in Impel
            end
        end)
        


    elseif game.PlaceId == 1730877806 then
        updateGoogleSheet("D" .. Cell, "Main Menu") -- Update Cell C when not in Impel
    elseif game.PlaceId == 7465136166 then
        updateGoogleSheet("D" .. Cell, "Main Game") -- Update Cell C when not in Impel
    end
end

-- Start the timer in a separate coroutine
coroutine.wrap(StartTimer)()

-- Example usage:
SendUserInfo()
Mode()
checkPlaceId() -- Check PlaceId and update the sheet
