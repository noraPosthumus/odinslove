package tests

import "core:image/png"
import "core:testing"
import "core:image"

import rl "vendor:raylib"
import lua "vendor:lua/5.4"
import odinslove"../src"
import "../src/modules/graphics"

prepare :: proc() -> ^lua.State {
    rl.SetTraceLogLevel(.NONE)

    rl.InitWindow(800, 600, "Tests")
    rl.ChangeDirectory(#directory)

    L := odinslove.init_lua()
    lua.open_debug(L)

    return L
}

cleanup :: proc(L: ^lua.State) {
    lua.close(L)

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

    testing.expect(t, lua.getfield(L, -1, "graphics") == auto_cast lua.TTABLE, "Graphics submodule isn't available as field of luaslove")
    lua.pop(L, 1)

    testing.expect(t, lua.getfield(L, -1, "audio") == auto_cast lua.TTABLE, "Audio submodule isn't available as field of luaslove")
    lua.pop(L, 1)

    lua.getfield(L, lua.REGISTRYINDEX, lua.LOADED_TABLE)
    
    testing.expect(t, lua.getfield(L, -1, "odinslove.graphics") == auto_cast lua.TTABLE, "Graphics submodule isn't registered")
    lua.pop(L, 1)

    testing.expect(t, lua.getfield(L, -1, "odinslove.audio") == auto_cast lua.TTABLE, "Audio submodule isn't registered")
    lua.pop(L, 2)

}

@(test)
images :: proc(t: ^testing.T) {
    L := prepare()
    defer cleanup(L)

    refrence_image := png.load_from_file(#directory + "resources/test.png") or_else testing.fail_now(t, "failed to load refrence image")

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
    testing.expect_value(t, width, refrence_image.width,)
    testing.expect_value(t, height, refrence_image.height,)

    //image:getWidth()
    lua.L_dostring(L, "width_2 = image:getWidth()")
    lua.getglobal(L, "width_2")
    width = int(lua.tointeger(L, -1))
    testing.expect_value(t, width, refrence_image.width,)

    //image:getHeight()
    lua.L_dostring(L, "height_2 = image:getHeight()")
    lua.getglobal(L, "height_2")
    height = int(lua.tointeger(L, -1))
    testing.expect_value(t, height, refrence_image.height,)
}
