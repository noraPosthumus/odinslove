package input

import "odinslove:lutils"
import "core:c"
import "base:runtime"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

MODNAME :: "odinslove.input"

// requires the input module and pushes it onto the stack.
require_input :: proc(L: ^lua.State) {
    lua.L_requiref(L, MODNAME, open_input, 0)
}

@(private)
Input_Module_Library :: []lua.L_Reg {
    {"isKeyPressed", is_key_pressed},
    {"isKeyDown", is_key_down},
    {"isKeyReleased", is_key_realeased},
    {"isKeyUp", is_key_up},
    {"isKeyPressedRepeat", is_key_pressed_repeat},
    {nil, nil},
}

@(private)
open_input: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()

    lutils.registeruserdatatype(L, TNAME_GAMEPAD, Gamepad_Methods)

    lua.L_newlib(L, Input_Module_Library)
    return 1
}

@(private)
is_key_pressed: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    key := lutils.checkenum(L, 1, rl.KeyboardKey)
    lua.pushboolean(L, auto_cast rl.IsKeyPressed(key))
    return 1
}

@(private)
is_key_down: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    key := lutils.checkenum(L, 1, rl.KeyboardKey)
    lua.pushboolean(L, auto_cast rl.IsKeyDown(key))
    return 1
}

@(private)
is_key_realeased: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    key := lutils.checkenum(L, 1, rl.KeyboardKey)
    lua.pushboolean(L, auto_cast rl.IsKeyReleased(key))
    return 1
}

@(private)
is_key_up: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    key := lutils.checkenum(L, 1, rl.KeyboardKey)
    lua.pushboolean(L, auto_cast rl.IsKeyUp(key))
    return 1
}

@(private)
is_key_pressed_repeat: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    key := lutils.checkenum(L, 1, rl.KeyboardKey)
    lua.pushboolean(L, auto_cast rl.IsKeyPressedRepeat(key))
    return 1
}
