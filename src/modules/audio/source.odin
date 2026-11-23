package audio

import "odinslove:lutils"
import "base:runtime"
import "core:c"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

TNAME_SOURCE :: MODNAME + ".Source"

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

@(private)
new_source : lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()

    check_if_audio_device_is_ready()

    n_args := lua.gettop(L)

    audio_context := lutils.getmodcontext(L, MODNAME, Audio_Context, nil)

    filename := lua.L_checkstring(L, 1)

    type: SourceType
    if n_args >= 2 {
        type = lutils.checkenum(L, 2, SourceType)
    } else {
        type = .static
    }

    source := lutils.newuserdataoftype(L, TNAME_SOURCE, Source)
    refrence := lutils.weakref(L, lua.REGISTRYINDEX)

    // push the newly created source on top of the stack so it can be returned
    lutils.getweakref(L, lua.REGISTRYINDEX, refrence)

    source.paused = false // music isn't paused, even if it isn't playing
    source.volume = 1
    source^.id = auto_cast refrence

    switch type {
    case .static: source.audio = rl.LoadSound(filename)
    case .stream: source.audio = rl.LoadMusicStream(filename)
    }

    append_elem(audio_context.source_refrences, auto_cast refrence)

    return 1
}

@(private)
source_get_volume :: proc "c" (L: ^lua.State) -> c.int {
    source := lutils.checkuserdataoftype(L, 1, TNAME_SOURCE, Source)

    lua.pushnumber(L, source.volume)
    return 1
}

@(private)
source_set_volume :: proc "c" (L: ^lua.State) -> c.int {
    source := lutils.checkuserdataoftype(L, 1, TNAME_SOURCE, Source)

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
    source := lutils.checkuserdataoftype(L, 1, TNAME_SOURCE, Source)

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
    source := lutils.checkuserdataoftype(L, 1, TNAME_SOURCE, Source)

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
    source := lutils.checkuserdataoftype(L, 1, TNAME_SOURCE, Source)

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
    source := lutils.checkuserdataoftype(L, 1, TNAME_SOURCE, Source)
    position := lua.L_checknumber(L, 2)

    switch audio in source.audio {
    case rl.Music:
        if !rl.IsMusicValid(audio) do handle_invalid_audio_error(L)
        rl.SeekMusicStream(audio, f32(position))
    case rl.Sound:
        lua.L_argerror(L, 1, "Seeking is only allowed on sources of type \"stream\"")
    }
    return 0
}

@(private)
delete_source :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()
    source := lutils.checkuserdataoftype(L, 1, TNAME_SOURCE, Source)

    switch audio in source.audio {
    case rl.Music:
        if rl.IsMusicValid(audio) do rl.UnloadMusicStream(audio)
    case rl.Sound:
        if rl.IsSoundValid(audio) do rl.UnloadSound(audio)
    }

    audio_context := lutils.getmodcontext(L, MODNAME, Audio_Context, nil)

    // delete the source from the list of all sources
    for refrence, i in audio_context.source_refrences {
        if refrence == source.id {
            unordered_remove(audio_context.source_refrences, i)
        }
    }
    shrink(audio_context.source_refrences)

    // free the refrence
    lutils.weakunref(L, lua.REGISTRYINDEX, auto_cast source.id)

    return 0
}
