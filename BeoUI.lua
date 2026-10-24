--[[
    BeoUI v2 — BeoHub style UI lib
    - Smooth open/close animation (scale + fade)
    - Accent pulse, card polish, toggle/button tweens
    Usage:
        local BeoUI = loadstring(game:HttpGet("RAW_URL"))()
        local Win = BeoUI:CreateWindow({ Title = "BeoHub v7", Tag = "KEYLESS", Logo = 12053823591 })
        local Tab = Win:Tab("Fish", "🎣")
        Tab:Toggle("Auto Cast", false, function(v) end)
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer

local BeoUI = {}
BeoUI.__index = BeoUI

local Theme = {
    Accent = Color3.fromRGB(0, 220, 255),
    Accent2 = Color3.fromRGB(80, 255, 200),
    Bg = Color3.fromRGB(9, 11, 16),
    Side = Color3.fromRGB(13, 16, 24),
    Card = Color3.fromRGB(18, 22, 34),
    Soft = Color3.fromRGB(26, 32, 46),
    Text = Color3.fromRGB(235, 240, 250),
    Muted = Color3.fromRGB(115, 125, 145),
    Danger = Color3.fromRGB(220, 100, 120),
}

local function N(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        o[k] = v
    end
    if parent then o.Parent = parent end
    return o
end

local function Corner(p, r)
    return N("UICorner", { CornerRadius = UDim.new(0, r or 8) }, p)
end

local function Stroke(p, color, thick, trans)
    return N("UIStroke", {
        Color = color or Theme.Accent,
        Thickness = thick or 1,
        Transparency = trans or 0.4,
    }, p)
end

local function Tween(obj, t, props, style, dir)
    local ti = TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

local function makeDrag(frame, handle)
    local dragging, startMouse, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startMouse = i.Position
            startPos = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - startMouse
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

function BeoUI:CreateWindow(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "BeoHub"
    local tagText = cfg.Tag or "KEYLESS"
    local logoId = cfg.Logo or 12053823591
    local size = cfg.Size or UDim2.fromOffset(430, 360)
    local guiName = cfg.Name or ("BeoUI_" .. tostring(math.random(1000, 9999)))

    pcall(function()
        for _, g in ipairs({ CoreGui, lp:FindFirstChild("PlayerGui") }) do
            if g then
                local old = g:FindFirstChild(guiName)
                if old then old:Destroy() end
            end
        end
    end)

    local gui = N("ScreenGui", {
        Name = guiName,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 50,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

    local bubble = N("TextButton", {
        Size = UDim2.fromOffset(52, 52),
        Position = UDim2.new(0.03, 0, 0.42, 0),
        BackgroundColor3 = Theme.Bg,
        BackgroundTransparency = 0.05,
        Text = "B",
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBlack,
        TextSize = 21,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 10,
    }, gui)
    Corner(bubble, 26)
    local bStroke = Stroke(bubble, Theme.Accent, 2, 0.2)

    local glow = N("Frame", {
        Size = UDim2.fromOffset(62, 62),
        Position = UDim2.fromOffset(-5, -5),
        BackgroundTransparency = 1,
        ZIndex = 9,
    }, bubble)
    local glowStroke = Stroke(glow, Theme.Accent, 3, 0.75)
    Corner(glow, 31)

    local main = N("Frame", {
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
        BackgroundColor3 = Theme.Bg,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        Visible = false,
        Active = true,
        ClipsDescendants = true,
        ZIndex = 5,
    }, gui)
    Corner(main, 18)
    local mainStroke = Stroke(main, Color3.fromRGB(0, 200, 245), 1.5, 0.45)
    local mainGrad = N("UIGradient", { Rotation = 130 }, main)
    mainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 18, 28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 9, 14)),
    })
    local scale = N("UIScale", { Scale = 0.86 }, main)

    local accent = N("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, main)
    local ag = N("UIGradient", {}, accent)
    ag.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.05),
        NumberSequenceKeypoint.new(1, 1),
    })

    local tbar = N("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 6,
    }, main)

    local logoWrap = N("Frame", {
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(0, 12, 0.5, -16),
        BackgroundColor3 = Theme.Soft,
        BorderSizePixel = 0,
        ZIndex = 7,
    }, tbar)
    Corner(logoWrap, 9)
    Stroke(logoWrap, Theme.Accent, 1, 0.4)
    N("ImageLabel", {
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.fromOffset(2, 2),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. tostring(logoId),
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 8,
    }, logoWrap)

    N("TextLabel", {
        Size = UDim2.new(1, -130, 1, 0),
        Position = UDim2.new(0, 52, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(245, 248, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7,
    }, tbar)

    local tag = N("TextLabel", {
        Size = UDim2.fromOffset(52, 17),
        Position = UDim2.new(0, 148, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(0, 140, 180),
        BackgroundTransparency = 0.55,
        Text = tagText,
        TextColor3 = Color3.fromRGB(140, 240, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        ZIndex = 7,
    }, tbar)
    Corner(tag, 6)

    local closeB = N("TextButton", {
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        BackgroundColor3 = Color3.fromRGB(40, 28, 34),
        Text = "x",
        TextColor3 = Theme.Danger,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 7,
    }, tbar)
    Corner(closeB, 9)

    local side = N("Frame", {
        Size = UDim2.new(0, 56, 1, -58),
        Position = UDim2.new(0, 8, 0, 50),
        BackgroundColor3 = Theme.Side,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, main)
    Corner(side, 14)
    Stroke(side, Color3.fromRGB(40, 50, 70), 1, 0.6)

    local cont = N("ScrollingFrame", {
        Size = UDim2.new(1, -78, 1, -62),
        Position = UDim2.new(0, 72, 0, 52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 6,
    }, main)
    N("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, cont)
    N("UIPadding", {
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 4),
    }, cont)

    makeDrag(main, tbar)
    makeDrag(bubble, bubble)
local opened = false
local animating = false

local function setOpen(v)
    if animating or v == opened then return end
    animating = true
    opened = v
    if opened then
        main.Visible = true
        scale.Scale = 0.88
        main.BackgroundTransparency = 0.35
        mainStroke.Transparency = 0.8
        Tween(scale, 0.32, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Tween(main, 0.28, { BackgroundTransparency = 0.04 }, Enum.EasingStyle.Quint)
        Tween(mainStroke, 0.3, { Transparency = 0.4 })
        Tween(bStroke, 0.2, { Color = Theme.Accent2, Transparency = 0.05 })
        Tween(bubble, 0.2, { TextColor3 = Theme.Accent2 })
        bubble.Text = "x"
        task.delay(0.35, function() animating = false end)
    else
        Tween(scale, 0.22, { Scale = 0.9 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        Tween(main, 0.22, { BackgroundTransparency = 0.4 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        Tween(mainStroke, 0.2, { Transparency = 0.85 })
        Tween(bStroke, 0.2, { Color = Theme.Accent, Transparency = 0.2 })
        Tween(bubble, 0.2, { TextColor3 = Theme.Accent })
        bubble.Text = "B"
        task.delay(0.24, function()
            if not opened then main.Visible = false end
            animating = false
        end)
    end
end

bubble.MouseButton1Click:Connect(function() setOpen(not opened) end)
closeB.MouseButton1Click:Connect(function() setOpen(false) end)

task.spawn(function()
    while gui.Parent do
        if not opened then
            local pulse = (math.sin(os.clock() * 2.2) + 1) * 0.5
            bStroke.Transparency = 0.15 + pulse * 0.25
            glowStroke.Transparency = 0.65 + pulse * 0.25
        end
        task.wait(0.04)
    end
end)

task.spawn(function()
    while gui.Parent do
        local hue = (os.clock() * 0.12) % 1
        accent.BackgroundColor3 = Color3.fromHSV(hue * 0.15 + 0.5, 0.85, 1)
        if opened then
            mainStroke.Color = Color3.fromHSV(hue * 0.12 + 0.5, 0.7, 1)
        end
        task.wait(0.05)
    end
end)

local tabs, pages = {}, {}
local tabOrder = 0

local function clearCont()
    for _, c in ipairs(cont:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
end

local function openPage(name)
    clearCont()
    for n, b in pairs(tabs) do
        local active = n == name
        Tween(b, 0.18, { BackgroundColor3 = active and Color3.fromRGB(22, 36, 54) or Theme.Side })
        local ic = b:FindFirstChild("Icon")
        if ic then Tween(ic, 0.18, { TextColor3 = active and Theme.Accent or Theme.Muted }) end
    end
    if pages[name] then
        pages[name](cont)
        for _, c in ipairs(cont:GetChildren()) do
            if c:IsA("GuiObject") and not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
                if c:IsA("TextLabel") then
                    c.TextTransparency = 0.45
                    Tween(c, 0.2, { TextTransparency = 0 })
                elseif c:IsA("Frame") or c:IsA("TextButton") then
                    local old = c.BackgroundTransparency
                    c.BackgroundTransparency = math.min(old + 0.3, 0.85)
                    Tween(c, 0.22, { BackgroundTransparency = old })
                end
            end
        end
    end
end

local Window = { Gui = gui, Main = main }

function Window:Tab(name, icon)
    tabOrder = tabOrder + 1
    local order = tabOrder
    local b = N("TextButton", {
        Size = UDim2.new(1, -10, 0, 42),
        Position = UDim2.new(0, 5, 0, 6 + (order - 1) * 48),
        BackgroundColor3 = Theme.Side,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 7,
    }, side)
    Corner(b, 11)
    N("TextLabel", {
        Name = "Icon",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = icon or "*",
        TextColor3 = Theme.Muted,
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        ZIndex = 8,
    }, b)
    tabs[name] = b
    b.MouseButton1Click:Connect(function() openPage(name) end)

    local builders = {}
    local layoutOrder = 0
    local function nextOrder()
        layoutOrder = layoutOrder + 1
        return layoutOrder
    end
    local Tab = {}

    function Tab:Section(text)
        builders[#builders + 1] = function(parent)
            N("TextLabel", {
                Size = UDim2.new(1, -4, 0, 22),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = nextOrder(),
                ZIndex = 7,
            }, parent)
        end
        return Tab
    end

    function Tab:Toggle(text, default, callback)
        local state = default and true or false
        builders[#builders + 1] = function(parent)
            local r = N("Frame", {
                Size = UDim2.new(1, -4, 0, 36),
                BackgroundColor3 = Theme.Card,
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                ZIndex = 7,
            }, parent)
            Corner(r, 10)
            Stroke(r, Color3.fromRGB(40, 50, 70), 1, 0.65)
            N("TextLabel", {
                Size = UDim2.new(1, -72, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8,
            }, r)
            local btn = N("TextButton", {
                Size = UDim2.new(0, 50, 0, 26),
                Position = UDim2.new(1, -58, 0.5, -13),
                BorderSizePixel = 0,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                AutoButtonColor = false,
                ZIndex = 8,
            }, r)
            Corner(btn, 13)
            local function paint(animate)
                if state then
                    btn.Text = "ON"
                    if animate then
                        Tween(btn, 0.15, { BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(8, 12, 18) })
                    else
                        btn.BackgroundColor3 = Theme.Accent
                        btn.TextColor3 = Color3.fromRGB(8, 12, 18)
                    end
                else
                    btn.Text = "OFF"
                    if animate then
                        Tween(btn, 0.15, { BackgroundColor3 = Color3.fromRGB(38, 44, 58), TextColor3 = Theme.Muted })
                    else
                        btn.BackgroundColor3 = Color3.fromRGB(38, 44, 58)
                        btn.TextColor3 = Theme.Muted
                    end
                end
            end
            paint(false)
            btn.MouseButton1Click:Connect(function()
                state = not state
                paint(true)
                if callback then pcall(callback, state) end
            end)
        end
        return Tab
    end

    function Tab:Slider(text, min, max, default, callback)
        local value = tonumber(default) or min
        builders[#builders + 1] = function(parent)
            local r = N("Frame", {
                Size = UDim2.new(1, -4, 0, 52),
                BackgroundColor3 = Theme.Card,
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                ZIndex = 7,
            }, parent)
            Corner(r, 10)
            Stroke(r, Color3.fromRGB(40, 50, 70), 1, 0.65)
            local lab = N("TextLabel", {
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1,
                Text = text .. " : " .. tostring(value),
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8,
            }, r)
            local bar = N("Frame", {
                Size = UDim2.new(1, -24, 0, 5),
                Position = UDim2.new(0, 12, 1, -14),
                BackgroundColor3 = Color3.fromRGB(36, 42, 56),
                BorderSizePixel = 0,
                ZIndex = 8,
            }, r)
            Corner(bar, 3)
            local fill = N("Frame", {
                Size = UDim2.new((value - min) / math.max(max - min, 0.001), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 9,
            }, bar)
            Corner(fill, 3)
            local knob = N("Frame", {
                Size = UDim2.fromOffset(12, 12),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new((value - min) / math.max(max - min, 0.001), 0, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(240, 250, 255),
                BorderSizePixel = 0,
                ZIndex = 10,
            }, bar)
            Corner(knob, 6)
            local hit = N("TextButton", {
                Size = UDim2.new(1, 0, 3, 0),
                Position = UDim2.new(0, 0, -1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 11,
            }, bar)
            local function apply(rel)
                rel = math.clamp(rel, 0, 1)
                local step = (max - min) <= 5 and 0.05 or 1
                local val = min + (max - min) * rel
                if step >= 1 then val = math.floor(val + 0.5)
                else val = math.floor(val / step + 0.5) * step; val = math.floor(val * 100 + 0.5) / 100 end
                value = val
                fill.Size = UDim2.new(rel, 0, 1, 0)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                lab.Text = text .. " : " .. tostring(value)
                if callback then pcall(callback, value) end
            end
            hit.MouseButton1Down:Connect(function()
                local dragging = true
                local c1, c2
                c1 = UIS.InputChanged:Connect(function(i)
                    if not dragging then return end
                    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                        apply((i.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1))
                    end
                end)
                c2 = UIS.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        if c1 then c1:Disconnect() end
                        if c2 then c2:Disconnect() end
                    end
                end)
            end)
        end
        return Tab
    end
        function Tab:Button(text, callback)
            builders[#builders + 1] = function(parent)
                local btn = N("TextButton", {
                    Size = UDim2.new(1, -4, 0, 36),
                    BackgroundColor3 = Color3.fromRGB(26, 34, 52),
                    Text = text,
                    TextColor3 = Color3.fromRGB(200, 230, 255),
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    BorderSizePixel = 0,
                    LayoutOrder = nextOrder(),
                    AutoButtonColor = false,
                    ZIndex = 7,
                }, parent)
                Corner(btn, 10)
                Stroke(btn, Color3.fromRGB(50, 70, 100), 1, 0.55)
                btn.MouseEnter:Connect(function() Tween(btn, 0.12, { BackgroundColor3 = Color3.fromRGB(32, 44, 68) }) end)
                btn.MouseLeave:Connect(function() Tween(btn, 0.12, { BackgroundColor3 = Color3.fromRGB(26, 34, 52) }) end)
                btn.MouseButton1Click:Connect(function()
                    Tween(btn, 0.08, { BackgroundColor3 = Theme.Accent })
                    task.delay(0.1, function()
                        if btn.Parent then Tween(btn, 0.15, { BackgroundColor3 = Color3.fromRGB(26, 34, 52) }) end
                    end)
                    if callback then pcall(callback) end
                end)
            end
            return Tab
        end

        function Tab:SkillRow(keys, getFn, setFn)
            -- keys: {"Z","X","C","V"}  getFn(key)->bool  setFn(key, bool)
            keys = keys or { "Z", "X", "C", "V" }
            builders[#builders + 1] = function(parent)
                local r = N("Frame", {
                    Size = UDim2.new(1, -4, 0, 36),
                    BackgroundColor3 = Theme.Card,
                    BorderSizePixel = 0,
                    LayoutOrder = nextOrder(),
                    ZIndex = 7,
                }, parent)
                Corner(r, 10)
                Stroke(r, Color3.fromRGB(40, 50, 70), 1, 0.65)

                local n = #keys
                local gap = 6
                local sidePad = 10
                -- compute button width after parent lays out; use fixed for mobile
                local btnW = 50
                local totalW = n * btnW + (n - 1) * gap
                local startX = sidePad

                for i, k in ipairs(keys) do
                    local btn = N("TextButton", {
                        Size = UDim2.fromOffset(btnW, 26),
                        Position = UDim2.new(0, startX + (i - 1) * (btnW + gap), 0.5, -13),
                        BorderSizePixel = 0,
                        Font = Enum.Font.GothamBold,
                        TextSize = 12,
                        AutoButtonColor = false,
                        ZIndex = 8,
                        Text = k,
                    }, r)
                    Corner(btn, 7)

                    local function paint()
                        local on = false
                        if getFn then
                            local ok, v = pcall(getFn, k)
                            on = ok and v and true or false
                        end
                        if on then
                            btn.Text = k .. " ON"
                            btn.BackgroundColor3 = Theme.Accent
                            btn.TextColor3 = Color3.fromRGB(8, 12, 18)
                        else
                            btn.Text = k .. " OFF"
                            btn.BackgroundColor3 = Color3.fromRGB(38, 44, 58)
                            btn.TextColor3 = Theme.Muted
                        end
                    end
                    paint()
                    btn.MouseButton1Click:Connect(function()
                        local on = false
                        if getFn then
                            local ok, v = pcall(getFn, k)
                            on = ok and v and true or false
                        end
                        on = not on
                        if setFn then pcall(setFn, k, on) end
                        paint()
                    end)
                end
            end
            return Tab
        end

        function Tab:Paragraph(title, desc)
            builders[#builders + 1] = function(parent)
                local r = N("Frame", {
                    Size = UDim2.new(1, -4, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Theme.Card,
                    BorderSizePixel = 0,
                    LayoutOrder = nextOrder(),
                    ZIndex = 7,
                }, parent)
                Corner(r, 10)
                Stroke(r, Color3.fromRGB(40, 50, 70), 1, 0.65)
                N("UIPadding", {
                    PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
                }, r)
                N("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, r)
                N("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
                    Text = title, TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, ZIndex = 8,
                }, r)
                N("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
                    Text = desc or "", TextColor3 = Theme.Muted, Font = Enum.Font.Gotham, TextSize = 11,
                    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, ZIndex = 8,
                }, r)
            end
            return Tab
        end

        pages[name] = function(parent)
            layoutOrder = 0
            for _, build in ipairs(builders) do build(parent) end
        end
        if order == 1 then task.defer(function() openPage(name) end) end
        return Tab
    end

    function Window:Notify(title, content, duration)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title or "BeoUI", Text = content or "", Duration = duration or 3,
            })
        end)
    end
    function Window:Destroy() if gui then gui:Destroy() end end
    function Window:SetVisible(v) setOpen(v and true or false) end

    return Window
end

return BeoUI