if not game:IsLoaded() then game.Loaded:Wait() end

if getgenv and getgenv().ParagonRippedUnload then
    pcall(getgenv().ParagonRippedUnload)
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local isRunning = true
local activeConnections = {}
local cleanUpInstances = {}
local originalNamecall = nil
local originalUtilityRaycast = nil

local function hideFromStack(fn)
    if typeof(fn) == "function" and setstackhidden then
        pcall(setstackhidden, fn, true)
    end
end

local autoReinjectScript = [[
    task.spawn(function()
        repeat task.wait(0.5) until game:IsLoaded()
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        repeat task.wait(0.5) until lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        task.wait(1.5)
        local success, err = pcall(function()
            if loadfile then
                local f = loadfile("rivals.luau") or loadfile("Rivals.luau")
                if f then f() end
            end
        end)
    end)
]]

if queue_on_teleport then
    pcall(function() queue_on_teleport(autoReinjectScript) end)
elseif syn and syn.queue_on_teleport then
    pcall(function() syn.queue_on_teleport(autoReinjectScript) end)
end

LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started or state == Enum.TeleportState.InProgress then
        if queue_on_teleport then
            pcall(function() queue_on_teleport(autoReinjectScript) end)
        elseif syn and syn.queue_on_teleport then
            pcall(function() syn.queue_on_teleport(autoReinjectScript) end)
        end
    end
end)

local Config = {

    Aimbot = false,
    TeamCheck = true,
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimbotKeyMode = "Hold",
    AimbotPart = "Closest",
    AimbotSmoothing = 0.28,
    AimbotFOV = 120,
    AimbotFOVCircle = false,
    AimbotVisibleOnly = true,
    AimbotScopeOnly = false,
    AimbotDisableReloading = true,
    ContinuousTargeting = true,
    InstantCameraLock = false,
    TrackThroughWalls = true,
    CorrectLockedShots = true,

    SilentAim = false,
    SilentKey = Enum.KeyCode.C,
    SilentKeyMode = "Always",
    SilentTargetPart = "Head",
    SilentFOV = 242,
    SilentHitChance = 78,
    SilentHeadChance = 59,
    SilentVisibleOnly = true,
    SilentVulnerableOnly = true,
    SilentIgnoreDeflecting = true,
    SilentIgnoreShielded = true,

    Ragebot = false,
    RagebotAutoShoot = false,
    RagebotTargetStrafe = false,
    TargetStrafeRadius = 14,
    TargetStrafeSpeed = 6,
    Autoplay = false,
    AutoplayDistance = 18,
    RagebotTargetPriority = "Distance",
    RagebotWallbang = true,
    AutoRespawn = false,
    AutoQueue = false,
    QueueMode = "1v1",
    AutoVoteMaps = false,
    MapPriority = "Arena, Onyx, Crossroads",
    AutoBanWeapons = false,
    WeaponBanPriority = "Grenade Launcher, Minigun, RPG",
    SecondBanPriority = "Grenade Launcher, Minigun, RPG",
    AutoLoadout = false,
    LoadoutOnlySelected = false,
    EnabledMaps = "Arena, Crossroads",
    AntiAim = false,
    AntiAimMode = "Jitter",
    AntiAimSpeed = 10,
    HackerDetector = false,
    NotifyHackers = true,
    HackerAutoLoad = false,
    HackerProfile = "rage",
    SpeedThreshold = 180,
    SpeedDuration = 0.75,
    ModDetector = false,
    NotifyMods = true,
    MinGroupRank = 200,
    ModUsernames = "name1, name2",
    ModFriendList = "name1, name2",
    AutoPickup = false,
    PickupRadius = 25,

    ESP_Master = false,
    ESP_EnemyOnly = true,
    ESP_Lobby = true,
    ESP_MaxDistance = 500,
    ESP_Boxes = true,
    ESP_Names = true,
    ESP_Distance = true,
    ESP_HealthBar = true,
    ESP_Weapon = true,
    ESP_Tracers = false,
    ESP_Chams = false,
    ESP_Skeleton = true,
    ESP_HeadDot = true,
    ESP_Tripmines = false,
    ESP_FOV = false,
    TargetVisualizer = false,
    TargetVisualizerHUD = false,
    TargetVisualizerPath = true,
    VisualizerArrowSpacing = 10,
    VisualizerArrowSpeed = 14,

    SpeedHack = false,
    SpeedValue = 49,
    FlyHack = false,
    FlySpeed = 50,
    InfiniteJump = false,
    BunnyHop = false,
    Noclip = false,

    NoRecoil = false,
    NoSpread = false,
    FastReload = false,
    RapidFire = false,
    InstantEquip = false,
    AutomaticGuns = false,
    InfiniteAmmo = false,

    UnlockAllSkins = false,
    SelectedCategory = "Primary",
    SelectedWeapon = "Assault Rifle",
    SelectedWrap = "Liquid Gold",
    SelectedCharm = "Dice",
    SelectedFinisher = "Gingerbreadify",
    RainbowGunSkin = false,
    WeaponChams = false,
    CustomViewModelFOV = false,
    ViewModelFOVValue = 70,
    ViewModelXOffset = 0,
    ViewModelYOffset = 0,
    ViewModelZOffset = 0,
    HideViewModel = false,

    Fullbright = false,
    NoFog = false,
    CustomFOV = false,
    FOVValue = 90,
    BulletTracers = false,
    HitSound = "Off",

    ThirdPerson = false,
    ThirdPersonDist = 12,
    Freecam = false,
    FreecamSpeed = 40,

    MenuKey = Enum.KeyCode.RightControl,
    MobileToggle = false,

    AnonymousMode = false,
    AnonymousAlias = "anonymous",
    AnonymousAppearance = "Baby Blue",
    AnonymousShirt = "",
    AnonymousPants = "",
    AnonymousHideAccessories = false
}

local Theme = {
    OuterBorder     = Color3.fromRGB(32, 46, 60),
    BorderPink      = Color3.fromRGB(132, 190, 232),
    BorderPinkDark  = Color3.fromRGB(64, 101, 130),

    WindowBg        = Color3.fromRGB(24, 29, 39),
    WindowBgTop     = Color3.fromRGB(24, 29, 39),
    WindowBgBottom  = Color3.fromRGB(24, 29, 39),
    InnerCanvasBg   = Color3.fromRGB(24, 29, 39),
    HeaderBg        = Color3.fromRGB(20, 25, 34),

    CardBg          = Color3.fromRGB(31, 39, 51),
    CardBgTop       = Color3.fromRGB(31, 39, 51),
    CardBgBottom    = Color3.fromRGB(31, 39, 51),
    BorderDark      = Color3.fromRGB(48, 67, 85),
    BorderCard      = Color3.fromRGB(39, 53, 69),

    AccentPink      = Color3.fromRGB(157, 209, 246),
    AccentPinkLight = Color3.fromRGB(194, 228, 255),
    AccentPinkDark  = Color3.fromRGB(100, 162, 208),
    AccentPinkDim   = Color3.fromRGB(41, 71, 94),

    TextWhite       = Color3.fromRGB(220, 232, 245),
    TextMuted       = Color3.fromRGB(146, 169, 190),
    TextDark        = Color3.fromRGB(105, 131, 155),
    ControlBg       = Color3.fromRGB(38, 53, 70),
    ButtonBg        = Color3.fromRGB(38, 53, 70),
    ButtonHoverBg   = Color3.fromRGB(47, 68, 88),
    ButtonBorder    = Color3.fromRGB(55, 79, 101),
    Red             = Color3.fromRGB(235, 75, 75),
    Yellow          = Color3.fromRGB(245, 195, 65),

    AccentGreen     = Color3.fromRGB(157, 209, 246),
    AccentGreenLight= Color3.fromRGB(194, 228, 255),
    AccentGreenDark = Color3.fromRGB(100, 162, 208),
    AccentGreenDim  = Color3.fromRGB(41, 71, 94)
}

local MainFont = Enum.Font.GothamMedium

local LOBBY_CENTER = Vector3.new(109, -680, 1184)
local function isInLobby()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    return (root.Position - LOBBY_CENTER).Magnitude < 450
end

local function isTeammate(p)
    if not p then return false end
    if p == LocalPlayer then return true end
    if Config.TeamCheck == false then return false end

    local pl = nil
    if typeof(p) == "Instance" then
        if p:IsA("Player") then
            pl = p
        elseif LocalPlayer.Character and (p == LocalPlayer.Character or p:IsDescendantOf(LocalPlayer.Character)) then
            return true
        else
            pl = Players:GetPlayerFromCharacter(p:IsA("Model") and p or p:FindFirstAncestorOfClass("Model"))
        end
    end

    if pl and LocalPlayer.Team and pl.Team and LocalPlayer.Team == pl.Team then
        return true
    end

    if pl then
        local myT = LocalPlayer:GetAttribute("TeamID") or LocalPlayer:GetAttribute("Team")
        local theirT = pl:GetAttribute("TeamID") or pl:GetAttribute("Team")
        if myT ~= nil and theirT ~= nil and myT == theirT then
            return true
        end
    end

    local pChar = pl and pl.Character or (typeof(p) == "Instance" and (p:IsA("Model") and p or p:FindFirstAncestorOfClass("Model")))
    local myChar = LocalPlayer.Character
    if pChar and myChar then
        local myCT = myChar:GetAttribute("TeamID") or myChar:GetAttribute("Team")
        local theirCT = pChar:GetAttribute("TeamID") or pChar:GetAttribute("Team")
        if myCT ~= nil and theirCT ~= nil and myCT == theirCT then
            return true
        end
        if pChar:FindFirstChild("TeammateLabel", true) or pChar:FindFirstChild("AllyLabel", true) then
            return true
        end
    end

    return false
end
hideFromStack(isTeammate)

local function isEnemyPlayer(p)
    if not p or p == LocalPlayer then return false end

    if isInLobby() then
        return Config.ESP_Lobby == true
    end

    if isTeammate(p) then
        return false
    end

    if Config.ESP_EnemyOnly and LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then
        return false
    end

    return true
end
hideFromStack(isEnemyPlayer)

local function getGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local ok, gui = pcall(function() return CoreGui end)
    if ok and gui then return gui end
    return LocalPlayer:WaitForChild("PlayerGui", 5) or LocalPlayer:FindFirstChild("PlayerGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "oregonnscriptsUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = getGuiParent()
table.insert(cleanUpInstances, screenGui)

 
 
local LocalIdentity = {saved = {}, created = {}, labels = {}, textMasks = {}, characterConnections = {}, character = nil, status = "Off — choose a name, then Apply Name & Look."}

function LocalIdentity.alias()
    local value = tostring(Config.AnonymousAlias or "anonymous")
    value = value:gsub("[^%w _%.%-]", ""):gsub("%s+", " "):match("^%s*(.-)%s*$")
    return value ~= "" and value:sub(1, 24) or "anonymous"
end

function LocalIdentity.template(value)
    local text = tostring(value or ""):match("^%s*(.-)%s*$")
    local digits = text:match("^(%d+)$") or text:match("^rbxassetid://(%d+)$")
    if not digits or tonumber(digits) == 0 then return nil end
    return "rbxassetid://" .. digits
end

function LocalIdentity.color()
    return ({["Baby Blue"] = Color3.fromRGB(157, 209, 246), ["Mint Green"] = Color3.fromRGB(164, 231, 199),
        ["Midnight"] = Color3.fromRGB(54, 68, 91)})[Config.AnonymousAppearance]
end

function LocalIdentity.setStatus(text, failed)
    LocalIdentity.status = text
    LocalIdentity.failed = failed == true
    if LocalIdentity.statusLabel and LocalIdentity.statusLabel.Parent then
        LocalIdentity.statusLabel.Text = text
        LocalIdentity.statusLabel.TextColor3 = failed and Theme.Red or Theme.AccentPinkLight
    end
end

function LocalIdentity.set(object, property, value)
    local saved = LocalIdentity.saved[object]
    if not saved then saved = {}; LocalIdentity.saved[object] = saved end
    if saved[property] == nil then saved[property] = object[property] end
    object[property] = value
end

function LocalIdentity.restoreCharacter()
    if LocalIdentity.stopOverheads then LocalIdentity.stopOverheads() end
    for _, object in ipairs(LocalIdentity.created) do pcall(function() object:Destroy() end) end
    table.clear(LocalIdentity.created)
    for object, properties in pairs(LocalIdentity.saved) do
        pcall(function()
            if object.Parent then
                for property, value in pairs(properties) do object[property] = value end
            end
        end)
    end
    table.clear(LocalIdentity.saved)
end
LocalIdentity.restore = LocalIdentity.restoreCharacter

function LocalIdentity.bind(label, format)
    table.insert(LocalIdentity.labels, {label = label, original = label.Text, format = format or "%s"})
end

function LocalIdentity.updateLabels()
    for _, item in ipairs(LocalIdentity.labels) do
        if item.label.Parent then
            item.label.Text = Config.AnonymousMode and string.format(item.format, LocalIdentity.alias()) or item.original
        end
    end
end

function LocalIdentity.restoreTextMasks()
    for object, record in pairs(LocalIdentity.textMasks) do
        if record.connection then record.connection:Disconnect() end
        pcall(function()
            if object.Parent and object.Text == record.masked then object.Text = record.original end
        end)
    end
    table.clear(LocalIdentity.textMasks)
    if LocalIdentity.guiConnection then LocalIdentity.guiConnection:Disconnect(); LocalIdentity.guiConnection = nil end
end

function LocalIdentity.maskGameUI()
    LocalIdentity.restoreTextMasks()
    if not Config.AnonymousMode then return end
    local gui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not gui then return end
    local alias = LocalIdentity.alias()
    local names = {LocalPlayer.Name, LocalPlayer.DisplayName}
    table.sort(names, function(a, b) return #a > #b end)
    local function bind(object)
        if object:IsDescendantOf(screenGui) then return end
        if not (object:IsA("TextLabel") or object:IsA("TextButton")) then return end
        if LocalIdentity.textMasks[object] then return end
        local record = {original = object.Text, masked = nil, writing = false}
        LocalIdentity.textMasks[object] = record
        local function update()
            if record.writing or not isRunning or not Config.AnonymousMode then return end
            local original = object.Text
            if original == record.masked then return end
            local masked = original
            for _, name in ipairs(names) do
                if name ~= "" and name ~= alias then
                    local escaped = name:gsub("([^%w])", "%%%1")
                    masked = masked:gsub("%f[%w_]" .. escaped .. "%f[^%w_]", function() return alias end)
                end
            end
            if masked ~= original then
                record.original, record.masked = original, masked
                record.writing = true
                object.Text = masked
                record.writing = false
            end
        end
        record.connection = object:GetPropertyChangedSignal("Text"):Connect(update)
        update()
    end
    for _, object in ipairs(gui:GetDescendants()) do bind(object) end
    LocalIdentity.guiConnection = gui.DescendantAdded:Connect(bind)
end

 
 
function LocalIdentity.stopOverheads()
    for _, connection in ipairs(LocalIdentity.overheadConnections or {}) do
        connection:Disconnect()
    end
    LocalIdentity.overheadConnections = {}
    for tag, record in pairs(LocalIdentity.overheadTags or {}) do
        for _, connection in ipairs(record.connections) do connection:Disconnect() end
        if record.originalEnabled ~= nil then
            pcall(function() tag.Enabled = record.originalEnabled end)
        end
    end
    LocalIdentity.overheadTags = {}
end

function LocalIdentity.hideOverheads(character)
    LocalIdentity.stopOverheads()
    local function ownTag(tag)
        if tag.Name == "oregonnscriptsLocalName" or tag:GetAttribute("OregonLocalAppearance") then return false end
        if tag:IsDescendantOf(character) then return true end
        local adornee = tag.Adornee
        return adornee ~= nil and (adornee == character or adornee:IsDescendantOf(character))
    end
    local function watch(tag)
        if not tag:IsA("BillboardGui") or LocalIdentity.overheadTags[tag] then return end
        if tag.Name == "oregonnscriptsLocalName" or tag:GetAttribute("OregonLocalAppearance") then return end
        local record = {connections = {}}
        LocalIdentity.overheadTags[tag] = record
        local function update()
            if not isRunning or not Config.AnonymousMode then return end
            if ownTag(tag) then
                if record.originalEnabled == nil then record.originalEnabled = tag.Enabled end
                if tag.Enabled then tag.Enabled = false end
            elseif record.originalEnabled ~= nil then
                 
                local enabled = record.originalEnabled
                record.originalEnabled = nil
                tag.Enabled = enabled
            end
        end
        table.insert(record.connections, tag:GetPropertyChangedSignal("Adornee"):Connect(update))
        table.insert(record.connections, tag:GetPropertyChangedSignal("Enabled"):Connect(update))
        table.insert(record.connections, tag.AncestryChanged:Connect(update))
        table.insert(record.connections, tag.Destroying:Connect(function()
            for _, connection in ipairs(record.connections) do connection:Disconnect() end
            LocalIdentity.overheadTags[tag] = nil
        end))
        update()
    end
    local roots = {Workspace}
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then table.insert(roots, playerGui) end
    if CoreGui then table.insert(roots, CoreGui) end
    for _, root in ipairs(roots) do
         
        pcall(function()
            table.insert(LocalIdentity.overheadConnections, root.DescendantAdded:Connect(watch))
            for _, object in ipairs(root:GetDescendants()) do watch(object) end
        end)
    end
end

function LocalIdentity.refresh()
    if LocalIdentity.applying then return not LocalIdentity.failed, LocalIdentity.status end
    LocalIdentity.applying = true
    LocalIdentity.restoreCharacter()
    LocalIdentity.updateLabels()
    local maskOK, maskError = pcall(LocalIdentity.maskGameUI)
    if not maskOK then warn("[oregonnscripts] Name masking: " .. tostring(maskError)) end
    if not isRunning or not Config.AnonymousMode then
        LocalIdentity.setStatus("Off — original local name and appearance restored.")
        LocalIdentity.applying = false
        return true, LocalIdentity.status
    end
    local character = LocalPlayer.Character or LocalIdentity.character
    if not character or not character.Parent then
        LocalIdentity.setStatus("Waiting for your character to spawn…")
        LocalIdentity.applying = false
        return false, LocalIdentity.status
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        LocalIdentity.setStatus("Waiting for the character Humanoid…")
        LocalIdentity.applying = false
        return false, LocalIdentity.status
    end
    local ok, err = pcall(function()
        LocalIdentity.set(humanoid, "DisplayName", LocalIdentity.alias())
         
         
        LocalIdentity.set(humanoid, "DisplayDistanceType", Enum.HumanoidDisplayDistanceType.None)
        LocalIdentity.set(humanoid, "NameDisplayDistance", 0)
        LocalIdentity.set(humanoid, "HealthDisplayDistance", 0)
        LocalIdentity.hideOverheads(character)
        local color = LocalIdentity.color()
        local changedParts = 0
        for _, object in ipairs(character:GetDescendants()) do
            if color and object:IsA("BasePart") and object.Parent == character and object.Name ~= "HumanoidRootPart" then
                LocalIdentity.set(object, "Color", color)
                LocalIdentity.set(object, "Material", Enum.Material.SmoothPlastic)
                if object:IsA("MeshPart") then LocalIdentity.set(object, "TextureID", "") end
                changedParts = changedParts + 1
            elseif color and object:IsA("BodyColors") then
                for _, property in ipairs({"HeadColor3", "TorsoColor3", "LeftArmColor3", "RightArmColor3", "LeftLegColor3", "RightLegColor3"}) do
                    LocalIdentity.set(object, property, color)
                end
            elseif Config.AnonymousHideAccessories and object:IsA("BasePart") and object:FindFirstAncestorOfClass("Accessory") then
                LocalIdentity.set(object, "Transparency", 1)
            elseif color and object:IsA("ShirtGraphic") then
                LocalIdentity.set(object, "Graphic", "")
            end
        end
         
         
        for _, spec in ipairs({
            {class = "Shirt", property = "ShirtTemplate", value = Config.AnonymousShirt},
            {class = "Pants", property = "PantsTemplate", value = Config.AnonymousPants},
        }) do
            local asset = LocalIdentity.template(spec.value)
            local clothing = character:FindFirstChildOfClass(spec.class)
            if asset and not clothing then
                clothing = Instance.new(spec.class)
                clothing.Name = "oregonnscriptsLocal" .. spec.class
                clothing:SetAttribute("OregonLocalAppearance", true)
                clothing.Parent = character
                table.insert(LocalIdentity.created, clothing)
            end
            if clothing and (asset or color) then LocalIdentity.set(clothing, spec.property, asset or "") end
        end
        local head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
        if head then
            local tag = Instance.new("BillboardGui")
            tag.Name = "oregonnscriptsLocalName"
            tag:SetAttribute("OregonLocalAppearance", true)
            tag.Adornee = head
            tag.Size = UDim2.fromOffset(180, 32)
            tag.StudsOffset = Vector3.new(0, 2.5, 0)
            tag.AlwaysOnTop = true
            tag.MaxDistance = 250
            tag.Parent = screenGui
            table.insert(LocalIdentity.created, tag)
            local label = Instance.new("TextLabel", tag)
            label.Size = UDim2.fromScale(1, 1)
            label.BackgroundColor3 = Theme.HeaderBg
            label.BackgroundTransparency = 0.2
            label.BorderSizePixel = 0
            label.Font = MainFont
            label.Text = LocalIdentity.alias()
            label.TextSize = 14
            label.TextColor3 = Theme.AccentPinkLight
            Instance.new("UICorner", label).CornerRadius = UDim.new(0, 7)
        end
        LocalIdentity.setStatus("Active as " .. LocalIdentity.alias() .. " · " .. tostring(changedParts) .. " body parts updated (local only).")
    end)
    if not ok then
        LocalIdentity.restoreCharacter()
        LocalIdentity.setStatus("Apply failed: " .. tostring(err), true)
        warn("[oregonnscripts] " .. LocalIdentity.status)
    end
    LocalIdentity.applying = false
    return ok, LocalIdentity.status
end

function LocalIdentity.watch(character)
    LocalIdentity.restoreCharacter()
    for _, connection in ipairs(LocalIdentity.characterConnections) do connection:Disconnect() end
    table.clear(LocalIdentity.characterConnections)
    LocalIdentity.character = character
    if character then
        local pending = false
        local connection = character.DescendantAdded:Connect(function(object)
            if object and object:GetAttribute("OregonLocalAppearance") then return end
            if LocalIdentity.applying or pending or not Config.AnonymousMode then return end
            pending = true
            task.defer(function()
                pending = false
                if isRunning and LocalIdentity.character == character then LocalIdentity.refresh() end
            end)
        end)
        table.insert(LocalIdentity.characterConnections, connection)
        table.insert(activeConnections, connection)
    end
    LocalIdentity.refresh()
end

function LocalIdentity.destroy()
    LocalIdentity.restoreCharacter()
    LocalIdentity.restoreTextMasks()
    for _, connection in ipairs(LocalIdentity.characterConnections) do connection:Disconnect() end
    table.clear(LocalIdentity.characterConnections)
    for _, item in ipairs(LocalIdentity.labels) do
        if item.label.Parent then item.label.Text = item.original end
    end
end

table.insert(activeConnections, LocalPlayer.CharacterAdded:Connect(function(character)
    if isRunning then LocalIdentity.watch(character) end
end))
table.insert(activeConnections, LocalPlayer.CharacterAppearanceLoaded:Connect(function(character)
    if isRunning and character == LocalIdentity.character and Config.AnonymousMode then LocalIdentity.refresh() end
end))
LocalIdentity.watch(LocalPlayer.Character)

local function UnloadScript()
    pcall(LocalIdentity.destroy)
    isRunning = false
    for _, conn in ipairs(activeConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(activeConnections)
    for _, inst in ipairs(cleanUpInstances) do pcall(function() inst:Destroy() end) end
    table.clear(cleanUpInstances)
    if originalUtilityRaycast then
        pcall(function()
            local util = require(ReplicatedStorage.Modules.Utility)
            util.Raycast = originalUtilityRaycast
        end)
    end
    pcall(function() ContextActionService:UnbindAction("ParagonMenuFreeze") end)
    pcall(function()
        local ps = LocalPlayer:FindFirstChild("PlayerScripts")
        local pm = ps and ps:FindFirstChild("PlayerModule")
        if pm then
            local controls = require(pm):GetControls()
            if controls then controls:Enable() end
        end
    end)
    pcall(function()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    end)
    if getgenv then getgenv().ParagonRippedUnload = nil end
end

if getgenv then getgenv().ParagonRippedUnload = UnloadScript end

local originalWeaponStats = {}
local function ApplyWeaponModifications()
    if not isRunning then return end
    pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local itemModule = rep:FindFirstChild("Modules") and rep.Modules:FindFirstChild("ItemLibrary")
        if not itemModule then return end
        local itemLib = require(itemModule)
        if itemLib and itemLib.Items then
            for name, item in pairs(itemLib.Items) do
                if type(item) == "table" and item.ShootRecoil ~= nil then
                    if not originalWeaponStats[name] then
                        originalWeaponStats[name] = {
                            ShootRecoil = item.ShootRecoil,
                            ShootSpread = item.ShootSpread,
                            AimSpreadMultiplier = item.AimSpreadMultiplier,
                            ShootSpreadPerVelocityUnit = item.ShootSpreadPerVelocityUnit,
                            ShootSpreadPerVelocityLimit = item.ShootSpreadPerVelocityLimit,
                            EquipCooldown = item.EquipCooldown,
                            ReloadLength = item.ReloadLength,
                            EmptyReloadLength = item.EmptyReloadLength,
                            ReloadActionTimestamp = item.ReloadActionTimestamp,
                            EmptyReloadActionTimestamp = item.EmptyReloadActionTimestamp,
                            ShootCooldown = item.ShootCooldown,
                            MaxAmmo = item.MaxAmmo,
                            MaxAmmoReserve = item.MaxAmmoReserve
                        }
                    end

                    local orig = originalWeaponStats[name]
                    item.ShootRecoil = Config.NoRecoil and 0 or orig.ShootRecoil
                    item.ShootSpread = Config.NoSpread and 0 or orig.ShootSpread
                    item.AimSpreadMultiplier = Config.NoSpread and 0 or orig.AimSpreadMultiplier
                    item.ShootSpreadPerVelocityUnit = Config.NoSpread and 0 or orig.ShootSpreadPerVelocityUnit
                    item.ShootSpreadPerVelocityLimit = Config.NoSpread and 0 or orig.ShootSpreadPerVelocityLimit
                    item.EquipCooldown = Config.InstantEquip and 0.01 or orig.EquipCooldown
                    item.ReloadLength = Config.FastReload and 0.05 or orig.ReloadLength
                    item.EmptyReloadLength = Config.FastReload and 0.05 or orig.EmptyReloadLength
                    item.ReloadActionTimestamp = Config.FastReload and 0.01 or orig.ReloadActionTimestamp
                    item.EmptyReloadActionTimestamp = Config.FastReload and 0.01 or orig.EmptyReloadActionTimestamp
                    item.ShootCooldown = Config.RapidFire and (orig.ShootCooldown * 0.4) or orig.ShootCooldown
                    if orig.MaxAmmo then
                        item.MaxAmmo = Config.InfiniteAmmo and 9999 or orig.MaxAmmo
                    end
                    if orig.MaxAmmoReserve then
                        item.MaxAmmoReserve = Config.InfiniteAmmo and 9999 or orig.MaxAmmoReserve
                    end
                end
            end
        end
    end)
end

local function UnlockAllCosmeticsClientSide()
    pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local pdCtrl = require(LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
        local cosmeticLib = require(rep.Modules.CosmeticLibrary)
        local itemLib = require(rep.Modules.ItemLibrary)

        if pdCtrl and pdCtrl.CurrentData and pdCtrl.CurrentData.Data then
            local cosmInv = pdCtrl.CurrentData.Data.CosmeticInventory or {}
            local rawWeapInv = pdCtrl.CurrentData.Data.WeaponInventory or {}

            if cosmeticLib and cosmeticLib.Cosmetics then
                for name, _ in pairs(cosmeticLib.Cosmetics) do
                    cosmInv[name] = true
                end
            end

            local weapInv = {}
            local existing = {}
            if typeof(rawWeapInv) == "table" then
                for _, item in pairs(rawWeapInv) do
                    if typeof(item) == "table" and item.Name then
                        table.insert(weapInv, item)
                        existing[item.Name] = true
                    end
                end
            end

            if itemLib and itemLib.Items then
                for name, _ in pairs(itemLib.Items) do
                    if not existing[name] then
                        table.insert(weapInv, {
                            Name = name,
                            Level = 100,
                            Prestige = 5,
                            XP = 99999,
                            IsFavorited = false
                        })
                        existing[name] = true
                    end
                end
            end

            pdCtrl.CurrentData.Data.CosmeticInventory = cosmInv
            pdCtrl.CurrentData.Data.WeaponInventory = weapInv
        end
    end)
end

local function ApplySelectedCosmeticsClientSide(weaponName, wrapName, charmName, finisherName)
    pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local pdCtrl = require(LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
        if pdCtrl and pdCtrl.CurrentData and pdCtrl.CurrentData.Data then
            local weapInv = pdCtrl.CurrentData.Data.WeaponInventory
            if typeof(weapInv) == "table" then
                for _, weapon in ipairs(weapInv) do
                    if typeof(weapon) == "table" and (weapon.Name == weaponName or weaponName == "All") then
                        if wrapName and wrapName ~= "Default" and wrapName ~= "None" then
                            weapon.Wrap = { Name = wrapName, Inverted = false }
                        elseif wrapName == "Default" or wrapName == "None" then
                            weapon.Wrap = nil
                        end

                        if charmName and charmName ~= "None" then
                            weapon.Charm = { Name = charmName }
                        elseif charmName == "None" then
                            weapon.Charm = nil
                        end

                        if finisherName and finisherName ~= "None" then
                            weapon.Finisher = { Name = finisherName }
                        elseif finisherName == "None" then
                            weapon.Finisher = nil
                        end
                    end
                end
            end
        end

        local rem = rep:FindFirstChild("Remotes")
        local dataRem = rem and rem:FindFirstChild("Data")
        local equipCosm = dataRem and dataRem:FindFirstChild("EquipCosmetic")
        if equipCosm and weaponName ~= "All" then
            if wrapName and wrapName ~= "Default" and wrapName ~= "None" then
                equipCosm:FireServer(weaponName, "Wrap", wrapName)
            end
            if charmName and charmName ~= "None" then
                equipCosm:FireServer(weaponName, "Charm", charmName)
            end
            if finisherName and finisherName ~= "None" then
                equipCosm:FireServer(weaponName, "Finisher", finisherName)
            end
        end
    end)
end

local dropdownOverlay = Instance.new("Frame")
dropdownOverlay.Name = "DropdownOverlay"
dropdownOverlay.Size = UDim2.new(1, 0, 1, 0)
dropdownOverlay.BackgroundTransparency = 1
dropdownOverlay.ZIndex = 1000
dropdownOverlay.Parent = screenGui
table.insert(cleanUpInstances, dropdownOverlay)

local activeDropdownClose = nil

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if activeDropdownClose then
            activeDropdownClose(input.Position)
        end
    end
end)

local watermarkFrame = Instance.new("Frame")
watermarkFrame.Name = "oregonnscriptsWatermark"
watermarkFrame.Size = UDim2.new(0, 285, 0, 22)
watermarkFrame.Position = UDim2.new(1, -295, 0, 8)
watermarkFrame.BackgroundColor3 = Theme.CardBg
watermarkFrame.BorderSizePixel = 0
watermarkFrame.ZIndex = 90
watermarkFrame.Parent = screenGui
Instance.new("UICorner", watermarkFrame).CornerRadius = UDim.new(0, 5)
table.insert(cleanUpInstances, watermarkFrame)

local wmGrad = Instance.new("UIGradient")
wmGrad.Rotation = 90
wmGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.CardBgTop),
    ColorSequenceKeypoint.new(1, Theme.CardBgBottom)
})
wmGrad.Enabled = false
wmGrad.Parent = watermarkFrame

