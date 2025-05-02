local Storage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")

local IsRanked

local Data = Storage.Application.GetQuestions:InvokeServer()
local Messenger = Storage.Application.Messenger
local GetRank = Storage.Application.GetRank

local Userinterface = Player.PlayerGui:FindFirstChild("UserInterface")

if Userinterface then
    Userinterface:Destroy()
else
    Player:Kick("[Kohau Systems]: Failed to load gui, rejoin.")
end

local function CreateLoadingScreen(parent)
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    screenGui.Name = "LoadingScreen"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = parent

    local mainFrame = Instance.new("CanvasGroup")
    mainFrame.Name = "Main"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    mainFrame.BorderSizePixel = 0
    mainFrame.GroupTransparency = 1
    mainFrame.Parent = screenGui

    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 100, 0, 100)
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.new(0.5, 0, 0.45, 0)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://80990588449079"
    logo.Parent = mainFrame

    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(0, 125, 0, 20)
    statusText.AnchorPoint = Vector2.new(0.5, 0.5)
    statusText.Position = UDim2.new(0.5, 0, 0.55, 0)
    statusText.Font = Enum.Font.GothamBold
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.BackgroundTransparency = 1
    statusText.TextScaled = true
    statusText.Text = "Loading..."
    statusText.Parent = mainFrame

    TweenService:Create(logo, TweenInfo.new(2.4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = 360 }):Play()

    return {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        StatusText = statusText,
    }
end

local ui = CreateLoadingScreen(Player:WaitForChild("PlayerGui"))

TweenService:Create(ui.MainFrame, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {GroupTransparency = 0}):Play()
ui.MainFrame.BackgroundTransparency = .3

local function UpdateStatus(text)
    if ui.StatusText then
        ui.StatusText.Text = text
    end
end

local function ProcessAndSendData()
    local manipulatedAnswers = {}

    for QIndex, QInfo in ipairs(Data) do
        for AnsIndex, AnsData in ipairs(QInfo.Answers) do
            if AnsData.Correct then
                manipulatedAnswers[QIndex] = AnsIndex 
                break
            end
        end
    end

    for QIndex, Choice in pairs(manipulatedAnswers) do
        Messenger:FireServer(QIndex, Choice)
    end

    local result = GetRank:InvokeServer()
    return result
end

UpdateStatus("Fetching your rank...")

local isRanked = false

task.delay(2.5, function()
    UpdateStatus("Contacting Kohau's Systems...")
end)

task.delay(5, function()
    UpdateStatus("Finalizing...")
    task.wait(2.5)
    if isRanked then
        Player:Kick("[Kohau Systems]: Ranked to Trainee.")
    end
    if not isRanked then
        task.delay(25, function()
            if not isRanked then
                Player:Kick("[Kohau Systems]: We cannot rank you at this moment, the system is broken.")
            end
        end)
    end
end)

isRanked = ProcessAndSendData()

