-- AcrylicUI Library
-- Современная UI библиотека с акриликовым блюром

local AcrylicUI = {}
AcrylicUI.__index = AcrylicUI

-- Сервисы
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Утилиты
local function CreateTween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quint,
        easingDirection or Enum.EasingDirection.Out
    )
    return TweenService:Create(object, tweenInfo, properties)
end

local function CreateBlur(parent)
    local blur = Instance.new("BlurEffect")
    blur.Size = 10
    blur.Parent = game.Lighting
    
    local connection
    connection = parent.AncestryChanged:Connect(function()
        if not parent.Parent then
            blur:Destroy()
            connection:Disconnect()
        end
    end)
    
    return blur
end

local function CreateAcrylicFrame(parent, size, position)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(1, 0, 1, 0)
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    return frame
end

local function MakeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Основной класс
function AcrylicUI.new(title, subtitle)
    local self = setmetatable({}, AcrylicUI)
    
    self.Title = title or "AcrylicUI"
    self.Subtitle = subtitle or "Modern UI Library"
    self.Tabs = {}
    self.CurrentTab = nil
    self.SearchTerm = ""
    
    self:CreateUI()
    
    return self
end

function AcrylicUI:CreateUI()
    -- Основной ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "AcrylicUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = CoreGui
    
    -- Создаем блюр
    self.Blur = CreateBlur(self.ScreenGui)
    
    -- Главный фрейм
    self.MainFrame = CreateAcrylicFrame(self.ScreenGui, UDim2.new(0, 800, 0, 600), UDim2.new(0.5, -400, 0.5, -300))
    MakeDraggable(self.MainFrame)
    
    -- Заголовок
    self.TitleFrame = Instance.new("Frame")
    self.TitleFrame.Size = UDim2.new(1, 0, 0, 60)
    self.TitleFrame.Position = UDim2.new(0, 0, 0, 0)
    self.TitleFrame.BackgroundTransparency = 1
    self.TitleFrame.Parent = self.MainFrame
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 18
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.Parent = self.TitleFrame
    
    self.SubtitleLabel = Instance.new("TextLabel")
    self.SubtitleLabel.Size = UDim2.new(0, 200, 0, 20)
    self.SubtitleLabel.Position = UDim2.new(0, 20, 0, 25)
    self.SubtitleLabel.BackgroundTransparency = 1
    self.SubtitleLabel.Text = self.Subtitle
    self.SubtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    self.SubtitleLabel.TextSize = 12
    self.SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.SubtitleLabel.Font = Enum.Font.Gotham
    self.SubtitleLabel.Parent = self.TitleFrame
    
    -- Поисковая строка
    self:CreateSearchBar()
    
    -- Кнопка закрытия
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -40, 0, 15)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    self.CloseButton.BackgroundTransparency = 0.2
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.CloseButton.TextSize = 18
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Parent = self.TitleFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = self.CloseButton
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Контейнер для табов
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(1, -40, 0, 40)
    self.TabContainer.Position = UDim2.new(0, 20, 0, 70)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.MainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 10)
    tabLayout.Parent = self.TabContainer
    
    -- Контейнер для контента
    self.ContentFrame = CreateAcrylicFrame(self.MainFrame, UDim2.new(1, -40, 1, -140), UDim2.new(0, 20, 0, 120))
    self.ContentFrame.BackgroundTransparency = 0.8
    
    -- Скролл для модулей
    self.ModuleScroll = Instance.new("ScrollingFrame")
    self.ModuleScroll.Size = UDim2.new(1, -20, 1, -20)
    self.ModuleScroll.Position = UDim2.new(0, 10, 0, 10)
    self.ModuleScroll.BackgroundTransparency = 1
    self.ModuleScroll.BorderSizePixel = 0
    self.ModuleScroll.ScrollBarThickness = 6
    self.ModuleScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    self.ModuleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ModuleScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.ModuleScroll.Parent = self.ContentFrame
    
    -- Двухколоночная сетка для модулей
    self.ModuleGrid = Instance.new("Frame")
    self.ModuleGrid.Size = UDim2.new(1, 0, 1, 0)
    self.ModuleGrid.BackgroundTransparency = 1
    self.ModuleGrid.Parent = self.ModuleScroll
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.5, -10, 0, 120)
    gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = self.ModuleGrid
    
    local gridPadding = Instance.new("UIPadding")
    gridPadding.PaddingAll = UDim.new(0, 10)
    gridPadding.Parent = self.ModuleGrid
