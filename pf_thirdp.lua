-- Services
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local plrs = game:GetService("Players")
local ws = game:GetService("Workspace")

-- Local
local plr = plrs.LocalPlayer
local fake_rep_object = nil

local game_client = {}

do -- Client Collector
    local garbage = getgc(true)
    local loaded_modules = getloadedmodules()

    for i = 1, #garbage do
        local v = garbage[i]
        if typeof(v) == "table" then
            if rawget(v, "send") and rawget(v, "fetch") then -- Networking Module
                game_client.network = v
            elseif rawget(v, "getCharacterObject") then -- Used for sending LocalPlayer Character Data to Server
                game_client.character_interface = v
            elseif rawget(v, "updateReplication") and rawget(v, "getThirdPersonObject") then -- This represents a "Player" separate from their character
                game_client.replication_object = v
            elseif rawget(v, "getController") then -- Weapon Detection
                game_client.weapon_controller_interface = v
            elseif rawget(v, "getCharacterModel") and rawget(v, 'popCharacterModel') then -- Used for Displaying other Characters
                game_client.third_person_object = v
            end
        end
    end

    for i = 1, #loaded_modules do
        local v = loaded_modules[i]
        if v.Name == "ActiveLoadoutUtils" then
            game_client.active_loadout = require(v)
        elseif v.Name == "GameClock" then
            game_client.game_clock = require(v)
        elseif v.Name == "PlayerDataStoreClient" then
            game_client.player_data = require(v)
        elseif v.Name == "ContentDatabase" then
            game_client.content_database = require(v)
        end
    end
end

local old_send = game_client.network.send
local old_new_index

local library = {}
local utility = {}
local shared = {
    drawings = {},
    connections = {},
    hidden_connections = {},
    pointers = {},
    theme = {
        inline = Color3.fromRGB(6, 6, 6),
        dark = Color3.fromRGB(24, 24, 24),
        text = Color3.fromRGB(255, 255, 255),
        section = Color3.fromRGB(150, 150, 150),
        accent = Color3.fromRGB(0, 102, 255)
    },
    accents = {},
    moveKeys = {
        ["Movement"] = {
            ["Up"] = "Up",
            ["Down"] = "Down"
        },
        ["Action"] = {
            ["Return"] = "Enter",
            ["Left"] = "Left",
            ["Right"] = "Right"
        }
    },
    allowedKeyCodes = {"Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","One","Two","Three","Four","Five","Six","Seveen","Eight","Nine","0","Insert","Tab","Home","End","LeftAlt","LeftControl","LeftShift","RightAlt","RightControl","RightShift","CapsLock","Return","Up","Down","Left","Right"},
    allowedInputTypes = {"MouseButton1","MouseButton2","MouseButton3"},
    shortenedInputs = {["MouseButton1"] = "MB1", ["MouseButton2"] = "MB2", ["MouseButton3"] = "MB3", ["Insert"] = "Ins", ["LeftAlt"] = "LAlt", ["LeftControl"] = "LCtrl", ["LeftShift"] = "LShift", ["RightAlt"] = "RAlt", ["RightControl"] = "RCtrl", ["RightShift"] = "RShift", ["CapsLock"] = "Caps"},
    colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 100, 0), Color3.fromRGB(255, 200, 0), Color3.fromRGB(210, 255, 0), Color3.fromRGB(110, 255, 0), Color3.fromRGB(10, 255, 0), Color3.fromRGB(0, 255, 90), Color3.fromRGB(0, 255, 190), Color3.fromRGB(0, 220, 255), Color3.fromRGB(0, 120, 255), Color3.fromRGB(0, 20, 255), Color3.fromRGB(80, 0, 255), Color3.fromRGB(180, 0, 255), Color3.fromRGB(255, 0, 230), Color3.fromRGB(255, 0, 130), Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0)},
    toggleKey = {Enum.KeyCode.Home, true},
    unloadKey = {Enum.KeyCode.End, true},
    windowActive = true
}

