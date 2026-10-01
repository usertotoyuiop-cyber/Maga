-- ============================================
-- DR HUB FULL (Good Aimbot + Preview 2D + Hat + Trail)
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

local KEY_FREE = "magabok"
local KEY_PREM = "magaPrem"
local IS_PREMIUM = false
local AIM_PART = "Head"

local ACCENT = Color3.fromRGB(140, 90, 255)
local RED = Color3.fromRGB(255, 40, 40)
local GOLD = Color3.fromRGB(255, 200, 60)
local BG = Color3.fromRGB(22, 22, 30)
local PANEL = Color3.fromRGB(32, 32, 44)
local SIDE = Color3.fromRGB(18, 18, 26)
local OFF = Color3.fromRGB(70, 70, 88)
local WHITE = Color3.new(1, 1, 1)

local S = {
    Chams=false, ChamsRainbow=false, Highlight=false,
    ESP=false, ESPDist=true, Tracers=false,
    Spin=false, ThirdPerson=false,
    Aim=false, FOVCircle=false, WallCheck=true, Snap=false,
    Hat=false, Trail=false,
}

local spinSpeed = 6
local aimFovSize = 150
local aimSmooth = 0.3
local defaultFov = Cam.FieldOfView
local fovCircle = nil
local hasDrawing = pcall(function() return Drawing.new("Circle") end)

local chamsColor = Color3.fromRGB(255, 60, 120)
local chamsTransparency = 0.35
local espColor = Color3.fromRGB(255, 255, 255)
local tracerColor = Color3.fromRGB(255, 255, 255)
local hatColor = Color3.fromRGB(255, 200, 40)
local trailColor = Color3.fromRGB(0, 200, 255)
local trailColor2 = Color3.fromRGB(255, 60, 200)

local espObjects = {}
local tracerObjects = {}
local charOriginals = {}
local lastSkin = nil

local ColorPalette = {
    {name="Red",color=Color3.fromRGB(255,40,40)}, {name="Blue",color=Color3.fromRGB(40,120,255)},
    {name="Green",color=Color3.fromRGB(40,255,90)}, {name="Yellow",color=Color3.fromRGB(255,230,40)},
    {name="Pink",color=Color3.fromRGB(255,60,200)}, {name="Orange",color=Color3.fromRGB(255,130,40)},
    {name="Purple",color=Color3.fromRGB(180,60,255)}, {name="Cyan",color=Color3.fromRGB(60,230,255)},
    {name="White",color=Color3.fromRGB(255,255,255)}, {name="Black",color=Color3.fromRGB(20,20,20)},
}