end

function AcrylicUI:CreateSearchBar()
    self.SearchFrame = CreateAcrylicFrame(self.TitleFrame, UDim2.new(0, 200, 0, 30), UDim2.new(1, -230, 0, 15))
    self.SearchFrame.BackgroundTransparency = 0.7
    
    self.SearchBox = Instance.new("TextBox")
    self.SearchBox.Size = UDim2.new(1, -40, 1, 0)
    self.SearchBox.Position = UDim2.new(0, 10, 0, 0)
    self.SearchBox.BackgroundTransparency = 1
    self.SearchBox.Text = ""
    self.SearchBox.PlaceholderText = "Search modules..."
    self.SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    self.SearchBox.TextSize = 12
    self.SearchBox.Font = Enum.Font.Gotham
    self.SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    self.SearchBox.Parent = self.SearchFrame
    
    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.new(0, 16, 0, 16)
    searchIcon.Position = UDim2.new(1, -26, 0.5, -8)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://3926305904"
    searchIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
    searchIcon.Parent = self.SearchFrame
    
    self.SearchBox.Changed:Connect(function()
        self.SearchTerm = self.SearchBox.Text:lower()
        self:FilterModules()
    end)
end

function AcrylicUI:FilterModules()
    if not self.CurrentTab then return end
    
    for _, module in pairs(self.CurrentTab.Modules) do
        local shouldShow = self.SearchTerm == "" or 
                          module.Name:lower():find(self.SearchTerm) or
                          module.Description:lower():find(self.SearchTerm)
        
        module.Frame.Visible = shouldShow
    end
end

function AcrylicUI:CreateTab(name, icon)
    local tab = {
        Name = name,
        Icon = icon,
        Modules = {},
        Button = nil,
        Active = false
    }
    
    -- Кнопка таба
    tab.Button = Instance.new("TextButton")
    tab.Button.Size = UDim2.new(0, 120, 1, 0)
    tab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tab.Button.BackgroundTransparency = 0.3
    tab.Button.BorderSizePixel = 0
    tab.Button.Text = name
    tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
    tab.Button.TextSize = 12
    tab.Button.Font = Enum.Font.GothamMedium
    tab.Button.Parent = self.TabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tab.Button
    
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

