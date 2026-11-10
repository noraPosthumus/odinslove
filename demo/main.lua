function odinslove.load()
    print("Hellope, Lua!")

    image = odinslove.graphics.newImage("test.png")

    test_sound = odinslove.audio.newSource("test.wav")

    test_sound:play()

end

function odinslove.draw()
    odinslove.graphics.clear(0,0,0,1)
    odinslove.graphics.setColor(0,1,0,1)
    odinslove.graphics.circle("fill", 100, 100, 50)

   odinslove.graphics.draw( image, 400, 400, 0, 20)
end

function odinslove.update(dt)
end
