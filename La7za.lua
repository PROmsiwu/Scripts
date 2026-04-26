-- ============================================
-- LA7ZA ULTIMATE MENU HUB
 -- Menu Hub مع خلفية فيديو وأزرار تفعيل
-- للأغراض التعليمية فقط
-- ============================================

-- ============================================
-- إعدادات الواجهة
-- ============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- إعدادات البوت
local Settings = {
    EspEnabled = false,
    SpeedEnabled = false,
    SpeedValue = 50,
    FlyEnabled = false,
    NoClipEnabled = false,
    InfiniteJump = false,
}

-- ============================================
-- 1. إنشاء واجهة الفيديو (YouTube Background)
-- ============================================
-- شرح: نستخدم BillBoardGui لعرض فيديو كخلفية

local function createVideoBackground(videoId, autoPlay)
    -- إنشاء إطار الفيديو
    local videoFrame = Instance.new("BillboardGui")
    videoFrame.Name = "VideoBackground"
    videoFrame.Size = UDim2.new(0, 800, 0, 600)
    videoFrame.StudsOffset = Vector3.new(0, 0, 0)
    videoFrame.AlwaysOnTop = true
    videoFrame.Enabled = true
    videoFrame.Parent = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") or LocalPlayer
    
    -- إطار داخلي لعرض الفيديو
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0
    frame.Parent = videoFrame
    
    -- رابط الفيديو (YouTube embed)
    local videoUrl = "https://youtu.be/JnwB4w18Xoo?si=iRF-Uf8lHZOIn73A" .. videoId .. "?autoplay=" .. (autoPlay and "1" or "0") .. "&loop=1&playlist=" .. videoId
    local videoLabel = Instance.new("TextLabel")
    videoLabel.Size = UDim2.new(1, 0, 1, 0)
    videoLabel.Text = ""
    videoLabel.BackgroundTransparency = 1
    videoLabel.Parent = frame
    
    -- محاولة تحميل الفيديو كـ Image (طريقة مبسطة)
    -- ملاحظة: Roblox لا يدعم فيديو YouTube مباشرة، هذا محاكاة
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Image = "rbxasset://textures/ui/Shell/Background.png"
    imageLabel.ImageColor3 = Color3.fromRGB(30, 30, 50)
    imageLabel.Parent = frame
    
    return videoFrame
end

-- متغير للتحكم في الفيديو
local videoBackground = nil
local videoEnabled = true

local function toggleVideo(enable)
    if enable then
        if not videoBackground then
            videoBackground = createVideoBackground("dQw4w9WgXcQ", true) -- YouTube ID
        else
            videoBackground.Enabled = true
        end
        print("[VIDEO] تم تشغيل خلفية الفيديو")
    else
        if videoBackground then
            videoBackground.Enabled = false
        end
        print("[VIDEO] تم إيقاف خلفية الفيديو")
    end
end

-- ============================================
-- 2. وظائف السكربت (الميزات)
-- ============================================

-- 2.1 كشف الأعداء (ESP)
local espObjects = {}
local function toggleESP(enable)
    Settings.EspEnabled = enable
    if enable then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_La7Za"
                highlight.FillColor = Color3.fromRGB(255, 50, 50)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.Adornee = player.Character
                highlight.Parent = player.Character
                espObjects[player] = highlight
            end
        end
        print("[ESP] تم التفعيل")
    else
        for _, obj in pairs(espObjects) do
            if obj then obj:Destroy() end
        end
        espObjects = {}
        print("[ESP] تم الإيقاف")
    end
end

-- 2.2 سرعة خارقة
local function setSpeed(value)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
        print("[SPEED] تم ضبط السرعة إلى " .. value)
    end
end

-- 2.3 طيران (Fly)
local flyBodyVelocity = nil
local function toggleFly(enable)
    Settings.FlyEnabled = enable
    local char = LocalPlayer.Character
    if not char then return end
    
    if enable then
        -- تعطيل الجاذبية
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            end
        end
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = true
        end
        
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 1e5
        flyBodyVelocity.Velocity = Vector3.new(0, 25, 0)
        if char:FindFirstChild("HumanoidRootPart") then
            flyBodyVelocity.Parent = char.HumanoidRootPart
        end
        print("[FLY] تم التفعيل")
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = false
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = nil
            end
        end
        print("[FLY] تم الإيقاف")
    end
end

-- 2.4 NoClip (اختراق الجدران)
local function toggleNoClip(enable)
    Settings.NoClipEnabled = enable
    local char = LocalPlayer.Character
    if not char then return
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enable
        end
    end
    print("[NOCLIP] " .. (enable and "تم التفعيل" or "تم الإيقاف"))
end

