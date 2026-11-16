package generate_refrences

import rl "vendor:raylib"

main :: proc() {
    rl.SetTraceLogLevel(.NONE)

    rl.InitWindow(100, 100, "Generator")
    rl.SetTargetFPS(4)
    rl.ChangeDirectory(#directory)


    bg_texture := rl.LoadRenderTexture(100, 100)

    // basic shapes
    rl.BeginTextureMode(bg_texture)

    rl.ClearBackground(rl.GetColor(0x9dfae9ff))

    // Background Color #9DFAE9
    rl.DrawRectangle(0,0,100,100,rl.GetColor(0x9dfae9ff))

    // circle #ff0000, x=50, y=50, radius=48
    rl.DrawCircle(50, 50, 48, rl.ColorFromNormalized({1, 0, 0, 1}))

    // circle line #565EFC, x=50, y=50, radius=48, line thickness=2
    rl.DrawRing({50, 50}, 46, 48, 0, 360, 45, rl.GetColor(0x565EFCff))

    // rectangle #671F9480, x=1, y=1, width=98, height=10
    rl.DrawRectangle(1, 1, 98, 10, rl.GetColor(0x671F9480))

    // rectangle line #00000080, x=1, y=1, width=98, height=10, line thickness=1
    rl.DrawRectangleLinesEx({1, 1, 98, 10,}, 1, rl.GetColor(0x00000080))

    // line #FC8456, x1=10, y1=12, x2=60, y2=59, thickness=3
    rl.DrawLineEx({10, 12}, {60, 59}, 3, rl.GetColor(0xFC8456ff))

    rl.EndTextureMode()
    image_for_export := rl.LoadImageFromTexture(bg_texture.texture)
    rl.ImageFlipVertical(&image_for_export)
    rl.ExportImage(image_for_export, "shapes.png")
    rl.UnloadImage(image_for_export)

    rl.UnloadRenderTexture(bg_texture)
    rl.CloseWindow()
}
