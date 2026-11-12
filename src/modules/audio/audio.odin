package audio

import "../../lutils"
import "base:runtime"
import "core:c"
import "core:fmt"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

MODNAME :: "odinslove.audio"

Audio_Context :: struct {
    source_refrences: ^[dynamic]int,
}

Audio_Module_LReg :: []lua.L_Reg {
    {"getVolume", lua_get_volume},
    {"setVolume", lua_set_volume},
    {"newSource", lua_new_source},
    {"play", lua_play},
    {"pause", lua_pause},
    {nil, nil},
}

open_audio :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()

    modname := lua.L_checkstring(L, 1)

    if modname != MODNAME {
        lua.pushstring(
            L,
            fmt.caprintf(
                "Tried to require audio module with wrong module name ('%s' instead of '%s'",
                modname,
                MODNAME,
            ),
        )
        lua.error(L)
    }

    register_types(L)

    lua.L_newlib(L, Audio_Module_LReg)
    return 1
}

require_audio :: proc(L: ^lua.State) {
    lua.L_requiref(L, MODNAME, open_audio, 0)
}

get_audio_context :: proc "c" (L: ^lua.State) -> ^Audio_Context {
    context = runtime.default_context()
    type := lua.getfield(L, lua.REGISTRYINDEX, "odinslove.audio.audio_context")

    if type != auto_cast lua.TUSERDATA {     // if no audio context exists, create one
        lua.pop(L, 1)
        audio_context := cast(^Audio_Context)(lua.newuserdatauv(L, size_of(Audio_Context), 1)) // "odinslove.audio.audio_context"
        audio_context.source_refrences = new([dynamic]int)
        lua.newtable(L) // "sources as a uservalue"
        lua.newtable(L) // metatable because we want weak refrences
        lua.pushliteral(L, "v")
        lua.setfield(L, -2, "__mode")
        lua.setmetatable(L, -2) // setmetatable(new_table,metatable)
        lua.setiuservalue(L, -2, 1)
        lua.setfield(L, lua.REGISTRYINDEX, "odinslove.audio.audio_context")
        lua.getfield(L, lua.REGISTRYINDEX, "odinslove.audio.audio_context")
    }

    audio_context := cast(^Audio_Context)lua.touserdata(L, -1)

    lua.pop(L, 1)
    if audio_context == nil {
        lua.pushstring(L, "failed to access graphics context")
        lua.error(L)
    }

    return audio_context
}

get_all_sources :: proc "c" (L: ^lua.State) -> []^Source {
    context = runtime.default_context()
    audio_context := get_audio_context(L)

    sources := make([dynamic]^Source, context.temp_allocator)

    lua.getfield(L, lua.REGISTRYINDEX, "odinslove.audio.audio_context")
    type := lua.getiuservalue(L, -1, 1)

    if type != auto_cast lua.TTABLE do return {}

    for source_ref in audio_context.source_refrences {
        type = lua.rawgeti(L, -1, auto_cast source_ref)
        if type == auto_cast lua.TUSERDATA {
            append_elem(&sources, cast(^Source)lua.touserdata(L, -1))
        }
        lua.pop(L, 1)
    }

    return sources[:]
}

lua_new_source :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()
    n_args := lua.gettop(L)

    audio_context := get_audio_context(L)

    filename := lua.L_checkstring(L, 1)

    type: SourceType
    if n_args >= 2 {
        type = lutils.Lu_checkenum(L, 2, SourceType)
    } else {
        type = .static
    }

    source := cast(^Source)lua.newuserdata(L, size_of(Source))
    source.paused = false // music isn't paused, even if it isn't playing
    source.volume = 1

    switch type {
    case .static: source.audio = rl.LoadSound(filename)
    case .stream: source.audio = rl.LoadMusicStream(filename)
    }

    lua.L_setmetatable(L, "odinslove.audio.Source")

    lua.getfield(L, lua.REGISTRYINDEX, "odinslove.audio.audio_context")

    lua.getiuservalue(L, -1, 1)
    lua.pushvalue(L, -3)
    refrence := lua.L_ref(L, -2)
    source^.id = auto_cast refrence
    lua.pop(L, 2)

    append_elem(audio_context.source_refrences, auto_cast refrence)

    return 1
}

lua_get_volume :: proc "c" (L: ^lua.State) -> c.int {
    lua.pushnumber(L, lua.Number(rl.GetMasterVolume()))
    return 1
}

lua_set_volume :: proc "c" (L: ^lua.State) -> c.int {
    volume := lua.L_checknumber(L, 1)
    rl.SetMasterVolume(f32(volume))
    return 0
}

lua_play :: proc "c" (L: ^lua.State) -> c.int {
    n_args := lua.gettop(L)
    if n_args == 0 do return 0
    for i in 1 ..= n_args {
        source := lutils.Lu_checkudataoftype(L, i, Source, MODNAME)
        switch audio in source.audio {
        case rl.Music:
            if source.paused do rl.ResumeMusicStream(audio)
            else do rl.PlayMusicStream(audio)
            source.paused = false
        case rl.Sound:
            if source.paused do rl.ResumeSound(audio)
            else do rl.PlaySound(audio)
            source.paused = false
        }
    }

    return 0
}

lua_pause :: proc "c" (L: ^lua.State) -> c.int {
    n_args := lua.gettop(L)

    if n_args == 0 {
        audio_context := get_audio_context(L)
        lua.newtable(L)

        lua.getfield(L, lua.REGISTRYINDEX, "odinslove.audio.audio_context")
        type := lua.getiuservalue(L, -1, 1)

        if type != auto_cast lua.TTABLE do return {}

        i := 1
        for source_ref in audio_context.source_refrences {
            top := lua.gettop(L)
            defer lua.settop(L, top)
            type = lua.rawgeti(L, -1, auto_cast source_ref)
            if type == auto_cast lua.TUSERDATA {
                source := cast(^Source)lua.touserdata(L, -1)
                switch audio in source.audio {
                case rl.Music:
                    if rl.IsMusicStreamPlaying(audio) {
                        rl.PauseMusicStream(audio)
                        source.paused = true
                        lua.seti(L, -4, auto_cast i)
                        i += 1
                    }
                case rl.Sound:
                    if rl.IsSoundPlaying(audio) {
                        rl.PauseSound(audio)
                        source.paused = true
                        lua.seti(L, -4, auto_cast i)
                        i += 1
                    }
                }
            }
        }
        lua.pop(L, 2)

        return 1
    }

    for i in 1 ..= n_args {
        source := lutils.Lu_checkudataoftype(L, i, Source, MODNAME)
        switch audio in source.audio {
        case rl.Music:
            rl.PauseMusicStream(audio)
            source.paused = true
        case rl.Sound:
            rl.PauseSound(audio)
            source.paused = true
        }
    }
    return 0
}
