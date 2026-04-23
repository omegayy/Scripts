--[[
    OrcaLib - A High-Fidelity UI Library Replica of Orca Hub
    Created for "Our Own Orca"
--]]

local OrcaLib = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Themes
local THEMES = {
    Sorbet = {
        Background = Color3.fromHex("#141414"),
        Surface = Color3.fromHex("#1f1f1f"),
        Accent = Color3.fromHex("#C6428E"),
        Accent2 = Color3.fromHex("#9a3fe5"),
        Text = Color3.fromHex("#FFFFFF"),
        TextMuted = Color3.fromHex("#A0A0A0"),
        Border = Color3.fromHex("#2a2a2a"),
    }
}

local currentTheme = THEMES.Sorbet

-- Utility
local function Create(className, properties, children)
    local inst = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        inst[prop] = val
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function Tween(inst, info, goals)
    local tween = TweenService:Create(inst, info, goals)
    tween:Play()
    return tween
end

-- Library Core
function OrcaLib:CreateWindow(title, themeName)
    local theme = THEMES[themeName] or THEMES.Sorbet
    
    local ScreenGui = Create("ScreenGui", {
        Name = "OrcaLib",
        ResetOnSpawn = false,
        Parent = PlayerGui
    })

    local Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 580, 0, 400),
        Position = UDim2.new(0.5, -290, 0.5, -200),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Create("UIStroke", {Color = theme.Border, Thickness = 1.5})
    })

    -- Dragging
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 65, 1, 0),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Parent = Main
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Create("Frame", { -- Corner Fix
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -20, 0, 0),
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0,
            ZIndex = 0,
        }),
        Create("ImageLabel", { -- Logo
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(0.5, -20, 0, 15),
            BackgroundTransparency = 1,
            Image = "rbxassetid://8992031167",
            ImageColor3 = theme.Accent,
        })
    })

    local TabList = Create("Frame", {
        Size = UDim2.new(1, 0, 1, -80),
        Position = UDim2.new(0, 0, 0, 70),
        BackgroundTransparency = 1,
        Parent = Sidebar
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 12),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        })
    })

    local Header = Create("TextLabel", {
        Size = UDim2.new(1, -85, 0, 40),
        Position = UDim2.new(0, 75, 0, 10),
        BackgroundTransparency = 1,
        Text = title:upper(),
        TextColor3 = theme.Text,
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Main
    }, {
        Create("UIGradient", {
            Color = ColorSequence.new(theme.Accent, theme.Accent2),
            Rotation = 45
        })
    })

    local Pages = Create("Frame", {
        Name = "Pages",
        Size = UDim2.new(1, -85, 1, -60),
        Position = UDim2.new(0, 75, 0, 50),
        BackgroundTransparency = 1,
        Parent = Main
    })

    local window = {
        CurrentTab = nil,
        Tabs = {}
    }

    function window:CreateTab(name, icon)
        local tabBtn = Create("ImageButton", {
            Size = UDim2.new(0, 40, 0, 40),
            BackgroundColor3 = theme.Background,
            Image = icon or "rbxassetid://8992031167",
            ImageColor3 = theme.TextMuted,
            BorderSizePixel = 0,
            Parent = TabList
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
            Create("UIStroke", {Color = theme.Border, Transparency = 0.5})
        })

        local page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            Visible = false,
            Parent = Pages
        }, {
            Create("UIListLayout", {Padding = UDim.new(0, 15)})
        })

        local tab = { Page = page }

        tabBtn.MouseButton1Click:Connect(function()
            if window.CurrentTab then
                Tween(window.CurrentTab.Btn, TweenInfo.new(0.2), {BackgroundColor3 = theme.Background, ImageColor3 = theme.TextMuted})
                window.CurrentTab.Page.Visible = false
            end
            Tween(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.Accent, ImageColor3 = theme.Text})
            page.Visible = true
            Header.Text = name:upper()
            window.CurrentTab = {Btn = tabBtn, Page = page}
        end)

        function tab:CreateButton(text, callback)
            local button = Create("TextButton", {
                Size = UDim2.new(1, -5, 0, 40),
                BackgroundColor3 = theme.Surface,
                AutoButtonColor = false,
                Text = "",
                Parent = page
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = theme.Border, Transparency = 0.5}),
                Create("TextLabel", {
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = theme.Text,
                    TextSize = 14,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            })
            button.MouseEnter:Connect(function() Tween(button, TweenInfo.new(0.2), {BackgroundColor3 = theme.Surface:Lerp(Color3.new(1,1,1), 0.05)}) end)
            button.MouseLeave:Connect(function() Tween(button, TweenInfo.new(0.2), {BackgroundColor3 = theme.Surface}) end)
            button.MouseButton1Click:Connect(callback)
            return button
        end

        function tab:CreateToggle(text, default, callback)
            local enabled = default or false
            local toggle = Create("TextButton", {
                Size = UDim2.new(1, -5, 0, 40),
                BackgroundColor3 = theme.Surface,
                AutoButtonColor = false,
                Text = "",
                Parent = page
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = theme.Border, Transparency = 0.5}),
                Create("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = theme.Text,
                    TextSize = 14,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            })

            local box = Create("Frame", {
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -34, 0.5, -12),
                BackgroundColor3 = theme.Background,
                Parent = toggle
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {Color = theme.Border})
            })

            local check = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0.5, -7, 0.5, -7),
                BackgroundColor3 = theme.Accent,
                Visible = enabled,
                Parent = box
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                Create("UIGradient", { Color = ColorSequence.new(theme.Accent, theme.Accent2) })
            })

            toggle.MouseButton1Click:Connect(function()
                enabled = not enabled
                check.Visible = enabled
                callback(enabled)
            end)
            return toggle
        end

        function tab:CreateSlider(text, min, max, default, callback)
            local slider = Create("Frame", {
                Size = UDim2.new(1, -5, 0, 50),
                BackgroundColor3 = theme.Surface,
                Parent = page
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Create("UIStroke", {Color = theme.Border, Transparency = 0.5}),
                Create("TextLabel", {
                    Size = UDim2.new(1, -20, 0, 25),
                    Position = UDim2.new(0, 10, 0, 5),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = theme.Text,
                    TextSize = 14,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            })

            local bar = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0, 10, 1, -12),
                BackgroundColor3 = theme.Background,
                BorderSizePixel = 0,
                Parent = slider
            }, { Create("UICorner", {CornerRadius = UDim.new(1, 0)}) })

            local fill = Create("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = theme.Accent,
                BorderSizePixel = 0,
                Parent = bar
            }, { 
                Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Create("UIGradient", { Color = ColorSequence.new(theme.Accent, theme.Accent2) })
            })

            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local function update()
                        local percent = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                        fill.Size = UDim2.new(percent, 0, 1, 0)
                        callback(math.floor(min + (max - min) * percent))
                    end
                    local move = RunService.RenderStepped:Connect(update)
                    local release; release = UserInputService.InputEnded:Connect(function(endInput)
                        if endInput.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect(); release:Disconnect() end
                    end)
                    update()
                end
            end)
            return slider
        end

        if not window.CurrentTab then tabBtn.MouseButton1Click:Fire() end
        return tab
    end

    return window
end

return OrcaLib
