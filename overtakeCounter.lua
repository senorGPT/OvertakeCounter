-- Please do not share this script without permission from the author.
-- Inspired By: JBoondock : www.patreon.com/JBoondock
--
-- Version: 1.0
-- Written By: Dexter
-- Discord: BigDaddyDex#0001
-- Server: discord.gg/UwH68aHMPn
--
----------------------------------------------------------------------------------------------------------------------------
--========================================================================================================================--
----------------------------------------------------------------------------------------------------------------------------
--                                                   CONFIGURATION                                                        --
----------------------------------------------------------------------------------------------------------------------------
--========================================================================================================================--
CONFIG = {}

CONFIG.messages = {
    -- messages that appear when the player has crashed
    crashed = {
        'TRADING PAINT BIG TIME',
        'Why R u GEy?',
        'Ain\'t no way you were makin that.',
        'Wack Stuff Boi',
        'Yo Momma Teach You How TO Drive?',
        'Shitidiot...',
        'TradePaint Master',
        'Rest in Pieces...',
        'MAAAACK!!!!',
        'M A C K S A U C E',
        'You Hesitated....',
        'bRUH',
        'No Shot...'
    },
    -- messages that appear when the player has achieved an overtake
    overtake = {
        'IN THAT!!!!! 3x',
        'WAVY BABY. 3x',
        'D I V E 3x',
        'SKRRT!!! 3x',
        'SWERVIN LIKE SHERVIN! 3x',
        'ALMOST SHIT YO PANTS! 3x',
    },
    -- messages that appear when the player has achieved a super close overtake
    closeOvertake = {
        'HOLLY NO WAY YOU MADE THAT 5x',
        'MANS BE ACTING NINJA OUTHERE 5x',
        'SAYING YOU BE DOPED UP 5x',
        'ALCOHOL SKILL CURVE 5x',
        'JUICED UP LIKE TRUMP 5x'
    }
}

CONFIG.sounds = {
    overtake = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1000988999877394512/pog_noti_sound.mp3',
    closeOvertake = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1000988999877394512/pog_noti_sound.mp3',
    superCloseOvertake = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1000988999877394512/pog_noti_sound.mp3',
    personalBest = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1000988999877394512/pog_noti_sound.mp3'
}

CONFIG.levels = {
    {
        amount  = 0,
        name    = 'Drivers Aid',
        sound   = CONFIG.sounds.overtake,
        color   = nil
    },
    {
        amount  = 1000,
        name    = 'Gettin There',
        sound   = CONFIG.sounds.overtake,
        color   = nil
    },
    {
        amount  = 10000,
        name    = 'Duckin N\' Dodgin',
        sound   = CONFIG.sounds.overtake,
        color   = nil
    },
    {
        amount  = 100000,
        name    = 'Fast & Furious',
        sound   = CONFIG.sounds.overtake,
        color   = nil
    },
    {
        amount  = 1000000,
        name    = 'Van Diesel',
        sound   = CONFIG.sounds.overtake,
        color   = nil
    },
    {
        amount  = 10000000,
        name    = 'BaSeD',
        sound   = CONFIG.sounds.overtake,
        color   = nil
    },
}

-- DO NOT MODIFY KEYS, IE, 'adjustUI', 'resetVehicle'
-- ONLY MODIFY THE VALUES, IE, ac.KeyIndex.B, 'B', 'UI Move mode '
CONFIG.controls = {
    adjustUI = {
        key = ac.KeyIndex.B,
        keyName = 'B',
        message = 'UI Move mode '
    },
    resetVehicle = {
        key = ac.KeyIndex.Delete,
        keyName = 'Delete',
        message = 'Vehicle Reset & Re-Oriented!'
    },
    toggleSounds = {
        key = ac.KeyIndex.M,
        keyName = 'M',
        message = 'Sounds '
    }
}

CONFIG.requiredSpeed = 95                   -- required speed for the counter to start at
CONFIG.overtakeDistance = 9                 -- overtake distance between the player and other vehicles for it to count as sucessful overtake
CONFIG.closeOvertakeDistance = 4            -- close overtake distance
CONFIG.superCloseOvertakeDistance = 1       -- super close overtake distance

