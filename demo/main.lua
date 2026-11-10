function odinslove.load()
    print("Hellope, Lua!")

    image = odinslove.graphics.newImage("test.png")
    image:setFilter("nearest")
    print(image:getFilter())
end

function odinslove.draw()
    odinslove.graphics.clear(0,0,0,1)
    odinslove.graphics.setColor(0,1,0,1)
    odinslove.graphics.circle("fill", 100, 100, 50)
end

function odinslove.update(dt)
end