local wmStroke = Instance.new("UIStroke")
wmStroke.Color = Theme.BorderCard
wmStroke.Thickness = 1
wmStroke.Parent = watermarkFrame

local wmTopLine = Instance.new("Frame")
wmTopLine.Size = UDim2.new(1, 0, 0, 1.5)
wmTopLine.BackgroundColor3 = Theme.AccentPink
wmTopLine.BorderSizePixel = 0
wmTopLine.ZIndex = 91
wmTopLine.Parent = watermarkFrame

local wmLineGrad = Instance.new("UIGradient")
wmLineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.AccentPinkLight),
    ColorSequenceKeypoint.new(1, Theme.AccentPinkDark)
})
wmLineGrad.Parent = wmTopLine

local wmLbl = Instance.new("TextLabel")
wmLbl.Size = UDim2.new(1, -12, 1, -2)
wmLbl.Position = UDim2.new(0, 8, 0, 2)
wmLbl.BackgroundTransparency = 1
wmLbl.Font = MainFont
wmLbl.RichText = true
wmLbl.Text = '<b>OS</b>  |  <font color="#9dd1f6">oregonnscripts</font>  |  60 fps  |  0 ms'
wmLbl.TextColor3 = Theme.TextWhite
wmLbl.TextSize = 10.5
wmLbl.TextXAlignment = Enum.TextXAlignment.Left
wmLbl.ZIndex = 92
wmLbl.Parent = watermarkFrame

local notifContainer = Instance.new("Frame")
notifContainer.Name = "NotifContainer"
notifContainer.Size = UDim2.new(0, 260, 1, -40)
notifContainer.Position = UDim2.new(1, -275, 0, 36)
notifContainer.BackgroundTransparency = 1
notifContainer.ZIndex = 100
notifContainer.Parent = screenGui
table.insert(cleanUpInstances, notifContainer)

local notifLayout = Instance.new("UIListLayout")
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 5)
notifLayout.Parent = notifContainer

local function ShowNotification(title, message, notifType, duration)
    if not isRunning then return end
    pcall(function()
        if not notifContainer or not notifContainer.Parent then return end
        duration = duration or 3.5
        notifType = notifType or "INFO"
        local barColor = Theme.AccentGreen
        if notifType == "SUCCESS" then barColor = Theme.AccentGreenLight
        elseif notifType == "WARN" then barColor = Theme.Yellow
        elseif notifType == "ERROR" then barColor = Theme.Red end

        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 0)
        card.BackgroundColor3 = Theme.CardBg
        card.BorderSizePixel = 0
        card.ClipsDescendants = true
        card.ZIndex = 101
        card.Parent = notifContainer

        local stroke = Instance.new("UIStroke")
        stroke.Color = Theme.BorderDark
        stroke.Thickness = 1
        stroke.Parent = card

        local topAcc = Instance.new("Frame")
        topAcc.Size = UDim2.new(1, 0, 0, 1.5)
        topAcc.BackgroundColor3 = barColor
        topAcc.BorderSizePixel = 0
        topAcc.ZIndex = 102
        topAcc.Parent = card

        local tLbl = Instance.new("TextLabel")
        tLbl.Size = UDim2.new(1, -14, 0, 15)
        tLbl.Position = UDim2.new(0, 8, 0, 3)
        tLbl.BackgroundTransparency = 1
        tLbl.Font = MainFont
        tLbl.Text = title
        tLbl.TextColor3 = Theme.AccentGreen
        tLbl.TextSize = 11.5
        tLbl.TextXAlignment = Enum.TextXAlignment.Left
        tLbl.ZIndex = 102
        tLbl.Parent = card

        local mLbl = Instance.new("TextLabel")
        mLbl.Size = UDim2.new(1, -14, 0, 22)
        mLbl.Position = UDim2.new(0, 8, 0, 18)
        mLbl.BackgroundTransparency = 1
        mLbl.Font = MainFont
        mLbl.Text = message
        mLbl.TextColor3 = Theme.TextWhite
        mLbl.TextSize = 10
        mLbl.TextWrapped = true
        mLbl.TextXAlignment = Enum.TextXAlignment.Left
        mLbl.ZIndex = 102
        mLbl.Parent = card

        TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 46)}):Play()

        task.delay(duration, function()
            if card and card.Parent then
                local tw = TweenService:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
                tw:Play()
                tw.Completed:Connect(function() card:Destroy() end)
            end
        end)
    end)
end

local TargetVis = {
    hudFrame = nil,
    hudTitle = nil,
    hudAvatar = nil,
    hudName = nil,
    hudHpFill = nil,
    visualizerFolder = nil,
    poolLines = {},
    poolChevrons = {},
    cachedWaypoints = {},
    autoplayWpIndex = 1,
    lastAutoplayStuckTime = 0,
    lastAutoplayPos = nil,
    lastTargetUserId = nil,
    activeRoot = nil,
    activeChar = nil,
    activeHum = nil,
    activePlayer = nil,
    cachedEnemies = {},
    lastEnemyUpdateTime = 0,
    targetCache = {},
    staticRayParams = nil,
    lastFullbrightCheck = 0,
    lastNoFogCheck = 0,
    lastPathMyPos = nil,
    lastPathActPos = nil,
}

local function initTargetVisualizer()
    local hud = Instance.new("Frame")
    hud.Name = "TargetHUD"
    hud.Size = UDim2.new(0, 310, 0, 72)
    hud.Position = UDim2.new(0.5, -155, 1, -125)
    hud.BackgroundColor3 = Theme.CardBg
    hud.BorderSizePixel = 0
    hud.Visible = false
    hud.ZIndex = 80
    hud.Parent = screenGui
    table.insert(cleanUpInstances, hud)
    TargetVis.hudFrame = hud

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.BorderPinkDark
    stroke.Thickness = 1.2
    stroke.Parent = hud

    local topLine = Instance.new("Frame")
    topLine.Size = UDim2.new(1, 0, 0, 2.5)
    topLine.BackgroundColor3 = Theme.AccentPink
    topLine.BorderSizePixel = 0
    topLine.ZIndex = 81
    topLine.Parent = hud

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 18)
    title.Position = UDim2.new(0, 10, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = MainFont
    title.Text = "Target  -  150/150"
    title.TextColor3 = Theme.TextWhite
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 82
    title.Parent = hud
    TargetVis.hudTitle = title

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 42, 0, 42)
    avatar.Position = UDim2.new(0, 10, 0, 24)
    avatar.BackgroundColor3 = Theme.ControlBg
    avatar.BorderSizePixel = 0
    avatar.ZIndex = 82
    avatar.Parent = hud
    TargetVis.hudAvatar = avatar

    local avStroke = Instance.new("UIStroke")
    avStroke.Color = Theme.AccentPink
    avStroke.Thickness = 1.2
    avStroke.Parent = avatar

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -68, 0, 18)
    nameLbl.Position = UDim2.new(0, 60, 0, 24)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = MainFont
    nameLbl.Text = "Player (@username)"
    nameLbl.TextColor3 = Theme.TextWhite
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex = 82
    nameLbl.Parent = hud
    TargetVis.hudName = nameLbl

    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(1, -68, 0, 8)
    hpBg.Position = UDim2.new(0, 60, 0, 48)
    hpBg.BackgroundColor3 = Theme.ControlBg
    hpBg.BorderSizePixel = 0
    hpBg.ZIndex = 82
    hpBg.Parent = hud

    local hpCorner = Instance.new("UICorner")
    hpCorner.CornerRadius = UDim.new(0, 2)
    hpCorner.Parent = hpBg

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Theme.AccentPink
    hpFill.BorderSizePixel = 0
    hpFill.ZIndex = 83
    hpFill.Parent = hpBg
    TargetVis.hudHpFill = hpFill

    local hpFillCorner = Instance.new("UICorner")
    hpFillCorner.CornerRadius = UDim.new(0, 2)
    hpFillCorner.Parent = hpFill

    local vFolder = Instance.new("Folder")
    vFolder.Name = "ParagonTargetVisualizer"
    vFolder.Parent = Workspace
    table.insert(cleanUpInstances, vFolder)
    TargetVis.visualizerFolder = vFolder

    for i = 1, 40 do
        local p = Instance.new("Part")
        p.Name = "VisLine_" .. i
        p.Anchored = true
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = false
        p.CastShadow = false
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(195, 255, 30)
        p.Transparency = 1
        p.Size = Vector3.new(0.18, 0.06, 1)
        p.Parent = vFolder
        table.insert(TargetVis.poolLines, p)
    end

    for i = 1, 30 do
        local wingL = Instance.new("Part")
        wingL.Name = "ChevL_" .. i
        wingL.Anchored = true
        wingL.CanCollide = false
        wingL.CanTouch = false
        wingL.CanQuery = false
        wingL.CastShadow = false
        wingL.Material = Enum.Material.Neon
        wingL.Color = Color3.fromRGB(195, 255, 30)
        wingL.Transparency = 1
        wingL.Size = Vector3.new(0.22, 0.08, 1.2)
        wingL.Parent = vFolder

        local wingR = Instance.new("Part")
        wingR.Name = "ChevR_" .. i
        wingR.Anchored = true
        wingR.CanCollide = false
        wingR.CanTouch = false
        wingR.CanQuery = false
        wingR.CastShadow = false
        wingR.Material = Enum.Material.Neon
        wingR.Color = Color3.fromRGB(195, 255, 30)
        wingR.Transparency = 1
        wingR.Size = Vector3.new(0.22, 0.08, 1.2)
        wingR.Parent = vFolder

        table.insert(TargetVis.poolChevrons, { Left = wingL, Right = wingR })
    end
end
initTargetVisualizer()

local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.fromOffset(560, 660)
mainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
mainWindow.Position = UDim2.fromScale(0.5, 0.5)
mainWindow.BackgroundColor3 = Theme.WindowBg
mainWindow.BorderSizePixel = 0
mainWindow.ClipsDescendants = false
mainWindow.Active = true
mainWindow.ZIndex = 10
mainWindow.Parent = screenGui
table.insert(cleanUpInstances, mainWindow)

 
 
do
    Instance.new("UICorner", mainWindow).CornerRadius = UDim.new(0, 12)
    local function fitMenu()
        local camera = Workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1280, 900)
        local compact = viewport.X < 640 or (UserInputService.TouchEnabled and
            (not UserInputService.KeyboardEnabled or math.min(viewport.X, viewport.Y) < 600))
        local width = compact and math.min(350, viewport.X - 24) or math.min(560, viewport.X - 32)
        local height = compact and math.min(380, math.floor(viewport.Y * 0.72)) or math.min(660, viewport.Y - 40)
        mainWindow.Size = UDim2.fromOffset(math.max(180, width), math.max(150, height))
        mainWindow:SetAttribute("CompactLayout", compact)
         
        mainWindow.Position = UDim2.fromScale(0.5, 0.5)
    end
    fitMenu()
    local viewportConnection
    local function watchCamera()
        if viewportConnection then viewportConnection:Disconnect() end
        if Workspace.CurrentCamera then
            viewportConnection = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitMenu)
            table.insert(activeConnections, viewportConnection)
        end
        fitMenu()
    end
    watchCamera()
    table.insert(activeConnections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera))
    table.insert(activeConnections, UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(fitMenu))
    table.insert(activeConnections, UserInputService:GetPropertyChangedSignal("KeyboardEnabled"):Connect(fitMenu))
end

local FreecamState = { enabled = false, rotX = 0, rotY = 0, pos = Vector3.zero }
local sPing = nil
local lastBhopJumpTime = 0
local lastRageAutoShootTime = 0
local lastAutoShootTime = 0
local isTargetStrafing = false

local function hasWeaponEquipped()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then return true end
    end
    local vm = Workspace:FindFirstChild("ViewModels")
    local fp = vm and vm:FindFirstChild("FirstPerson")
    if fp and #fp:GetChildren() > 0 then
        for _, c in ipairs(fp:GetChildren()) do
            if c:IsA("Model") or c:IsA("BasePart") then
                return true
            end
        end
    end
    return false
end

local function setPlayerControlsEnabled(enabled)
    pcall(function()
        local ps = LocalPlayer:FindFirstChild("PlayerScripts")
        local pm = ps and ps:FindFirstChild("PlayerModule")
        if pm then
            local controls = require(pm):GetControls()
            if controls then
                if enabled then
                    controls:Enable()
                else
                    controls:Disable()
                end
            end
        end
    end)
end

 
 
pcall(function() ContextActionService:UnbindAction("ParagonMenuFreeze") end)
setPlayerControlsEnabled(true)

local function setMenuVisible(visible)
    mainWindow.Visible = visible == true
    if not mainWindow.Visible and activeDropdownClose then activeDropdownClose() end
end

local windowStroke = Instance.new("UIStroke")
windowStroke.Color = Theme.OuterBorder
windowStroke.Thickness = 1
windowStroke.Transparency = 0.6
windowStroke.Parent = mainWindow

local windowGrad = Instance.new("UIGradient")
windowGrad.Rotation = 90
windowGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.WindowBgTop),
    ColorSequenceKeypoint.new(1, Theme.WindowBgBottom)
})
windowGrad.Enabled = false
windowGrad.Parent = mainWindow

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BackgroundColor3 = Theme.HeaderBg
topBar.BorderSizePixel = 0
topBar.ZIndex = 11
topBar.Parent = mainWindow
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)
do
    local headerFill = Instance.new("Frame")
    headerFill.Size = UDim2.new(1, 0, 0, 12)
    headerFill.Position = UDim2.new(0, 0, 1, -12)
    headerFill.BackgroundColor3 = Theme.HeaderBg
    headerFill.BorderSizePixel = 0
    headerFill.ZIndex = 11
    headerFill.Parent = topBar
end

local isDragging = false
local dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = mainWindow.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then isDragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local logoFrame = Instance.new("Frame")
logoFrame.Name = "oregonnscriptsLogo"
logoFrame.Size = UDim2.new(0, 16, 0, 18)
logoFrame.Position = UDim2.new(0, 10, 0.5, -9)
logoFrame.BackgroundTransparency = 1
logoFrame.ZIndex = 12
logoFrame.Parent = topBar
logoFrame.Visible = false

local pStem = Instance.new("Frame")
pStem.Size = UDim2.new(0, 5, 0, 17)
pStem.Position = UDim2.new(0, 0, 0, 0.5)
pStem.BackgroundColor3 = Theme.AccentPinkDark
pStem.BorderSizePixel = 0
pStem.ZIndex = 13
pStem.Parent = logoFrame

local pTop = Instance.new("Frame")
pTop.Size = UDim2.new(0, 11, 0, 5)
pTop.Position = UDim2.new(0, 5, 0, 0.5)
pTop.BackgroundColor3 = Theme.AccentPinkLight
pTop.BorderSizePixel = 0
pTop.ZIndex = 14
pTop.Parent = logoFrame

local pRight = Instance.new("Frame")
pRight.Size = UDim2.new(0, 5, 0, 6)
pRight.Position = UDim2.new(0, 11, 0, 4.5)
pRight.BackgroundColor3 = Theme.AccentPink
pRight.BorderSizePixel = 0
pRight.ZIndex = 14
pRight.Parent = logoFrame

local pMid = Instance.new("Frame")
pMid.Size = UDim2.new(0, 7, 0, 4)
pMid.Position = UDim2.new(0, 5, 0, 9.5)
pMid.BackgroundColor3 = Theme.AccentPink
pMid.BorderSizePixel = 0
pMid.ZIndex = 14
pMid.Parent = logoFrame

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 220, 1, 0)
titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
titleLbl.Position = UDim2.new(0, 16, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Font = MainFont
titleLbl.RichText = true
titleLbl.Text = '<font color="#9dd1f6">oregonnscripts</font>   <font color="#92a9be">Interface</font>'
titleLbl.TextSize = 10
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 13
titleLbl.Parent = topBar
do
    local badge = Instance.new("TextLabel")
    badge.Name = "InterfaceMode"
    badge.Size = UDim2.fromOffset(51, 15)
    badge.Position = UDim2.new(0, 168, 0.5, -7.5)
    badge.BackgroundColor3 = Theme.WindowBg
    badge.BorderSizePixel = 0
    badge.Font = MainFont
    badge.Text = "Standard"
    badge.TextSize = 9
    badge.TextColor3 = Theme.TextMuted
    badge.ZIndex = 13
    badge.Parent = topBar
    Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)
    local border = Instance.new("UIStroke", badge)
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Color = Theme.BorderCard
end

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0, 100, 0, 22)
searchBox.Position = UDim2.new(1, -138, 0.5, -11)
searchBox.BackgroundColor3 = Theme.ControlBg
searchBox.BorderSizePixel = 0
searchBox.Font = MainFont
searchBox.PlaceholderText = "Search..."
searchBox.PlaceholderColor3 = Theme.TextDark
searchBox.Text = ""
searchBox.TextColor3 = Theme.TextWhite
searchBox.TextSize = 10
searchBox.ZIndex = 12
searchBox.Parent = topBar
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)

local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, 6)
pad.Parent = searchBox

local sbStroke = Instance.new("UIStroke")
sbStroke.Color = Theme.BorderDark
sbStroke.Thickness = 1
sbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
sbStroke.Parent = searchBox

searchBox.Focused:Connect(function() sbStroke.Color = Theme.BorderPink end)
searchBox.FocusLost:Connect(function() sbStroke.Color = Theme.BorderDark end)

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Modal = mainWindow.Visible
closeBtn.Size = UDim2.new(0, 26, 0, 24)
closeBtn.Position = UDim2.new(1, -32, 0.5, -12)
closeBtn.BackgroundColor3 = Theme.ControlBg
closeBtn.BorderSizePixel = 0
closeBtn.Font = MainFont
closeBtn.Text = "×"
closeBtn.TextColor3 = Theme.TextMuted
closeBtn.TextSize = 14
closeBtn.ZIndex = 12
closeBtn.Parent = topBar
table.insert(activeConnections, mainWindow:GetPropertyChangedSignal("Visible"):Connect(function()
    closeBtn.Modal = mainWindow.Visible
end))
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

local cbStroke = Instance.new("UIStroke")
cbStroke.Color = Theme.BorderDark
cbStroke.Thickness = 1
cbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
cbStroke.Parent = closeBtn

closeBtn.MouseEnter:Connect(function()
    closeBtn.TextColor3 = Theme.AccentPinkLight
    cbStroke.Color = Theme.BorderPink
end)
closeBtn.MouseLeave:Connect(function()
    closeBtn.TextColor3 = Theme.TextMuted
    cbStroke.Color = Theme.BorderDark
end)
closeBtn.Activated:Connect(function()
    setMenuVisible(false)
end)

local innerCanvas = Instance.new("Frame")
innerCanvas.Name = "InnerCanvas"
innerCanvas.Size = UDim2.new(1, 0, 1, -32)
innerCanvas.Position = UDim2.new(0, 0, 0, 32)
innerCanvas.BackgroundColor3 = Theme.InnerCanvasBg
innerCanvas.BackgroundTransparency = 1
innerCanvas.BorderSizePixel = 0
innerCanvas.ZIndex = 11
innerCanvas.Parent = mainWindow

local innerStroke = Instance.new("UIStroke")
innerStroke.Color = Theme.BorderDark
innerStroke.Thickness = 0
innerStroke.Parent = innerCanvas

 
local tabNavFrame = Instance.new("ScrollingFrame")
tabNavFrame.Name = "TabNavFrame"
tabNavFrame.Size = UDim2.new(1, -24, 0, 26)
tabNavFrame.Position = UDim2.fromOffset(12, 1)
tabNavFrame.BackgroundTransparency = 1
tabNavFrame.BorderSizePixel = 0
tabNavFrame.CanvasSize = UDim2.new()
tabNavFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
tabNavFrame.ScrollingDirection = Enum.ScrollingDirection.X
tabNavFrame.ScrollBarThickness = 0
tabNavFrame.ZIndex = 12
tabNavFrame.Parent = innerCanvas

local tabNavLayout = Instance.new("UIListLayout")
tabNavLayout.FillDirection = Enum.FillDirection.Horizontal
tabNavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabNavLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabNavLayout.Padding = UDim.new(0, 8)
tabNavLayout.Parent = tabNavFrame

local tabNavPad = Instance.new("UIPadding")
tabNavPad.PaddingLeft = UDim.new(0, 0)
tabNavPad.PaddingRight = UDim.new(0, 4)
tabNavPad.Parent = tabNavFrame

local tabContentFrame = Instance.new("Frame")
tabContentFrame.Name = "TabContentFrame"
tabContentFrame.Size = UDim2.new(1, -24, 1, -62)
tabContentFrame.Position = UDim2.fromOffset(12, 32)
tabContentFrame.BackgroundTransparency = 1
tabContentFrame.ZIndex = 12
tabContentFrame.Parent = innerCanvas

local statusBar = Instance.new("Frame")
statusBar.Name = "StatusBar"
statusBar.Size = UDim2.new(1, 0, 0, 23)
statusBar.Position = UDim2.new(0, 0, 1, -23)
statusBar.BackgroundColor3 = Theme.HeaderBg
statusBar.BorderSizePixel = 0
statusBar.ZIndex = 12
statusBar.Parent = innerCanvas
Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 10)

local statusLine = Instance.new("Frame")
statusLine.Size = UDim2.new(1, 0, 0, 1)
statusLine.Position = UDim2.new(0, 0, 0, 0)
statusLine.BackgroundColor3 = Theme.BorderDark
statusLine.BorderSizePixel = 0
statusLine.ZIndex = 12
statusLine.Parent = statusBar
statusLine.Visible = false

local statusLeft = Instance.new("TextLabel")
statusLeft.Size = UDim2.new(0.6, 0, 1, -2)
statusLeft.Position = UDim2.new(0, 14, 0, 0)
statusLeft.BackgroundTransparency = 1
statusLeft.Font = MainFont
statusLeft.RichText = true
statusLeft.RichText = false
statusLeft.Text = "●  " .. LocalPlayer.DisplayName
statusLeft.TextColor3 = Theme.TextMuted
statusLeft.TextSize = 9
statusLeft.TextXAlignment = Enum.TextXAlignment.Left
statusLeft.ZIndex = 13
statusLeft.Parent = statusBar
LocalIdentity.bind(statusLeft, "●  %s")

local statusRight = Instance.new("TextLabel")
statusRight.Size = UDim2.new(0.4, -14, 1, -2)
statusRight.Position = UDim2.new(0.6, 0, 0, 0)
statusRight.BackgroundTransparency = 1
statusRight.Font = MainFont
statusRight.RichText = true
statusRight.RichText = false
statusRight.Text = "Rivals  •  " .. Config.MenuKey.Name
statusRight.TextColor3 = Theme.TextMuted
statusRight.TextSize = 9
statusRight.TextXAlignment = Enum.TextXAlignment.Right
statusRight.ZIndex = 13
statusRight.Parent = statusBar

