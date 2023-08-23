-- Please do not share this script without permission from the author.
-- Author: JBoondock
-- Version: 1.0
-- Patreon: www.patreon.com/JBoondock
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Modified & Rewritten By: Dexter
-- Discord: BigDaddyDex#0001
-- Server: discord.gg/UwH68aHMPn

                                                    ----------------------------
                                                    ---------- CONFIG ----------
                                                    ----------------------------

local requiredSpeed, overtakeDistance, closeOvertakeDistance = 95, 9, 4
local levelStates = {
    -- TODO: investigate if this split in string actually does anything
    killingSpree = {  url = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1001011172641878016/killingSpree.mp3', played = false, threshold = 25 },
    killingFrenzy = { url = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1001011172335702096/KillingFrenzy.mp3', played = false, threshold = 50 },
    runningRiot = { url = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1001011170272100352/RunningRiot.mp3', played = false, threshold = 75 },
    rampage = { url = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1001011169944932453/Rampage.mp3', played = false, threshold = 100 },
    untouchable = { url = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1001011170959954060/untouchable.mp3', played = false, threshold = 150 },
    invincible = { url = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1001011171974983710/invincible.mp3', played = false, threshold = 200 },
    inconcievable = { url = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1001011171236782160/inconceivable.mp3', played = false, threshold = 250 },
    unfriggenbelievable = { url = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1001011170574094376/unfriggenbelievable.mp3', played = false, threshold = 300 },
    -- TODO: add more level states
}
local soundTracks = {
    noti = { url = 'http' .. 's://cdn.discordapp.com/attachments/140183723348852736/1000988999877394512/pog_noti_sound.mp3', played = false },
    personalBest = { url = 'http' .. 's://www.myinstants.com/media/sounds/holy-shit.mp3', played = false },
}
local controls = {
    moveToggle = { key = ac.KeyIndex.B, name = 'B' },
    soundToggle = { key = ac.KeyIndex.M, name = 'M' },
    resetVehicle = { key = ac.KeyIndex.Delete, name = 'Delete' }
}
-- TODO: rename these variables to something more camelcased
local MackMessages = {
    'MAAAACK!!!!',
    'M A C K S A U C E',
    'You Hesitated....',
    'bRUH', 'No Shot...',
    'TRADING PAINT BIG TIME',
    'Ain\'t no way you were makin that.',
    'Wack Stuff Boi',
    'Yo Momma Teach You How TO Drive?',
    'Shitidiot...',
    'TradePaint Master'
}
local CloseMessages = {
    'IN THAT!!!!! 3x',
    'WAVY BABY. 3x',
    'D I V E 3x',
    'SKRRT!!! 3x',
    'SWERVIN LIKE SHERVIN! 3x',
    'ALMOST SHIT YO PANTS! 3x',
}

                                                    --------------------------
                                                    ---------- CODE ----------
                                                    --------------------------
                                                    --    DONT EDIT BELOW   --
                                                    --------------------------


-- TODO: dont know what this does
function script.prepare(dt)
    return ac.getCarState(1).speedKmh > 60
end

local mediaPlayers, carsState = { ui.MediaPlayer(), ui.MediaPlayer(), ui.MediaPlayer() }, {}
local timePassed, speedMessageTimer, mackMessageTimer, totalScore, comboMeter, comboColor, dangerouslySlowTimer, wheelsWarningTimeout, personalBest = 0, 0, 0, 0, 1, 0, 0, 0, 0
local uiCustomPos, uiMoveMode, muteToggle, lastKeyState = vec2(0, 0), false, false, nil

function script.update(dt)
                                        -- KEY PRESS LISTENER --

    -- check if the player has pressed B and toggled moving the UI around
    local isKeyPressedDown = ac.isKeyDown(controls.moveToggle.key)
    if isKeyPressedDown and lastKeyState ~= controls.moveToggle.name --[[ tracking for button hold-down ]] then
        uiMoveMode = not uiMoveMode
        lastKeyState = controls.moveToggle.name

        if not uiMoveMode then addMessage('UI Move mode Disabled', -1)
        else addMessage('UI Move mode Enabled', -1) end
    elseif not isKeyPressedDown then
        lastKeyState = nil -- reset hold-down button tracking
    end

    -- listener for keypress when UI move mode is toggled on
    if ui.mouseClicked(ui.MouseButton.Left) and uiMoveMode then
        uiCustomPos = ui.mousePos()
    end

    -- check if the player has pressed M and toggled the sounds
    isKeyPressedDown = ac.isKeyDown(controls.soundToggle.key)
    if isKeyPressedDown and lastKeyState ~= controls.soundToggle.name --[[ tracking for button hold-down ]] then
        muteToggle = not muteToggle
        lastKeyState = controls.soundToggle.name

        if muteToggle then addMessage('Sounds off', -1)
        else addMessage('Sounds on', -1) end
    elseif not isKeyPressedDown then
        lastKeyState = nil -- reset hold-down button tracking
    end

    -- check if the player is trying to reset and re-orient their vehicle
    isKeyPressedDown = ac.isKeyDown(controls.resetVehicle.key)
    if isKeyPressedDown and player.speedKmh < 15 and lastKeyState ~= controls.resetVehicle.name --[[ tracking for button hold-down ]] then
        lastKeyState = controls.soundToggle.name    
        physics.setCarPosition(0, player.position, ac.getCameraForward())

        addMessage('Vehicle Reset & Re-Oriented!', -1)
    elseif not isKeyPressedDown then
        lastKeyState = nil -- reset hold-down button tracking
    end

                                        -- /END/ KEY PRESS LISTENER --

    -- only show help menu for the start of the script
    if timePassed == 0 then
        ac.debug(" overtake counter started")
        addMessage(ac.getCarName(0), 0)
        addMessage('Original by Boon - Rewritten by Dexter', 2)
        addMessage('CTRL + D to toggle UI', -1)
        addMessage(controls.soundToggle.name .. ' to toggle sounds', -1)
        addMessage(controls.resetVehicle.name .. ' to re-orient car', -1)
        addMessage(controls.moveToggle.name .. ' to toggle moving UI', -1)
    end

    local player = ac.getCarState(1)

    timePassed = timePassed + dt
    speedMessageTimer = speedMessageTimer + dt
    mackMessageTimer = mackMessageTimer + dt

    local comboFadingRate = 0.5 * math.lerp(1, 0.1, math.lerpInvSat(player.speedKmh, 80, 200)) + player.wheelsOutside
    comboMeter = math.max(1, comboMeter - dt * comboFadingRate)

    local sim = ac.getSim()
    -- TODO: i dont think this code is necessary
    while sim.carsCount > #carsState do
        carsState[#carsState + 1] = {}
    end

    -- if wheelsWarningTimeout > 0 then
    --     wheelsWarningTimeout = wheelsWarningTimeout - dt
    -- elseif player.wheelsOutside > 0 then
    --     addMessage('Car is Out Of Zone', -1)
    --     wheelsWarningTimeout = 60
    -- end

    -- track if player is going less than the required speed
    if player.speedKmh < requiredSpeed then
        if dangerouslySlowTimer > 3 then
            ac.console('Overtake score: ' .. totalScore)
            resetPlayerStates()
        else
            if dangerouslySlowTimer < 3 and speedMessageTimer > 5 and not timePassed == 0 then
                addMessage('3 Seconds until score reset!', -1)
                speedMessageTimer = 0
            end

            if dangerouslySlowTimer == 0 and not timePassed == 0 then
                addMessage('Speed up!', -1)
            end
        end

        dangerouslySlowTimer = dangerouslySlowTimer + dt

        return -- so we dont increase our score while going less than required speed?
    else
        dangerouslySlowTimer = 0
    end

    -- player crashed, reset score
    if player.collidedWith == 0 then
        resetPlayerStates()

        --if mackMessageTimer > 1 then
            addMessage(MackMessages[math.random(1, #MackMessages)], -1)
            --mackMessageTimer = 0
        --end
    end

    -- iterate through all the level states and play the respective soundtrack when the combo score has been met
    for soundTrackName, soundTrack in pairs(levelStates) do
        if comboMeter >= soundTrack.threshold and not soundTrack.played then
            playerMediaSound(mediaPlayers[2], soundTrack.url, 0.25)
            soundTrack.played = true
        end
    end

    -- update the comboMeter depending on how close we overtake other vehicles
    for i = 2, ac.getSim().carsCount do
        local car = ac.getCarState(i)
        local state = carsState[i] -- TODO: what is teh point of this variable

        -- ac.debug(car.collidedWith .. " COLLISION")
        -- if player passed a vehicle within a normal range
        if car.position:closerToThan(player.position, overtakeDistance) then
            local drivingAlong = math.dot(car.look, player.look) > 0.2
            if not drivingAlong then
                -- if player has passed a vehicle super close
                if not state.nearMiss and car.position:closerToThan(player.position, closeOvertakeDistance) then
                    state.nearMiss = true
                end
            end

            -- ??? no idea what these variables are: drivingAlong
            if not state.overtaken and not state.collided and state.drivingAlong then
                local posDir = (car.position - player.position):normalize()
                local posDot = math.dot(posDir, car.look)
                state.maxPosDot = math.max(state.maxPosDot, posDot)
                if posDot < -0.5 and state.maxPosDot > 0.5 then
                    totalScore = totalScore + math.ceil(10 * comboMeter)
                    comboMeter = comboMeter + 1
                    comboColor = comboColor + 90

                    playerMediaSound(mediaPlayers[3], soundTracks.noti, 1)
                    addMessage('Overtake 1x', comboMeter > 50 and 1 or 0)
                    state.overtaken = true -- dont allow multiple overtakes of same vehicle

                    if car.position:closerToThan(player.position, closeOvertakeDistance) then
                        comboMeter = comboMeter + 3
                        comboColor = comboColor + math.random(1, 90)
                        comboColor = comboColor + 90

                        playerMediaSound(mediaPlayers[3], soundTracks.noti, 1)
                        addMessage(CloseMessages[math.random(#CloseMessages)], 2)
                    end

                end
            end

        else
            state.maxPosDot = -1
            state.overtaken = false
            state.collided = false
            state.drivingAlong = true
            state.nearMiss = false
        end
    end
end

                                                    --------------------------------------
                                                    ---------- HELPER FUNCTIONS ----------
                                                    --------------------------------------

function playerMediaSound(targetPlayer, soundId, volume)
    -- why is it an if/else, if its disabled should it not just do nothing?
    if muteToggle then
        targetPlayer:setSource(soundId)
        targetPlayer:setVolume(volume)
        targetPlayer:play()
    else
        targetPlayer:setSource(soundId)
        targetPlayer:setVolume(0)
        targetPlayer:pause()
    end
end

function resetPlayerStates()
    if totalScore >= personalBest then
        personalBest = totalScore
        playerMediaSound(mediaPlayers[1], soundTracks.personalBest, 0.25)
        ac.sendChatMessage('just scored a ' .. personalBest)
    end

    comboMeter = 1
    totalScore = 0

    -- iterate through all the level states and and reset the played attribute
    for soundTrackName, soundTrack in pairs(levelStates) do
        soundTrack.played = false
    end
end

                                                    ------------------------
                                                    ---------- UI ----------
                                                    ------------------------
                                                    -- TODO: rewrite alot --
local messages = {}
local glitter = {}
local glitterCount = 0

function addMessage(text, mood)
    for i = math.min(#messages + 1, 4), 2, -1 do
        messages[i] = messages[i - 1]
        messages[i].targetPos = i
    end
    messages[1] = { text = text, age = 0, targetPos = 1, currentPos = 1, mood = mood }
    if mood == 1 then
        for i = 1, 60 do
            local dir = vec2(math.random() - 0.5, math.random() - 0.5)
            glitterCount = glitterCount + 1
            glitter[glitterCount] = {
                color = rgbm.new(hsv(math.random() * 360, 1, 1):rgb(), 1),
                pos = vec2(80, 140) + dir * vec2(40, 20),
                velocity = dir:normalize():scale(0.2 + math.random()),
                life = 0.5 + 0.5 * math.random()
            }
        end
    end
end

local function updateMessages(dt)
    comboColor = comboColor + dt * 10 * comboMeter
    if comboColor > 360 then comboColor = comboColor - 360 end
    for i = 1, #messages do
        local m = messages[i]
        m.age = m.age + dt
        m.currentPos = math.applyLag(m.currentPos, m.targetPos, 0.8, dt)
    end
    for i = glitterCount, 1, -1 do
        local g = glitter[i]
        g.pos:add(g.velocity)
        g.velocity.y = g.velocity.y + 0.02
        g.life = g.life - dt
        g.color.mult = math.saturate(g.life * 4)
        if g.life < 0 then
            if i < glitterCount then
                glitter[i] = glitter[glitterCount]
            end
            glitterCount = glitterCount - 1
        end
    end
    if comboMeter > 10 and math.random() > 0.98 then
        for i = 1, math.floor(comboMeter) do
            local dir = vec2(math.random() - 0.5, math.random() - 0.5)
            glitterCount = glitterCount + 1
            glitter[glitterCount] = {
                color = rgbm.new(hsv(math.random() * 360, 1, 1):rgb(), 1),
                pos = vec2(195, 75) + dir * vec2(40, 20),
                velocity = dir:normalize():scale(0.2 + math.random()),
                life = 0.5 + 0.5 * math.random()
            }
        end
    end
end

local speedWarning = 0
local UIToggle = true
local LastKeyState = false
function script.drawUI()
    local keyState = ac.isKeyDown(ac.KeyIndex.Control) and ac.isKeyDown(ac.KeyIndex.D)
    if keyState and LastKeyState ~= keyState then
        UIToggle = not UIToggle
        LastKeyState = keyState
    elseif not keyState then
        LastKeyState = false
    end


    if UIToggle then
        local uiState = ac.getUiState()
        updateMessages(uiState.dt)

        local speedRelative = math.saturate(math.floor(ac.getCarState(1).speedKmh) / requiredSpeed)
        speedWarning = math.applyLag(speedWarning, speedRelative < 1 and 1 or 0, 0.5, uiState.dt)

        local colorDark = rgbm(0.4, 0.4, 0.4, 1)
        local colorGrey = rgbm(0.7, 0.7, 0.7, 1)
        local colorAccent = rgbm.new(hsv(speedRelative * 120, 1, 1):rgb(), 1)
        local colorCombo = rgbm.new(hsv(comboColor, math.saturate(comboMeter / 10), 1):rgb(),
            math.saturate(comboMeter / 4))

        local function speedMeter(ref)
            ui.drawRectFilled(ref + vec2(0, -4), ref + vec2(180, 5), colorDark, 1)
            ui.drawLine(ref + vec2(0, -4), ref + vec2(0, 4), colorGrey, 1)
            ui.drawLine(ref + vec2(requiredSpeed, -4), ref + vec2(requiredSpeed, 4), colorGrey, 1)

            local speed = math.min(ac.getCarState(1).speedKmh, 180)
            if speed > 1 then
                ui.drawLine(ref + vec2(0, 0), ref + vec2(speed, 0), colorAccent, 4)
            end
        end

        -- original
        -- ui.beginTransparentWindow('overtakeScore', vec2(uiState.windowSize.x * 0.5 - 600, 100), vec2(1400, 1400), true)
        ui.beginTransparentWindow('overtakeScore', uiCustomPos, vec2(1400, 1400), true)
        ui.beginOutline()

        ui.pushStyleVar(ui.StyleVar.Alpha, 1 - speedWarning)
        ui.pushFont(ui.Font.Title)
        ui.text('Shmoovin\'')
        -- ui.sameLine(0, 20)
        ui.pushFont(ui.Font.Huge)
        ui.textColored('PB:' .. personalBest .. ' pts', colorCombo)
        ui.popFont()
        ui.popStyleVar()

        ui.pushFont(ui.Font.Huge)
        ui.text(totalScore .. ' pts')
        ui.sameLine(0, 40)
        ui.beginRotation()
        ui.textColored(math.ceil(comboMeter * 10) / 10 .. 'x', colorCombo)
        if comboMeter > 20 then
            ui.endRotation(math.sin(comboMeter / 180 * 3141.5) * 3 * math.lerpInvSat(comboMeter, 20, 30) + 90)
        end
        if comboMeter > 50 then
            ui.endRotation(math.sin(comboMeter / 220 * 3141.5) * 3 * math.lerpInvSat(comboMeter, 20, 30) + 90)
        end
        if comboMeter > 100 then
            ui.endRotation(math.sin(comboMeter / 260 * 3141.5) * 3 * math.lerpInvSat(comboMeter, 20, 30) + 90)
        end
        if comboMeter > 250 then
            ui.endRotation(math.sin(comboMeter / 360 * 3141.5) * 3 * math.lerpInvSat(comboMeter, 20, 30) + 90)
        end

        ui.popFont()
        ui.endOutline(rgbm(0, 0, 0, 0.3))

        ui.offsetCursorY(20)
        ui.pushFont(ui.Font.Title)
        local startPos = ui.getCursor()
        for i = 1, #messages do
            local m = messages[i]
            local f = math.saturate(4 - m.currentPos) * math.saturate(8 - m.age)
            ui.setCursor(startPos + vec2(20 + math.saturate(1 - m.age * 10) ^ 2 * 100, (m.currentPos - 1) * 30))
            ui.textColored(m.text, m.mood == 1 and rgbm(0, 1, 0, f)
                or m.mood == -1 and rgbm(1, 0, 0, f) or m.mood == 2 and rgbm(100, 84, 0, f) or rgbm(1, 1, 1, f))
        end
        for i = 1, glitterCount do
            local g = glitter[i]
            if g ~= nil then
                ui.drawLine(g.pos, g.pos + g.velocity * 4, g.color, 2)
            end
        end
        ui.popFont()
        ui.setCursor(startPos + vec2(0, 4 * 30))

        ui.pushStyleVar(ui.StyleVar.Alpha, speedWarning)
        ui.setCursorY(0)
        ui.pushFont(ui.Font.Main)
        ui.textColored('Keep speed above ' .. requiredSpeed .. ' km/h:', colorAccent)
        speedMeter(ui.getCursor() + vec2(-9, 4))
        ui.popFont()
        ui.popStyleVar()

        ui.endTransparentWindow()
    else
        ui.text('')

    end
end
