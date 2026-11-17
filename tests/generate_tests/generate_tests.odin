package generate_tests

import "core:fmt"
import "core:math/rand"
import "core:os"
import "core:strings"
import rl "vendor:raylib"

SHAPES :: enum {
    CIRCLE,
    CIRCLE_LINE,
    RECTANGLE,
    RECTANGLE_LINE,
    LINE,
}

snippet__header :: """
package tests

import \"core:testing\"
import lua \"vendor:lua/5.4\"
import rl \"vendor:raylib\"
import ol \"odinslove:core\"

// The following test cases are automatically generated.
// You can regenerate them by running `odin run tests/generate_tests`.

"""


snippet__call_craw_on_rendertexture :: """
    screen_texture := rl.LoadRenderTexture(100, 100)
    rl.BeginTextureMode(screen_texture)
        ol.draw(L)
    rl.EndTextureMode()
    screen := rl.LoadImageFromTexture(screen_texture.texture)
    rl.ImageFlipVertical(&screen)

"""


main :: proc() {

    test_file, ok := os.open(#directory + "../generated__basic_shapes.odin", {.Create, .Write})
    if ok != nil do panic("Failed to open or create test file")

    fmt.fprint(test_file, snippet__header)

    // prepare buffer for writing to files
    buffer : strings.Builder
    strings.builder_init(&buffer)

    rl.SetTraceLogLevel(.WARNING)

    rl.InitWindow(100, 100, "Generator")
    rl.SetTargetFPS(60)

    // basic shapes
    if !rl.DirectoryExists(#directory + "../resources/basic_shapes") do rl.MakeDirectory(#directory + "../resources/basic_shapes")

    rl.ChangeDirectory(#directory + "../resources/basic_shapes")

    for i in 1 ..= 3 {
        for shape in SHAPES {
            generate_random_shape(i, shape)

            fmt.fprint(test_file, "\n@(test)\n")
            fmt.fprintfln(
                test_file,
                "draw_%s_%d :: proc(t: ^testing.T) {{",
                strings.to_lower(fmt.enum_value_to_string(shape) or_else "unknown_shape"),
                i,
            )
            fmt.fprintln(test_file, "    L := prepare()")
            fmt.fprintln(test_file, "    defer cleanup(L)")
            fmt.fprintfln(
                test_file,
                "    refrence_image := rl.LoadImage(#directory + \"resources/basic_shapes/generated__%3d_%s.png\")",
                i,
                shape,
            )
            fmt.fprintfln(
                test_file,
                "    lua.L_dofile(L, #directory + \"resources/basic_shapes/generated__%3d_%s.lua\")",
                i,
                shape,
            )
            fmt.fprint(test_file, snippet__call_craw_on_rendertexture)
            fmt.fprintln(test_file, "    expect_images_to_match(t, screen, refrence_image)")
            fmt.fprintln(test_file, "}")
        }
    }


    rl.CloseWindow()
}

random_color :: proc() -> rl.Color {
    r := u8(rand.uint32_range(0, 256))
    g := u8(rand.uint32_range(0, 256))
    b := u8(rand.uint32_range(0, 256))
    a := u8(rand.uint32_range(128, 256))
    return {r, g, b, a}
}

generate_random_shape :: proc(i: int, shape : SHAPES) {
    bg_color := rl.ColorAlpha(random_color(), 1)
    fg_color := random_color()
    width := rand.float32_range(0, 100)
    height := (shape == .CIRCLE || shape == .CIRCLE_LINE) ? width : rand.float32_range(0, 100)
    x := rand.int32_range(auto_cast (width / 2), auto_cast (100 - (width / 2)))
    y := rand.int32_range(auto_cast (height / 2), auto_cast (100 - (height / 2)))
    thickness := rand.float32_range(0.1, 10)

    bg_texture := rl.LoadRenderTexture(100, 100)

    rl.BeginTextureMode(bg_texture)
    rl.ClearBackground(bg_color)
    switch shape {
    case .CIRCLE: rl.DrawCircle(x, y, width, fg_color)
    case .CIRCLE_LINE: rl.DrawRing({auto_cast x, auto_cast y}, width - thickness, width, 0, 360, 45, fg_color)
    case .RECTANGLE: rl.DrawRectanglePro({auto_cast x, auto_cast y, width, height}, {0,0}, 0, fg_color)
    case .RECTANGLE_LINE: rl.DrawRectangleLinesEx({auto_cast x, auto_cast y, width, height}, thickness, fg_color)
    case .LINE:
        rl.DrawLineEx({auto_cast x, auto_cast y}, {auto_cast x + width, auto_cast y + height}, thickness, fg_color)
    }
    rl.EndTextureMode()

    // export generated image
    image_for_export := rl.LoadImageFromTexture(bg_texture.texture)
    rl.ImageFlipVertical(&image_for_export)
    rl.ExportImage(image_for_export, fmt.caprintf("generated__%3d_%s.png", i, shape))
    rl.UnloadImage(image_for_export)
    rl.UnloadRenderTexture(bg_texture)

    // generate lua code
    buffer : strings.Builder
    strings.builder_init(&buffer)

    bg_color_normalized := rl.ColorNormalize(bg_color)
    fg_color_normalized := rl.ColorNormalize(fg_color)

    fmt.sbprintln(&buffer, "function odinslove.draw()")
    fmt.sbprintfln(
        &buffer,
        "   odinslove.graphics.clear(%g, %g, %g, %g)",
        bg_color_normalized.r,
        bg_color_normalized.g,
        bg_color_normalized.b,
        bg_color_normalized.a,
    )
    fmt.sbprintfln(
        &buffer,
        "   odinslove.graphics.setColor(%g, %g, %g, %g)",
        fg_color_normalized.r,
        fg_color_normalized.g,
        fg_color_normalized.b,
        fg_color_normalized.a,
    )

    switch shape {
    case .CIRCLE: fmt.sbprintfln(&buffer, "   odinslove.graphics.circle(\"fill\", %d, %d, %g)", x, y, width)
    case .CIRCLE_LINE:
        fmt.sbprintfln(&buffer, "   odinslove.graphics.setLineWidth(%g)", thickness)
        fmt.sbprintfln(&buffer, "   odinslove.graphics.circle(\"line\", %d, %d, %g)", x, y, width)
    case .RECTANGLE:
        fmt.sbprintfln(&buffer, "   odinslove.graphics.rectangle(\"fill\", %d, %d, %g, %g)", x, y, width, height)
    case .RECTANGLE_LINE:
        fmt.sbprintfln(&buffer, "   odinslove.graphics.setLineWidth(%g)", thickness)
        fmt.sbprintfln(&buffer, "   odinslove.graphics.rectangle(\"line\", %d, %d, %g, %g)", x, y, width, height)
    case .LINE:
        fmt.sbprintfln(&buffer, "   odinslove.graphics.setLineWidth(%g)", thickness)
        fmt.sbprintfln(&buffer, "   odinslove.graphics.line(%d, %d, %g, %g)", x, y, f32(x) + width, f32(y) + height)
    }
    fmt.sbprintln(&buffer, "end")
    strings.write_rune(&buffer, 0)
    rl.SaveFileText(fmt.caprintf("generated__%3d_%s.lua", i, shape), raw_data(buffer.buf))
}
