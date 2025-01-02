do
    makefolder("phantomhake")
    makefolder("phantomhake\\configs")
    for i = 1, 3 do
        if not isfile("phantomhake\\configs\\slot"..tostring(i)..".cfg") then
            writefile("phantomhake\\configs\\slot"..tostring(i)..".cfg", "")
        end
    end
end

rconsoleclear()
-- Services
local cas = game:GetService("ContextActionService")
local rps = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")
local cs = game:GetService("CollectionService")
local tps = game:GetService("TeleportService")
local sui = game:GetService("StarterGui")
local rs = game:GetService("RunService")
local lit = game:GetService("Lighting")
local sc = game:GetService("ScriptContext")
local ls = game:GetService("LogService")
local plrs = game:GetService("Players")
local ws = game:GetService("Workspace")

-- Local
local plr = plrs.LocalPlayer
local mouse = plr:GetMouse()

local ignore_folder = ws:WaitForChild("Ignore")
local aimbot_fov_circle

-- Global Tables
local library = {}
local utility = {}
local global = {
    drawing_containers = {
        menu = {},
        notification = {},
        esp = {},
    },
    connections = {},
    hidden_connections = {},
    pointers = {},
    theme = {
        inline = Color3.fromRGB(3, 3, 3),
        dark = Color3.fromRGB(24, 24, 24),
        text = Color3.fromRGB(155, 155, 155),
        section = Color3.fromRGB(60, 60, 60),
        accent = Color3.fromRGB(155, 39, 222)
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
    shortenedInputs = {
        -- Control Keys
        ["LeftControl"] = 'left control',
        ["RightControl"] = 'right control',
        ["LeftShift"] = 'left shift',
        ["RightShift"] = 'right shift',

        -- Numberbar
        ["Backquote"] = "grave",
        ["Tilde"] = "~",
        ["At"] = "@",
        ["Hash"] = "#",
        ["Dollar"] = "$",
        ["Percent"] = "%",
        ["Caret"] = "^",
        ["Ampersand"] = "&",
        ["Asterisk"] = "*",
        ["LeftParenthesis"] = "(",
        ["RightParenthesis"] = ")",

        ["Underscore"] = '_',
        ["Minus"] = '-',
        ["Plus"] = '+',
        ["Period"] = '.',
        ["Slash"] = '/',
        ["BackSlash"] = '\\',
        ["Question"] = '?',

        -- Super
        ["PageUp"] = "pgup",
        ["PageDown"] = "pgdwn",

        -- Keyboard
        ["Comma"] = ",",
        ["Period"] = ".",
        ["Semicolon"] = ",",
        ["Colon"] = ":",
        ["GreaterThan"] = ">",
        ["LessThan"] = "<",
        ["LeftBracket"] = "[",
        ["RightBracket"] = "]",
        ["LeftCurly"] = "{",
        ["RightCurly"] = "}",
        ["Pipe"] = "|",

        -- Numberpad
        ["NumLock"] = "num lock",
        ["KeypadNine"] = "num 9",
        ["KeypadEight"] = "num 8",
        ["KeypadSeven"] = "num 7",
        ["KeypadSix"] = "num 6",
        ["KeypadFive"] = "num 5",
        ["KeypadFour"] = "num 4",
        ["KeypadThree"] = "num 3",
        ["KeypadTwo"] = "num 2",
        ["KeypadOne"] = "num 1",
        ["KeypadZero"] = "num 0",
        
        ["KeypadMultiply"] = "num multiply",
        ["KeypadDivide"] = "num divide",
        ["KeypadPeriod"] = "num decimal",
        ["KeypadPlus"] = "num plus",
        ["KeypadMinus"] = "num sub",
        ["KeypadEnter"] = "num enter",
        ["KeypadEquals"] = "num equals",
        
        -- Mouse
        ["MouseButton1"] = 'mouse1',
        ["MouseButton2"] = 'mouse2',
        ["MouseButton3"] = 'mouse3',
    },   
    colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 100, 0), Color3.fromRGB(255, 200, 0), Color3.fromRGB(210, 255, 0), Color3.fromRGB(110, 255, 0), Color3.fromRGB(10, 255, 0), Color3.fromRGB(0, 255, 90), Color3.fromRGB(0, 255, 190), Color3.fromRGB(0, 220, 255), Color3.fromRGB(0, 120, 255), Color3.fromRGB(0, 20, 255), Color3.fromRGB(80, 0, 255), Color3.fromRGB(180, 0, 255), Color3.fromRGB(255, 0, 230), Color3.fromRGB(255, 0, 130), Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0)},
    toggleKey = {Enum.KeyCode.Home, true},
    unloadKey = {Enum.KeyCode.End, true},
    saveKey = {Enum.KeyCode.PageUp, true},
    loadKey = {Enum.KeyCode.PageDown, true},
    windowActive = true,
    notifications = {},
}
local cheat_client = {
    math_library = {},
    aimbot = {
        aimkey_translation = {
            ["mouse1"] = Enum.UserInputType.MouseButton1,
            ["mouse2"] = Enum.UserInputType.MouseButton2,
        },
        silent_vector = nil,
        current_target = nil,
    },
    window_active = true,
}

local game_client = {}
do -- Client Collector
    local garbage = getgc(true)
    local loaded_modules = getloadedmodules()

    for i = 1, #garbage do
        local v = garbage[i]
        if typeof(v) == "table" then
            if rawget(v, "send") and rawget(v, "fetch") then -- Networking Module
                game_client.network = v
            elseif rawget(v, 'goingLoud') and rawget(v, 'isInSight') then -- Useful for Radar Hack or Auto Spot
                game_client.spotting_interface = v
            elseif rawget(v, 'setMinimapStyle') and rawget(v, 'setRelHeight') then -- Useful for Radar Hack
                game_client.radar_interface = v
            elseif rawget(v, "getCharacterModel") and rawget(v, 'popCharacterModel') then -- Used for Displaying other Characters
                game_client.third_person_object = v
            elseif rawget(v, "getCharacterObject") then -- Used for sending LocalPlayer Character Data to Server
                game_client.character_interface = v
            elseif rawget(v, "isSprinting") and rawget(v, "getArmModels") then -- Used for sending LocalPlayer Character Data to Server
                game_client.character_object = v
            elseif rawget(v, "updateReplication") and rawget(v, "getThirdPersonObject") then -- This represents a "Player" separate from their character
                game_client.replication_object = v
            elseif rawget(v, "setHighMs") and rawget(v, "setLowMs") then -- Same as above
                game_client.replication_interface = v
            elseif rawget(v, 'setSway') and rawget(v, "_applyLookDelta") then -- You can modify camera values with this
                game_client.main_camera_object = v
            elseif rawget(v, 'getFirerate') and rawget(v, "getFiremode") then -- Weapon Stat Hooks
                game_client.firearm_object = v
            elseif rawget(v, 'canMelee') and rawget(v, "_processMeleeStateChange") then -- Melee Stat Hooks
                game_client.melee_object = v
            elseif rawget(v, 'canCancelThrow') and rawget(v, "canThrow") then -- Grenade Stat Hooks
                game_client.grenade_object = v
            elseif rawget(v, "vote") then -- Useful for Auto Vote
                game_client.votekick_interface = v
            elseif rawget(v, "getActiveWeapon") then -- Useful for Auto Vote
                game_client.weapon_controller_object = v
            elseif rawget(v, "getController") then -- Weapon Detection
                game_client.weapon_controller_interface = v
            elseif rawget(v, "updateVersion") and rawget(v, "inMenu") then -- Useful for chat spam :)
                game_client.chat_interface = v
            elseif rawget(v, "trajectory") and rawget(v, "timehit") then -- Useful for chat spam :)
                game_client.physics = v
            end
        end
    end

    for i = 1, #loaded_modules do
        local v = loaded_modules[i]
        if v.Name == "PlayerSettingsInterface" then
            game_client.player_settings = require(v)
        elseif v.Name == "PublicSettings" then
            game_client.public_settings = v
        end
    end
end

--[[
    All PF Network Commands (No Arguments)
        aim
        breakwindow
        bullethit
        capturedogtag
        captureflag
        changeAttachment
        changeClass
        changeModeVote
        changePlayerSetting
        changeTagColor
        changeWeapon
        chatted
        debug
        equip
        falldamage
        forcereset
        getammo
        knifehit
        logmessage
        modcmd
        newbullets
        newgrenade
        perfdump
        ping
        purchaseCaseAssign
        purchaseCaseCredit
        purchaseCaseKeyCredit
        purchaseCredits
        purchaseTag
        registerfunc
        reload
        repupdate
        requestMultiRoll
        requestRoll
        requestTradeRoll
        resetAttachments
        sellSkin
        spawn
        spotplayer
        sprint
        squadspawnupdate
        stab
        stance
        suppressionassist
        swapweapon
        teleportwithdata
        togglesquadspawn
        updatesight
        votefromUI
]]

local old_get_spring = game_client.character_object.getSpring -- Character

local old_network_send = game_client.network.send -- Network

local old_is_spotted = game_client.spotting_interface.isSpotted -- Radar

local old_set_sway = game_client.main_camera_object.setSway -- Camera
local old_shake = game_client.main_camera_object.shake

local old_gun_sway = game_client.firearm_object.gunSway -- Firearm
local old_gun_walk_sway = game_client.firearm_object.walkSway
local old_get_weapon_stat = game_client.firearm_object.getWeaponStat
local old_get_active_aim_stat = game_client.firearm_object.getActiveAimStat

local old_melee_sway = game_client.melee_object.meleeSway -- Melee
local old_melee_walk_sway = game_client.melee_object.walkSway
local old_get_melee_stat = game_client.firearm_object.getWeaponStat

local old_grenade_sway = game_client.grenade_object.modelSway -- Grenade
local old_grenade_walk_sway = game_client.grenade_object.walkSway