do
    local invite = "https://discord.gg/X5wuRQyENk"
    local discord = Instance.new("TextButton")
    discord.Name = "DiscordInvite"
    discord.Size = UDim2.new(0.4, 0, 1, 0)
    discord.Position = UDim2.new(0.3, 0, 0, 0)
    discord.BackgroundTransparency = 1
    discord.BorderSizePixel = 0
    discord.Font = MainFont
    discord.Text = "discord.gg/X5wuRQyENk"
    discord.TextSize = 9
    discord.TextColor3 = Theme.AccentPink
    discord.AutoButtonColor = false
    discord.ZIndex = 14
    discord.Parent = statusBar

    local selectable = Instance.new("TextBox")
    selectable.Name = "DiscordInviteText"
    selectable.Size = discord.Size
    selectable.Position = discord.Position
    selectable.BackgroundColor3 = Theme.ControlBg
    selectable.BorderSizePixel = 0
    selectable.Font = MainFont
    selectable.Text = invite
    selectable.TextSize = 9
    selectable.TextColor3 = Theme.AccentPinkLight
    selectable.ClearTextOnFocus = false
    selectable.Visible = false
    selectable.ZIndex = 15
    selectable.Parent = statusBar
    Instance.new("UICorner", selectable).CornerRadius = UDim.new(0, 4)

    discord.MouseEnter:Connect(function() discord.TextColor3 = Theme.AccentPinkLight end)
    discord.MouseLeave:Connect(function() discord.TextColor3 = Theme.AccentPink end)
    discord.Activated:Connect(function()
        local copy = setclipboard or toclipboard or (syn and syn.write_clipboard)
        if type(copy) == "function" then
            local ok = pcall(copy, invite)
            if ok then
                ShowNotification("oregonnscripts", "Discord invite copied.", "SUCCESS", 2)
                return
            end
        end
         
        selectable.Text = invite
        selectable.Visible = true
        selectable:CaptureFocus()
        selectable.CursorPosition = #invite + 1
        selectable.SelectionStart = 1
    end)
    selectable.FocusLost:Connect(function()
        selectable.Visible = false
        selectable.Text = invite
    end)
end

local tabList = {"home", "aim", "silent", "auto", "esp", "move", "guns", "skins", "world", "view", "config"}
local tabPages = {}
local tabButtons = {}
local currentTab = "esp"
 
local PanelUI = {
    category = {home = "home", aim = "combat", silent = "combat", auto = "combat", esp = "esp",
        move = "move", guns = "guns", skins = "guns", world = "world", view = "view", config = "config"},
    pageLabels = {home = "Home", aim = "Aimbot", silent = "Silent Aim", auto = "Automation", esp = "Visuals",
        move = "Character", guns = "Weapons", skins = "Skins", world = "World", view = "Camera", config = "Configs"},
    remembered = {combat = "aim", guns = "guns"},
    reveal = {},
}

local function switchTab(tabName)
    if not tabPages[tabName] then return end
    if activeDropdownClose then activeDropdownClose() end
    currentTab = tabName
    local category = PanelUI.category[tabName]
    PanelUI.remembered[category] = tabName
    for tName, page in pairs(tabPages) do
        page.Visible = (tName == tabName)
    end
    for _, data in ipairs(tabButtons) do
        local selected = data.name == category
        data.btn.TextColor3 = selected and Theme.AccentPinkLight or Theme.TextMuted
        data.btn.BackgroundTransparency = selected and 0 or 1
    end
end

do
    local topTabs = {
        {"combat", "Combat", "aim"}, {"esp", "Visuals", "esp"}, {"world", "World", "world"},
        {"move", "Character", "move"}, {"guns", "Weapons", "guns"}, {"view", "Camera", "view"},
        {"config", "Configs", "config"}, {"home", "Home", "home"},
    }
    for index, item in ipairs(topTabs) do
        local selected = item[1] == PanelUI.category[currentTab]
        local btn = Instance.new("TextButton")
        btn.Name = "TabBtn_" .. item[1]
        btn.LayoutOrder = index
        btn.Size = UDim2.fromOffset(0, 20)
        btn.AutomaticSize = Enum.AutomaticSize.X
        btn.BackgroundColor3 = Theme.ControlBg
        btn.BackgroundTransparency = selected and 0 or 1
        btn.BorderSizePixel = 0
        btn.Font = MainFont
        btn.Text = item[2]
        btn.TextSize = 10
        btn.TextColor3 = selected and Theme.AccentPinkLight or Theme.TextMuted
        btn.AutoButtonColor = false
        btn.ZIndex = 13
        btn.Parent = tabNavFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local padding = Instance.new("UIPadding", btn)
        padding.PaddingLeft = UDim.new(0, 7)
        padding.PaddingRight = UDim.new(0, 7)
        btn.Activated:Connect(function()
            switchTab(PanelUI.remembered[item[1]] or item[3])
        end)
        btn.MouseEnter:Connect(function() btn.TextColor3 = Theme.TextWhite end)
        btn.MouseLeave:Connect(function()
            btn.TextColor3 = PanelUI.category[currentTab] == item[1] and Theme.AccentPinkLight or Theme.TextMuted
        end)
        table.insert(tabButtons, {name = item[1], btn = btn})
    end
end

for idx, tabName in ipairs(tabList) do
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. tabName
    page:SetAttribute("TabLabel", PanelUI.pageLabels[tabName])
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Theme.BorderPinkDark
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.None
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = (tabName == currentTab)
    page.ZIndex = 13
    page.Parent = tabContentFrame

    local leftCol = Instance.new("Frame")
    leftCol.Name = "LeftCol"
    leftCol.Size = UDim2.new(0.5, -7, 0, 0)
    leftCol.Position = UDim2.new(0, 0, 0, 0)
    leftCol.BackgroundTransparency = 1
    leftCol.BorderSizePixel = 0
    leftCol.ZIndex = 14
    leftCol.Parent = page
    local lLayout = Instance.new("UIListLayout")
    lLayout.Padding = UDim.new(0, 7)
    lLayout.SortOrder = Enum.SortOrder.LayoutOrder
    lLayout.Parent = leftCol

    local rightCol = Instance.new("Frame")
    rightCol.Name = "RightCol"
    rightCol.Size = UDim2.new(0.5, -7, 0, 0)
    rightCol.Position = UDim2.new(0.5, 6, 0, 0)
    rightCol.BackgroundTransparency = 1
    rightCol.BorderSizePixel = 0
    rightCol.ZIndex = 14
    rightCol.Parent = page
    local rLayout = Instance.new("UIListLayout")
    rLayout.Padding = UDim.new(0, 7)
    rLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rLayout.Parent = rightCol

    tabPages[tabName] = page

     
    local function layoutPage()
        local compact = mainWindow:GetAttribute("CompactLayout")
        local oneColumn = compact
        local leftHeight = lLayout.AbsoluteContentSize.Y
        local rightHeight = rLayout.AbsoluteContentSize.Y
        if oneColumn then
            leftCol.Size = UDim2.new(1, -5, 0, leftHeight)
            rightCol.Size = UDim2.new(1, -5, 0, rightHeight)
            rightCol.Position = UDim2.fromOffset(0, leftHeight > 0 and leftHeight + 8 or 0)
            page.CanvasSize = UDim2.fromOffset(0, leftHeight + rightHeight + 16)
        else
            leftCol.Size = UDim2.new(0.5, -7, 0, leftHeight)
            rightCol.Size = UDim2.new(0.5, -7, 0, rightHeight)
            rightCol.Position = UDim2.new(0.5, 3, 0, 0)
            page.CanvasSize = UDim2.fromOffset(0, math.max(leftHeight, rightHeight) + 8)
        end
    end
    table.insert(activeConnections, lLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(layoutPage))
    table.insert(activeConnections, rLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(layoutPage))
    table.insert(activeConnections, mainWindow:GetAttributeChangedSignal("CompactLayout"):Connect(layoutPage))
    layoutPage()
end

do
    local function layoutShell()
        local compact = mainWindow:GetAttribute("CompactLayout")
        local topHeight = compact and 32 or 26
        topBar.Size = UDim2.new(1, 0, 0, topHeight)
        innerCanvas.Position = UDim2.fromOffset(0, topHeight)
        innerCanvas.Size = UDim2.new(1, 0, 1, -topHeight)
        tabNavFrame.Size = UDim2.new(1, -24, 0, compact and 32 or 26)
        tabContentFrame.Position = UDim2.fromOffset(12, compact and 38 or 32)
        tabContentFrame.Size = UDim2.new(1, -24, 1, compact and -68 or -62)
        tabNavLayout.Padding = UDim.new(0, compact and 5 or 8)
        for _, data in ipairs(tabButtons) do
            data.btn.Size = UDim2.fromOffset(0, compact and 26 or 20)
        end
        local badge = topBar:FindFirstChild("InterfaceMode")
        if badge then badge.Visible = not compact end
        titleLbl.Text = compact and '<font color="#9dd1f6">oregonnscripts</font>' or '<font color="#9dd1f6">oregonnscripts</font>   <font color="#92a9be">Interface</font>'
        titleLbl.Size = compact and UDim2.new(1, -166, 1, 0) or UDim2.new(0, 220, 1, 0)
        statusLeft.Size = UDim2.new(0.3, -20, 1, -2)
        statusLeft.Visible = not compact
        statusRight.Size = UDim2.new(0.3, -14, 1, -2)
        statusRight.Position = UDim2.new(0.7, 0, 0, 0)
        statusRight.Visible = not compact
        local discord = statusBar:FindFirstChild("DiscordInvite")
        local selectable = statusBar:FindFirstChild("DiscordInviteText")
        if discord and selectable then
            discord.Size = compact and UDim2.new(1, -24, 1, 0) or UDim2.new(0.4, 0, 1, 0)
            discord.Position = compact and UDim2.fromOffset(12, 0) or UDim2.new(0.3, 0, 0, 0)
            selectable.Size = discord.Size
            selectable.Position = discord.Position
        end
        statusLeft.TextTruncate = Enum.TextTruncate.AtEnd
        statusRight.Text = compact and "Rivals  •  Mobile" or "Rivals  •  " .. Config.MenuKey.Name
        if activeDropdownClose then activeDropdownClose() end
    end
    table.insert(activeConnections, mainWindow:GetAttributeChangedSignal("CompactLayout"):Connect(layoutShell))
    layoutShell()
end

local function createGroupbox(parent, title)
    local card = Instance.new("Frame")
    card.Name = "Group_" .. title:gsub("%s+", "")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.LayoutOrder = #parent:GetChildren()
    card.BackgroundColor3 = Theme.CardBg
    card.BorderSizePixel = 0
    card.ZIndex = 15
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 9)

    local headerHeight = 34
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, headerHeight)
    header.BackgroundTransparency = 1
    header.ZIndex = 16
    header.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "TitleLabel"
    titleLbl.Size = UDim2.new(1, -20, 0, 17)
    titleLbl.Position = UDim2.fromOffset(10, 7)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = MainFont
    titleLbl.Text = title
    titleLbl.TextColor3 = Theme.TextMuted
    titleLbl.TextSize = 10
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 17
    titleLbl.Parent = header

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -20, 0, 1)
    divider.Position = UDim2.new(0, 10, 1, -7)
    divider.BackgroundColor3 = Theme.BorderCard
    divider.BorderSizePixel = 0
    divider.ZIndex = 17
    divider.Parent = header

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 0, 0)
    content.Position = UDim2.fromOffset(10, headerHeight + 2)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.ZIndex = 16
    content.Parent = card

    local cLayout = Instance.new("UIListLayout")
    cLayout.Padding = UDim.new(0, 5)
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cLayout.Parent = content

    local cPad = Instance.new("UIPadding")
    cPad.PaddingBottom = UDim.new(0, 10)
    cPad.Parent = content

    return content
end

 
function PanelUI.strip(content, labels, selected, onSelect, fixedSelection)
    local card = content.Parent
    local header = card:FindFirstChild("Header")
    header:FindFirstChild("TitleLabel").Visible = false
    local strip = Instance.new("ScrollingFrame")
    strip.Name = "PanelSubtabs"
    strip.Size = UDim2.new(1, -16, 0, 27)
    strip.Position = UDim2.fromOffset(8, 1)
    strip.BackgroundTransparency = 1
    strip.BorderSizePixel = 0
    strip.CanvasSize = UDim2.new()
    strip.AutomaticCanvasSize = Enum.AutomaticSize.X
    strip.ScrollingDirection = Enum.ScrollingDirection.X
    strip.ScrollBarThickness = 0
    strip.ZIndex = 18
    strip.Parent = header
    local layout = Instance.new("UIListLayout", strip)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 3)
    local buttons = {}
    local function paint(index)
        for i, button in ipairs(buttons) do
            button.BackgroundTransparency = i == index and 0 or 1
            button.TextColor3 = i == index and Theme.AccentPinkLight or Theme.TextDark
        end
    end
    for index, label in ipairs(labels) do
        local button = Instance.new("TextButton")
        button.Name = "Subtab_" .. label:gsub("%s+", "")
        button.Size = UDim2.fromOffset(0, mainWindow:GetAttribute("CompactLayout") and 24 or 17)
        button.AutomaticSize = Enum.AutomaticSize.X
        button.LayoutOrder = index
        button.BackgroundColor3 = Theme.HeaderBg
        button.BorderSizePixel = 0
        button.Text = label
        button.Font = MainFont
        button.TextSize = 9
        button.AutoButtonColor = false
        button.ZIndex = 19
        button.Parent = strip
        Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)
        local padding = Instance.new("UIPadding", button)
        padding.PaddingLeft = UDim.new(0, 5)
        padding.PaddingRight = UDim.new(0, 5)
        buttons[index] = button
        button.Activated:Connect(function()
            if activeDropdownClose then activeDropdownClose() end
            paint(fixedSelection and selected or index)
            onSelect(index)
        end)
    end
    paint(selected)
    return paint
end

 
function PanelUI.merge(contents, labels, onSelect)
    local host = contents[1].Parent
    local active = 1
    host.AutomaticSize = Enum.AutomaticSize.None
    local function fit()
        local content = contents[active]
        local layout = content:FindFirstChildOfClass("UIListLayout")
        host.Size = UDim2.new(1, 0, 0, 36 + layout.AbsoluteContentSize.Y + 12)
    end
    local paint
    local function selectPane(index)
        active = index
        for i, pane in ipairs(contents) do pane.Visible = i == index end
        if paint then paint(index) end
        if onSelect then onSelect(index) end
        fit()
    end
    for i, pane in ipairs(contents) do
        local oldCard = pane.Parent
        pane:SetAttribute("PanelPane", labels[i])
        pane:SetAttribute("SearchTitle", oldCard.Header.TitleLabel.Text)
        pane.Name = i == 1 and "Content" or "Pane_" .. i
        pane.Position = UDim2.fromOffset(10, 36)
        pane.Parent = host
        if oldCard ~= host then oldCard:Destroy() end
        table.insert(activeConnections, pane:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fit))
        PanelUI.reveal[pane] = function() selectPane(i) end
    end
    paint = PanelUI.strip(contents[1], labels, 1, selectPane)
    selectPane(1)
    return selectPane
end

local function addCheckbox(parent, labelText, defaultVal, callback, swatchColor)
    local state = defaultVal or false
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, mainWindow:GetAttribute("CompactLayout") and 28 or 18)
    row.BackgroundTransparency = 1
    row.ZIndex = 16
    row.LayoutOrder = #parent:GetChildren()
    row.Parent = parent

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 14, 0, 14)
    box.Position = UDim2.new(0, 0, 0.5, -7)
    box.BackgroundColor3 = state and Theme.AccentPink or Theme.ControlBg
    box.BorderSizePixel = 0
    box.Text = ""
    box.ZIndex = 17
    box.AutoButtonColor = false
    box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = state and Theme.AccentPinkLight or Theme.BorderDark
    bStroke.Thickness = 0
    bStroke.Parent = box

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, swatchColor and -42 or -20, 1, 0)
    lbl.Position = UDim2.new(0, 20, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = MainFont
    lbl.Text = labelText
    lbl.TextColor3 = Theme.TextMuted
    lbl.TextSize = mainWindow:GetAttribute("CompactLayout") and 11 or 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 17
    lbl.Parent = row

     
    local hit = Instance.new("TextButton")
    hit.Name = "ToggleHitTarget"
    hit.Size = UDim2.new(1, swatchColor and -20 or 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.ZIndex = 18
    hit.Parent = row

    local tick = Instance.new("TextLabel")
    tick.Size = UDim2.fromScale(1, 1)
    tick.BackgroundTransparency = 1
    tick.Font = Enum.Font.GothamBold
    tick.Text = "✓"
    tick.TextSize = 10
    tick.TextColor3 = Theme.WindowBg
    tick.Visible = state
    tick.ZIndex = 18
    tick.Parent = box

     
    if swatchColor then
        local chip = Instance.new("Frame")
        chip.Name = "ColorPreview"
        chip.Size = UDim2.fromOffset(14, 14)
        chip.Position = UDim2.new(1, -14, 0.5, -7)
        chip.BackgroundColor3 = swatchColor
        chip.BorderSizePixel = 0
        chip.ZIndex = 17
        chip.Parent = row
        Instance.new("UICorner", chip).CornerRadius = UDim.new(0, 3)
    end

    local function syncState(newVal)
        state = newVal == true
        tick.Visible = state
        box.BackgroundColor3 = state and Theme.AccentPink or Theme.ControlBg
        bStroke.Color = state and Theme.AccentPinkLight or Theme.BorderDark
    end

    local function updateState(newVal)
        syncState(newVal)
        if type(callback) == "function" then
            local ok, err = pcall(callback, state)
            if not ok then
                warn("[oregonnscripts] " .. labelText .. ": " .. tostring(err))
                ShowNotification("oregonnscripts", labelText .. ": " .. tostring(err), "ERROR", 5)
            end
        end
    end

    hit.Activated:Connect(function()
        updateState(not state)
    end)

    return {
        Set = updateState,
        Sync = syncState,
        Get = function() return state end
    }
end

local function addSlider(parent, labelText, minVal, maxVal, defaultVal, displayTemplate, callback)
    local curVal = defaultVal or minVal

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 26)
    container.BackgroundTransparency = 1
    container.ZIndex = 16
    container.LayoutOrder = #parent:GetChildren()
    container.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 0, 13)
    lbl.BackgroundTransparency = 1
    lbl.Font = MainFont
    lbl.Text = labelText
    lbl.TextColor3 = Theme.TextMuted
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 17
    lbl.Parent = container

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 17)
    track.BackgroundColor3 = Theme.ControlBg
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    track.ZIndex = 17
    track.Parent = container
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local tStroke = Instance.new("UIStroke")
    tStroke.Color = Theme.BorderDark
    tStroke.Thickness = 0
    tStroke.Parent = track

    local fill = Instance.new("Frame")
    local pct = math.clamp((curVal - minVal) / (maxVal - minVal), 0, 1)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Theme.AccentPinkDark
    fill.BorderSizePixel = 0
    fill.ZIndex = 18
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local fGrad = Instance.new("UIGradient")
    fGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.AccentPinkLight),
        ColorSequenceKeypoint.new(1, Theme.AccentPinkDark)
    })
    fGrad.Enabled = false
    fGrad.Parent = fill

    local decimals = 0
    if displayTemplate then
        local d = displayTemplate:match("%%%.(%d+)f")
        if d then
            decimals = tonumber(d)
        elseif displayTemplate:find("%%f") then
            decimals = 2
        end
    elseif (minVal % 1 ~= 0) or (maxVal % 1 ~= 0) or (curVal % 1 ~= 0) then
        decimals = 2
    end

    local function roundVal(raw)
        if decimals > 0 then
            local mult = 10 ^ decimals
            return math.clamp(math.floor(raw * mult + 0.5) / mult, minVal, maxVal)
        else
            return math.clamp(math.floor(raw + 0.5), minVal, maxVal)
        end
    end

    local function getDisplay(v)
        if displayTemplate then
            return string.format(displayTemplate, v, maxVal)
        end
        return tostring(v)
    end

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.4, 0, 0, 13)
    valLbl.Position = UDim2.new(0.6, 0, 0, 0)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.BackgroundTransparency = 1
    valLbl.Font = MainFont
    valLbl.Text = getDisplay(curVal)
    valLbl.TextColor3 = Theme.TextMuted
    valLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    valLbl.TextStrokeTransparency = 1
    valLbl.TextSize = 9
    valLbl.ZIndex = 19
    valLbl.Parent = container

    local sliderHit = Instance.new("TextButton")
    sliderHit.Name = "SliderHitTarget"
    sliderHit.Size = UDim2.new(1, 0, 0, 15)
    sliderHit.Position = UDim2.fromOffset(0, 12)
    sliderHit.BackgroundTransparency = 1
    sliderHit.Text = ""
    sliderHit.ZIndex = 20
    sliderHit.Parent = container

    local isSliding = false
    local function updateFromInput(input)
        local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local raw = minVal + (maxVal - minVal) * relX
        curVal = roundVal(raw)
        local visualPct = math.clamp((curVal - minVal) / (maxVal - minVal), 0, 1)
        fill.Size = UDim2.new(visualPct, 0, 1, 0)
        valLbl.Text = getDisplay(curVal)
        if type(callback) == "function" then callback(curVal) end
    end

    sliderHit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            updateFromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    return {
        Set = function(v)
            local num = tonumber(v) or curVal
            curVal = roundVal(num)
            local p = math.clamp((curVal - minVal) / (maxVal - minVal), 0, 1)
            fill.Size = UDim2.new(p, 0, 1, 0)
            valLbl.Text = getDisplay(curVal)
            if type(callback) == "function" then callback(curVal) end
        end
    }
end

