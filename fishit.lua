-- Key System (auto load key, HWID lock, block script if not valid)
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
local keySaveFile = "flazu_key.txt"
local backendUrl = "http://165.154.203.110:3000/api/validate" -- GANTI jika backend berubah
local savedKey = ""
if pcall(function() return readfile end) and isfile and isfile(keySaveFile) then
    local ok, val = pcall(function() return readfile(keySaveFile) end)
    if ok and val then savedKey = val end
end

local function validateKeyWithBackend(key, hwid)
    local http = game:GetService("HttpService")
    local payload = http:JSONEncode({ key = key, hwid = hwid })
    local headers = { ["Content-Type"] = "application/json" }
    local response
    if syn and syn.request then
        response = syn.request({
            Url = backendUrl,
            Method = "POST",
            Headers = headers,
            Body = payload
        })
    elseif http_request then
        response = http_request({
            Url = backendUrl,
            Method = "POST",
            Headers = headers,
            Body = payload
        })
    elseif request then
        response = request({
            Url = backendUrl,
            Method = "POST",
            Headers = headers,
            Body = payload
        })
    else
        return { valid = false, reason = "Executor tidak support HTTP request!" }
    end
    if response and response.Body then
        local ok, data = pcall(function()
            return http:JSONDecode(response.Body)
        end)
        if ok and data then
            return data
        else
            return { valid = false, reason = "Gagal decode response!" }
        end
    else
        return { valid = false, reason = "Tidak dapat hubungi server!" }
    end
end

if not (savedKey and savedKey ~= "") then
    warn("Key belum ada, silakan login lewat menu utama!")
    return
end

local result = validateKeyWithBackend(savedKey, hwid)
if not result.valid then
    warn("Key/HWID tidak valid: "..tostring(result.reason))
    if pcall(function() return delfile end) then
        pcall(function() delfile(keySaveFile) end)
    end
    return
end

-- Check if the script is running in the correct game
if game.PlaceId ~= 121864768012064 then
    warn("This script is not compatible with this game!")
    return
end

-- Load UI library with fallback
local Library
local success, err = pcall(function()
    Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Rain-Design/Unnamed/main/Library.lua'))()
end)
if not success then
    warn("Gagal load Rain-Design library: " .. err)
    success, err = pcall(function()
        Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/LinoriaLib/Linoria/main/Library.lua'))()
    end)
    if not success then
        error("Gagal load Linoria library: " .. err)
    end
end

Library.Theme = "Dark"
local Flags = Library.Flags

-- Create window with generic name
local Window = Library:Window({
    Text = "Flazu Hub - 2025"
})

-- Ensure GUI doesn't reset on spawn
local screenGui = Window.ScreenGui -- Assuming library exposes this
if screenGui then
    screenGui.ResetOnSpawn = false
end

-- Create tabs
local Tab = Window:Tab({
    Text = "Fishing"
})

local Tab2 = Window:Tab({
    Text = "Teleport"
})

-- Sections
local FishingSection = Tab:Section({
    Text = "Auto Fishing"
})

local skipfish = Tab:Section({
    Text = "Skip Fish (Experimental)"
})
local TeleportSection = Tab2:Section({
    Text = "Teleport Locations"
})

-- Auto Fishing Toggle
FishingSection:Toggle({
    Text = "Auto fishing",
    Callback = function(bool)
        isfishing = bool
        if isfishing then
            task.spawn(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Net = ReplicatedStorage:WaitForChild("Packages", 5)
                if not Net then warn("Network package not found") isfishing = false return end
                Net = Net:WaitForChild("_Index", 5):WaitForChild("sleitnick_net@0.2.0", 5):WaitForChild("net", 5)
                if not Net then warn("Network service not found") isfishing = false return end

                local EquipTool = Net:WaitForChild("RE/EquipToolFromHotbar", 5)
                local ChargeRod = Net:WaitForChild("RF/ChargeFishingRod", 5)
                local RequestMinigame = Net:WaitForChild("RF/RequestFishingMinigameStarted", 5)
                local FishCaught = Net:WaitForChild("RE/FishCaught", 5)
                local FishingCompleted = Net:WaitForChild("RE/FishingCompleted", 5)

                if not (EquipTool and ChargeRod and RequestMinigame and FishCaught and FishingCompleted) then
                    warn("Required network events/functions not found")
                    isfishing = false
                    return
                end 

                local random = Random.new()
                while isfishing and game.Players.LocalPlayer.Character do
                    EquipTool:FireServer(1)
                    task.wait(random:NextNumber(0.5, 1.5))
                    ChargeRod:InvokeServer(1751785710.517113 + random:NextNumber(-0.1, 0.1))
                    task.wait(random:NextNumber(0.5, 1.5))
                    RequestMinigame:InvokeServer(-1.2379989624023438, 0.9904072418386307)
                    task.wait(random:NextNumber(0.5, 1.5))
                    if FishCaught then
                        FishingCompleted:FireServer()
                        task.wait(random:NextNumber(1, 2))
                    end
                end
            end)
        end
    end
})

