package audio

import "base:runtime"
import "core:fmt"
import "core:c"
import rl "vendor:raylib"
import lua "vendor:lua/5.4"
import "../../lutils"

Source :: struct{
    sound: rl.Sound,
    volume: lua.Number,
}

Source_Meta :: []lua.L_Reg{
    {"getVolume", source_get_volume},
    {"setVolume", source_set_volume},
    {"play", source_play},
    {"pause", nil},
    {"seek", nil},
    {"stop", nil},
    {nil, nil},
}

register_types :: proc(L: ^lua.State) {

    // Source
    lua.L_newmetatable(L, "odinslove.audio.Source")
    lua.pushcfunction(L, delete_source)
    lua.setfield(L, -2, "__gc")
    lua.pushvalue(L, -1)
    lua.setfield(L, -2, "__index")

    lua.L_setfuncs(L, raw_data(Source_Meta), 0)

    lua.pop(L, 1)
}

delete_source :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()
    source := lutils.Lu_checkudataoftype(L, 1, Source, MODNAME)

    rl.UnloadSound(source.sound)
    return 0
}

source_get_volume :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()
    source := lutils.Lu_checkudataoftype(L, 1, Source, MODNAME)

    lua.pushnumber(L, source.volume)
    return 1
}

source_set_volume :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()
    source := lutils.Lu_checkudataoftype(L, 1, Source, MODNAME)

    source.volume = lua.L_checknumber(L, 2)
    rl.SetSoundVolume(source.sound, f32(source.volume))
    return 0
}

source_play :: proc "c"  (L: ^lua.State) -> c.int {
    context = runtime.default_context()
    source := lutils.Lu_checkudataoftype(L, 1, Source, MODNAME)

    rl.PlaySound(source.sound)
    return 0
}