local function addDropdown(parent, labelText, options, defaultIdx, callback)
    local selectedIdx = defaultIdx or 1
    local isOpen = false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 39)
    container.BackgroundTransparency = 1
    container.ZIndex = 16
    container.LayoutOrder = #parent:GetChildren()
    container.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 13)
    lbl.BackgroundTransparency = 1
    lbl.Font = MainFont
    lbl.Text = labelText
    lbl.TextColor3 = Theme.TextMuted
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 17
    lbl.Parent = container

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(1, 0, 0, 22)
    box.Position = UDim2.new(0, 0, 0, 16)
    box.BackgroundColor3 = Theme.ControlBg
    box.BorderSizePixel = 0
    box.Font = MainFont
    box.Text = "  " .. options[selectedIdx]
    box.TextColor3 = Theme.TextWhite
    box.TextSize = 10
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ZIndex = 17
    box.AutoButtonColor = false
    box.Parent = container
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

    local bStroke = Instance.new("UIStroke")
    bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bStroke.Color = Theme.BorderDark
    bStroke.Thickness = 1
    bStroke.Parent = box

    local chevron = Instance.new("TextLabel")
    chevron.Size = UDim2.new(0, 14, 1, 0)
    chevron.Position = UDim2.new(1, -16, 0, 0)
    chevron.BackgroundTransparency = 1
    chevron.Font = Enum.Font.GothamBold
    chevron.Text = "▼"
    chevron.TextColor3 = Theme.AccentPinkDark
    chevron.TextSize = 8.5
    chevron.ZIndex = 18
    chevron.Parent = box

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Name = "DropdownMenu_" .. labelText:gsub("%s+", "")
    listFrame.BackgroundColor3 = Theme.CardBg
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 2.5
    listFrame.ScrollBarImageColor3 = Theme.AccentPink
    listFrame.CanvasSize = UDim2.new()
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFrame.ZIndex = 1001
    listFrame.Visible = false
    listFrame.Parent = dropdownOverlay
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 5)

    local lStroke = Instance.new("UIStroke")
    lStroke.Color = Theme.BorderPinkDark
    lStroke.Thickness = 1
    lStroke.Parent = listFrame

    local lGrad = Instance.new("UIGradient")
    lGrad.Rotation = 90
    lGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.CardBgTop),
        ColorSequenceKeypoint.new(1, Theme.CardBgBottom)
    })
    lGrad.Enabled = false
    lGrad.Parent = listFrame

    local optLayout = Instance.new("UIListLayout")
    optLayout.Padding = UDim.new(0, 1)
    optLayout.Parent = listFrame

    local function closeDropdown()
        isOpen = false
        listFrame.Visible = false
        chevron.Text = "▼"
        bStroke.Color = Theme.BorderDark
        if activeDropdownClose == closeDropdown then
            activeDropdownClose = nil
        end
    end

    local function refreshOptions()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for idx, optName in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 20)
            optBtn.BackgroundColor3 = (idx == selectedIdx) and Theme.ButtonBg or Color3.fromRGB(0, 0, 0)
            optBtn.BackgroundTransparency = (idx == selectedIdx) and 0 or 1
            optBtn.BorderSizePixel = 0
            optBtn.Font = MainFont
            optBtn.Text = "  " .. optName
            optBtn.TextColor3 = (idx == selectedIdx) and Theme.AccentPinkLight or Theme.TextWhite
            optBtn.TextSize = 11.5
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.ZIndex = 1002
            optBtn.Parent = listFrame

            optBtn.MouseEnter:Connect(function()
                if idx ~= selectedIdx then
                    optBtn.BackgroundTransparency = 0.5
                    optBtn.BackgroundColor3 = Theme.ButtonHoverBg
                end
            end)
            optBtn.MouseLeave:Connect(function()
                if idx ~= selectedIdx then
                    optBtn.BackgroundTransparency = 1
                end
            end)

            optBtn.Activated:Connect(function()
                selectedIdx = idx
                box.Text = "  " .. optName
                closeDropdown()
                if type(callback) == "function" then callback(optName, idx) end
            end)
        end
    end

    local function openDropdown()
        if activeDropdownClose and activeDropdownClose ~= closeDropdown then
            activeDropdownClose()
        end

        refreshOptions()
        local boxPos = box.AbsolutePosition
        local boxSize = box.AbsoluteSize
        local menuHeight = math.min(#options * 21, 140)

        local overlayPos = dropdownOverlay.AbsolutePosition
        local overlaySize = dropdownOverlay.AbsoluteSize
        local menuX = math.clamp(boxPos.X - overlayPos.X, 0, math.max(0, overlaySize.X - boxSize.X))
        local menuY = boxPos.Y - overlayPos.Y + boxSize.Y + 2
        if menuY + menuHeight > overlaySize.Y then
            menuY = math.max(0, boxPos.Y - overlayPos.Y - menuHeight - 2)
        end
        listFrame.Position = UDim2.fromOffset(menuX, menuY)
        listFrame.Size = UDim2.new(0, boxSize.X, 0, menuHeight)
        listFrame.Visible = true
        isOpen = true
        chevron.Text = "▲"
        bStroke.Color = Theme.BorderPink

        activeDropdownClose = function(clickPos)
            if clickPos then
                local menuPos = listFrame.AbsolutePosition
                local menuSize = listFrame.AbsoluteSize
                local inMenu = clickPos.X >= menuPos.X and clickPos.X <= (menuPos.X + menuSize.X) and clickPos.Y >= menuPos.Y and clickPos.Y <= (menuPos.Y + menuSize.Y)
                local inBox = clickPos.X >= boxPos.X and clickPos.X <= (boxPos.X + boxSize.X) and clickPos.Y >= boxPos.Y and clickPos.Y <= (boxPos.Y + boxSize.Y)
                if not inMenu and not inBox then
                    closeDropdown()
                end
            else
                closeDropdown()
            end
        end
    end

    box.Activated:Connect(function()
        if isOpen then
            closeDropdown()
        else
            openDropdown()
        end
    end)

    return {
        Set = function(valOrIdx)
            local targetIdx = 1
            if type(valOrIdx) == "number" then
                targetIdx = math.clamp(valOrIdx, 1, #options)
            elseif type(valOrIdx) == "string" then
                for i, name in ipairs(options) do
                    if name == valOrIdx then
                        targetIdx = i
                        break
                    end
                end
            end
            selectedIdx = targetIdx
            box.Text = "  " .. options[selectedIdx]
            if type(callback) == "function" then callback(options[selectedIdx], selectedIdx) end
        end,
        SetOptions = function(newOptions, newSelected)
            options = newOptions
            local targetIdx = 1
            if type(newSelected) == "number" then
                targetIdx = math.clamp(newSelected, 1, #options)
            elseif type(newSelected) == "string" then
                for i, name in ipairs(options) do
                    if name == newSelected then
                        targetIdx = i
                        break
                    end
                end
            end
            selectedIdx = targetIdx
            box.Text = "  " .. (options[selectedIdx] or "None")
        end,
        Get = function()
            return options[selectedIdx]
        end
    }
end

local function addTextbox(parent, labelText, defaultVal, placeholder, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 33)
    container.BackgroundTransparency = 1
    container.ZIndex = 16
    container.LayoutOrder = #parent:GetChildren()
    container.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 12)
    lbl.BackgroundTransparency = 1
    lbl.Font = MainFont
    lbl.Text = labelText
    lbl.TextColor3 = Theme.TextMuted
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 17
    lbl.Parent = container

    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(1, 0, 0, 19)
    tb.Position = UDim2.new(0, 0, 0, 13)
    tb.BackgroundColor3 = Theme.ControlBg
    tb.BorderSizePixel = 0
    tb.Font = MainFont
    tb.PlaceholderText = placeholder or ""
    tb.PlaceholderColor3 = Theme.TextDark
    tb.Text = defaultVal or ""
    tb.TextColor3 = Theme.TextWhite
    tb.TextSize = 10
    tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.ZIndex = 17
    tb.Parent = container
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 4)

    local tPad = Instance.new("UIPadding")
    tPad.PaddingLeft = UDim.new(0, 6)
    tPad.Parent = tb

    local tbStroke = Instance.new("UIStroke")
    tbStroke.Color = Theme.BorderDark
    tbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    tbStroke.Thickness = 1
    tbStroke.Parent = tb

    tb.Focused:Connect(function() tbStroke.Color = Theme.BorderPink end)
    tb.FocusLost:Connect(function()
        tbStroke.Color = Theme.BorderDark
        if type(callback) == "function" then callback(tb.Text) end
    end)

    return {
        Set = function(txt)
            tb.Text = tostring(txt)
            if type(callback) == "function" then callback(tb.Text) end
        end,
        Get = function()
            return tb.Text
        end
    }
end

local function clickWeapon()
    if mouse1click then
        pcall(mouse1click)
        return
    end
    if mouse1press and mouse1release then
        pcall(function()
            mouse1press()
            task.wait(0.01)
            mouse1release()
        end)
        return
    end
    local vim = game:GetService("VirtualInputManager")
    if vim then
        local vp = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
        local cx = math.floor(vp.X * 0.5)
        local cy = math.floor(vp.Y * 0.5)
        if UserInputService.TouchEnabled and not UserInputService.MouseEnabled and vim.SendTouchEvent then
            pcall(function()
                vim:SendTouchEvent(0, 0, cx, cy)
                task.wait(0.01)
                vim:SendTouchEvent(0, 2, cx, cy)
            end)
            return
        end
        if vim.SendMouseButtonEvent then
            pcall(function()
                vim:SendMouseButtonEvent(cx, cy, 0, true, Workspace, 0)
                task.wait(0.01)
                vim:SendMouseButtonEvent(cx, cy, 0, false, Workspace, 0)
            end)
            return
        end
    end
end
hideFromStack(clickWeapon)

local uiRegistry = {}
local isSyncingTeamCheck = false
local function updateTeamCheck(v)
    if isSyncingTeamCheck then return end
    isSyncingTeamCheck = true
    Config.TeamCheck = v
    for _, name in ipairs({"AimbotTeamCheck", "SilentTeamCheck", "RagebotTeamCheck"}) do
        if uiRegistry[name] and uiRegistry[name].Set and uiRegistry[name].Get() ~= v then
            pcall(function() uiRegistry[name].Set(v) end)
        end
    end
    isSyncingTeamCheck = false
end
hideFromStack(updateTeamCheck)

local function addButton(parent, btnText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 22)
    btn.BackgroundColor3 = Theme.ButtonBg
    btn.BorderSizePixel = 0
    btn.Font = MainFont
    btn.Text = btnText
    btn.TextColor3 = Theme.TextWhite
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.ZIndex = 17
    btn.LayoutOrder = #parent:GetChildren()
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Theme.ButtonBorder
    bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bStroke.Thickness = 1
    bStroke.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Theme.ButtonHoverBg
        bStroke.Color = Theme.BorderPinkDark
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Theme.ButtonBg
        bStroke.Color = Theme.ButtonBorder
    end)

    btn.Activated:Connect(function()
        if type(callback) == "function" then callback() end
    end)
    return btn
end

local function getEnemyPlayers()
    local now = tick()
    if (now - TargetVis.lastEnemyUpdateTime < 0.15) and (#TargetVis.cachedEnemies > 0) then
        return TargetVis.cachedEnemies
    end
    table.clear(TargetVis.cachedEnemies)

    local inLobby = isInLobby()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if inLobby then
                if Config.ESP_Lobby or Config.TargetVisualizer then
                    table.insert(TargetVis.cachedEnemies, p)
                end
            else
                if isEnemyPlayer(p) then
                    table.insert(TargetVis.cachedEnemies, p)
                end
            end
        end
    end
    TargetVis.lastEnemyUpdateTime = now
    return TargetVis.cachedEnemies
end

local function getClosestTarget(maxFOV, checkVisible, partMode, targetPriority)
    local now = tick()
    local cacheKey = tostring(maxFOV) .. "_" .. tostring(checkVisible) .. "_" .. tostring(partMode) .. "_" .. tostring(targetPriority)
    local cached = TargetVis.targetCache[cacheKey]
    if cached and (now - cached.time < 0.06) and cached.target and cached.target.Parent then
        return cached.target
    end

    if not TargetVis.staticRayParams then
        local p = RaycastParams.new()
        p.FilterType = Enum.RaycastFilterType.Exclude
        p.IgnoreWater = true
        TargetVis.staticRayParams = p
    end

    local closest, closestScore = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local camPos = Camera.CFrame.Position
    local camLook = Camera.CFrame.LookVector
    local is360 = (maxFOV == nil) or (maxFOV >= 999)

    TargetVis.staticRayParams.FilterDescendantsInstances = {myChar, Camera}

    for _, p in ipairs(getEnemyPlayers()) do
        local char = p.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")

        if char and hum and hum.Health > 0 and rootPart then

            local toRoot = rootPart.Position - camPos
            if is360 or toRoot:Dot(camLook) > -5 then

                local isDeflecting = char:GetAttribute("Deflecting") or char:FindFirstChild("Deflect") or char:FindFirstChild("KatanaDeflect")
                local isShielded = char:GetAttribute("Shielded") or char:FindFirstChild("Shield") or char:FindFirstChild("EnergyShield")
                local isProtected = char:GetAttribute("SpawnImmunity") or char:FindFirstChildOfClass("ForceField")

                local skip = false
                if isTeammate(p) or isTeammate(char) then skip = true end
                if Config.SilentIgnoreDeflecting and isDeflecting then skip = true end
                if Config.SilentIgnoreShielded and isShielded then skip = true end
                if Config.SilentVulnerableOnly and isProtected then skip = true end

                if not skip then
                    local headCandidate = char:FindFirstChild("Head") or char:FindFirstChild("HitboxHead")
                    local bodyCandidate = char:FindFirstChild("UpperTorso") or rootPart
                    local hitPart = nil

                    if partMode == "Head" then
                        hitPart = headCandidate or bodyCandidate
                    elseif partMode == "Body" then
                        hitPart = bodyCandidate or headCandidate
                    elseif partMode == "Closest" then
                        if headCandidate and bodyCandidate then
                            local hScr, hOn = Camera:WorldToViewportPoint(headCandidate.Position)
                            local bScr, bOn = Camera:WorldToViewportPoint(bodyCandidate.Position)
                            if hOn and bOn then
                                local hDist = (Vector2.new(hScr.X, hScr.Y) - mousePos).Magnitude
                                local bDist = (Vector2.new(bScr.X, bScr.Y) - mousePos).Magnitude
                                hitPart = (hDist <= bDist) and headCandidate or bodyCandidate
                            elseif hOn then
                                hitPart = headCandidate
                            elseif bOn then
                                hitPart = bodyCandidate
                            else
                                hitPart = headCandidate
                            end
                        else
                            hitPart = headCandidate or bodyCandidate
                        end
                    else
                        hitPart = headCandidate or bodyCandidate
                    end

                    if hitPart then
                        local inRange = false
                        local score = math.huge
                        if is360 then
                            local worldDist = myRoot and (hitPart.Position - myRoot.Position).Magnitude or (hitPart.Position - camPos).Magnitude
                            if worldDist <= (maxFOV or math.huge) then
                                inRange = true
                                if targetPriority == "Health" then
                                    score = hum.Health
                                else
                                    score = worldDist
                                end
                            end
                        else
                            local scrPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
                            if onScreen and scrPos.Z > 0 then
                                local fovDist = (Vector2.new(scrPos.X, scrPos.Y) - mousePos).Magnitude
                                if fovDist <= (maxFOV or math.huge) then
                                    inRange = true
                                    if targetPriority == "Health" then
                                        score = hum.Health
                                    elseif targetPriority == "Distance" and myRoot then
                                        score = (hitPart.Position - myRoot.Position).Magnitude
                                    else
                                        score = fovDist
                                    end
                                end
                            end
                        end

                        if inRange and score < closestScore then
                            if checkVisible then
                                local dir = hitPart.Position - camPos
                                local res = Workspace:Raycast(camPos, dir, TargetVis.staticRayParams)
                                if not res or res.Instance:IsDescendantOf(char) then
                                    closest = hitPart
                                    closestScore = score
                                end
                            else
                                closest = hitPart
                                closestScore = score
                            end
                        end
                    end
                end
            end
        end
    end

    TargetVis.targetCache[cacheKey] = { target = closest, time = now }
    return closest
end

local pageHome = tabPages["home"]
local homeLeft = pageHome:FindFirstChild("LeftCol")
local homeRight = pageHome:FindFirstChild("RightCol")

local gbAccount = createGroupbox(homeLeft, "Account")
local aUser = Instance.new("TextLabel")
aUser.Size = UDim2.new(1, 0, 0, 16)
aUser.BackgroundTransparency = 1
aUser.Font = MainFont
aUser.Text = LocalPlayer.Name
aUser.TextColor3 = Theme.TextWhite
aUser.TextSize = 12.5
aUser.TextXAlignment = Enum.TextXAlignment.Left
aUser.ZIndex = 17
aUser.Parent = gbAccount
LocalIdentity.bind(aUser, "%s")

local aDisplay = Instance.new("TextLabel")
aDisplay.Size = UDim2.new(1, 0, 0, 16)
aDisplay.BackgroundTransparency = 1
aDisplay.Font = MainFont
aDisplay.Text = "(@" .. LocalPlayer.DisplayName .. ")"
aDisplay.TextColor3 = Theme.TextMuted
aDisplay.TextSize = 12
aDisplay.TextXAlignment = Enum.TextXAlignment.Left
aDisplay.ZIndex = 17
aDisplay.Parent = gbAccount
LocalIdentity.bind(aDisplay, "(@%s)")

local gbBuild = createGroupbox(homeLeft, "Build")
local bLbl = Instance.new("TextLabel")
bLbl.Size = UDim2.new(1, 0, 0, 16)
bLbl.BackgroundTransparency = 1
bLbl.Font = MainFont
bLbl.Text = "oregonnscripts P1003 build"
bLbl.TextColor3 = Theme.TextWhite
bLbl.TextSize = 12.5
bLbl.TextXAlignment = Enum.TextXAlignment.Left
bLbl.ZIndex = 17
bLbl.Parent = gbBuild

local gbSessionInfo = createGroupbox(homeRight, "Current Session")
local sPlayer = Instance.new("TextLabel")
sPlayer.Size = UDim2.new(1, 0, 0, 16)
sPlayer.BackgroundTransparency = 1
sPlayer.Font = MainFont
sPlayer.Text = "Player: " .. LocalPlayer.Name
sPlayer.TextColor3 = Theme.TextWhite
sPlayer.TextSize = 12.5
sPlayer.TextXAlignment = Enum.TextXAlignment.Left
sPlayer.ZIndex = 17
sPlayer.Parent = gbSessionInfo
LocalIdentity.bind(sPlayer, "Player: %s")

sPing = Instance.new("TextLabel")
sPing.Size = UDim2.new(1, 0, 0, 16)
sPing.BackgroundTransparency = 1
sPing.Font = MainFont
sPing.Text = "0 ms - " .. #Players:GetPlayers() .. " players"
sPing.TextColor3 = Theme.TextWhite
sPing.TextSize = 12.5
sPing.TextXAlignment = Enum.TextXAlignment.Left
sPing.ZIndex = 17
sPing.Parent = gbSessionInfo

local gbSessionActions = createGroupbox(homeRight, "Session")
addButton(gbSessionActions, "Rejoin server", function()
    ShowNotification("oregonnscripts", "Reconnecting to experience...", "INFO", 3)
    task.spawn(function()
        task.wait(0.5)
        pcall(function()
            TeleportService:Teleport(17625359962, LocalPlayer)
        end)
    end)
end)

addButton(gbSessionActions, "Join lowest-ping server", function()
    ShowNotification("oregonnscripts", "Searching for lowest-ping public server...", "INFO", 3)
    task.spawn(function()
        local placeId = 17625359962
        local HttpService = game:GetService("HttpService")
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/0?sortOrder=2&excludeFullGames=true&limit=25", placeId)
        local success, res = pcall(function() return game:HttpGet(url) end)
        local targetServer = nil
        if success and res then
            local sDec, data = pcall(function() return HttpService:JSONDecode(res) end)
            if sDec and data and data.data then
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId and s.playing and s.maxPlayers and (s.playing < s.maxPlayers) then
                        if not targetServer or (s.ping and targetServer.ping and s.ping < targetServer.ping) or (s.ping and not targetServer.ping) then
                            targetServer = s
                        end
                    end
                end
            end
        end

        if targetServer then
            ShowNotification("oregonnscripts", string.format("Joining server (%d ms ping)...", targetServer.ping or 0), "SUCCESS", 3)
            task.wait(0.5)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, targetServer.id, LocalPlayer)
            end)
        else
            ShowNotification("oregonnscripts", "Connecting to optimal regional server...", "INFO", 3)
            task.wait(0.5)
            pcall(function()
                TeleportService:Teleport(placeId, LocalPlayer)
            end)
        end
    end)
end)

local pageAuto = tabPages["auto"]
local autoLeft = pageAuto:FindFirstChild("LeftCol")
local autoRight = pageAuto:FindFirstChild("RightCol")

local gbRagebot = createGroupbox(autoLeft, "Ragebot")
uiRegistry["Ragebot"] = addCheckbox(gbRagebot, "Enable ragebot", Config.Ragebot, function(v) Config.Ragebot = v end)
uiRegistry["RagebotTeamCheck"] = addCheckbox(gbRagebot, "Team check", Config.TeamCheck, function(v) updateTeamCheck(v) end)
uiRegistry["RagebotAutoShoot"] = addCheckbox(gbRagebot, "Auto shoot", Config.RagebotAutoShoot, function(v) Config.RagebotAutoShoot = v end)
uiRegistry["RagebotTargetStrafe"] = addCheckbox(gbRagebot, "Target strafe", Config.RagebotTargetStrafe, function(v) Config.RagebotTargetStrafe = v end)
uiRegistry["TargetStrafeRadius"] = addSlider(gbRagebot, "Strafe radius", 6, 30, Config.TargetStrafeRadius, "%d studs", function(v) Config.TargetStrafeRadius = v end)
uiRegistry["TargetStrafeSpeed"] = addSlider(gbRagebot, "Strafe speed", 2, 15, Config.TargetStrafeSpeed, "%d spd", function(v) Config.TargetStrafeSpeed = v end)
uiRegistry["Autoplay"] = addCheckbox(gbRagebot, "Autoplay", Config.Autoplay, function(v) Config.Autoplay = v end)
uiRegistry["AutoplayDistance"] = addSlider(gbRagebot, "Autoplay stop distance", 8, 40, Config.AutoplayDistance, "%d studs", function(v) Config.AutoplayDistance = v end)

local gbMatch = createGroupbox(autoLeft, "Match Automation")
uiRegistry["AutoRespawn"] = addCheckbox(gbMatch, "Auto respawn", Config.AutoRespawn, function(v) Config.AutoRespawn = v end)
uiRegistry["AutoQueue"] = addCheckbox(gbMatch, "Auto queue", Config.AutoQueue, function(v) Config.AutoQueue = v end)
uiRegistry["QueueMode"] = addDropdown(gbMatch, "Queue", {"1v1", "2v2", "3v3", "4v4", "5v5"}, 1, function(v) Config.QueueMode = v end)

local gbVote = createGroupbox(autoLeft, "Automatic Voting")
uiRegistry["AutoVoteMaps"] = addCheckbox(gbVote, "Auto vote maps", Config.AutoVoteMaps, function(v) Config.AutoVoteMaps = v end)
uiRegistry["MapPriority"] = addDropdown(gbVote, "Map priority", {"Arena, Onyx, Crossroads", "Onyx, Arena, Crossroads", "Crossroads, Arena, Onyx"}, 1, function(v) Config.MapPriority = v end)
uiRegistry["AutoBanWeapons"] = addCheckbox(gbVote, "Auto ban weapons", Config.AutoBanWeapons, function(v) Config.AutoBanWeapons = v end)
uiRegistry["WeaponBanPriority"] = addDropdown(gbVote, "Weapon ban priority", {"Grenade Launcher, Minigun, RPG", "RPG, Grenade Launcher, Sniper", "Minigun, RPG, Shotgun"}, 1, function(v) Config.WeaponBanPriority = v end)
uiRegistry["SecondBanPriority"] = addDropdown(gbVote, "Second ban priority", {"Grenade Launcher, Minigun, RPG", "Sniper, Katana, Bow"}, 1, function(v) Config.SecondBanPriority = v end)

local gbLoadout = createGroupbox(autoLeft, "Automatic Loadout")
uiRegistry["AutoLoadout"] = addCheckbox(gbLoadout, "Auto loadout", Config.AutoLoadout, function(v) Config.AutoLoadout = v end)
uiRegistry["LoadoutOnlySelected"] = addCheckbox(gbLoadout, "Only on selected maps", Config.LoadoutOnlySelected, function(v) Config.LoadoutOnlySelected = v end)
uiRegistry["EnabledMaps"] = addDropdown(gbLoadout, "Enabled maps", {"Arena, Crossroads", "Onyx, Crossroads", "All Maps"}, 1, function(v) Config.EnabledMaps = v end)

local gbAntiAim = createGroupbox(autoRight, "Anti-Aim")
uiRegistry["AntiAim"] = addCheckbox(gbAntiAim, "Enable anti-aim", Config.AntiAim, function(v) Config.AntiAim = v end)
uiRegistry["AntiAimMode"] = addDropdown(gbAntiAim, "Mode", {"Spin", "Jitter", "Backwards"}, 1, function(v) Config.AntiAimMode = v end)
uiRegistry["AntiAimSpeed"] = addSlider(gbAntiAim, "Spin speed", 10, 100, Config.AntiAimSpeed, "%d spd", function(v) Config.AntiAimSpeed = v end)

local gbDetectors = createGroupbox(autoRight, "Detectors")
uiRegistry["HackerDetector"] = addCheckbox(gbDetectors, "Hacker detector", Config.HackerDetector, function(v) Config.HackerDetector = v end)
uiRegistry["NotifyHackers"] = addCheckbox(gbDetectors, "Notify detected hackers", Config.NotifyHackers, function(v) Config.NotifyHackers = v end)
uiRegistry["HackerAutoLoad"] = addCheckbox(gbDetectors, "Auto load config on detect", Config.HackerAutoLoad, function(v) Config.HackerAutoLoad = v end)
uiRegistry["HackerProfile"] = addTextbox(gbDetectors, "Profile to auto load", Config.HackerProfile, "profile name (e.g. rage)", function(v) Config.HackerProfile = v end)
uiRegistry["SpeedThreshold"] = addSlider(gbDetectors, "Speed threshold", 50, 400, Config.SpeedThreshold, "%d studs/s/%d studs/s", function(v) Config.SpeedThreshold = v end)
uiRegistry["SpeedDuration"] = addSlider(gbDetectors, "Required duration", 0.1, 3, Config.SpeedDuration, "%.2f s/%.0f s", function(v) Config.SpeedDuration = v end)
uiRegistry["ModDetector"] = addCheckbox(gbDetectors, "Moderator detector", Config.ModDetector, function(v) Config.ModDetector = v end)
uiRegistry["NotifyMods"] = addCheckbox(gbDetectors, "Notify moderators", Config.NotifyMods, function(v) Config.NotifyMods = v end)
uiRegistry["MinGroupRank"] = addSlider(gbDetectors, "Minimum group rank", 1, 255, Config.MinGroupRank, "%d/%d", function(v) Config.MinGroupRank = v end)
uiRegistry["ModUsernames"] = addTextbox(gbDetectors, "Moderator usernames", Config.ModUsernames, "name1, name2", function(v) Config.ModUsernames = v end)
uiRegistry["ModFriendList"] = addTextbox(gbDetectors, "Moderator friend list", Config.ModFriendList, "name1, name2", function(v) Config.ModFriendList = v end)

local gbPickups = createGroupbox(autoRight, "Pickups & Tripmines")
uiRegistry["AutoPickup"] = addCheckbox(gbPickups, "Auto pickup nearby drops", Config.AutoPickup, function(v) Config.AutoPickup = v end)
uiRegistry["PickupRadius"] = addSlider(gbPickups, "Pickup radius", 10, 60, Config.PickupRadius, "%d studs/%d studs", function(v) Config.PickupRadius = v end)

local pageAim = tabPages["aim"]
local aimLeft = pageAim:FindFirstChild("LeftCol")
local aimRight = pageAim:FindFirstChild("RightCol")

local gbAimbot = createGroupbox(aimLeft, "Aimbot")
uiRegistry["Aimbot"] = addCheckbox(gbAimbot, "Enable aimbot", Config.Aimbot, function(v) Config.Aimbot = v end)
uiRegistry["AimbotTeamCheck"] = addCheckbox(gbAimbot, "Team check", Config.TeamCheck, function(v) updateTeamCheck(v) end)
uiRegistry["ContinuousTargeting"] = addCheckbox(gbAimbot, "Continuous targeting", Config.ContinuousTargeting, function(v) Config.ContinuousTargeting = v end)
uiRegistry["AimbotKeyMode"] = addDropdown(gbAimbot, "Key mode", {"Hold", "Toggle", "Always"}, 1, function(v) Config.AimbotKeyMode = v end)
do
    local aimFovGroup = createGroupbox(aimLeft, "Field of View")
    uiRegistry["AimbotFOVCircle"] = addCheckbox(aimFovGroup, "Show FOV Circle", Config.AimbotFOVCircle, function(v)
        Config.AimbotFOVCircle = v
    end, Theme.AccentPink)
    uiRegistry["AimbotFOV"] = addSlider(aimFovGroup, "FOV Radius", 30, 600, Config.AimbotFOV, "%d px", function(v)
        Config.AimbotFOV = v
    end)
end

gbAimbot = createGroupbox(aimRight, "Targeting")
uiRegistry["AimbotScopeOnly"] = addCheckbox(gbAimbot, "Scope only", Config.AimbotScopeOnly, function(v) Config.AimbotScopeOnly = v end)
uiRegistry["AimbotDisableReloading"] = addCheckbox(gbAimbot, "Disable while reloading", Config.AimbotDisableReloading, function(v) Config.AimbotDisableReloading = v end)
uiRegistry["AimbotSmoothing"] = addSlider(gbAimbot, "Smoothing speed", 0.05, 1, Config.AimbotSmoothing, "%.2f", function(v) Config.AimbotSmoothing = v end)
uiRegistry["InstantCameraLock"] = addCheckbox(gbAimbot, "Instant camera lock", Config.InstantCameraLock, function(v) Config.InstantCameraLock = v end)
uiRegistry["TrackThroughWalls"] = addCheckbox(gbAimbot, "Track lock through walls", Config.TrackThroughWalls, function(v) Config.TrackThroughWalls = v end)
uiRegistry["AimbotPart"] = addDropdown(gbAimbot, "Persistent lock part", {"Head", "Body", "Closest"}, 1, function(v) Config.AimbotPart = v end)
uiRegistry["CorrectLockedShots"] = addCheckbox(gbAimbot, "Correct locked shots", Config.CorrectLockedShots, function(v) Config.CorrectLockedShots = v end)

local gbSilent = createGroupbox(tabPages["silent"]:FindFirstChild("LeftCol"), "Silent Aim")
uiRegistry["SilentAim"] = addCheckbox(gbSilent, "Enable silent aim", Config.SilentAim, function(v) Config.SilentAim = v end)
uiRegistry["SilentTeamCheck"] = addCheckbox(gbSilent, "Team check", Config.TeamCheck, function(v) updateTeamCheck(v) end)
uiRegistry["SilentKeyMode"] = addDropdown(gbSilent, "Key mode", {"Always", "Hold", "Toggle"}, 1, function(v) Config.SilentKeyMode = v end)
gbSilent = createGroupbox(tabPages["silent"]:FindFirstChild("RightCol"), "Targeting & Accuracy")
uiRegistry["SilentVisibleOnly"] = addCheckbox(gbSilent, "Visible targets only", Config.SilentVisibleOnly, function(v) Config.SilentVisibleOnly = v end)
uiRegistry["SilentVulnerableOnly"] = addCheckbox(gbSilent, "Vulnerable targets only", Config.SilentVulnerableOnly, function(v) Config.SilentVulnerableOnly = v end)
uiRegistry["SilentIgnoreDeflecting"] = addCheckbox(gbSilent, "Ignore deflecting", Config.SilentIgnoreDeflecting, function(v) Config.SilentIgnoreDeflecting = v end)
uiRegistry["SilentIgnoreShielded"] = addCheckbox(gbSilent, "Ignore shielded", Config.SilentIgnoreShielded, function(v) Config.SilentIgnoreShielded = v end)
uiRegistry["SilentTargetPart"] = addDropdown(gbSilent, "Target part", {"Head", "Body", "Closest"}, 1, function(v) Config.SilentTargetPart = v end)
uiRegistry["SilentHeadChance"] = addSlider(gbSilent, "Head Chance", 0, 100, Config.SilentHeadChance, "%d%%", function(v) Config.SilentHeadChance = v end)
uiRegistry["SilentHitChance"] = addSlider(gbSilent, "Hit chance", 0, 100, Config.SilentHitChance, "%d%%", function(v) Config.SilentHitChance = v end)
uiRegistry["SilentFOV"] = addSlider(gbSilent, "FOV Radius", 30, 400, Config.SilentFOV, "%d px", function(v) Config.SilentFOV = v end)