local function round(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
end

-- ========== KEY (без текста успеха) ==========
local keyGui = Instance.new("ScreenGui")
keyGui.Name = "DRHubKey"; keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true; keyGui.DisplayOrder = 1000
keyGui.Parent = LP:WaitForChild("PlayerGui")

local kbg = Instance.new("Frame", keyGui)
kbg.Size = UDim2.new(1,0,1,0); kbg.BackgroundColor3 = Color3.fromRGB(10,10,15)
kbg.BorderSizePixel = 0

local kpanel = Instance.new("Frame", kbg)
kpanel.Size = UDim2.fromOffset(320, 200)
kpanel.Position = UDim2.new(0.5, -160, 0.5, -100)
kpanel.BackgroundColor3 = BG; kpanel.BorderSizePixel = 0
round(kpanel, 12)

local ktitle = Instance.new("TextLabel", kpanel)
ktitle.Size = UDim2.new(1,0,0,44); ktitle.Position = UDim2.fromOffset(0, 10)
ktitle.BackgroundTransparency = 1
ktitle.Text = "DR HUB"; ktitle.Font = Enum.Font.GothamBold
ktitle.TextSize = 24; ktitle.TextColor3 = ACCENT

local kbox = Instance.new("TextBox", kpanel)
kbox.Size = UDim2.new(1,-40,0,38); kbox.Position = UDim2.new(0,20,0,70)
kbox.BackgroundColor3 = PANEL; kbox.PlaceholderText = "Key..."
kbox.Font = Enum.Font.GothamMedium; kbox.TextSize = 15; kbox.TextColor3 = WHITE
kbox.PlaceholderColor3 = Color3.fromRGB(120,120,140); kbox.ClearTextOnFocus = false
round(kbox, 8)

local kbtn = Instance.new("TextButton", kpanel)
kbtn.Size = UDim2.new(1,-40,0,38); kbtn.Position = UDim2.new(0,20,0,120)
kbtn.BackgroundColor3 = ACCENT; kbtn.Text = "Enter"
kbtn.Font = Enum.Font.GothamBold; kbtn.TextSize = 15; kbtn.TextColor3 = WHITE
round(kbtn, 8)

local kerr = Instance.new("TextLabel", kpanel)
kerr.Size = UDim2.new(1,0,0,20); kerr.Position = UDim2.new(0,0,0,170)
kerr.BackgroundTransparency = 1; kerr.Text = ""
kerr.Font = Enum.Font.GothamBold; kerr.TextSize = 12; kerr.TextColor3 = Color3.fromRGB(255,80,80)

local unlocked = false
local function tryKey()
    if kbox.Text == KEY_FREE then
        unlocked = true; IS_PREMIUM = false
        keyGui:Destroy()
    elseif kbox.Text == KEY_PREM then
        unlocked = true; IS_PREMIUM = true
        keyGui:Destroy()
    else
        kerr.Text = "Wrong key"; kbox.Text = ""
    end
end
kbtn.MouseButton1Click:Connect(tryKey)
kbox.FocusLost:Connect(function(e) if e then tryKey() end end)
while not unlocked do task.wait(0.1) end

-- ========== MAIN GUI ==========
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "DRHub"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true

local BASE_W, BASE_H = 480, 320
local PREVIEW_W = 160
local currentRatio = BASE_W/BASE_H

local menuWrap = Instance.new("Frame", gui)
menuWrap.Size = UDim2.fromOffset(BASE_W + PREVIEW_W + 8, BASE_H)
menuWrap.Position = UDim2.new(0.5, -(BASE_W+PREVIEW_W+8)/2, 0.5, -BASE_H/2)
menuWrap.BackgroundTransparency = 1

local main = Instance.new("Frame", menuWrap)
main.Size = UDim2.fromOffset(BASE_W, BASE_H)
main.Position = UDim2.fromOffset(0, 0)
main.BackgroundColor3 = BG; main.BorderSizePixel = 0
round(main, 12)
local stroke = Instance.new("UIStroke", main)
stroke.Color = IS_PREMIUM and GOLD or ACCENT; stroke.Thickness = 1.5

local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.fromOffset(110, BASE_H - 16)
sidebar.Position = UDim2.fromOffset(8, 8)
sidebar.BackgroundColor3 = SIDE; sidebar.BorderSizePixel = 0
round(sidebar, 10)

local nameLbl = Instance.new("TextLabel", sidebar)
nameLbl.Size = UDim2.new(1,0,0,20); nameLbl.Position = UDim2.fromOffset(0, 10)
nameLbl.BackgroundTransparency = 1; nameLbl.Text = LP.Name or "Player"
nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 11
nameLbl.TextColor3 = WHITE; nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

local tabList = Instance.new("Frame", sidebar)
tabList.Size = UDim2.new(1,-8,1,-40); tabList.Position = UDim2.fromOffset(4, 36)
tabList.BackgroundTransparency = 1
local tll = Instance.new("UIListLayout", tabList)
tll.Padding = UDim.new(0,3); tll.SortOrder = Enum.SortOrder.LayoutOrder

local pages, tabButtons = {}, {}

local function selectTab(name)
    for n, p in pairs(pages) do
        p.Visible = (n == name)
        tabButtons[n].BackgroundColor3 = (n == name) and (IS_PREMIUM and GOLD or ACCENT) or SIDE
    end
end

local function createTab(name, order)
    local b = Instance.new("TextButton", tabList)
    b.Size = UDim2.new(1,0,0,24); b.BackgroundColor3 = SIDE; b.Text = name
    b.Font = Enum.Font.GothamMedium; b.TextSize = 10; b.TextColor3 = WHITE
    b.TextXAlignment = Enum.TextXAlignment.Left; b.AutoButtonColor = false
    b.LayoutOrder = order
    local bpad = Instance.new("UIPadding", b); bpad.PaddingLeft = UDim.new(0, 8)
    round(b, 6)

    local page = Instance.new("Frame", main)
    page.Size = UDim2.new(1, -128, 1, -16)
    page.Position = UDim2.fromOffset(122, 8)
    page.BackgroundTransparency = 1; page.Visible = false

    local scroll = Instance.new("ScrollingFrame", page)
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4; scroll.ScrollBarImageColor3 = IS_PREMIUM and GOLD or ACCENT
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local sl = Instance.new("UIListLayout", scroll); sl.Padding = UDim.new(0,5)
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingRight = UDim.new(0, 4); pad.PaddingBottom = UDim.new(0, 4)

    pages[name], tabButtons[name] = page, b
    b.MouseButton1Click:Connect(function() selectTab(name) end)
    return scroll
end

local pgProfile = createTab("Profile", 1)
local pgCombat, pgSkins, pgExtras
local pgVisual = createTab("Visual", 2)
local pgChar = createTab("Character", 3)
local pgSettings = createTab("Settings", 4)

if IS_PREMIUM then
    pgCombat = createTab("Combat", 5)
    pgSkins = createTab("Skins", 6)
    pgExtras = createTab("Extras", 7)
else
    pgExtras = createTab("Extras", 5)
end

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.fromOffset(22,22); closeBtn.Position = UDim2.new(1,-28,0,6)
closeBtn.BackgroundColor3 = PANEL; closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 12; closeBtn.TextColor3 = WHITE
round(closeBtn, 6); closeBtn.ZIndex = 3
closeBtn.MouseButton1Click:Connect(function() menuWrap.Visible = false end)

-- ===== PREVIEW =====
local preview = Instance.new("Frame", menuWrap)
preview.Size = UDim2.fromOffset(PREVIEW_W, BASE_H)
preview.Position = UDim2.fromOffset(BASE_W + 8, 0)
preview.BackgroundColor3 = BG; preview.BorderSizePixel = 0
round(preview, 12)
local pStroke = Instance.new("UIStroke", preview)
pStroke.Color = IS_PREMIUM and GOLD or ACCENT; pStroke.Thickness = 1.5

local pTitle = Instance.new("TextLabel", preview)
pTitle.Size = UDim2.new(1,0,0,20); pTitle.Position = UDim2.fromOffset(0,4)
pTitle.BackgroundTransparency = 1; pTitle.Text = "PREVIEW"
pTitle.Font = Enum.Font.GothamBold; pTitle.TextSize = 12
pTitle.TextColor3 = IS_PREMIUM and GOLD or ACCENT

local canvas = Instance.new("Frame", preview)
canvas.Size = UDim2.new(1, -16, 0, 170)
canvas.Position = UDim2.new(0, 8, 0, 26)
canvas.BackgroundColor3 = Color3.fromRGB(15,15,22)
canvas.BorderSizePixel = 0
round(canvas, 8)

local FOOT_Y = 155
local PART_DEFS = {
    {name="Head",       w=24, h=24, x=-12, y=6,   aim="Head"},
    {name="Torso",      w=30, h=48, x=-15, y=34,  aim="Torso"},
    {name="LeftArm",    w=10, h=48, x=-28, y=34,  aim="Left Arm"},
    {name="RightArm",   w=10, h=48, x=18,  y=34,  aim="Right Arm"},
    {name="LeftLeg",    w=12, h=52, x=-14, y=86,  aim="Left Leg"},
    {name="RightLeg",   w=12, h=52, x=2,   y=86,  aim="Right Leg"},
}
local parts = {}
local baseColor = Color3.fromRGB(80,80,95)
local labelNames = {
    Head="Head", Torso="Torso", LeftArm="L.Arm", RightArm="R.Arm",
    LeftLeg="L.Leg", RightLeg="R.Leg",
}

for _, d in ipairs(PART_DEFS) do
    local f = Instance.new("Frame", canvas)
    f.Size = UDim2.fromOffset(d.w, d.h)
    f.Position = UDim2.new(0.5, d.x, 0, d.y)
    f.BackgroundColor3 = baseColor; f.BorderSizePixel = 0
    round(f, 3); f.ZIndex = 2

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(2,0,0,8)
    lbl.Position = UDim2.new(-0.5,0,1,1)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelNames[d.name] or ""
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 7
    lbl.TextColor3 = Color3.fromRGB(200,200,220)
    lbl.ZIndex = 4

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1
    btn.Text = ""; btn.ZIndex = 3
    parts[d.name] = {frame = f, aim = d.aim, y = d.y, h = d.h}

    btn.MouseButton1Click:Connect(function() AIM_PART = d.aim end)
end

local dot = Instance.new("Frame", canvas)
dot.BackgroundColor3 = RED; dot.BorderSizePixel = 0
dot.Size = UDim2.fromOffset(12, 12)
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Position = UDim2.new(0.5, 0, 0, FOOT_Y)
dot.ZIndex = 5
round(dot, 6)
local dotStroke = Instance.new("UIStroke", dot)
dotStroke.Color = WHITE; dotStroke.Thickness = 1.5; dotStroke.Transparency = 0.3

local currentLaserY = FOOT_Y

local function updatePreviewColors()
    for name, rec in pairs(parts) do
        if rec.aim == AIM_PART then
            rec.frame.BackgroundColor3 = IS_PREMIUM and GOLD or ACCENT
        elseif S.Chams then
            rec.frame.BackgroundColor3 = S.ChamsRainbow and Color3.fromHSV((tick()*0.4)%1,1,1) or chamsColor
        elseif S.Highlight then
            rec.frame.BackgroundColor3 = IS_PREMIUM and GOLD or ACCENT
        else
            rec.frame.BackgroundColor3 = baseColor
        end
    end
end

local statusHolder = Instance.new("Frame", preview)
statusHolder.Size = UDim2.new(1, -16, 0, 90)
statusHolder.Position = UDim2.new(0, 8, 0, 200)
statusHolder.BackgroundColor3 = PANEL; statusHolder.BorderSizePixel = 0
round(statusHolder, 6)

local statusLabels = {}
local statusKeys = {"Chams","ESP","Tracers","Aim","Spin","Highlight"}
for i, k in ipairs(statusKeys) do
    local l = Instance.new("TextLabel", statusHolder)
    l.Size = UDim2.new(1, -10, 0, 14)
    l.Position = UDim2.fromOffset(6, (i-1)*14 + 4)
    l.BackgroundTransparency = 1
    l.Text = k .. ": OFF"
    l.Font = Enum.Font.Gotham; l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = Color3.fromRGB(180,180,200)
    statusLabels[k] = l
end

-- ===== КНОПКА M =====
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.fromOffset(46,46)
openBtn.Position = UDim2.new(0, 10, 0.5, -23)
openBtn.BackgroundColor3 = RED; openBtn.Text = "M"
openBtn.Font = Enum.Font.GothamBlack; openBtn.TextSize = 24; openBtn.TextColor3 = WHITE
openBtn.AutoButtonColor = false; round(openBtn, 23)

do
    local dragging, dragStart, startPos, moved = false, nil, nil, false
    openBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = openBtn.Position; moved = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            if math.abs(d.X) > 3 or math.abs(d.Y) > 3 then moved = true end
            openBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then menuWrap.Visible = not menuWrap.Visible end
            dragging = false
        end
    end)