----------------------------------------------------------------------------------------------------------------------------
--========================================================================================================================--
----------------------------------------------------------------------------------------------------------------------------



--//--//--//--//--//--//--//--//--//--//--//--//--//--// !! NOTE !! --//--//--//--//--//--//--//--//--//--//--//--//--//--//
--                  dont edit anything below this unless you understand what you are doing                                --
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//



--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--                                                    RUN CLASS                                                         --
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------
local Run = {}

function Run:new()
    local stats = {
        score = 0,
        combo = 1,
        time = 0,
        overtakes = 0,
        fastestSpeed = 0
    }
    self.__index = self
    return setmetatable(stats, self)
end

function Run:reset()
    self.stats = {
        score = 0,
        combo = 1,
        time = 0,
        overtakes = 0,
        fastestSpeed = 0
    }
end

--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--                                                  GLOBAL VARS                                                         --
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------
-- note, am not following Lua naming convention: uppercase variable names do NOT represent constants, rather globals.
local UI_POS = vec2(0, 0)

-- TODO: should we make a Client class to hold this kind of information?
local TIME_ELAPSED = 0

local KEYPRESS_EVENTS = {}
local LAST_KEY_STATE = nil

--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------



-- TODO: rename to SCRIPT FUNCS?
--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--                                                HELPER FUNCS                                                          --
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------
--
--======================================================================================================================--
--                                                   UI FUNCS                                                           --
--======================================================================================================================--
-- TODO: rewrite this whonya
local messages = {}
local function addMessage(text)
    for i = math.min(#messages + 1, 4), 2, -1 do
        messages[i] = messages[i - 1]
        messages[i].targetPos = i
    end
    messages[1] = { text = text, age = 0, targetPos = 1, currentPos = 1 }
end

local function updateMessages(dt)
    for i = 1, #messages do
        local m = messages[i]
        m.age = m.age + dt
        m.currentPos = math.applyLag(m.currentPos, m.targetPos, 0.8, dt)
    end
end

local function showHelpMenu()
    -- only show help menu for the start of the script
    if TIME_ELAPSED == 0 then
        ac.debug("[STATUS]", "running... " .. ac.getCarName(0))
        addMessage(ac.getCarName(0), 0);
        addMessage('Dexter is here boi' .. TIME_ELAPSED);
    end
end
                                                                                                                      --
--======================================================================================================================--
--                                                LOGIC FUNCS                                                           --
--======================================================================================================================--
local function booleanToString(target)
    return target and "Enabled" or "Disabled"
end

local function keypressListeners()
    for _, keypressData in pairs(KEYPRESS_EVENTS) do
        local isKeyPressedDown = ac.isKeyDown(keypressData.key)

        if isKeyPressedDown and LAST_KEY_STATE ~= keypressData.keyName --[[ inline comment :) ]] then
            keypressData.event(keypressData.args)
            if keypressData.IIFE ~= nil then keypressData.IIFE(keypressData.args) end
        elseif not isKeyPressedDown then
            -- TODO: need to rework logic for resetting key state, as this is faulty AF
            LAST_KEY_STATE = nil -- reset hold-down button tracking
        end
    end
end

-- TODO: not sure about my naming convention here...
-- probably should be more like: clickListenerAdjustUI
local function adjustUiMouseClickListener(args)
    if ui.mouseClicked(ui.MouseButton.Left) and args.toggled then
        ac.debug("[CLICK] - adjustUI", args.clickCounter)
        args.clickCounter = args.clickCounter + 1

        UI_POS = ui.mousePos()
    end
end

--======================================================================================================================--
--                                              KEYPRESS EVENTS                                                         --
--======================================================================================================================--
local function keypressEventAdjustUI(args)
    -- check if the playeer toggled moving the UI around
    ac.debug("[KEYPRESS] - adjustUI", args.keypressCounter)
    args.keypressCounter = args.keypressCounter + 1

    args.toggled = not args.toggled
    -- addMessage(args.message .. booleanToString(args.toggled), -1)

    -- TODO: whole tracking keystates and last key pressed stuff