local pageEsp = tabPages["esp"]
local espLeft = pageEsp:FindFirstChild("LeftCol")
local espRight = pageEsp:FindFirstChild("RightCol")

 
do
    local espMain = createGroupbox(espLeft, "ESP")
    uiRegistry["ESP_Master"] = addCheckbox(espMain, "Enabled", Config.ESP_Master, function(v) Config.ESP_Master = v end)
    uiRegistry["ESP_EnemyOnly"] = addCheckbox(espMain, "Team Check", Config.ESP_EnemyOnly, function(v) Config.ESP_EnemyOnly = v end)
    uiRegistry["ESP_MaxDistance"] = addSlider(espMain, "Render Distance", 100, 1000, Config.ESP_MaxDistance, "%d studs", function(v) Config.ESP_MaxDistance = v end)
    local box = createGroupbox(espLeft, "Box")
    uiRegistry["ESP_Boxes"] = addCheckbox(box, "Enabled", Config.ESP_Boxes, function(v) Config.ESP_Boxes = v end, Theme.AccentPinkLight)
    local name = createGroupbox(espLeft, "Name")
    uiRegistry["ESP_Names"] = addCheckbox(name, "Enabled", Config.ESP_Names, function(v) Config.ESP_Names = v end, Theme.TextWhite)
    local crosshair = createGroupbox(espLeft, "Crosshair")
    uiRegistry["ESP_FOV"] = addCheckbox(crosshair, "FOV Circle", Config.ESP_FOV, function(v) Config.ESP_FOV = v end)
    local misc = createGroupbox(espLeft, "Misc")
    uiRegistry["ESP_Lobby"] = addCheckbox(misc, "Show in Lobby", Config.ESP_Lobby, function(v) Config.ESP_Lobby = v end)
    uiRegistry["ESP_Tripmines"] = addCheckbox(misc, "Tripmines", Config.ESP_Tripmines, function(v) Config.ESP_Tripmines = v end)
    local indicators = createGroupbox(espRight, "Indicators")
    uiRegistry["ESP_Distance"] = addCheckbox(indicators, "Distance", Config.ESP_Distance, function(v) Config.ESP_Distance = v end, Theme.AccentPinkLight)
    uiRegistry["ESP_Weapon"] = addCheckbox(indicators, "Equipped Item", Config.ESP_Weapon, function(v) Config.ESP_Weapon = v end, Theme.AccentPinkLight)
    uiRegistry["ESP_Skeleton"] = addCheckbox(indicators, "Skeleton", Config.ESP_Skeleton, function(v) Config.ESP_Skeleton = v end, Theme.AccentPinkLight)
    uiRegistry["ESP_HeadDot"] = addCheckbox(indicators, "Head Dot", Config.ESP_HeadDot, function(v) Config.ESP_HeadDot = v end, Theme.AccentPinkLight)
    local health = createGroupbox(espRight, "Health")
    uiRegistry["ESP_HealthBar"] = addCheckbox(health, "Health Bar", Config.ESP_HealthBar, function(v) Config.ESP_HealthBar = v end, Theme.AccentPink)
    local chams = createGroupbox(espRight, "Chams")
    uiRegistry["ESP_Chams"] = addCheckbox(chams, "Enabled", Config.ESP_Chams, function(v) Config.ESP_Chams = v end, Theme.AccentPink)
    local tracer = createGroupbox(espRight, "Tracer")
    uiRegistry["ESP_Tracers"] = addCheckbox(tracer, "Enabled", Config.ESP_Tracers, function(v) Config.ESP_Tracers = v end, Theme.AccentPinkLight)
    local target = createGroupbox(espRight, "Target Visualizer")
    uiRegistry["TargetVisualizer"] = addCheckbox(target, "Enabled", Config.TargetVisualizer, function(v) Config.TargetVisualizer = v end)
    uiRegistry["TargetVisualizerHUD"] = addCheckbox(target, "Target HUD Card", Config.TargetVisualizerHUD, function(v) Config.TargetVisualizerHUD = v end)
    uiRegistry["TargetVisualizerPath"] = addCheckbox(target, "Ground Path & Arrows", Config.TargetVisualizerPath, function(v) Config.TargetVisualizerPath = v end)
    uiRegistry["VisualizerArrowSpacing"] = addSlider(target, "Arrow Spacing", 5, 25, Config.VisualizerArrowSpacing, "%d studs", function(v) Config.VisualizerArrowSpacing = v end)
    uiRegistry["VisualizerArrowSpeed"] = addSlider(target, "Arrow Speed", 5, 30, Config.VisualizerArrowSpeed, "%d spd", function(v) Config.VisualizerArrowSpeed = v end)
    local selectLeft = PanelUI.merge({espMain, crosshair, misc}, {"ESP", "Crosshair", "Misc"}, function(index)
        box.Parent.Visible = index == 1
        name.Parent.Visible = index == 1
    end)
     
    PanelUI.reveal[box] = function() selectLeft(1) end
    PanelUI.reveal[name] = function() selectLeft(1) end
    local selectRight = PanelUI.merge({indicators, target}, {"Indicators", "Target"}, function(index)
        health.Parent.Visible = index == 1
        chams.Parent.Visible = index == 1
        tracer.Parent.Visible = index == 1
    end)
    for _, pane in ipairs({health, chams, tracer}) do
        PanelUI.reveal[pane] = function() selectRight(1) end
    end
end

local pageMove = tabPages["move"]
local moveLeft = pageMove:FindFirstChild("LeftCol")
local moveRight = pageMove:FindFirstChild("RightCol")

local gbMovement = createGroupbox(moveLeft, "Ground Movement")
uiRegistry["SpeedHack"] = addCheckbox(gbMovement, "Speed hack", Config.SpeedHack, function(v) Config.SpeedHack = v end)
uiRegistry["SpeedValue"] = addSlider(gbMovement, "WalkSpeed", 16, 120, Config.SpeedValue, "%d ws", function(v) Config.SpeedValue = v end)
uiRegistry["InfiniteJump"] = addCheckbox(gbMovement, "Infinite jump", Config.InfiniteJump, function(v) Config.InfiniteJump = v end)
uiRegistry["BunnyHop"] = addCheckbox(gbMovement, "Bunny hop", Config.BunnyHop, function(v) Config.BunnyHop = v end)

local gbAirMovement = createGroupbox(moveRight, "Flight & Collision")
uiRegistry["FlyHack"] = addCheckbox(gbAirMovement, "Fly hack", Config.FlyHack, function(v) Config.FlyHack = v end)
uiRegistry["FlySpeed"] = addSlider(gbAirMovement, "Fly speed", 20, 150, Config.FlySpeed, "%d spd", function(v) Config.FlySpeed = v end)
uiRegistry["Noclip"] = addCheckbox(gbAirMovement, "Noclip", Config.Noclip, function(v) Config.Noclip = v end)

 
do
    local identity = createGroupbox(moveLeft, "Anonymous Mode")
    identity.Parent.LayoutOrder = 0
    uiRegistry["AnonymousMode"] = addCheckbox(identity, "Enabled (local only)", Config.AnonymousMode, function(v)
        Config.AnonymousMode = v
        if uiRegistry.AnonymousAlias then Config.AnonymousAlias = uiRegistry.AnonymousAlias.Get() end
        Config.AnonymousAlias = LocalIdentity.alias()
        LocalIdentity.refresh()
    end)
    uiRegistry["AnonymousAlias"] = addTextbox(identity, "Custom Display Name", Config.AnonymousAlias, "Up to 24 letters / numbers", function(v)
        Config.AnonymousAlias = v
        Config.AnonymousAlias = LocalIdentity.alias()
        if Config.AnonymousMode then LocalIdentity.refresh() end
    end)
    local function apply()
        Config.AnonymousAlias = uiRegistry.AnonymousAlias.Get()
        Config.AnonymousAlias = LocalIdentity.alias()
        for _, key in ipairs({"AnonymousShirt", "AnonymousPants"}) do
            local text = tostring(uiRegistry[key].Get()):match("^%s*(.-)%s*$")
            if text ~= "" and not LocalIdentity.template(text) then
                LocalIdentity.setStatus("Invalid clothing ID. Use a numeric template ID, or leave blank.", true)
                return
            end
            Config[key] = text
        end
        Config.AnonymousAppearance = uiRegistry.AnonymousAppearance.Get()
        Config.AnonymousHideAccessories = uiRegistry.AnonymousHideAccessories.Get()
        uiRegistry.AnonymousMode.Set(true)
        if LocalIdentity.failed then
            ShowNotification("oregonnscripts", LocalIdentity.status, "ERROR", 5)
        else
            ShowNotification("oregonnscripts", LocalIdentity.status, "SUCCESS", 3)
        end
    end
    local applyButton = addButton(identity, "Apply Name & Look", apply)
    applyButton.Name = "ApplyLocalIdentity"
    local status = Instance.new("TextLabel")
    status.Name = "LocalIdentityStatus"
    status.Size = UDim2.new(1, 0, 0, 42)
    status.LayoutOrder = 9000
    status.BackgroundTransparency = 1
    status.Font = MainFont
    status.Text = LocalIdentity.status
    status.TextSize = 10
    status.TextColor3 = Theme.AccentPinkLight
    status.TextWrapped = true
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.ZIndex = 17
    status.Parent = identity
    LocalIdentity.statusLabel = status

    local appearance = createGroupbox(moveRight, "Local Appearance")
    appearance.Parent.LayoutOrder = 0
    uiRegistry["AnonymousAppearance"] = addDropdown(appearance, "Outfit Preset", {"Original", "Baby Blue", "Mint Green", "Midnight"}, 2, function(v)
        Config.AnonymousAppearance = v
        if Config.AnonymousMode then LocalIdentity.refresh() end
    end)
    uiRegistry["AnonymousHideAccessories"] = addCheckbox(appearance, "Hide Accessories", Config.AnonymousHideAccessories, function(v)
        Config.AnonymousHideAccessories = v
        if Config.AnonymousMode then LocalIdentity.refresh() end
    end)
    local function setClothing(key, value)
        local text = tostring(value or ""):match("^%s*(.-)%s*$")
        if text ~= "" and not LocalIdentity.template(text) then
            LocalIdentity.setStatus("Invalid clothing ID. Use a numeric template ID, or leave blank.", true)
            return
        end
        Config[key] = text
        if Config.AnonymousMode then LocalIdentity.refresh() end
    end
    uiRegistry["AnonymousShirt"] = addTextbox(appearance, "Shirt Template ID", Config.AnonymousShirt, "Optional — leave blank for preset", function(v)
        setClothing("AnonymousShirt", v)
    end)
    uiRegistry["AnonymousPants"] = addTextbox(appearance, "Pants Template ID", Config.AnonymousPants, "Optional — leave blank for preset", function(v)
        setClothing("AnonymousPants", v)
    end)
    addButton(appearance, "View in Third Person", function()
        if uiRegistry.ThirdPerson then uiRegistry.ThirdPerson.Set(true) end
        setMenuVisible(false)
    end)
    addButton(appearance, "Disable & Restore Appearance", function()
        uiRegistry.AnonymousMode.Set(false)
    end)
end

local pageGuns = tabPages["guns"]
local gunsLeft = pageGuns:FindFirstChild("LeftCol")
local gunsRight = pageGuns:FindFirstChild("RightCol")

local gbGunMods = createGroupbox(gunsLeft, "Weapon Mechanics")
uiRegistry["NoRecoil"] = addCheckbox(gbGunMods, "No recoil", Config.NoRecoil, function(v)
    Config.NoRecoil = v
    ApplyWeaponModifications()
end)
uiRegistry["NoSpread"] = addCheckbox(gbGunMods, "No spread", Config.NoSpread, function(v)
    Config.NoSpread = v
    ApplyWeaponModifications()
end)
uiRegistry["FastReload"] = addCheckbox(gbGunMods, "Fast reload", Config.FastReload, function(v)
    Config.FastReload = v
    ApplyWeaponModifications()
end)
uiRegistry["RapidFire"] = addCheckbox(gbGunMods, "Rapid fire", Config.RapidFire, function(v)
    Config.RapidFire = v
    ApplyWeaponModifications()
end)
uiRegistry["InstantEquip"] = addCheckbox(gbGunMods, "Instant weapon equip", Config.InstantEquip, function(v)
    Config.InstantEquip = v
    ApplyWeaponModifications()
end)

local gbGunExtras = createGroupbox(gunsRight, "Weapon Features")
uiRegistry["AutomaticGuns"] = addCheckbox(gbGunExtras, "Automatic mode", Config.AutomaticGuns, function(v) Config.AutomaticGuns = v end)
uiRegistry["InfiniteAmmo"] = addCheckbox(gbGunExtras, "Infinite ammo", Config.InfiniteAmmo, function(v)
    Config.InfiniteAmmo = v
    ApplyWeaponModifications()
end)

local pageSkins = tabPages["skins"]
local skinsLeft = pageSkins:FindFirstChild("LeftCol")
local skinsRight = pageSkins:FindFirstChild("RightCol")

local gbSkins = createGroupbox(skinsLeft, "Weapon Customizer")
uiRegistry["UnlockAllSkins"] = addCheckbox(gbSkins, "Unlock all skins (Client)", Config.UnlockAllSkins, function(v)
    Config.UnlockAllSkins = v
    if v then
        UnlockAllCosmeticsClientSide()
        ShowNotification("oregonnscripts", "All 1,249 skins & cosmetics unlocked client-side.", "SUCCESS", 3)
    end
end)

uiRegistry["SelectedCategory"] = addDropdown(gbSkins, "Category", {"Primary", "Secondary", "Melee", "Utility"}, 1, function(v)
    Config.SelectedCategory = v
end)

uiRegistry["SelectedWeapon"] = addDropdown(gbSkins, "Weapon", {
    "Assault Rifle", "Sniper", "Shotgun", "Katana", "Revolver", "RPG",
    "Submachine Gun", "Hand Gun", "Minigun", "Grenade Launcher", "Energy Rifle", "Bow"
}, 1, function(v)
    Config.SelectedWeapon = v
end)

uiRegistry["SelectedWrap"] = addDropdown(gbSkins, "Equipped Wrap", {
    "Liquid Gold", "Mainframe", "Obsidian", "Scribble", "Vexed", "Igneous",
    "Candy Apple", "Red Rubber", "Tidal", "Purple", "Popsicle", "Lighthouse",
    "Celtic", "Empress", "PixelBlight", "Sunset", "Money", "Portal", "Venom", "Default"
}, 1, function(v)
    Config.SelectedWrap = v
end)

uiRegistry["SelectedCharm"] = addDropdown(gbSkins, "Equipped Charm", {
    "Dice", "Kashy", "Jolly Hat", "Devious Pumpkin", "Chibi Grenade",
    "Lucky Horseshoe", "Bat Daggers", "Pirate Hook", "Mini Present", "None"
}, 1, function(v)
    Config.SelectedCharm = v
end)

uiRegistry["SelectedFinisher"] = addDropdown(gbSkins, "Equipped Finisher", {
    "Flop", "Rising Star", "Gingerbreadify", "Warp Sickness", "Freeze",
    "Batsplosion", "Northern Light Show", "Supernova", "Orbital Strike", "Disintegrate", "None"
}, 1, function(v)
    Config.SelectedFinisher = v
end)

addButton(gbSkins, "Apply Skin to Weapon", function()
    UnlockAllCosmeticsClientSide()
    ApplySelectedCosmeticsClientSide(Config.SelectedWeapon, Config.SelectedWrap, Config.SelectedCharm, Config.SelectedFinisher)
    ShowNotification("oregonnscripts", "Equipped " .. tostring(Config.SelectedWrap) .. " on " .. tostring(Config.SelectedWeapon), "SUCCESS", 2.5)
end)

addButton(gbSkins, "Apply Skin to ALL Weapons", function()
    UnlockAllCosmeticsClientSide()
    ApplySelectedCosmeticsClientSide("All", Config.SelectedWrap, Config.SelectedCharm, Config.SelectedFinisher)
    ShowNotification("oregonnscripts", "Equipped " .. tostring(Config.SelectedWrap) .. " on ALL weapons!", "SUCCESS", 2.5)
end)

local gbViewModel = createGroupbox(skinsRight, "Viewmodel & Render")
uiRegistry["RainbowGunSkin"] = addCheckbox(gbViewModel, "Rainbow gun skin", Config.RainbowGunSkin, function(v) Config.RainbowGunSkin = v end)
uiRegistry["WeaponChams"] = addCheckbox(gbViewModel, "Weapon chams & glow", Config.WeaponChams, function(v) Config.WeaponChams = v end)
uiRegistry["CustomViewModelFOV"] = addCheckbox(gbViewModel, "Custom Viewmodel FOV", Config.CustomViewModelFOV, function(v) Config.CustomViewModelFOV = v end)
uiRegistry["ViewModelFOVValue"] = addSlider(gbViewModel, "Viewmodel FOV", 50, 110, Config.ViewModelFOVValue, "%d°", function(v) Config.ViewModelFOVValue = v end)
uiRegistry["ViewModelXOffset"] = addSlider(gbViewModel, "Viewmodel X offset", -30, 30, Config.ViewModelXOffset, "%d/30", function(v) Config.ViewModelXOffset = v end)
uiRegistry["ViewModelYOffset"] = addSlider(gbViewModel, "Viewmodel Y offset", -30, 30, Config.ViewModelYOffset, "%d/30", function(v) Config.ViewModelYOffset = v end)
uiRegistry["ViewModelZOffset"] = addSlider(gbViewModel, "Viewmodel Z offset", -30, 30, Config.ViewModelZOffset, "%d/30", function(v) Config.ViewModelZOffset = v end)
uiRegistry["HideViewModel"] = addCheckbox(gbViewModel, "Hide viewmodel", Config.HideViewModel, function(v) Config.HideViewModel = v end)

local pageWorld = tabPages["world"]
local worldLeft = pageWorld:FindFirstChild("LeftCol")
local worldRight = pageWorld:FindFirstChild("RightCol")

local gbWorldMods = createGroupbox(worldLeft, "World & Visuals")
uiRegistry["Fullbright"] = addCheckbox(gbWorldMods, "Fullbright", Config.Fullbright, function(v)
    Config.Fullbright = v
    if v then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)
uiRegistry["NoFog"] = addCheckbox(gbWorldMods, "No fog", Config.NoFog, function(v)
    Config.NoFog = v
    if v then
        Lighting.FogEnd = 1000000
    else
        Lighting.FogEnd = 1000
    end
end)
uiRegistry["CustomFOV"] = addCheckbox(gbWorldMods, "Custom FOV", Config.CustomFOV, function(v)
    Config.CustomFOV = v
    if v then Camera.FieldOfView = Config.FOVValue end
end)
uiRegistry["FOVValue"] = addSlider(gbWorldMods, "FOV Angle", 70, 120, Config.FOVValue, "%d°", function(v)
    Config.FOVValue = v
    if Config.CustomFOV then Camera.FieldOfView = v end
end)

local gbWorldAudio = createGroupbox(worldRight, "Effects & Sounds")
uiRegistry["BulletTracers"] = addCheckbox(gbWorldAudio, "Bullet tracers", Config.BulletTracers, function(v) Config.BulletTracers = v end)
uiRegistry["HitSound"] = addDropdown(gbWorldAudio, "Hit sound", {"Off", "Skeet", "Rust", "Ding"}, 1, function(v) Config.HitSound = v end)

local pageView = tabPages["view"]
local viewLeft = pageView:FindFirstChild("LeftCol")
local viewRight = pageView:FindFirstChild("RightCol")

local gbView = createGroupbox(viewLeft, "Third-Person")
uiRegistry["ThirdPerson"] = addCheckbox(gbView, "Third-person mode", Config.ThirdPerson, function(v)
    Config.ThirdPerson = v
end)
uiRegistry["ThirdPersonDist"] = addSlider(gbView, "Third-person distance", 5, 30, Config.ThirdPersonDist, "%d studs", function(v) Config.ThirdPersonDist = v end)

local gbFreecam = createGroupbox(viewRight, "Freecam")
uiRegistry["Freecam"] = addCheckbox(gbFreecam, "Freecam mode", Config.Freecam, function(v) Config.Freecam = v end)
uiRegistry["FreecamSpeed"] = addSlider(gbFreecam, "Freecam speed", 10, 100, Config.FreecamSpeed, "%d spd", function(v) Config.FreecamSpeed = v end)

local function SerializeConfig()
    local tbl = {}
    for k, v in pairs(Config) do
        if typeof(v) == "EnumItem" then
            tbl[k] = { __type = "EnumItem", enumType = tostring(v.EnumType), name = v.Name }
        elseif typeof(v) == "Color3" then
            tbl[k] = { __type = "Color3", r = v.R, g = v.G, b = v.B }
        elseif typeof(v) == "Vector3" then
            tbl[k] = { __type = "Vector3", x = v.X, y = v.Y, z = v.Z }
        else
            tbl[k] = v
        end
    end
    return tbl
end

local function DeserializeConfig(data)
    local res = {}
    for k, v in pairs(data) do
        if type(v) == "table" and v.__type == "EnumItem" then
            local enumName = tostring(v.enumType or ""):gsub("^Enum%.", "")
            local ok, enumItem = pcall(function()
                return Enum[enumName][v.name]
            end)
            if ok and enumItem then res[k] = enumItem end
        elseif type(v) == "table" and v.__type == "Color3" then
            res[k] = Color3.new(v.r, v.g, v.b)
        elseif type(v) == "table" and v.__type == "Vector3" then
            res[k] = Vector3.new(v.x, v.y, v.z)
        else
            res[k] = v
        end
    end
    return res
end

local ProfileSystem = {
    startupDisabled = {
        AnonymousMode = true,
        Aimbot = true,
        AimbotFOVCircle = true,
        SilentAim = true,
        Ragebot = true,
        Autoplay = true,
        AutoRespawn = true,
        AutoQueue = true,
        AutoVoteMaps = true,
        AutoBanWeapons = true,
        AutoLoadout = true,
        AntiAim = true,
        HackerDetector = true,
        HackerAutoLoad = true,
        ModDetector = true,
        AutoPickup = true,
        ESP_Master = true,
        ESP_FOV = true,
        ESP_Tripmines = true,
        TargetVisualizer = true,
        TargetVisualizerHUD = true,
        SpeedHack = true,
        FlyHack = true,
        InfiniteJump = true,
        BunnyHop = true,
        Noclip = true,
        NoRecoil = true,
        NoSpread = true,
        FastReload = true,
        RapidFire = true,
        InstantEquip = true,
        AutomaticGuns = true,
        InfiniteAmmo = true,
        UnlockAllSkins = true,
        RainbowGunSkin = true,
        WeaponChams = true,
        CustomViewModelFOV = true,
        HideViewModel = true,
        Fullbright = true,
        NoFog = true,
        CustomFOV = true,
        BulletTracers = true,
        ThirdPerson = true,
        Freecam = true,
        MobileToggle = true,
    },
    current = "default",
    autoload = "default",
    names = { "default", "rage" },
    profiles = {},
    nameInput = nil,
    dropdown = nil,
    autoLoadLabel = nil,
    defaultProfiles = {
        ["default"] = {
            Aimbot = false,
            TeamCheck = true,
            AimbotDisableReloading = true,
            AimbotFOV = 120,
            AimbotFOVCircle = false,
            AimbotKey = Enum.UserInputType.MouseButton2,
            AimbotKeyMode = "Hold",
            AimbotPart = "Closest",
            AimbotScopeOnly = false,
            AimbotSmoothing = 0.28,
            AimbotVisibleOnly = true,
            AntiAim = false,
            AntiAimMode = "Jitter",
            AntiAimSpeed = 10,
            AutoBanWeapons = false,
            AutoLoadout = true,
            AutoPickup = false,
            AutoQueue = false,
            AutoRespawn = false,
            AutoVoteMaps = false,
            AutomaticGuns = false,
            Autoplay = false,
            AutoplayDistance = 18,
            BulletTracers = false,
            BunnyHop = false,
            CorrectLockedShots = true,
            ContinuousTargeting = true,
            CustomFOV = false,
            CustomViewModelFOV = false,
            ESP_Boxes = true,
            ESP_Chams = false,
            ESP_Distance = true,
            ESP_EnemyOnly = true,
            ESP_FOV = true,
            ESP_HeadDot = true,
            ESP_HealthBar = true,
            ESP_Lobby = true,
            ESP_Master = true,
            ESP_MaxDistance = 500,
            ESP_Names = true,
            ESP_Skeleton = true,
            ESP_Tracers = false,
            ESP_Tripmines = true,
            ESP_Weapon = true,
            EnabledMaps = "Arena, Crossroads",
            FastReload = false,
            FlyHack = false,
            FlySpeed = 50,
            FOVValue = 90,
            Freecam = false,
            FreecamSpeed = 40,
            Fullbright = false,
            HackerAutoLoad = true,
            HackerDetector = true,
            HackerProfile = "rage",
            HideViewModel = false,
            HitSound = "Skeet",
            InfiniteAmmo = false,
            InfiniteJump = false,
            InstantCameraLock = false,
            InstantEquip = false,
            LoadoutOnlySelected = false,
            MapPriority = "Arena, Onyx, Crossroads",
            MenuKey = Enum.KeyCode.RightControl,
            MinGroupRank = 200,
            ModDetector = true,
            ModFriendList = "name1, name2",
            ModUsernames = "name1, name2",
            NoFog = true,
            NoRecoil = true,
            NoSpread = true,
            Noclip = false,
            NotifyHackers = true,
            NotifyMods = true,
            PickupRadius = 25,
            QueueMode = "1v1",
            Ragebot = false,
            RagebotAutoShoot = false,
            RagebotTargetPriority = "Distance",
            RagebotTargetStrafe = false,
            RagebotWallbang = true,
            RainbowGunSkin = false,
            RapidFire = false,
            SecondBanPriority = "Grenade Launcher, Minigun, RPG",
            SelectedCategory = "Primary",
            SelectedCharm = "Dice",
            SelectedFinisher = "Gingerbreadify",
            SelectedWeapon = "Assault Rifle",
            SelectedWrap = "Liquid Gold",
            SilentAim = true,
            SilentFOV = 242,
            SilentHeadChance = 59,
            SilentHitChance = 78,
            SilentIgnoreDeflecting = true,
            SilentIgnoreShielded = true,
            SilentKey = Enum.KeyCode.C,
            SilentKeyMode = "Always",
            SilentTargetPart = "Head",
            SilentVisibleOnly = true,
            SilentVulnerableOnly = true,
            SpeedDuration = 0.75,
            SpeedHack = false,
            SpeedThreshold = 180,
            SpeedValue = 49,
            TargetStrafeRadius = 14,
            TargetStrafeSpeed = 6,
            TargetVisualizer = true,
            TargetVisualizerHUD = true,
            TargetVisualizerPath = true,
            ThirdPerson = false,
            ThirdPersonDist = 12,
            TrackThroughWalls = true,
            UnlockAllSkins = false,
            ViewModelFOVValue = 70,
            ViewModelXOffset = 0,
            ViewModelYOffset = 0,
            ViewModelZOffset = 0,
            VisualizerArrowSpacing = 10,
            VisualizerArrowSpeed = 14,
            WeaponBanPriority = "Grenade Launcher, Minigun, RPG",
            WeaponChams = false,
        },
        ["rage"] = {
            Aimbot = false,
            TeamCheck = true,
            AimbotDisableReloading = true,
            AimbotFOV = 120,
            AimbotFOVCircle = false,
            AimbotKey = Enum.UserInputType.MouseButton2,
            AimbotKeyMode = "Hold",
            AimbotPart = "Closest",
            AimbotScopeOnly = false,
            AimbotSmoothing = 0.28,
            AimbotVisibleOnly = true,
            AntiAim = false,
            AntiAimMode = "Jitter",
            AntiAimSpeed = 10,
            AutoBanWeapons = false,
            AutoLoadout = false,
            AutoPickup = false,
            AutoQueue = false,
            AutoRespawn = false,
            AutoVoteMaps = false,
            AutomaticGuns = false,
            Autoplay = true,
            AutoplayDistance = 18,
            BulletTracers = true,
            BunnyHop = true,
            CorrectLockedShots = true,
            ContinuousTargeting = true,
            CustomFOV = false,
            CustomViewModelFOV = false,
            ESP_Boxes = true,
            ESP_Chams = true,
            ESP_Distance = true,
            ESP_EnemyOnly = true,
            ESP_FOV = true,
            ESP_HeadDot = true,
            ESP_HealthBar = true,
            ESP_Lobby = true,
            ESP_Master = true,
            ESP_MaxDistance = 500,
            ESP_Names = true,
            ESP_Skeleton = true,
            ESP_Tracers = false,
            ESP_Tripmines = true,
            ESP_Weapon = true,
            EnabledMaps = "Arena, Crossroads",
            FastReload = false,
            FlyHack = false,
            FlySpeed = 50,
            FOVValue = 90,
            Freecam = false,
            FreecamSpeed = 40,
            Fullbright = false,
            HackerAutoLoad = true,
            HackerDetector = true,
            HackerProfile = "rage",
            HideViewModel = false,
            HitSound = "Skeet",
            InfiniteAmmo = false,
            InfiniteJump = false,
            InstantCameraLock = false,
            InstantEquip = false,
            LoadoutOnlySelected = false,
            MapPriority = "Arena, Onyx, Crossroads",
            MenuKey = Enum.KeyCode.RightControl,
            MinGroupRank = 200,
            ModDetector = true,
            ModFriendList = "name1, name2",
            ModUsernames = "name1, name2",
            NoFog = true,
            NoRecoil = true,
            NoSpread = true,
            Noclip = false,
            NotifyHackers = true,
            NotifyMods = true,
            PickupRadius = 25,
            QueueMode = "1v1",
            Ragebot = true,
            RagebotAutoShoot = true,
            RagebotTargetPriority = "Distance",
            RagebotTargetStrafe = true,
            RagebotWallbang = true,
            RainbowGunSkin = false,
            RapidFire = false,
            SecondBanPriority = "Grenade Launcher, Minigun, RPG",
            SelectedCategory = "Primary",
            SelectedCharm = "Dice",
            SelectedFinisher = "Gingerbreadify",
            SelectedWeapon = "Assault Rifle",
            SelectedWrap = "Liquid Gold",
            SilentAim = true,
            SilentFOV = 400,
            SilentHeadChance = 100,
            SilentHitChance = 100,
            SilentIgnoreDeflecting = true,
            SilentIgnoreShielded = true,
            SilentKey = Enum.KeyCode.C,
            SilentKeyMode = "Always",
            SilentTargetPart = "Head",
            SilentVisibleOnly = true,
            SilentVulnerableOnly = true,
            SpeedDuration = 0.75,
            SpeedHack = true,
            SpeedThreshold = 180,
            SpeedValue = 49,
            TargetStrafeRadius = 14,
            TargetStrafeSpeed = 6,
            TargetVisualizer = true,
            TargetVisualizerHUD = true,
            TargetVisualizerPath = true,
            ThirdPerson = false,
            ThirdPersonDist = 12,
            TrackThroughWalls = true,
            UnlockAllSkins = false,
            ViewModelFOVValue = 70,
            ViewModelXOffset = 0,
            ViewModelYOffset = 0,
            ViewModelZOffset = 0,
            VisualizerArrowSpacing = 10,
            VisualizerArrowSpeed = 14,
            WeaponBanPriority = "Grenade Launcher, Minigun, RPG",
            WeaponChams = false,
        }
    }
}

