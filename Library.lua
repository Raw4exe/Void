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
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1
    stroke.Transparency = 0.3
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
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "AcrylicUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = CoreGui
    
    self.Blur = Instance.new("BlurEffect")
    self.Blur.Size = 15
    self.Blur.Parent = game.Lighting
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 700, 0, 500)
    self.MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    self.MainFrame.BackgroundTransparency = 0.1
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    local mainShadow = Instance.new("ImageLabel")
    mainShadow.Name = "Shadow"
    mainShadow.Size = UDim2.new(1, 40, 1, 40)
    mainShadow.Position = UDim2.new(0, -20, 0, -20)
    mainShadow.BackgroundTransparency = 1
    mainShadow.Image = "rbxassetid://5554236805"
    mainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    mainShadow.ImageTransparency = 0.5
    mainShadow.ScaleType = Enum.ScaleType.Slice
    mainShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    mainShadow.ZIndex = 0
    mainShadow.Parent = self.MainFrame
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = self.MainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(100, 100, 100)
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.2
    mainStroke.Parent = self.MainFrame
    
    MakeDraggable(self.MainFrame)
    
    self.TitleFrame = Instance.new("Frame")
    self.TitleFrame.Size = UDim2.new(1, 0, 0, 55)
    self.TitleFrame.Position = UDim2.new(0, 0, 0, 0)
    self.TitleFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    self.TitleFrame.BackgroundTransparency = 0.2
    self.TitleFrame.BorderSizePixel = 0
    self.TitleFrame.Parent = self.MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = self.TitleFrame
    
    local titleLine = Instance.new("Frame")
    titleLine.Size = UDim2.new(1, -30, 0, 1)
    titleLine.Position = UDim2.new(0, 15, 1, -1)
    titleLine.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    titleLine.BackgroundTransparency = 0.5
    titleLine.BorderSizePixel = 0
    titleLine.Parent = self.TitleFrame
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(0, 250, 0, 22)
    self.TitleLabel.Position = UDim2.new(0, 18, 0, 8)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 17
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.Parent = self.TitleFrame
    
    self.SubtitleLabel = Instance.new("TextLabel")
    self.SubtitleLabel.Size = UDim2.new(0, 250, 0, 16)
    self.SubtitleLabel.Position = UDim2.new(0, 18, 0, 30)
    self.SubtitleLabel.BackgroundTransparency = 1
    self.SubtitleLabel.Text = self.Subtitle
    self.SubtitleLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    self.SubtitleLabel.TextSize = 12
    self.SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.SubtitleLabel.Font = Enum.Font.Gotham
    self.SubtitleLabel.Parent = self.TitleFrame
    
    self:CreateSearchBar()
    
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -42, 0, 12)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    self.CloseButton.BackgroundTransparency = 0.1
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.CloseButton.TextSize = 20
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Parent = self.TitleFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = self.CloseButton
    
    local closeStroke = Instance.new("UIStroke")
    closeStroke.Color = Color3.fromRGB(255, 100, 100)
    closeStroke.Thickness = 1
    closeStroke.Transparency = 0.4
    closeStroke.Parent = self.CloseButton
    
    self.CloseButton.MouseEnter:Connect(function()
        CreateTween(self.CloseButton, {BackgroundTransparency = 0}):Play()
    end)
    
    self.CloseButton.MouseLeave:Connect(function()
        CreateTween(self.CloseButton, {BackgroundTransparency = 0.1}):Play()
    end)
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(1, -30, 0, 38)
    self.TabContainer.Position = UDim2.new(0, 15, 0, 65)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.MainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.Parent = self.TabContainer
    
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Size = UDim2.new(1, -30, 1, -125)
    self.ContentFrame.Position = UDim2.new(0, 15, 0, 113)
    self.ContentFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    self.ContentFrame.BackgroundTransparency = 0.2
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.Parent = self.MainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 10)
    contentCorner.Parent = self.ContentFrame
    
    local contentStroke = Instance.new("UIStroke")
    contentStroke.Color = Color3.fromRGB(70, 70, 70)
    contentStroke.Thickness = 1
    contentStroke.Transparency = 0.4
    contentStroke.Parent = self.ContentFrame
    
    self.ModuleScroll = Instance.new("ScrollingFrame")
    self.ModuleScroll.Size = UDim2.new(1, -20, 1, -20)
    self.ModuleScroll.Position = UDim2.new(0, 10, 0, 10)
    self.ModuleScroll.BackgroundTransparency = 1
    self.ModuleScroll.BorderSizePixel = 0
    self.ModuleScroll.ScrollBarThickness = 4
    self.ModuleScroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
    self.ModuleScroll.ScrollBarImageTransparency = 0.3
    self.ModuleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ModuleScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.ModuleScroll.Parent = self.ContentFrame
    
    self.ModuleGrid = Instance.new("Frame")
    self.ModuleGrid.Size = UDim2.new(1, 0, 1, 0)
    self.ModuleGrid.BackgroundTransparency = 1
    self.ModuleGrid.Parent = self.ModuleScroll
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.5, -8, 0, 120)
    gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = self.ModuleGrid
    
    local gridPadding = Instance.new("UIPadding")
    gridPadding.PaddingAll = UDim.new(0, 6)
    gridPadding.Parent = self.ModuleGrid
