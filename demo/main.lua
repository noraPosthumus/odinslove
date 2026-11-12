function odinslove.load()
    image = odinslove.graphics.newImage("test.png")

    test_sound = odinslove.audio.newSource("test.wav", "stream")
    other_sound = odinslove.audio.newSource("test.wav", "stream")

    test_sound:play()
    test_sound:seek(15)
    audios = odinslove.audio.pause()
    for i, audio in ipairs(audios) do
        audio:play()
    end
end

function odinslove.draw()
    odinslove.graphics.clear(0,0,0,1)
    odinslove.graphics.setColor(0,1,0,1)
    odinslove.graphics.circle("fill", 100, 100, 50)

   odinslove.graphics.draw( image, 400, 400, 0, 20)
end

function odinslove.update(dt)
end