end

local function keypressEventResetVehicle(args)
    local player = ac.getCarState(1)

    ac.debug("[KEYPRESS] - resetVehicle", args.keypressCounter)
    args.keypressCounter = args.keypressCounter + 1

    physics.setCarPosition(0, player.position, ac.getCameraForward())
    --addMessage(args.message, -1)

    -- TODO: whole tracking keystates and last key pressed stuff
end

local function keypressEventToggleSounds(args)
    ac.debug("[KEYPRESS] - toggleSounds", args.keypressCounter)
    args.keypressCounter = args.keypressCounter + 1

    args.toggled = not args.toggled
    -- TODO: create a function to call that runs until args.toggled is turned off?? might not have to
    -- addMessage(args.message .. booleanToString(args.toggled), -1)

    -- TODO: whole tracking keystates and last key pressed stuff
end

KEYPRESS_EVENTS = {
    adjustUI = {
        event = keypressEventAdjustUI,
        args = {
            toggled = false,
            message = CONFIG.controls.adjustUI.message,
            keypressCounter = 1,
            clickCounter = 1
        },
        name  = 'adjustUI',
        key = CONFIG.controls.adjustUI.key,
        keyName = CONFIG.controls.adjustUI.keyName,
        IIFE = adjustUiMouseClickListener
    },
    resetVehicle = {
        event = keypressEventResetVehicle,
        args = {
            keypressCounter = 1,
            message = CONFIG.controls.resetVehicle.message,
        },
        name = 'Reset Vehicle',
        key = CONFIG.controls.resetVehicle.key,
        keyName = CONFIG.controls.resetVehicle.keyName,
        IIFE = nil
    },
    toggleSounds = {
        event = keypressEventToggleSounds,
        args = {
            toggled = false,
            message = CONFIG.controls.toggleSounds.message,
            keypressCounter = 1
        },
        name  = 'toggleSounds',
        key = CONFIG.controls.toggleSounds.key,
        keyName = CONFIG.controls.toggleSounds.keyName,
        IIFE = nil
    }
}

--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--                                                    AC FUNCS                                                          --
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------
function script.prepare(deltaTime)
    -- This function is called once when your plugin is loaded and prepared to run.
    -- Initialize variables, load resources, set up hooks, etc.
    return true --ac.getCarState(1).speedKmh > 60
end

function script.update(deltaTime)
    -- deltaTime is the time elapsed since the last frame in seconds
    -- Update plugin logic here
    ac.debug('[TIME_ELAPSED]', TIME_ELAPSED)

    showHelpMenu()

    keypressListeners()

    -- local player = ac.getCarState(1)
    -- local sim = ac.getSim()

    TIME_ELAPSED = TIME_ELAPSED + deltaTime
end

function script.drawUI()
    -- TODO: try .getUI() instead
    local uiState = ac.getUiState()
    updateMessages(uiState.dt)

    ui.beginTransparentWindow('overtakeScore', vec2(uiState.windowSize.x * 0.5 - 600, 100), vec2(1400, 1400), true)
    --ui.beginTransparentWindow('overtakeScore', UI_POS, vec2(1400, 1400), true)
    ui.beginOutline()

    -- FUNCS GO HERE :Dexter
    ui.pushFont(ui.Font.Title)
    ui.text('Overtake Counter :Dexter')
    ui.textColored('Personal Best:', rgbm.new(255, 0, 0, 1))


    ui.offsetCursorY(20)
    local startPos = ui.getCursor()
    for i = 1, #messages do
        local m = messages[i]
        local f = math.saturate(4 - m.currentPos) * math.saturate(8 - m.age)
        ui.setCursor(startPos + vec2(20 + math.saturate(1 - m.age * 10) ^ 2 * 100, (m.currentPos - 1) * 30))
        ui.textColored(m.text, rgbm(0, 255, 0, f))
    end

    ui.endTransparentWindow()
end

--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------