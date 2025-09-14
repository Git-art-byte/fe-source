-- MINIMAL TEST SCRIPT - NO UI, JUST CHAT COMMAND
print("Starting minimal NPC script...")

-- Prevent multiple instances
if _G.minimalnpc then 
    warn("Minimal script already running!")
    return 
end
_G.minimalnpc = true

local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer
local mouse = lp:GetMouse()
local rs = game:GetService("RunService")

local currentnpc
local prefix = "/"

-- Simple partowner function
local function partowner(part)
    return part.ReceiveAge == 0
end

-- Simple isnpc function
local function isnpc(model)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local player = plrs:GetPlayerFromCharacter(model)
    return humanoid and not player
end

-- Simple highlight function
local function simpleLight(npc, color)
    print("Highlighting NPC:", npc.Name, "with color:", tostring(color))
    -- Create temporary highlight
    local highlight = Instance.new("Highlight")
    highlight.Parent = npc
    highlight.OutlineColor = color
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    
    -- Remove after 1 second
    game:GetService("Debris"):AddItem(highlight, 1)
end

-- Mouse click to select NPC (simplified)
mouse.Button1Down:Connect(function()
    if mouse.Target and mouse.Target.Parent then
        local model = mouse.Target.Parent
        
        -- Check if it's an NPC
        if isnpc(model) then
            local part = model:FindFirstChild("HumanoidRootPart")
            if part and not part.Anchored then
                if partowner(part) then
                    currentnpc = model
                    simpleLight(currentnpc, Color3.new(0, 1, 0)) -- Green
                    print("✅ NPC selected:", currentnpc.Name)
                else
                    simpleLight(model, Color3.new(1, 0, 0)) -- Red
                    print("❌ NPC not network owned:", model.Name)
                end
            else
                print("❌ NPC is anchored or no HumanoidRootPart")
            end
        else
            print("ℹ️ Not an NPC:", model.Name)
        end
    end
end)

-- Chat command (simplified)
lp.Chatted:Connect(function(message)
    print("💬 Chat message:", message)
    
    -- Check prefix
    if string.sub(message, 1, #prefix) == prefix then
        local command = string.lower(string.sub(message, #prefix + 1))
        print("🎯 Command detected:", command)
        
        if command == "die" then
            if currentnpc then
                print("💀 Attempting to kill:", currentnpc.Name)
                
                local part = currentnpc:FindFirstChild("HumanoidRootPart")
                if part and partowner(part) then
                    local hum = currentnpc:FindFirstChildOfClass("Humanoid")
                    if hum then
                        -- Kill the NPC (state 15 = dead)
                        hum:ChangeState(15)
                        simpleLight(currentnpc, Color3.new(1, 0, 1)) -- Purple
                        print("✅ NPC killed successfully!")
                    else
                        print("❌ No Humanoid found")
                    end
                else
                    print("❌ Lost network ownership or no part")
                    simpleLight(currentnpc, Color3.new(1, 0, 0)) -- Red
                end
            else
                print("❌ No NPC selected! Click on an NPC first.")
            end
        elseif command == "help" then
            print("📋 Commands:")
            print("  " .. prefix .. "die - Kill selected NPC")
            print("  " .. prefix .. "help - Show this help")
        end
    end
end)

-- Simple simulation radius (less aggressive)
spawn(function()
    while _G.minimalnpc do
        if lp then
            lp.SimulationRadius = 150
        end
        wait(1) -- Only update every second instead of every frame
    end
end)

print("✅ Minimal NPC script loaded!")
print("📋 Usage:")
print("  1. Click on an NPC to select it")
print("  2. Type '" .. prefix .. "die' to kill it")
print("  3. Type '" .. prefix .. "help' for help")