end

UIS.InputBegan:Connect(function(i,p)
    if not p and i.KeyCode == Enum.KeyCode.RightShift then menuWrap.Visible = not menuWrap.Visible end
end)

do
    local dragging, dragStart, startPos
    sidebar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = menuWrap.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            menuWrap.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- ===== РЕСАЙЗ =====
local resizeHandle = Instance.new("TextButton", main)
resizeHandle.Size = UDim2.fromOffset(16,16); resizeHandle.Position = UDim2.new(1,-18,1,-18)
resizeHandle.BackgroundColor3 = IS_PREMIUM and GOLD or ACCENT
resizeHandle.Text = "="; resizeHandle.Font = Enum.Font.GothamBold
resizeHandle.TextSize = 10; resizeHandle.TextColor3 = WHITE
resizeHandle.AutoButtonColor = false; resizeHandle.ZIndex = 5
round(resizeHandle, 4)

do
    local resizing, startPos, startSize
    resizeHandle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            resizing = true; startPos = i.Position; startSize = main.AbsoluteSize
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startPos
            local newW = math.clamp(startSize.X + d.X, 400, 900)
            local newH = newW / currentRatio
            if newH < 250 then newH = 250; newW = newH * currentRatio end
            main.Size = UDim2.fromOffset(newW, newH)
            preview.Size = UDim2.fromOffset(PREVIEW_W, newH)
            preview.Position = UDim2.fromOffset(newW + 8, 0)
            menuWrap.Size = UDim2.fromOffset(newW + PREVIEW_W + 8, newH)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then resizing = false end
    end)
