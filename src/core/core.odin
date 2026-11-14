package core

import "core:os"
import "odinslove:modules/audio"
import "odinslove:modules/graphics"
import "core:c"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

Libs :: enum{
    standard = 0,
    graphics,
    audio,
}

// Initializes a new lua state, loads the specified libraries and runs the specified lua code. Also calls the "odinslove.load" callback inside lua.
// Important: Call this after creating a raylib window.
init :: proc(lua_source_files: ..cstring, libs: bit_set[Libs] = {.standard, .graphics, .audio}, lua_source_code: cstring = "") -> ^lua.State {

    if !rl.IsWindowReady() {
        rl.TraceLog(.FATAL, "Window not initialized. Make sure to call `rl.InitWindow()` before initializing odinslove.")
        os.exit(1)
    }
    
    if !rl.IsAudioDeviceReady() && .audio in libs {
        rl.TraceLog(.WARNING, "Missing audio device. Make sure to call `rl.InitAudioDevice()` before initializing odinslove.")
    }

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
            if !rl.IsAudioDeviceReady() {
                rl.TraceLog(.FATAL, "Missing audio device. Don't forget to call `rl.InitAudioDevice()` before loading any audio.")
                os.exit(1)
            }
            rl.UpdateMusicStream(audio)
        }
    }

    if rl.Vector2Length(rl.GetMouseDelta()) > 0.2 {
        call_mousemoved(L, rl.GetMousePosition(), rl.GetMouseDelta())
    }

    for key := rl.GetKeyPressed(); key != rl.KeyboardKey.KEY_NULL; key = rl.GetKeyPressed() {
        call_keypressed(L, key)
    }

    for mouse_button in rl.MouseButton {
        if rl.IsMouseButtonPressed(mouse_button) {
            call_mousepressed(L, rl.GetMousePosition(), mouse_button)
        }
    }

    if rl.Vector2Length(rl.GetMouseWheelMoveV()) > 0.2 {
        call_wheelmoved(L, rl.GetMouseWheelMoveV())
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

    if .standard in libs {
        // open luas standard libraries
        lua.L_openlibs(L)
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
