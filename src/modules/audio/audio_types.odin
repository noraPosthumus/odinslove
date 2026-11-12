package audio

import "../../lutils"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

SourceType :: enum {
    static,
    stream,
}

Source :: struct {
    id:     int,
    audio:  union {
        rl.Music,
        rl.Sound,
    },
    volume: lua.Number,
    paused: bool,
}

@(private)
Source_Methods :: []lua.L_Reg {
    {"getVolume", source_get_volume},
    {"setVolume", source_set_volume},
    {"play", source_play},
    {"pause", source_pause},
    {"seek", source_seek},
    {"stop", source_stop},
    {"__gc", delete_source},
    {nil, nil},
}

// Register all types defined by the graphics module
register_types :: proc "c" (L: ^lua.State) {

    // Source
    lua.L_newmetatable(L, "odinslove.audio.Source")

    lua.pushvalue(L, -1)
    lua.setfield(L, -2, "__index")

    lua.L_setfuncs(L, raw_data(Source_Methods), 0)

    lua.pop(L, 1)
}

@(private)
delete_source :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()
    source := lutils.Lu_checkudataoftype(L, 1, Source, MODNAME)

    switch audio in source.audio {
    case rl.Music:
        if rl.IsMusicValid(audio) do rl.UnloadMusicStream(audio)
    case rl.Sound:
        if rl.IsSoundValid(audio) do rl.UnloadSound(audio)
    }

    lua.getfield(L, lua.REGISTRYINDEX, "odinslove.audio.audio_context")
    type := lua.getiuservalue(L, -1, 1)

    if type != auto_cast lua.TTABLE do return {}

    audio_context := get_audio_context(L)
    lua.rawgeti(L, -1, auto_cast source.id)
    for refrence, i in audio_context.source_refrences {
        if refrence == source.id {
            unordered_remove(audio_context.source_refrences, i)
        }
    }
    shrink(audio_context.source_refrences)

    return 0
}

@(private)
source_get_volume :: proc "c" (L: ^lua.State) -> c.int {
    source := lutils.Lu_checkudataoftype(L, 1, Source, MODNAME)

    lua.pushnumber(L, source.volume)
    return 1
}

@(private)
source_set_volume :: proc "c" (L: ^lua.State) -> c.int {
    source := lutils.Lu_checkudataoftype(L, 1, Source, MODNAME)

    source.volume = lua.L_checknumber(L, 2)
    switch audio in source.audio {
    case rl.Music:
        if !rl.IsMusicReady(audio) do handle_invalid_audio_error(L)
        rl.SetMusicVolume(audio, f32(source.volume))
    case rl.Sound:
        if !rl.IsSoundValid(audio) do handle_invalid_audio_error(L)
        rl.SetSoundVolume(audio, f32(source.volume))
    }
    return 0
}

@(private)
source_play :: proc "c" (L: ^lua.State) -> c.int {
    source := lutils.Lu_checkudataoftype(L, 1, Source, MODNAME)

    switch audio in source.audio {
    case rl.Music:
        if !rl.IsMusicValid(audio) do handle_invalid_audio_error(L)
        if source.paused do rl.ResumeMusicStream(audio)
        else do rl.PlayMusicStream(audio)
    case rl.Sound:
        if !rl.IsSoundValid(audio) do handle_invalid_audio_error(L)
        if source.paused do rl.ResumeSound(audio)
        else do rl.PlaySound(audio)
    }
    return 0
}

@(private)
source_pause :: proc "c" (L: ^lua.State) -> c.int {
    source := lutils.Lu_checkudataoftype(L, 1, Source, MODNAME)

    switch audio in source.audio {
    case rl.Music:
        if !rl.IsMusicValid(audio) do handle_invalid_audio_error(L)
        rl.PauseMusicStream(audio)
    case rl.Sound:
        if !rl.IsSoundValid(audio) do handle_invalid_audio_error(L)
        rl.PauseSound(audio)
    }
    return 0
}

@(private)
source_stop :: proc "c" (L: ^lua.State) -> c.int {
    source := lutils.Lu_checkudataoftype(L, 1, Source, MODNAME)

    switch audio in source.audio {
    case rl.Music:
        if !rl.IsMusicValid(audio) do handle_invalid_audio_error(L)
        rl.StopMusicStream(audio)
        source.paused = false
    case rl.Sound:
        if !rl.IsSoundValid(audio) do handle_invalid_audio_error(L)
        rl.StopSound(audio)
        source.paused = false
    }
    return 0
}

@(private)
source_seek :: proc "c" (L: ^lua.State) -> c.int {
    source := lutils.Lu_checkudataoftype(L, 1, Source, MODNAME)
    position := lua.L_checknumber(L, 2)

    switch audio in source.audio {
    case rl.Music:
        if !rl.IsMusicValid(audio) do handle_invalid_audio_error(L)
        rl.SeekMusicStream(audio, f32(position))
    case rl.Sound:
        lua.L_argerror(L, 1, "(Seeking is only allowed on sources of type \"stream\")")
    }
    return 0
}