end

-- ========== UI COMPONENTS ==========
local function createToggle(page, text, key, onChange)
    local row = Instance.new("TextButton", page)
    row.Size = UDim2.new(1,-6,0,30); row.BackgroundColor3 = PANEL
    row.Text = ""; row.AutoButtonColor = false; round(row, 6)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-56,1,0); lbl.Position = UDim2.fromOffset(10,0)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextColor3 = WHITE

    local accent = IS_PREMIUM and GOLD or ACCENT
    local pill = Instance.new("Frame", row)
    pill.Size = UDim2.fromOffset(36,18); pill.Position = UDim2.new(1,-44,0.5,-9)
    pill.BackgroundColor3 = S[key] and accent or OFF; round(pill, 9)

    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.fromOffset(14,14)
    knob.Position = S[key] and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2)
    knob.BackgroundColor3 = WHITE; round(knob, 7)

    row.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        local on = S[key]
        TS:Create(pill, TweenInfo.new(0.15), {BackgroundColor3 = on and accent or OFF}):Play()
        TS:Create(knob, TweenInfo.new(0.15), {Position = on and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2)}):Play()
        if onChange then onChange(on) end
        updatePreviewColors()
    end)
end

local function createSlider(page, text, mn, mx, init, fmt, onChange)
    local row = Instance.new("Frame", page)
    row.Size = UDim2.new(1,-6,0,42); row.BackgroundColor3 = PANEL; round(row, 6)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-60,0,18); lbl.Position = UDim2.fromOffset(10,3)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextColor3 = WHITE
    local val = Instance.new("TextLabel", row)
    val.Size = UDim2.fromOffset(56,18); val.Position = UDim2.new(1,-62,0,3)
    val.BackgroundTransparency = 1; val.Text = string.format(fmt, init)
    val.Font = Enum.Font.GothamBold; val.TextSize = 11
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.TextColor3 = IS_PREMIUM and GOLD or ACCENT

    local bar = Instance.new("Frame", row)
    bar.Size = UDim2.new(1,-20,0,6); bar.Position = UDim2.new(0,10,0,28)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,76); round(bar, 3)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((init-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3 = IS_PREMIUM and GOLD or ACCENT; round(fill, 3)

    local drag = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
            local v = mn + (mx-mn)*rel
            fill.Size = UDim2.new(rel,0,1,0)
            val.Text = string.format(fmt, v)
            if onChange then onChange(v) end
        end
    end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
end

local function createColorPicker(page, titleText, initialColor, onSelect)
    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1,-6,0,18); title.BackgroundTransparency = 1
    title.Text = titleText; title.Font = Enum.Font.GothamBold; title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Left; title.TextColor3 = WHITE

    local gridHolder = Instance.new("Frame", page)
    gridHolder.Size = UDim2.new(1,-6,0,80); gridHolder.BackgroundColor3 = PANEL
    round(gridHolder, 6)

    local grid = Instance.new("UIGridLayout", gridHolder)
    grid.CellSize = UDim2.fromOffset(48,28); grid.CellPadding = UDim2.fromOffset(4,4)
    local gridPad = Instance.new("UIPadding", gridHolder)
    gridPad.PaddingLeft = UDim.new(0,4); gridPad.PaddingTop = UDim.new(0,4)

    for _, c in ipairs(ColorPalette) do
        local b = Instance.new("TextButton", gridHolder)
        b.BackgroundColor3 = c.color; b.Text = ""
        b.AutoButtonColor = false; round(b, 5)
        b.MouseButton1Click:Connect(function()
            onSelect(c.color, c.name)
            updatePreviewColors()
        end)
    end
end

-- ========== PROFILE ==========
do
    local info = Instance.new("Frame", pgProfile)
    info.Size = UDim2.new(1,-6,0,72); info.BackgroundColor3 = PANEL; round(info, 8)
    local t1 = Instance.new("TextLabel", info)
    t1.Size = UDim2.new(1,-10,0,20); t1.Position = UDim2.fromOffset(10,6)
    t1.BackgroundTransparency = 1
    t1.Text = IS_PREMIUM and "DR HUB premium" or "DR HUB free"
    t1.Font = Enum.Font.GothamBold; t1.TextSize = 15
    t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.TextColor3 = IS_PREMIUM and GOLD or ACCENT
    local t2 = Instance.new("TextLabel", info)
    t2.Size = UDim2.new(1,-10,0,14); t2.Position = UDim2.fromOffset(10,28)
    t2.BackgroundTransparency = 1; t2.Text = "Welcome, " .. LP.Name
    t2.Font = Enum.Font.Gotham; t2.TextSize = 10
    t2.TextXAlignment = Enum.TextXAlignment.Left; t2.TextColor3 = Color3.fromRGB(200,200,220)
    local t3 = Instance.new("TextLabel", info)
    t3.Size = UDim2.new(1,-10,0,14); t3.Position = UDim2.fromOffset(10,46)
    t3.BackgroundTransparency = 1; t3.Text = "Aim part: " .. AIM_PART
    t3.Font = Enum.Font.Gotham; t3.TextSize = 10
    t3.TextXAlignment = Enum.TextXAlignment.Left; t3.TextColor3 = Color3.fromRGB(180,180,200)
    RunService.RenderStepped:Connect(function()
        t3.Text = "Aim part: " .. AIM_PART
    end)
end

-- ========== VISUAL FUNCS ==========
local function applyChams(p)
    if p == LP or not p.Character then return end
    local h = p.Character:FindFirstChild("DH_Chams")
    if S.Chams then
        if not h then
            h = Instance.new("Highlight", p.Character)
            h.Name = "DH_Chams"; h.Adornee = p.Character
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
        h.FillColor = chamsColor; h.OutlineColor = chamsColor
        h.FillTransparency = chamsTransparency; h.OutlineTransparency = 0
    elseif h then h:Destroy() end
end

local function applyHL(p)
    if p == LP or not p.Character then return end
    local h = p.Character:FindFirstChild("DH_HL")
    if S.Highlight then
        if not h then
            h = Instance.new("Highlight", p.Character)
            h.Name = "DH_HL"; h.Adornee = p.Character
        end
        h.FillColor = IS_PREMIUM and GOLD or ACCENT
        h.OutlineColor = WHITE; h.FillTransparency = 0.6
    elseif h then h:Destroy() end
end

local function refreshVisuals()
    for _, p in ipairs(Players:GetPlayers()) do applyHL(p); applyChams(p) end
end

local function recolorChams()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("DH_Chams")
            if h then h.FillColor = chamsColor; h.OutlineColor = chamsColor; h.FillTransparency = chamsTransparency end
        end
    end
end

local function createESPObjects(p)
    if not hasDrawing then return end
    if espObjects[p] then
        if espObjects[p].name then espObjects[p].name:Remove() end
        if espObjects[p].dist then espObjects[p].dist:Remove() end
    end
    if tracerObjects[p] then tracerObjects[p]:Remove() end

    local nameTag = Drawing.new("Text"); nameTag.Size = 14; nameTag.Center = true
    nameTag.Outline = true; nameTag.Color = WHITE; nameTag.Visible = false
    local distTag = Drawing.new("Text"); distTag.Size = 13; distTag.Center = true
    distTag.Outline = true; distTag.Color = Color3.fromRGB(255,220,100); distTag.Visible = false
    local line = Drawing.new("Line"); line.Thickness = 2
    line.Color = tracerColor; line.Transparency = 1; line.Visible = false

    espObjects[p] = {name = nameTag, dist = distTag}
    tracerObjects[p] = line
end

local function removeESP(p)
    if espObjects[p] then
        if espObjects[p].name then espObjects[p].name:Remove() end
        if espObjects[p].dist then espObjects[p].dist:Remove() end
        espObjects[p] = nil
    end
    if tracerObjects[p] then tracerObjects[p]:Remove(); tracerObjects[p] = nil end
end

local function hookPlayer(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5); applyHL(p); applyChams(p); createESPObjects(p)
    end)
    if p.Character then createESPObjects(p) end
