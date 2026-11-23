package input

import "odinslove:lutils"
import "core:c"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

TNAME_GAMEPAD :: MODNAME + ".Gamepad"

Gamepad :: struct{
    id: i32,
}

@(private)
Gamepad_Methods :: []lua.L_Reg {
    {"setVibration", gamepad_set_vibration},
    {"getName", gamepad_get_name},
    {"getID", gamepad_get_id},
    {"isConnected", gamepad_is_connected},
    {"getAxisCount", gamepad_get_axis_count},
    {"getAxis", gamepad_get_axis},
    {"getAxes", gamepad_get_axes},
    {"isDown", gamepad_is_down},
    {"isUp", gamepad_is_up},
    {"isPressed", gamepad_is_pressed},
    {"isReleased", gamepad_is_released},
    {nil, nil},
}

@(private)
get_gamepads: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    lua.newtable(L)
    for gamepad := i32(0); rl.IsGamepadAvailable(gamepad); gamepad+=1 {
        gamepad_udata := lutils.newuserdataoftype(L, TNAME_GAMEPAD, Gamepad)
        gamepad_udata^.id = gamepad
        lua.rawseti(L, -2, auto_cast gamepad)
    }
    return 1
}

@(private)
gamepad_set_vibration: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    gamepad := lutils.checkuserdataoftype(L, 1, TNAME_GAMEPAD, Gamepad)
    duration := f32(lua.L_checknumber(L, 2))
    left_motor := f32(lua.L_checknumber(L, 3))
    right_motor := f32(lua.L_optnumber(L, 4, 0))

    rl.SetGamepadVibration(gamepad.id, left_motor, right_motor, duration)
    return 0
}

@(private)
gamepad_get_name: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    gamepad := lutils.checkuserdataoftype(L, 1, TNAME_GAMEPAD, Gamepad)
    lua.pushstring(L, rl.GetGamepadName(gamepad.id))
    return 1
}

@(private)
gamepad_get_id: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    gamepad := lutils.checkuserdataoftype(L, 1, TNAME_GAMEPAD, Gamepad)
    lua.pushinteger(L, auto_cast gamepad.id)
    return 1
}

@(private)
gamepad_is_connected: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    gamepad := lutils.checkuserdataoftype(L, 1, TNAME_GAMEPAD, Gamepad)
    lua.pushboolean(L, auto_cast rl.IsGamepadAvailable(gamepad.id))
    return 1
}

@(private)
gamepad_get_axis_count: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    gamepad := lutils.checkuserdataoftype(L, 1, TNAME_GAMEPAD, Gamepad)
    lua.pushinteger(L, auto_cast rl.GetGamepadAxisCount(gamepad.id))
    return 1
}

@(private)
gamepad_get_axis: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    gamepad := lutils.checkuserdataoftype(L, 1, TNAME_GAMEPAD, Gamepad)
    axis := lua.L_checkinteger(L, 2)
    lua.pushnumber(L, auto_cast rl.GetGamepadAxisMovement(gamepad.id, rl.GamepadAxis(axis)))
    return 1
}

@(private)
gamepad_get_axes: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    gamepad := lutils.checkuserdataoftype(L, 1, TNAME_GAMEPAD, Gamepad)
    axis_count := rl.GetGamepadAxisCount(gamepad.id)
    for i in 0..<axis_count {
        lua.pushnumber(L, auto_cast rl.GetGamepadAxisMovement(gamepad.id, rl.GamepadAxis(i)))
    }
    return axis_count
}

@(private)
gamepad_is_down: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    gamepad := lutils.checkuserdataoftype(L, 1, TNAME_GAMEPAD, Gamepad)
    result := false
    for i in 2..=lua.gettop(L) {
        result ||= rl.IsGamepadButtonDown(gamepad.id, lutils.checkenum(L, i, rl.GamepadButton))
    }
    lua.pushboolean(L, auto_cast result)
    return 1
}

@(private)
gamepad_is_up: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    gamepad := lutils.checkuserdataoftype(L, 1, TNAME_GAMEPAD, Gamepad)
    result := false
    for i in 2..=lua.gettop(L) {
        result ||= rl.IsGamepadButtonUp(gamepad.id, lutils.checkenum(L, i, rl.GamepadButton))
    }
    lua.pushboolean(L, auto_cast result)
    return 1
}

@(private)
gamepad_is_pressed: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    gamepad := lutils.checkuserdataoftype(L, 1, TNAME_GAMEPAD, Gamepad)
    result := false
    for i in 2..=lua.gettop(L) {
        result ||= rl.IsGamepadButtonPressed(gamepad.id, lutils.checkenum(L, i, rl.GamepadButton))
    }
    lua.pushboolean(L, auto_cast result)
    return 1
}

@(private)
gamepad_is_released: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    gamepad := lutils.checkuserdataoftype(L, 1, TNAME_GAMEPAD, Gamepad)
    result := false
    for i in 2..=lua.gettop(L) {
        result ||= rl.IsGamepadButtonReleased(gamepad.id, lutils.checkenum(L, i, rl.GamepadButton))
    }
    lua.pushboolean(L, auto_cast result)
    return 1
}
