package core

import "odinslove:modules/audio"
import "odinslove:modules/graphics"
import "core:c"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

Libs :: enum{
    base = 0,
    graphics,
    audio,
}

// Initializes a new lua state, loads the specified libraries and runs the specified lua code. Also calls the "odinslove.load" callback inside lua.
init :: proc(lua_source_files: ..cstring, libs: bit_set[Libs] = {.base, .graphics, .audio}, lua_source_code: cstring = "") -> ^lua.State {
    L := init_lua(libs)

    if lua_source_code != "" {
        result :=  lua.L_dostring(L, lua_source_code)

        if result != c.int(lua.Status.OK) {
            error := lua.tostring(L, -1)
            rl.TraceLog(.ERROR, error)

            lua.pop(L, 1)
        }
    }

    for file in lua_source_files {
        result := lua.L_dofile(L, file)

        if result != c.int(lua.Status.OK) {
            error := lua.tostring(L, -1)
            rl.TraceLog(.ERROR, error)

            lua.pop(L, 1)
        }
    }

    call_load(L)

    return L
}

// This needs to be called once every frame. Calls the "odinslove.update" callback inside lua.
update :: proc(L: ^lua.State, delta_time : f32) {
    for audio_source in audio.get_all_sources(L) {
        #partial switch audio in audio_source.audio {
        case rl.Music:
            rl.UpdateMusicStream(audio)
        }
    }

    call_update(L, delta_time)
}

// This needs to be called once every frame between `rl.BeginDrawing()` and `rl.EndDrawing()`. Calls the "odinslove.draw" callback inside lua.
draw :: proc(L: ^lua.State) {
    call_draw(L)
}

// This needs to be called before exiting the game. Calls the "odinslove.quit" callback inside lua.
// Important: It also closes the lua state.
quit :: proc(L: ^lua.State) {
    call_quit(L)
    lua.close(L)
}

@(private)
init_lua :: proc(libs: bit_set[Libs]) -> ^lua.State {
    L := lua.L_newstate()

    if .base in libs {
        // open luas base libraries
        lua.open_base(L)
    }

    // this table is going to be saved as global "odinslove"
    lua.newtable(L)

    //load the individual modules and register them as fields of our new table
    if .graphics in libs {
        graphics.require_graphics(L)
        lua.setfield(L, -2, "graphics")
    }

    if .audio in libs {
        audio.require_audio(L)
        lua.setfield(L, -2, "audio")
    }

    lua.setglobal(L, "odinslove")
    return L
}