function AcrylicUI:SelectTab(tab)
    -- Деактивируем все табы
    for _, t in pairs(self.Tabs) do
        t.Active = false
        CreateTween(t.Button, {
            BackgroundTransparency = 0.3,
            TextColor3 = Color3.fromRGB(180, 180, 180)
        }):Play()
    end
    
    -- Активируем выбранный таб
    tab.Active = true
    self.CurrentTab = tab
    CreateTween(tab.Button, {
        BackgroundTransparency = 0.1,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    -- Очищаем контент
    for _, child in pairs(self.ModuleGrid:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Показываем модули выбранного таба
    for _, module in pairs(tab.Modules) do
        module.Frame.Parent = self.ModuleGrid
    end
    
    self:FilterModules()
end

function AcrylicUI:CreateModule(tab, name, description)
    local module = {
        Name = name,
        Description = description,
        Elements = {},
        Frame = nil,
        Enabled = false
    }
    
    -- Фрейм модуля
    module.Frame = CreateAcrylicFrame(nil, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
    module.Frame.BackgroundTransparency = 0.6
    module.Frame.LayoutOrder = #tab.Modules + 1
    
    -- Заголовок модуля
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Parent = module.Frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = name
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = header
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -50, 0, 15)
    descLabel.Position = UDim2.new(0, 10, 0, 20)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Center
    descLabel.Parent = header
    
    -- Переключатель модуля
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -45, 0, 10)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.Parent = header
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggle
    
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
    toggleIndicator.Position = UDim2.new(0, 2, 0, 2)
    toggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Parent = toggle
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 8)
    indicatorCorner.Parent = toggleIndicator
    
    toggle.MouseButton1Click:Connect(function()
        module.Enabled = not module.Enabled
        
        if module.Enabled then
            CreateTween(toggle, {BackgroundColor3 = Color3.fromRGB(100, 200, 100)}):Play()
            CreateTween(toggleIndicator, {Position = UDim2.new(1, -18, 0, 2)}):Play()
        else
            CreateTween(toggle, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
            CreateTween(toggleIndicator, {Position = UDim2.new(0, 2, 0, 2)}):Play()
        end
        
        if module.Callback then
            module.Callback(module.Enabled)
        end
    end)
    
    -- Контейнер для элементов
    module.ElementContainer = Instance.new("Frame")
    module.ElementContainer.Size = UDim2.new(1, -20, 1, -50)
    module.ElementContainer.Position = UDim2.new(0, 10, 0, 45)
    module.ElementContainer.BackgroundTransparency = 1
    module.ElementContainer.Parent = module.Frame
    
    local elementLayout = Instance.new("UIListLayout")
    elementLayout.Padding = UDim.new(0, 5)
    elementLayout.SortOrder = Enum.SortOrder.LayoutOrder
    elementLayout.Parent = module.ElementContainer
    
    table.insert(tab.Modules, module)
    
    return module
end

function AcrylicUI:AddToggle(module, name, default, callback)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, 0, 0, 25)
    toggle.BackgroundTransparency = 1
    toggle.Parent = module.ElementContainer
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 20, 0, 20)
    button.Position = UDim2.new(1, -22, 0, 2)
    button.BackgroundColor3 = default and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(60, 60, 70)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = toggle
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    local enabled = default
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        CreateTween(button, {
            BackgroundColor3 = enabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(60, 60, 70)
        }):Play()
        
        if callback then
            callback(enabled)
        end
    end)
    
    return {
        SetValue = function(value)
            enabled = value
            CreateTween(button, {
                BackgroundColor3 = enabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(60, 60, 70)
            }):Play()
        end
    }
end

function AcrylicUI:AddSlider(module, name, min, max, default, callback)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 35)
    slider.BackgroundTransparency = 1
    slider.Parent = module.ElementContainer
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 15)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 1, -8)
    track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    track.BorderSizePixel = 0
    track.Parent = slider
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 2)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill
    
    local handle = Instance.new("TextButton")
    handle.Size = UDim2.new(0, 12, 0, 12)
    handle.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BorderSizePixel = 0
    handle.Text = ""
    handle.Parent = track
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 6)
    handleCorner.Parent = handle
    
    local value = default
    local dragging = false
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * relativeX)
            
            label.Text = name .. ": " .. value
            handle.Position = UDim2.new(relativeX, -6, 0.5, -6)
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
            
            if callback then
                callback(value)
            end
        end
    end)
    
    return {
        SetValue = function(newValue)
            value = math.clamp(newValue, min, max)
            local relativeX = (value - min) / (max - min)
            label.Text = name .. ": " .. value
            handle.Position = UDim2.new(relativeX, -6, 0.5, -6)
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
        end
    }
end

function AcrylicUI:AddButton(module, name, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 25)
    button.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 11
    button.Font = Enum.Font.GothamMedium
    button.Parent = module.ElementContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        CreateTween(button, {BackgroundColor3 = Color3.fromRGB(100, 100, 110)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        CreateTween(button, {BackgroundColor3 = Color3.fromRGB(80, 80, 90)}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    return button
end

function AcrylicUI:Destroy()
    if self.Blur then
        self.Blur:Destroy()
    end
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return AcrylicUI
