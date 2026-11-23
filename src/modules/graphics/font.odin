package graphics

import "odinslove:lutils"
import "core:c"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

TNAME_FONT :: MODNAME + ".Font"

Font :: rl.Font

Font_Methods :: []lua.L_Reg {
    {"__gc", delete_font},
    {nil,nil},
}

@(private)
new_font: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    filename := lua.L_checkstring(L, 1)

    font := rl.LoadFont(filename)

    font_userdata := lutils.newuserdataoftype(L, TNAME_FONT, Font)
    font_userdata^ = font

    return 1
}

@(private)
delete_font : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    font := lutils.checkuserdataoftype(L, 1, TNAME_FONT, rl.Font)

    rl.UnloadFont(font^)
    return 0
}
