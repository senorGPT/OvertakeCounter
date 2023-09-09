-- Please do not share this script without permission from the author.
-- Inspired By: JBoondock : www.patreon.com/JBoondock
--
-- Version: 1.0
-- Written By: Dexter
-- Discord: SenorGPT#0001
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
    overtake            = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1000988999877394512/pog_noti_sound.mp3',
    closeOvertake       = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1000988999877394512/pog_noti_sound.mp3',
    superCloseOvertake  = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1000988999877394512/pog_noti_sound.mp3',
    personalBest        = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1000988999877394512/pog_noti_sound.mp3'
}

--TODO implement functionality for this
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
    adjustUI        = {
        key     = ac.KeyIndex.B,
        keyName = 'B',
        message = 'UI Move mode '
    },
    resetVehicle    = {
        key     = ac.KeyIndex.Delete,
        keyName = 'Delete',
        message = 'Vehicle Reset & Re-Oriented!'
    },
    toggleSounds    = {
        key     = ac.KeyIndex.M,
        keyName = 'M',
        message = 'Sounds '
    }
}

CONFIG.requiredSpeed                = 95    -- required speed for the counter to start at
CONFIG.overtakeDistance             = 9     -- overtake distance between the player and other vehicles for it to count as sucessful overtake
CONFIG.closeOvertakeDistance        = 4     -- close overtake distance
CONFIG.superCloseOvertakeDistance   = 1     -- super close overtake distance

----------------------------------------------------------------------------------------------------------------------------
--========================================================================================================================--
----------------------------------------------------------------------------------------------------------------------------



--//--//--//--//--//--//--//--//--//--//--//--//--//--// !! NOTE !! --//--//--//--//--//--//--//--//--//--//--//--//--//--//
--                  dont edit anything below this unless you understand what you are doing                                --
--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//



--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--                                                    TIMER CLASS                                                       --
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------
local Timer = {}
function Timer:new()
    local instance = {
        active = false,
        time = 0,
        timeOut = 0,
        callback = nil,
        timedOut = false
    }
    self.__index = self
    return setmetatable(instance, self)
end

function Timer:new_(active, time, timeOut, callback)
    local instance = {
        active = active,
        time = time,
        timeOut = timeOut,
        callback = callback,
        timedOut = false
    }
    self.__index = self
    return setmetatable(instance, self)
end

function Timer:init(active, time, timeOut, callback)
    self.active = active
    self.time = time
    self.timeOut = timeOut
    self.callback = callback
    self.timedOut = false
end

function Timer:start(currentTime, timeOutSeconds, callback)
    self.active = true
    self.time = currentTime
    self.timeOut = currentTime + timeOutSeconds
    if callback then
        self.callback = callback
    end
end

function Timer:restart(currentTime, timeOutSeconds)
    if not self.active then return end
    self.time = currentTime
    self.timeOut = currentTime + timeOutSeconds
end

function Timer:isActive()
    return self.active
end

function Timer:isTimedOut()
    return self.timedOut
end

function Timer:reset(hardReset)
    self.active = false
    self.time = 0
    self.timeOut = 0
    self.timedOut = false

    if hardReset then self.callback = nil end
end

function Timer:tick(currentTime)
    if not self.active then return end

    if (self.time + self.timeOut) >= currentTime then
        self.timedOut = true
        self.active = false
        return
    end
end

--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--                                                    RUN CLASS                                                         --
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------
local Run = {}
function Run:new()
    local stats = {
        score           = 0,
        combo           = 1,
        timeStarted     = 0,
        timeElapsed     = 0, --! might be a useless variable
        overtakes       = 0,
        fastestSpeed    = 0,
        active          = false,
        over            = false,
        player          = ac.getCarState(1),
        slowTimer       = Timer:new()
    }
    self.__index = self
    return setmetatable(stats, self)
end

function Run:reset()
    self.score          = 0
    self.combo          = 1
    self.timeStarted    = 0
    self.timeElapsed    = 0 --! might be a useless variable
    self.overtakes      = 0
    self.fastestSpeed   = 0
    self.active         = false
    self.over           = false
    self.player         = ac.getCarState(1)
    self.slowTimer:reset()
end

function Run:isOver()
    return self.over
end

function Run:setOver()
    self.over = true
    self.active = false
end

