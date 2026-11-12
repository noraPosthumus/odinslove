#+private
package core

import lua "vendor:lua/5.4"
import rl "vendor:raylib"

call_load :: proc(L: ^lua.State) {
    lua.getglobal(L, "odinslove")
    lua.getfield(L, -1, "load")
    if lua.isfunction(L, -1) {
        err := lua.pcall(L, 0, 0, 0)
        if int(err) != int(lua.OK) {
            msg := lua.tostring(L, -1)
            lua.pop(L, 1)
            rl.TraceLog(.ERROR, "Lua Error : %s", msg)
        }
    }
    lua.pop(L, 1)
}

call_update :: proc(L: ^lua.State, delta_time: f32) {
    lua.getglobal(L, "odinslove")
    lua.getfield(L, -1, "update")
    if lua.isfunction(L, -1) {
        lua.pushnumber(L, lua.Number(delta_time))
        err := lua.pcall(L, 1, 0, 0)
        if int(err) != int(lua.OK) {
            msg := lua.tostring(L, -1)
            lua.pop(L, 1)
            rl.TraceLog(.ERROR, "Lua Error : %s", msg)
        }
    }
    lua.pop(L, 1)
}

call_draw :: proc(L: ^lua.State) {
    lua.getglobal(L, "odinslove")
    lua.getfield(L, -1, "draw")
    if lua.isfunction(L, -1) {
        err := lua.pcall(L, 0, 0, 0)
        if int(err) != int(lua.OK) {
            msg := lua.tostring(L, -1)
            lua.pop(L, 1)
            rl.TraceLog(.ERROR, "Lua Error : %s", msg)
        }
    }
    lua.pop(L, 1)
}

call_quit :: proc(L: ^lua.State) {
    lua.getglobal(L, "odinslove")
    lua.getfield(L, -1, "quit")
    if lua.isfunction(L, -1) {
        err := lua.pcall(L, 0, 0, 0)
        if int(err) != int(lua.OK) {
            msg := lua.tostring(L, -1)
            lua.pop(L, 1)
            rl.TraceLog(.ERROR, "Lua Error : %s", msg)
        }
    }
    lua.pop(L, 1)
}
