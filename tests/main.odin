package tests

import "core:log"
import "core:image"
import "core:image/png"
import "core:testing"

import ol "odinslove:core"
import "odinslove:modules/graphics"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

prepare :: proc() -> ^lua.State {
    rl.SetTraceLogLevel(.NONE)

    rl.InitWindow(100, 100, "Tests")
    rl.SetTargetFPS(120)
    rl.ChangeDirectory(#directory)

    L := ol.init()
    lua.open_debug(L)

    return L
}

cleanup :: proc(L: ^lua.State) {
    ol.quit(L)

    rl.CloseWindow()
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

@(test)
drawing_basic_shapes :: proc(t: ^testing.T) {
    L := prepare()
    defer cleanup(L)

    refrence_image := rl.LoadImage(#directory + "resources/shapes.png")

    lua.L_dostring(L, """
    function odinslove.draw()
        draw_was_called = true

        ---Background Color #9DFAE9
        odinslove.graphics.clear(0x9D/255, 0xFA/255, 0xE9/255, 1)

        ---circle #ff0000, x=50, y=50, radius=48
        odinslove.graphics.setColor(1, 0, 0, 1)
        odinslove.graphics.circle( \"fill\", 50, 50, 48)

        ---circle line #565EFC, x=50, y=50, radius=48, line thickness=2
        odinslove.graphics.setColor(0x56/255, 0x5E/255, 0xFC/255, 1)
        odinslove.graphics.setLineWidth(2)
        odinslove.graphics.circle( \"line\", 50, 50, 48)

        ---rectangle #671F9480, x=1, y=1, width=98, height=10
        odinslove.graphics.setColor(0x67/255, 0x1F/255, 0x94/255, 0x80/255)
        odinslove.graphics.rectangle( \"fill\", 1, 1, 98, 10)

        ---rectangle line #00000080, x=1, y=1, width=98, height=10, line thickness=1
        odinslove.graphics.setColor(0, 0, 0, 0x80/255)
        odinslove.graphics.setLineWidth(1)
        odinslove.graphics.rectangle( \"line\", 1, 1, 98, 10)

        ---line #FC8456, x1=10, y1=12, x2=60, y2=59, thickness=3
        odinslove.graphics.setColor(0xFC/255, 0x84/255, 0x56/255, 1)
        odinslove.graphics.setLineWidth(3)
        odinslove.graphics.line(10, 12, 60, 59)
    end
    """)

    // Call the prepared draw function and store the result to an image
    screen_texture := rl.LoadRenderTexture(100, 100)
    rl.BeginTextureMode(screen_texture)
        ol.draw(L)
    rl.EndTextureMode()
    screen := rl.LoadImageFromTexture(screen_texture.texture)
    rl.ImageFlipVertical(&screen)

    // check that the draw callback was called
    lua.getglobal(L, "draw_was_called")
    testing.expect(t, auto_cast lua.toboolean(L, -1), "Draw callback wasn't called.")

    // compare the resulting image with the refrence image
    screen_matches_refrence := true
    for x in 0..<screen.width {
        for y in 0..<screen.height {
            if rl.GetImageColor(screen, x, y) != rl.GetImageColor(refrence_image, x, y) {
                log.infof("%v=%v", rl.GetImageColor(screen, x, y), rl.GetImageColor(refrence_image, x, y) )
            }
            screen_matches_refrence = screen_matches_refrence && rl.GetImageColor(screen, x, y) == rl.GetImageColor(refrence_image, x, y)
        }
    }

    if !screen_matches_refrence {
        rl.SetWindowSize(1360, 500)
        rl.SetWindowPosition((rl.GetMonitorWidth(rl.GetCurrentMonitor()) - 1360) / 2, (rl.GetMonitorHeight(rl.GetCurrentMonitor()) - 500) / 2)
        refrence_texture := rl.LoadTextureFromImage(refrence_image)
        for !rl.WindowShouldClose() {
            rl.BeginDrawing()
                rl.ClearBackground(rl.WHITE)

                rl.DrawText("Failed to recreate the refrence image!", 40, 10, 24, rl.RED)

                rl.DrawText("Refrence Image:", 40, 50, 16, rl.BLACK)

                rl.DrawText("Image drawn using odinslove:", 500, 50, 16, rl.BLACK)

                rl.DrawText("Color Diffrence:", 920, 50, 16, rl.BLACK)

                rl.DrawTextureEx(refrence_texture, {40, 70,}, 0, 4, rl.WHITE)
                rl.DrawTexturePro(screen_texture.texture, {0,0,100,-100}, {480, 70, 400, 400}, {0,0}, 0, rl.WHITE)

                rl.DrawTexturePro(refrence_texture, {0,0,100,100}, {920, 70, 400, 400}, {0,0}, 0, rl.WHITE)
                rl.BeginBlendMode(.SUBTRACT_COLORS)
                rl.DrawTexturePro(screen_texture.texture, {0,0,100,-100}, {920, 70, 400, 400}, {0,0}, 0, rl.WHITE)
                rl.EndBlendMode()


            rl.EndDrawing()
        }
    }

    testing.expect(t, screen_matches_refrence, "Drawn image doesn't match refrence.")
}