-- Encrypt Module
do
    local BitBuffer

    do -- Bit Buffer Module
        BitBuffer = {}

        local NumberToBase64
        local Base64ToNumber
        do
            NumberToBase64 = {}
            Base64ToNumber = {}
            local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
            for i = 1, #chars do
                local ch = chars:sub(i, i)
                NumberToBase64[i-1] = ch
                Base64ToNumber[ch] = i-1
            end
        end

        local PowerOfTwo;
        do
            PowerOfTwo = {}
            for i = 0, 64 do
                PowerOfTwo[i] = 2^i
            end
        end

        local BrickColorToNumber; local NumberToBrickColor; do
            BrickColorToNumber = {}
            NumberToBrickColor = {}
            for i = 0, 63 do
                local color = BrickColor.palette(i)
                BrickColorToNumber[color.Number] = i
                NumberToBrickColor[i] = color
            end
        end

        local floor,insert = math.floor, table.insert
        function ToBase(n, b)
            n = floor(n)
            if not b or b == 10 then return tostring(n) end
            local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            local t = {}
            local sign = ""
            if n < 0 then
                sign = "-"
                n = -n
            end
            repeat
                local d = (n % b) + 1
                n = floor(n / b)
                insert(t, 1, digits:sub(d, d))
            until n == 0
            return sign..table.concat(t, "")
        end

        function BitBuffer.Create()
            local this = {}

            -- Tracking
            local mBitPtr = 0
            local mBitBuffer = {}

            function this:ResetPtr()
                mBitPtr = 0
            end
            function this:Reset()
                mBitBuffer = {}
                mBitPtr = 0
            end

            -- Set debugging on
            local mDebug = false
            function this:SetDebug(state)
                mDebug = state
            end

            -- Read / Write to a string
            function this:FromString(str)
                this:Reset()
                for i = 1, #str do
                    local ch = str:sub(i, i):byte()
                    for i = 1, 8 do
                        mBitPtr = mBitPtr + 1
                        mBitBuffer[mBitPtr] = ch % 2
                        ch = math.floor(ch / 2)
                    end
                end
                mBitPtr = 0
            end
            function this:ToString()
                local str = ""
                local accum = 0
                local pow = 0
                for i = 1, math.ceil((#mBitBuffer) / 8)*8 do
                    accum = accum + PowerOfTwo[pow]*(mBitBuffer[i] or 0)
                    pow = pow + 1
                    if pow >= 8 then
                        str = str..string.char(accum)
                        accum = 0
                        pow = 0
                    end
                end
                return str
            end

            -- Read / Write to base64
            function this:FromBase64(str)
                this:Reset()
                for i = 1, #str do
                    local ch = Base64ToNumber[str:sub(i, i)]
                    assert(ch, "Bad character: 0x"..ToBase(str:sub(i, i):byte(), 16))
                    for i = 1, 6 do
                        mBitPtr = mBitPtr + 1
                        mBitBuffer[mBitPtr] = ch % 2
                        ch = math.floor(ch / 2)
                    end
                    assert(ch == 0, "Character value 0x"..ToBase(Base64ToNumber[str:sub(i, i)], 16).." too large")
                end
                this:ResetPtr()
            end
            function this:ToBase64()
                local strtab = {}
                local accum = 0
                local pow = 0
                for i = 1, math.ceil((#mBitBuffer) / 6)*6 do
                    accum = accum + PowerOfTwo[pow]*(mBitBuffer[i] or 0)
                    pow = pow + 1
                    if pow >= 6 then
                        table.insert(strtab, NumberToBase64[accum])
                        accum = 0
                        pow = 0
                    end
                end
                return table.concat(strtab)
            end	

            -- Dump
            function this:Dump()
                local str = ""
                local str2 = ""
                local accum = 0
                local pow = 0
                for i = 1, math.ceil((#mBitBuffer) / 8)*8 do
                    str2 = str2..(mBitBuffer[i] or 0)
                    accum = accum + PowerOfTwo[pow]*(mBitBuffer[i] or 0)
                    --print(pow..": +"..PowerOfTwo[pow].."*["..(mBitBuffer[i] or 0).."] -> "..accum)
                    pow = pow + 1
                    if pow >= 8 then
                        str2 = str2.." "
                        str = str.."0x"..ToBase(accum, 16).." "
                        accum = 0
                        pow = 0
                    end
                end
            end

            -- Read / Write a bit
            local function writeBit(v)
                mBitPtr = mBitPtr + 1
                mBitBuffer[mBitPtr] = v
            end
            local function readBit(v)
                mBitPtr = mBitPtr + 1
                return mBitBuffer[mBitPtr]
            end

            -- Read / Write an unsigned number
            function this:WriteUnsigned(w, value, printoff)
                assert(w, "Bad arguments to BitBuffer::WriteUnsigned (Missing BitWidth)")
                assert(value, "Bad arguments to BitBuffer::WriteUnsigned (Missing Value)")
                assert(value >= 0, "Negative value to BitBuffer::WriteUnsigned")
                assert(math.floor(value) == value, "Non-integer value to BitBuffer::WriteUnsigned")
                if mDebug and not printoff then
                    print("WriteUnsigned["..w.."]:", value)
                end
                -- Store LSB first
                for i = 1, w do
                    writeBit(value % 2)
                    value = math.floor(value / 2)
                end
                assert(value == 0, "Value "..tostring(value).." has width greater than "..w.."bits")
            end 
            function this:ReadUnsigned(w, printoff)
                local value = 0
                for i = 1, w do
                    value = value + readBit() * PowerOfTwo[i-1]
                end
                return value
            end

            -- Read / Write a signed number
            function this:WriteSigned(w, value)
                assert(w and value, "Bad arguments to BitBuffer::WriteSigned (Did you forget a bitWidth?)")
                assert(math.floor(value) == value, "Non-integer value to BitBuffer::WriteSigned")
                -- Write sign
                if value < 0 then
                    writeBit(1)
                    value = -value
                else
                    writeBit(0)
                end
                -- Write value
                this:WriteUnsigned(w-1, value, true)
            end
            function this:ReadSigned(w)
                -- Read sign
                local sign = (-1)^readBit()
                -- Read value
                local value = this:ReadUnsigned(w-1, true)
                if mDebug then
                    print("ReadSigned["..w.."]:", sign*value)
                end
                return sign*value
            end

            -- Read / Write a string. May contain embedded nulls (string.char(0))
            function this:WriteString(s)
                -- First check if it's a 7 or 8 bit width of string
                local bitWidth = 7
                for i = 1, #s do
                    if s:sub(i, i):byte() > 127 then
                        bitWidth = 8
                        break
                    end
                end

                -- Write the bit width flag
                if bitWidth == 7 then
                    this:WriteBool(false)
                else
                    this:WriteBool(true) -- wide chars
                end

                -- Now write out the string, terminated with "0x10, 0b0"
                -- 0x10 is encoded as "0x10, 0b1"
                for i = 1, #s do
                    local ch = s:sub(i, i):byte()
                    if ch == 0x10 then
                        this:WriteUnsigned(bitWidth, 0x10)
                        this:WriteBool(true)
                    else
                        this:WriteUnsigned(bitWidth, ch)
                    end
                end

                -- Write terminator
                this:WriteUnsigned(bitWidth, 0x10)
                this:WriteBool(false)
            end
            function this:ReadString()
                -- Get bit width
                local bitWidth;
                if this:ReadBool() then
                    bitWidth = 8
                else
                    bitWidth = 7
                end

                -- Loop
                local str = ""
                while true do
                    local ch = this:ReadUnsigned(bitWidth)
                    if ch == 0x10 then
                        local flag = this:ReadBool()
                        if flag then
                            str = str..string.char(0x10)
                        else
                            break
                        end
                    else
                        str = str..string.char(ch)
                    end
                end
                return str
            end

            -- Read / Write a bool
            function this:WriteBool(v)
                if v then
                    this:WriteUnsigned(1, 1, true)
                else
                    this:WriteUnsigned(1, 0, true)
                end
            end
            function this:ReadBool()
                local v = (this:ReadUnsigned(1, true) == 1)
                return v
            end

            -- Read / Write a floating point number with |wfrac| fraction part
            -- bits, |wexp| exponent part bits, and one sign bit.
            function this:WriteFloat(wfrac, wexp, f)
                assert(wfrac and wexp and f)

                -- Sign
                local sign = 1
                if f < 0 then
                    f = -f
                    sign = -1
                end

                -- Decompose
                local mantissa, exponent = math.frexp(f)
                if exponent == 0 and mantissa == 0 then
                    this:WriteUnsigned(wfrac + wexp + 1, 0)
                    return
                else
                    mantissa = ((mantissa - 0.5)/0.5 * PowerOfTwo[wfrac])
                end

                -- Write sign
                if sign == -1 then
                    this:WriteBool(true)
                else
                    this:WriteBool(false)
                end

                -- Write mantissa
                mantissa = math.floor(mantissa + 0.5) -- Not really correct, should round up/down based on the parity of |wexp|
                this:WriteUnsigned(wfrac, mantissa)

                -- Write exponent
                local maxExp = PowerOfTwo[wexp-1]-1
                if exponent > maxExp then
                    exponent = maxExp
                end
                if exponent < -maxExp then
                    exponent = -maxExp
                end
                this:WriteSigned(wexp, exponent)	
            end
            function this:ReadFloat(wfrac, wexp)
                assert(wfrac and wexp)

                -- Read sign
                local sign = 1
                if this:ReadBool() then
                    sign = -1
                end

                -- Read mantissa
                local mantissa = this:ReadUnsigned(wfrac)

                -- Read exponent
                local exponent = this:ReadSigned(wexp)
                if exponent == 0 and mantissa == 0 then
                    return 0
                end

                -- Convert mantissa
                mantissa = mantissa / PowerOfTwo[wfrac] * 0.5 + 0.5

                -- Output
                return sign * math.ldexp(mantissa, exponent)
            end

            -- Read / Write single precision floating point
            function this:WriteFloat32(f)
                this:WriteFloat(23, 8, f)
            end
            function this:ReadFloat32()
                return this:ReadFloat(23, 8)
            end

            -- Read / Write double precision floating point
            function this:WriteFloat64(f)
                this:WriteFloat(52, 11, f)
            end
            function this:ReadFloat64()
                return this:ReadFloat(52, 11)
            end

            -- Read / Write a BrickColor
            function this:WriteBrickColor(b)
                local pnum = BrickColorToNumber[b.Number]
                if not pnum then
                    warn("Attempt to serialize non-pallete BrickColor `"..tostring(b).."` (#"..b.Number.."), using Light Stone Grey instead.")
                    pnum = BrickColorToNumber[BrickColor.new(1032).Number]
                end
                this:WriteUnsigned(6, pnum)
            end
            function this:ReadBrickColor()
                return NumberToBrickColor[this:ReadUnsigned(6)]
            end

            -- Read / Write a rotation as a 64bit value.
            local function round(n)
                return math.floor(n + 0.5)
            end
            function this:WriteRotation(cf)
                local lookVector = cf.lookVector
                local azumith = math.atan2(-lookVector.X, -lookVector.Z)
                local ybase = (lookVector.X^2 + lookVector.Z^2)^0.5
                local elevation = math.atan2(lookVector.Y, ybase)
                local withoutRoll = CFrame.new(cf.p) * CFrame.Angles(0, azumith, 0) * CFrame.Angles(elevation, 0, 0)
                local x, y, z = (withoutRoll:inverse()*cf):toEulerAnglesXYZ()
                local roll = z
                -- Atan2 -> in the range [-pi, pi] 
                azumith   = round((azumith   /  math.pi   ) * (2^21-1))
                roll      = round((roll      /  math.pi   ) * (2^20-1))
                elevation = round((elevation / (math.pi/2)) * (2^20-1))
                --
                this:WriteSigned(22, azumith)
                this:WriteSigned(21, roll)
                this:WriteSigned(21, elevation)
            end
            function this:ReadRotation()
                local azumith   = this:ReadSigned(22)
                local roll      = this:ReadSigned(21)
                local elevation = this:ReadSigned(21)
                --
                azumith =    math.pi    * (azumith / (2^21-1))
                roll =       math.pi    * (roll    / (2^20-1))
                elevation = (math.pi/2) * (elevation / (2^20-1))
                --
                local rot = CFrame.Angles(0, azumith, 0)
                rot = rot * CFrame.Angles(elevation, 0, 0)
                rot = rot * CFrame.Angles(0, 0, roll)
                --
                return rot
            end

            return this
        end

    end

    local TypeIntegerLength = 3
    local IntegerLength = 10

    local function TypeToId(Type)
        if Type == "Integer" then
            return 1
        elseif Type == "NegInteger" then
            return 2
        elseif Type == "Number" then
            return 3
        elseif Type == "String" then
            return 4
        elseif Type == "Boolean" then
            return 5
        elseif Type == "Table" then
            return 6
        end
        return 0
    end

    local function IdToType(Type)
        if Type == 1 then
            return "Integer"
        elseif Type == 2 then
            return "NegInteger"
        elseif Type == 3 then
            return "Number"
        elseif Type == 4 then
            return "String"
        elseif Type == 5 then
            return "Boolean"
        elseif Type == 6 then
            return "Table"
        end
    end

    local function IsInt(Number)
        local Decimal = string.find(tostring(Number),"%.")
        if Decimal then
            return false
        else
            return true
        end
    end

    local function log(Base,Number)
        return math.log(Number)/math.log(Base)
    end

    local function GetMaxBitsInt(Table)
        local Max = 0
        for Key,Value in pairs(Table) do
            if type(Value) == "number" then
                Value = math.abs(Value)
                if IsInt(Value) and Value > 0 then
                    local Bits = math.ceil(log(2,Value + 1))
                    if Bits > Max then Max = Bits end
                end
            end
            
            if type(Key) == "number" then
                Key = math.abs(Key)
                if IsInt(Key) and Key > 0 then
                    local Bits = math.ceil(log(2,Key + 1))
                    if Bits > Max then Max = Bits end
                end
            end
        end
        return Max*2
    end

    local function GetTableLength(Table)
        local Total = 0
        for _,_ in pairs(Table) do
            Total = Total + 1
        end
        return Total
    end

    local function GetType(Key)
        local Type = type(Key) 
        if Type == "number" then
            if IsInt(Key) then
                if Key < 0 then
                    return "NegInteger"
                end
                return "Integer"
            else
                return "Number"
            end
        else
            return Type
        end
    end

    local function GetAllType(Table)
        local Type
        for Key,_ in pairs(Table) do
            if not Type then 
                Type = GetType(Key)
            end
            if type(Key) ~= Type then
                local NewType = GetType(Key)
                if NewType ~= Type then
                    return nil
                end
            end
        end	
        if Type == "Number" then
            return "Number"
        elseif Type == "Integer" then
            return "Integer"
        elseif Type == "NegInteger" then
            return "NegInteger"
        else
            return "String"
        end
    end

    local crypt = {}
    function crypt:encode(Table,UseBase64)
        local AllType = GetAllType(Table)
        local Buffer = BitBuffer.Create()
        if UseBase64 == true then
            Buffer:WriteBool(true)
        else
            Buffer:WriteBool(false)
        end
        Buffer:WriteUnsigned(IntegerLength,GetTableLength(Table))
        
        local function WriteFloat(Number)
            if UseBase64 == true then
                Buffer:WriteFloat64(Number)
            else
                Buffer:WriteFloat32(Number)
            end
        end
        Buffer:WriteUnsigned(TypeIntegerLength,TypeToId(AllType))
        local MaxBits = GetMaxBitsInt(Table)
        Buffer:WriteUnsigned(IntegerLength,MaxBits)
        
        local function WriteKey(Key,AllowAllSame)
            if not (AllowAllSame == true and AllType) then
                Buffer:WriteUnsigned(TypeIntegerLength,Key)
            elseif AllowAllSame == false then
                Buffer:WriteUnsigned(TypeIntegerLength,Key)
            end
        end
        
        for Key,Value in pairs(Table) do
            if type(Key) == "string" then
                WriteKey(TypeToId("String"),true)
                Buffer:WriteString(Key)
            elseif type(Key) == "number" and IsInt(Key) then
                if Key >= 0 then
                    WriteKey(TypeToId("Integer"),true)
                    Buffer:WriteUnsigned(MaxBits,Key)
                else
                    WriteKey(TypeToId("NegInteger"),true)
                    Buffer:WriteSigned(MaxBits*2,Key)
                end
            elseif type(Key) == "number" then
                WriteKey(TypeToId("Number"),true)
                WriteFloat(Key)
            end
            
            if type(Value) == "boolean" then
                WriteKey(TypeToId("Boolean"))
                Buffer:WriteBool(Value)
            elseif type(Value) == "number" then
                if IsInt(Value) then
                    if Value < 0 then
                        WriteKey(TypeToId("NegInteger"))
                        Buffer:WriteSigned(MaxBits*2,Value)
                    else
                        WriteKey(TypeToId("Integer"))
                        Buffer:WriteUnsigned(MaxBits,Value)
                    end
                else
                    WriteKey(TypeToId("Number"))
                    WriteFloat(Value)
                end
            elseif type(Value) == "table" then
                WriteKey(TypeToId("Table"))
                Buffer:WriteString(crypt:encode(Value,UseBase64))
            elseif type(Value) == "string" then
                WriteKey(TypeToId("String"))
                Buffer:WriteString(tostring(Value))
            end
        end
        return Buffer:ToBase64()
    end

    function crypt:decode(BinaryString)
        local Buffer = BitBuffer.Create()
        Buffer:FromBase64(BinaryString)
        local Table = {}
        local UseBase64 = Buffer:ReadBool()
        local function ReadFloat()
            if UseBase64 == true then
                return Buffer:ReadFloat64()
            else
                return Buffer:ReadFloat32()
            end
        end
        local Length = Buffer:ReadUnsigned(IntegerLength)
        local AllType = Buffer:ReadUnsigned(TypeIntegerLength)
        local MaxBits = Buffer:ReadUnsigned(IntegerLength)
        if AllType == 0 then AllType = nil end
        
        for i = 1, Length do
            local KeyType,Key = AllType or Buffer:ReadUnsigned(TypeIntegerLength)
            
            local KeyRealType = IdToType(KeyType)
            if KeyRealType == "Integer" then
                Key = Buffer:ReadUnsigned(MaxBits)
            elseif KeyRealType == "NegInteger" then
                Key = Buffer:ReadSigned(MaxBits*2)
            elseif KeyRealType == "Number" then
                Key = ReadFloat()
            elseif KeyRealType == "String" then
                Key = Buffer:ReadString()
            end
            
            local ValueType,Value = Buffer:ReadUnsigned(TypeIntegerLength)
            local ValueRealType = IdToType(ValueType)
            if ValueRealType == "String" then
                Value = Buffer:ReadString()
            elseif ValueRealType == "Boolean" then
                Value = Buffer:ReadBool()
            elseif ValueRealType == "Number" then
                Value = ReadFloat()
            elseif ValueRealType == "Integer" then
                Value = Buffer:ReadUnsigned(MaxBits)
            elseif ValueRealType == "NegInteger" then
                Value = Buffer:ReadSigned((MaxBits * 2))
            elseif ValueRealType == "Table" then
                Value = crypt:decode(Buffer:ReadString())
            elseif ValueRealType == "Color3" then
                Value = Color3.new(ReadFloat(),ReadFloat(),ReadFloat())
            elseif ValueRealType == "CFrame" then
                Value = CFrame.new(ReadFloat(),ReadFloat(),ReadFloat()) * Buffer:ReadRotation()
            elseif ValueRealType == "BrickColor" then
                Value = Buffer:ReadBrickColor()
            elseif ValueRealType == "UDim2" then
                Value = UDim2.new(ReadFloat(),ReadFloat(),ReadFloat(),ReadFloat())
            elseif ValueRealType == "UDim" then
                Value = UDim.new(ReadFloat(),ReadFloat())
            elseif ValueRealType == "Region3" then
                Value = Region3.new(Vector3.new(ReadFloat(),ReadFloat(),ReadFloat()),Vector3.new(ReadFloat(),ReadFloat(),ReadFloat()))
            elseif ValueRealType == "Region3int16" then
                Value = Region3int16.new(Vector3int16.new(ReadFloat(),ReadFloat(),ReadFloat()),Vector3int16.new(ReadFloat(),ReadFloat(),ReadFloat()))
            elseif ValueRealType == "Vector3" then
                Value = Vector3.new(ReadFloat(Value.X),ReadFloat(Value.Y),ReadFloat(Value.Z))
            elseif ValueRealType == "Vector2" then
                Value = Vector2.new(ReadFloat(Value.X),ReadFloat(Value.Y))
            elseif ValueRealType == "EnumItem" then
                Value = Enum[Buffer:ReadString()][Buffer:ReadString()]
            elseif ValueRealType == "Enums" then
                Value = Enum[Buffer:ReadString()]
            elseif ValueRealType == "Enum" then
                Value = Enum
            elseif ValueRealType == "Ray" then
                Value = Ray.new(Vector3.new(ReadFloat(),ReadFloat(),ReadFloat()),Vector3.new(ReadFloat(),ReadFloat(),ReadFloat()))
            elseif ValueRealType == "Axes" then
                local X,Y,Z = Buffer:ReadBool(),Buffer:ReadBool(),Buffer:ReadBool()
                Value = Axes.new(X == true and Enum.Axis.X,Y == true and Enum.Axis.Y,Z == true and Enum.Axis.Z)
            elseif ValueRealType == "Faces" then
                local Front,Back,Left,Right,Top,Bottom = Buffer:ReadBool(),Buffer:ReadBool(),Buffer:ReadBool(),Buffer:ReadBool(),Buffer:ReadBool(),Buffer:ReadBool()
                Value = Faces.new(Front == true and Enum.NormalId.Front,Back == true and Enum.NormalId.Back,Left == true and Enum.NormalId.Left,Right == true and Enum.NormalId.Right,Top == true and Enum.NormalId.Top,Bottom == true and Enum.NormalId.Bottom)
            elseif ValueRealType == "ColorSequence" then
                local Points = crypt:decode(Buffer:ReadString())
                Value = ColorSequence.new(Points[1].Value,Points[2].Value)
            elseif ValueRealType == "ColorSequenceKeypoint" then
                Value = ColorSequenceKeypoint.new(ReadFloat(),Color3.new(ReadFloat(),ReadFloat(),ReadFloat()))
            elseif ValueRealType == "NumberRange" then
                Value = NumberRange.new(ReadFloat(),ReadFloat())
            elseif ValueRealType == "NumberSequence" then
                Value = NumberSequence.new(crypt:decode(Buffer:ReadString()))
            elseif ValueRealType == "NumberSequenceKeypoint" then	
                Value = NumberSequenceKeypoint.new(ReadFloat(),ReadFloat(),ReadFloat())
            end
            Table[Key] = Value
        end
        return Table
    end

    global.crypt = crypt
end

-- Math Module
do
    cheat_client.physics_library = {
        physicsignore = {ws:FindFirstChild("Players"), ws.CurrentCamera, ws:FindFirstChild("Ignore")}
    }
    
    function cheat_client.physics_library.visible_check(origin, target)
        local direction = CFrame.new(origin, target)
        local distance = (origin - target).Magnitude
        
        local modified = {
            direction * CFrame.new(Vector3.new(0.3, 0.3, -0.3)),
            direction * CFrame.new(Vector3.new(-0.3, 0.3, -0.3)),
            direction * CFrame.new(Vector3.new(0.3, -0.3, -0.3)),
            direction * CFrame.new(Vector3.new(-0.3, -0.3, -0.3))
        }
    
        for _, v in next, modified do
            local o0 = v.Position
            local t0 = (v * CFrame.new(0, 0, -distance)).Position
    
            if ws:FindPartOnRayWithIgnoreList(Ray.new(o0, t0 - o0), cheat_client.physics_library.physicsignore) ~= nil then
                return false
            end
        end
    
        return true
    end
end

-- Utility Functions
do
    function utility:Create(instanceType, instanceProperties, container)
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
                        instance["Color"] = global.theme[value]
                        --
                        if value == "accent" then
                            global.accents[#global.accents + 1] = instance
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
        global.drawing_containers[container][#global.drawing_containers[container] + 1] = instance
        --
        return instance
    end

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
                instance.Color = global.theme[instanceValue]
                --
                if instanceValue == "accent" then
                    global.accents[#global.accents + 1] = instance
                else
                    if table.find(global.accents, instance) then
                        table.remove(global.accents, table.find(global.accents, instance))
                    end
                end
            else
                instance.Color = instanceValue
            end
        end
    end

    function utility:Connection(connectionType, connectionCallback)
        local connection = connectionType:Connect(connectionCallback)
        global.connections[#global.connections + 1] = connection
        --
        return connection
    end

    function utility:RemoveConnection(connection)
        for index, con in pairs(global.connections) do
            if con == connection then
                global.connections[index] = nil
                con:Disconnect()
            end
        end
        --
        for index, con in pairs(global.hidden_connections) do
            if con == connection then
                global.hidden_connections[index] = nil
                con:Disconnect()
            end
        end
    end

    function utility:Object(type, properties)
        local object = Instance.new(type)
        for i,v in next, properties do
            object[i] = v
        end
        return object
    end

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

    function utility:Unload()
        for i,v in pairs(global.connections) do
            v:Disconnect()
        end
        --
        for i,v in pairs(global.drawing_containers) do
            for _,k in pairs(v) do
                if rawget(k, "__OBJECT_EXISTS") then
                    k:Remove()
                end
            end
        end
        --
        table.clear(global.drawing_containers)
        global.drawing_containers = nil
        global.connections = nil
        --
        cas:UnbindAction("DisableInputKeys")
        sethiddenproperty(lit, "Technology", Enum.Technology.Compatibility)
        --
        table.clear(global)
        global = nil
        utility = nil
        library = nil
        do -- Unhook
           game_client.character_object.getSpring = old_get_spring -- Character
           game_client.network.send = old_network_send -- Network
           game_client.spotting_interface.isSpotted = old_is_spotted  -- Radar
           game_client.main_camera_object.setSway = old_set_sway -- Camera
           game_client.main_camera_object.shake = old_shake
           
           game_client.firearm_object.gunSway = old_gun_sway  -- Firearm
           game_client.firearm_object.walkSway = old_gun_walk_sway
           game_client.firearm_object.getWeaponStat = old_get_weapon_stat
           game_client.firearm_object.getActiveAimStat = old_get_active_aim_stat
           
           game_client.melee_object.meleeSway = old_melee_sway  -- Melee
           game_client.melee_object.walkSway = old_melee_walk_sway
           game_client.firearm_object.getWeaponStat = old_get_melee_stat
           
           game_client.grenade_object.modelSway = old_grenade_sway -- Grenade
           game_client.grenade_object.walkSway = old_grenade_walk_sway
        end
        --
        table.clear(cheat_client)
        cheat_client = nil
    end

    function utility:Toggle()
        global.toggleKey[2] = not global.toggleKey[2]
        --
        for index, drawing in pairs(global.drawing_containers["menu"]) do
            if getmetatable(drawing).__type == "Text" then
                utility:Lerp(drawing, {Transparency = global.toggleKey[2] and 1 or 0}, 0.15)
            else
                utility:Lerp(drawing, {Transparency = global.toggleKey[2] and 1 or 0}, 0.25)
            end
        end
    end

    function utility:ChangeAccent(accentColor)
        global.theme.accent = accentColor
        --
        for index, drawing in pairs(global.accents) do
            drawing.Color = global.theme.accent
        end
    end

    function utility:SaveConfig()
        local data = {}
        for key, pointer in next, global.pointers do
            if key == "config_slot" then -- Skip the slot
                continue
            end

            data[key] = pointer:Get()
        end

        local encrypted_data = nil

        local success = pcall(function()
            encrypted_data = global.crypt:encode(data)
        end)

        if success then
            local current_slot = global.pointers["config_slot"]:Get()
            writefile("phantomhake\\configs\\"..current_slot, encrypted_data)
            library:Notify("Successfully saved config to phantomhake\\configs\\"..current_slot, Color3.fromRGB(155, 39, 222))
        else
            library:Notify("Unsuccessfully attempted to save config phantomhake\\configs\\"..current_slot, Color3.fromRGB(155, 39, 222))
        end

    end

    function utility:LoadConfig()
        local current_slot = global.pointers["config_slot"]:Get()
        local encrypted_data = readfile("phantomhake\\configs\\"..current_slot, encrypted_data)
        if encrypted_data ~= "" then
            local data = nil

            local success = pcall(function()
                data = global.crypt:decode(encrypted_data)
            end)

            if success then
                for key, pointer in next, global.pointers do
                    if key == "config_slot" then -- Skip the slot
                        continue
                    end
                    pointer:Set(data[key])
                end

                library:Notify("Successfully loaded config phantomhake\\configs\\"..current_slot, Color3.fromRGB(155, 39, 222))
            else
                library:Notify("Unsuccessfully attempted to load config phantomhake\\configs\\"..current_slot, Color3.fromRGB(155, 39, 222))
            end
        end
    end

    function utility:IsHoveringFrame(frame)
        local mouse_location = uis:GetMouseLocation()

        local x1 = frame.AbsolutePosition.X
        local y1 = frame.AbsolutePosition.Y
        local x2 = x1 + frame.AbsoluteSize.X
        local y2 = y1 + frame.AbsoluteSize.Y

        return (mouse_location.X >= x1 and mouse_location.Y - 36 >= y1 and mouse_location.X <= x2 and mouse_location.Y - 36 <= y2)
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
            for i,v in pairs(global.moveKeys[keyType]) do
                if tostring(v) == tostring(moveDirection) then
                    global.moveKeys[keyType][i] = nil
                    global.moveKeys[keyType][newKey] = moveDirection
                end
            end
        end
        -- // Main
        local windowFrame = utility:Create("Square", {
            Visible = true,
            Filled = true,
            Thickness = 0,
            Color = global.theme.inline,
            Size = UDim2.new(0, 280, 0, 19),
            Position = UDim2.new(0, 50, 0, 80)
        }, "menu")
        --
        local windowInline = utility:Create("Square", {
            Parent = windowFrame,
            Visible = true,
            Filled = true,
            Thickness = 0,
            Color = global.theme.dark,
            Size = UDim2.new(1, -2, 1, -4),
            Position = UDim2.new(0, 1, 0, 3)
        }, "menu")
        --
        local windowAccent = utility:Create("Square", {
            Parent = windowFrame,
            Visible = true,
            Filled = true,
            Thickness = 0,
            Color = "accent",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 0, 0)
        }, "menu")
        --
        local windowText = utility:Create("Text", {
            Parent = windowAccent,
            Visible = true,
            Text = windowName,
            Center = true,
            Outline = true,
            Font = 2,
            Color = global.theme.text,
            Size = 13,
            Position = UDim2.new(0.5, 0, 0, 3)
        }, "menu")
        -- // Connections
        utility:Connection(uis.InputBegan, function(Input)
            if global.toggleKey[2] and Input.KeyCode then
                if global.moveKeys["Movement"][Input.KeyCode.Name] then
                    window:Movement("Movement", global.moveKeys["Movement"][Input.KeyCode.Name])
                elseif global.moveKeys["Action"][Input.KeyCode.Name] then
                    window:Movement("Action", global.moveKeys["Action"][Input.KeyCode.Name])
                end
            end
            
            if Input.KeyCode == global.toggleKey[1] then
                utility:Toggle()
            elseif Input.KeyCode == global.unloadKey[1] then
                utility:Unload()
            elseif Input.KeyCode == global.saveKey[1] then
                utility:SaveConfig()
                return
            elseif Input.KeyCode == global.loadKey[1] then
                utility:LoadConfig()
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
                Color = (#window.content == 0 and global.theme.accent or global.theme.text),
                Size = 13,
                Position = UDim2.new(0, 5, 0, 19 + ((#window.content) * 17))
            }, "menu")
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
                    Color = global.theme.section,
                    Size = 13
                }, "menu")
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
                    local labelPointer = labelProperties.pointer or labelProperties.Pointer or labelProperties.flag or labelProperties.Flag or nil
                    -- // Functions
                    -- // Main
                    local labelText = utility:Create("Text", {
                        Visible = false,
                        Text = labelName,
                        Outline = true,
                        Font = 2,
                        Color = global.theme.text,
                        Size = 13
                    }, "menu")
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
                    if labelPointer then
                        local pointer = {}
                        --
                        function pointer:Get()
                            return label.name
                        end
                        --
                        function pointer:Set(value)
                            if typeof(value) == "string" then
                                label.name = value
                                label.text.Text = value
                            end
                        end
                        --
                        global.pointers[labelPointer] = pointer
                    end
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
                        Color = global.theme.text,
                        Size = 13
                    }, "menu")
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
                        Color = global.theme.text,
                        Size = 13
                    }, "menu")
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
                            toggle.current = value
                            toggle.text.Text = toggle.name .. " -> " .. (toggle.current and "ON" or "OFF")
                            --
                            toggleCallback(toggle.current)
                        end
                        --
                        global.pointers[togglePointer] = pointer
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
                        Color = global.theme.text,
                        Size = 13
                    }, "menu")
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
                        slider.text.Text = sliderName .. " -> " .. "<" .. tostring(slider.current) .. "/" .. tostring(slider.max) .. ">"
                        --
                        sliderCallback(slider.current)
                    end
                    -- // Returning + Other
                    slider.name = sliderName
                    slider.text = sliderText
                    slider.current = sliderDefault
                    slider.max = sliderMax
                    slider.min = sliderMin
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
                            slider.current = value
                            slider.text.Text = sliderName .. " -> " .. "<" .. tostring(slider.current) .. "/" .. tostring(slider.max) .. ">"
                            --
                            sliderCallback(slider.current)
                        end
                        --
                        global.pointers[sliderPointer] = pointer
                    end
                    --
                    return slider
                end
                --
                function section:List(listProperties)
                    local list = {}
                    local listProperties = listProperties or {}
                    --
                    local listName = listProperties.name or listProperties.Name or "New List"
                    local listEnter = listProperties.enter or listProperties.Enter or listProperties.comfirm or listProperties.Comfirm or false
                    local listDefault = listProperties.default or listProperties.Default or listProperties.def or listProperties.Def or 1
                    local listOptions = listProperties.options or listProperties.Options or {"Option 1", "Option 2", "Option 3"}
                    local listPointer = listProperties.pointer or listProperties.Pointer or listProperties.flag or listProperties.Flag or nil
                    local listCallback = listProperties.callback or listProperties.Callback or listProperties.CallBack or listProperties.callBack or function() end
                    -- // Functions
                    -- // Main
                    local listText = utility:Create("Text", {
                        Visible = false,
                        Text = listName .. " -> " .. tostring(listOptions[listDefault]),
                        Outline = true,
                        Font = 2,
                        Color = global.theme.text,
                        Size = 13
                    }, "menu")
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
                            list.text.Text = listName .. " -> " .. tostring(list.options[list.current])
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
                        function pointer:Get()
                            return list.options[list.current]
                        end
                        --
                        function pointer:Set(value)
                            list.current = table.find(list.options, value)
                            --
                            list.text.Text = listName .. " -> " .. tostring(list.options[list.current])
                            --
                            if not listEnter then
                                listCallback(list.options[list.current])
                            end
                        end
                        --
                        global.pointers[listPointer] = pointer
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
                    local multiListName = multiListProperties.name or multiListProperties.Name or "New Multilist"
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
                        Color = global.theme.text,
                        Size = 13
                    }, "menu")
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
                            return multiList.options
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
                        global.pointers[multiListPointer] = pointer
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
                        Color = global.theme.text,
                        Size = 13
                    }, "menu")
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
                        for i,v in pairs(global.shortenedInputs) do
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
                                if table.find(global.allowedKeyCodes, input.Name) or table.find(global.allowedInputTypes, input.Name) then
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
                        Color = global.theme.text,
                        Size = 13
                    }, "menu")
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
                            if value[1] and value[2] then
                                local inputProcessed = keybind:Change(Enum[value[1]][value[2]])
                                --
                                if inputProcessed then
                                    keybindCallback(Enum[keybind.current[1]][keybind.current[2]])
                                end
                            end
                        end
                        --
                        global.pointers[keybindPointer] = pointer
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
                        Color = global.theme.text,
                        Size = 13
                    }, "menu")
                    --
                    local colorListColor = utility:Create("Square", {
                        Visible = false,
                        Filled = true,
                        Thickness = 0,
                        Color = global.colors[colorListDefault],
                        Size = UDim2.new(0, 17, 0, 9),
                    }, "menu")
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
                            colorList.current = value
                            --
                            colorList.text.Text = colorListName .. " -> " .. "<   >"
                            colorList.color.Color = colorList.options[colorList.current]
                            --
                            colorListCallback(colorList.options[colorList.current])
                        end
                        --
                        global.pointers[colorListPointer] = pointer
                    end
                    --
                    colorList.name = colorListName
                    colorList.text = colorListText
                    colorList.color = colorListColor
                    colorList.current = colorListDefault
                    colorList.options = global.colors
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

    function library:Notify(text, color) 
        local notification = {
            text = text,
            drawings = {},
            color = color,
            start_tick = tick(),
            lifetime = 5,
        }
    
        do -- Create Drawings
            notification.drawings.shadow_text = utility:Create("Text", {
                Center = false,
                Outline = false,
                Color = Color3.new(),
                Transparency = 200/255,
                Text = text,
                Size = 13,
                Font = 2,
                ZIndex = 99,
                Visible = false
            }, "notification")
        
            notification.drawings.main_text = utility:Create("Text", {
                Center = false,
                Outline = false,
                Color = notification.color,
                Transparency = 1,
                Text = text,
                Size = 13,
                Font = 2,
                ZIndex = 100,
                Visible = false
            }, "notification")
        end
    
        function notification:destruct()
            local shadow_text_origin = self.drawings.shadow_text.Position
            local main_text_origin = self.drawings.main_text.Position
            local shadow_text_transparency = self.drawings.shadow_text.Transparency
            local main_text_transparency = self.drawings.main_text.Transparency
    
            for i = 0, 1, 1/60 do
                self.drawings.shadow_text.Position = shadow_text_origin:Lerp(Vector2.new(), i)
                self.drawings.main_text.Position = main_text_origin:Lerp(Vector2.new(), i)
                self.drawings.shadow_text.Transparency = shadow_text_transparency * (1 - i)
                self.drawings.main_text.Transparency = main_text_transparency * (1 - i)
                rs.RenderStepped:Wait()
            end

            for _,v in next, notification.drawings do
                table.remove(global.drawing_containers.notification, table.find(global.drawing_containers.notification, v))
                v:Remove()
            end

            self.drawings.main_text = nil
            self.drawings.shadow_text = nil
            table.clear(self)
            self = nil
        end
    
        global.notifications[#global.notifications + 1] = notification
        return notification
    end
end

-- Cheat Functions
do
    do -- ESP
        do -- Player
            function cheat_client:calculate_player_bounding_box(character)
                local cam = ws.CurrentCamera.CFrame
                local torso = character.PrimaryPart.CFrame
                local head = character.Head.CFrame
                local top, top_isrendered = ws.CurrentCamera:WorldToViewportPoint(head.Position + (torso.UpVector * 1) + cam.UpVector)
                local bottom, bottom_isrendered = ws.CurrentCamera:WorldToViewportPoint(torso.Position - (torso.UpVector * 2.5) - cam.UpVector)
        
                local minY = math.abs(bottom.y - top.y)
                local sizeX = math.ceil(math.max(math.clamp(math.abs(bottom.x - top.x) * 2.5, 0, minY), minY / 2, 3))
                local sizeY = math.ceil(math.max(minY, sizeX * 0.5, 3))
        
                if top_isrendered or bottom_isrendered then
                    local boxtop = Vector2.new(math.floor(top.x * 0.5 + bottom.x * 0.5 - sizeX * 0.5), math.floor(math.min(top.y, bottom.y)) + 10)
                    local boxsize = Vector2.new(sizeX, sizeY)
                    return boxtop, boxsize 
                end
            end
        
            function cheat_client:get_character(player)
                local entry = game_client.replication_interface.getEntry(player)
        
                if entry then
                    local third_person_object = entry._thirdPersonObject
                    if third_person_object then
                        return third_person_object._characterHash.head.Parent
                    end
                end
            end
        
            function cheat_client:get_health(player)
                local entry = game_client.replication_interface.getEntry(player)

                if entry then
                    return entry:getHealth()
                end
            end
        
            function cheat_client:get_alive(player)
                local entry = game_client.replication_interface.getEntry(player)
        
                if entry then
                    return entry._alive
                end
            end
        
            function cheat_client:get_weapon(player)
                local entry = game_client.replication_interface.getEntry(player)
        
                if entry then
                    local third_person_object = entry._thirdPersonObject
                    if third_person_object then
                        return third_person_object._weaponname or ""
                    end
                end
            end
        
            function cheat_client:add_player_esp(player)
                local esp = {
                    drawings = {},
                    low_health = Color3.fromRGB(255,0,0),
                }
        
                do -- Create Drawings
                    esp.drawings.name = utility:Create("Text", {
                        Text = player.Name,
                        Font = 2,
                        Size = 13,
                        Center = true,
                        Outline = true,
                        Color = Color3.fromRGB(255,255,255),
                        ZIndex = -10
                    }, "esp")
        
                    esp.drawings.weapon = utility:Create("Text", {
                        Text = "",
                        Font = 2,
                        Size = 13,
                        Center = true,
                        Outline = true,
                        Color = Color3.fromRGB(255,255,255),
                        ZIndex = -10
                    }, "esp")
        
                    esp.drawings.box = utility:Create("Square", {
                        Color = Color3.fromRGB(255,10,10),
                        Thickness = 1,
                        ZIndex = -9
                    }, "esp")
        
                    esp.drawings.box_outline = utility:Create("Square", {   
                        Thickness = 3,
                        Color = Color3.fromRGB(0,0,0),
                        ZIndex = -10,
                    }, "esp")
        
                    esp.drawings.health = utility:Create("Line", {
                        Thickness = 2,           
                        Color = Color3.fromRGB(0, 255, 0),
                        ZIndex = -9
                    }, "esp")
        
                    esp.drawings.health_outline = utility:Create("Line", {
                        Thickness = 5,           
                        Color = Color3.fromRGB(0, 0, 0),
                        ZIndex = -10
                    }, "esp")
        
                    esp.drawings.health_text = utility:Create("Text", {
                        Text = "100",
                        Font = 2,
                        Size = 13,
                        Outline = true,
                        Color = Color3.fromRGB(255, 255, 255),
                        ZIndex = -10
                    }, "esp")
                end
        
                function esp:destruct()
                    esp.update_connection:Disconnect() -- Disconnect before deleting drawings so that the drawings don't cause an index error
                    for _,v in next, esp.drawings do
                        v:Remove()
                    end
                end
        
                esp.update_connection = utility:Connection(rs.RenderStepped, function()
                    if player.Parent ~= nil then
                        if global.pointers["player_esp"]:Get() then
                            local character = cheat_client:get_character(player)
                            local alive = cheat_client:get_alive(player)
                            local health, max_health = cheat_client:get_health(player)
                            local team = player.Team
                            if character and alive and (team ~= plr.Team and not global.pointers["player_show_team"]:Get() or global.pointers["player_show_team"]:Get()) then
                                local distance = (ws.CurrentCamera.CFrame.Position - character:FindFirstChild("Torso").CFrame.Position).Magnitude
                                if distance < global.pointers["player_range"]:Get() then
                                    local _, on_screen = ws.CurrentCamera:WorldToViewportPoint(character.Torso.Position)
                                    if on_screen then
                                        local screen_position, screen_size = cheat_client:calculate_player_bounding_box(character)
                                        if screen_size then
                                            do -- Box
                                                if global.pointers["player_box"]:Get() then
                                                    esp.drawings.box.Position = screen_position
                                                    esp.drawings.box.Size = screen_size
                                                    
                                                    esp.drawings.box_outline.Position = esp.drawings.box.Position
                                                    esp.drawings.box_outline.Size = esp.drawings.box.Size
                    
                                                    esp.drawings.box.Color = (cheat_client.aimbot.current_target == player and Color3.fromRGB(255, 255, 0)) or player.Team == plr.Team and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 0, 0)
                                                    
                                                    esp.drawings.box.Visible = true
                                                    esp.drawings.box_outline.Visible = true
                                                else
                                                    esp.drawings.box.Position = screen_position
                                                    esp.drawings.box.Size = screen_size
                                                    
                                                    esp.drawings.box_outline.Position = esp.drawings.box.Position
                                                    esp.drawings.box_outline.Size = esp.drawings.box.Size
                                                    
                                                    esp.drawings.box.Visible = false
                                                    esp.drawings.box_outline.Visible = false
                                                end
                                            end
                
                                            do -- Name
                                                if global.pointers["player_name"]:Get() then
                                                    esp.drawings.name.Text = "("..tostring(math.floor(distance)).."m) "..player.Name
                                                    esp.drawings.name.Position = esp.drawings.box.Position + Vector2.new(screen_size.X/2, -esp.drawings.name.TextBounds.Y)

                                                    esp.drawings.name.Visible = true
                                                else
                                                    esp.drawings.name.Visible = false
                                                end
                                            end
                
                                            do -- Health
                                                if global.pointers["player_health"]:Get() then
                                                    esp.drawings.health.From = Vector2.new(screen_position.X - 5, screen_position.Y + screen_size.Y)
                                                    esp.drawings.health.To = Vector2.new(esp.drawings.health.From.X, esp.drawings.health.From.Y - (health / max_health) * screen_size.Y)
                                                    esp.drawings.health.Color = esp.low_health:Lerp(Color3.fromRGB(0,255,0), health / max_health)

                                                    esp.drawings.health_outline.From = esp.drawings.health.From + Vector2.new(0, 1)
                                                    esp.drawings.health_outline.To = Vector2.new(esp.drawings.health_outline.From.X, screen_position.Y - 1)
                                    
                                                    esp.drawings.health_text.Text = tostring(math.floor(health))
                                                    esp.drawings.health_text.Position = esp.drawings.health.To - Vector2.new((esp.drawings.health_text.TextBounds.X + 4), 0)

                                                    esp.drawings.health.Visible = true
                                                    esp.drawings.health_outline.Visible = true
                                                    esp.drawings.health_text.Visible = true
                                                    esp.drawings.health_text.Visible = true
                                                else
                                                    esp.drawings.health.Visible = false
                                                    esp.drawings.health_outline.Visible = false
                                                    esp.drawings.health_text.Visible = false
                                                end
                                            end
                
                                            do -- intent
                                                if global.pointers["player_weapon"]:Get() then
                                                    local weapon = cheat_client:get_weapon(player)
                                                    if weapon and distance < 500 then
                                                        esp.drawings.weapon.Text = weapon
                                                        esp.drawings.weapon.Position = esp.drawings.box.Position + Vector2.new(0,esp.drawings.box.Size.Y) + Vector2.new(screen_size.X/2,0)
                                                    
                                                        esp.drawings.weapon.Visible = true
                                                    else
                                                        esp.drawings.weapon.Visible = false
                                                    end
                                                else
                                                    esp.drawings.weapon.Visible = false
                                                end
                                            end
                                        else
                                            for _,v in next, esp.drawings do
                                                v.Visible = false
                                            end
                                        end
                                    else
                                        for _,v in next, esp.drawings do
                                            v.Visible = false
                                        end
                                    end
                                else
                                    for _,v in next, esp.drawings do
                                        v.Visible = false
                                    end
                                end
                            else
                                for _,v in next, esp.drawings do
                                    v.Visible = false
                                end
                            end
                        else
                            for _,v in next, esp.drawings do
                                v.Visible = false
                            end
                        end
                    else
                        esp:destruct()
                    end
                end)
        
                return esp
            end
        end

        do -- Dropped
            function cheat_client:add_dropped_esp(dropped)
                local esp = {
                    object = dropped:WaitForChild("Slot1", 9e9),
                    name = dropped:WaitForChild("Gun", 9e9).Value,
                    color = Color3.fromRGB(149, 121, 192),
                    drawings = {},
                }

                do -- Create Drawings
                    esp.drawings.main_text = utility:Create("Text", {
                        Center = true,
                        Outline = true,
                        Color = esp.color,
                        Transparency = 1,
                        Text = esp.name,
                        Size = 13,
                        Font = 2,
                        ZIndex = -10,
                        Visible = false
                    }, "esp")
                end

                function esp:destruct()
                    esp.update_connection:Disconnect() -- Disconnect before deleting drawings so that the drawings don't cause an index error
                    for _,v in next, esp.drawings do
                        table.remove(global.drawing_containers.esp, table.find(global.drawing_containers.esp, v))
                        v:Remove()
                    end
                end

                esp.update_connection = utility:Connection(rs.RenderStepped, function()
                    if esp.object.Parent ~= nil then
                        if global.pointers["dropped_esp"]:Get() then
                            local distance = (ws.CurrentCamera.CFrame.Position - esp.object.CFrame.Position).Magnitude
                            if distance < global.pointers["dropped_range"]:Get() then
                                local screen_position, on_screen = ws.CurrentCamera:WorldToViewportPoint(esp.object.CFrame.Position)
                                if on_screen then
                                    esp.drawings.main_text.Text = esp.name
                                    
                                    if global.pointers["dropped_ammo"]:Get() then
                                        esp.drawings.main_text.Text ..= "\n("..tostring(dropped.Spare.Value)..")"
                                    end

                                    esp.drawings.main_text.Position = Vector2.new(screen_position.X, screen_position.Y)
                                    
                                    local transparency = math.clamp(1 - distance/global.pointers["dropped_range"]:Get(), 0, 1)
                                    
                                    if transparency >= .9 then
                                        transparency = 1
                                    end

                                    for _,v in next, esp.drawings do
                                        v.Transparency = transparency
                                    end

                                    esp.drawings.main_text.Visible = true
                                else
                                    esp.drawings.main_text.Visible = false
                                end
                            else
                                esp.drawings.main_text.Visible = false
                            end
                        else
                            esp.drawings.main_text.Visible = false
                        end
                    else
                        esp:destruct()
                    end
                end)
                return esp
            end
        end

    end

    do -- Aimbot
        function cheat_client:calculate_aimbot_target(hitparts)
            local max_distance = aimbot_fov_circle.Radius
            local target = cheat_client.aimbot.current_target
            local target_part = nil
            local hitparts = hitparts or {}

            local visible = global.pointers["aimbot_visible"]:Get()
            
            
            if target then
                if target.Parent ~= nil and target.Team ~= plr.Team then
                    local character = cheat_client:get_character(target)
                    local health = cheat_client:get_health(target)
                    local alive = cheat_client:get_alive(target)
                    
                    if character and alive and (health > 0) then
                        local selected_body_part = nil

                        for _,body_part in next, character:GetChildren() do
                            if body_part.ClassName == "Part" and hitparts[body_part.Name] then
                                local screen_position, on_screen = ws.CurrentCamera:WorldToViewportPoint(body_part.Position)
                                local magnitude = (Vector2.new(uis:GetMouseLocation().X, uis:GetMouseLocation().Y) - Vector2.new(screen_position.X, screen_position.Y)).Magnitude
                                if magnitude < max_distance then
                                    if (visible and cheat_client.physics_library.visible_check(ws.CurrentCamera.CFrame.Position, body_part.Position)) or not visible then
                                        selected_body_part = body_part
                                        max_distance = magnitude
                                    end
                                end
                            end
                        end

                        if selected_body_part then
                            return target, selected_body_part
                        end
                    end
                end

                return target
            end

            for _, v in next, plrs:GetPlayers() do
                if v == plr then
                    continue
                end

                if v.Team == plr.Team then
                    continue
                end
    
                local character = cheat_client:get_character(v)
                local health = cheat_client:get_health(v)
                local alive = cheat_client:get_alive(v)
                
    
                if not character then
                    continue
                end
    
                if not alive then
                    continue
                end
    
                if health <= 0 then
                    continue
                end

                for _,body_part in next, character:GetChildren() do
                    if body_part.ClassName == "Part" and hitparts[body_part.Name] then
                        local screen_position, on_screen = ws.CurrentCamera:WorldToViewportPoint(body_part.Position)
                        local magnitude = (Vector2.new(uis:GetMouseLocation().X, uis:GetMouseLocation().Y) - Vector2.new(screen_position.X, screen_position.Y)).Magnitude
                        if magnitude < max_distance then
                            if (visible and cheat_client.physics_library.visible_check(ws.CurrentCamera.CFrame.Position, body_part.Position)) or not visible then
                                target_part = body_part
                                target = v
                                max_distance = magnitude
                            end
                        end
                    end
                end
            end

            return target, target_part
        end
    end