function ProfileSystem.readStore()
    local ok, res = pcall(function()
        if readfile and isfile and isfile("paragon_ripped_config.json") then
            local raw = readfile("paragon_ripped_config.json")
            return HttpService:JSONDecode(raw)
        end
        return nil
    end)
    if ok and type(res) == "table" then
        if type(res.profiles) == "table" then
            ProfileSystem.profiles = res.profiles
            ProfileSystem.autoload = tostring(res.autoload or "default")
        else
            ProfileSystem.profiles = { ["default"] = res }
            ProfileSystem.autoload = "default"
        end
    else
        ProfileSystem.profiles = {}
        ProfileSystem.autoload = "default"
    end

    for pName, pData in pairs(ProfileSystem.defaultProfiles) do
        if not ProfileSystem.profiles[pName] then
            local copy = {}
            for k, v in pairs(pData) do copy[k] = v end
            ProfileSystem.profiles[pName] = copy
        end
    end

    local list = {}
    for name, _ in pairs(ProfileSystem.profiles) do
        table.insert(list, tostring(name))
    end
    table.sort(list)
    if #list == 0 then
        list = { "default", "rage" }
    end
    ProfileSystem.names = list

    local found = false
    for _, name in ipairs(ProfileSystem.names) do
        if name == ProfileSystem.autoload then
            found = true
            break
        end
    end
    if not found then
        ProfileSystem.autoload = "default"
    end
    ProfileSystem.current = ProfileSystem.autoload

    if not (isfile and isfile("paragon_ripped_config.json")) then
        ProfileSystem.writeStore()
    end
end

function ProfileSystem.writeStore()
    if not writefile then return false end
    local store = {
        autoload = ProfileSystem.autoload or "default",
        profiles = ProfileSystem.profiles
    }
    local ok = pcall(function()
        local json = HttpService:JSONEncode(store)
        writefile("paragon_ripped_config.json", json)
    end)
    return ok
end

function ProfileSystem.applyProfile(pName, notify, startDisabled)
    pName = tostring(pName or ProfileSystem.current or "default")
    local data = ProfileSystem.profiles[pName]
    if not data then
        if notify then
            ShowNotification("oregonnscripts", "Profile not found: " .. pName, "WARN", 2.5)
        end
        return false
    end

    local res = DeserializeConfig(data)
    if startDisabled then
         
         
        for key in pairs(ProfileSystem.startupDisabled) do res[key] = false end
        res.HitSound = "Off"
        res.ViewModelXOffset = 0
        res.ViewModelYOffset = 0
        res.ViewModelZOffset = 0
    end
     
    for k, v in pairs(res) do Config[k] = v end
    for k, v in pairs(res) do
        local control = uiRegistry[k]
        if control then
            if startDisabled and type(v) == "boolean" and control.Sync then
                control.Sync(v)
            elseif control.Set then
                pcall(function() control.Set(v) end)
            end
        end
    end
     
    for _, key in ipairs({"AimbotTeamCheck", "SilentTeamCheck", "RagebotTeamCheck"}) do
        local control = uiRegistry[key]
        if control and control.Sync then control.Sync(Config.TeamCheck) end
    end
    ApplyWeaponModifications()
    if Config.UnlockAllSkins then UnlockAllCosmeticsClientSide() end

    ProfileSystem.current = pName
    if ProfileSystem.nameInput and ProfileSystem.nameInput.Set then
        ProfileSystem.nameInput.Set(pName)
    end
    if ProfileSystem.dropdown and ProfileSystem.dropdown.Set then
        ProfileSystem.dropdown.Set(pName)
    end
    if notify then
        ShowNotification("oregonnscripts", "Loaded profile: " .. pName, "SUCCESS", 2.5)
    end
    return true
end

function ProfileSystem.saveProfile(pName)
    local rawName = pName or (ProfileSystem.nameInput and ProfileSystem.nameInput.Get and ProfileSystem.nameInput.Get())
    if not rawName or rawName:gsub("%s+", "") == "" then
        rawName = ProfileSystem.current or "default"
    end
    local cleanName = rawName:match("^%s*(.-)%s*$")
    ProfileSystem.profiles[cleanName] = SerializeConfig()
    ProfileSystem.current = cleanName

    local list = {}
    for name, _ in pairs(ProfileSystem.profiles) do
        table.insert(list, tostring(name))
    end
    table.sort(list)
    ProfileSystem.names = list

    ProfileSystem.writeStore()
    if ProfileSystem.dropdown and ProfileSystem.dropdown.SetOptions then
        ProfileSystem.dropdown.SetOptions(ProfileSystem.names, cleanName)
    end
    if ProfileSystem.nameInput and ProfileSystem.nameInput.Set then
        ProfileSystem.nameInput.Set(cleanName)
    end
    ShowNotification("oregonnscripts", "Saved profile: " .. cleanName, "SUCCESS", 2.5)
end

function ProfileSystem.setAutoload(pName)
    local target = pName or ProfileSystem.current or "default"
    if not ProfileSystem.profiles[target] then
        ProfileSystem.profiles[target] = SerializeConfig()
    end
    ProfileSystem.autoload = target
    ProfileSystem.writeStore()
    if ProfileSystem.autoLoadLabel then
        ProfileSystem.autoLoadLabel.Text = "Startup preset: " .. target .. " (features off)"
    end
    ShowNotification("oregonnscripts", "Startup preset: " .. target .. "; main features stay off.", "SUCCESS", 2.5)
end

function ProfileSystem.deleteProfile(pName)
    local target = pName or ProfileSystem.current
    if #ProfileSystem.names <= 1 then
        ShowNotification("oregonnscripts", "Cannot delete only remaining profile.", "WARN", 2.5)
        return
    end

    ProfileSystem.profiles[target] = nil
    local list = {}
    for name, _ in pairs(ProfileSystem.profiles) do
        table.insert(list, tostring(name))
    end
    table.sort(list)
    ProfileSystem.names = list

    if ProfileSystem.autoload == target then
        ProfileSystem.autoload = ProfileSystem.names[1]
    end
    ProfileSystem.current = ProfileSystem.names[1]

    ProfileSystem.writeStore()
    if ProfileSystem.dropdown and ProfileSystem.dropdown.SetOptions then
        ProfileSystem.dropdown.SetOptions(ProfileSystem.names, ProfileSystem.current)
    end
    if ProfileSystem.nameInput and ProfileSystem.nameInput.Set then
        ProfileSystem.nameInput.Set(ProfileSystem.current)
    end
    if ProfileSystem.autoLoadLabel then
        ProfileSystem.autoLoadLabel.Text = "Startup preset: " .. ProfileSystem.autoload .. " (features off)"
    end
    ProfileSystem.applyProfile(ProfileSystem.current, false)
    ShowNotification("oregonnscripts", "Deleted profile: " .. target, "INFO", 2.5)
end

ProfileSystem.readStore()

local pageConfig = tabPages["config"]
local cfgLeft = pageConfig:FindFirstChild("LeftCol")
local cfgRight = pageConfig:FindFirstChild("RightCol")

local gbConfig = createGroupbox(cfgLeft, "Profiles")

ProfileSystem.nameInput = addTextbox(gbConfig, "Profile name", ProfileSystem.current, "Profile name...", function(txt)
    ProfileSystem.current = txt
end)

ProfileSystem.dropdown = addDropdown(gbConfig, "Select profile", ProfileSystem.names, 1, function(selected)
    ProfileSystem.current = selected
    if ProfileSystem.nameInput and ProfileSystem.nameInput.Set then
        ProfileSystem.nameInput.Set(selected)
    end
end)

addButton(gbConfig, "Save profile", function()
    ProfileSystem.saveProfile()
end)

addButton(gbConfig, "Load profile", function()
    ProfileSystem.applyProfile(ProfileSystem.current, true)
end)

addButton(gbConfig, "Use values on startup (features off)", function()
    ProfileSystem.setAutoload(ProfileSystem.current)
end)

addButton(gbConfig, "Delete profile", function()
    ProfileSystem.deleteProfile(ProfileSystem.current)
end)

ProfileSystem.autoLoadLabel = Instance.new("TextLabel")
ProfileSystem.autoLoadLabel.Size = UDim2.new(1, 0, 0, 30)
ProfileSystem.autoLoadLabel.TextWrapped = true
ProfileSystem.autoLoadLabel.TextSize = 10
ProfileSystem.autoLoadLabel.BackgroundTransparency = 1
ProfileSystem.autoLoadLabel.Font = MainFont
ProfileSystem.autoLoadLabel.Text = "Startup preset: " .. ProfileSystem.autoload .. " (features off)"
ProfileSystem.autoLoadLabel.TextColor3 = Theme.AccentPinkLight
ProfileSystem.autoLoadLabel.TextSize = 11.5
ProfileSystem.autoLoadLabel.TextXAlignment = Enum.TextXAlignment.Left
ProfileSystem.autoLoadLabel.ZIndex = 17
ProfileSystem.autoLoadLabel.Parent = gbConfig

addButton(gbConfig, "Unload script", UnloadScript)

local gbShortcuts = createGroupbox(cfgRight, "Keybinds & Info")
local kbMenu = Instance.new("TextLabel")
kbMenu.Size = UDim2.new(1, 0, 0, 16)
kbMenu.BackgroundTransparency = 1
kbMenu.Font = MainFont
kbMenu.Text = "Menu Toggle: RightControl"
kbMenu.TextColor3 = Theme.TextWhite
kbMenu.TextSize = 12
kbMenu.TextXAlignment = Enum.TextXAlignment.Left
kbMenu.ZIndex = 17
kbMenu.Parent = gbShortcuts


pcall(function()
    ProfileSystem.applyProfile(ProfileSystem.autoload, false, true)
end)

 
 
Config.TargetVisualizerHUD = false
if uiRegistry["TargetVisualizerHUD"] then
    uiRegistry["TargetVisualizerHUD"].Set(false)
end
if TargetVis.hudFrame then
    TargetVis.hudFrame.Visible = false
end
LocalIdentity.refresh()

 
 
do
    local function firstContent(pageID)
        local col = tabPages[pageID]:FindFirstChild("LeftCol")
        local first
        for _, child in ipairs(col:GetChildren()) do
            if child:IsA("Frame") and (not first or child.LayoutOrder < first.LayoutOrder) then first = child end
        end
        return first and first:FindFirstChild("Content")
    end
    local combatPages = {"aim", "silent", "auto"}
    for i, pageID in ipairs(combatPages) do
        PanelUI.strip(firstContent(pageID), {"Aimbot", "Silent Aim", "Automation"}, i, function(index)
            switchTab(combatPages[index])
        end, true)
    end
    local weaponPages = {"guns", "skins"}
    for i, pageID in ipairs(weaponPages) do
        PanelUI.strip(firstContent(pageID), {"Mechanics", "Skins"}, i, function(index)
            switchTab(weaponPages[index])
        end, true)
    end
end

local function setupSearch()
    local items = {}
    for _, pageID in ipairs(tabList) do
        local page = tabPages[pageID]
        for _, colName in ipairs({"LeftCol", "RightCol"}) do
            for _, card in ipairs(page[colName]:GetChildren()) do
                if card:IsA("Frame") then
                    local title = card.Header.TitleLabel.Text
                    for _, pane in ipairs(card:GetChildren()) do
                        if pane:IsA("Frame") and (pane.Name == "Content" or pane:GetAttribute("PanelPane")) then
                            for _, control in ipairs(pane:GetChildren()) do
                                if control:IsA("Frame") or control:IsA("TextButton") then
                                    local label = control:FindFirstChildWhichIsA("TextLabel") or (control:IsA("TextButton") and control)
                                    if label and label.Text ~= "" then
                                        table.insert(items, {pageID = pageID, pane = pane, control = control,
                                            text = label.Text, section = pane:GetAttribute("SearchTitle") or pane:GetAttribute("PanelPane") or title})
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local popup = Instance.new("ScrollingFrame")
    popup.Name = "SearchDropdown"
    popup.BackgroundColor3 = Theme.CardBg
    popup.BorderSizePixel = 0
    popup.CanvasSize = UDim2.new()
    popup.AutomaticCanvasSize = Enum.AutomaticSize.Y
    popup.ScrollBarThickness = 2
    popup.ScrollBarImageColor3 = Theme.BorderPink
    popup.Visible = false
    popup.ZIndex = 1005
    popup.Parent = dropdownOverlay
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 6)
    local layout = Instance.new("UIListLayout", popup)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    local function filter()
        for _, child in ipairs(popup:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
        end
        local query = searchBox.Text:lower():match("^%s*(.-)%s*$")
        if query == "" then popup.Visible = false return end
        local count = 0
        for _, item in ipairs(items) do
            local haystack = (item.text .. " " .. item.section .. " " .. PanelUI.pageLabels[item.pageID]):lower()
            if haystack:find(query, 1, true) and count < 24 then
                count = count + 1
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, 0, 0, 30)
                button.LayoutOrder = count
                button.BackgroundColor3 = Theme.ControlBg
                button.BackgroundTransparency = 0.5
                button.BorderSizePixel = 0
                button.Font = MainFont
                button.Text = "  " .. item.text .. "  ·  " .. item.section
                button.TextSize = 10
                button.TextColor3 = Theme.TextWhite
                button.TextXAlignment = Enum.TextXAlignment.Left
                button.TextTruncate = Enum.TextTruncate.AtEnd
                button.ZIndex = 1006
                button.Parent = popup
                button.Activated:Connect(function()
                    searchBox.Text = ""
                    searchBox:ReleaseFocus()
                    popup.Visible = false
                    switchTab(item.pageID)
                    if PanelUI.reveal[item.pane] then PanelUI.reveal[item.pane]() end
                    task.defer(function()
                        if not isRunning then return end
                        local page = tabPages[item.pageID]
                        local y = item.control.AbsolutePosition.Y - page.AbsolutePosition.Y + page.CanvasPosition.Y - 40
                        page.CanvasPosition = Vector2.new(0, math.clamp(y, 0, math.max(0, page.AbsoluteCanvasSize.Y - page.AbsoluteSize.Y)))
                    end)
                end)
            end
        end
        if count == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, 0, 0, 30)
            empty.BackgroundTransparency = 1
            empty.Text = "No matching settings"
            empty.TextColor3 = Theme.TextMuted
            empty.Font = MainFont
            empty.TextSize = 10
            empty.ZIndex = 1006
            empty.Parent = popup
        end
        local origin = dropdownOverlay.AbsolutePosition
        local area = dropdownOverlay.AbsoluteSize
        local pos = searchBox.AbsolutePosition - origin
        local width = math.min(270, area.X - 16)
        local height = math.min(math.max(1, count) * 32, 180, area.Y - 16)
        local x = math.clamp(pos.X + searchBox.AbsoluteSize.X - width, 8, math.max(8, area.X - width - 8))
        local y = math.clamp(pos.Y + searchBox.AbsoluteSize.Y + 4, 8, math.max(8, area.Y - height - 8))
        popup.Position = UDim2.fromOffset(x, y)
        popup.Size = UDim2.fromOffset(width, height)
        popup.CanvasPosition = Vector2.zero
        popup.Visible = mainWindow.Visible
    end
    table.insert(activeConnections, searchBox:GetPropertyChangedSignal("Text"):Connect(filter))
    table.insert(activeConnections, mainWindow:GetPropertyChangedSignal("Visible"):Connect(function()
        if not mainWindow.Visible then popup.Visible = false end
    end))
    table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input)
        if not popup.Visible then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local point = input.Position
        local function inside(gui)
            local p, size = gui.AbsolutePosition, gui.AbsoluteSize
            return point.X >= p.X and point.X <= p.X + size.X and point.Y >= p.Y and point.Y <= p.Y + size.Y
        end
        if not inside(popup) and not inside(searchBox) then popup.Visible = false end
    end))
end

setupSearch()

local cornerGrip = Instance.new("Frame")
cornerGrip.Name = "CornerGrip"
cornerGrip.Size = UDim2.new(0, 14, 0, 14)
cornerGrip.Position = UDim2.new(1, -15, 1, -15)
cornerGrip.BackgroundTransparency = 1
cornerGrip.BorderSizePixel = 0
cornerGrip.ZIndex = 25
cornerGrip.Parent = mainWindow
cornerGrip.Visible = false

for i = 1, 14 do
    local slice = Instance.new("Frame")
    slice.Name = "Slice_" .. i
    slice.Size = UDim2.new(0, 1, 0, i)
    slice.Position = UDim2.new(0, i - 1, 1, -i)
    slice.BackgroundColor3 = Theme.AccentGreen
    slice.BorderSizePixel = 0
    slice.ZIndex = 26
    slice.Parent = cornerGrip
end

local fovCircleGui = Instance.new("Frame")
fovCircleGui.Name = "FOVCircle"
fovCircleGui.Size = UDim2.new(0, Config.SilentFOV * 2, 0, Config.SilentFOV * 2)
fovCircleGui.Position = UDim2.new(0.5, -Config.SilentFOV, 0.5, -Config.SilentFOV)
fovCircleGui.BackgroundTransparency = 1
fovCircleGui.Visible = Config.ESP_FOV
fovCircleGui.ZIndex = 1
fovCircleGui.Parent = screenGui
table.insert(cleanUpInstances, fovCircleGui)

Instance.new("UICorner", fovCircleGui).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Theme.AccentGreen
fovStroke.Transparency = 0.5
fovStroke.Thickness = 1.2
fovStroke.Parent = fovCircleGui

 
 
do
    local circle = Instance.new("Frame")
    circle.Name = "AimbotFOVCircle"
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    circle.Size = UDim2.fromOffset(Config.AimbotFOV * 2, Config.AimbotFOV * 2)
    circle.BackgroundTransparency = 1
    circle.BorderSizePixel = 0
    circle.Active = false
    circle.Visible = false
    circle.ZIndex = 1
    circle.Parent = screenGui
    table.insert(cleanUpInstances, circle)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", circle)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Theme.AccentPink
    stroke.Thickness = 1.5
    stroke.Transparency = 0.15

    local function updateAimbotCircle()
        circle.Visible = isRunning and Config.AimbotFOVCircle == true
        if not circle.Visible then return end
        local radius = math.max(0, tonumber(Config.AimbotFOV) or 120)
        local cursor = UserInputService:GetMouseLocation()
        circle.Size = UDim2.fromOffset(radius * 2, radius * 2)
        circle.Position = UDim2.fromOffset(cursor.X, cursor.Y)
    end
    updateAimbotCircle()
    table.insert(activeConnections, RunService.RenderStepped:Connect(updateAimbotCircle))
end
 

 
do
    local button = Instance.new("TextButton")
    button.Name = "oregonnscriptsMenuToggle"
    button.AnchorPoint = Vector2.new(0, 0.5)
    button.Position = UDim2.new(0, 10, 0.5, 0)
    button.Size = UDim2.fromOffset(84, 40)
    button.BackgroundColor3 = Theme.ButtonBg
    button.BorderSizePixel = 0
    button.Font = MainFont
    button.TextSize = 11
    button.TextColor3 = Theme.AccentPinkLight
    button.AutoButtonColor = false
    button.Modal = false
    button.Visible = true
    button.ZIndex = 2000
    button.Parent = screenGui
    table.insert(cleanUpInstances, button)
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 9)
    local border = Instance.new("UIStroke", button)
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Color = Theme.AccentPink
    border.Thickness = 1

    local function updateButton()
        local compact = mainWindow:GetAttribute("CompactLayout")
        local width, height = compact and 88 or 84, compact and 46 or 40
        button.Size = UDim2.fromOffset(width, height)
        button.Text = mainWindow.Visible and "Hide UI" or "Open UI"
        button.BackgroundColor3 = mainWindow.Visible and Theme.ControlBg or Theme.ButtonBg
        local camera = Workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
        local y = viewport.Y * 0.5
         
         
        if mainWindow.Visible then
            local pos, size = mainWindow.AbsolutePosition, mainWindow.AbsoluteSize
            if pos.X < 10 + width + 8 and pos.X + size.X > 10 then
                if pos.Y >= height + 16 then
                    y = pos.Y - 8 - height * 0.5
                elseif pos.Y + size.Y + height + 16 <= viewport.Y then
                    y = pos.Y + size.Y + 8 + height * 0.5
                end
            end
        end
        button.Position = UDim2.fromOffset(10, math.clamp(y, height * 0.5 + 8, math.max(height * 0.5 + 8, viewport.Y - height * 0.5 - 8)))
    end
    button.Activated:Connect(function()
        setMenuVisible(not mainWindow.Visible)
    end)
    button.MouseEnter:Connect(function() border.Color = Theme.AccentPinkLight end)
    button.MouseLeave:Connect(function() border.Color = Theme.AccentPink end)
    table.insert(activeConnections, mainWindow:GetPropertyChangedSignal("Visible"):Connect(updateButton))
    table.insert(activeConnections, mainWindow:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateButton))
    table.insert(activeConnections, mainWindow:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateButton))
    table.insert(activeConnections, mainWindow:GetAttributeChangedSignal("CompactLayout"):Connect(updateButton))

     
     
    local cursorHeld = false
    local previousMouseBehavior
    local function releaseCursor()
        if not cursorHeld then return end
        cursorHeld = false
        button.Modal = false
        if not mainWindow.Visible and previousMouseBehavior then
            UserInputService.MouseBehavior = previousMouseBehavior
        end
        previousMouseBehavior = nil
    end
    table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, processed)
        if processed or UserInputService:GetFocusedTextBox() then return end
        if input.KeyCode == Enum.KeyCode.LeftAlt and not cursorHeld then
            cursorHeld = true
            previousMouseBehavior = UserInputService.MouseBehavior
            button.Modal = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end))
    table.insert(activeConnections, UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftAlt then releaseCursor() end
    end))
    table.insert(activeConnections, UserInputService.WindowFocusReleased:Connect(releaseCursor))
    updateButton()
end
 

local isSilentKeyDown = false

local function performSilentAimRedirect(origin, defaultTargetPos, maxDist)
    if not isRunning or not Config.SilentAim then return defaultTargetPos end
    if Config.SilentKeyMode == "Hold" and not isSilentKeyDown then return defaultTargetPos end

    local target = getClosestTarget(Config.SilentFOV, Config.SilentVisibleOnly, Config.SilentTargetPart)
    if target then
        if isTeammate(target) then return defaultTargetPos end
        local hitRoll = math.random(1, 100)
        if hitRoll <= Config.SilentHitChance then
            local aimPos = target.Position
            if math.random(1, 100) <= Config.SilentHeadChance then
                local tChar = target:IsA("Model") and target or target:FindFirstAncestorOfClass("Model")
                local head = tChar and (tChar:FindFirstChild("Head") or tChar:FindFirstChild("HitboxHead"))
                if head then aimPos = head.Position end
            end
            return aimPos
        end
    end
    return defaultTargetPos
