local pd <const> = playdate
local gfx <const> = playdate.graphics

SoundManager = {}

function SoundManager:initialize()
    self.sounds = {
        cast = playdate.sound.sampleplayer.new("assets/sound/woosh1"),
        reel = playdate.sound.sampleplayer.new("assets/sound/Reel"),
        catch = playdate.sound.sampleplayer.new("assets/sound/FishCatch"),
        splash = playdate.sound.sampleplayer.new("assets/sound/Splash"),
        cash = playdate.sound.sampleplayer.new("assets/sound/coin1"),
        bg1 = playdate.sound.fileplayer.new("assets/sound/J2F2_overworld"),
        bg2 = playdate.sound.fileplayer.new("assets/sound/J2F2_water"),
    }
end
function SoundManager:playSound(soundName, plays)
    if self.sounds[soundName] then
        self.sounds[soundName]:play(plays)
        print("Playing sound:", soundName)
    else
        print("Sound not found:", soundName)
    end
end

function SoundManager:stopSound(soundName)
    if self.sounds[soundName] then
        self.sounds[soundName]:stop()
    else
        print("Sound not found:", soundName)
    end
end

function SoundManager:playBGM()
    if not self.sounds.bg1:isPlaying() then
        self.sounds.bg1:play()
    end
end

function SoundManager:switchBGM(gameState)
    local currentOffset = 0

    if gameState == "idle" then
        -- Switch to bg1
        if self.sounds.bg2:isPlaying() then
            currentOffset = self.sounds.bg2:getOffset() -- Get the current playback position of bg2
            self.sounds.bg2:stop()
        end
        if not self.sounds.bg1:isPlaying() then
            self.sounds.bg1:setOffset(currentOffset) -- Set bg1 to start at the same position
            self.sounds.bg1:play()
        end
    else
        -- Switch to bg2
        if self.sounds.bg1:isPlaying() then
            currentOffset = self.sounds.bg1:getOffset() -- Get the current playback position of bg1
            self.sounds.bg1:stop()
        end
        if not self.sounds.bg2:isPlaying() then
            self.sounds.bg2:setOffset(currentOffset) -- Set bg2 to start at the same position
            self.sounds.bg2:play()
        end
    end
end