end
for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(removeESP)

-- ========== HAT + TRAIL ==========
local function getChar() return LP.Character end

local function clearHat()
    local ch = getChar(); if not ch then return end
    local old = ch:FindFirstChild("DH_Hat")
    if old then old:Destroy() end
end

local function makeHat()
    local ch = getChar(); if not ch then return end
    clearHat()
    if not S.Hat then return end
    local head = ch:FindFirstChild("Head")
    if not head then return end

    local model = Instance.new("Model")
    model.Name = "DH_Hat"

    local brim = Instance.new("Part")
    brim.Name = "Brim"
    brim.Shape = Enum.PartType.Cylinder
    brim.Size = Vector3.new(0.2, 2.4, 2.4)
    brim.Color = hatColor
    brim.Material = Enum.Material.SmoothPlastic
    brim.CanCollide = false
    brim.Massless = true
    brim.TopSurface = Enum.SurfaceType.Smooth
    brim.BottomSurface = Enum.SurfaceType.Smooth
    brim.Parent = model

    local cone = Instance.new("Part")
    cone.Name = "Cone"
    cone.Size = Vector3.new(1.2, 1.2, 1.2)
    cone.Color = hatColor
    cone.Material = Enum.Material.SmoothPlastic
    cone.CanCollide = false
    cone.Massless = true
    cone.TopSurface = Enum.SurfaceType.Smooth
    cone.BottomSurface = Enum.SurfaceType.Smooth
    cone.Parent = model
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://168892491"
    mesh.Scale = Vector3.new(1.6, 1.2, 1.6)
    mesh.Parent = cone

    model.Parent = ch
    brim.CFrame = head.CFrame * CFrame.new(0, 0.6, 0) * CFrame.Angles(0, 0, math.rad(90))
    cone.CFrame = head.CFrame * CFrame.new(0, 1.2, 0)

    local weld1 = Instance.new("WeldConstraint")
    weld1.Part0 = head; weld1.Part1 = brim; weld1.Parent = brim
    local weld2 = Instance.new("WeldConstraint")
    weld2.Part0 = head; weld2.Part1 = cone; weld2.Parent = cone