end

local hitSoundIds = {
    Skeet = "rbxassetid://4817809188",
    Rust = "rbxassetid://1255040462",
    Ding = "rbxassetid://9114223175"
}

local lastHitSoundTime = 0
local function PlayHitSound()
    if not isRunning or Config.HitSound == "Off" then return end
    local now = tick()
    if now - lastHitSoundTime < 0.04 then return end
    lastHitSoundTime = now

    pcall(function()
        local sndId = hitSoundIds[Config.HitSound] or hitSoundIds.Skeet
        local snd = Instance.new("Sound")
        snd.SoundId = sndId
        snd.Volume = 1.2
        snd.Parent = SoundService
        snd:Play()
        local deb = game:GetService("Debris")
        if deb then
            deb:AddItem(snd, 1.5)
        else
            task.delay(1.5, function()
                if snd and snd.Parent then snd:Destroy() end
            end)
        end
    end)
end

local function CreateBulletTracer(origin, targetPos)
    if not Config.BulletTracers or not isRunning then return end
    pcall(function()
        if typeof(origin) ~= "Vector3" or typeof(targetPos) ~= "Vector3" then return end
        local diff = targetPos - origin
        local dist = diff.Magnitude
        if dist < 3 or dist > 1500 then return end

        local a0 = Instance.new("Attachment")
        a0.Position = origin
        a0.Parent = Workspace.Terrain

        local a1 = Instance.new("Attachment")
        a1.Position = targetPos
        a1.Parent = Workspace.Terrain

        local beam = Instance.new("Beam")
        beam.Name = "ParagonBulletTracer"
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.Width0 = 0.06
        beam.Width1 = 0.06
        beam.FaceCamera = true
        beam.LightEmission = 1
        beam.LightInfluence = 0
        beam.Color = ColorSequence.new(Theme.AccentPinkLight)
        beam.Transparency = NumberSequence.new(0)
        beam.Parent = Workspace.Terrain
        table.insert(cleanUpInstances, a0)
        table.insert(cleanUpInstances, a1)
        table.insert(cleanUpInstances, beam)

        task.spawn(function()
            local d = 0.35
            local t0 = tick()
            while isRunning and (tick() - t0 < d) do
                local alpha = math.clamp((tick() - t0) / d, 0, 1)
                beam.Transparency = NumberSequence.new(alpha)
                task.wait(0.03)
            end
            if a0.Parent then a0:Destroy() end
            if a1.Parent then a1:Destroy() end
            if beam.Parent then beam:Destroy() end
        end)
    end)
end

pcall(function()
    local crc = LocalPlayer.PlayerScripts:FindFirstChild("Modules") and LocalPlayer.PlayerScripts.Modules:FindFirstChild("ClientReplicatedClasses")
    local cf = crc and crc:FindFirstChild("ClientFighter")
    local ciMod = cf and cf:FindFirstChild("ClientItem")
    if ciMod then
        local ci = require(ciMod)
        if ci and type(ci._PlayHitmarkerQueue) == "function" then
            local origHitmarker = ci._PlayHitmarkerQueue
            ci._PlayHitmarkerQueue = function(self, ...)
                pcall(function()
                    local fighter = self and (self.Fighter or self._fighter or self.Player)
                    local isLocal = (fighter == LocalPlayer) or (self and self.Character == LocalPlayer.Character)
                    if isLocal then
                        PlayHitSound()
                    end
                end)
                return origHitmarker(self, ...)
            end
        end

        local ii = ciMod:FindFirstChild("ItemInterface")
        local mMod = ii and ii:FindFirstChild("Mouse")
        local mcMod = mMod and mMod:FindFirstChild("MouseCrosshair")
        if mcMod then
            local mc = require(mcMod)
            if mc and type(mc.DamageEffect) == "function" then
                local origDamageEffect = mc.DamageEffect
                mc.DamageEffect = function(self, ...)
                    pcall(PlayHitSound)
                    return origDamageEffect(self, ...)
                end
            end
        end
    end
end)

pcall(function()
    local gunModule = LocalPlayer.PlayerScripts:FindFirstChild("Modules") and LocalPlayer.PlayerScripts.Modules:FindFirstChild("ItemTypes") and LocalPlayer.PlayerScripts.Modules.ItemTypes:FindFirstChild("Gun")
    if gunModule then
        local gun = require(gunModule)
        if gun and type(gun._LocalTracers) == "function" then
            local origLocalTracers = gun._LocalTracers
            gun._LocalTracers = function(self, ...)
                if Config.BulletTracers and isRunning then
                    pcall(function()
                        local cam = Workspace.CurrentCamera
                        local mPos = UserInputService:GetMouseLocation()
                        local ray = cam:ViewportPointToRay(mPos.X, mPos.Y)
                        local origin = cam.CFrame.Position - Vector3.new(0, 0.4, 0)
                        local hitPos = origin + (ray.Direction * 350)
                        local rp = RaycastParams.new()
                        rp.FilterType = Enum.RaycastFilterType.Exclude
                        rp.FilterDescendantsInstances = {LocalPlayer.Character, cam}
                        local res = Workspace:Raycast(origin, ray.Direction * 350, rp)
                        if res then hitPos = res.Position end
                        CreateBulletTracer(origin, hitPos)
                    end)
                end
                return origLocalTracers(self, ...)
            end
        end
    end
end)

pcall(function()
    local utilModule = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Utility")
    if utilModule then
        local util = require(utilModule)
        if util and type(util.Raycast) == "function" then
            originalUtilityRaycast = util.Raycast
            util.Raycast = function(...)
                local n = select("#", ...)
                local args = {...}
                local offset = 0
                if typeof(args[1]) == "table" or typeof(args[1]) == "Instance" then
                    offset = 1
                end
                local originVec = args[offset + 1]
                local targetPos = args[offset + 2]
                local maxDist = args[offset + 3]
                if isRunning and Config.SilentAim then
                    pcall(function()
                        if typeof(originVec) == "Vector3" and typeof(targetPos) == "Vector3" then
                            local redirectedPos = performSilentAimRedirect(originVec, targetPos, maxDist)
                            if redirectedPos and typeof(redirectedPos) == "Vector3" and redirectedPos ~= targetPos then
                                local diff = redirectedPos - originVec
                                if diff.Magnitude > 0.05 then
                                    local dir = diff.Unit * (maxDist or 1000)
                                    args[offset + 2] = originVec + dir
                                end
                            end
                        end
                    end)
                end
                return originalUtilityRaycast(unpack(args, 1, n))
            end
        end
    end
end)

if hookmetamethod and newcclosure and checkcaller then
    originalNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not isRunning or checkcaller() or not method then
            if setnamecallmethod then setnamecallmethod(method) end
            return originalNamecall(self, ...)
        end

        local m = method:lower()
        if m ~= "fireserver" and m ~= "invokeserver" then
            if setnamecallmethod then setnamecallmethod(method) end
            return originalNamecall(self, ...)
        end

        local args = {...}
        if Config.SilentAim and typeof(self) == "Instance" and (self.Name == "UseItem" or self.Name == "UseItemFeedback" or self.Name == "SnowballThrow") then
            local target = getClosestTarget(Config.SilentFOV, Config.SilentVisibleOnly, Config.SilentTargetPart)
            if target and not isTeammate(target) then
                local hitRoll = math.random(1, 100)
                if hitRoll <= Config.SilentHitChance then
                    local aimPos = target.Position
                    if math.random(1, 100) <= Config.SilentHeadChance then
                        local tChar = target:IsA("Model") and target or target:FindFirstAncestorOfClass("Model")
                        local head = tChar and (tChar:FindFirstChild("Head") or tChar:FindFirstChild("HitboxHead"))
                        if head then aimPos = head.Position end
                    end
                    if #args >= 2 and typeof(args[2]) == "Vector3" then
                        args[2] = aimPos
                    elseif #args >= 1 and typeof(args[1]) == "Vector3" then
                        args[1] = aimPos
                    end
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        CreateBulletTracer(LocalPlayer.Character.HumanoidRootPart.Position, aimPos)
                    end
                    if setnamecallmethod then setnamecallmethod(method) end
                    return originalNamecall(self, unpack(args))
                end
            end
        end

        if m == "invokeserver" and typeof(self) == "Instance" and self.ClassName == "RemoteFunction" then
            return self.InvokeServer(self, ...)
        end

        if setnamecallmethod then setnamecallmethod(method) end
        return originalNamecall(self, ...)
    end))
end

pcall(function()
    local lp = Players.LocalPlayer
    local ctrl = lp.PlayerScripts:FindFirstChild("Controllers")
    if ctrl then
        local tc = ctrl:FindFirstChild("TimerController")
        if tc then
            local tcm = require(tc)
            if tcm and type(tcm.SetTimeRemaining) == "function" then
                local origSet = tcm.SetTimeRemaining
                tcm.SetTimeRemaining = function(self, name, duration, ...)
                    if typeof(duration) ~= "number" then
                        if typeof(name) == "number" then
                            duration = name
                            name = "Timer"
                        else
                            return
                        end
                    end
                    return origSet(self, name, duration, ...)
                end
            end
        end

        local fc = ctrl:FindFirstChild("FFlagController")
        if fc then
            local fcm = require(fc)
            if fcm and type(fcm._Fetch) == "function" then
                fcm._Fetch = function(self, ...)
                    local res
                    pcall(function()
                        res = ReplicatedStorage.Remotes.Misc.RequestFFlags:InvokeServer()
                    end)
                    if typeof(res) == "table" then
                        for i, v in pairs(res) do
                            pcall(function() self:SetFFlag(i, v) end)
                        end
                    end
                end
            end
        end
    end
end)

local SKELETON_CONNECTIONS_R15 = {
    { "Head", "UpperTorso" },
    { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" },
    { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" },
    { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" },
    { "LeftUpperLeg", "LeftLowerLeg" },
    { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" },
    { "RightLowerLeg", "RightFoot" }
}

local SKELETON_CONNECTIONS_R6 = {
    { "Head", "Torso" },
    { "Torso", "Left Arm" },
    { "Torso", "Right Arm" },
    { "Torso", "Left Leg" },
    { "Torso", "Right Leg" }
}

local function createGuiLine(parent, zIndex)
    local line = Instance.new("Frame")
    line.BorderSizePixel = 0
    line.BackgroundColor3 = Theme.AccentPinkLight
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Visible = false
    line.ZIndex = zIndex or 2
    line.Parent = parent
    return line
end

local function updateGuiLine(line, p1, p2, thickness, color)
    local diff = p2 - p1
    local dist = diff.Magnitude
    if dist < 1 then
        line.Visible = false
        return
    end
    line.Size = UDim2.new(0, dist, 0, thickness or 1.2)
    line.Position = UDim2.new(0, (p1.X + p2.X) * 0.5, 0, (p1.Y + p2.Y) * 0.5)
    line.Rotation = math.deg(math.atan2(diff.Y, diff.X))
    if color then line.BackgroundColor3 = color end
    line.Visible = true
end

local espObjects = {}
local function createESPForPlayer(p)
    local holder = Instance.new("Folder")
    holder.Name = "ESP_" .. p.Name
    holder.Parent = screenGui
    table.insert(cleanUpInstances, holder)

    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.ZIndex = 2
    box.Parent = holder
    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Theme.AccentPink
    bStroke.Thickness = 1.2
    bStroke.Parent = box

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0, 120, 0, 14)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = MainFont
    nameLbl.Text = p.DisplayName
    nameLbl.TextColor3 = Theme.TextWhite
    nameLbl.TextSize = 11.5
    nameLbl.Visible = false
    nameLbl.ZIndex = 3
    nameLbl.Parent = holder

    local distLbl = Instance.new("TextLabel")
    distLbl.Size = UDim2.new(0, 60, 0, 14)
    distLbl.BackgroundTransparency = 1
    distLbl.Font = MainFont
    distLbl.Text = "0m"
    distLbl.TextColor3 = Theme.AccentPinkLight
    distLbl.TextSize = 10.5
    distLbl.Visible = false
    distLbl.ZIndex = 3
    distLbl.Parent = holder

    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(0, 2, 1, 0)
    healthBg.Position = UDim2.new(0, -6, 0, 0)
    healthBg.BackgroundColor3 = Theme.ControlBg
    healthBg.BorderSizePixel = 0
    healthBg.Visible = false
    healthBg.ZIndex = 3
    healthBg.Parent = box

    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.Position = UDim2.new(0, 0, 1, 0)
    healthFill.AnchorPoint = Vector2.new(0, 1)
    healthFill.BackgroundColor3 = Theme.AccentPink
    healthFill.BorderSizePixel = 0
    healthFill.ZIndex = 4
    healthFill.Parent = healthBg

    local headDot = Instance.new("Frame")
    headDot.Size = UDim2.new(0, 4, 0, 4)
    headDot.AnchorPoint = Vector2.new(0.5, 0.5)
    headDot.BackgroundColor3 = Theme.AccentPinkLight
    headDot.BorderSizePixel = 0
    headDot.Visible = false
    headDot.ZIndex = 5
    headDot.Parent = holder
    Instance.new("UICorner", headDot).CornerRadius = UDim.new(1, 0)

    local chamsHighlight = Instance.new("Highlight")
    chamsHighlight.Name = "ParagonHighlight"
    chamsHighlight.FillColor = Theme.AccentPink
    chamsHighlight.FillTransparency = 0.6
    chamsHighlight.OutlineColor = Theme.AccentPinkLight
    chamsHighlight.OutlineTransparency = 0.1
    chamsHighlight.Enabled = false
    local weapLbl = Instance.new("TextLabel")
    weapLbl.Size = UDim2.new(0, 120, 0, 14)
    weapLbl.BackgroundTransparency = 1
    weapLbl.Font = MainFont
    weapLbl.Text = "Weapon"
    weapLbl.TextColor3 = Theme.AccentPinkLight
    weapLbl.TextSize = 10.5
    weapLbl.Visible = false
    weapLbl.ZIndex = 3
    weapLbl.Parent = holder

    local skeletonLines = {}
    for i = 1, #SKELETON_CONNECTIONS_R15 do
        table.insert(skeletonLines, createGuiLine(holder, 2))
    end

    local tracerLine = createGuiLine(holder, 2)

    espObjects[p] = {
        holder = holder,
        box = box,
        nameLbl = nameLbl,
        distLbl = distLbl,
        weapLbl = weapLbl,
        healthBg = healthBg,
        healthFill = healthFill,
        headDot = headDot,
        highlight = chamsHighlight,
        skeletonLines = skeletonLines,
        tracerLine = tracerLine,
        isShown = false
    }
end

local function hideESP(esp)
    if esp.isShown then
        esp.isShown = false
        esp.box.Visible = false
        esp.nameLbl.Visible = false
        esp.distLbl.Visible = false
        esp.headDot.Visible = false
        esp.healthBg.Visible = false
        if esp.weapLbl then esp.weapLbl.Visible = false end
        if esp.highlight then esp.highlight.Enabled = false end
        if esp.skeletonLines then
            for _, line in ipairs(esp.skeletonLines) do line.Visible = false end
        end
        if esp.tracerLine then esp.tracerLine.Visible = false end
    end
end

local playerWeaponCache = {}
local function getPlayerWeapon(pChar)
    if not pChar then return "Unarmed" end
    local now = tick()
    local cached = playerWeaponCache[pChar]
    if cached and (now - cached.time < 0.5) then
        return cached.name
    end

    local foundName = "Fighter"
    for _, child in ipairs(pChar:GetChildren()) do
        if child:IsA("Tool") then
            foundName = child.Name
            break
        end
    end
    if foundName == "Fighter" then
        local rHand = pChar:FindFirstChild("RightHand") or pChar:FindFirstChild("Right Arm")
        if rHand then
            for _, w in ipairs(rHand:GetChildren()) do
                if (w:IsA("Weld") or w:IsA("Motor6D")) and w.Part1 and w.Part1.Parent and w.Part1.Parent ~= pChar and w.Part1.Parent ~= Workspace then
                    foundName = w.Part1.Parent.Name
                    break
                end
            end
        end
    end

    playerWeaponCache[pChar] = { name = foundName, time = now }
    return foundName
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESPForPlayer(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then createESPForPlayer(p) end
end)
Players.PlayerRemoving:Connect(function(p)
    if espObjects[p] then
        espObjects[p].holder:Destroy()
        espObjects[p] = nil
    end
end)

local isAimbotKeyDown = false
table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Config.MenuKey then
        setMenuVisible(not mainWindow.Visible)
        return
    end
    if gpe then return end
    if input.UserInputType == Config.AimbotKey or input.KeyCode == Config.AimbotKey then
        isAimbotKeyDown = true
    elseif input.KeyCode == Config.SilentKey then
        if Config.SilentKeyMode == "Toggle" then
            Config.SilentAim = not Config.SilentAim
            ShowNotification("oregonnscripts", "Silent Aim: " .. (Config.SilentAim and "ON" or "OFF"), "INFO", 1.5)
        elseif Config.SilentKeyMode == "Hold" then
            isSilentKeyDown = true
        end
    end
end))

local lastInfJumpTime = 0
table.insert(activeConnections, UserInputService.JumpRequest:Connect(function()
    if isRunning and not UserInputService:GetFocusedTextBox() then
        if Config.InfiniteJump then
            local now = tick()
            if now - lastInfJumpTime >= 0.25 then
                lastInfJumpTime = now
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end
end))

table.insert(activeConnections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.AimbotKey or input.KeyCode == Config.AimbotKey then
        isAimbotKeyDown = false
    elseif input.KeyCode == Config.SilentKey then
        if Config.SilentKeyMode == "Hold" then
            isSilentKeyDown = false
        end
    end
end))

task.spawn(function()
    local navPath = PathfindingService:CreatePath({
        AgentRadius = 2.0,
        AgentHeight = 5.0,
        AgentCanJump = true,
        WaypointSpacing = 3.5
    })
    local groundRayParams = RaycastParams.new()
    groundRayParams.FilterType = Enum.RaycastFilterType.Exclude
    groundRayParams.IgnoreWater = true

    while isRunning do
        task.wait(0.28)
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        local actRoot = TargetVis.activeRoot
        if ((Config.TargetVisualizer and Config.TargetVisualizerPath) or Config.Autoplay) and r and actRoot then
            local rPos = r.Position
            local aPos = actRoot.Position
            if TargetVis.lastPathMyPos and TargetVis.lastPathActPos and #TargetVis.cachedWaypoints >= 2 then
                if (rPos - TargetVis.lastPathMyPos).Magnitude < 3.5 and (aPos - TargetVis.lastPathActPos).Magnitude < 3.5 then
                    continue
                end
            end
            TargetVis.lastPathMyPos = rPos
            TargetVis.lastPathActPos = aPos
            pcall(function()
                groundRayParams.FilterDescendantsInstances = {c, TargetVis.visualizerFolder}
                local success = pcall(function()
                    navPath:ComputeAsync(rPos, aPos)
                end)
                if success and navPath.Status == Enum.PathStatus.Success then
                    local rawWps = navPath:GetWaypoints()
                    local clamped = {}
                    for _, wp in ipairs(rawWps) do
                        local ray = Workspace:Raycast(wp.Position + Vector3.new(0, 3, 0), Vector3.new(0, -12, 0), groundRayParams)
                        local groundY = ray and (ray.Position.Y + 0.1) or (wp.Position.Y - 2.4)
                        table.insert(clamped, {
                            Position = Vector3.new(wp.Position.X, groundY, wp.Position.Z),
                            Action = wp.Action
                        })
                    end
                    if #clamped >= 2 then
                        TargetVis.cachedWaypoints = clamped
                        if TargetVis.autoplayWpIndex > #clamped then TargetVis.autoplayWpIndex = 1 end
                    end
                else
                    local rayL = Workspace:Raycast(r.Position + Vector3.new(0, 3, 0), Vector3.new(0, -8, 0), groundRayParams)
                    local rayT = Workspace:Raycast(actRoot.Position + Vector3.new(0, 3, 0), Vector3.new(0, -8, 0), groundRayParams)
                    local posL = rayL and (rayL.Position + Vector3.new(0, 0.1, 0)) or (r.Position - Vector3.new(0, 2.4, 0))
                    local posT = rayT and (rayT.Position + Vector3.new(0, 0.1, 0)) or (actRoot.Position - Vector3.new(0, 2.4, 0))
                    TargetVis.cachedWaypoints = {
                        { Position = posL, Action = Enum.PathWaypointAction.Custom },
                        { Position = posT, Action = Enum.PathWaypointAction.Custom }
                    }
                    TargetVis.autoplayWpIndex = 1
                end
            end)
        else
            if not actRoot then
                TargetVis.cachedWaypoints = {}
                TargetVis.autoplayWpIndex = 1
            end
        end
    end
end)

local flyBV, flyBG
local fpsFrameCount = 0
local lastFpsSampleTime = tick()
local liveFps = 60
local livePing = 0

