require("luafft")
UpdateSpectrum = true
BarWidth = 10
Song = "music/song.ogg" --You have to put your songs somewhere along the main.lua file, so love2d can access it. Then, just point this string to the song you wish to use.

function devide(list, factor)
    for i,v in ipairs(list) do list[i] = list[i] * factor end
    -- This function multiplies every value in the list of frequencies for a given constant.Think of it as a sensibility setting.
end


function love.load()
    SoundData = love.sound.newSoundData(Song) --You need to load the song both to obtain it's data AND play it.
    Size = 1024 --The amount of frequencies to obtain as result of the FFT process. 
    Frequency = 44100 --The sampling rate of the song, in Hz
    length = Size / Frequency -- The size of each frequency range of the final generated FFT values.
    Music = love.audio.newSource(Song, "stream")
    Music:play()
    Window = love.window.setMode(1024, 768, {resizable=true, vsync=true})
end


function love.update()
    ScreenSizeW = love.graphics.getWidth() --gets screen dimensions.
    ScreenSizeH = love.graphics.getHeight() --gets screen dimensions.

    local MusicPos = Music:tell("samples") --Returns the current sample being played by the engine.
    local MusicSize = SoundData:getSampleCount() --Obtain the size of the song in samples, so you can keep track of when it's gonna end.
    if MusicPos >= MusicSize - 1536 then Music:seek(0) end --Rewinds the song when the music is almost over.

    local List = {} --We'll fill this with sample information.

    for i = MusicPos, MusicPos+(Size-1) do
        CopyPos = i
        if i + 2048 > MusicSize then i = MusicSize/2 end --Make sure you stop trying to copy stuff when the song is *almost* over, or you'll wind up getting access errors!
   
        List[#List+1] = complex.new(SoundData:getSample(i*2), 0) --Copies every sample to the list, which will be fed for the FFT calculation engine.
        -- In this case, we're fetching the Right channel samples, hence the "i*2". For the left channel, use "i*2+1". If it's a mono music, use "i*2" and you should be good.
        -- The "new" function used above is for generating complex numbers. The FFT function only works if given a table of complex values, and it returns a table of this kind.
    end

    spectrum = fft(List, false) --runs your list through the FFT analyzer. Returns a table of complex values, all properly processed for your usage.
    --An FFT converts audio from a time space to a frequency space, so you can analyze the volume level in each one of it's frequency bands.

    devide(spectrum, 10) --Multiply all obtained FFT freq infos by 10.
end


function love.draw()
    if UpdateSpectrum then
        
        bars()
        --fire()
        --balls()

        for i = 1, #spectrum/8 do --In case you want to show only a part of the list, you can use #spec/(amount of bars). Setting this to 1 will render all bars processed.
            love.graphics.setColor(1,0.5,0.25,1)
            love.graphics.print("@ "..math.floor((i)/length).."Hz "..math.floor(spectrum[i]:abs()*0.7), ScreenSizeW-90,(12*i)) --prints the frequency and it's current value on the screen.
        end
        love.graphics.setColor(1,1,1,1)
        love.graphics.print("current sample: " .. CopyPos, 0, 0) --Current position being analyzed.
        love.graphics.print("total samples : " .. SoundData:getSampleCount(), 0, 20) --Current size of song in samples.
        love.graphics.print(math.floor(CopyPos *100 / SoundData:getSampleCount()) .. "%", 0,40) -- Current percentage
    end
end


function love.keypressed(key)
    if key == "escape" then love.event.quit() end
end


function bars()
    -- white bars
    for i = 1, #spectrum/8 do 
        local s = 1*(spectrum[i]:abs()*0.7)
        love.graphics.setColor(0.5,0.75,0.5,1)
        love.graphics.rectangle("fill", i*BarWidth+1, ScreenSizeH, BarWidth, -1*(spectrum[i]:abs()*0.7))
    end
end


function fire()
    -- orange/yellow/white
    for i = 1, #spectrum/8 do 
        local s = 1*(spectrum[i]:abs()*0.7)
        love.graphics.setColor(s/10000*i*10/2, s/10000*i*5/2, s/10000*i/2/2,1)
        love.graphics.rectangle("fill", i*BarWidth+1, ScreenSizeH, BarWidth, -1*(spectrum[i]:abs()*0.7),-2,-2,10)
    end
end


function balls()
    -- red bouncing balls
    for i = 1, #spectrum/8 do
        local s = 1*(spectrum[i]:abs()*0.5)
        love.graphics.setColor(1,0,0,1)
        love.graphics.circle("fill", i*BarWidth+1, ScreenSizeH - 1*(spectrum[i]:abs()), love.math.random(5,10), 20)
    end
end