function Run:crashHandler()
    self.over = self.active and self.player.collidedWith == 0
    --TODO addMessage(MackMessages[math.random(1, #MackMessages)], -1)   ... wrap in an if?
end

function Run:speedHandler(timeElapsed)
    -- check if player is going less than the required speed
    if self.active and self.player.speedKmh < CONFIG.requiredSpeed then
        if not self.slowTimer:isActive() then
            --TODO we need to make a configurable variable for amount of time
            self.slowTimer:start(timeElapsed, 5)
        end

        if self.slowTimer:isTimedOut() then
            Run:setOver()
            return
        end
    end

    -- keep track of players fastest speed
    if self.active and self.player.speedKmh > self.fastestSpeed then
        self.fastestSpeed = self.player.speedKmh
    end

    -- start the run if player goes above required speed for first time
    if not self.active and self.player.speedKmh >= CONFIG.requiredSpeed then
        self.active = true
    end
end

function Run:handler(timeElapsed)
    -- check if the player has collided
    self:crashHandler()

    -- check if player is going faster than threshold speed
    self:speedHandler(timeElapsed)

    -- TODO handle overtakes

    -- TODO handle combo & score

    self.slowTimer:tick(timeElapsed)
end

--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--                                                    CLIENT CLASS                                                      --
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------
local Client = {}
function Client:new()
    local instance = {
        runs = {},
        best_run = nil, --! possibly useless variable
        current_run = nil,
        time_elapsed = 0,
        ui_pos = vec2(0, 0),
        last_key = {
            key = nil,
            time = nil,
            timeout = 1
        },
        timers = {
            slow = Timer:new()
        }
    }
    self.__index = self
    return setmetatable(instance, self)
end

function Client:hasKeypressTimedOut()
    local returnBoolean = false
    if self.last_key.key == nil then
        ac.debug('[HAS_KEYPRESS_TIMEDOUT]', true)
        return true
    end
    if self.last_key.time + self.last_key.timeout >= self.time_elapsed then
        returnBoolean = true
    end
    ac.debug('[HAS_KEYPRESS_TIMEDOUT]', returnBoolean)
    return returnBoolean
end

function Client:canPressButton(targetButton)
    local returnBoolean = false
    -- no key has been pressed
    if self.last_key.key == nil then
        returnBoolean = true
        ac.debug('[CAN_PRESS_BUTTON_RETURN]', 'self.last_key.key == nil')
        ac.debug('[CAN_PRESS_BUTTON]', returnBoolean)
        return true
    end
    -- key is different than the last key pressed
    if self.last_key.key ~= targetButton then
        returnBoolean = true
        ac.debug('[CAN_PRESS_BUTTON_RETURN]', 'self.last_key.key ~= targetButton')
    end
    -- the timeout for the keypress has elapsed
    if self:hasKeypressTimedOut() then
        returnBoolean = true
        ac.debug('[CAN_PRESS_BUTTON_RETURN]', 'self:hasKeypressTimedOut()')
    end
    ac.debug('[CAN_PRESS_BUTTON]', returnBoolean)
    --TODO addMessage()?
    return returnBoolean
end

function Client:resetLastKey()
    self.last_key = {
        key = nil,
        time = nil,
        timeout = 1
    }
end

function Client:setKey(key, time)
    self.last_key.key = key
    self.last_key.time = time
    ac.debug('[SET_KEY]', tostring(self.last_key.key) .. ', ' .. tostring(self.last_key.time))
end

function Client:keypressTimeOutHandler()
    ac.debug('[KEYPRESS_TIMER]', tostring(self.last_key.time))
    if self:hasKeypressTimedOut() and self.last_key.key ~= nil then
        ac.debug('[keypressTimeOutHandler()]', tostring(self.time_elapsed))
        self:resetLastKey()
    end
end

function Client:isCurrentRunBestRun()
    if #self.runs == 0 then return true end

    local flag_isBestRun = true
    for i = 1, #self.runs do
        if self.runs[i].score > self.current_run.score then
            flag_isBestRun = false
        end
    end

    return flag_isBestRun
end

function Client:handler()
    self.current_run:handler()

    if self.current_run:isOver() then
        table.insert(self.runs, self.current_run)

        -- check if current_run is a `best run`
        if self:isCurrentRunBestRun() then
            self.best_run = #self.runs
        end

        --TODO addMessage()?

        self.current_run = Run:new()
    end

    self:keypressTimeOutHandler()
end

--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--                                                  GLOBAL VARS                                                         --
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------

local KEYPRESS_EVENTS = {}
local CLIENT = Client:new()

--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------



--! we might need to move helper functions above the classes
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
    ac.debug("[LAST_MSG]", text)
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
    if CLIENT.time_elapsed == 0 then
        ac.debug("[STATUS]", "running... " .. ac.getCarName(0))
        --TODO this
        addMessage(ac.getCarName(0));
        addMessage('Dexter is here boi' .. CLIENT.time_elapsed);
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
        -- TODO i dont think this needs to be a variable
        local isKeyPressedDown = ac.isKeyDown(keypressData.key)

        if isKeyPressedDown and CLIENT:canPressButton(keypressData.keyName) --[[ inline comment :) ]] then
            -- initiate callback with specified callback args
            keypressData.event(keypressData.args)
            --! probably need to make a variable for each keypress on how long to wait before user can press again
            --! self.last_key.timeOut?
            CLIENT:setKey(keypressData.keyName, CLIENT.time_elapsed + 1.0)
            -- call immediatly invoked function expression if set
            if keypressData.IIFE ~= nil then keypressData.IIFE(keypressData.args) end
        end
    end
end

local function clickListenerAdjustUI(args)
    if ui.mouseClicked(ui.MouseButton.Left) and args.toggled then
        ac.debug("[CLICK] - adjustUI", args.clickCounter)
        args.clickCounter = args.clickCounter + 1

        CLIENT.ui_pos = ui.mousePos()
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
    addMessage(args.message .. booleanToString(args.toggled))
end

local function keypressEventResetVehicle(args)
    local player = ac.getCarState(1)

    --TODO check if player is stopped or barely moving before allowing to reset

    ac.debug("[KEYPRESS] - resetVehicle", args.keypressCounter)
    args.keypressCounter = args.keypressCounter + 1

    physics.setCarPosition(0, player.position, ac.getCameraForward())
    addMessage(args.message)
end

local function keypressEventToggleSounds(args)
    ac.debug("[KEYPRESS] - toggleSounds", args.keypressCounter)
    args.keypressCounter = args.keypressCounter + 1

    args.toggled = not args.toggled
    addMessage(args.message .. booleanToString(args.toggled))
end

KEYPRESS_EVENTS = {
    adjustUI        = {
        event   = keypressEventAdjustUI,
        args    = {
            toggled         = false,
            message         = CONFIG.controls.adjustUI.message,
            keypressCounter = 1,
            clickCounter    = 1
        },
        name    = 'adjustUI',
        key     = CONFIG.controls.adjustUI.key,
        keyName = CONFIG.controls.adjustUI.keyName,
        IIFE    = clickListenerAdjustUI
    },
    resetVehicle    = {
        event   = keypressEventResetVehicle,
        args    = {
            keypressCounter = 1,
            message         = CONFIG.controls.resetVehicle.message,
        },
        name    = 'Reset Vehicle',
        key     = CONFIG.controls.resetVehicle.key,
        keyName = CONFIG.controls.resetVehicle.keyName,
        IIFE    = nil
    },
    toggleSounds    = {
        event   = keypressEventToggleSounds,
        args    = {
            toggled         = false,
            message         = CONFIG.controls.toggleSounds.message,
            keypressCounter = 1
        },
        name    = 'toggleSounds',
        key     = CONFIG.controls.toggleSounds.key,
        keyName = CONFIG.controls.toggleSounds.keyName,
        IIFE    = nil
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
    ac.debug('[TIME_ELAPSED]', CLIENT.time_elapsed)

    showHelpMenu()
    keypressListeners()

    CLIENT:handler()
    CLIENT.time_elapsed = CLIENT.time_elapsed + deltaTime
end

function script.drawUI()
    -- TODO: try .getUI() instead
    local uiState = ac.getUiState()
    updateMessages(uiState.dt)

    ui.beginTransparentWindow('overtakeScore', vec2(uiState.windowSize.x * 0.5 - 600, 100), vec2(1400, 1400), true)
    --ui.beginTransparentWindow('overtakeScore', CLIENT.ui_pos, vec2(1400, 1400), true)
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
