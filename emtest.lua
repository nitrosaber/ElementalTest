repeat task.wait() until game:IsLoaded()
getgenv().autofarm = true

AttackRange = 55
Instakill = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = ReplicatedStorage:WaitForChild("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services")
local PartyService = Services:WaitForChild("PartyService")
local GetPartyFromPlayer = PartyService:WaitForChild("RF"):WaitForChild("GetPartyFromPlayer")
local VoteOn = PartyService:WaitForChild("RF"):WaitForChild("VoteOn")
local StartDungeon = Services:WaitForChild("DungeonService"):WaitForChild("RF"):WaitForChild("StartDungeon")
function getCurrentMap()
    local mapsFolder = workspace.Map
    if mapsFolder then
        for _, map in ipairs(mapsFolder:GetChildren()) do
            if map:IsA("Folder") and map:FindFirstChild("PlayerSpawns") then
                return map
            end
        end
    end
    return nil
end
function getSpawnCFrame()
    local currentMap = getCurrentMap()
    if currentMap then
        local spawnLocation = currentMap:FindFirstChild("PlayerSpawns") and currentMap.PlayerSpawns[0] and currentMap.PlayerSpawns[0].Part and currentMap.PlayerSpawns[0].Part.SpawnLocation
        if spawnLocation and spawnLocation:IsA("BasePart") then
            return spawnLocation.CFrame
        end
    end
    return nil
end
local swordArgs = {
    [1] = {
        ["Direction"] = nil,
        ["Position"] = nil,
        ["Origin"] = nil
    }
}
local RunService = game:GetService("RunService")
local lastDestroyTime = 0
local destroyInterval = 5  
 
RunService.RenderStepped:Connect(destroyIceIllusionMobs)
function createDungeon(name, difficulty, join, hardcore)
    CreateParty:InvokeServer(name, difficulty, join, not hardcore and "Normal")
    StartParty:InvokeServer(GetPartyFromPlayer:InvokeServer(LocalPlayer)['Data']['UUID'])
end
function createDungeon(name, difficulty, join, hardcore)
    CreateParty:InvokeServer(name, difficulty, join, not hardcore and "Normal")
    StartParty:InvokeServer(GetPartyFromPlayer:InvokeServer(LocalPlayer)['Data']['UUID'])
end
function retry()
    VoteOn:InvokeServer("Retry")
end
function goNext()
    VoteOn:InvokeServer("Next")
end
if game.PlaceId == 10515146389 then
    createDungeon("SnowCastle", "Hell", "All", "Normal")
end
function startDungeon()
    StartDungeon:InvokeServer()
end
function getAliveMobs()
    local mobs = {}
 
    for _,v in next, workspace.Mobs:GetChildren() do
        if v:FindFirstChild("Humanoid") and v.PrimaryPart and v.Humanoid.Health > 0 then
            table.insert(mobs, v)
        end
    end
    return mobs
end

function swing()
    UseSword:InvokeServer()
end

local currentTarget = nil
function chooseNewTarget()
    local spawnCFrame = getSpawnCFrame()
    if not spawnCFrame then
        return
    end
    startDungeon()
    local mobs = getAliveMobs()
    for _, mob in ipairs(mobs) do
        if mob:FindFirstChild("Humanoid") then
            local mobCFrame = mob.PrimaryPart.CFrame
            if mobCFrame.Y >= spawnCFrame.Y - 30 then
                currentTarget = mob
                return
            end
        end
    end
    currentTarget = nil
end
local function destroyIceIllusionMobs()
    while true do
       
        local currentTime = tick()
        if workspace.Mobs:FindFirstChild("[Lv. 85] Ice Illusion") then
            local timeSinceLastDestroy = currentTime - lastDestroyTime
            if timeSinceLastDestroy >= destroyInterval then
                workspace.Mobs["[Lv. 85] Ice Illusion"]:Destroy()
                lastDestroyTime = currentTime
            end
        end
        wait(1)  --  control the frequency of checks
    end
end
function teleportBehindMob(mob)
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and mob.PrimaryPart and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                    if workspace.Mobs:FindFirstChild("[Lv. 75] Ice Illusion") then
            workspace.Mobs["[Lv. 75] Ice Illusion"]:Destroy() 
        
        end
 if workspace.Mobs:FindFirstChild("[Lv. 85] Ice Illusion") then
            workspace.Mobs["[Lv. 85] Ice Illusion"]:Destroy() 
        
        end
        if workspace.Mobs:FindFirstChild("[Lv. 95] Ice Illusion") then
            workspace.Mobs["[Lv. 95] Ice Illusion"]:Destroy()
        end
        local mobCFrame = mob.PrimaryPart.CFrame
        local targetPosition = mobCFrame.p - mobCFrame.lookVector * 9
        LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
    end
end
function attackMob(mob)
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and mob.PrimaryPart and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
        local oldHealth = mob.Humanoid.Health
        repeat
            if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then
                break
            end
            
            local mobCFrame = mob.PrimaryPart.CFrame
            
            -- Calculate the direction vector towards the target mob
            local direction = (mobCFrame.p - LocalPlayer.Character.PrimaryPart.Position).unit
            
            -- Teleport behind the mob
            teleportBehindMob(mob)
            
            -- Make the player face the direction of the mob
            LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(LocalPlayer.Character.PrimaryPart.Position, mobCFrame.p))
            
            game:GetService("ReplicatedStorage").ReplicatedStorage.Packages.Knit.Services.WeaponService.RF.UseSword:InvokeServer()
            
            task.wait()
            
        until mob.Humanoid.Health ~= oldHealth or #mob.Humanoid:GetPlayingAnimationTracks() > 1
    end
end
function pickupShit()
    for _,v in next, workspace.Camera.Drops:GetChildren() do
        if v:FindFirstChild("Center") and v.Center:FindFirstChild("ProximityPrompt") then
            fireproximityprompt(v.Center.ProximityPrompt)
            print()
        end
    end 
end
function dogeAttacks(targetPosition, obstacles)
    for pos1 = 1,100 do
        for neg1 = -1, 1, 3 do
            for pos2 = 1,100 do
                for neg2 = -1, 1, 3 do 
                    local randomOffset = Vector3.new(pos1 * neg1, 0, pos2 * neg2)
                    local newPosition = targetPosition + randomOffset

                    if isPositionClear(newPosition, obstacles) then
                        return newPosition
                    end
                end
            end
        end
    end
    
    return nil
end

function updateTarget()
    while getgenv().autofarm do
        if not currentTarget or (currentTarget and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health <= 0) then
            wait()  
             if workspace.Mobs:FindFirstChild("[Lv. 75] Ice Illusion") then
            workspace.Mobs["[Lv. 75] Ice Illusion"]:Destroy() 
        
        end
 if workspace.Mobs:FindFirstChild("[Lv. 85] Ice Illusion") then
            workspace.Mobs["[Lv. 85] Ice Illusion"]:Destroy() 
        
        end
        if workspace.Mobs:FindFirstChild("[Lv. 95] Ice Illusion") then
            workspace.Mobs["[Lv. 95] Ice Illusion"]:Destroy()
        end
            chooseNewTarget()
        end
        if currentTarget then
            attackMob(currentTarget)
        end
         if game:GetService("Players").LocalPlayer.PlayerGui.DungeonComplete.Main.Visible then
       
        retry()
    end
        
        wait()
    end
end
task.spawn(updateTarget)
