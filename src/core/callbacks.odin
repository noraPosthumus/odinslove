#+private
package core

import lua "vendor:lua/5.4"
import rl "vendor:raylib"

call_load :: proc(L: ^lua.State) {
    top_before := lua.gettop(L)
    defer lua.settop(L, top_before)

    lua.getglobal(L, "odinslove")
    lua.getfield(L, -1, "load")
    if lua.isfunction(L, -1) {
        err := lua.pcall(L, 0, 0, 0)
        if err != auto_cast lua.OK {
            msg := lua.tostring(L, -1)
            lua.pop(L, 1)
            rl.TraceLog(.ERROR, msg)
        }
    }
}

call_update :: proc(L: ^lua.State, delta_time: f32) {
    top_before := lua.gettop(L)
    defer lua.settop(L, top_before)

    lua.getglobal(L, "odinslove")
    lua.getfield(L, -1, "update")
    if lua.isfunction(L, -1) {
        lua.pushnumber(L, lua.Number(delta_time))
        err := lua.pcall(L, 1, 0, 0)
        if err != auto_cast lua.OK {
            msg := lua.tostring(L, -1)
            lua.pop(L, 1)
            rl.TraceLog(.ERROR, msg)
        }
    }
}

call_draw :: proc(L: ^lua.State) {
    top_before := lua.gettop(L)
    defer lua.settop(L, top_before)

    lua.getglobal(L, "odinslove")
    lua.getfield(L, -1, "draw")
    if lua.isfunction(L, -1) {
        err := lua.pcall(L, 0, 0, 0)
        if err != auto_cast lua.OK {
            msg := lua.tostring(L, -1)
            lua.pop(L, 1)
            rl.TraceLog(.ERROR, msg)
        }
    }
}

call_quit :: proc(L: ^lua.State) {
    top_before := lua.gettop(L)
    defer lua.settop(L, top_before)

    lua.getglobal(L, "odinslove")
    lua.getfield(L, -1, "quit")
    if lua.isfunction(L, -1) {
        err := lua.pcall(L, 0, 0, 0)
        if err != auto_cast lua.OK {
            msg := lua.tostring(L, -1)
            lua.pop(L, 1)
            rl.TraceLog(.ERROR, msg)
        }
    }
}

call_keypressed :: proc(L: ^lua.State, key: rl.KeyboardKey) {
    top_before := lua.gettop(L)
    defer lua.settop(L, top_before)

    lua.getglobal(L, "odinslove")
    lua.getfield(L, -1, "keypressed")
    if lua.isfunction(L, -1) {
        lua.pushstring(L, rl.GetKeyName(key))
        err := lua.pcall(L, 1, 0, 0)
        if err != auto_cast lua.OK {
            msg := lua.tostring(L, -1)
            lua.pop(L, 1)
            rl.TraceLog(.ERROR, msg)
        }
    }
}

call_mousemoved :: proc(L: ^lua.State, mouse_position: rl.Vector2, mouse_delta: rl.Vector2) {
    top_before := lua.gettop(L)
    defer lua.settop(L, top_before)

    lua.getglobal(L, "odinslove")
    lua.getfield(L, -1, "mousemoved")
    if lua.isfunction(L, -1) {
        lua.pushnumber(L, auto_cast mouse_position.x)
        lua.pushnumber(L, auto_cast mouse_position.y)
        lua.pushnumber(L, auto_cast mouse_delta.x)
        lua.pushnumber(L, auto_cast mouse_delta.y)
        err := lua.pcall(L, 4, 0, 0)
        if err != auto_cast lua.OK {
            msg := lua.tostring(L, -1)
            lua.pop(L, 1)
            rl.TraceLog(.ERROR, msg)
        }
    }
}

call_mousepressed :: proc(L: ^lua.State, mouse_position: rl.Vector2, button: rl.MouseButton) {
    top_before := lua.gettop(L)
    defer lua.settop(L, top_before)

    lua.getglobal(L, "odinslove")
    lua.getfield(L, -1, "mousepressed")
    if lua.isfunction(L, -1) {
        lua.pushnumber(L, auto_cast mouse_position.x)
        lua.pushnumber(L, auto_cast mouse_position.y)
        lua.pushinteger(L, auto_cast button)
        err := lua.pcall(L, 3, 0, 0)
        if err != auto_cast lua.OK {
            msg := lua.tostring(L, -1)
            lua.pop(L, 1)
            rl.TraceLog(.ERROR, msg)
        }
    }
}

call_wheelmoved :: proc(L: ^lua.State, mouse_wheel_movement: rl.Vector2) {
    top_before := lua.gettop(L)
    defer lua.settop(L, top_before)

    lua.getglobal(L, "odinslove")
    lua.getfield(L, -1, "wheelmoved")
    if lua.isfunction(L, -1) {
        lua.pushnumber(L, auto_cast mouse_wheel_movement.x)
        lua.pushnumber(L, auto_cast mouse_wheel_movement.y)
        err := lua.pcall(L, 2, 0, 0)
        if err != auto_cast lua.OK {
            msg := lua.tostring(L, -1)
            lua.pop(L, 1)
            rl.TraceLog(.ERROR, msg)
        }
    }
}