end

local function clearTrail()
    local ch = getChar(); if not ch then return end
    for _, obj in ipairs(ch:GetChildren()) do
        if obj.Name == "DH_TrailA" then obj:Destroy() end
    end
    for _, obj in ipairs(ch:GetDescendants()) do
        if obj.Name == "DH_TrailAttach" then obj:Destroy() end
    end
end

local function makeTrail()
    local ch = getChar(); if not ch then return end
    clearTrail()
    if not S.Trail then return end

    local hrp = ch:FindFirstChild("HumanoidRootPart")
    local head = ch:FindFirstChild("Head")
    if not hrp or not head then return end

    local a0 = Instance.new("Attachment")
    a0.Name = "DH_TrailAttach"
    a0.Parent = head
    a0.Position = Vector3.new(0, 0.5, 0)

    local a1 = Instance.new("Attachment")
    a1.Name = "DH_TrailAttach"
    a1.Parent = hrp
    a1.Position = Vector3.new(0, 0, 0)

    local trail = Instance.new("Trail")
    trail.Name = "DH_TrailA"
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Lifetime = 0.8
    trail.MinLength = 0
    trail.FaceCamera = true
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, trailColor),
        ColorSequenceKeypoint.new(0.5, trailColor2),
        ColorSequenceKeypoint.new(1, trailColor),
    })
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })
    trail.Parent = ch
end

-- ========== AIMBOT (хороший) ==========
local AIM_MAP = {
    ["Head"]={"Head"}, ["Torso"]={"Torso","UpperTorso","LowerTorso"},
    ["Left Arm"]={"Left Arm","LeftUpperArm","LeftLowerArm"},
    ["Right Arm"]={"Right Arm","RightUpperArm","RightLowerArm"},
    ["Left Leg"]={"Left Leg","LeftUpperLeg","LeftLowerLeg"},
    ["Right Leg"]={"Right Leg","RightUpperLeg","RightLowerLeg"},
}

local function getBodyPart(char)
    local list = AIM_MAP[AIM_PART] or {"Head"}
    for _, n in ipairs(list) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    return char:FindFirstChild("Head")
end

local function isPlayerVisible(part)
    if not S.WallCheck then return true end
    local origin = Cam.CFrame.Position
    local myChar = LP.Character
    if myChar and myChar:FindFirstChild("Head") then
        origin = myChar.Head.Position
    end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {LP.Character, Cam}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local res = workspace:Raycast(origin, part.Position - origin, rp)
    if res then
        return res.Instance:IsDescendantOf(part.Parent)
    end
    return true
end

local function getTarget()
    local center = Cam.ViewportSize / 2
    local best, bestDist = nil, aimFovSize
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hu = plr.Character:FindFirstChildOfClass("Humanoid")
            local part = getBodyPart(plr.Character)
            if part and hu and hu.Health > 0 and isPlayerVisible(part) then
                local pos, onScreen = Cam:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < bestDist then
                        best, bestDist = part, dist
                    end
                end
            end
        end
    end
    return best
end

if hasDrawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 2
    fovCircle.NumSides = 64
    fovCircle.Radius = aimFovSize
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.Color = GOLD
    fovCircle.Visible = false
end

-- ========== COMBAT (premium) ==========
if IS_PREMIUM and pgCombat then
    createToggle(pgCombat, "Aim Assist (RMB)", "Aim")
    createToggle(pgCombat, "Snap Aim (instant)", "Snap")
    createToggle(pgCombat, "Show FOV Circle", "FOVCircle")
    createToggle(pgCombat, "Wall Check (Raycast)", "WallCheck")
    createSlider(pgCombat, "FOV Size", 50, 500, aimFovSize, "%.0f", function(v)
        aimFovSize = v
        if fovCircle then fovCircle.Radius = v end
    end)
    createSlider(pgCombat, "Aim Smoothness", 0.05, 1, aimSmooth, "%.2f", function(v)
        aimSmooth = v
    end)
    local hint = Instance.new("TextLabel", pgCombat)
    hint.Size = UDim2.new(1,-6,0,28); hint.BackgroundColor3 = PANEL
    hint.Text = "Target part -> chosen in PREVIEW (right)"
    hint.Font = Enum.Font.Gotham; hint.TextSize = 10
    hint.TextColor3 = Color3.fromRGB(200,200,220)
    hint.TextWrapped = true
    round(hint, 6)
end

-- ========== VISUAL ==========
createToggle(pgVisual, "ESP (nick)", "ESP")
createToggle(pgVisual, "maga kotakbas", "ESPDist")
createToggle(pgVisual, "Tracers", "Tracers")
createToggle(pgVisual, "Highlight", "Highlight", refreshVisuals)
createColorPicker(pgVisual, "Nick color:", espColor, function(c) espColor = c end)
createColorPicker(pgVisual, "Tracer color:", tracerColor, function(c) tracerColor = c end)
createToggle(pgVisual, "Chams", "Chams", refreshVisuals)
createToggle(pgVisual, "LGBT Chams", "ChamsRainbow")
createSlider(pgVisual, "Chams Transp", 0, 0.9, chamsTransparency, "%.2f", function(v)
    chamsTransparency = v; recolorChams()
end)
createColorPicker(pgVisual, "Chams color:", chamsColor, function(c)
    chamsColor = c; S.ChamsRainbow = false; recolorChams()
end)

