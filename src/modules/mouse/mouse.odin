package mouse

import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

MODNAME :: "odinslove.mouse"

require_mouse :: proc (L: ^lua.State) {
    lua.L_requiref(L, MODNAME, open_mouse, 0)
}

@(private)
Methods :: []lua.L_Reg {
    {"getPosition", get_position},
    {"getX", get_x},
    {"getY", get_y},
    {"getY", get_y},
    {"isDown", is_down},
    {"setX", set_x},
    {"setY", set_y},
    {nil, nil},
}

@(private)
open_mouse: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()

    lua.L_newlib(L, Methods)
    return 1
}

@(private)
get_position: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    pos := rl.GetMousePosition()
    lua.pushnumber(L, auto_cast pos.x)
    lua.pushnumber(L, auto_cast pos.y)
    return 2
}

@(private)
get_x: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    pos := rl.GetMouseX()
    lua.pushinteger(L, auto_cast pos)
    return 1
}

@(private)
get_y: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    pos := rl.GetMouseY()
    lua.pushinteger(L, auto_cast pos)
    return 1
}

@(private)
is_visible: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    lua.pushboolean(L, !rl.IsCursorHidden())
    return 1
}

@(private)
set_visible: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    visible := bool(lua.L_checkinteger(L, 1))
    if visible {
        rl.ShowCursor()
    } else {
        rl.HideCursor()
    }
    return 0
}

@(private)
is_down: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    result := false
    for i in 2..=lua.gettop(L) {
        button := int(lua.L_checkinteger(L, i)) - 1
        lua.L_argcheck(L, button >= int(min(rl.MouseButton)) && button <= int(max(rl.MouseButton)), i, "Unknown mouse button.")
        result ||= rl.IsMouseButtonDown(rl.MouseButton(button))
    }
    lua.pushboolean(L, auto_cast result)
    return 1
}

@(private)
set_position: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    x := lua.L_checknumber(L, 1)
    y := lua.L_checknumber(L, 2)

    rl.SetMousePosition(auto_cast x, auto_cast y)
    return 0
}

@(private)
set_x: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    x := lua.L_checknumber(L, 1)

    rl.SetMousePosition(auto_cast x, rl.GetMouseY())
    return 0
}

@(private)
set_y: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    y := lua.L_checknumber(L, 1)

    rl.SetMousePosition(rl.GetMouseX(), auto_cast y)
    return 0
}
