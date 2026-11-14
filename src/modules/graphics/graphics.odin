package graphics

import "core:strings"
import "../../lutils"
import "base:runtime"
import "core:c"
import "core:fmt"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

MODNAME :: "odinslove.graphics"

Graphics_Context :: struct {
    color: Color, // the currently active color, can be set from within lua by calling `odinslove.graphics.setColor()`
    line_width: f32,
}

@(private)
Graphics_Module_Library :: []lua.L_Reg {
    {"clear", clear},
    {"circle", circle},
    {"getColor", get_color},
    {"setColor", set_color},
    {"newImage", new_image},
    {"draw", draw},
    {"line", line},
    {"getLineWidth", get_line_width},
    {"setLineWidth", set_line_width},
    {"rectangle", rectangle},
    {"print", print},
    {"printf", printf},
    {"newFont", new_font},
    {"getDimensions", get_dimensions},
    {"getWidth", get_width},
    {"getHeight", get_height},
    {nil, nil},
}

// requires the graphics module and pushes it onto the stack.
require_graphics :: proc(L: ^lua.State) {
    lua.L_requiref(L, MODNAME, open_graphics, 0)
}

// Get the current graphics context. If no context exists, this creates a new one.
get_graphics_context :: proc "c" (L: ^lua.State) -> ^Graphics_Context {
    lua.getfield(L, lua.REGISTRYINDEX, "odinslove.graphics.graphics_context")

    // if no graphics context exists, create one
    if !lua.isuserdata(L, -1) {
        lua.pop(L, 1)

        // the graphics context is full userdata
        graphics := cast(^Graphics_Context)(lua.newuserdatauv(L, size_of(Graphics_Context), 0))

        // {1, 1, 1, 1} => white
        graphics^ = Graphics_Context{{1, 1, 1, 1}, 1}
        lua.setfield(L, lua.REGISTRYINDEX, "odinslove.graphics.graphics_context")
        lua.getfield(L, lua.REGISTRYINDEX, "odinslove.graphics.graphics_context")
    }

    graphics_context := cast(^Graphics_Context)lua.touserdata(L, -1)

    // pop the graphics context from the stack so the function is balanced (doesn't remove or add to the stack)
    lua.pop(L, 1)
    if graphics_context == nil {
        lua.pushstring(L, "failed to access graphics context")
        lua.error(L)
    }

    return graphics_context
}

@(private)
open_graphics: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()

    modname := lua.L_checkstring(L, 1)

    if modname != MODNAME {
        lua.pushstring(
            L,
            fmt.caprintf(
                "Tried to require graphics module with wrong module name ('%s' instead of '%s'",
                modname,
                MODNAME,
            ),
        )
        lua.error(L)
    }

    register_types(L)

    lua.L_newlib(L, Graphics_Module_Library)
    return 1
}

@(private)
clear: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    color: Color

    for i in 1 ..= 4 {
        color[i - 1] = f32(lua.L_optnumber(L, auto_cast i, 1)) // color defaults to white
    }

    rl.ClearBackground(rl.ColorFromNormalized(color))

    return 0
}

@(private)
circle: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    x := f32(lua.L_checknumber(L, 2))
    y := f32(lua.L_checknumber(L, 3))
    radius := f32(lua.L_checknumber(L, 4))

    mode := lutils.Lu_checkenum(L, 1, DrawMode)

    graphics_context := get_graphics_context(L)

    switch mode {
    case .line:
        rl.DrawCircleLinesV({x, y,}, radius, rl.ColorFromNormalized(graphics_context.color))
    case .fill:
        rl.DrawCircleV({x, y,}, radius, rl.ColorFromNormalized(graphics_context.color))
    }

    return 0
}

@(private)
rectangle: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    x := f32(lua.L_checknumber(L, 2))
    y := f32(lua.L_checknumber(L, 3))
    width := f32(lua.L_checknumber(L, 4))
    height := f32(lua.L_optnumber(L, 5, auto_cast width))
    roundness := f32(lua.L_optnumber(L, 6, 0))
    segments := i32(lua.L_optinteger(L, 7, 1))

    mode := lutils.Lu_checkenum(L, 1, DrawMode)

    graphics_context := get_graphics_context(L)

    switch mode {
    case .line:
        rl.DrawRectangleRoundedLinesEx({x, y, width, height,}, roundness, segments, graphics_context.line_width, rl.ColorFromNormalized(graphics_context.color))
    case .fill:
        rl.DrawRectangleRounded({x, y, width, height,}, roundness, segments, rl.ColorFromNormalized(graphics_context.color))
    }

    return 0
}

@(private)
line: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    x1 := f32(lua.L_checknumber(L, 1))
    y1 := f32(lua.L_checknumber(L, 2))
    x2 := f32(lua.L_checknumber(L, 3))
    y2 := f32(lua.L_checknumber(L, 4))

    graphics_context := get_graphics_context(L)

    rl.DrawLineEx({x1, y1,}, {x2, y2,}, graphics_context.line_width, rl.ColorFromNormalized(graphics_context.color))

    return 0
}

@(private)
print: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    text := lua.L_checkstring(L, 1)

    x := f32(lua.L_checknumber(L, 2))
    y := f32(lua.L_checknumber(L, 3))
    fontsize := f32(lua.L_optnumber(L, 4, 16))
    spacing := f32(lua.L_optnumber(L, 5, 1))
    font := lua.L_opt(L, proc "c" (L: ^lua.State, arg: c.int) -> rl.Font { return lutils.Lu_checkudataoftype(L, arg, rl.Font, MODNAME)^ }, 6, rl.GetFontDefault())
    r := f32(lua.L_optnumber(L, 7, 0))
    ox := f32(lua.L_optnumber(L, 8, 0))
    oy := f32(lua.L_optnumber(L, 9, 0))

    graphics_context := get_graphics_context(L)

    rl.DrawTextPro(font, text, {x, y,}, {ox, oy,}, r, fontsize, spacing, rl.ColorFromNormalized(graphics_context.color) )

    return 0
}

