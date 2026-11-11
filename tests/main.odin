package tests

import "core:testing"

import rl "vendor:raylib"
import lua "vendor:lua/5.4"
import odinslove"../src"
import "../src/modules/graphics"

prepare :: proc() -> ^lua.State {
    rl.SetTraceLogLevel(.NONE)

    rl.InitWindow(800, 600, "Tests")

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