end

-- UI
do
    local window = library:Window({name = "phantomhake"})

    do -- Aimbot
        local page_aimbot = window:Page({name = "aimbot"})
        local section_settings = page_aimbot:Section({name = "aimbot settings"})
        
        section_settings:Toggle({name = "enabled", default = false, pointer = "aimbot_enabled"})
        section_settings:List({name = "aimbot key", default = 1, options = {"mouse1", "mouse2", "adaptive"}, pointer = "aimbot_aimkey"})
        section_settings:Slider({name = "smoothness", default = 2, max = 25, min = 1, tick = 1, pointer = "aimbot_smoothness"})
        section_settings:Slider({name = "fov", default = 10, max = 180, min = 0, tick = 1, pointer = "aimbot_fov"})
        section_settings:Toggle({name = "dynamic fov", default = false, pointer = "dynamic_fov"})
        section_settings:MultiList({name = "hitboxes", default = 1, options = {{"Head", true}, {"Torso", true}, {"Arms", false}, {"Legs", false}}, pointer = "aimbot_hitboxes"})
        section_settings:Toggle({name = "visible", default = false, pointer = "aimbot_visible"})
    end

    do -- Visuals
        local page_visuals = window:Page({name = "visuals"})
        local section_settings = page_visuals:Section({name = "visual settings"})

        do -- Player
            section_settings:Toggle({name = "player esp", default = true, pointer = "player_esp"})
            section_settings:Toggle({name = "name", default = true, pointer = "player_name"})
            section_settings:Toggle({name = "box", default = false, pointer = "player_box"})
            section_settings:Toggle({name = "health", default = true, pointer = "player_health"})
            section_settings:Toggle({name = "weapon", default = true, pointer = "player_weapon"})
            section_settings:Toggle({name = "show team", default = true, pointer = "player_show_team"})
            section_settings:Slider({name = "range", default = 2500, max = 5000, min = 0, tick = 100, pointer = "player_range"})
        end

        section_settings:Label({name = "--"})

        do -- Dropped
            section_settings:Toggle({name = "dropped esp", default = true, pointer = "dropped_esp"})
            section_settings:Toggle({name = "spare ammo", default = true, pointer = "dropped_ammo"})
            section_settings:Slider({name = "range", default = 250, max = 500, min = 0, tick = 50, pointer = "dropped_range"})
        end
 
        section_settings:Label({name = "--"})

        do -- Aimbot
            section_settings:Toggle({name = "visualize fov", default = true, pointer = "visualize_fov"})
        end

        section_settings:Label({name = "--"})

        do -- World
            section_settings:Toggle({name = "better lighting", default = false, callback = function(state)
                if state then
                    sethiddenproperty(lit, "Technology", Enum.Technology.Future)
                else
                    sethiddenproperty(lit, "Technology", Enum.Technology.Compatibility)
                end
            end})
        end

    end

    do -- Exploits 
        local page_exploits = window:Page({name = "exploits"})
        local section_settings = page_exploits:Section({name = "exploits settings"})

        section_settings:Toggle({name = "no fall", default = false, pointer = "no_fall"})
        section_settings:Toggle({name = "radar hack", default = false, pointer = "radar_hack"})
    end

    do -- Misc
        local page_misc = window:Page({name = "misc"})
        local section_settings = page_misc:Section({name = "misc settings"})

        section_settings:Toggle({name = "no camera sway", default = false, pointer = "no_sway"})
        section_settings:Toggle({name = "no camera shake", default = false, pointer = "no_shake"})

        section_settings:Label({name = "--"})

        section_settings:Toggle({name = "no weapon bob", default = false, pointer = "no_weapon_bob"})
        section_settings:Toggle({name = "instant gun equip", default = false, pointer = "instant_equip"})
        section_settings:Toggle({name = "run and gun", default = false, pointer = "run_and_gun"})
        section_settings:Toggle({name = "no gun spread", default = false, pointer = "no_gun_spread"})
        section_settings:Toggle({name = "no gun recoil", default = false, pointer = "no_recoil"})
        section_settings:Toggle({name = "instant scope", default = false, pointer = "instant_scope"})
        section_settings:Toggle({name = "no scope sway", default = false, pointer = "no_scope_sway"})
        
        section_settings:Label({name = "--"})

        section_settings:Button({name = "rejoin", confirm = true, callback = function()
            tps:Teleport(game.PlaceId, plr, game.JobId)
        end})

    end

    do -- Config
        local page_misc = window:Page({name = "config"})
        local section_settings = page_misc:Section({name = "config settings"})

        section_settings:Button({name = "save config", confirm = true, callback = function()
            utility:SaveConfig()
        end})
        section_settings:Button({name = "load config", callback = function()
            utility:LoadConfig(global.pointers["config_slot"]:Get())
        end})
        section_settings:List({name = "config slot", options = {"slot1.cfg", "slot2.cfg", "slot3.cfg"}, default = 1, pointer = "config_slot"})
    end
