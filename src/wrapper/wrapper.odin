package odinslove

import "core:dynlib"

SHARED_LIBRARY_PATH :: #config(OL_SHARED_LIBRARY_PATH, "odinslove.so")

lua_State :: struct{}

Libs :: enum{
    standard = 0,
    graphics,
    audio,
    window,
    input,
    mouse,
}

// Initializes a new lua state, loads the specified libraries and runs the specified lua code. Also calls the "odinslove.load" callback inside lua.
// Important: Call this after creating a raylib window.
init :: proc(lua_source_files: ..cstring, libs: bit_set[Libs] = {.standard, .graphics, .audio, .window, .input, .mouse,}, lua_source_code: cstring = "") -> ^lua_State {
    _, ok :=  dynlib.initialize_symbols(&_wrapper, SHARED_LIBRARY_PATH)

    if !ok do return nil

    return _wrapper._init(..lua_source_files, libs=libs, lua_source_code=lua_source_code)
}

// This needs to be called once every frame. Calls the "odinslove.update" callback inside lua.
update :: proc(L: ^lua_State, delta_time : f32) {
    _wrapper._update(L, delta_time)
}

// This needs to be called once every frame between `rl.BeginDrawing()` and `rl.EndDrawing()`. Calls the "odinslove.draw" callback inside lua.
draw :: proc(L: ^lua_State) {
    _wrapper._draw(L)
}

// This needs to be called before exiting the game. Calls the "odinslove.quit" callback inside lua.
// Important: It also closes the lua state
quit :: proc(L: ^lua_State) {
    _wrapper._quit(L)
    dynlib.unload_library(_wrapper.__handle)
}

@(private)
Odinslove :: struct{
    _init: proc(lua_source_files: ..cstring, libs: bit_set[Libs] = {.standard, .graphics, .audio, .window, .input, .mouse,}, lua_source_code: cstring = "") -> ^lua_State `dynlib:"init"`,

    _update: proc(L: ^lua_State, delta_time : f32) `dynlib:"update"`,

    _draw: proc(L: ^lua_State) `dynlib:"draw"`,

    _quit : proc(L: ^lua_State) `dynlib:"quit"`,

    __handle: dynlib.Library,
}

@(private)
_wrapper := Odinslove{}
