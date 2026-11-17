package tests

import "core:c"
import "core:image"
import "core:image/png"
import "core:testing"

import ol "odinslove:core"
import "odinslove:modules/graphics"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

prepare :: proc(script: cstring="") -> ^lua.State {
    rl.SetTraceLogLevel(.NONE)

    rl.InitWindow(100, 100, "Tests")
    rl.SetTargetFPS(120)
    rl.ChangeDirectory(#directory)

    L := ol.init(lua_source_code=script)
    lua.open_debug(L)

    return L
}

cleanup :: proc(L: ^lua.State) {
    ol.quit(L)

    rl.CloseWindow()
}

expect_images_to_match :: proc(t: ^testing.T, a: rl.Image, b: rl.Image) {
    testing.expect(t, a.width == b.width && a.height == b.height, "Image sizes don't match.")
    match := true
    for x in 0..<a.width {
        for y in 0..<a.height {
            match = match && rl.GetImageColor(a, x, y) == rl.GetImageColor(b, x, y)
        }
    }

    if !match {
        rl.SetWindowSize(1360, 500)
        rl.SetWindowPosition((rl.GetMonitorWidth(rl.GetCurrentMonitor()) - 1360) / 2, (rl.GetMonitorHeight(rl.GetCurrentMonitor()) - 500) / 2)
        a_texture := rl.LoadTextureFromImage(a)
        b_texture := rl.LoadTextureFromImage(b)

        for !rl.WindowShouldClose() {
            rl.BeginDrawing()
                rl.ClearBackground(rl.WHITE)

                rl.DrawText("Images don't match!", 40, 10, 24, rl.RED)

                rl.DrawText("A:", 40, 50, 16, rl.BLACK)

                rl.DrawText("B:", 500, 50, 16, rl.BLACK)

                rl.DrawText("Color Diffrence:", 920, 50, 16, rl.BLACK)

                rl.DrawTextureEx(a_texture, {40, 70,}, 0, 4, rl.WHITE)
                rl.DrawTexturePro(b_texture, {0,0,100,100}, {480, 70, 400, 400}, {0,0}, 0, rl.WHITE)

                rl.DrawTexturePro(a_texture, {0,0,100,100}, {920, 70, 400, 400}, {0,0}, 0, rl.WHITE)
                rl.BeginBlendMode(.SUBTRACT_COLORS)
                rl.DrawTexturePro(b_texture, {0,0,100,100}, {920, 70, 400, 400}, {0,0}, 0, rl.WHITE)
                rl.EndBlendMode()
            rl.EndDrawing()
        }
    }

    testing.expect(t, match, "Images don't match.")
}

@(test)
lua_should_init :: proc(t: ^testing.T) {
    L := prepare()
    defer cleanup(L)

    testing.expect(t, L != nil, "Failed to init Lua")
}

// On initialization, odinslove should create a global table "odinslove". This table should contain subtables for each module.
// Each module should also register itself as a Lua package.
@(test)
library_registration :: proc(t: ^testing.T) {
    L := prepare()
    defer cleanup(L)

    testing.expect(t, lua.getglobal(L, "odinslove") == auto_cast lua.TTABLE, "Luaslove global table doesn't exist")

    testing.expect(
        t,
        lua.getfield(L, -1, "graphics") == auto_cast lua.TTABLE,
        "Graphics submodule isn't available as field of luaslove",
    )
    lua.pop(L, 1)

    testing.expect(
        t,
        lua.getfield(L, -1, "audio") == auto_cast lua.TTABLE,
        "Audio submodule isn't available as field of luaslove",
    )
    lua.pop(L, 1)

    testing.expect(
        t,
        lua.getfield(L, -1, "window") == auto_cast lua.TTABLE,
        "Window submodule isn't available as field of luaslove",
    )
    lua.pop(L, 1)

    lua.getfield(L, lua.REGISTRYINDEX, lua.LOADED_TABLE)

    testing.expect(
        t,
        lua.getfield(L, -1, "odinslove.graphics") == auto_cast lua.TTABLE,
        "Graphics submodule isn't registered",
    )
    lua.pop(L, 1)

    testing.expect(
        t,
        lua.getfield(L, -1, "odinslove.audio") == auto_cast lua.TTABLE,
        "Audio submodule isn't registered",
    )
    lua.pop(L, 1)

    testing.expect(
        t,
        lua.getfield(L, -1, "odinslove.window") == auto_cast lua.TTABLE,
        "Window submodule isn't registered",
    )
    lua.pop(L, 1)

}

@(test)
callbacks :: proc(t: ^testing.T) {

    L := prepare("""
function odinslove.load()
    load_called = true
end

function odinslove.update(dt)
    delta_time = dt
end

function odinslove.draw()
    draw_called = true
end

function odinslove.quit()
    setQuitCalledToTrue()
end
""")
    defer rl.CloseWindow()

    lua.getglobal(L, "load_called")
    load_called := lua.toboolean(L, -1)
    testing.expect(t, auto_cast load_called, "Load callback wasn't called on init.")

    mock_dt := f32(1.0/60)
    ol.update(L, mock_dt)

    delta_time_type := lua.getglobal(L, "delta_time")
    delta_time := lua.tonumber(L, -1)
    testing.expect(t, lua.Type(delta_time_type) == lua.Type.NUMBER, "Update callback wasn't called.")


    testing.expect(t, mock_dt == auto_cast delta_time, "Incorrect deltatime supplied to update callback.")

    rl.BeginDrawing()
    ol.draw(L)
    rl.EndDrawing()

    lua.getglobal(L, "draw_called")
    draw_called := lua.toboolean(L, -1)
    testing.expect(t, auto_cast draw_called, "Draw callback wasn't called.")

    quit_called := false
    lua.pushlightuserdata(L, &quit_called)
    lua.setglobal(L, "quit_called")

    lua.pushcfunction(L, proc "c" (L: ^lua.State) -> c.int {
        lua.getglobal(L, "quit_called")
        quit_called_ptr := cast(^bool)lua.touserdata(L, -1)
        quit_called_ptr^ = true
        return 0
    })
    lua.setglobal(L, "setQuitCalledToTrue")

    ol.quit(L)
    testing.expect(t, auto_cast quit_called, "Quit callback wasn't called.")
}

@(test)
images :: proc(t: ^testing.T) {
    L := prepare()
    defer cleanup(L)

    refrence_image :=
        png.load_from_file(#directory + "resources/test.png") or_else testing.fail_now(
            t,
            "failed to load refrence image",
        )
    defer png.destroy(refrence_image)

    //odinslove.graphics.newImage()
    lua.L_dostring(L, "image = odinslove.graphics.newImage(\"resources/test.png\")")
    lua.getglobal(L, "image")
    image := cast(^graphics.Image)lua.touserdata(L, -1)
    testing.expect(t, rl.IsTextureValid(image.texture), "Failed to open image")

    //image:getDimensions()
    lua.L_dostring(L, "width, height = image:getDimensions()")
    lua.getglobal(L, "width")
    width := int(lua.tointeger(L, -1))
    lua.getglobal(L, "height")
    height := int(lua.tointeger(L, -1))
    testing.expect_value(t, width, refrence_image.width)
    testing.expect_value(t, height, refrence_image.height)

    //image:getWidth()
    lua.L_dostring(L, "width_2 = image:getWidth()")
    lua.getglobal(L, "width_2")
    width = int(lua.tointeger(L, -1))
    testing.expect_value(t, width, refrence_image.width)

    //image:getHeight()
    lua.L_dostring(L, "height_2 = image:getHeight()")
    lua.getglobal(L, "height_2")
    height = int(lua.tointeger(L, -1))
    testing.expect_value(t, height, refrence_image.height)

    //image:setFilter() and image:getFilter()
    lua.L_dostring(L, "image:setFilter(\"linear\")\nfilter = image:getFilter()")
    lua.getglobal(L, "filter")
    filter := lua.tostring(L, -1)
    testing.expect_value(t, filter, "linear")
    lua.L_dostring(L, "image:setFilter(\"nearest\")\nfilter = image:getFilter()")
    lua.getglobal(L, "filter")
    filter = lua.tostring(L, -1)
    testing.expect_value(t, filter, "nearest")

    //image:setWrap() and image:getWrap()
    lua.L_dostring(L, "image:setWrap(\"repeat\")\nwrap = image:getWrap()")
    lua.getglobal(L, "wrap")
    wrap := lua.tostring(L, -1)
    testing.expect_value(t, wrap, "repeat")
    lua.L_dostring(L, "image:setWrap(\"clamp\")\nwrap = image:getWrap()")
    lua.getglobal(L, "wrap")
    wrap = lua.tostring(L, -1)
    testing.expect_value(t, wrap, "clamp")
    lua.L_dostring(L, "image:setWrap(\"mirroredrepeat\")\nwrap = image:getWrap()")
    lua.getglobal(L, "wrap")
    wrap = lua.tostring(L, -1)
    testing.expect_value(t, wrap, "mirroredrepeat")
    lua.L_dostring(L, "image:setWrap(\"mirroredclamp\")\nwrap = image:getWrap()")
    lua.getglobal(L, "wrap")
    wrap = lua.tostring(L, -1)
    testing.expect_value(t, wrap, "mirroredclamp")
}
