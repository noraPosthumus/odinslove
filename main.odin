package main

import "core:log"
import "core:fmt"
import "core:os"

import ol "odinslove:core"

import rl "vendor:raylib"

USAGE_INFO :: """

    usage: odinslove <DIRECTORY> [-h] [-v]

    Play the odinslove project inside <DIRECTORY>.

    -h, --help          Print this usage information
    -v, --version       Print the version of odinslove

    Note: An odinslove project consists of a main.lua file and any number of resources that are accessed from within main.lua.

    To get started, create a new folder and inside that folder create a new file, main.lua. The following lua code is an example for a simple main.lua script.

    function odinslove.draw()
        odinslove.graphics.clear()
        odinslove.graphics.setColor(0,1,0,1)
        odinslove.graphics.circle(\"fill\", 50, 50, 30)
    end

"""

main :: proc() {
    context.logger = log.create_console_logger()

    if len(os.args) < 2 || os.args[1] == "-h" || os.args[1] == "--help" {
        fmt.print(USAGE_INFO)
        os.exit(0)
    }

    if os.args[1] == "-v" || os.args[1] == "--version" {
        fmt.println("    Odinslove is still in very early development and doesn't have a version number yet :P")
    }

    directory := fmt.caprint(os.args[1])

    if !rl.DirectoryExists(directory) {
        fmt.printfln("    ERROR: '%s' is not a valid directory.", directory)
        fmt.print(USAGE_INFO)
        os.exit(1)
    }

    rl.SetTraceLogLevel(.WARNING)

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