-- 2.5 قفز لا نهائي
local function toggleInfiniteJump(enable)
    Settings.InfiniteJump = enable
    if enable then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = 100
        end
        print("[JUMP] تم تفعيل القفز اللانهائي")
    else
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = 50
        end
        print("[JUMP] تم إيقاف القفز اللانهائي")
    end
end

-- ============================================
-- 3. الواجهة الرسومية الرئيسية (المود مينيو)
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "La7ZaUltimateMenu"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- الإطار الرئيسي
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 550)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- خلفية متحركة (Gradient)
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 80)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 50, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 80)),
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- شريط العنوان
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 60, 100)
TitleBar.BackgroundTransparency = 0.3
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "🔥 LA7ZA ULTIMATE MENU HUB 🔥"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TitleBar

-- زر الفيديو (تشغيل/إيقاف الخلفية)
local VideoBtn = Instance.new("TextButton")
VideoBtn.Size = UDim2.new(0, 70, 1, -10)
VideoBtn.Position = UDim2.new(1, -165, 0, 5)
VideoBtn.Text = "📹 ON"
VideoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VideoBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
VideoBtn.Font = Enum.Font.GothamBold
VideoBtn.TextSize = 12
VideoBtn.BorderSizePixel = 0
VideoBtn.Parent = TitleBar
Instance.new("UICorner", VideoBtn).CornerRadius = UDim.new(0, 6)

-- زر الإغلاق
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 1, -10)
CloseBtn.Position = UDim2.new(1, -50, 0, 5)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 60)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

-- زر تصغير
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 40, 1, -10)
MinBtn.Position = UDim2.new(1, -95, 0, 5)
MinBtn.Text = "─"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar

-- حاوية الأزرار (ScrollingFrame)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -65)
ScrollFrame.Position = UDim2.new(0, 10, 0, 60)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.Parent = MainFrame

-- دالة إنشاء زر Toggle
local function createToggle(text, y, color, initial, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = text .. " : " .. (initial and "✅ ON" or "❌ OFF")
    btn.BackgroundColor3 = initial and color or Color3.fromRGB(50, 50, 75)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = ScrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local state = initial
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. " : " .. (state and "✅ ON" or "❌ OFF")
        btn.BackgroundColor3 = state and color or Color3.fromRGB(50, 50, 75)
        callback(state)
    end)
    return btn
end

-- شريط تحكم السرعة (Slider)
local SpeedSliderFrame = Instance.new("Frame")
SpeedSliderFrame.Size = UDim2.new(1, -20, 0, 60)
SpeedSliderFrame.Position = UDim2.new(0, 10, 0, 230)
SpeedSliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
SpeedSliderFrame.Parent = ScrollFrame
Instance.new("UICorner", SpeedSliderFrame).CornerRadius = UDim.new(0, 8)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 25)
SpeedLabel.Position = UDim2.new(0, 10, 0, 5)
SpeedLabel.Text = "🎚️ السرعة: " .. Settings.SpeedValue
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 12
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Parent = SpeedSliderFrame

local SpeedSlider = Instance.new("TextButton")
SpeedSlider.Size = UDim2.new(0.9, 0, 0, 8)
SpeedSlider.Position = UDim2.new(0.05, 0, 0, 35)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
SpeedSlider.Text = ""
SpeedSlider.Parent = SpeedSliderFrame
Instance.new("UICorner", SpeedSlider).CornerRadius = UDim.new(1, 0)

local SliderIndicator = Instance.new("Frame")
SliderIndicator.Size = UDim2.new(0.2, 0, 1, 0)
SliderIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 120)
SliderIndicator.Parent = SpeedSlider
Instance.new("UICorner", SliderIndicator).CornerRadius = UDim.new(1, 0)

-- قيم السرعة
local speedValues = {25, 50, 75, 100, 125, 150, 175, 200, 250}
local speedIndex = 2

