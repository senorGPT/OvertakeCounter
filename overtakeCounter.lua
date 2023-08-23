
--local requiredSpeed, overtakeDistance, closeOvertakeDistance, superCloseOvertakeDistance = 95, 9, 4, 1;
--local controls = {;
--    moveToggle = { key = ac.KeyIndex.B, name = 'B' },;
--    resetVehicle = { key = ac.KeyIndex.Delete, name = 'Delete' };
--};
---- TODO: rename these variables to something more camelcased;
--local MackMessages = {;
--    'TRADING PAINT BIG TIME',;
--    'Why R u GEy?',;
--    'Ain\'t no way you were makin that.',;
--    'Wack Stuff Boi',;
--    'Yo Momma Teach You How TO Drive?',;
--    'Shitidiot...',;
--    'TradePaint Master',;
--    'Rest in Pieces...',;
--    'MAAAACK!!!!',;
--    'M A C K S A U C E',;
--    'You Hesitated....',;
--    'bRUH',;
--    'No Shot...';
--};
--local CloseMessages = {;
--    'IN THAT!!!!! 3x',;
--    'WAVY BABY. 3x',;
--    'D I V E 3x',;
--    'SKRRT!!! 3x',;
--    'SWERVIN LIKE SHERVIN! 3x',;
--    'ALMOST SHIT YO PANTS! 3x',;
--};
--local superCloseMessage = {;
--    'HOLLY NO WAY YOU MADE THAT 5x',;
--    'MANS BE ACTING LIKE WAVY OUTHERE 5x',;
--    'SAYING YOU BE DOPED UP 5x',;
--    'ALCOHOL SKILL CURVE 5x',;
--    'JUICED UP LIKE TRUMP 5x';
--};
--local carsState = {}
--local timePassed, speedMessageTimer, mackMessageTimer, totalScore, comboMeter, comboColor, dangerouslySlowTimer, wheelsWarningTimeout, personalBest = 0, 0, 0, 0, 1, 0, 0, 0, 0
--local uiCustomPos, uiMoveMode, muteToggle, lastKeyStates = vec2(0, 0), false, false, { toggleMove = false, toggleSounds = false,  reorientVehicle = false }



-- Please do not share this script without permission from the author.
-- Author: JBoondock
-- Version: 1.0
-- Patreon: www.patreon.com/JBoondock
--
-- Modified & Rewritten By: Dexter
-- Discord: BigDaddyDex#0001
-- Server: discord.gg/UwH68aHMPn


--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------
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

CONFIG.controls = {
    adjustUI = { key = ac.KeyIndex.B, name = 'B' },
    resetVehicle = { key = ac.KeyIndex.Delete, name = 'Delete' }
}

CONFIG.requiredSpeed = 95                   -- required speed for the counter to start at
CONFIG.overtakeDistance = 9                 -- overtake distance between the player and other vehicles for it to count as sucessful overtake
CONFIG.closeOvertakeDistance = 4            -- close overtake distance
CONFIG.superCloseOvertakeDistance = 1       -- super close overtake distance

--------------------------------------------------------------------------------------------------------------------------
--======================================================================================================================--
--------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------
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

local RUN = require("run")

local uiCustomPos, timePassed = vec2(0, 0), 0

function script.prepare(dt)
    -- This function is called once when your plugin is loaded and prepared to run.
    -- Initialize variables, load resources, set up hooks, etc.
    return true --ac.getCarState(1).speedKmh > 60
end

function script.update(dt)
    -- deltaTime is the time elapsed since the last frame in seconds
    -- Update plugin logic here

    -- only show help menu for the start of the script
    if timePassed == 0 then
        ac.debug(" overtake counter started")
        ac.debug(" overtake counter started")
        ac.debug(" overtake counter started")
        ac.debug(" overtake counter started")
        ac.debug(" overtake counter started")
        ac.debug(" overtake counter started")
        ac.debug(" overtake counter started")
        --addMessage(ac.getCarName(0), 0)
        --addMessage('Dexter is here boi' .. timePassed, 2)
    end

    local player = ac.getCarState(1)
    local sim = ac.getSim()

    timePassed = timePassed + dt