-- ========== EXTRAS ==========
if pgExtras then
    createToggle(pgExtras, "Chinese Hat", "Hat", function() makeHat() end)
    createColorPicker(pgExtras, "Hat color:", hatColor, function(c) hatColor = c; if S.Hat then makeHat() end end)

    createToggle(pgExtras, "Trail", "Trail", function() makeTrail() end)
    createColorPicker(pgExtras, "Trail color A:", trailColor, function(c) trailColor = c; if S.Trail then makeTrail() end end)
    createColorPicker(pgExtras, "Trail color B:", trailColor2, function(c) trailColor2 = c; if S.Trail then makeTrail() end end)
end

-- ========== CHARACTER ==========
local function applyTP()
    if not LP.Character then return end
    if S.ThirdPerson then
        LP.CameraMode = Enum.CameraMode.Classic
        LP.CameraMinZoomDistance = 8; LP.CameraMaxZoomDistance = 20
        local hu = LP.Character:FindFirstChildOfClass("Humanoid")
        if hu then Cam.CameraSubject = hu; Cam.CameraType = Enum.CameraType.Custom end
    else
        LP.CameraMinZoomDistance = 0.5; LP.CameraMaxZoomDistance = 0.5
        LP.CameraMode = Enum.CameraMode.LockFirstPerson
        local hu = LP.Character:FindFirstChildOfClass("Humanoid")
        if hu then Cam.CameraSubject = hu end
    end
end

createToggle(pgChar, "Third Person", "ThirdPerson", function(on) applyTP() end)
createToggle(pgChar, "Spin", "Spin", function(on)
    local ch = LP.Character
    local hu = ch and ch:FindFirstChildOfClass("Humanoid")
    if hu then hu.AutoRotate = not on end
end)
createSlider(pgChar, "Spin Speed", 1, 100, spinSpeed, "%.0f", function(v) spinSpeed = v end)
createSlider(pgChar, "Camera FOV", 50, 110, defaultFov, "%.0f", function(v) Cam.FieldOfView = v end)

-- ========== SKINS ==========
if IS_PREMIUM and pgSkins then
    local function resetSkin()
        for part, d in pairs(charOriginals) do
            if part.Parent then part.Color, part.Material, part.Transparency = d.c, d.m, d.t end
        end
        charOriginals = {}; lastSkin = nil
    end
    local function applySkin(c, m, t)
        lastSkin = {c = c, m = m, t = t}
        local ch = LP.Character; if not ch then return end
        for _, part in ipairs(ch:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart"
                and part.Name ~= "Brim" and part.Name ~= "Cone" then
                if not charOriginals[part] then
                    charOriginals[part] = {c = part.Color, m = part.Material, t = part.Transparency}
                end
                part.Color = c; part.Material = m
                if t then part.Transparency = t end
            end
        end
    end
    local holder = Instance.new("Frame", pgSkins)
    holder.Size = UDim2.new(1,-6,0,180); holder.BackgroundTransparency = 1
    local grid = Instance.new("UIGridLayout", holder)
    grid.CellSize = UDim2.fromOffset(110,28); grid.CellPadding = UDim2.fromOffset(5,5)
    local list = {
        {"Gold", function() applySkin(Color3.fromRGB(255,200,40), Enum.Material.Metal) end},
        {"Neon", function() applySkin(GOLD, Enum.Material.Neon) end},
        {"Ice", function() applySkin(Color3.fromRGB(150,220,255), Enum.Material.Ice) end},
        {"Ghost", function() applySkin(Color3.fromRGB(230,230,255), Enum.Material.ForceField, 0.3) end},
        {"Lava", function() applySkin(Color3.fromRGB(255,80,20), Enum.Material.CrackedLava) end},
        {"Black", function() applySkin(Color3.fromRGB(20,20,20), Enum.Material.Plastic) end},
        {"Reset", resetSkin},
    }
    for _, it in ipairs(list) do
        local b = Instance.new("TextButton", holder)
        b.BackgroundColor3 = PANEL; b.Text = it[1]
        b.Font = Enum.Font.GothamMedium; b.TextSize = 11; b.TextColor3 = WHITE
        round(b, 6); b.MouseButton1Click:Connect(it[2])
    end
end

-- ========== SETTINGS ==========
do
    local resetBtn = Instance.new("TextButton", pgSettings)
    resetBtn.Size = UDim2.new(1,-6,0,30); resetBtn.BackgroundColor3 = PANEL
    resetBtn.Text = "Reset Menu Size"; resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 11; resetBtn.TextColor3 = WHITE
    round(resetBtn, 6)
    resetBtn.MouseButton1Click:Connect(function()
        main.Size = UDim2.fromOffset(BASE_W, BASE_H)
        preview.Size = UDim2.fromOffset(PREVIEW_W, BASE_H)
        preview.Position = UDim2.fromOffset(BASE_W + 8, 0)
        menuWrap.Size = UDim2.fromOffset(BASE_W + PREVIEW_W + 8, BASE_H)
        menuWrap.Position = UDim2.new(0.5, -(BASE_W+PREVIEW_W+8)/2, 0.5, -BASE_H/2)
    end)
    local credit = Instance.new("TextLabel", pgSettings)
    credit.Size = UDim2.new(1,-6,0,40); credit.BackgroundTransparency = 1
    credit.Text = (IS_PREMIUM and "DR HUB premium" or "DR HUB free") .. "\nby Assistant"
    credit.Font = Enum.Font.Gotham; credit.TextSize = 10
    credit.TextColor3 = Color3.fromRGB(150,150,170)
    credit.TextWrapped = true
end

-- ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function(dt)
    Cam = workspace.CurrentCamera

    local tY = 4
    for name, rec in pairs(parts) do
        if rec.aim == AIM_PART then tY = rec.y + rec.h / 2; break end
    end
    currentLaserY = currentLaserY + (tY - currentLaserY) * math.min(dt * 6, 1)
    dot.Position = UDim2.new(0.5, 0, 0, currentLaserY)
    if S.Aim then
        local pulse = 1 + math.sin(tick()*6) * 0.25
        dot.Size = UDim2.fromOffset(12 * pulse, 12 * pulse)
        dot.BackgroundColor3 = RED:Lerp(GOLD, (math.sin(tick()*5)+1)/2)
        dotStroke.Transparency = 0
    else
        dot.Size = UDim2.fromOffset(12, 12)
        dot.BackgroundColor3 = RED
        dotStroke.Transparency = 0.3
    end

    if S.ChamsRainbow then updatePreviewColors() end

    statusLabels.Chams.Text = "Chams: " .. (S.Chams and "ON" or "OFF")
    statusLabels.ESP.Text = "ESP: " .. (S.ESP and "ON" or "OFF")
    statusLabels.Tracers.Text = "Tracers: " .. (S.Tracers and "ON" or "OFF")
    statusLabels.Aim.Text = "Aim: " .. (S.Aim and "ON" or "OFF") .. " -> " .. AIM_PART
    statusLabels.Spin.Text = "Spin: " .. (S.Spin and "ON" or "OFF")
    statusLabels.Highlight.Text = "Highlight: " .. (S.Highlight and "ON" or "OFF")

    if IS_PREMIUM then
        if fovCircle then
            fovCircle.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
            fovCircle.Radius = aimFovSize
            fovCircle.Visible = S.FOVCircle and S.Aim
        end

        local aiming = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UIS.TouchEnabled

        if S.Aim and aiming then
            local t = getTarget()
            if t then
                local goal = CFrame.lookAt(Cam.CFrame.Position, t.Position)
                if S.Snap then
                    Cam.CFrame = goal
                else
                    Cam.CFrame = Cam.CFrame:Lerp(goal, aimSmooth)
                end
            end
        end
    end

    if S.Spin then
        local ch = LP.Character
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
        end
    end
end)

