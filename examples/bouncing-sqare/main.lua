local counter = 0

local window_width
local window_height

local x, y = 0, 0
local direction_x, direction_y = 1, 1
local size
local speed

local color

local function generateRandomColor()
    local r = math.random(0, 1)
    local g = math.random(0, 1)
    local b = math.random(0, 1)
    if r + g + b == 0 then
        r = 1
        g = 1
        b = 1
    end
    return { r, g, b, 1 }
end

function odinslove.load()
    window_width = odinslove.graphics.getWidth()
    window_height = odinslove.graphics.getHeight()

    size = math.max(20, math.min(window_height, window_width) / 10)
    speed = size * 7

    color = generateRandomColor()
end

function odinslove.draw()
    --- clear the screen
    odinslove.graphics.clear(0, 0, 0, 1)

    --- set the current color to our ranomly generated one
    odinslove.graphics.setColor(color)

    --- draw the sqare
    odinslove.graphics.rectangle("fill", x, y, size)

    --- draw the counter
    odinslove.graphics.setColor(1, 1, 1, 1)
    odinslove.graphics.printf(tostring(counter), 0, 20, window_width, "center", 80)
end

function odinslove.update(dt)
    x = x + dt * speed * direction_x
    if x < 0 then
        x = 0
        direction_x = 1
        counter = counter + 1
        color = generateRandomColor()
    elseif x + size > window_width then
        x = window_width - size
        direction_x = -1
        counter = counter + 1
        color = generateRandomColor()
    end

    y = y + dt * speed * direction_y
    if y < 0 then
        y = 0
        direction_y = 1
        counter = counter + 1
        color = generateRandomColor()
    elseif y + size > window_height then
        y = window_height - size
        direction_y = -1
        counter = counter + 1
        color = generateRandomColor()
    end
end
