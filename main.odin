package main

import "core:log"
import "core:fmt"
import "core:os"
import "core:flags"

import ol "odinslove:core"

import rl "vendor:raylib"

Options :: struct {
    game_directory: cstring `args:"pos=0,required" usage:"Path to the odinslove project to play"`,
    fullscreen: bool,
    target_fps: int,
}

USAGE_INFO :: """

    usage: odinslove <game-directory> [--fullscreen] [--target-fps <fps>] 

    Play the odinslove project located at <game-directory>.

    -h, --help              Print this usage information
    --fullscreen            Start the game in fullscreen mode
    --target-fps            Set the games target framerate (in frames per second)

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

    options: Options
	style : flags.Parsing_Style = .Unix
    errors := flags.parse(&options, os.args[1:], style)

    if errors != nil {
        switch error in errors {
        case flags.Parse_Error:
            log.logf(.Fatal, "%v: %s", error.reason, error.message)
        case flags.Open_File_Error:
            log.logf(.Fatal, "Encountered an unexpected error while trying to parse command line arguments.")
        case flags.Help_Request:
            fmt.print(USAGE_INFO)
        case flags.Validation_Error:
            fmt.println("   ", error.message, "")
            fmt.print(USAGE_INFO)
        }
        os.exit(1)
    }

    rl.SetTraceLogLevel(.WARNING)

    if !rl.DirectoryExists(options.game_directory) {
        fmt.printfln("Can't find game. '%s' isn't a valid directory.", options.game_directory)
        os.exit(1)
    }

    rl.ChangeDirectory(options.game_directory)

    rl.InitWindow(800, 600, "Odinslove")

    if options.fullscreen && !rl.IsWindowFullscreen() {
        rl.ToggleFullscreen()
    }

    rl.InitAudioDevice()

    rl.SetTargetFPS(options.target_fps > 0 ? i32(options.target_fps) : 60)

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