end

-- Hooks
do
    do -- Network
        game_client.network.send = function(self, ...)
            local arguments = {...}
            local command = arguments[1]

            if command == "falldamage" and global.pointers["no_fall"]:Get() then
                return
            end

            return old_network_send(self, unpack(arguments))
        end
    end

    do -- Radar
        game_client.spotting_interface.isSpotted = function(player)
            if game_client.character_interface.isAlive() and global.pointers["radar_hack"]:Get() and player ~= plr then
                return true
            else
                return old_is_spotted(player)
            end
        end
    end

    do -- Shake and Sway
        game_client.main_camera_object.setSway = function(self, amount)
            local sway = global.pointers["no_sway"]:Get() and 0 or amount
        
            return old_set_sway(self, sway)
        end
        
        game_client.main_camera_object.shake = function(self, amount)
            local shake = global.pointers["no_shake"]:Get() and Vector3.zero or amount
        
            return old_shake(self, shake)
        end
    end

    do -- Gun Mods
        do -- Character
            game_client.character_object.getSpring = function(self, spring)
                if spring == "swingspring" and global.pointers["run_and_gun"]:Get() then
                    return {v = Vector3.zero}
                elseif spring == "sprintspring" and global.pointers["run_and_gun"]:Get() then
                    return {p = 0}
                elseif spring == "equipspring" and global.pointers["run_and_gun"]:Get() then
                    return {p = 0}
                elseif spring == "crouchspring" and global.pointers["run_and_gun"]:Get() then
                    return {p = 0}
                elseif spring == "pronespring" and global.pointers["run_and_gun"]:Get() then
                    return {p = 0}
                elseif spring == "slidespring" and global.pointers["run_and_gun"]:Get() then
                    return {p = 0}
                elseif spring == "climbing" and global.pointers["run_and_gun"]:Get() then
                    return {p = 0}
                end

                return old_get_spring(self, spring)
            end
        end

        do -- Firearm
            game_client.firearm_object.walkSway = function (self, lower_aimspring, higher_aimspring)
                if global.pointers["no_weapon_bob"]:Get() then
                    lower_aimspring = 0
                    higher_aimspring = 0
                end
                return old_gun_walk_sway(self, lower_aimspring, higher_aimspring)
            end

            game_client.firearm_object.gunSway = function(self, amount)
                local amount = not global.pointers["no_scope_sway"]:Get() and 0 or amount
            
                return old_gun_sway(self, amount)
            end

            game_client.firearm_object.getWeaponStat = function(self, stat)
                if stat == "hipfirespread" and global.pointers["no_gun_spread"]:Get() then
                    return 0
                elseif stat == "spread" and global.pointers["no_gun_spread"]:Get() then
                    return 0
                elseif (stat == "equipspeed") and global.pointers["instant_equip"]:Get() then
                    return 9e9
                elseif (stat == "transkickmin" or stat == "transkickmax") and global.pointers["no_recoil"]:Get() then
                    return Vector3.zero
                elseif (stat == "rotkickmin" or stat == "rotkickmax") and global.pointers["no_recoil"]:Get() then
                    return Vector3.zero
                elseif (stat == "aimswingmod" or stat == "swingmod") and global.pointers["no_recoil"]:Get() then
                    return 0
                end

                return old_get_weapon_stat(self, stat)
            end

            game_client.firearm_object.getActiveAimStat = function(self, stat)
                if (stat == "aimspeed") and global.pointers["instant_scope"]:Get() then
                    return 9e9
                elseif (stat == "aimtranskickmin" or stat == "aimtranskickmax") and global.pointers["no_recoil"]:Get() then
                    return Vector3.zero
                elseif (stat == "aimrotkickmin" or stat == "aimrotkickmax") and global.pointers["no_recoil"]:Get() then
                    return Vector3.zero
                end

                return old_get_active_aim_stat(self, stat)
            end
        end

        do -- Melee
            game_client.melee_object.walkSway = function (self, lower_aimspring, higher_aimspring)
                if global.pointers["no_weapon_bob"]:Get() then
                    lower_aimspring = 0
                    higher_aimspring = 0
                end
                return old_melee_walk_sway(self, lower_aimspring, higher_aimspring)
            end

            game_client.melee_object.meleeSway = function(self, amount)
                local amount = not global.pointers["no_weapon_bob"]:Get() and 0 or amount
            
                return old_melee_sway(self, amount)
            end

            game_client.melee_object.getWeaponStat = function(self, stat)
                if (stat == "equipspeed") and global.pointers["instant_equip"]:Get() then
                    return 9e9
                end

                return old_get_melee_stat(self, stat)
            end
        end

        do -- Grenade
            game_client.grenade_object.walkSway = function (self, lower_aimspring, higher_aimspring)
                if global.pointers["no_weapon_bob"]:Get() then
                    lower_aimspring = 0
                    higher_aimspring = 0
                end
                return old_grenade_walk_sway(self, lower_aimspring, higher_aimspring)
            end

            game_client.grenade_object.modelSway = function(self, amount)
                local amount = not global.pointers["no_weapon_bob"]:Get() and 0 or amount
            
                return old_grenade_sway(self, amount)
            end
        end
    end