skipfish:Toggle({
    Text = "Skip Fish (Experimental)",
    Callback = function(bool)
        isSkipFishing = bool
        if isSkipFishing then
            task.spawn(function()
                while isSkipFishing do
                    if FishCaught then
                        local FishCaught = Net:WaitForChild("RE/FishCaught", 5)
                        local FishingCompleted = Net:WaitForChild("RE/FishingCompleted", 5)
                        FishingCompleted:FireServer()
                        task.wait(random:NextNumber(1, 2))
                    end
                end
            end)
        end
    end
})

-- Teleport Buttons
TeleportSection:Button({
    Text = "Coral Reefs",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-3265.80518, 0.941767395, 2224.69531, 0.90632683, 2.78803054e-05, -0.422577471, -0.00738814939, 0.999848187, -0.0157798342, 0.422512859, 0.0174237527, 0.906189442)
            print("Teleport berhasil ke Coral Reefs: -3265.80518, 0.941767395, 2224.69531")
        else
            warn("Gagal teleport: Karakter atau HumanoidRootPart tidak ditemukan")
        end
    end
})

TeleportSection:Button({
    Text = "Crater Island",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(1077.91089, -0.614976883, 5056.82227, 0.173577905, -0.254914165, -0.951256812, -2.23070383e-05, 0.965918303, -0.258847177, 0.984820187, 0.0449513942, 0.167656422)
            print("Teleport berhasil ke Crater Island: 1077.91089, -0.614976883, 5056.82227")
        else
            warn("Gagal teleport: Karakter atau HumanoidRootPart tidak ditemukan")
        end
    end
})

TeleportSection:Button({
    Text = "Esoteric Depth",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(3256.996337890625, -1304.0830078125, 1390.310791015625)
            print("Teleport berhasil ke Esoteric Depth: 3256.996337890625, -1304.0830078125, 1390.310791015625")
        else
            warn("Gagal teleport: Karakter atau HumanoidRootPart tidak ditemukan")
        end
    end
})

TeleportSection:Button({
    Text = "Kohana",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-639.214417, 12.5432739, 607.379395, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            print("Teleport berhasil ke Kohana: -639.214417, 12.5432739, 607.379395")
        else
            warn("Gagal teleport: Karakter atau HumanoidRootPart tidak ditemukan")
        end
    end
})

TeleportSection:Button({
    Text = "Stingray Shores",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-16.0332184, 2.24999952, 2833.85229, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            print("Teleport berhasil ke Stingray Shores: -16.0332184, 2.24999952, 2833.85229")
        else
            warn("Gagal teleport: Karakter atau HumanoidRootPart tidak ditemukan")
        end
    end
})

TeleportSection:Button({
    Text = "Tropical Groves",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-2111.10791, 3.92504883, 3701.39233, 0.95753628, -0, -0.288312793, 0, 1, -0, 0.288312793, 0, 0.95753628)
            print("Teleport berhasil ke Tropical Groves: -2111.10791, 3.92504883, 3701.39233")
        else
            warn("Gagal teleport: Karakter atau HumanoidRootPart tidak ditemukan")
        end
    end
})

TeleportSection:Button({
    Text = "Winter Fest",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(1725.9425, 4.27581787, 3194.69678, -0.422592998, 0, -0.906319618, 0, 1, 0, 0.906319618, 0, -0.422592998)
            print("Teleport berhasil ke Winter Fest: 1725.9425, 4.27581787, 3194.69678")
        else
            warn("Gagal teleport: Karakter atau HumanoidRootPart tidak ditemukan")
        end
    end
})

TeleportSection:Button({
    Text = "Respawn",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(71.0332413, 7.26000023, 2831.04565)
            print("Teleport berhasil ke Respawn: 71.0332413, 7.26000023, 2831.04565")
        else
            warn("Gagal teleport: Karakter atau HumanoidRootPart tidak ditemukan")
        end
    end
})

TeleportSection:Button({
    Text = "Ares Rod",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-2209.74707, 1.37117302, 3705.06396, 0.717944264, -0.106869891, -0.687847972, 1.72108412e-05, 0.988147259, -0.153508976, 0.696100593, 0.110199049, 0.709436536)
            print("Teleport berhasil ke Ares Rod: -2209.74707, 1.37117302, 3705.06396")
        else
            warn("Gagal teleport: Karakter atau HumanoidRootPart tidak ditemukan")
        end
    end
})

-- Select Fishing tab by default
Tab:Select()