end
















--local messages = {}
--local glitter = {}
--local glitterCount = 0
--
--function addMessage(text, mood)
--    for i = math.min(#messages + 1, 4), 2, -1 do
--        messages[i] = messages[i - 1]
--        messages[i].targetPos = i
--    end
--    messages[1] = { text = text, age = 0, targetPos = 1, currentPos = 1, mood = mood }
--    if mood == 1 then
--        for i = 1, 60 do
--            local dir = vec2(math.random() - 0.5, math.random() - 0.5)
--            glitterCount = glitterCount + 1
--            glitter[glitterCount] = {
--                color = rgbm.new(hsv(math.random() * 360, 1, 1):rgb(), 1),
--                pos = vec2(80, 140) + dir * vec2(40, 20),
--                velocity = dir:normalize():scale(0.2 + math.random()),
--                life = 0.5 + 0.5 * math.random()
--            }
--        end
--    end
--end
--
--local function updateMessages(dt)
--    comboColor = comboColor + dt * 10 * comboMeter
--    if comboColor > 360 then comboColor = comboColor - 360 end
--    for i = 1, #messages do
--        local m = messages[i]
--        m.age = m.age + dt
--        m.currentPos = math.applyLag(m.currentPos, m.targetPos, 0.8, dt)
--    end
--    for i = glitterCount, 1, -1 do
--        local g = glitter[i]
--        g.pos:add(g.velocity)
--        g.velocity.y = g.velocity.y + 0.02
--        g.life = g.life - dt
--        g.color.mult = math.saturate(g.life * 4)
--        if g.life < 0 then
--            if i < glitterCount then
--                glitter[i] = glitter[glitterCount]
--            end
--            glitterCount = glitterCount - 1
--        end
--    end
--    if comboMeter > 10 and math.random() > 0.98 then
--        for i = 1, math.floor(comboMeter) do
--            local dir = vec2(math.random() - 0.5, math.random() - 0.5)
--            glitterCount = glitterCount + 1
--            glitter[glitterCount] = {
--                color = rgbm.new(hsv(math.random() * 360, 1, 1):rgb(), 1),
--                pos = vec2(195, 75) + dir * vec2(40, 20),
--                velocity = dir:normalize():scale(0.2 + math.random()),
--                life = 0.5 + 0.5 * math.random()
--            }
--        end
--    end
--end

--local speedWarning = 0
local UIToggle = true
--local LastKeyState = false
function script.drawUI()
    --local keyState = ac.isKeyDown(ac.KeyIndex.Control) and ac.isKeyDown(ac.KeyIndex.D);
    --if keyState and LastKeyState ~= keyState then;
    --    UIToggle = not UIToggle;
    --    LastKeyState = keyState;
    --elseif not keyState then;
    --    LastKeyState = false;
    --end;


    if UIToggle then
        local uiState = ac.getUiState()
        --updateMessages(uiState.dt)

        --local speedRelative = math.saturate(math.floor(ac.getCarState(1).speedKmh) / requiredSpeed);
        --speedWarning = math.applyLag(speedWarning, speedRelative < 1 and 1 or 0, 0.5, uiState.dt);

        --local colorDark = rgbm(0.4, 0.4, 0.4, 1);
        --local colorGrey = rgbm(0.7, 0.7, 0.7, 1);
        --local colorAccent = rgbm.new(hsv(speedRelative * 120, 1, 1):rgb(), 1);
        --local colorCombo = rgbm.new(hsv(comboColor, math.saturate(comboMeter / 10), 1):rgb(),;
        --    math.saturate(comboMeter / 4));

        --local function speedMeter(ref);
        --    ui.drawRectFilled(ref + vec2(0, -4), ref + vec2(180, 5), colorDark, 1);
        --    ui.drawLine(ref + vec2(0, -4), ref + vec2(0, 4), colorGrey, 1);
        --    ui.drawLine(ref + vec2(requiredSpeed, -4), ref + vec2(requiredSpeed, 4), colorGrey, 1);

        --    local speed = math.min(ac.getCarState(1).speedKmh, 180);
        --    if speed > 1 then;
        --        ui.drawLine(ref + vec2(0, 0), ref + vec2(speed, 0), colorAccent, 4);
        --    end;
        --end;

        -- original
        -- ui.beginTransparentWindow('overtakeScore', vec2(uiState.windowSize.x * 0.5 - 600, 100), vec2(1400, 1400), true)
        ui.beginTransparentWindow('overtakeScore', uiCustomPos, vec2(1400, 1400), true)
        ui.beginOutline()

        ui.pushStyleVar(ui.StyleVar.Alpha, 1 - 1)
        ui.pushFont(ui.Font.Title)
        ui.text('Shmoovin\'')
        -- ui.sameLine(0, 20)
        --ui.pushFont(ui.Font.Huge)
        --ui.textColored('PB:' .. personalBest .. ' pts', colorCombo)
        --ui.popFont()
        --ui.popStyleVar()
--
        --ui.pushFont(ui.Font.Huge)
        --ui.text(totalScore .. ' pts')
        --ui.sameLine(0, 40)
        --ui.beginRotation()
        --ui.textColored(math.ceil(comboMeter * 10) / 10 .. 'x', colorCombo)
        --if comboMeter > 20 then
        --    ui.endRotation(math.sin(comboMeter / 180 * 3141.5) * 3 * math.lerpInvSat(comboMeter, 20, 30) + 90)
        --end
        --if comboMeter > 50 then;
        --    ui.endRotation(math.sin(comboMeter / 220 * 3141.5) * 3 * math.lerpInvSat(comboMeter, 20, 30) + 90);
        --end;
        --if comboMeter > 100 then;
        --    ui.endRotation(math.sin(comboMeter / 260 * 3141.5) * 3 * math.lerpInvSat(comboMeter, 20, 30) + 90);
        --end;
        --if comboMeter > 250 then;
        --    ui.endRotation(math.sin(comboMeter / 360 * 3141.5) * 3 * math.lerpInvSat(comboMeter, 20, 30) + 90);
        --end;

        --ui.popFont();
        --ui.endOutline(rgbm(0, 0, 0, 0.3));
--
        --ui.offsetCursorY(20);
        --ui.pushFont(ui.Font.Title);
        --local startPos = ui.getCursor();
        --for i = 1, #messages do;
        --    local m = messages[i];
        --    local f = math.saturate(4 - m.currentPos) * math.saturate(8 - m.age);
        --    ui.setCursor(startPos + vec2(20 + math.saturate(1 - m.age * 10) ^ 2 * 100, (m.currentPos - 1) * 30));
        --    ui.textColored(m.text, m.mood == 1 and rgbm(0, 1, 0, f);
        --        or m.mood == -1 and rgbm(1, 0, 0, f) or m.mood == 2 and rgbm(100, 84, 0, f) or rgbm(1, 1, 1, f));
        --end;
        --for i = 1, glitterCount do;
        --    local g = glitter[i];
        --    if g ~= nil then;
        --        ui.drawLine(g.pos, g.pos + g.velocity * 4, g.color, 2);
        --    end;
        --end;
        --ui.popFont()
        --ui.setCursor(startPos + vec2(0, 4 * 30))

        --ui.pushStyleVar(ui.StyleVar.Alpha, speedWarning)
        --ui.setCursorY(0)
        --ui.pushFont(ui.Font.Main)
        --ui.textColored('Keep speed above ' .. requiredSpeed .. ' km/h:', colorAccent)
        --speedMeter(ui.getCursor() + vec2(-9, 4))
        --ui.popFont()
        --ui.popStyleVar()

        ui.endTransparentWindow()
    else
        ui.text('')

    end
end
