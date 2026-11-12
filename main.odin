package main

import "core:fmt"
import "core:os"

import ol "odinslove:core"

import rl "vendor:raylib"

main :: proc() {
    if len(os.args) < 2 do panic("Missing path to game files")

    directory := fmt.caprint(os.args[1])
    rl.ChangeDirectory(directory)
    delete(directory)

    rl.InitWindow(800, 600, "Odinslove")
    rl.InitAudioDevice()

    L := ol.init("main.lua")

    for !rl.WindowShouldClose() {

        ol.update(L, rl.GetFrameTime())

        rl.BeginDrawing()
        ol.draw(L)
        rl.EndDrawing()

        free_all(context.temp_allocator)
    }

    ol.quit(L)

    rl.CloseAudioDevice()
    rl.CloseWindow()
}
