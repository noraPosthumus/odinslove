package input

import "base:runtime"
import "core:c"
import "odinslove:lutils"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

MODNAME :: "odinslove.input"

KeyConstant :: #sparse[rl.KeyboardKey]string {
    .APOSTROPHE    = "'",
    .COMMA         = ",",
    .MINUS         = "-",
    .PERIOD        = ".",
    .SLASH         = "/",
    .ZERO          = "0",
    .ONE           = "1",
    .TWO           = "2",
    .THREE         = "3",
    .FOUR          = "4",
    .FIVE          = "5",
    .SIX           = "6",
    .SEVEN         = "7",
    .EIGHT         = "8",
    .NINE          = "9",
    .SEMICOLON     = ";",
    .EQUAL         = "=",
    .A             = "a",
    .B             = "b",
    .C             = "c",
    .D             = "d",
    .E             = "e",
    .F             = "f",
    .G             = "g",
    .H             = "h",
    .I             = "i",
    .J             = "j",
    .K             = "k",
    .L             = "l",
    .M             = "m",
    .N             = "n",
    .O             = "o",
    .P             = "p",
    .Q             = "q",
    .R             = "r",
    .S             = "s",
    .T             = "t",
    .U             = "u",
    .V             = "v",
    .W             = "w",
    .X             = "x",
    .Y             = "y",
    .Z             = "z",
    .LEFT_BRACKET  = "[",
    .BACKSLASH     = "\\",
    .RIGHT_BRACKET = "]",
    .GRAVE         = "`",
    .SPACE         = " ",
    .ESCAPE        = "escape",
    .ENTER         = "enter",
    .TAB           = "tab",
    .BACKSPACE     = "backspace",
    .INSERT        = "insert",
    .DELETE        = "delete",
    .RIGHT         = "right",
    .LEFT          = "left",
    .DOWN          = "down",
    .UP            = "up",
    .PAGE_UP       = "pageup",
    .PAGE_DOWN     = "pagedown",
    .HOME          = "apphome",
    .END           = "end",
    .CAPS_LOCK     = "capslock",
    .SCROLL_LOCK   = "scrolllock",
    .NUM_LOCK      = "numlock",
    .PRINT_SCREEN  = "printscreen",
    .PAUSE         = "pause",
    .F1            = "f1",
    .F2            = "f2",
    .F3            = "f3",
    .F4            = "f4",
    .F5            = "f5",
    .F6            = "f6",
    .F7            = "f7",
    .F8            = "f8",
    .F9            = "f9",
    .F10           = "f10",
    .F11           = "f11",
    .F12           = "f12",
    .LEFT_SHIFT    = "lshift",
    .LEFT_CONTROL  = "lctrl",
    .LEFT_ALT      = "lalt",
    .LEFT_SUPER    = "lgui",
    .RIGHT_SHIFT   = "rshift",
    .RIGHT_CONTROL = "rctrl",
    .RIGHT_ALT     = "ralt",
    .RIGHT_SUPER   = "rgui",
    .KB_MENU       = "menu",
    .KP_0          = "kp0",
    .KP_1          = "kp1",
    .KP_2          = "kp2",
    .KP_3          = "kp3",
    .KP_4          = "kp4",
    .KP_5          = "kp5",
    .KP_6          = "kp6",
    .KP_7          = "kp7",
    .KP_8          = "kp8",
    .KP_9          = "kp9",
    .KP_DECIMAL    = "kp.",
    .KP_DIVIDE     = "kp/",
    .KP_MULTIPLY   = "kp*",
    .KP_SUBTRACT   = "kp-",
    .KP_ADD        = "kp+",
    .KP_ENTER      = "kpenter",
    .KP_EQUAL      = "kp=",
    .KEY_NULL      = "",
    .BACK          = "back",
    .VOLUME_UP     = "volume+",
    .VOLUME_DOWN   = "volume-",
    .MENU          = "menu",
}

// requires the input module and pushes it onto the stack.
require_input :: proc(L : ^lua.State) {
    lua.L_requiref(L, MODNAME, open_input, 0)
}

@(private)
Input_Module_Library :: []lua.L_Reg {
    {"isKeyDown", is_key_down},
    {"isKeyUp", is_key_up},
    {nil, nil},
}

@(private)
open_input : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    context = runtime.default_context()

    lutils.registeruserdatatype(L, TNAME_GAMEPAD, Gamepad_Methods)

    lua.L_newlib(L, Input_Module_Library)
    return 1
}

@(private)
is_key_down : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    result := false

    for i in 1..=lua.gettop(L) {
        key := lua.L_checkstring(L, i)
        for v, k in KeyConstant {
            if string(key) == v {
                result ||= rl.IsKeyDown(k)
            }
        }
    }

    lua.pushboolean(L, auto_cast result)
    return 1
}

@(private)
is_key_up : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    result := false

    for i in 1..=lua.gettop(L) {
        key := lua.L_checkstring(L, i)
        for v, k in KeyConstant {
            if string(key) == v {
                result ||= rl.IsKeyUp(k)
            }
        }
    }

    lua.pushboolean(L, auto_cast result)
    return 1
}