-- ESP render
RunService.RenderStepped:Connect(function()
    if not hasDrawing then return end
    for p, obj in pairs(espObjects) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("HumanoidRootPart") then
            local headPos = p.Character.Head.Position
            local rootPos = p.Character.HumanoidRootPart.Position
            local sp, on = Cam:WorldToViewportPoint(headPos)
            if on then
                local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local dist = 0
                if myPos then dist = (myPos.Position - rootPos).Magnitude end
                if S.ESP then
                    obj.name.Text = p.Name
                    obj.name.Position = Vector2.new(sp.X, sp.Y - 20)
                    obj.name.Color = espColor
                    obj.name.Visible = true
                    if S.ESPDist then
                        obj.dist.Text = string.format("[%d m]", math.floor(dist))
                        obj.dist.Position = Vector2.new(sp.X, sp.Y - 4)
                        obj.dist.Visible = true
                    else obj.dist.Visible = false end
                else
                    obj.name.Visible = false; obj.dist.Visible = false
                end
                if S.Tracers then
                    local line = tracerObjects[p]
                    if line then
                        line.From = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y)
                        line.To = Vector2.new(sp.X, sp.Y)
                        line.Color = tracerColor
                        line.Visible = true
                    end
                else
                    if tracerObjects[p] then tracerObjects[p].Visible = false end
                end
            else
                obj.name.Visible = false; obj.dist.Visible = false
                if tracerObjects[p] then tracerObjects[p].Visible = false end
            end
        end
    end
end)

-- Respawn
LP.CharacterAdded:Connect(function()
    task.wait(0.6)
    applyTP()
    local hu = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hu then hu.AutoRotate = not S.Spin end
    task.wait(0.3)
    refreshVisuals()
    if IS_PREMIUM and lastSkin then
        task.wait(0.2)
        local ch = LP.Character
        if ch then
            for _, part in ipairs(ch:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart"
                    and part.Name ~= "Brim" and part.Name ~= "Cone" then
                    charOriginals[part] = {c = part.Color, m = part.Material, t = part.Transparency}
                    part.Color = lastSkin.c; part.Material = lastSkin.m
                    if lastSkin.t then part.Transparency = lastSkin.t end
                end
            end
        end
    end
    task.wait(0.2)
    if S.Hat then makeHat() end
    if S.Trail then makeTrail() end
end)

task.spawn(function()
    task.wait(1)
    if S.Hat then makeHat() end
    if S.Trail then makeTrail() end
end)

selectTab("Profile")
print(IS_PREMIUM and "DR HUB premium loaded!" or "DR HUB free loaded!")
