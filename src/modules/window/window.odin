package window

import "odinslove:lutils"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

MODNAME :: "odinslove.window"

Window_Context :: struct{
    window_title : cstring,
}

@(private)
Window_Module_Library :: []lua.L_Reg {
    {"getFullscreen", get_fullscreen},
    {"getMode", get_mode},
    {"getPosition", get_position},
    {"getTitle", get_title},
    {"hasFocus", has_focus},
    {"maximize", maximize},
    {"minimize", minimize},
    {"restore", restore},
    {"setTitle", set_title},
    {"setPosition", set_position},
    {"setMode", set_mode},
    {nil, nil},
}

// requires the window module and pushes it onto the stack.
require_window :: proc(L: ^lua.State) {
    lua.L_requiref(L, MODNAME, open_window, 0)
}

@(private)
open_window: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()

    modname := lua.L_checkstring(L, 1)

    if modname != MODNAME {
        lua.pushstring(
            L, "Tried to require window module with the wrong module name",
        )
        lua.error(L)
    }

    lutils.getmodcontext(L, MODNAME, Window_Context, {"unknown"})

    lua.L_newlib(L, Window_Module_Library)
    return 1
}

get_fullscreen: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    lua.pushboolean(L, auto_cast rl.IsWindowFullscreen())
    return 1
}

get_mode: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    lua.pushnumber(L, auto_cast rl.GetScreenWidth())
    lua.pushnumber(L, auto_cast rl.GetScreenHeight())

    lua.newtable(L)
    lua.pushboolean(L, auto_cast rl.IsWindowFullscreen())
    lua.setfield(L, -2, "fullscreen")
    lua.pushboolean(L, auto_cast rl.IsWindowState({.VSYNC_HINT}))
    lua.setfield(L, -2, "vsync")
    lua.pushboolean(L, auto_cast rl.IsWindowState({.WINDOW_RESIZABLE}))
    lua.setfield(L, -2, "resizable")
    lua.pushboolean(L, auto_cast rl.IsWindowState({.BORDERLESS_WINDOWED_MODE}))
    lua.setfield(L, -2, "borderless")
    lua.pushboolean(L, auto_cast rl.IsWindowState({.WINDOW_TOPMOST}))
    lua.setfield(L, -2, "topmost")
    lua.pushboolean(L, auto_cast rl.IsWindowState({.WINDOW_ALWAYS_RUN}))
    lua.setfield(L, -2, "alwaysrun")
    lua.pushinteger(L, auto_cast rl.GetCurrentMonitor())
    lua.setfield(L, -2, "display")
    lua.pushinteger(L, auto_cast rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()))
    lua.setfield(L, -2, "refreshrate")
    lua.pushnumber(L, auto_cast rl.GetWindowPosition().x)
    lua.setfield(L, -2, "x")
    lua.pushnumber(L, auto_cast rl.GetWindowPosition().y)
    lua.setfield(L, -2, "y")

    return 3
}

get_position: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    lua.pushnumber(L, auto_cast rl.GetWindowPosition().x)
    lua.pushnumber(L, auto_cast rl.GetWindowPosition().y)

    return 2
}

get_title: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {

    window_context := lutils.getmodcontext(L, MODNAME, Window_Context, nil)
    lua.pushstring(L, window_context.window_title)

    return 1
}

has_focus: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    lua.pushboolean(L, auto_cast rl.IsWindowFocused())
    return 1
}

maximize: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    rl.MaximizeWindow()
    return 0
}

minimize: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    rl.MinimizeWindow()
    return 0
}

restore: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    rl.RestoreWindow()
    return 0
}

set_title: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    title := lua.L_checkstring(L, 1)

    window_context := lutils.getmodcontext(L, MODNAME, Window_Context, nil)
    window_context.window_title = title
    rl.SetWindowTitle(title)

    return 0
}

set_position: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    x := i32(lua.L_checknumber(L, 1))
    y := i32(lua.L_checknumber(L, 2))

    rl.SetWindowPosition(x, y)

    return 0
}

set_mode: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {

    width := lua.L_checknumber(L, 1)
    height := i32(lua.L_checknumber(L, 2))

    flagsvalid := true

    lua.getfield(L, 3, "fullscreen")
    flagsvalid = flagsvalid && lua.isboolean(L, -1)
    fullscreen := lua.toboolean(L, -1)
    lua.pop(L, 1)

    lua.getfield(L, 3, "vsync")
    flagsvalid = flagsvalid && lua.isboolean(L, -1)
    vsync := lua.toboolean(L, -1)
    lua.pop(L, 1)

    lua.getfield(L, 3, "resizable")
    flagsvalid = flagsvalid && lua.isboolean(L, -1)
    resizable := lua.toboolean(L, -1)
    lua.pop(L, 1)

    lua.getfield(L, 3, "borderless")
    flagsvalid = flagsvalid && lua.isboolean(L, -1)
    borderless := lua.toboolean(L, -1)
    lua.pop(L, 1)

    lua.getfield(L, 3, "topmost")
    flagsvalid = flagsvalid && lua.isboolean(L, -1)
    topmost := lua.toboolean(L, -1)
    lua.pop(L, 1)

    lua.getfield(L, 3, "alwaysrun")
    flagsvalid = flagsvalid && lua.isboolean(L, -1)
    alwaysrun := lua.toboolean(L, -1)
    lua.pop(L, 1)

    lua.getfield(L, 3, "display")
    flagsvalid = flagsvalid && lua.isinteger(L, -1)
    display := lua.tointeger(L, -1)
    lua.pop(L, 1)

    lua.getfield(L, 3, "x")
    flagsvalid = flagsvalid && lua.isnumber(L, -1)
    x := lua.tonumber(L, -1)
    lua.pop(L, 1)

    lua.getfield(L, 3, "y")
    flagsvalid = flagsvalid && lua.isnumber(L, -1)
    y := lua.tonumber(L, -1)
    lua.pop(L, 1)

    lua.L_argcheck(L, flagsvalid, 3, "invalid flags")

    flags : rl.ConfigFlags

    if fullscreen do flags += {.FULLSCREEN_MODE}
    if vsync do flags += {.VSYNC_HINT}
    if resizable do flags += {.WINDOW_RESIZABLE}
    if borderless do flags += {.BORDERLESS_WINDOWED_MODE}
    if topmost do flags += {.WINDOW_TOPMOST}
    if alwaysrun do flags += {.WINDOW_ALWAYS_RUN}

    rl.SetWindowState(flags)

    rl.SetWindowMonitor(auto_cast display)

    rl.SetWindowPosition(auto_cast x, auto_cast y)

    return 0
}