table.insert(activeConnections, RunService.RenderStepped:Connect(function(dt)
    if not isRunning then return end

     

    fpsFrameCount = fpsFrameCount + 1
    local curTime = tick()
    if curTime - lastFpsSampleTime >= 0.25 then
        liveFps = math.floor(fpsFrameCount / (curTime - lastFpsSampleTime) + 0.5)
        fpsFrameCount = 0
        lastFpsSampleTime = curTime

        pcall(function()
            if LocalPlayer and LocalPlayer.GetNetworkPing then
                livePing = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5)
            else
                local stats = game:GetService("Stats")
                local net = stats and stats:FindFirstChild("Network")
                local sStats = net and net:FindFirstChild("ServerStatsItem")
                local pingItem = sStats and sStats:FindFirstChild("Data Ping")
                if pingItem then livePing = math.floor(pingItem:GetValue() + 0.5) end
            end
        end)

        if wmLbl and wmLbl.Parent then
            wmLbl.Text = '<b>OS</b>  |  <font color="#9dd1f6">oregonnscripts</font>  |  ' .. tostring(liveFps) .. ' fps  |  ' .. tostring(livePing) .. ' ms'
        end
        if sPing and sPing.Parent then
            sPing.Text = tostring(livePing) .. " ms - " .. tostring(#Players:GetPlayers()) .. " players"
        end
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local cam = Workspace.CurrentCamera

    if Config.ESP_FOV then
        fovCircleGui.Visible = true
        fovCircleGui.Size = UDim2.new(0, Config.SilentFOV * 2, 0, Config.SilentFOV * 2)
        local mPos = UserInputService:GetMouseLocation()
        fovCircleGui.Position = UDim2.new(0, mPos.X - Config.SilentFOV, 0, mPos.Y - Config.SilentFOV)
    else
        fovCircleGui.Visible = false
    end

    if Config.SpeedHack and root and hum and not UserInputService:GetFocusedTextBox() then
        hum.WalkSpeed = tonumber(Config.SpeedValue) or 32
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local baseSpeed = 16
            local targetSpeed = tonumber(Config.SpeedValue) or 32
            local extraSpeed = math.max(0, targetSpeed - baseSpeed)
            if extraSpeed > 0 then
                root.CFrame = root.CFrame + (moveDir.Unit * (extraSpeed * dt))
            end
        end
    end

    if Config.FlyHack and root and hum and cam then
        if not flyBV or flyBV.Parent ~= root then
            if flyBV then flyBV:Destroy() end
            flyBV = Instance.new("BodyVelocity")
            flyBV.Velocity = Vector3.zero
            flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBV.Parent = root
            table.insert(cleanUpInstances, flyBV)
        end
        if not flyBG or flyBG.Parent ~= root then
            if flyBG then flyBG:Destroy() end
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBG.Parent = root
            table.insert(cleanUpInstances, flyBG)
        end

        local camCF = cam.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

        flyBG.CFrame = camCF
        flyBV.Velocity = (dir.Magnitude > 0) and (dir.Unit * Config.FlySpeed) or Vector3.zero
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
    end

    if Config.Fullbright and (tick() - (TargetVis.lastFullbrightCheck or 0) >= 1) then
        TargetVis.lastFullbrightCheck = tick()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
    if Config.NoFog and (tick() - (TargetVis.lastNoFogCheck or 0) >= 1) then
        TargetVis.lastNoFogCheck = tick()
        pcall(function()
            Lighting.FogEnd = 100000
            for _, eff in ipairs(Lighting:GetChildren()) do
                if eff:IsA("Atmosphere") then
                    eff.Density = 0
                elseif eff:IsA("PostEffect") then
                    if not eff.Name:find("Teleporting") then
                        eff.Enabled = false
                    end
                end
            end
        end)
    end

    if Config.CustomFOV and cam and not (Config.AimbotScopeOnly and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
        cam.FieldOfView = tonumber(Config.FOVValue) or 90
    end

    if Config.BunnyHop and hum and root and not UserInputService:GetFocusedTextBox() then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if hum.FloorMaterial ~= Enum.Material.Air then
                local now = tick()
                if now - lastBhopJumpTime > 0.08 then
                    lastBhopJumpTime = now
                    hum.Jump = true
                end
            end
        end
    end

    if (Config.ThirdPerson or Config.Freecam) and cam then
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.LocalTransparencyModifier = 0
                end
            end
        end
    end

    if Config.ThirdPerson and root and hum and not Config.Freecam then
        local head = char:FindFirstChild("Head") or root
        local headPos = head.Position + Vector3.new(0, 0.5, 0)
        local targetDist = tonumber(Config.ThirdPersonDist) or 12
        local backDir = -cam.CFrame.LookVector * targetDist
        local hitParams = RaycastParams.new()
        hitParams.FilterDescendantsInstances = {char, cam}
        hitParams.FilterType = Enum.RaycastFilterType.Exclude
        local rayRes = Workspace:Raycast(headPos, backDir, hitParams)
        local camPos = rayRes and (rayRes.Position + rayRes.Normal * 0.4) or (headPos + backDir)
        cam.CFrame = CFrame.lookAt(camPos, headPos + cam.CFrame.LookVector * 100)
    end

    if Config.Freecam and cam then
        if not FreecamState.enabled then
            FreecamState.enabled = true
            local rx, ry = cam.CFrame:ToOrientation()
            FreecamState.rotX = rx
            FreecamState.rotY = ry
            FreecamState.pos = cam.CFrame.Position
        end
        if root then
            root.Anchored = true
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        if not mainWindow.Visible then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
            local delta = UserInputService:GetMouseDelta()
            if delta.Magnitude > 0 then
                FreecamState.rotY = FreecamState.rotY - math.rad(delta.X * 0.25)
                FreecamState.rotX = math.clamp(FreecamState.rotX - math.rad(delta.Y * 0.25), math.rad(-89), math.rad(89))
            end
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
        local camRot = CFrame.Angles(0, FreecamState.rotY, 0) * CFrame.Angles(FreecamState.rotX, 0, 0)
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camRot.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camRot.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camRot.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camRot.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then
            FreecamState.pos = FreecamState.pos + (moveDir.Unit * (Config.FreecamSpeed or 40) * dt)
        end
        cam.CFrame = CFrame.new(FreecamState.pos) * camRot
    else
        if FreecamState.enabled then
            FreecamState.enabled = false
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            if root then
                root.Anchored = false
            end
        end
    end

    if Config.AntiAim and root then
        if Config.AntiAimMode == "Spin" then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(math.min(Config.AntiAimSpeed, 35) * dt * 60), 0)
        elseif Config.AntiAimMode == "Jitter" then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(math.random(-45, 45)), 0)
        elseif Config.AntiAimMode == "Backwards" then
            root.CFrame = CFrame.lookAt(root.Position, root.Position - cam.CFrame.LookVector)
        end
    end

    if Config.Aimbot and (Config.AimbotKeyMode == "Always" or isAimbotKeyDown) and not mainWindow.Visible then
        local isScoped = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or cam.FieldOfView < 70
        local isReloading = char and char:GetAttribute("Reloading")
        if (not Config.AimbotScopeOnly or isScoped) and (not Config.AimbotDisableReloading or not isReloading) then
            local checkVis = Config.AimbotVisibleOnly and not Config.TrackThroughWalls
            local target = getClosestTarget(Config.AimbotFOV, checkVis, Config.AimbotPart)
            if target and cam then
                local targetPos = target.Position
                if Config.InstantCameraLock then
                    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, targetPos)
                else
                    local scrPos, onScreen = cam:WorldToViewportPoint(targetPos)
                    if onScreen and scrPos.Z > 0 then
                        local mPos = UserInputService:GetMouseLocation()
                        local deltaX = scrPos.X - mPos.X
                        local deltaY = scrPos.Y - mPos.Y
                        local smooth = math.clamp(tonumber(Config.AimbotSmoothing) or 0.28, 0.02, 1)
                        if mousemoverel then
                            mousemoverel(deltaX * smooth, deltaY * smooth)
                        elseif typeof(mouse_move) == "function" then
                            mouse_move(deltaX * smooth, deltaY * smooth)
                        else
                            local curCF = cam.CFrame
                            local goalCF = CFrame.lookAt(curCF.Position, targetPos)
                            cam.CFrame = curCF:Lerp(goalCF, math.clamp(smooth * 45 * dt, 0.05, 1))
                        end
                    else
                        local curCF = cam.CFrame
                        local goalCF = CFrame.lookAt(curCF.Position, targetPos)
                        cam.CFrame = curCF:Lerp(goalCF, math.clamp(Config.AimbotSmoothing * 45 * dt, 0.05, 1))
                    end
                end
            end
        end
    end

    local rageTarget = nil
    if Config.Ragebot and root and not mainWindow.Visible and hasWeaponEquipped() then
        rageTarget = getClosestTarget(1000, true, "Head", Config.RagebotTargetPriority)
    end
    local candidateTarget = rageTarget
    if not candidateTarget then
        if Config.TargetVisualizer or (not isInLobby() and hasWeaponEquipped()) then
            candidateTarget = getClosestTarget(1000, false, "Head", "Distance")
        end
    end
    if candidateTarget and candidateTarget.Parent then
        local tChar = candidateTarget.Parent
        local tHum = tChar:FindFirstChildOfClass("Humanoid")
        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
        if tHum and tHum.Health > 0 and tRoot then
            TargetVis.activeChar = tChar
            TargetVis.activeHum = tHum
            TargetVis.activeRoot = tRoot
            TargetVis.activePlayer = Players:GetPlayerFromCharacter(tChar)
        else
            TargetVis.activeChar = nil
            TargetVis.activeHum = nil
            TargetVis.activeRoot = nil
            TargetVis.activePlayer = nil
        end
    else
        TargetVis.activeChar = nil
        TargetVis.activeHum = nil
        TargetVis.activeRoot = nil
        TargetVis.activePlayer = nil
    end

    if Config.TargetVisualizer and Config.TargetVisualizerHUD and TargetVis.activePlayer and TargetVis.activeHum and TargetVis.activeHum.Health > 0 then
        if TargetVis.hudTitle then
            TargetVis.hudTitle.Text = string.format("Target  -  %d/%d", math.floor(TargetVis.activeHum.Health), math.floor(TargetVis.activeHum.MaxHealth))
        end
        if TargetVis.lastTargetUserId ~= TargetVis.activePlayer.UserId then
            TargetVis.lastTargetUserId = TargetVis.activePlayer.UserId
            if TargetVis.hudAvatar then
                TargetVis.hudAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. TargetVis.activePlayer.UserId .. "&w=100&h=100"
            end
            if TargetVis.hudName then
                TargetVis.hudName.Text = TargetVis.activePlayer.DisplayName .. "  (@" .. TargetVis.activePlayer.Name .. ")"
            end
        end
        if TargetVis.hudHpFill then
            local hpPct = math.clamp(TargetVis.activeHum.Health / math.max(TargetVis.activeHum.MaxHealth, 1), 0, 1)
            TargetVis.hudHpFill.Size = UDim2.new(hpPct, 0, 1, 0)
        end
        if TargetVis.hudFrame then TargetVis.hudFrame.Visible = true end
    else
        if TargetVis.hudFrame then TargetVis.hudFrame.Visible = false end
    end

    if Config.TargetVisualizer and Config.TargetVisualizerPath and TargetVis.activeRoot and #TargetVis.cachedWaypoints >= 2 then
        local wps = TargetVis.cachedWaypoints
        local numSegments = #wps - 1
        local lineCount = math.min(numSegments, #TargetVis.poolLines)

        for i = 1, lineCount do
            local pA = wps[i].Position
            local pB = wps[i + 1].Position
            local diff = pB - pA
            local dist = diff.Magnitude
            local part = TargetVis.poolLines[i]
            if dist > 0.1 then
                part.Size = Vector3.new(0.18, 0.06, dist)
                part.CFrame = CFrame.lookAt((pA + pB) * 0.5, pB)
                part.Transparency = 0
            else
                part.Transparency = 1
            end
        end
        for i = lineCount + 1, #TargetVis.poolLines do
            TargetVis.poolLines[i].Transparency = 1
        end

        local segDists = {}
        local totalLength = 0
        for i = 1, numSegments do
            local d = (wps[i + 1].Position - wps[i].Position).Magnitude
            table.insert(segDists, d)
            totalLength = totalLength + d
        end

        local spacing = math.max(tonumber(Config.VisualizerArrowSpacing) or 10, 5)
        local speed = math.max(tonumber(Config.VisualizerArrowSpeed) or 14, 2)
        local travelOffset = (tick() * speed) % spacing
        local numChevrons = math.min(math.floor(totalLength / spacing) + 1, 16, #TargetVis.poolChevrons)

        local wingLen = 1.1
        local curSeg = 1
        local curAcc = 0
        for cIdx = 1, numChevrons do
            local distOnPath = (cIdx - 1) * spacing + travelOffset
            if distOnPath <= totalLength and distOnPath >= 0.5 then
                while curSeg < numSegments and (curAcc + segDists[curSeg]) < distOnPath do
                    curAcc = curAcc + segDists[curSeg]
                    curSeg = curSeg + 1
                end
                local segLen = segDists[curSeg] or 1
                local t = segLen > 0 and ((distOnPath - curAcc) / segLen) or 0
                local pos = wps[curSeg].Position:Lerp(wps[curSeg + 1].Position, math.clamp(t, 0, 1))
                local fwd = (wps[curSeg + 1].Position - wps[curSeg].Position).Unit

                local chev = TargetVis.poolChevrons[cIdx]
                local baseCF = CFrame.lookAt(pos, pos + fwd)
                chev.Left.CFrame = baseCF * CFrame.Angles(0, math.rad(-140), 0) * CFrame.new(0, 0, wingLen * 0.5)
                chev.Left.Size = Vector3.new(0.2, 0.08, wingLen)
                chev.Left.Transparency = 0

                chev.Right.CFrame = baseCF * CFrame.Angles(0, math.rad(140), 0) * CFrame.new(0, 0, wingLen * 0.5)
                chev.Right.Size = Vector3.new(0.2, 0.08, wingLen)
                chev.Right.Transparency = 0
            else
                TargetVis.poolChevrons[cIdx].Left.Transparency = 1
                TargetVis.poolChevrons[cIdx].Right.Transparency = 1
            end
        end
        for cIdx = numChevrons + 1, #TargetVis.poolChevrons do
            TargetVis.poolChevrons[cIdx].Left.Transparency = 1
            TargetVis.poolChevrons[cIdx].Right.Transparency = 1
        end
    else
        for _, p in ipairs(TargetVis.poolLines) do p.Transparency = 1 end
        for _, c in ipairs(TargetVis.poolChevrons) do
            c.Left.Transparency = 1
            c.Right.Transparency = 1
        end
    end

    if Config.Ragebot and root and not mainWindow.Visible and hasWeaponEquipped() then
        local target = rageTarget
        if target and target.Parent and cam then
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position)

            if Config.RagebotTargetStrafe and hum and root then
                isTargetStrafing = true
                local tPos = target.Position
                local currentAngle = tick() * (tonumber(Config.TargetStrafeSpeed) or 6)
                local rad = tonumber(Config.TargetStrafeRadius) or 14
                local goalWorldPos = Vector3.new(
                    tPos.X + math.cos(currentAngle) * rad,
                    root.Position.Y,
                    tPos.Z + math.sin(currentAngle) * rad
                )
                local moveOffset = goalWorldPos - root.Position
                local moveDir = Vector3.new(moveOffset.X, 0, moveOffset.Z)
                if moveDir.Magnitude > 0.5 then
                    hum:Move(moveDir.Unit, false)
                else
                    hum:Move(Vector3.zero, false)
                end
            elseif isTargetStrafing and hum and not Config.Autoplay then
                isTargetStrafing = false
                hum:Move(Vector3.zero, false)
            end

            if Config.RagebotAutoShoot then
                local now = tick()
                if now - lastRageAutoShootTime >= 0.12 then
                    lastRageAutoShootTime = now
                    clickWeapon()
                end
            end
        else
            if isTargetStrafing and hum and not Config.Autoplay then
                isTargetStrafing = false
                hum:Move(Vector3.zero, false)
            end
        end
    else
        if isTargetStrafing and hum and not Config.Autoplay then
            isTargetStrafing = false
            hum:Move(Vector3.zero, false)
        end
    end

    if Config.Autoplay and root and hum and not mainWindow.Visible and hasWeaponEquipped() then
        if TargetVis.activeRoot and TargetVis.activeHum and TargetVis.activeHum.Health > 0 then
            if cam then
                local enemyHead = TargetVis.activeChar and (TargetVis.activeChar:FindFirstChild("Head") or TargetVis.activeChar:FindFirstChild("HitboxHead"))
                local aimPoint = enemyHead and enemyHead.Position or (TargetVis.activeRoot.Position + Vector3.new(0, 1.5, 0))
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, aimPoint)

                if Config.RagebotAutoShoot then
                    local dir = aimPoint - cam.CFrame.Position
                    local res = Workspace:Raycast(cam.CFrame.Position, dir, TargetVis.staticRayParams)
                    if not res or (TargetVis.activeChar and res.Instance:IsDescendantOf(TargetVis.activeChar)) then
                        local now = tick()
                        if now - lastRageAutoShootTime >= 0.12 then
                            lastRageAutoShootTime = now
                            pcall(function()
                                if mouse1click then
                                    mouse1click()
                                elseif mouse1press and mouse1release then
                                    mouse1press()
                                    task.wait(0.01)
                                    mouse1release()
                                end
                            end)
                        end
                    end
                end
            end

            local tDist = (TargetVis.activeRoot.Position - root.Position).Magnitude
            local stopDist = tonumber(Config.AutoplayDistance) or 18

            if TargetVis.cachedWaypoints and #TargetVis.cachedWaypoints >= 2 then
                local curWp = TargetVis.cachedWaypoints[TargetVis.autoplayWpIndex]
                if curWp then
                    local wpDist = (Vector3.new(curWp.Position.X, root.Position.Y, curWp.Position.Z) - root.Position).Magnitude
                    if wpDist < 4.5 and TargetVis.autoplayWpIndex < #TargetVis.cachedWaypoints then
                        TargetVis.autoplayWpIndex = TargetVis.autoplayWpIndex + 1
                        curWp = TargetVis.cachedWaypoints[TargetVis.autoplayWpIndex]
                    end
                end

                if tDist > stopDist and curWp then
                    local moveVec = Vector3.new(curWp.Position.X - root.Position.X, 0, curWp.Position.Z - root.Position.Z)
                    if moveVec.Magnitude > 0.5 then
                        hum:Move(moveVec.Unit, false)
                    end

                    if curWp.Action == Enum.PathWaypointAction.Jump then
                        hum.Jump = true
                    end

                    if TargetVis.lastAutoplayPos and (root.Position - TargetVis.lastAutoplayPos).Magnitude < 0.6 then
                        TargetVis.lastAutoplayStuckTime = TargetVis.lastAutoplayStuckTime + dt
                        if TargetVis.lastAutoplayStuckTime > 0.35 then
                            hum.Jump = true
                            TargetVis.lastAutoplayStuckTime = 0
                        end
                    else
                        TargetVis.lastAutoplayStuckTime = 0
                    end
                    TargetVis.lastAutoplayPos = root.Position
                else
                    if not Config.RagebotTargetStrafe then
                        hum:Move(Vector3.zero, false)
                    end
                end
            else
                local toEnemy = Vector3.new(TargetVis.activeRoot.Position.X - root.Position.X, 0, TargetVis.activeRoot.Position.Z - root.Position.Z)
                if toEnemy.Magnitude > stopDist then
                    hum:Move(toEnemy.Unit, false)
                else
                    if not Config.RagebotTargetStrafe then
                        hum:Move(Vector3.zero, false)
                    end
                end
            end
        else
            if not Config.RagebotTargetStrafe then
                hum:Move(Vector3.zero, false)
            end
        end
    end

    if Config.AutomaticGuns and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not mainWindow.Visible and hasWeaponEquipped() then
        local now = tick()
        if now - lastAutoShootTime >= 0.08 then
            lastAutoShootTime = now
            clickWeapon()
        end
    end

    local vmFolder = Workspace:FindFirstChild("ViewModels") or cam
    if vmFolder and (Config.RainbowGunSkin or Config.HideViewModel or Config.WeaponChams or Config.CustomViewModelFOV or Config.ViewModelXOffset ~= 0 or Config.ViewModelYOffset ~= 0 or Config.ViewModelZOffset ~= 0) then
        local fpModel = vmFolder:FindFirstChild("FirstPerson") or vmFolder
        local hue = (tick() * 0.4) % 1
        local rainbowColor = Color3.fromHSV(hue, 0.8, 1)

        for _, part in ipairs(fpModel:GetDescendants()) do
            if part:IsA("BasePart") then
                if Config.HideViewModel then
                    part.Transparency = 1
                else
                    if Config.RainbowGunSkin and part.Transparency < 1 then
                        part.Color = rainbowColor
                    end
                    if Config.WeaponChams and part.Transparency < 1 then
                        part.Material = Enum.Material.Neon
                        part.Color = Theme.AccentPink
                    end
                end
            end
        end
    end

    pcall(function()
        if not Config.ESP_Master then
            for _, esp in pairs(espObjects) do
                hideESP(esp)
            end
            return
        end

        local camCF = Camera.CFrame
        local camPos = camCF.Position
        local camLook = camCF.LookVector
        local maxDist = tonumber(Config.ESP_MaxDistance) or 500
        if isInLobby() then maxDist = math.min(maxDist, 160) end
        local visibleSkeletonsCount = 0
        local maxSkeletons = isInLobby() and 2 or 4
        local maxSkeletonDist = isInLobby() and 60 or 120

        for p, esp in pairs(espObjects) do
            local pChar = p.Character
            local pHum = pChar and pChar:FindFirstChildOfClass("Humanoid")
            local pRoot = pChar and pChar:FindFirstChild("HumanoidRootPart")
            local pHead = pChar and (pChar:FindFirstChild("Head") or pChar:FindFirstChild("HitboxHead") or pChar:FindFirstChild("HitboxHeadSmall"))

            if isEnemyPlayer(p) and pChar and pHum and pRoot and pHead and pHum.Health > 0 then
                local toRoot = pRoot.Position - camPos
                local distStuds = toRoot.Magnitude
                local inFront = toRoot:Dot(camLook) > 0

                if (not inFront) or (distStuds > maxDist) then
                    hideESP(esp)
                else
                    local top3D = pHead.Position + Vector3.new(0, 0.8, 0)
                    local bot3D = pRoot.Position - Vector3.new(0, 2.85, 0)

                    local top2D, tOn = Camera:WorldToViewportPoint(top3D)
                    local bot2D, bOn = Camera:WorldToViewportPoint(bot3D)
                    local head2D, hOn = Camera:WorldToViewportPoint(pHead.Position)
                    local root2D = Camera:WorldToViewportPoint(pRoot.Position)

                    if tOn and bOn and top2D.Z > 0 and bot2D.Z > 0 then
                        esp.isShown = true

                        local boxHeight = math.abs(bot2D.Y - top2D.Y)
                        local boxWidth = boxHeight * 0.65
                        local boxTopY = top2D.Y
                        local boxLeftX = root2D.X - (boxWidth / 2)

                        if Config.ESP_Boxes then
                            esp.box.Visible = true
                            esp.box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                            esp.box.Position = UDim2.new(0, boxLeftX, 0, boxTopY)
                        else
                            esp.box.Visible = false
                        end

                        if Config.ESP_Names then
                            esp.nameLbl.Visible = true
                            esp.nameLbl.Position = UDim2.new(0, root2D.X - 60, 0, boxTopY - 16)
                            esp.nameLbl.Size = UDim2.new(0, 120, 0, 14)
                        else
                            esp.nameLbl.Visible = false
                        end

                        if Config.ESP_Distance then
                            local dist = math.floor(distStuds * 0.28)
                            esp.distLbl.Visible = true
                            esp.distLbl.Text = tostring(dist) .. "m"
                            esp.distLbl.Position = UDim2.new(0, root2D.X - 30, 0, bot2D.Y + 2)
                            esp.distLbl.Size = UDim2.new(0, 60, 0, 14)
                        else
                            esp.distLbl.Visible = false
                        end

                        if Config.ESP_Weapon and esp.weapLbl then
                            esp.weapLbl.Visible = true
                            esp.weapLbl.Text = getPlayerWeapon(pChar)
                            esp.weapLbl.Position = UDim2.new(0, root2D.X - 60, 0, (Config.ESP_Distance and (bot2D.Y + 16) or (bot2D.Y + 2)))
                        elseif esp.weapLbl then
                            esp.weapLbl.Visible = false
                        end

                        if Config.ESP_HealthBar then
                            esp.healthBg.Visible = true
                            local hpPct = math.clamp(pHum.Health / pHum.MaxHealth, 0, 1)
                            esp.healthFill.Size = UDim2.new(1, 0, hpPct, 0)
                        else
                            esp.healthBg.Visible = false
                        end

                        if Config.ESP_HeadDot and hOn and head2D.Z > 0 then
                            esp.headDot.Visible = true
                            esp.headDot.Position = UDim2.new(0, head2D.X, 0, head2D.Y)
                        else
                            esp.headDot.Visible = false
                        end

                        if Config.ESP_Chams then
                            esp.highlight.Enabled = true
                            esp.highlight.Adornee = pChar
                        else
                            esp.highlight.Enabled = false
                        end
                    else
                        hideESP(esp)
                    end

                    if Config.ESP_Skeleton and esp.skeletonLines and distStuds <= maxSkeletonDist and tOn and bOn and visibleSkeletonsCount < maxSkeletons then
                        visibleSkeletonsCount = visibleSkeletonsCount + 1
                        local isR15 = pChar:FindFirstChild("UpperTorso") ~= nil
                        local connections = isR15 and SKELETON_CONNECTIONS_R15 or SKELETON_CONNECTIONS_R6
                        for i, bonePair in ipairs(connections) do
                            local line = esp.skeletonLines[i]
                            local partA = pChar:FindFirstChild(bonePair[1])
                            local partB = pChar:FindFirstChild(bonePair[2])
                            if partA and partB and line then
                                local posA, onA = Camera:WorldToViewportPoint(partA.Position)
                                local posB, onB = Camera:WorldToViewportPoint(partB.Position)
                                if (onA or onB) and posA.Z > 0 and posB.Z > 0 then
                                    updateGuiLine(line, Vector2.new(posA.X, posA.Y), Vector2.new(posB.X, posB.Y), 1.2, Theme.AccentPinkLight)
                                else
                                    line.Visible = false
                                end
                            elseif line then
                                line.Visible = false
                            end
                        end
                        for i = #connections + 1, #esp.skeletonLines do
                            if esp.skeletonLines[i] then esp.skeletonLines[i].Visible = false end
                        end
                    elseif esp.skeletonLines then
                        for _, line in ipairs(esp.skeletonLines) do line.Visible = false end
                    end

                    if Config.ESP_Tracers and esp.tracerLine and distStuds <= 350 and bot2D and bot2D.Z > 0 and bOn then
                        local vpSize = Camera.ViewportSize
                        local origin2D = Vector2.new(vpSize.X * 0.5, vpSize.Y)
                        local target2D = Vector2.new(root2D.X, bot2D.Y)
                        updateGuiLine(esp.tracerLine, origin2D, target2D, 1.2, Theme.AccentPink)
                    elseif esp.tracerLine then
                        esp.tracerLine.Visible = false
                    end
                end
            else
                hideESP(esp)
            end
        end
    end)
end))

table.insert(activeConnections, RunService.Stepped:Connect(function()
    if not isRunning then return end
    local char = LocalPlayer.Character
    if Config.Noclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end))


task.spawn(function()
    local hackerDetectionTimestamps = {}
    local hackerNotifiedTimestamps = {}
    local modNotifiedCache = {}

    ApplyWeaponModifications()
    while isRunning do
        pcall(function()
            local rem = ReplicatedStorage:FindFirstChild("Remotes")
            local duels = rem and rem:FindFirstChild("Duels")
            local matchmaking = rem and rem:FindFirstChild("Matchmaking")

            if Config.AutoRespawn and duels and duels:FindFirstChild("RespawnNow") then
                duels.RespawnNow:FireServer()
            end

            if Config.AutoQueue and matchmaking and matchmaking:FindFirstChild("JoinQueue") then
                local targetQueue = Config.QueueMode or "1v1"
                task.spawn(function()
                    pcall(function()
                        matchmaking.JoinQueue:InvokeServer(targetQueue)
                    end)
                end)
            end

            if (Config.AutoVoteMaps or Config.AutoBanWeapons) then
                if duels and duels:FindFirstChild("Vote") then
                    if Config.AutoVoteMaps then
                        local topMap = string.split(Config.MapPriority or "Arena", ",")[1]:match("^%s*(.-)%s*$")
                        pcall(function() duels.Vote:FireServer("Map", topMap or "Arena") end)
                        pcall(function() duels.Vote:FireServer(topMap or "Arena") end)
                    end
                    if Config.AutoBanWeapons then
                        local topBan = string.split(Config.WeaponBanPriority or "Grenade Launcher", ",")[1]:match("^%s*(.-)%s*$")
                        pcall(function() duels.Vote:FireServer("Weapon", topBan or "Grenade Launcher") end)
                        pcall(function() duels.Vote:FireServer(topBan or "Grenade Launcher") end)
                    end
                end

                pcall(function()
                    local pages = LocalPlayer.PlayerScripts:FindFirstChild("Modules") and LocalPlayer.PlayerScripts.Modules:FindFirstChild("Pages")
                    local pwMod = pages and pages:FindFirstChild("PickWeapons")
                    if pwMod then
                        local pw = require(pwMod)
                        if pw and pw._is_open then
                            if Config.AutoVoteMaps and pw.MapFrame then
                                for _, d in ipairs(pw.MapFrame:GetDescendants()) do
                                    if (d:IsA("TextButton") or d:IsA("ImageButton")) and getconnections then
                                        for _, c in ipairs(getconnections(d.MouseButton1Click) or {}) do c:Fire() end
                                    end
                                end
                            end
                            if Config.AutoBanWeapons and pw._ban_frames then
                                for _, frame in pairs(pw._ban_frames) do
                                    if typeof(frame) == "Instance" then
                                        for _, btn in ipairs(frame:GetDescendants()) do
                                            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and getconnections then
                                                for _, c in ipairs(getconnections(btn.MouseButton1Click) or {}) do c:Fire() end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end

            if Config.AutoLoadout and duels and duels:FindFirstChild("PickWeaponsAheadOfTime") then
                duels.PickWeaponsAheadOfTime:FireServer()
            end

            if Config.HackerDetector then
                local threshold = tonumber(Config.SpeedThreshold) or 180
                local duration = tonumber(Config.SpeedDuration) or 0.75
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                        if pRoot then
                            local vel = pRoot.AssemblyLinearVelocity.Magnitude
                            if vel > threshold then
                                if not hackerDetectionTimestamps[p] then
                                    hackerDetectionTimestamps[p] = tick()
                                elseif tick() - hackerDetectionTimestamps[p] >= duration then
                                    if not hackerNotifiedTimestamps[p] or tick() - hackerNotifiedTimestamps[p] > 12 then
                                        hackerNotifiedTimestamps[p] = tick()
                                        if Config.NotifyHackers then
                                            ShowNotification("oregonnscripts", "Hacker Flag: " .. p.DisplayName .. " (" .. math.floor(vel) .. " studs/s)", "WARN", 3.5)
                                        end
                                        if Config.HackerAutoLoad and Config.HackerProfile and Config.HackerProfile ~= "" then
                                            local targetProfile = Config.HackerProfile:match("^%s*(.-)%s*$")
                                            if ProfileSystem and ProfileSystem.current ~= targetProfile then
                                                local loaded = ProfileSystem.applyProfile(targetProfile, false)
                                                if loaded then
                                                    ShowNotification("oregonnscripts", "Hacker detected! Loaded profile: " .. targetProfile, "SUCCESS", 3.5)
                                                end
                                            end
                                        end
                                    end
                                end
                            else
                                hackerDetectionTimestamps[p] = nil
                            end
                        end
                    end
                end
            end

            if Config.ModDetector then
                local minRank = tonumber(Config.MinGroupRank) or 200
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and not modNotifiedCache[p] then
                        local isMod = false
                        local rank = p:GetAttribute("GroupRank")
                        if not rank then
                            pcall(function() rank = p:GetRankInGroup(game.CreatorId > 0 and game.CreatorId or 16124806) end)
                        end
                        if rank and rank >= minRank then
                            isMod = true
                        end
                        if not isMod and Config.ModUsernames and Config.ModUsernames ~= "" then
                            for uName in Config.ModUsernames:gmatch("[^,%s]+") do
                                if p.Name:lower() == uName:lower() or p.DisplayName:lower() == uName:lower() then
                                    isMod = true
                                    break
                                end
                            end
                        end
                        if isMod then
                            modNotifiedCache[p] = true
                            if Config.NotifyMods then
                                ShowNotification("oregonnscripts", "STAFF / MOD DETECTED: " .. p.DisplayName .. " (Rank: " .. tostring(rank or "Staff") .. ")", "ERROR", 5)
                            end
                        end
                    end
                end
            end

            if Config.AutoPickup then
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if obj.Name:find("Drop") or obj.Name:find("Tripmine") or obj.Name:find("Ammo") then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part and (part.Position - root.Position).Magnitude <= Config.PickupRadius then
                                if firetouchinterest then
                                    firetouchinterest(root, part, false)
                                    firetouchinterest(root, part, true)
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

setMenuVisible(true)
ShowNotification("oregonnscripts", "Loaded oregonnscripts successfully.", "SUCCESS", 4)