@(private)
printf: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()
    graphics_context := get_graphics_context(L)

    text := lua.L_checkstring(L, 1)
    x := f32(lua.L_checknumber(L, 2))
    y := f32(lua.L_checknumber(L, 3))
    limit := f32(lua.L_checknumber(L, 4))
    align := lutils.Lu_checkenum(L, 5, AlignMode)
    fontsize := f32(lua.L_optnumber(L, 6, 16))
    spacing := f32(lua.L_optnumber(L, 7, 1))
    font := lua.L_opt(L, proc "c" (L: ^lua.State, arg: c.int) -> rl.Font { return lutils.Lu_checkudataoftype(L, arg, rl.Font, MODNAME)^ }, 8, rl.GetFontDefault())
    r := f32(lua.L_optnumber(L, 9, 0))
    ox := f32(lua.L_optnumber(L, 10, 0))
    oy := f32(lua.L_optnumber(L, 11, 0))
    line_height := rl.MeasureTextEx(font, "X", fontsize, spacing).y + 2 * spacing

    Line :: struct{width: f32, content: cstring}
    lines := make([dynamic]Line, context.temp_allocator)
    text_as_string := string(text)

    for word in strings.split_after_iterator(&text_as_string, " ") {
        word_as_cstring := strings.clone_to_cstring(word, context.temp_allocator)
        word_width := rl.MeasureTextEx(font, word_as_cstring, fontsize, spacing).x

        if len(lines) < 1 || lines[len(lines)-1].width + word_width >= limit {
            append_elem(&lines, {word_width, word_as_cstring})
            continue
        }
        current_line := &lines[len(lines)-1]
        current_line.width += word_width
        current_line.content = fmt.caprint(current_line.content, word_as_cstring, sep="", allocator=context.temp_allocator)
    }

    for line, i in lines {
        line_x : f32
        line_y := y + f32(i) * line_height
        switch align {
        case .left:
            line_x = x
        case .right:
            line_x += limit - line.width
        case .center:
            line_x += (limit - line.width) / 2
        }
        rl.DrawTextPro(font, line.content, {line_x, line_y,}, {ox, oy,}, r, fontsize, spacing, rl.ColorFromNormalized(graphics_context.color))
    }

    return 0
}

@(private)
set_line_width: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    width := lua.L_checknumber(L, 1)
    graphics_context := get_graphics_context(L)
    graphics_context.line_width = auto_cast width
    return 0
}

@(private)
get_line_width: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    graphics_context := get_graphics_context(L)
    lua.pushnumber(L, auto_cast graphics_context.line_width)
    return 1
}

@(private)
get_color: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    graphics_context := get_graphics_context(L)

    lua.pushnumber(L, lua.Number(graphics_context.color.r))
    lua.pushnumber(L, lua.Number(graphics_context.color.g))
    lua.pushnumber(L, lua.Number(graphics_context.color.b))
    lua.pushnumber(L, lua.Number(graphics_context.color.a))
    return 4
}

@(private)
set_color: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    graphics_context := get_graphics_context(L)

    if lua.istable(L, 1) {
        for i in 1 ..= 4 {
            lua.geti(L, 1, auto_cast i)
            graphics_context.color[i - 1] = f32(lua.tointeger(L, -1))
            lua.pop(L, 1)
        }
        return 0
    }

    for i in 1 ..= 4 {
        graphics_context.color[i - 1] = f32(lua.L_optnumber(L, auto_cast i, lua.Number(graphics_context.color[i - 1])))
    }
    return 0
}

@(private)
new_image: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    filename := lua.L_checkstring(L, 1)

    texture := rl.LoadTexture(filename)

    image := cast(^Image)lua.newuserdata(L, size_of(Image))
    image.texture = texture
    image.filter = .linear

    lua.L_setmetatable(L, "odinslove.graphics.Image")

    return 1
}


@(private)
new_font: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    filename := lua.L_checkstring(L, 1)

    font := rl.LoadFont(filename)

    font_userdata := cast(^Font)lua.newuserdata(L, size_of(Font))
    font_userdata^ = font

    lua.L_setmetatable(L, "odinslove.graphics.Font")

    return 1
}

@(private)
draw: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    image := cast(^Image)lua.L_checkudata(L, 1, "odinslove.graphics.Image")
    lua.L_argcheck(L, image == nil, 1, "missing image object")

    x := f32(lua.L_optnumber(L, 2, 0))
    y := f32(lua.L_optnumber(L, 3, 0))
    r := f32(lua.L_optnumber(L, 4, 0))
    sx := f32(lua.L_optnumber(L, 5, 1))
    sy := f32(lua.L_optnumber(L, 6, lua.Number(sx)))
    ox := f32(lua.L_optnumber(L, 7, 0))
    oy := f32(lua.L_optnumber(L, 8, 0))

    rl.DrawTexturePro(
        image.texture,
        {0, 0, f32(image.texture.width), f32(image.texture.height)},
        {x, y, f32(image.texture.width) * sx, f32(image.texture.height) * sy},
        {ox, oy},
        r,
        rl.WHITE,
    )
    return 0
}

get_dimensions: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    lua.pushinteger(L, auto_cast rl.GetScreenWidth())
    lua.pushinteger(L, auto_cast rl.GetScreenHeight())
    return 2
}

get_width: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    lua.pushinteger(L, auto_cast rl.GetScreenWidth())
    return 1
}

get_height: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    lua.pushinteger(L, auto_cast rl.GetScreenHeight())
    return 1
}

