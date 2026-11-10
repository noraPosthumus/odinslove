package audio

import "base:runtime"
import "core:fmt"
import "core:c"
import rl "vendor:raylib"
import lua "vendor:lua/5.4"

MODNAME :: "odinslove.audio"

Audio_Module_LReg :: []lua.L_Reg{
    {"getVolume", nil},
    {"setVolume", nil},
    {"newSource", lua_new_source},
    {"play", nil},
    {"pause", nil},
    {nil, nil},
}

open_audio :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()

    modname := lua.L_checkstring(L, 1)

    if modname != MODNAME {
        lua.pushstring(L, fmt.caprintf("Tried to require audio module with wrong module name ('%s' instead of '%s'", modname, MODNAME))
        lua.error(L)
    }

    register_types(L)
        
    lua.L_newlib(L, Audio_Module_LReg)
    return 1
}

require_audio :: proc (L: ^lua.State) {
    lua.L_requiref(L, MODNAME, open_audio, 0)
}

lua_new_source :: proc "c" (L: ^lua.State) -> c.int {
    filename := lua.L_checkstring(L, 1)

    sound := rl.LoadSound(filename)

    source := cast(^Source)lua.newuserdata(L, size_of(Source))
    source.sound = sound

    lua.L_setmetatable(L, "odinslove.audio.Source")

    return 1
}
