local LoadingTick = os.clock()
local Library do
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")

    gethui = gethui or function()
        return CoreGui
    end

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    local Mouse = cloneref(LocalPlayer:GetMouse())

    local FromRGB = Color3.fromRGB
    local FromHSV = Color3.fromHSV
    local FromHex = Color3.fromHex

    local RGBSequence = ColorSequence.new
    local RGBSequenceKeypoint = ColorSequenceKeypoint.new
    local NumSequence = NumberSequence.new
    local NumSequenceKeypoint = NumberSequenceKeypoint.new

    local UDim2New = UDim2.new
    local UDimNew = UDim.new
    local Vector2New = Vector2.new

    local MathClamp = math.clamp
    local MathFloor = math.floor
    local MathAbs = math.abs
    local MathSin = math.sin

    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove
    local TableConcat = table.concat
    local TableClone = table.clone
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringFind = string.find
    local StringGSub = string.gsub
    local StringLower = string.lower
    local StringSub = string.sub
    local StringLen = string.len

    local InstanceNew = Instance.new
    local RectNew = Rect.new

    local IsMobile = UserInputService.TouchEnabled or false

    Library = {
        Theme = { },
        MenuKeybind = tostring(Enum.KeyCode.Z),
        Flags = { },
        FadeSpeed = 0.3,
        Tween = { Time = 0.3, Style = Enum.EasingStyle.Cubic, Direction = Enum.EasingDirection.Out },
        Folders = { Directory = "kagihub", Configs = "kagihub/Configs", Assets = "kagihub/Assets" },
        Images = {
            ["Saturation"] = {"Saturation.png", "https://github.com/sametexe001/images/blob/main/saturation.png?raw=true" },
            ["Value"] = { "Value.png", "https://github.com/sametexe001/images/blob/main/value.png?raw=true" },
            ["Hue"] = { "Hue.png", "https://github.com/sametexe001/images/blob/main/horizontalhue.png?raw=true" },
            ["Checkers"] = { "Checkers.png", "https://github.com/sametexe001/images/blob/main/checkers.png?raw=true" },
        },
        Pages = { }, Sections = { }, Connections = { }, Threads = { },
        ThemeMap = { }, ThemeItems = { }, OpenFrames = { }, SetFlags = { },
        UnnamedConnections = 0, UnnamedFlags = 0, Colorpickers = { },
        Holder = nil, NotifHolder = nil, UnusedHolder = nil, CopiedColor = false, Font = nil
    }

    Library.__index = Library
    Library.Pages.__index = Library.Pages
    Library.Sections.__index = Library.Sections

    local Themes = {
        ["Default"] = {
            ["Background"] = FromRGB(15, 14, 18),
            ["Inline"] = FromRGB(26, 24, 31),
            ["Text"] = FromRGB(255, 255, 255),
            ["Element"] = FromRGB(40, 38, 49),
            ["Accent"] = FromRGB(251, 159, 255),
            ["Image"] = FromRGB(255, 255, 255),
            ["Gradient"] = FromRGB(211, 211, 211)
        }
    }

    Library.Theme = TableClone(Themes["Default"])

    local Keys = {
        ["RightShift"] = "RightShift", ["LeftShift"] = "LeftShift",
        ["RightControl"] = "RightControl", ["LeftControl"] = "LeftControl",
        ["LeftAlt"] = "LeftAlt", ["RightAlt"] = "RightAlt"
    }

    for Index, Value in Library.Folders do
        if not isfolder(Value) then makefolder(Value) end
    end

    for Index, Value in Library.Images do
        local ImageName = Value[1]
        local ImageLink = Value[2]
        if not isfile(Library.Folders.Assets .. "/" .. ImageName) then
            writefile(Library.Folders.Assets .. "/" .. ImageName, game:HttpGet(ImageLink))
        end
    end

    local Tween = { } do
        Tween.__index = Tween
        Tween.Create = function(self, Item, Info, Goal, IsRawItem)
            Item = IsRawItem and Item or Item.Instance
            Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)
            local NewTween = { Tween = TweenService:Create(Item, Info, Goal), Info = Info, Goal = Goal, Item = Item }
            NewTween.Tween:Play()
            setmetatable(NewTween, Tween)
            return NewTween
        end
        Tween.GetProperty = function(self, Item)
            Item = Item or self.Item
            if Item:IsA("Frame") then return { "BackgroundTransparency" }
            elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then return { "BackgroundTransparency", "ImageTransparency" }
            elseif Item:IsA("ScrollingFrame") then return { "BackgroundTransparency", "ScrollBarImageTransparency" }
            elseif Item:IsA("TextBox") then return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("UIStroke") then return { "Transparency" }
            end
        end
        Tween.FadeItem = function(self, Item, Property, Visibility, Speed)
            local Item = Item or self.Item
            local OldTransparency = Item[Property]
            Item[Property] = Visibility and 1 or OldTransparency
            local NewTween = Tween:Create(Item, TweenInfo.new(Speed or Library.FadeSpeed, Library.Tween.Style, Library.Tween.Direction), {
                [Property] = Visibility and OldTransparency or 1
            }, true)
            Library:Connect(NewTween.Tween.Completed, function()
                if not Visibility then task.wait(); Item[Property] = OldTransparency end
            end)
            return NewTween
        end
        Tween.Get = function(self) if not self.Tween then return end return self.Tween, self.Info, self.Goal end
        Tween.Pause = function(self) if not self.Tween then return end self.Tween:Pause() end
        Tween.Play = function(self) if not self.Tween then return end self.Tween:Play() end
        Tween.Clean = function(self) if not self.Tween then return end Tween:Pause(); self = nil end
    end

    local Instances = { } do
        Instances.__index = Instances
        Instances.Create = function(self, Class, Properties)
            local NewItem = { Instance = InstanceNew(Class), Properties = Properties, Class = Class }
            setmetatable(NewItem, Instances)
            for Property, Value in NewItem.Properties do NewItem.Instance[Property] = Value end
            return NewItem
        end
        Instances.AddToTheme = function(self, Properties)
            if not self.Instance then return end
            Library:AddToTheme(self, Properties)
        end
        Instances.ChangeItemTheme = function(self, Properties)
            if not self.Instance then return end
            Library:ChangeItemTheme(self, Properties)
        end
        Instances.Set = function(self, Property, Value)
            if not self.Instance then return end
            if not self.Instance[Property] then return end
            self.Instance[Property] = Value
        end
        Instances.Connect = function(self, Event, Callback, Name)
            if not self.Instance then return end
            if not self.Instance[Event] then return end
            if IsMobile then
                if Event == "MouseButton1Down" or Event == "MouseButton1Click" then Event = "TouchTap"
                elseif Event == "MouseButton2Down" or Event == "MouseButton2Click" then Event = "TouchLongPress" end
            end
            return Library:Connect(self.Instance[Event], Callback, Name)
        end
        Instances.Tween = function(self, Info, Goal)
            if not self.Instance then return end
            return Tween:Create(self, Info, Goal)
        end
        Instances.Disconnect = function(self, Name)
            if not self.Instance then return end
            return Library:Disconnect(Name)
        end
        Instances.Clean = function(self)
            if not self.Instance then return end
            self.Instance:Destroy(); self = nil
        end
        Instances.MakeDraggable = function(self)
            if not self.Instance then return end
            local Gui = self.Instance
            local Dragging = false
            local DragStart
            local StartPosition
            local InputChanged
            local Set = function(Input)
                local DragDelta = Input.Position - DragStart
                self:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y)})
            end
            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    DragStart = Input.Position
                    StartPosition = Gui.Position
                    if InputChanged then return end
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            if InputChanged then InputChanged:Disconnect(); InputChanged = nil end
                        end
                    end)
                end
            end)
            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Dragging then Set(Input) end
                end
            end)
            return Dragging
        end
        Instances.MakeResizeable = function(self, Minimum, Maximum)
            if not self.Instance then return end
            local Gui = self.Instance
            local Resizing = false
            local Start = UDim2New()
            local Delta = UDim2New()
            local ResizeMax = Gui.Parent.AbsoluteSize - Gui.AbsoluteSize
            local InputChanged
            local ResizeButton = Instances:Create("ImageButton", {
                Parent = Gui, Image = "rbxassetid://7368471234", AnchorPoint = Vector2New(1, 1),
                BorderColor3 = FromRGB(0, 0, 0), Size = UDim2New(0, 7, 0, 7), Position = UDim2New(1, -3, 1, -3),
                Name = "\0", BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 5, AutoButtonColor = false, Visible = true,
            })
            ResizeButton:AddToTheme({ImageColor3 = "Accent"})
            ResizeButton:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Resizing = true
                    Start = Gui.Size - UDim2New(0, Input.Position.X, 0, Input.Position.Y)
                    if InputChanged then return end
                    Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Resizing = false
                            if InputChanged then InputChanged:Disconnect(); InputChanged = nil end
                        end
                    end)
                end
            end)
            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Resizing then
                        ResizeMax = Maximum or Gui.Parent.AbsoluteSize - Gui.AbsoluteSize
                        Delta = Start + UDim2New(0, Input.Position.X, 0, Input.Position.Y)
                        Delta = UDim2New(0, math.clamp(Delta.X.Offset, Minimum.X, ResizeMax.X), 0, math.clamp(Delta.Y.Offset, Minimum.Y, ResizeMax.Y))
                        Tween:Create(Gui, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = Delta}, true)
                    end
                end
            end)
            return ResizeButton
        end
        Instances.OnHover = function(self, Function)
            if not self.Instance then return end
            return Library:Connect(self.Instance.MouseEnter, Function)
        end
        Instances.OnHoverLeave = function(self, Function)
            if not self.Instance then return end
            return Library:Connect(self.Instance.MouseLeave, Function)
        end
    end

    local CustomFont = { } do
        function CustomFont:New(Name, Weight, Style, Data)
            if isfile(Library.Folders.Assets .. "/" .. Name .. ".json") then
                return Font.new(getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".json"))
            end
            if not isfile(Library.Folders.Assets .. "/" .. Name .. ".ttf") then
                writefile(Library.Folders.Assets .. "/" .. Name .. ".ttf", game:HttpGet(Data.Url))
            end
            local FontData = { name = Name, faces = { { name = "Regular", weight = Weight, style = Style, assetId = getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".ttf") } } }
            writefile(Library.Folders.Assets .. "/" .. Name .. ".json", HttpService:JSONEncode(FontData))
            return Font.new(getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".json"))
        end
        function CustomFont:Get(Name)
            if isfile(Library.Folders.Assets .. "/" .. Name .. ".json") then
                return Font.new(getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".json"))
            end
        end
        CustomFont:New("PoppinsMedium", 400, "Regular", { Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/Poppins-Medium.ttf" })
        Library.Font = CustomFont:Get("PoppinsMedium")
    end

    Library.Holder = Instances:Create("ScreenGui", { Parent = gethui(), Name = "\0", ZIndexBehavior = Enum.ZIndexBehavior.Global, DisplayOrder = 2, ResetOnSpawn = false })
    Library.UnusedHolder = Instances:Create("ScreenGui", { Parent = gethui(), Name = "\0", ZIndexBehavior = Enum.ZIndexBehavior.Global, Enabled = false })
    Library.NotifHolder = Instances:Create("Frame", { Parent = Library.Holder.Instance, Name = "\0", BackgroundTransparency = 1, Size = UDim2New(0, 0, 1, 0), BorderColor3 = FromRGB(0, 0, 0), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = FromRGB(255, 255, 255) })

    Instances:Create("UIListLayout", { Parent = Library.NotifHolder.Instance, Name = "\0", VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDimNew(0, 14), SortOrder = Enum.SortOrder.LayoutOrder })
    Instances:Create("UIPadding", { Parent = Library.NotifHolder.Instance, Name = "\0", PaddingTop = UDimNew(0, 12), PaddingBottom = UDimNew(0, 12), PaddingRight = UDimNew(0, 12), PaddingLeft = UDimNew(0, 12) })

    Library.Unload = function(self)
        for Index, Value in self.Connections do Value.Connection:Disconnect() end
        for Index, Value in self.Threads do coroutine.close(Value) end
        if self.Holder then self.Holder:Clean() end
        Library = nil
        getgenv().Library = nil
    end

    Library.GetImage = function(self, Image)
        local ImageData = self.Images[Image]
        if not ImageData then return end
        return getcustomasset(self.Folders.Assets .. "/" .. ImageData[1])
    end

    Library.Round = function(self, Number, Float)
        local Multiplier = 1 / (Float or 1)
        return MathFloor(Number * Multiplier) / Multiplier
    end

    Library.Thread = function(self, Function)
        local NewThread = coroutine.create(Function)
        coroutine.wrap(function() coroutine.resume(NewThread) end)()
        TableInsert(self.Threads, NewThread)
        return NewThread
    end

    Library.SafeCall = function(self, Function, ...)
        local Arguements = { ... }
        local Success, Result = pcall(Function, TableUnpack(Arguements))
        if not Success then warn(Result); return false end
        return Success
    end

    Library.Connect = function(self, Event, Callback, Name)
        Name = Name or StringFormat("Connection%s%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))
        local NewConnection = { Event = Event, Callback = Callback, Name = Name, Connection = nil }
        Library:Thread(function() NewConnection.Connection = Event:Connect(Callback) end)
        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    Library.Disconnect = function(self, Name)
        for _, Connection in self.Connections do
            if Connection.Name == Name then Connection.Connection:Disconnect(); break end
        end
    end

    Library.NextFlag = function(self)
        local FlagNumber = self.UnnamedFlags + 1
        return StringFormat("Flag%s%s", FlagNumber, HttpService:GenerateGUID(false))
    end

    Library.LimitHeight = function(self, Item, MaxHeight)
        Item = Item.Instance
        local AbsoluteSize = Item.AbsoluteSize
        if AbsoluteSize.Y >= MaxHeight then Item.Size = UDim2New(0, AbsoluteSize.X, 0, MaxHeight) end
    end

    Library.AddToTheme = function(self, Item, Properties)
        Item = Item.Instance or Item
        local ThemeData = { Item = Item, Properties = Properties }
        for Property, Value in ThemeData.Properties do
            if type(Value) == "string" then Item[Property] = self.Theme[Value] else Item[Property] = Value() end
        end
        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    Library.RemoveFromTheme = function(self, Item)
        Item = Item.Instance or Item
        if not self.ThemeMap[Item] then return end
        self.ThemeMap[Item].Properties = nil
        self.ThemeMap[Item] = nil
    end

    Library.ChangeItemTheme = function(self, Item, Properties)
        Item = Item.Instance or Item
        if not self.ThemeMap[Item] then return end
        self.ThemeMap[Item].Properties = Properties
        self.ThemeMap[Item] = self.ThemeMap[Item]
    end

    Library.ChangeTheme = function(self, Theme, Color)
        self.Theme[Theme] = Color
        for _, Item in self.ThemeItems do
            for Property, Value in Item.Properties do
                if type(Value) == "string" and Value == Theme then Item.Item[Property] = Color
                elseif type(Value) == "function" then Item.Item[Property] = Value() end
            end
        end
    end

    Library.GetConfig = function(self)
        local Config = { }
        local Success, Result = Library:SafeCall(function()
            for Index, Value in Library.Flags do
                if type(Value) == "table" and Value.Key then Config[Index] = {Key = tostring(Value.Key), Mode = Value.Mode}
                elseif type(Value) == "table" and Value.Color then Config[Index] = {Color = "#" .. Value.Color, Alpha = Value.Alpha}
                else Config[Index] = Value end
            end
        end)
        return HttpService:JSONEncode(Config)
    end

    Library.LoadConfig = function(self, Config)
        local Decoded = HttpService:JSONDecode(Config)
        local Success, Result = Library:SafeCall(function()
            for Index, Value in Decoded do
                local SetFunction = Library.SetFlags[Index]
                if not SetFunction then continue end
                if type(Value) == "table" and Value.Key then SetFunction(Value)
                elseif type(Value) == "table" and Value.Color then SetFunction(Value.Color, Value.Alpha)
                else SetFunction(Value) end
            end
        end)
        return Success, Result
    end

    Library.DeleteConfig = function(self, Config)
        if isfile(Library.Folders.Configs .. "/" .. Config) then delfile(Library.Folders.Configs .. "/" .. Config) end
    end

    Library.RefreshConfigsList = function(self, Element)
        local CurrentList = { }
        local List = { }
        local ConfigFolderName = StringGSub(Library.Folders.Configs, Library.Folders.Directory .. "/", "")
        for Index, Value in listfiles(Library.Folders.Configs) do
            local FileName = StringGSub(Value, Library.Folders.Directory .. "\\" .. ConfigFolderName .. "\\", "")
            List[Index] = FileName
        end
        local IsNew = #List ~= CurrentList
        if not IsNew then
            for Index = 1, #List do
                if List[Index] ~= CurrentList[Index] then IsNew = true; break end
            end
        else
            CurrentList = List
            Element:Refresh(CurrentList)
        end
    end

    Library.IsMouseOverFrame = function(self, Frame)
        Frame = Frame.Instance
        local MousePosition = Vector2New(Mouse.X, Mouse.Y)
        return MousePosition.X >= Frame.AbsolutePosition.X and MousePosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X
        and MousePosition.Y >= Frame.AbsolutePosition.Y and MousePosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
    end

    local Components = { } do
        Components.Toggle = function(self, Data)
            local Toggle = { Flag = Data.Flag, Value = false }
            local Items = { } do
                Items["Toggle"] = Instances:Create("TextButton", {
                    Parent = Data.Parent.Instance, Name = "\0", FontFace = Library.Font, TextColor3 = FromRGB(0,0,0),
                    BorderColor3 = FromRGB(0,0,0), Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
                    ZIndex = 2, Size = UDim2New(1,0,0,16), BorderSizePixel = 0, TextSize = 14, BackgroundColor3 = FromRGB(255,255,255)
                })
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Toggle"].Instance, Name = "\0", FontFace = Library.Font, TextColor3 = FromRGB(255,255,255),
                    BorderColor3 = FromRGB(0,0,0), Text = Data.Name, AnchorPoint = Vector2New(0,0.5), Size = UDim2New(0,0,0,15),
                    BackgroundTransparency = 1, Position = UDim2New(0,0,0.5,0), ZIndex = 2, BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, TextSize = 16, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["Text"]:AddToTheme({TextColor3 = "Text"})
                Items["Indicator"] = Instances:Create("Frame", {
                    Parent = Items["Toggle"].Instance, Name = "\0", AnchorPoint = Vector2New(1,0), Position = UDim2New(1,0,0,0),
                    ZIndex = 2, BorderColor3 = FromRGB(0,0,0), Size = UDim2New(0,18,0,18), BorderSizePixel = 0, BackgroundColor3 = FromRGB(40,38,49)
                }); Items["Indicator"]:AddToTheme({BackgroundColor3 = "Element"})
                Instances:Create("UICorner", { Parent = Items["Indicator"].Instance, Name = "\0", CornerRadius = UDimNew(0,5) })
                Instances:Create("UIGradient", {
                    Parent = Items["Indicator"].Instance, Name = "\0", Rotation = 90,
                    Color = RGBSequence{RGBSequenceKeypoint(0,FromRGB(255,255,255)),RGBSequenceKeypoint(1,FromRGB(211,211,211))}
                }):AddToTheme({Color = function() return RGBSequence{RGBSequenceKeypoint(0,FromRGB(255,255,255)),RGBSequenceKeypoint(1,Library.Theme["Gradient"])} end})
                Items["Check"] = Instances:Create("ImageLabel", {
                    Parent = Items["Indicator"].Instance, Name = "\0", ImageColor3 = FromRGB(0,0,0), ImageTransparency = 1,
                    BorderColor3 = FromRGB(0,0,0), AnchorPoint = Vector2New(0.5,0.5), Image = "rbxassetid://100217033137980",
                    BackgroundTransparency = 1, Position = UDim2New(0.5,0,0.5,0), ZIndex = 2, Size = UDim2New(1,-4,1,-4),
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(255,255,255)
                })
                Items["SubElements"] = Instances:Create("Frame", {
                    Parent = Items["Toggle"].Instance, Name = "\0", BorderColor3 = FromRGB(0,0,0), AnchorPoint = Vector2New(1,0),
                    BackgroundTransparency = 1, Position = UDim2New(1,-24,0,0), Size = UDim2New(0,0,1,0), ZIndex = 2,
                    BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = FromRGB(255,255,255)
                })
                Instances:Create("UIListLayout", {
                    Parent = Items["SubElements"].Instance, Name = "\0", FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDimNew(0,6), SortOrder = Enum.SortOrder.LayoutOrder
                })
            end
            function Toggle:Get() return self.Value end
            function Toggle:Set(Bool)
                self.Value = Bool
                Library.Flags[self.Flag] = self.Value
                if self.Value then
                    Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Accent"})
                    Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme.Accent})
                    Items["Check"]:Tween(nil, {ImageTransparency = 0})
                else
                    Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Element"})
                    Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme.Element})
                    Items["Check"]:Tween(nil, {ImageTransparency = 1})
                end
                if Data.Callback then Library:SafeCall(Data.Callback, self.Value) end
            end
            function Toggle:SetVisibility(Bool) Items["Toggle"].Instance.Visible = Bool end
            Items["Toggle"]:Connect("MouseButton1Down", function() Toggle:Set(not Toggle.Value) end)
            Toggle:Set(Data.Default)
            Library.SetFlags[Toggle.Flag] = function(Value) Toggle:Set(Value) end
            return Toggle, Items
        end

        Components.Button = function(self, Data)
            local Button = { }
            local Items = { } do
                Items["Button"] = Instances:Create("Frame", {
                    Parent = Data.Parent.Instance, Name = "\0", BackgroundTransparency = 1, BorderColor3 = FromRGB(0,0,0),
                    ZIndex = 2, Size = UDim2New(1,0,0,25), BorderSizePixel = 0, BackgroundColor3 = FromRGB(255,255,255)
                })
                Instances:Create("UIListLayout", {
                    Parent = Items["Button"].Instance, Name = "\0", FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill, Padding = UDimNew(0,8), SortOrder = Enum.SortOrder.LayoutOrder
                })
            end
            function Button:Add(Name, Callback)
                local SubButton = { }
                local SubItems = { }
                SubItems["NewButton"] = Instances:Create("TextButton", {
                    Parent = Items["Button"].Instance, Name = "\0", FontFace = Library.Font, TextColor3 = FromRGB(0,0,0),
                    BorderColor3 = FromRGB(0,0,0), Text = "", AutoButtonColor = false, Size = UDim2New(1,0,1,0),
                    BorderSizePixel = 0, ZIndex = 2, TextSize = 14, BackgroundColor3 = FromRGB(40,38,49)
                }); SubItems["NewButton"]:AddToTheme({BackgroundColor3 = "Element"})
                Instances:Create("UICorner", { Parent = SubItems["NewButton"].Instance, Name = "\0", CornerRadius = UDimNew(0,5) })
                Instances:Create("UIGradient", {
                    Parent = SubItems["NewButton"].Instance, Name = "\0", Rotation = 90,
                    Color = RGBSequence{RGBSequenceKeypoint(0,FromRGB(255,255,255)),RGBSequenceKeypoint(1,FromRGB(211,211,211))}
                }):AddToTheme({Color = function() return RGBSequence{RGBSequenceKeypoint(0,FromRGB(255,255,255)),RGBSequenceKeypoint(1,Library.Theme["Gradient"])} end})
                SubItems["Text"] = Instances:Create("TextLabel", {
                    Parent = SubItems["NewButton"].Instance, Name = "\0", FontFace = Library.Font, TextColor3 = FromRGB(255,255,255),
                    BorderColor3 = FromRGB(0,0,0), Text = Name, AnchorPoint = Vector2New(0.5,0.5), Size = UDim2New(0,0,0,15),
                    BackgroundTransparency = 1, Position = UDim2New(0.5,0,0.5,0), ZIndex = 2, BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, TextSize = 16, BackgroundColor3 = FromRGB(255,255,255)
                }); SubItems["Text"]:AddToTheme({TextColor3 = "Text"})
                function SubButton:Press()
                    SubItems["NewButton"]:ChangeItemTheme({BackgroundColor3 = "Accent"})
                    SubItems["NewButton"]:Tween(nil, {BackgroundColor3 = Library.Theme.Accent})
                    Library:SafeCall(Callback)
                    task.wait(0.1)
                    SubItems["NewButton"]:ChangeItemTheme({BackgroundColor3 = "Element"})
                    SubItems["NewButton"]:Tween(nil, {BackgroundColor3 = Library.Theme.Element})
                end
                SubItems["NewButton"]:Connect("MouseButton1Down", function() SubButton:Press() end)
                return SubButton, SubItems
            end
            return Button, Items
        end

        Components.Slider = function(self, Data)
            local Slider = { Flag = Data.Flag, Value = 0, Sliding = false }
            local Items = { } do
                Items["Slider"] = Instances:Create("Frame", {
                    Parent = Data.Parent.Instance, Name = "\0", BackgroundTransparency = 1, BorderColor3 = FromRGB(0,0,0),
                    Size = UDim2New(1,0,0,33), ZIndex = 2, BorderSizePixel = 0, BackgroundColor3 = FromRGB(255,255,255)
                })
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Slider"].Instance, Name = "\0", FontFace = Library.Font, TextColor3 = FromRGB(255,255,255),
                    BorderColor3 = FromRGB(0,0,0), Text = Data.Name, ZIndex = 2, BackgroundTransparency = 1, Size = UDim2New(0,0,0,15),
                    BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, TextSize = 16, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["Text"]:AddToTheme({TextColor3 = "Text"})
                Items["RealSlider"] = Instances:Create("TextButton", {
                    Parent = Items["Slider"].Instance, Text = "", AutoButtonColor = false, Name = "\0", AnchorPoint = Vector2New(0,1),
                    Position = UDim2New(0,0,1,0), BorderColor3 = FromRGB(0,0,0), Size = UDim2New(1,0,0,12), ZIndex = 2,
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(40,38,49), ClipsDescendants = true
                }); Items["RealSlider"]:AddToTheme({BackgroundColor3 = "Element"})
                Instances:Create("UICorner", { Parent = Items["RealSlider"].Instance, Name = "\0", CornerRadius = UDimNew(0,5) })
                Instances:Create("UIGradient", {
                    Parent = Items["RealSlider"].Instance, Name = "\0", Rotation = 90,
                    Color = RGBSequence{RGBSequenceKeypoint(0,FromRGB(255,255,255)),RGBSequenceKeypoint(1,FromRGB(211,211,211))}
                }):AddToTheme({Color = function() return RGBSequence{RGBSequenceKeypoint(0,FromRGB(255,255,255)),RGBSequenceKeypoint(1,Library.Theme["Gradient"])} end})
                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["RealSlider"].Instance, Name = "\0", BorderColor3 = FromRGB(0,0,0), Size = UDim2New(0.3,0,1,0),
                    BorderSizePixel = 0, ZIndex = 2, BackgroundColor3 = FromRGB(0,178,255)
                }); Items["Accent"]:AddToTheme({BackgroundColor3 = "Accent"})
                Instances:Create("UICorner", { Parent = Items["Accent"].Instance, Name = "\0", CornerRadius = UDimNew(0,5) })
                Items["Value"] = Instances:Create("TextLabel", {
                    Parent = Items["Slider"].Instance, Name = "\0", FontFace = Library.Font, TextColor3 = FromRGB(255,255,255),
                    ZIndex = 2, BorderColor3 = FromRGB(0,0,0), Text = "0", AnchorPoint = Vector2New(1,0), Size = UDim2New(0,0,0,15),
                    BackgroundTransparency = 1, Position = UDim2New(1,-1,0,0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X, TextSize = 16, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["Value"]:AddToTheme({TextColor3 = "Text"})
            end
            function Slider:Get() return self.Value end
            function Slider:Set(Value)
                self.Value = MathClamp(Library:Round(Value, Data.Decimals), Data.Min, Data.Max)
                Library.Flags[self.Flag] = self.Value
                Items["Accent"]:Tween(TweenInfo.new(0.21, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2New((self.Value - Data.Min) / (Data.Max - Data.Min), 0, 1, 0)})
                Items["Value"].Instance.Text = StringFormat("%s%s", tostring(self.Value), Data.Suffix)
                if Data.Callback then Library:SafeCall(Data.Callback, self.Value) end
            end
            function Slider:SetVisibility(Bool) Items["Slider"].Instance.Visible = Bool end
            local InputChanged
            Items["RealSlider"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Slider.Sliding = true
                    local SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                    Slider:Set(((Data.Max - Data.Min) * SizeX) + Data.Min)
                    if InputChanged then return end
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Slider.Sliding = false; InputChanged:Disconnect(); InputChanged = nil
                        end
                    end)
                end
            end)
            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Slider.Sliding then
                        local SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                        Slider:Set(((Data.Max - Data.Min) * SizeX) + Data.Min)
                    end
                end
            end)
            if Data.Default then Slider:Set(Data.Default) end
            Library.SetFlags[Slider.Flag] = function(Value) Slider:Set(Value) end
            return Slider, Items
        end

        Components.Textbox = function(self, Data)
            local Textbox = { Value = "", Flag = Data.Flag }
            local Items = { } do
                Items["Textbox"] = Instances:Create("Frame", {
                    Parent = Data.Parent.Instance, Name = "\0", BackgroundTransparency = 1, BorderColor3 = FromRGB(0,0,0),
                    ZIndex = 2, Size = UDim2New(1,0,0,47), BorderSizePixel = 0, BackgroundColor3 = FromRGB(255,255,255)
                })
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Textbox"].Instance, Name = "\0", FontFace = Library.Font, TextColor3 = FromRGB(255,255,255),
                    BorderColor3 = FromRGB(0,0,0), ZIndex = 2, Text = Data.Name, BackgroundTransparency = 1, Size = UDim2New(0,0,0,15),
                    BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, TextSize = 16, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["Text"]:AddToTheme({TextColor3 = "Text"})
                Items["Background"] = Instances:Create("Frame", {
                    Parent = Items["Textbox"].Instance, Name = "\0", AnchorPoint = Vector2New(0,1), Position = UDim2New(0,0,1,0),
                    BorderColor3 = FromRGB(0,0,0), Size = UDim2New(1,0,0,25), ZIndex = 2, BorderSizePixel = 0, BackgroundColor3 = FromRGB(40,38,49)
                }); Items["Background"]:AddToTheme({BackgroundColor3 = "Element"})
                Instances:Create("UICorner", { Parent = Items["Background"].Instance, Name = "\0", CornerRadius = UDimNew(0,5) })
                Items["Input"] = Instances:Create("TextBox", {
                    Parent = Items["Background"].Instance, Name = "\0", FontFace = Library.Font, AnchorPoint = Vector2New(0,0.5),
                    PlaceholderColor3 = FromRGB(185,185,185), PlaceholderText = Data.Placeholder, TextSize = 16, Size = UDim2New(1,-16,0,15),
                    TextColor3 = FromRGB(255,255,255), BorderColor3 = FromRGB(0,0,0), Text = "", BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Position = UDim2New(0,8,0.5,0), ClearTextOnFocus = false,
                    BorderSizePixel = 0, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["Input"]:AddToTheme({TextColor3 = "Text"})
            end
            function Textbox:Get() return self.Value end
            function Textbox:SetVisibility(Bool) Items["Textbox"].Instance.Visible = Bool end
            function Textbox:Set(Value)
                self.Value = Value
                Items["Input"].Instance.Text = Value
                Library.Flags[self.Flag] = Value
                if Data.Callback then Library:SafeCall(Data.Callback, Value) end
            end
            if Data.Finished then
                Items["Input"]:Connect("FocusLost", function(PressedEnter)
                    if PressedEnter then Textbox:Set(Items["Input"].Instance.Text) end
                end)
            else
                Items["Input"].Instance:GetPropertyChangedSignal("Text"):Connect(function()
                    Textbox:Set(Items["Input"].Instance.Text)
                end)
            end
            if Data.Default then Textbox:Set(Data.Default) end
            Library.SetFlags[Textbox.Flag] = function(Value) Textbox:Set(Value) end
            return Textbox, Items
        end
    end

    do -- Elements
        Library.Watermark = function(self, Name)
            local Watermark = { }
            local Items = { } do
                Items["Watermark"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance, Name = "\0", AnchorPoint = Vector2New(0.5,0), Position = UDim2New(0.5,0,0,20),
                    BorderColor3 = FromRGB(0,0,0), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = FromRGB(15,14,18)
                }); Items["Watermark"]:AddToTheme({BackgroundColor3 = "Background"})
                Items["Watermark"]:MakeDraggable()
                Instances:Create("UICorner", { Parent = Items["Watermark"].Instance, Name = "\0", CornerRadius = UDimNew(0,5) })
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Watermark"].Instance, Name = "\0", FontFace = Library.Font, TextColor3 = FromRGB(255,255,255),
                    BorderColor3 = FromRGB(0,0,0), Text = Name, BackgroundTransparency = 1, BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.XY, TextSize = 16, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["Text"]:AddToTheme({TextColor3 = "Text"})
                Instances:Create("UIPadding", { Parent = Items["Watermark"].Instance, Name = "\0", PaddingTop = UDimNew(0,8), PaddingBottom = UDimNew(0,8), PaddingRight = UDimNew(0,8), PaddingLeft = UDimNew(0,8) })
            end
            function Watermark:SetVisibility(Bool) Items["Watermark"].Instance.Visible = Bool end
            Library:Connect(RunService.RenderStepped, function()
                local FullTime = os.date("%I:%M %p")
                Items["Text"].Instance.Text = Name .. " - " .. FullTime
            end)
            return Watermark
        end

        Library.KeybindList = function(self)
            local KeyList = { }
            self.KeyList = KeyList
            local Items = { } do
                Items["KeybindList"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance, Name = "\0", Position = UDim2New(0,11,0,442), BorderColor3 = FromRGB(0,0,0),
                    BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = FromRGB(15,14,18)
                }); Items["KeybindList"]:AddToTheme({BackgroundColor3 = "Background"})
                Items["KeybindList"]:MakeDraggable()
                Instances:Create("UICorner", { Parent = Items["KeybindList"].Instance, Name = "\0", CornerRadius = UDimNew(0,5) })
                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["KeybindList"].Instance, Name = "\0", BackgroundTransparency = 1, BorderColor3 = FromRGB(0,0,0),
                    BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = FromRGB(255,255,255)
                })
                Instances:Create("UIListLayout", { Parent = Items["Content"].Instance, Name = "\0", Padding = UDimNew(0,4), SortOrder = Enum.SortOrder.LayoutOrder })
                Instances:Create("UIPadding", { Parent = Items["KeybindList"].Instance, Name = "\0", PaddingTop = UDimNew(0,8), PaddingBottom = UDimNew(0,8), PaddingRight = UDimNew(0,8), PaddingLeft = UDimNew(0,8) })
            end
            function KeyList:SetVisibility(Bool) Items["KeybindList"].Instance.Visible = Bool end
            return KeyList
        end

        Library.Notification = function(self, Name, Description, Duration)
            local Items = { } do
                Items["Notification"] = Instances:Create("Frame", {
                    Parent = Library.NotifHolder.Instance, Name = "\0", BorderColor3 = FromRGB(0,0,0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = FromRGB(15,14,18)
                }); Items["Notification"]:AddToTheme({BackgroundColor3 = "Background"})
                Instances:Create("UICorner", { Parent = Items["Notification"].Instance, Name = "\0", CornerRadius = UDimNew(0,6) })
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Notification"].Instance, Name = "\0", FontFace = Library.Font, TextColor3 = FromRGB(255,255,255),
                    BorderColor3 = FromRGB(0,0,0), Text = Name, BackgroundTransparency = 1, BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.XY, TextSize = 16, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["Text"]:AddToTheme({TextColor3 = "Text"})
                Instances:Create("UIPadding", { Parent = Items["Notification"].Instance, Name = "\0", PaddingTop = UDimNew(0,8), PaddingBottom = UDimNew(0,8), PaddingRight = UDimNew(0,8), PaddingLeft = UDimNew(0,8) })
                Items["Description"] = Instances:Create("TextLabel", {
                    Parent = Items["Notification"].Instance, Name = "\0", FontFace = Library.Font, TextColor3 = FromRGB(255,255,255),
                    TextTransparency = 0.5, Text = Description, BorderSizePixel = 0, BackgroundTransparency = 1, Position = UDim2New(0,0,0,18),
                    BorderColor3 = FromRGB(0,0,0), AutomaticSize = Enum.AutomaticSize.XY, TextSize = 16, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["Description"]:AddToTheme({TextColor3 = "Text"})
            end
            for Index, Value in Items do
                if Value.Instance:IsA("Frame") then Value.Instance.BackgroundTransparency = 1
                elseif Value.Instance:IsA("TextLabel") then Value.Instance.TextTransparency = 1 end
            end
            Items["Notification"].Instance.AutomaticSize = Enum.AutomaticSize.Y
            Library:Thread(function()
                for Index, Value in Items do
                    if Value.Instance:IsA("Frame") then Value:Tween(nil, {BackgroundTransparency = 0})
                    elseif Value.Instance:IsA("TextLabel") and Index ~= "Description" then Value:Tween(nil, {TextTransparency = 0})
                    elseif Value.Instance:IsA("TextLabel") and Index == "Description" then Value:Tween(nil, {TextTransparency = 0.5}) end
                end
                task.delay(Duration, function()
                    for Index, Value in Items do
                        if Value.Instance:IsA("Frame") then Value:Tween(nil, {BackgroundTransparency = 1})
                        elseif Value.Instance:IsA("TextLabel") then Value:Tween(nil, {TextTransparency = 1}) end
                    end
                    Items["Notification"]:Tween(nil, {Size = UDim2New(0, 0, 0, 0)})
                    task.wait(0.5)
                    Items["Notification"]:Clean()
                end)
            end)
        end

        Library.Window = function(self, Data)
            Data = Data or { }
            local Window = { Name = Data.Name or "Window", Pages = { }, Items = { } }
            local Items = { } do
                Items["MainFrame"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance, Name = "\0", AnchorPoint = Vector2New(0,0),
                    Position = UDim2New(0, Camera.ViewportSize.X/3-100, 0, Camera.ViewportSize.Y/3-100), BorderColor3 = FromRGB(0,0,0),
                    Visible = false, ClipsDescendants = true, ZIndex = 1, Size = UDim2New(0,833,0,562), BorderSizePixel = 0, BackgroundColor3 = FromRGB(15,14,18)
                }); Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background"})
                Items["MainFrame"]:MakeDraggable()
                local ResizeButton = Items["MainFrame"]:MakeResizeable(
                    Vector2New(Items["MainFrame"].Instance.Size.X.Offset, Items["MainFrame"].Instance.Size.Y.Offset),
                    Vector2New(9999, 9999)
                )
                Instances:Create("UICorner", { Parent = Items["MainFrame"].Instance, Name = "\0", CornerRadius = UDimNew(0,5) })
                Items["Topbar"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance, Name = "\0", BorderColor3 = FromRGB(0,0,0), ZIndex = 2,
                    Size = UDim2New(1,0,0,40), BorderSizePixel = 0, BackgroundColor3 = FromRGB(26,24,31)
                }); Items["Topbar"]:AddToTheme({BackgroundColor3 = "Inline"})
                Instances:Create("UICorner", { Parent = Items["Topbar"].Instance, Name = "\0", CornerRadius = UDimNew(0,5) })
                Items["Title"] = Instances:Create("TextLabel", {
                    Parent = Items["Topbar"].Instance, Name = "\0", FontFace = Library.Font, ZIndex = 2, TextColor3 = FromRGB(255,255,255),
                    BorderColor3 = FromRGB(0,0,0), Text = Window.Name, AnchorPoint = Vector2New(0,0.5), Size = UDim2New(0,0,0,15),
                    BackgroundTransparency = 1, Position = UDim2New(0,12,0.5,1), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 20, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["Title"]:AddToTheme({TextColor3 = "Text"})
                Items["CloseButton"] = Instances:Create("ImageButton", {
                    Parent = Items["Topbar"].Instance, Name = "\0", BorderColor3 = FromRGB(0,0,0), AutoButtonColor = false, ZIndex = 2,
                    AnchorPoint = Vector2New(1,0.5), Image = "rbxassetid://135157838478598", BackgroundTransparency = 1,
                    Position = UDim2New(1,-2,0.5,0), Size = UDim2New(0,32,0,32), BorderSizePixel = 0, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["CloseButton"]:AddToTheme({ImageColor3 = "Image"})
                Items["Pages"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance, Name = "\0", BackgroundTransparency = 1, Position = UDim2New(0,8,0,48),
                    ZIndex = 2, BorderColor3 = FromRGB(0,0,0), Size = UDim2New(0,185,1,-56), BorderSizePixel = 0, BackgroundColor3 = FromRGB(255,255,255)
                })
                Instances:Create("UIListLayout", { Parent = Items["Pages"].Instance, Name = "\0", Padding = UDimNew(0,8), SortOrder = Enum.SortOrder.LayoutOrder })
                Items["UserInfo"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance, Name = "\0", AnchorPoint = Vector2New(0,1), Position = UDim2New(0,8,1,-8),
                    BorderColor3 = FromRGB(0,0,0), ZIndex = 2, Size = UDim2New(0,185,0,40), BorderSizePixel = 0, BackgroundColor3 = FromRGB(26,24,31)
                }); Items["UserInfo"]:AddToTheme({BackgroundColor3 = "Inline"})
                Instances:Create("UICorner", { Parent = Items["UserInfo"].Instance, Name = "\0", CornerRadius = UDimNew(0,5) })
                Items["Username"] = Instances:Create("TextLabel", {
                    Parent = Items["UserInfo"].Instance, Name = "\0", FontFace = Library.Font, TextColor3 = FromRGB(255,255,255),
                    BorderColor3 = FromRGB(0,0,0), Text = LocalPlayer.Name, AnchorPoint = Vector2New(0,0.5), Size = UDim2New(0,0,0,15),
                    BackgroundTransparency = 1, Position = UDim2New(0,48,0.5,0), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16, ZIndex = 2, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["Username"]:AddToTheme({TextColor3 = "Text"})
                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance, Name = "\0", BackgroundTransparency = 1, Position = UDim2New(0,201,0,48),
                    ZIndex = 2, BorderColor3 = FromRGB(0,0,0), Size = UDim2New(1,-209,1,-56), BorderSizePixel = 0, BackgroundColor3 = FromRGB(255,255,255)
                })
                Window.Items = Items
            end
            local Debounce = false
            function Window:SetOpen(Bool)
                if Debounce then return end
                Window.IsOpen = Bool
                Debounce = true
                if Window.IsOpen then Items["MainFrame"].Instance.Visible = true end
                local Descendants = Items["MainFrame"].Instance:GetDescendants()
                TableInsert(Descendants, Items["MainFrame"].Instance)
                local NewTween
                for Index, Value in Descendants do
                    local TransparencyProperty = Tween:GetProperty(Value)
                    if not TransparencyProperty then continue end
                    if type(TransparencyProperty) == "table" then
                        for _, Property in TransparencyProperty do NewTween = Tween:FadeItem(Value, Property, Window.IsOpen, Library.FadeSpeed) end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Window.IsOpen, Library.FadeSpeed)
                    end
                end
                Library:Connect(NewTween.Tween.Completed, function()
                    Debounce = false
                    Items["MainFrame"].Instance.Visible = Window.IsOpen
                end)
            end
            Library:Connect(UserInputService.InputBegan, function(Input)
                if tostring(Input.KeyCode) == Library.MenuKeybind or tostring(Input.UserInputType) == Library.MenuKeybind then
                    Window:SetOpen(not Window.IsOpen)
                end
            end)
            Items["CloseButton"]:Connect("MouseButton1Down", function() Window:SetOpen(false) end)
            Window:SetOpen(true)
            return setmetatable(Window, self)
        end

        Library.Page = function(self, Data)
            Data = Data or { }
            local Page = { Window = self, Name = Data.Name or "New Page", Icon = Data.Icon, Columns = Data.Columns or 2, Active = false, Items = { }, ColumnsData = { } }
            local Items = { } do
                Items["Inactive"] = Instances:Create("TextButton", {
                    Parent = Page.Window.Items["Pages"].Instance, Name = "\0", FontFace = Library.Font, TextColor3 = FromRGB(0,0,0),
                    ZIndex = 2, BorderColor3 = FromRGB(0,0,0), Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
                    Size = UDim2New(1,0,0,35), BorderSizePixel = 0, TextSize = 14, BackgroundColor3 = FromRGB(26,24,31)
                }); Items["Inactive"]:AddToTheme({BackgroundColor3 = "Inline"})
                Instances:Create("UICorner", { Parent = Items["Inactive"].Instance, Name = "\0", CornerRadius = UDimNew(0,5) })
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Inactive"].Instance, Name = "\0", FontFace = Library.Font, ZIndex = 2, TextColor3 = FromRGB(255,255,255),
                    TextTransparency = 0.5, Text = Page.Name, Size = UDim2New(0,0,0,15), AnchorPoint = Vector2New(0,0.5), BorderSizePixel = 0,
                    BackgroundTransparency = 1, Position = UDim2New(0,32,0.5,1), BorderColor3 = FromRGB(0,0,0), AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 16, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["Text"]:AddToTheme({TextColor3 = "Text"})
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Inactive"].Instance, Name = "\0", ImageTransparency = 0.5, BorderColor3 = FromRGB(0,0,0),
                    ZIndex = 2, AnchorPoint = Vector2New(0,0.5), Image = Page.Icon, BackgroundTransparency = 1,
                    Position = UDim2New(0,8,0.5,0), Size = UDim2New(0,16,0,16), BorderSizePixel = 0, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["Icon"]:AddToTheme({ImageColor3 = "Image"})
                Items["Page"] = Instances:Create("Frame", {
                    Parent = Page.Window.Items["Content"].Instance, Name = "\0", Visible = false, BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0,0,0), ZIndex = 2, Size = UDim2New(1,0,1,0), BorderSizePixel = 0, BackgroundColor3 = FromRGB(255,255,255)
                })
                Items["Columns"] = Instances:Create("Frame", {
                    Parent = Items["Page"].Instance, Name = "\0", BackgroundTransparency = 1, Position = UDim2New(0,0,0,0),
                    BorderColor3 = FromRGB(0,0,0), Size = UDim2New(1,0,1,0), ZIndex = 2, BorderSizePixel = 0, BackgroundColor3 = FromRGB(255,255,255)
                })
                Instances:Create("UIListLayout", {
                    Parent = Items["Columns"].Instance, Name = "\0", FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder, HorizontalFlex = Enum.UIFlexAlignment.Fill
                })
                for Index = 1, Page.Columns do
                    local NewColumn = Instances:Create("ScrollingFrame", {
                        Parent = Items["Columns"].Instance, Name = "\0", ScrollBarImageColor3 = FromRGB(0,0,0), Active = true,
                        AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0, BackgroundTransparency = 1, Size = UDim2New(1,0,1,0),
                        BackgroundColor3 = FromRGB(255,255,255), BorderColor3 = FromRGB(0,0,0), BorderSizePixel = 0, CanvasSize = UDim2New(0,0,0,0)
                    })
                    Instances:Create("UIPadding", { Parent = NewColumn.Instance, Name = "\0", PaddingTop = UDimNew(0,4), PaddingBottom = UDimNew(0,4), PaddingRight = UDimNew(0,8), PaddingLeft = UDimNew(0,8) })
                    Instances:Create("UIListLayout", { Parent = NewColumn.Instance, Name = "\0", Padding = UDimNew(0,8), SortOrder = Enum.SortOrder.LayoutOrder })
                    Page.ColumnsData[Index] = NewColumn
                end
                Page.Items = Items
            end
            local Debounce = false
            function Page:Turn(Bool)
                if Debounce then return end
                Page.Active = Bool
                Debounce = true
                Items["Page"].Instance.Visible = Bool
                if Page.Active then
                    Items["Icon"]:ChangeItemTheme({ImageColor3 = "Accent"})
                    Items["Icon"]:Tween(nil, {ImageColor3 = Library.Theme.Accent, ImageTransparency = 0})
                    Items["Text"]:Tween(nil, {TextTransparency = 0})
                    Items["Inactive"]:Tween(nil, {BackgroundTransparency = 0})
                else
                    Items["Icon"]:ChangeItemTheme({ImageColor3 = "Image"})
                    Items["Icon"]:Tween(nil, {ImageColor3 = Library.Theme.Image, ImageTransparency = 0.5})
                    Items["Text"]:Tween(nil, {TextTransparency = 0.5})
                    Items["Inactive"]:Tween(nil, {BackgroundTransparency = 1})
                end
                task.delay(Library.FadeSpeed, function() Debounce = false end)
            end
            Items["Inactive"]:Connect("MouseButton1Down", function()
                for Index, Value in Page.Window.Pages do Value:Turn(Value == Page) end
            end)
            if #Page.Window.Pages == 0 then Page:Turn(true) end
            TableInsert(Page.Window.Pages, Page)
            return setmetatable(Page, Library.Pages)
        end

        Library.Pages.Section = function(self, Data)
            Data = Data or { }
            local Section = { Window = self.Window, Page = self, Name = Data.Name or "Section", Side = Data.Side or 1, Items = { } }
            local Items = { } do
                Items["Section"] = Instances:Create("Frame", {
                    Parent = Section.Page.ColumnsData[Section.Side].Instance, Name = "\0", Size = UDim2New(1,0,0,25), BorderColor3 = FromRGB(0,0,0),
                    BorderSizePixel = 0, ZIndex = 2, AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = FromRGB(26,24,31)
                }); Items["Section"]:AddToTheme({BackgroundColor3 = "Inline"})
                Instances:Create("UICorner", { Parent = Items["Section"].Instance, Name = "\0", CornerRadius = UDimNew(0,5) })
                Instances:Create("UIPadding", { Parent = Items["Section"].Instance, Name = "\0", PaddingBottom = UDimNew(0,8) })
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Section"].Instance, Name = "\0", FontFace = Library.Font, TextColor3 = FromRGB(255,255,255),
                    BorderColor3 = FromRGB(0,0,0), Text = Section.Name, Size = UDim2New(0,0,0,15), BackgroundTransparency = 1, ZIndex = 2,
                    Position = UDim2New(0,8,0,8), BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.X, TextSize = 16, BackgroundColor3 = FromRGB(255,255,255)
                }); Items["Text"]:AddToTheme({TextColor3 = "Text"})
                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["Section"].Instance, Name = "\0", BorderColor3 = FromRGB(0,0,0), BackgroundTransparency = 1,
                    Position = UDim2New(0,8,0,40), ZIndex = 2, Size = UDim2New(1,-16,0,0), BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = FromRGB(255,255,255)
                })
                Instances:Create("UIListLayout", { Parent = Items["Content"].Instance, Name = "\0", Padding = UDimNew(0,8), SortOrder = Enum.SortOrder.LayoutOrder })
                Section.Items = Items
            end
            return setmetatable(Section, Library.Sections)
        end

        Library.Sections.Toggle = function(self, Data)
            Data = Data or { }
            local Toggle = { Window = self.Window, Page = self.Page, Section = self, Name = Data.Name or "Toggle",
                Flag = Data.Flag or Library:NextFlag(), Default = Data.Default or false, Callback = Data.Callback or function() end }
            local NewToggle = Components:Toggle({ Name = Toggle.Name, Parent = Toggle.Section.Items["Content"], Flag = Toggle.Flag, Default = Toggle.Default, Callback = Toggle.Callback })
            return NewToggle
        end

        Library.Sections.Button = function(self)
            local Button = { Window = self.Window, Page = self.Page, Section = self }
            local NewButton = Components:Button({ Parent = Button.Section.Items["Content"] })
            return NewButton
        end

        Library.Sections.Slider = function(self, Data)
            Data = Data or { }
            local Slider = { Window = self.Window, Page = self.Page, Section = self, Name = Data.Name or "Slider",
                Flag = Data.Flag or Library:NextFlag(), Default = Data.Default or 0, Min = Data.Min or 0, Max = Data.Max or 100,
                Decimals = Data.Decimals or 1, Callback = Data.Callback or function() end, Suffix = Data.Suffix or "" }
            local NewSlider = Components:Slider({ Name = Slider.Name, Parent = Slider.Section.Items["Content"], Flag = Slider.Flag,
                Default = Slider.Default, Min = Slider.Min, Max = Slider.Max, Decimals = Slider.Decimals, Suffix = Slider.Suffix, Callback = Slider.Callback })
            return NewSlider
        end

        Library.Sections.Textbox = function(self, Data)
            Data = Data or { }
            local Textbox = { Window = self.Window, Page = self.Page, Section = self, Name = Data.Name or "Textbox",
                Flag = Data.Flag or Library:NextFlag(), Default = Data.Default or "", Callback = Data.Callback or function() end,
                Placeholder = Data.Placeholder or "...", Finished = Data.Finished }
            local NewTextbox = Components:Textbox({ Name = Textbox.Name, Parent = Textbox.Section.Items["Content"], Flag = Textbox.Flag,
                Default = Textbox.Default, Placeholder = Textbox.Placeholder, Finished = Textbox.Finished, Callback = Textbox.Callback })
            return NewTextbox
        end
    end
end

return Library