-- Utility Functions
do
    function utility:Create(instanceType, instanceProperties)
        local instance = Drawing.new(instanceType)
        local parent
        --
        if instanceProperties["Parent"] or instanceProperties["parent"] then
            parent = instanceProperties["Parent"] or instanceProperties["parent"]
            --
            instanceProperties["parent"] = nil
            instanceProperties["Parent"] = nil
        end
        --
        for property, value in pairs(instanceProperties) do
            if property and value then
                if property == "Size" or property == "Size" then
                    if instanceType == "Text" then
                        instance.Size = value
                    else
                        local xSize = (value.X.Scale * ((parent and parent.Size) or ws.CurrentCamera.ViewportSize).X) + value.X.Offset
                        local ySize = (value.Y.Scale * ((parent and parent.Size) or ws.CurrentCamera.ViewportSize).Y) + value.Y.Offset
                        --
                        instance.Size = Vector2.new(xSize, ySize)
                    end
                elseif property == "Position" or property == "position" then
                    if instanceType == "Text" then
                        local xPosition = ((((parent and parent.Position) or Vector2.new(0, 0)).X) + (value.X.Scale * ((typeof(parent.Size) == "number" and parent.TextBounds) or parent.Size).X)) + value.X.Offset
                        local yPosition = ((((parent and parent.Position) or Vector2.new(0, 0)).Y) + (value.Y.Scale * ((typeof(parent.Size) == "number" and parent.TextBounds) or parent.Size).Y)) + value.Y.Offset
                        --
                        instance.Position = Vector2.new(xPosition, yPosition)
                    else
                        local xPosition = ((((parent and parent.Position) or Vector2.new(0, 0)).X) + value.X.Scale * ((parent and parent.Size) or ws.CurrentCamera.ViewportSize).X) + value.X.Offset
                        local yPosition = ((((parent and parent.Position) or Vector2.new(0, 0)).Y) + value.Y.Scale * ((parent and parent.Size) or ws.CurrentCamera.ViewportSize).Y) + value.Y.Offset
                        --
                        instance.Position = Vector2.new(xPosition, yPosition)
                    end
                elseif property == "Color" or property == "color" then
                    if typeof(value) == "string" then
                        instance["Color"] = shared.theme[value]
                        --
                        if value == "accent" then
                            shared.accents[#shared.accents + 1] = instance
                        end
                    else
                        instance[property] = value
                    end
                else
                    instance[property] = value
                end
            end
        end
        --
        shared.drawings[#shared.drawings + 1] = instance
        --
        return instance
    end
    --
    function utility:Update(instance, instanceProperty, instanceValue, instanceParent)
        if instanceProperty == "Size" or instanceProperty == "Size" then
            local xSize = (instanceValue.X.Scale * ((instanceParent and instanceParent.Size) or ws.CurrentCamera.ViewportSize).X) + instanceValue.X.Offset
            local ySize = (instanceValue.Y.Scale * ((instanceParent and instanceParent.Size) or ws.CurrentCamera.ViewportSize).Y) + instanceValue.Y.Offset
            --
            instance.Size = Vector2.new(xSize, ySize)
        elseif instanceProperty == "Position" or instanceProperty == "position" then
                local xPosition = ((((instanceParent and instanceParent.Position) or Vector2.new(0, 0)).X) + (instanceValue.X.Scale * ((typeof(instanceParent.Size) == "number" and instanceParent.TextBounds) or instanceParent.Size).X)) + instanceValue.X.Offset
                local yPosition = ((((instanceParent and instanceParent.Position) or Vector2.new(0, 0)).Y) + (instanceValue.Y.Scale * ((typeof(instanceParent.Size) == "number" and instanceParent.TextBounds) or instanceParent.Size).Y)) + instanceValue.Y.Offset
                --
                instance.Position = Vector2.new(xPosition, yPosition)
        elseif instanceProperty == "Color" or instanceProperty == "color" then
            if typeof(instanceValue) == "string" then
                instance.Color = shared.theme[instanceValue]
                --
                if instanceValue == "accent" then
                    shared.accents[#shared.accents + 1] = instance
                else
                    if table.find(shared.accents, instance) then
                        table.remove(shared.accents, table.find(shared.accents, instance))
                    end
                end
            else
                instance.Color = instanceValue
            end
        end
    end
    --
    function utility:Connection(connectionType, connectionCallback)
        local connection = connectionType:Connect(connectionCallback)
        shared.connections[#shared.connections + 1] = connection
        --
        return connection
    end
    --
    function utility:RemoveConnection(connection)
        for index, con in pairs(shared.connections) do
            if con == connection then
                shared.connections[index] = nil
                con:Disconnect()
            end
        end
        --
        for index, con in pairs(shared.hidden_connections) do
            if con == connection then
                shared.hidden_connections[index] = nil
                con:Disconnect()
            end
        end
    end
    --
    function utility:Lerp(instance, instanceTo, instanceTime)
        local currentTime = 0
        local currentIndex = {}
        local connection
        --
        for i,v in pairs(instanceTo) do
            currentIndex[i] = instance[i]
        end
        --
        local function lerp()
            for i,v in pairs(instanceTo) do
                instance[i] = ((v - currentIndex[i]) * currentTime / instanceTime) + currentIndex[i]
            end
        end
        --
        connection = rs.RenderStepped:Connect(function(delta)
            if currentTime < instanceTime then
                currentTime = currentTime + delta
                lerp()
            else
                connection:Disconnect()
            end
        end)
    end
    --
    function utility:Unload()
        for i,v in pairs(shared.drawings) do
            v:Remove()
        end
        --
        for i,v in pairs(shared.connections) do
            v:Disconnect()
        end
        --
        shared.drawings = nil
        shared.connections = nil
        --
        local third_person_object = fake_rep_object:getThirdPersonObject()
        if third_person_object then
            local character_model = third_person_object:popCharacterModel()
            character_model:Destroy()
            fake_rep_object:despawn()
        end
        --
        shared = nil
        utility = nil
        library = nil
    end
    --
    function utility:Toggle()
        shared.toggleKey[2] = not shared.toggleKey[2]
        --
        for index, drawing in pairs(shared.drawings) do
            if getmetatable(drawing).__type == "Text" then
                utility:Lerp(drawing, {Transparency = shared.toggleKey[2] and 1 or 0}, 0.15)
            else
                utility:Lerp(drawing, {Transparency = shared.toggleKey[2] and 1 or 0}, 0.25)
            end
        end
    end
    --
    function utility:ChangeAccent(accentColor)
        shared.theme.accent = accentColor
        --
        for index, drawing in pairs(shared.accents) do
            drawing.Color = shared.theme.accent
        end
    end
    --
    function utility:Object(type, properties)
        local object = Instance.new(type)
        for i,v in next, properties do
            object[i] = v
        end
        return object
    end
    --
    function utility:Round(n, scale)
        return tonumber(string.format("%." .. (typeof(scale) == "number" and scale or 2) .. "f", n))
    end
end

-- Library Functions
do
    function library:Window(windowProperties)
        -- // Variables
        local window = {
            current = nil,
            currentindex = 1,
            content = {},
            pages = {}
        }
        local windowProperties = windowProperties or {}
        --
        local windowName = windowProperties.name or windowProperties.Name or "New Window"
        -- // Functions
        function window:Movement(moveAction, moveDirection)
            if moveAction == "Movement" then
                window.content[window.currentindex]:Turn(false)
                --
                if window.content[moveDirection == "Down" and window.currentindex + 1 or window.currentindex - 1] then
                    window.currentindex = moveDirection == "Down" and window.currentindex + 1 or window.currentindex - 1
                else
                    window.currentindex = moveDirection == "Down" and 1 or #window.content
                end
                --
                window.content[window.currentindex]:Turn(true)
            else
                window.content[window.currentindex]:Action(moveDirection)
            end
        end
        --
        function window:ChangeKeys(keyType, moveDirection, newKey)
            for i,v in pairs(shared.moveKeys[keyType]) do
                if tostring(v) == tostring(moveDirection) then
                    shared.moveKeys[keyType][i] = nil
                    shared.moveKeys[keyType][newKey] = moveDirection
                end
            end
        end
        -- // Main
        local windowFrame = utility:Create("Square", {
            Visible = true,
            Filled = true,
            Thickness = 0,
            Color = shared.theme.inline,
            Size = UDim2.new(0, 280, 0, 19),
            Position = UDim2.new(0, 50, 0, 80)
        })
        --
        local windowInline = utility:Create("Square", {
            Parent = windowFrame,
            Visible = true,
            Filled = true,
            Thickness = 0,
            Color = shared.theme.dark,
            Size = UDim2.new(1, -2, 1, -4),
            Position = UDim2.new(0, 1, 0, 3)
        })
        --
        local windowAccent = utility:Create("Square", {
            Parent = windowFrame,
            Visible = true,
            Filled = true,
            Thickness = 0,
            Color = "accent",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 0, 0)
        })
        --
        local windowText = utility:Create("Text", {
            Parent = windowAccent,
            Visible = true,
            Text = windowName,
            Center = true,
            Outline = true,
            Font = 2,
            Color = shared.theme.text,
            Size = 13,
            Position = UDim2.new(0.5, 0, 0, 3)
        })
        -- // Connections
        utility:Connection(uis.InputBegan, function(Input)
            if shared.toggleKey[2] and Input.KeyCode then
                if shared.moveKeys["Movement"][Input.KeyCode.Name] then
                    window:Movement("Movement", shared.moveKeys["Movement"][Input.KeyCode.Name])
                elseif shared.moveKeys["Action"][Input.KeyCode.Name] then
                    window:Movement("Action", shared.moveKeys["Action"][Input.KeyCode.Name])
                end
            end
            --
            if Input.KeyCode and Input.KeyCode == shared.toggleKey[1] then
                utility:Toggle()
            end
        end)

        -- // Nested Functions
        function window:ChangeName(newName)
            windowText.Text = newName
        end
        --
        function window:Refresh()
            window.content = {}
            local contentCount = 0
            --
            for index, page in pairs(window.pages) do
                page:Position(19 + (contentCount * 17))
                window.content[#window.content + 1] = page
                contentCount = contentCount + 1
                --
                if page.open then
                    for index, section in pairs(page.sections) do
                        section:Position(19 + (contentCount * 17))
                        contentCount = contentCount + 1
                        --
                        for index, content in pairs(section.content) do
                            content:Position(19 + (contentCount * 17))
                            if not content.noaction then
                                window.content[#window.content + 1] = content
                            end
                            contentCount = contentCount + 1
                        end
                    end
                end
            end
            --
            utility:Update(windowFrame, "Size", UDim2.new(0, 280, 0, 23 + (contentCount * 17)))
            utility:Update(windowInline, "Size", UDim2.new(1, -2, 1, -4), windowFrame)
        end
        --
        function window:Page(pageProperties)
            -- // Variables
            local page = {open = false, sections = {}}
            local pageProperties = pageProperties or {}
            --
            local pageName = pageProperties.name or pageProperties.Name or "New Page"
            -- // Functions
            -- // Main
            local pageText = utility:Create("Text", {
                Parent = windowFrame,
                Visible = true,
                Text = "[+] "..pageName,
                Outline = true,
                Font = 2,
                Color = (#window.content == 0 and shared.theme.accent or shared.theme.text),
                Size = 13,
                Position = UDim2.new(0, 5, 0, 19 + ((#window.content) * 17))
            })
            -- // Nested Functions
            function page:Turn(state)
                if state then
                    utility:Update(pageText, "Color", "accent")
                else
                    utility:Update(pageText, "Color", "text")
                end
            end
            --
            function page:Position(yAxis)
                utility:Update(page.text, "Position", UDim2.new(0, 5, 0, yAxis), windowFrame)
            end
            --
            function page:Open(state, externalOpen)
                if not externalOpen then
                    local ind = 0
                    for index, other_page in pairs(window.pages) do
                        if other_page == page then
                            ind = index
                        else
                            if other_page.open then
                                other_page:Open(false, true)
                            end
                        end
                    end
                    --
                    window.currentindex = ind
                end
                --
                page.open = state
                pageText.Text = (page.open and "[-] " or "[+] ") .. pageName
                --
                for index, section in pairs(page.sections) do
                    section:Open(page.open)
                end
                --
                window:Refresh()
            end
            --
            function page:Action(action)
                if action == "Enter" then
                    page:Open(not page.open)
                elseif action == "Right" and not page.open then
                    page:Open(true)
                elseif action == "Left" and page.open then
                    page:Open(false)
                end
            end
            --
            function page:Section(sectionProperties)
                -- // Variables
                local section = {content = {}}
                local sectionProperties = sectionProperties or {}
                --
                local sectionName = sectionProperties.name or sectionProperties.Name or "New Section"
                -- // Functions
                -- // Main
                local sectionText = utility:Create("Text", {
                    Visible = false,
                    Text = "["..sectionName.."]",
                    Outline = true,
                    Font = 2,
                    Color = shared.theme.section,
                    Size = 13
                })
                -- // Nested Functions
                function section:Open(state)
                    section.text.Visible = state
                    --
                    for index, content in pairs(section.content) do
                        content:Open(state)
                    end
                end
                --
                function section:Position(yAxis)
                    utility:Update(section.text, "Position", UDim2.new(0, 22, 0, yAxis), windowFrame)
                end
                --
                function section:Label(labelProperties)
                    -- // Variables
                    local label = {noaction = true}
                    local labelProperties = labelProperties or {}
                    --
                    local labelName = labelProperties.name or labelProperties.Name or "New Label"
                    -- // Functions
                    -- // Main
                    local labelText = utility:Create("Text", {
                        Visible = false,
                        Text = labelName,
                        Outline = true,
                        Font = 2,
                        Color = shared.theme.text,
                        Size = 13
                    })
                    -- // Nested Functions
                    function label:Turn(state)
                        if state then
                            utility:Update(label.text, "Color", "accent")
                        else
                            utility:Update(label.text, "Color", "text")
                        end
                    end
                    --
                    function label:Position(yAxis)
                        utility:Update(label.text, "Position", UDim2.new(0, 22, 0, yAxis), windowFrame)
                    end
                    --
                    function label:Open(state)
                        label.text.Visible = state
                    end
                    --
                    function label:Action(action)
                    end
                    -- // Returning + Other
                    label.name = labelName
                    label.text = labelText
                    --
                    section.content[#section.content + 1] = label
                    --
                    return label
                end
                --
                function section:Button(buttonProperties)
                    -- // Variables
                    local button = {}
                    local buttonProperties = buttonProperties or {}
                    --
                    local buttonName = buttonProperties.name or buttonProperties.Name or "New Button"
                    local buttonConfirm = buttonProperties.confirm or buttonProperties.Confirm or false
                    local buttonCallback = buttonProperties.callback or buttonProperties.Callback or buttonProperties.CallBack or buttonProperties.callBack or function() end
                    -- // Functions
                    -- // Main
                    local buttonText = utility:Create("Text", {
                        Visible = false,
                        Text = buttonName,
                        Outline = true,
                        Font = 2,
                        Color = shared.theme.text,
                        Size = 13
                    })
                    -- // Nested Functions
                    function button:Turn(state)
                        if state then
                            utility:Update(button.text, "Color", "accent")
                        else
                            utility:Update(button.text, "Color", "text")
                        end
                    end
                    --
                    function button:Position(yAxis)
                        utility:Update(button.text, "Position", UDim2.new(0, 22, 0, yAxis), windowFrame)
                    end
                    --
                    function button:Open(state)
                        button.text.Visible = state
                    end
                    --
                    function button:Action(action)
                        if buttonConfirm and button.text.Text ~= "confirm?" then
                            button.text.Text = "confirm?"
                            task.delay(3, function()
                                if button.text.Text == "confirm?" then
                                    button.text.Text = buttonName
                                end
                            end)
                            return
                        end
                        --
                        button.text.Text = "<"..buttonName..">"
                        --
                        buttonCallback()
                        --
                        wait(0.2)
                        button.text.Text = buttonName
                    end
                    -- // Returning + Other
                    button.name = buttonName
                    button.text = buttonText
                    --
                    section.content[#section.content + 1] = button
                    --
                    return button
                end
                --
                function section:Toggle(toggleProperties)
                    local toggle = {}
                    local toggleProperties = toggleProperties or {}
                    --
                    local toggleName = toggleProperties.name or toggleProperties.Name or "New Toggle"
                    local toggleDefault = toggleProperties.default or toggleProperties.Default or toggleProperties.def or toggleProperties.Def or false
                    local togglePointer = toggleProperties.pointer or toggleProperties.Pointer or toggleProperties.flag or toggleProperties.Flag or nil
                    local toggleCallback = toggleProperties.callback or toggleProperties.Callback or toggleProperties.CallBack or toggleProperties.callBack or function() end
                    -- // Functions
                    -- // Main
                    local toggleText = utility:Create("Text", {
                        Visible = false,
                        Text = toggleName .. " -> " .. (toggleDefault and "ON" or "OFF"),
                        Outline = true,
                        Font = 2,
                        Color = shared.theme.text,
                        Size = 13
                    })
                    -- // Nested Functions
                    function toggle:Turn(state)
                        if state then
                            utility:Update(toggle.text, "Color", "accent")
                        else
                            utility:Update(toggle.text, "Color", "text")
                        end
                    end
                    --
                    function toggle:Position(yAxis)
                        utility:Update(toggle.text, "Position", UDim2.new(0, 22, 0, yAxis), windowFrame)
                    end
                    --
                    function toggle:Open(state)
                        toggle.text.Visible = state
                    end
                    --
                    function toggle:Action(action)
                        toggle.current = not toggle.current
                        toggle.text.Text = toggle.name .. " -> " .. (toggle.current and "ON" or "OFF")
                        --
                        toggleCallback(toggle.current)
                    end
                    -- // Returning + Other
                    toggle.name = toggleName
                    toggle.text = toggleText
                    toggle.current = toggleDefault
                    --
                    section.content[#section.content + 1] = toggle
                    --
                    if togglePointer then
                        local pointer = {}
                        --
                        function pointer:Get()
                            return toggle.current
                        end
                        --
                        function pointer:Set(value)
                            if typeof(value) == "bool" then
                                toggle.current = value
                                toggle.text.Text = toggle.name .. " -> " .. (toggle.current and "ON" or "OFF")
                                --
                                toggleCallback(toggle.current)
                            end
                        end
                        --
                        shared.pointers[togglePointer] = pointer
                    end
                    --
                    return toggle
                end
                --
                function section:Slider(sliderProperties)
                    local slider = {}
                    local sliderProperties = sliderProperties or {}
                    --
                    local sliderName = sliderProperties.name or sliderProperties.Name or "New Toggle"
                    local sliderDefault = sliderProperties.default or sliderProperties.Default or sliderProperties.def or sliderProperties.Def or 1
                    local sliderMax = sliderProperties.max or sliderProperties.Max or sliderProperties.maximum or sliderProperties.Maximum or 10
                    local sliderMin = sliderProperties.min or sliderProperties.Min or sliderProperties.minimum or sliderProperties.Minimum or 1
                    local sliderDigits = sliderProperties.digits or sliderProperties.Digits or sliderProperties.scale or sliderProperties.Scale or 1
                    local sliderTick = sliderProperties.tick or sliderProperties.Tick or sliderProperties.decimals or sliderProperties.Decimals or 1
                    local sliderPointer = sliderProperties.pointer or sliderProperties.Pointer or sliderProperties.flag or sliderProperties.Flag or nil
                    local sliderCallback = sliderProperties.callback or sliderProperties.Callback or sliderProperties.CallBack or sliderProperties.callBack or function() end
                    -- // Functions
                    -- // Main
                    local sliderText = utility:Create("Text", {
                        Visible = false,
                        Text = sliderName .. " -> " .. "<" .. tostring(sliderDefault) .. "/" .. tostring(sliderMax) .. ">",
                        Outline = true,
                        Font = 2,
                        Color = shared.theme.text,
                        Size = 13
                    })
                    -- // Nested Functions
                    function slider:Turn(state)
                        if state then
                            utility:Update(slider.text, "Color", "accent")
                        else
                            utility:Update(slider.text, "Color", "text")
                        end
                    end
                    --
                    function slider:Position(yAxis)
                        utility:Update(slider.text, "Position", UDim2.new(0, 22, 0, yAxis), windowFrame)
                    end
                    --
                    function slider:Open(state)
                        slider.text.Visible = state
                    end
                    --
                    function slider:Action(action)
                        slider.current = math.clamp(action == "Left" and (slider.current - slider.tick) or (slider.current + slider.tick), slider.min, slider.max)
                        slider.text.Text = sliderName .. " -> " .. "<" .. utility:Round(slider.current, slider.digits) .. "/" .. utility:Round(slider.max, slider.digits) .. ">"
                        --
                        sliderCallback(slider.current)
                    end
                    -- // Returning + Other
                    slider.name = sliderName
                    slider.text = sliderText
                    slider.current = sliderDefault
                    slider.max = sliderMax
                    slider.min = sliderMin
                    slider.digits = sliderDigits
                    slider.tick = sliderTick
                    --
                    section.content[#section.content + 1] = slider
                    --
                    if sliderPointer then
                        local pointer = {}
                        --
                        function pointer:Get()
                            return slider.current
                        end
                        --
                        function pointer:Set(value)
                            if typeof(value) == "number" then
                                slider.current = value
                                slider.text.Text = sliderName .. " -> " .. "<" .. utility:Round(slider.current, slider.digits) .. "/" .. utility:Round(slider.max, slider.digits) .. ">"
                                --
                                sliderCallback(slider.current)
                            end
                        end
                        --
                        shared.pointers[sliderPointer] = pointer
                    end
                    --
                    return slider
                end
                --
                function section:List(listProperties)
                    local list = {}
                    local listProperties = listProperties or {}
                    --
                    local listName = listProperties.name or listProperties.Name or "New Toggle"
                    local listEnter = listProperties.enter or listProperties.Enter or listProperties.comfirm or listProperties.Comfirm or false
                    local listDefault = listProperties.default or listProperties.Default or listProperties.def or listProperties.Def or 1
                    local listOptions = listProperties.options or listProperties.Options or {"Option 1", "Option 2", "Option 3"}
                    local listPointer = listProperties.pointer or listProperties.Pointer or listProperties.flag or listProperties.Flag or nil
                    local listCallback = listProperties.callback or listProperties.Callback or listProperties.CallBack or listProperties.callBack or function() end
                    -- // Functions
                    -- // Main
                    local listText = utility:Create("Text", {
                        Visible = false,
                        Text = listName .. " -> " .. "<" .. tostring(listOptions[listDefault]) .. ">",
                        Outline = true,
                        Font = 2,
                        Color = shared.theme.text,
                        Size = 13
                    })
                    -- // Nested Functions
                    function list:Turn(state)
                        if state then
                            utility:Update(list.text, "Color", "accent")
                        else
                            utility:Update(list.text, "Color", "text")
                        end
                    end
                    --
                    function list:Position(yAxis)
                        utility:Update(list.text, "Position", UDim2.new(0, 22, 0, yAxis), windowFrame)
                    end
                    --
                    function list:Open(state)
                        list.text.Visible = state
                    end
                    --
                    function list:Action(action)
                        if (listEnter and action == "Enter") then
                            listCallback(list.options[list.current])
                        else
                            list.current = ((list.options[action == "Left" and list.current - 1 or list.current + 1]) and (action == "Left" and list.current - 1 or list.current + 1)) or (action == "Left" and #list.options or 1)
                            --
                            list.text.Text = listName .. " -> " .. "<" .. tostring(list.options[list.current]) .. ">"
                            --
                            if not listEnter then
                                listCallback(list.options[list.current])
                            end
                        end
                    end
                    -- // Returning + Other
                    if listPointer then
                        local pointer = {}
                        --
                        function pointer:Get(cfg)
                            if cfg then
                                return list.current
                            else
                                return list.options[list.current]
                            end
                        end
                        --
                        function pointer:Set(value)
                            if typeof(value) == "number" and list.options[value] then
                                list.current = value
                                --
                                list.text.Text = listName .. " -> " .. "<" .. tostring(list.options[list.current]) .. ">"
                                --
                                if not listEnter then
                                    listCallback(list.options[list.current])
                                end
                            end
                        end
                        --
                        shared.pointers[listPointer] = pointer
                    end
                    --
                    list.name = listName
                    list.text = listText
                    list.current = listDefault
                    list.options = listOptions
                    --
                    section.content[#section.content + 1] = list
                    --
                    return list
                end
                --
                function section:MultiList(multiListProperties)
                    local multiList = {}
                    local multiListProperties = multiListProperties or {}
                    --
                    local multiListName = multiListProperties.name or multiListProperties.Name or "New Toggle"
                    local multiListDefault = multiListProperties.default or multiListProperties.Default or multiListProperties.def or multiListProperties.Def or 1
                    local multiListOptions = multiListProperties.options or multiListProperties.Options or {{"Option 1", false}, {"Option 2", false}, {"Option 3", false}}
                    local multiListPointer = multiListProperties.pointer or multiListProperties.Pointer or multiListProperties.flag or multiListProperties.Flag or nil
                    local multiListCallback = multiListProperties.callback or multiListProperties.Callback or multiListProperties.CallBack or multiListProperties.callBack or function() end
                    -- // Functions
                    -- // Main
                    local multiListText = utility:Create("Text", {
                        Visible = false,
                        Text = multiListName .. " -> " .. "<" .. (multiListOptions[multiListDefault] and (tostring(multiListOptions[multiListDefault][1]) .. ":" .. ((multiListOptions[multiListDefault][2]) and "ON" or "OFF")) or "Nil") .. ">",
                        Outline = true,
                        Font = 2,
                        Color = shared.theme.text,
                        Size = 13
                    })
                    -- // Nested Functions
                    function multiList:Turn(state)
                        if state then
                            utility:Update(multiList.text, "Color", "accent")
                        else
                            utility:Update(multiList.text, "Color", "text")
                        end
                    end
                    --
                    function multiList:Position(yAxis)
                        utility:Update(multiList.text, "Position", UDim2.new(0, 22, 0, yAxis), windowFrame)
                    end
                    --
                    function multiList:Open(state)
                        multiList.text.Visible = state
                    end
                    --
                    function multiList:Action(action)
                        if action == "Enter" then
                            multiList.options[multiList.current][2] = not multiList.options[multiList.current][2]
                            --
                            multiList.text.Text = multiList.name .. " -> " .. "<" .. tostring(multiList.options[multiList.current][1]) .. ":" .. (multiList.options[multiList.current][2] and "ON" or "OFF") .. ">"
                            --
                            multiListCallback(multiList.options)
                        else
                            multiList.current = ((multiList.options[action == "Left" and multiList.current - 1 or multiList.current + 1]) and (action == "Left" and multiList.current - 1 or multiList.current + 1)) or (action == "Left" and #multiList.options or 1)
                            --
                            multiList.text.Text = multiList.name .. " -> " .. "<" .. tostring(multiList.options[multiList.current][1]) .. ":" .. (multiList.options[multiList.current][2] and "ON" or "OFF") .. ">"
                            --
                            multiListCallback(multiList.options)
                        end
                    end
                    -- // Returning + Other
                    if multiListPointer then
                        local pointer = {}
                        --
                        function pointer:Get()
                            return list.options
                        end
                        --
                        function pointer:Set(value)
                            if typeof(value) == "table" and value[multiList.current] then
                                multiList.options = value
                                --
                                multiList.text.Text = multiList.name .. " -> " .. "<" .. tostring(multiList.options[multiList.current][1]) .. ":" .. (multiList.options[multiList.current][2] and "ON" or "OFF") .. ">"
                                --
                                multiListCallback(multiList.options)
                            end
                        end
                        --
                        shared.pointers[multiListPointer] = pointer
                    end
                    --
                    multiList.name = multiListName
                    multiList.text = multiListText
                    multiList.current = multiListDefault
                    multiList.options = multiListOptions
                    --
                    section.content[#section.content + 1] = multiList
                    --
                    return multiList
                end
                --
                function section:PlayerList(playerListProperties)
                    local playerList = {}
                    local playerListProperties = playerListProperties or {}
                    --
                    local playerListName = playerListProperties.name or playerListProperties.Name or "New Toggle"
                    local playerListEnter = playerListProperties.enter or playerListProperties.Enter or playerListProperties.comfirm or playerListProperties.Comfirm or false
                    local playerListCallback = playerListProperties.callback or playerListProperties.Callback or playerListProperties.CallBack or playerListProperties.callBack or function() end
                    local playerListOptions = {}
                    -- // Functions
                    for index, player in pairs(plrs:GetPlayers()) do
                        if player ~= plr then
                            playerListOptions[#playerListOptions + 1] = player
                        end
                    end
                    --
                    utility:Connection(plrs.PlayerAdded, function(player)
                        if player ~= plr then
                            if not table.find(playerList.options, player) then
                                playerList.options[#playerList.options + 1] = player
                            end
                            --
                            if #playerList.options == 1 then
                                playerList.current = 1
                                --
                                playerList.text.Text = playerList.name .. " -> " .. "<" .. tostring(playerList.options[playerList.current].Name) .. ">"
                                --
                                if not playerListEnter then
                                    playerListCallback(tostring(playerList.options[playerList.current]))
                                end
                            end
                        end
                    end)
                    --
                    utility:Connection(plrs.PlayerRemoving, function(player)
                        if player ~= plr then
                            local index = table.find(playerList.options, player)
                            local current = playerList.current
                            local current_plr = playerList.options[current]
                            --
                            if index then
                                table.remove(playerList.options, index)
                            end
                            --
                            if #playerList.options == 0 then
                                playerList.text.Text = playerList.name .. " -> " .. "<Nil>"
                            else
                                local oldCurrent = playerList.current
                                --
                                if index and playerList.options[playerList.current] ~= current_plr and table.find(playerList.options, current_plr) then
                                    playerList.current = table.find(playerList.options, current_plr)
                                end
                                --
                                playerList.text.Text = playerList.name .. " -> " .. "<" .. tostring(playerList.options[playerList.current].Name) .. ">"
                                --
                                if not playerListEnter then
                                    if oldCurrent ~= playerList.current then
                                        playerListCallback(tostring(playerList.options[playerList.current]))
                                    end
                                end
                            end
                        end
                    end)
                    -- // Main
                    local playerListText = utility:Create("Text", {
                        Visible = false,
                        Text = playerListName .. " -> " .. "<" .. (#playerListOptions >= 1 and tostring(playerListOptions[1].Name) or "Nil") .. ">",
                        Outline = true,
                        Font = 2,
                        Color = shared.theme.text,
                        Size = 13
                    })
                    -- // Nested Functions
                    function playerList:Turn(state)
                        if state then
                            utility:Update(playerList.text, "Color", "accent")
                        else
                            utility:Update(playerList.text, "Color", "text")
                        end
                    end
                    --
                    function playerList:Position(yAxis)
                        utility:Update(playerList.text, "Position", UDim2.new(0, 22, 0, yAxis), windowFrame)
                    end
                    --
                    function playerList:Open(state)
                        playerList.text.Visible = state
                    end
                    --
                    function playerList:Action(action)
                        if (playerListEnter and action == "Enter") then
                            if #playerList.options >= 1 then
                                playerListCallback(tostring(playerList.options[playerList.current]))
                            end
                        else
                            if #playerList.options >= 1 then
                                local oldCurrent = playerList.current
                                --
                                playerList.current = ((playerList.options[action == "Left" and playerList.current - 1 or playerList.current + 1]) and (action == "Left" and playerList.current - 1 or playerList.current + 1)) or (action == "Left" and #playerList.options or 1)
                                --
                                playerList.text.Text = playerList.name .. " -> " .. "<" .. tostring(playerList.options[playerList.current].Name) .. ">"
                                --
                                if not playerListEnter then
                                    if oldCurrent ~= playerList.current then
                                        playerListCallback(tostring(playerList.options[playerList.current]))
                                    end
                                end
                            end
                        end
                    end
                    -- // Returning + Other
                    playerList.name = playerListName
                    playerList.text = playerListText
                    playerList.current = 1
                    playerList.options = playerListOptions
                    --
                    section.content[#section.content + 1] = playerList
                    --
                    return playerList
                end
                --
                function section:Keybind(keybindProperties)
                    -- // Variables
                    local keybind = {}
                    local keybindProperties = keybindProperties or {}
                    --
                    local keybindName = keybindProperties.name or keybindProperties.Name or "New Keybind"
                    local keybindDefault = keybindProperties.default or keybindProperties.Default or keybindProperties.def or keybindProperties.Def or Enum.KeyCode.B
                    local keybindInputs = keybindProperties.inputs or keybindProperties.Inputs or true
                    local keybindPointer = keybindProperties.pointer or keybindProperties.Pointer or keybindProperties.flag or keybindProperties.Flag or nil
                    local keybindCallback = keybindProperties.callback or keybindProperties.Callback or keybindProperties.CallBack or keybindProperties.callBack or function() end
                    -- // Functions
                    function keybind:Shorten(string)
                        for i,v in pairs(shared.shortenedInputs) do
                            string = string.gsub(string, i, v)
                        end
                        --
                        return string
                    end
                    --
                    function keybind:Change(input)
                        input = input or "..."
                        local inputTable = {}
                        --
                        if input.EnumType then
                            if input.EnumType == Enum.KeyCode or input.EnumType == Enum.UserInputType then
                                if table.find(shared.allowedKeyCodes, input.Name) or table.find(shared.allowedInputTypes, input.Name) then
                                    inputTable = {input.EnumType == Enum.KeyCode and "KeyCode" or "UserInputType", input.Name}
                                    --
                                    keybind.current = inputTable
                                    keybind.text.Text = keybindName .. " -> " .. "<" .. (#keybind.current > 0 and keybind:Shorten(keybind.current[2]) or "...") .. ">"
                                    --
                                    return true
                                end
                            end
                        end
                        --
                        return false
                    end
                    -- // Main
                    local keybindText = utility:Create("Text", {
                        Visible = false,
                        Text = keybindName .. " -> " .. "<" .. "..." .. ">",
                        Outline = true,
                        Font = 2,
                        Color = shared.theme.text,
                        Size = 13
                    })
                    -- // Nested Functions
                    function keybind:Turn(state)
                        if state then
                            utility:Update(keybind.text, "Color", "accent")
                        else
                            utility:Update(keybind.text, "Color", "text")
                        end
                    end
                    --
                    function keybind:Position(yAxis)
                        utility:Update(keybind.text, "Position", UDim2.new(0, 22, 0, yAxis), windowFrame)
                    end
                    --
                    function keybind:Open(state)
                        keybind.text.Visible = state
                    end
                    --
                    function keybind:Action(action)
                        if not keybind.selecting then
                            keybind.text.Text = keybindName .. " -> " .. "<" .. "..." .. ">"
                            --
                            keybind.selecting = true
                            --
                            local connection
                            connection = utility:Connection(uis.InputBegan, function(Input)
                                if connection then
                                    local inputProcessed = keybind:Change(Input.KeyCode.Name ~= "Unknown" and Input.KeyCode or (keybind.inputs and Input.UserInputType))
                                    --
                                    if inputProcessed then
                                        wait()
                                        keybind.selecting = false
                                        --
                                        utility:RemoveConnection(connection)
                                        keybindCallback(Enum[keybind.current[1]][keybind.current[2]])
                                    end
                                end
                            end)
                        end
                    end
                    -- // Returning + Other
                    if keybindPointer then
                        local pointer = {}
                        --
                        function pointer:Get(cfg)
                            if cfg then
                                return keybind.current
                            else
                                return Enum[keybind.current[1]][keybind.current[2]]
                            end
                        end
                        --
                        function pointer:Set(value)
                            if typeof(value) == "table" and value[1] and value[2] then
                                local inputProcessed = keybind:Change(Enum[value[1]][value[2]])
                                --
                                if inputProcessed then
                                    keybindCallback(Enum[keybind.current[1]][keybind.current[2]])
                                end
                            end
                        end
                        --
                        shared.pointers[keybindPointer] = pointer
                    end
                    --
                    keybind.name = keybindName
                    keybind.text = keybindText
                    keybind.current = {}
                    keybind.inputs = keybindInputs
                    keybind.selecting = false
                    --
                    keybind:Change(keybindDefault)
                    --
                    section.content[#section.content + 1] = keybind
                    --
                    return keybind
                end
                --
                function section:ColorList(colorListProperties)
                    local colorList = {}
                    local colorListProperties = colorListProperties or {}
                    --
                    local colorListName = colorListProperties.name or colorListProperties.Name or "New Toggle"
                    local colorListDefault = colorListProperties.default or colorListProperties.Default or colorListProperties.def or colorListProperties.Def or 1
                    local colorListPointer = colorListProperties.pointer or colorListProperties.Pointer or colorListProperties.flag or colorListProperties.Flag or nil
                    local colorListCallback = colorListProperties.callback or colorListProperties.Callback or colorListProperties.CallBack or colorListProperties.callBack or function() end
                    -- // Functions
                    -- // Main
                    --
                    local colorListText = utility:Create("Text", {
                        Visible = false,
                        Text = colorListName .. " -> " .. "<   >",
                        Outline = true,
                        Font = 2,
                        Color = shared.theme.text,
                        Size = 13
                    })
                    --
                    local colorListColor = utility:Create("Square", {
                        Visible = false,
                        Filled = true,
                        Thickness = 0,
                        Color = shared.colors[colorListDefault],
                        Size = UDim2.new(0, 17, 0, 9),
                    })
                    -- // Nested Functions
                    function colorList:Turn(state)
                        if state then
                            utility:Update(colorList.text, "Color", "accent")
                        else
                            utility:Update(colorList.text, "Color", "text")
                        end
                    end
                    --
                    function colorList:Position(yAxis)
                        utility:Update(colorList.text, "Position", UDim2.new(0, 22, 0, yAxis), windowFrame)
                        utility:Update(colorList.color, "Position", UDim2.new(0, 22 + colorList.text.TextBounds.X - 26, 0, yAxis + 3), windowFrame)
                    end
                    --
                    function colorList:Open(state)
                        colorList.text.Visible = state
                        colorList.color.Visible = state
                    end
                    --
                    function colorList:Action(action)
                        colorList.current = ((colorList.options[action == "Left" and colorList.current - 1 or colorList.current + 1]) and (action == "Left" and colorList.current - 1 or colorList.current + 1)) or (action == "Left" and #colorList.options or 1)
                        --
                        colorList.text.Text = colorListName .. " -> " .. "<   >"
                        colorList.color.Color = colorList.options[colorList.current]
                        --
                        colorListCallback(colorList.options[colorList.current])
                    end
                    -- // Returning + Other
                    if colorListPointer then
                        local pointer = {}
                        --
                        function pointer:Get(cfg)
                            if cfg then
                                return colorList.current
                            else
                                return colorList.options[colorList.current]
                            end
                        end
                        --
                        function pointer:Set(value)
                            if typeof(value) == "number" then
                                colorList.current = value
                                --
                                colorList.text.Text = colorListName .. " -> " .. "<   >"
                                colorList.color.Color = colorList.options[colorList.current]
                                --
                                colorListCallback(colorList.options[colorList.current])
                            end
                        end
                        --
                        shared.pointers[colorListPointer] = pointer
                    end
                    --
                    colorList.name = colorListName
                    colorList.text = colorListText
                    colorList.color = colorListColor
                    colorList.current = colorListDefault
                    colorList.options = shared.colors
                    --
                    section.content[#section.content + 1] = colorList
                    --
                    return colorList
                end
                -- // Returning + Other
                section.name = sectionName
                section.text = sectionText
                --
                page.sections[#page.sections + 1] = section
                --
                return section
            end
            -- // Returning + Other
            page.name = pageName
            page.text = pageText
            --
            window.pages[#window.pages + 1] = page
            window:Refresh()
            --
            return page
        end
        -- // Returning
        return window
    end
end

-- UI
do
    local window = library:Window({name = "menu"})
    local page_thirdperson = window:Page({name = "third person"})
    local section_settings = page_thirdperson:Section({name = "third person settings"})
    
    do -- third person
        section_settings:Toggle({name = "enabled", default = false, pointer = "third_person"})
        section_settings:Slider({name = "third person x", default = 0, max = 10, min = -10, tick = 0.1, pointer = "third_person_x"})
        section_settings:Slider({name = "third person y", default = 0, max = 10, min = -10, tick = 0.1, pointer = "third_person_y"})
        section_settings:Slider({name = "third person z", default = 5, max = 10, min = -10, tick = 0.1, pointer = "third_person_z"})
    end
end

do -- Hooks
    game_client.network.send = function(self, command, ...)
        local arguments = {...}
    
        if command == "stance" then
            local third_person_object = fake_rep_object:getThirdPersonObject()
            if third_person_object then
                local stance = arguments[1]
                third_person_object:setStance(stance)
            end
        end
    
        if command == "aim" then
            local third_person_object = fake_rep_object:getThirdPersonObject()
            if third_person_object then
                local aim = arguments[1]
                third_person_object:setAim(aim)
            end
        end
    
        if command == "equip" then
            local third_person_object = fake_rep_object:getThirdPersonObject()
            if third_person_object then
                local weapon_index = arguments[1]
                if weapon_index < 3 then
                    third_person_object:equip(weapon_index)
                elseif weapon_index == 3 then
                    third_person_object:equipMelee(weapon_index)
                end
            end
        end
    
        if command == "sprint" then
            local third_person_object = fake_rep_object:getThirdPersonObject()
            if third_person_object then
                local sprinting = arguments[1]
                third_person_object:setSprint(sprinting)
            end
        end
    
        if command == "stab" then
            local third_person_object = fake_rep_object:getThirdPersonObject()
            if third_person_object then
                third_person_object:stab()
            end
        end
    
        if command == "spawn" then
            local third_person_object = fake_rep_object:getThirdPersonObject()
            if third_person_object then
                local character_model = third_person_object:popCharacterModel()
                character_model:Destroy()
                fake_rep_object:despawn()
            end

            local current_loadout = game_client.active_loadout.getActiveLoadoutData(game_client.player_data.getPlayerData())
            fake_rep_object:spawn(nil, current_loadout)
        end
    
        if command == "forcereset" then
            local third_person_object = fake_rep_object:getThirdPersonObject()
            if third_person_object then
                local character_model = third_person_object._character
                character_model:Destroy()
                fake_rep_object:despawn()
            end
        end

        if command == "newbullets" then
            local third_person_object = fake_rep_object:getThirdPersonObject()
            if third_person_object then
                third_person_object:kickWeapon()
            end
        end

        if command == "swapweapon" then
            local third_person_object = fake_rep_object:getThirdPersonObject()
            if third_person_object then
                local weapon_index = arguments[2]
                local weapon_dropped = arguments[1]

                if weapon_index < 3 then
                    fake_rep_object._activeWeaponRegistry[weapon_index] = {
                        weaponName = weapon_dropped.Gun.Value,
                        weaponData = game_client.content_database.getWeaponData(weapon_dropped.Gun.Value),
                    }
                else
                    fake_rep_object._activeWeaponRegistry[weapon_index] = {
                        weaponName = weapon_dropped.Knife.Value,
                        weaponData = game_client.content_database.getWeaponData(weapon_dropped.Knife.Value),
                    }
                end
            end
        end
    
        if command == "repupdate" then
            if shared.pointers["third_person"]:Get() and game_client.character_interface:isAlive() then
                local third_person_object = fake_rep_object:getThirdPersonObject()
                if not third_person_object then
                    local weapon_controller = game_client.weapon_controller_interface.getController()
                    fake_rep_object._activeWeaponRegistry[1] = {
                        weaponName = weapon_controller._activeWeaponRegistry[1]._weaponName, 
                        weaponData = weapon_controller._activeWeaponRegistry[1]._weaponData, 
                        attachmentData = weapon_controller._activeWeaponRegistry[1]._weaponAttachments, 
                        camoData = weapon_controller._activeWeaponRegistry[1]._camoList
                    }
    
                    fake_rep_object._activeWeaponRegistry[2] = {
                        weaponName = weapon_controller._activeWeaponRegistry[2]._weaponName, 
                        weaponData = weapon_controller._activeWeaponRegistry[2]._weaponData, 
                        attachmentData = weapon_controller._activeWeaponRegistry[2]._weaponAttachments, 
                        camoData = weapon_controller._activeWeaponRegistry[2]._camoList
                    }
    
                    fake_rep_object._activeWeaponRegistry[3] = {
                        weaponName = weapon_controller._activeWeaponRegistry[3]._weaponName, 
                        weaponData = weapon_controller._activeWeaponRegistry[3]._weaponData, 
                        camoData = weapon_controller._activeWeaponRegistry[3]._camoData
                    }
    
                    fake_rep_object._activeWeaponRegistry[4] = {
                        weaponName = weapon_controller._activeWeaponRegistry[4]._weaponName, 
                        weaponData = weapon_controller._activeWeaponRegistry[4]._weaponData
                    }
    
                    fake_rep_object._thirdPersonObject = game_client.third_person_object.new(fake_rep_object._player, nil, fake_rep_object)
                    fake_rep_object._thirdPersonObject:equip(weapon_controller._activeWeaponIndex, true)
                    fake_rep_object._alive = true
                end
                local clock_time = game_client.game_clock.getTime()
                local tick = tick()
                local velocity = Vector3.zero

                if fake_rep_object._receivedPosition and fake_rep_object._receivedFrameTime then
                    velocity = (arguments[1] - fake_rep_object._receivedPosition) / (tick - fake_rep_object._receivedFrameTime);
                end
                
                local broken = false
                if fake_rep_object._lastPacketTime and clock_time - fake_rep_object._lastPacketTime > 0.5 then
                    broken = true
                    fake_rep_object._breakcount = fake_rep_object._breakcount + 1
                end

                fake_rep_object._smoothReplication:receive(clock_time, tick, {
                    t = tick, 
                    position = arguments[1],
                    velocity = velocity, 
                    angles = arguments[2], 
                    breakcount = fake_rep_object._breakcount
                }, broken);

                fake_rep_object._updaterecieved = true
                fake_rep_object._receivedPosition = arguments[1]
                fake_rep_object._receivedFrameTime = tick
                fake_rep_object._lastPacketTime = clock_time
                fake_rep_object:step(3, true)
            else
                local third_person_object = fake_rep_object:getThirdPersonObject()
                if third_person_object then
                    local character_model = third_person_object:popCharacterModel()
                    character_model:Destroy()
                    fake_rep_object:despawn()
                end
            end
        end
    
        return old_send(self, command, table.unpack(arguments))
    end
    
    old_new_index = hookmetamethod(game, "__newindex", function(self, index, value)
        if checkcaller() then
            return old_new_index(self, index, value)
        end
    
        if game_client.character_interface:isAlive() and shared.pointers["third_person"]:Get() then
            if self == ws.CurrentCamera and index == "CFrame" then
                value *= CFrame.new(shared.pointers["third_person_x"]:Get(), shared.pointers["third_person_y"]:Get(), shared.pointers["third_person_z"]:Get())
            end
        end
    
        return old_new_index(self, index, value)
    end)
end

do -- Third Person 
    local player = Instance.new("Player") -- Create a new character to avoid the warn function
    fake_rep_object = game_client.replication_object.new(player)
    fake_rep_object._player = plr -- Set it to your localplayer
    player:Destroy()
    player = nil

    if game_client.character_interface:isAlive() and game_client.weapon_controller_interface.getController() then
        local weapon_controller = game_client.weapon_controller_interface.getController()

        fake_rep_object._activeWeaponRegistry[1] = {
            weaponName = weapon_controller._activeWeaponRegistry[1]._weaponName, 
            weaponData = weapon_controller._activeWeaponRegistry[1]._weaponData, 
            attachmentData = weapon_controller._activeWeaponRegistry[1]._weaponAttachments, 
            camoData = weapon_controller._activeWeaponRegistry[1]._camoList
        }

        fake_rep_object._activeWeaponRegistry[2] = {
            weaponName = weapon_controller._activeWeaponRegistry[2]._weaponName, 
            weaponData = weapon_controller._activeWeaponRegistry[2]._weaponData, 
            attachmentData = weapon_controller._activeWeaponRegistry[2]._weaponAttachments, 
            camoData = weapon_controller._activeWeaponRegistry[2]._camoList
        }

        fake_rep_object._activeWeaponRegistry[3] = {
            weaponName = weapon_controller._activeWeaponRegistry[3]._weaponName, 
            weaponData = weapon_controller._activeWeaponRegistry[3]._weaponData, 
            camoData = weapon_controller._activeWeaponRegistry[3]._camoData
        }

        fake_rep_object._activeWeaponRegistry[4] = {
            weaponName = weapon_controller._activeWeaponRegistry[4]._weaponName, 
            weaponData = weapon_controller._activeWeaponRegistry[4]._weaponData
        }

        fake_rep_object._thirdPersonObject = game_client.third_person_object.new(fake_rep_object._player, nil, fake_rep_object)
        fake_rep_object._thirdPersonObject:equip(1, true)
        fake_rep_object._alive = true
    end
end