end

function AcrylicUI:CreateSearchBar()
    self.SearchFrame = Instance.new("Frame")
    self.SearchFrame.Size = UDim2.new(0, 200, 0, 30)
    self.SearchFrame.Position = UDim2.new(1, -240, 0, 12)
    self.SearchFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.SearchFrame.BackgroundTransparency = 0.2
    self.SearchFrame.BorderSizePixel = 0
    self.SearchFrame.Parent = self.TitleFrame
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 8)
    searchCorner.Parent = self.SearchFrame
    
    local searchStroke = Instance.new("UIStroke")
    searchStroke.Color = Color3.fromRGB(90, 90, 90)
    searchStroke.Thickness = 1
    searchStroke.Transparency = 0.4
    searchStroke.Parent = self.SearchFrame
    
    self.SearchBox = Instance.new("TextBox")
    self.SearchBox.Size = UDim2.new(1, -40, 1, 0)
    self.SearchBox.Position = UDim2.new(0, 10, 0, 0)
    self.SearchBox.BackgroundTransparency = 1
    self.SearchBox.Text = ""
    self.SearchBox.PlaceholderText = "Search modules..."
    self.SearchBox.TextColor3 = Color3.fromRGB(240, 240, 240)
    self.SearchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
    self.SearchBox.TextSize = 12
    self.SearchBox.Font = Enum.Font.Gotham
    self.SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    self.SearchBox.Parent = self.SearchFrame
    
    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.new(0, 16, 0, 16)
    searchIcon.Position = UDim2.new(1, -26, 0.5, -8)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://3926305904"
    searchIcon.ImageColor3 = Color3.fromRGB(140, 140, 140)
    searchIcon.ImageTransparency = 0.2
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
    
    tab.Button = Instance.new("TextButton")
    tab.Button.Size = UDim2.new(0, 120, 1, 0)
    tab.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    tab.Button.BackgroundTransparency = 0.2
    tab.Button.BorderSizePixel = 0
    tab.Button.Text = icon .. " " .. name
    tab.Button.TextColor3 = Color3.fromRGB(170, 170, 170)
    tab.Button.TextSize = 13
    tab.Button.Font = Enum.Font.GothamMedium
    tab.Button.Parent = self.TabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tab.Button
    
    local tabStroke = Instance.new("UIStroke")
    tabStroke.Color = Color3.fromRGB(80, 80, 80)
    tabStroke.Thickness = 1
    tabStroke.Transparency = 0.5
    tabStroke.Parent = tab.Button
    
    tab.Button.MouseEnter:Connect(function()
        if not tab.Active then
            CreateTween(tab.Button, {BackgroundTransparency = 0.05}):Play()
            CreateTween(tabStroke, {Transparency = 0.3}):Play()
        end
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if not tab.Active then
            CreateTween(tab.Button, {BackgroundTransparency = 0.2}):Play()
            CreateTween(tabStroke, {Transparency = 0.5}):Play()
        end
    end)
    
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
    for _, t in pairs(self.Tabs) do
        t.Active = false
        CreateTween(t.Button, {
            BackgroundTransparency = 0.2,
            TextColor3 = Color3.fromRGB(170, 170, 170)
        }):Play()
        
        local stroke = t.Button:FindFirstChild("UIStroke")
        if stroke then
            CreateTween(stroke, {Transparency = 0.5}):Play()
        end
    end
    
    tab.Active = true
    self.CurrentTab = tab
    CreateTween(tab.Button, {
        BackgroundTransparency = 0,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    local stroke = tab.Button:FindFirstChild("UIStroke")
    if stroke then
        CreateTween(stroke, {
            Transparency = 0.2,
            Color = Color3.fromRGB(120, 120, 120)
        }):Play()
    end
    
    for _, child in pairs(self.ModuleGrid:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
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
    
    module.Frame = Instance.new("Frame")
    module.Frame.Size = UDim2.new(1, 0, 1, 0)
    module.Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    module.Frame.BackgroundTransparency = 0.15
    module.Frame.BorderSizePixel = 0
    module.Frame.LayoutOrder = #tab.Modules + 1
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = module.Frame
    
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(75, 75, 75)
    frameStroke.Thickness = 1
    frameStroke.Transparency = 0.4
    frameStroke.Parent = module.Frame
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Parent = module.Frame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header
    
    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, -20, 0, 1)
    headerLine.Position = UDim2.new(0, 10, 1, 0)
    headerLine.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    headerLine.BackgroundTransparency = 0.5
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -55, 0, 18)
    titleLabel.Position = UDim2.new(0, 10, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = name
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = header
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -55, 0, 12)
    descLabel.Position = UDim2.new(0, 10, 0, 22)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Center
    descLabel.Parent = header
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -46, 0, 10)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.Parent = header
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggle
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(70, 70, 70)
    toggleStroke.Thickness = 1
    toggleStroke.Transparency = 0.4
    toggleStroke.Parent = toggle
    
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
    toggleIndicator.Position = UDim2.new(0, 2, 0, 2)
    toggleIndicator.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Parent = toggle
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 8)
    indicatorCorner.Parent = toggleIndicator
    
    toggle.MouseButton1Click:Connect(function()
        module.Enabled = not module.Enabled
        
        if module.Enabled then
            CreateTween(toggle, {BackgroundColor3 = Color3.fromRGB(80, 180, 80)}):Play()
            CreateTween(toggleIndicator, {
                Position = UDim2.new(1, -18, 0, 2),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            CreateTween(toggleStroke, {Color = Color3.fromRGB(100, 200, 100)}):Play()
        else
            CreateTween(toggle, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            CreateTween(toggleIndicator, {
                Position = UDim2.new(0, 2, 0, 2),
                BackgroundColor3 = Color3.fromRGB(180, 180, 180)
            }):Play()
            CreateTween(toggleStroke, {Color = Color3.fromRGB(70, 70, 70)}):Play()
        end
        
        if module.Callback then
            module.Callback(module.Enabled)
        end
    end)
    
    module.ElementContainer = Instance.new("ScrollingFrame")
    module.ElementContainer.Size = UDim2.new(1, -16, 1, -48)
    module.ElementContainer.Position = UDim2.new(0, 8, 0, 44)
    module.ElementContainer.BackgroundTransparency = 1
    module.ElementContainer.BorderSizePixel = 0
    module.ElementContainer.ScrollBarThickness = 3
    module.ElementContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    module.ElementContainer.ScrollBarImageTransparency = 0.4
    module.ElementContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    module.ElementContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
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
    toggle.Size = UDim2.new(1, 0, 0, 28)
    toggle.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    toggle.BackgroundTransparency = 0.3
    toggle.BorderSizePixel = 0
    toggle.Parent = module.ElementContainer
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggle
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(65, 65, 65)
    toggleStroke.Thickness = 1
    toggleStroke.Transparency = 0.5
    toggleStroke.Parent = toggle
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 22, 0, 22)
    button.Position = UDim2.new(1, -25, 0.5, -11)
    button.BackgroundColor3 = default and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(40, 40, 40)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = toggle
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 5)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = default and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(70, 70, 70)
    buttonStroke.Thickness = 1
    buttonStroke.Transparency = 0.4
    buttonStroke.Parent = button
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = default and "✓" or ""
    checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkmark.TextSize = 16
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Parent = button
    
    local enabled = default
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        if enabled then
            CreateTween(button, {BackgroundColor3 = Color3.fromRGB(80, 180, 80)}):Play()
            CreateTween(buttonStroke, {Color = Color3.fromRGB(100, 200, 100)}):Play()
            checkmark.Text = "✓"
        else
            CreateTween(button, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            CreateTween(buttonStroke, {Color = Color3.fromRGB(70, 70, 70)}):Play()
            checkmark.Text = ""
        end
        
        if callback then
            callback(enabled)
        end
    end)
    
    return {
        SetValue = function(value)
            enabled = value
            if enabled then
                CreateTween(button, {BackgroundColor3 = Color3.fromRGB(80, 180, 80)}):Play()
                CreateTween(buttonStroke, {Color = Color3.fromRGB(100, 200, 100)}):Play()
                checkmark.Text = "✓"
            else
                CreateTween(button, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                CreateTween(buttonStroke, {Color = Color3.fromRGB(70, 70, 70)}):Play()
                checkmark.Text = ""
            end
        end
    }
end

function AcrylicUI:AddSlider(module, name, min, max, default, callback)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 42)
    slider.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    slider.BackgroundTransparency = 0.3
    slider.BorderSizePixel = 0
    slider.Parent = module.ElementContainer
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 6)
    sliderCorner.Parent = slider
    
    local sliderStroke = Instance.new("UIStroke")
    sliderStroke.Color = Color3.fromRGB(65, 65, 65)
    sliderStroke.Thickness = 1
    sliderStroke.Transparency = 0.5
    sliderStroke.Parent = slider
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 18)
    valueLabel.Position = UDim2.new(1, -60, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = slider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 5)
    track.Position = UDim2.new(0, 10, 1, -12)
    track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    track.BorderSizePixel = 0
    track.Parent = slider
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 2.5)
    trackCorner.Parent = track
    
    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = Color3.fromRGB(60, 60, 60)
    trackStroke.Thickness = 1
    trackStroke.Transparency = 0.5
    trackStroke.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2.5)
    fillCorner.Parent = fill
    
    local handle = Instance.new("TextButton")
    handle.Size = UDim2.new(0, 14, 0, 14)
    handle.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BorderSizePixel = 0
    handle.Text = ""
    handle.Parent = track
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 7)
    handleCorner.Parent = handle
    
    local handleStroke = Instance.new("UIStroke")
    handleStroke.Color = Color3.fromRGB(100, 200, 100)
    handleStroke.Thickness = 2
    handleStroke.Transparency = 0.3
    handleStroke.Parent = handle
    
    local value = default
    local dragging = false
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            CreateTween(handle, {Size = UDim2.new(0, 16, 0, 16)}):Play()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            CreateTween(handle, {Size = UDim2.new(0, 14, 0, 14)}):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * relativeX)
            
            valueLabel.Text = tostring(value)
            handle.Position = UDim2.new(relativeX, -7, 0.5, -7)
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
            valueLabel.Text = tostring(value)
            handle.Position = UDim2.new(relativeX, -7, 0.5, -7)
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
        end
    }
end

function AcrylicUI:AddButton(module, name, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 32)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.Parent = module.ElementContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(90, 90, 90)
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = button
    
    button.MouseEnter:Connect(function()
        CreateTween(button, {
            BackgroundColor3 = Color3.fromRGB(80, 80, 80),
            BackgroundTransparency = 0.1
        }):Play()
        CreateTween(stroke, {Transparency = 0.2}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        CreateTween(button, {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            BackgroundTransparency = 0.2
        }):Play()
        CreateTween(stroke, {Transparency = 0.4}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        CreateTween(button, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
        wait(0.1)
        CreateTween(button, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
        
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