end

-- Init
do
    do -- Disable Input Keys
        cas:BindActionAtPriority("DisableInputKeys", function()
            return Enum.ContextActionResult.Sink
        end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right, Enum.KeyCode.PageUp, Enum.KeyCode.PageDown)
    end

    do -- Init ESP
        do -- Player
            for _,v in next, plrs:GetPlayers() do
                if v ~= plr then
                    cheat_client:add_player_esp(v)
                end
            end
        end

        do -- Dropped
            for _,object in next, ignore_folder.GunDrop:GetChildren() do
                if object.Name == "Dropped" then
                    task.spawn(cheat_client.add_dropped_esp, cheat_client, object)
                end
            end
        end

    end

    do -- Init Aimbot
        aimbot_fov_circle = utility:Create("Circle", {
            Visible = true,
            Radius = 100,
            Transparency = 1,
            Thickness = 1,
            Color = Color3.fromRGB(255,255,255),
        }, "esp")
    end
end

-- Connections
do
    do -- Player ESP
        utility:Connection(plrs.PlayerAdded, function(player)
            cheat_client:add_player_esp(player)
        end)
        
    end

    do -- Dropped ESP
        utility:Connection(ignore_folder.GunDrop.ChildAdded, function(object)
            if object.Name == "Dropped" then
                cheat_client:add_dropped_esp(object)
            end
        end)
    end

    do -- Aimbot
        utility:Connection(rs.RenderStepped, function()
            if global.pointers["aimbot_enabled"]:Get() then
                local fov = global.pointers["aimbot_fov"]:Get()
                if global.pointers["dynamic_fov"]:Get() then
                    aimbot_fov_circle.Radius =  fov / ws.CurrentCamera.FieldOfView *  ws.CurrentCamera.ViewportSize.Y
                else
                    fov = ws.CurrentCamera.FieldOfView / game_client.player_settings.getValue("fov") * fov
                    aimbot_fov_circle.Radius =  fov / ws.CurrentCamera.FieldOfView *  ws.CurrentCamera.ViewportSize.Y
                end

                aimbot_fov_circle.Position = ws.CurrentCamera.ViewportSize/2
                aimbot_fov_circle.Visible = global.pointers["visualize_fov"]:Get()

                local aimkey = global.pointers["aimbot_aimkey"]:Get()

                local weapon_controller = game_client.weapon_controller_interface.getController()
                local current_weapon
                if weapon_controller ~= nil then
                    current_weapon = weapon_controller:getActiveWeapon()
                    if current_weapon then
                        if current_weapon:getWeaponType() == "Melee" then
                            return
                        end

                        local firemode = current_weapon:getWeaponStat("firemodes")[current_weapon._firemodeIndex]
                        if aimkey == "adaptive" then
                            if firemode == true then
                                aimkey = "mouse1"
                            else
                                aimkey = "mouse2"
                            end
                        end
                    else
                        return
                    end
                else
                    cheat_client.aimbot.current_target = nil
                    return
                end

                if uis:IsMouseButtonPressed(cheat_client.aimbot.aimkey_translation[aimkey]) then
                    local hitboxes = global.pointers["aimbot_hitboxes"]:Get()
                    local hitparts = {}

                    for i,v in next, hitboxes do
                        if v[2] then
                            if v[1] == "Arms" then
                                hitparts["Right Arm"] = true
                                hitparts["Left Arm"] = true
                            elseif v[1] == "Legs" then
                                hitparts["Right Leg"] = true
                                hitparts["Left Leg"] = true
                            else 
                                hitparts[v[1]] = true
                            end
                        end
                    end

                    local target, target_part = cheat_client:calculate_aimbot_target(hitparts)
                    if target and target_part then
                        cheat_client.aimbot.current_target = target

                        local screen_position, on_screen = ws.CurrentCamera:WorldToViewportPoint(target_part.Position)

                        mousemoverel((screen_position.X - aimbot_fov_circle.Position.X)/global.pointers["aimbot_smoothness"]:Get(), (screen_position.Y - aimbot_fov_circle.Position.Y)/global.pointers["aimbot_smoothness"]:Get())
                    else
                        cheat_client.aimbot.silent_vector = nil
                        cheat_client.aimbot.current_target = nil
                    end
                else
                    cheat_client.aimbot.silent_vector = nil
                    cheat_client.aimbot.current_target = nil
                end
            else
                cheat_client.aimbot.silent_vector = nil
                cheat_client.aimbot.current_target = nil
                aimbot_fov_circle.Visible = false
            end
        end)
    end

    do -- Notification Updater
        utility:Connection(rs.RenderStepped, function()
            local count = #global.notifications
            local removed_first = false
        
            for i = 1, count do
                local current_tick = tick()
                local notification = global.notifications[i]
                if notification then
                    if current_tick - notification.start_tick > notification.lifetime then
                        task.spawn(notification.destruct, notification)
                        table.remove(global.notifications, i)
                    elseif count > 10 and not removed_first then
                        removed_first = true
                        local first = table.remove(global.notifications, 1)
                        task.spawn(first.destruct, first)
                    else
                        local previous_notification = global.notifications[i - 1]
                        local basePosition
                        if previous_notification then
                            basePosition = Vector2.new(16, previous_notification.drawings.main_text.Position.y + previous_notification.drawings.main_text.TextBounds.y + 1)
                        else
                            basePosition = Vector2.new(16, 40)
                        end
        
                        notification.drawings.shadow_text.Position = basePosition + Vector2.new(1, 1)
                        notification.drawings.main_text.Position = basePosition
                        notification.drawings.shadow_text.Visible = true
                        notification.drawings.main_text.Visible = true
                    end
                end
            end
        end)
    end
end