local function updateSpeedSlider()
    local percent = speedIndex / (#speedValues - 1)
    SliderIndicator.Size = UDim2.new(percent, 0, 1, 0)
    Settings.SpeedValue = speedValues[speedIndex]
    SpeedLabel.Text = "🎚️ السرعة: " .. Settings.SpeedValue
    if Settings.SpeedEnabled then
        setSpeed(Settings.SpeedValue)
    end
end

local draggingSlider = false
SpeedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
        local percent = math.clamp((input.Position.X - SpeedSlider.AbsolutePosition.X) / SpeedSlider.AbsoluteSize.X, 0, 1)
        speedIndex = math.floor(percent * (#speedValues - 1)) + 1
        speedIndex = math.clamp(speedIndex, 1, #speedValues)
        updateSpeedSlider()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local percent = math.clamp((input.Position.X - SpeedSlider.AbsolutePosition.X) / SpeedSlider.AbsoluteSize.X, 0, 1)
        speedIndex = math.floor(percent * (#speedValues - 1)) + 1
        speedIndex = math.clamp(speedIndex, 1, #speedValues)
        updateSpeedSlider()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

-- الأزرار
createToggle("👁️ ESP (كشف الأعداء)", 10, Color3.fromRGB(100, 150, 255), Settings.EspEnabled, function(state)
    toggleESP(state)
end)

createToggle("🏃 Speed Hack", 65, Color3.fromRGB(100, 200, 100), Settings.SpeedEnabled, function(state)
    Settings.SpeedEnabled = state
    if state then
        setSpeed(Settings.SpeedValue)
    else
        setSpeed(16)
    end
end)

createToggle("✈️ Fly Hack", 120, Color3.fromRGB(100, 200, 255), Settings.FlyEnabled, function(state)
    toggleFly(state)
end)

createToggle("🚪 NoClip", 175, Color3.fromRGB(200, 150, 100), Settings.NoClipEnabled, function(state)
    toggleNoClip(state)
end)

createToggle("🦘 Infinite Jump", 300, Color3.fromRGB(150, 100, 200), Settings.InfiniteJump, function(state)
    toggleInfiniteJump(state)
end)

-- معلومات
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 0, 60)
Info.Position = UDim2.new(0, 10, 0, 370)
Info.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Info.TextColor3 = Color3.fromRGB(150, 150, 170)
Info.Font = Enum.Font.Gotham
Info.TextSize = 11
Info.TextWrapped = true
Info.Text = "🔥 LA7ZA ULTIMATE MENU HUB\n📹 زر الفيديو: تشغيل/إيقاف خلفية الفيديو\n🎚️ شريط السرعة: التحكم في قيمة السرعة"
Info.Parent = ScrollFrame
Instance.new("UICorner", Info).CornerRadius = UDim.new(0, 8)

ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 450)

-- ============================================
-- 4. التحكم في الفيديو
-- ============================================
VideoBtn.MouseButton1Click:Connect(function()
    videoEnabled = not videoEnabled
    VideoBtn.Text = videoEnabled and "📹 ON" or "📹 OFF"
    VideoBtn.BackgroundColor3 = videoEnabled and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(120, 60, 60)
    toggleVideo(videoEnabled)
end)

-- بدء الفيديو تلقائياً
task.delay(1, function()
    toggleVideo(true)
end)

-- زر عائم
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 55, 0, 55)
FloatBtn.Position = UDim2.new(0, 15, 0.8, 0)
FloatBtn.Text = "🔥"
FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 100)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 24
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local guiVisible = true
FloatBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    MainFrame.Visible = guiVisible
end)

-- تصغير الواجهة
local minimized = false
local originalSize = MainFrame.Size

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 400, 0, 55), "Out", "Quad", 0.3, true)
        MinBtn.Text = "□"
    else
        MainFrame:TweenSize(originalSize, "Out", "Quad", 0.3, true)
        MinBtn.Text = "─"
    end
end)

-- إغلاق السكربت
CloseBtn.MouseButton1Click:Connect(function()
    toggleESP(false)
    toggleFly(false)
    toggleNoClip(false)
    toggleInfiniteJump(false)
    setSpeed(16)
    ScreenGui:Destroy()
    if videoBackground then videoBackground:Destroy() end
    print("[HUB] تم إغلاق المود مينيو")
end)

-- ============================================
-- سحب الواجهة
-- ============================================
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ============================================
-- رسالة الترحيب
-- ============================================
print([[
╔═══════════════════════════════════════════════════════════════════════╗
║              🔥 LA7ZA ULTIMATE MENU HUB LOADED 🔥                      ║
╠═══════════════════════════════════════════════════════════════════════╣
║  📌 الميزات:                                                          ║
║  👁️ ESP        - كشف الأعداء عبر الجدران                              ║
║  🏃 Speed Hack - زيادة السرعة (شريط تحكم)                             ║
║  ✈️ Fly Hack   - الطيران في الهواء                                    ║
║  🚪 NoClip     - اختراق الجدران                                        ║
║  🦘 Jump       - قفز لا نهائي                                          ║
║  📹 Video      - خلفية فيديو (YouTube)                                 ║
╠═══════════════════════════════════════════════════════════════════════╣
║  🖱️ اسحب شريط العنوان للتحريك | ─ للتصغير | ✕ للإغلاق                 ║
║  📹 زر الفيديو: يشغل/يوقف خلفية الفيديو                               ║
╚═══════════════════════════════════════════════════════════════════════╝
]])

MainFrame.Visible = true