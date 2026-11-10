package graphics

import "core:fmt"
import "base:runtime"
import "core:c"
import rl "vendor:raylib"
import lua "vendor:lua/5.4"
import "../../lutils"

MODNAME :: "odinslove.graphics"

Graphics_Context :: struct{color: Color}

Graphics_Module_LReg :: []lua.L_Reg{
    {"clear", lua_clear},
    {"circle", lua_circle},
    {"getColor", lua_get_color},
    {"setColor", lua_set_color},
    {"newImage", lua_new_image},
    {"draw", lua_draw},
    {nil, nil},
}

open_graphics :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()

    modname := lua.L_checkstring(L, 1)

    if modname != MODNAME {
        lua.pushstring(L, fmt.caprintf("Tried to require graphics module with wrong module name ('%s' instead of '%s'", modname, MODNAME))
        lua.error(L)
    }

    register_types(L)
        
    lua.L_newlib(L, Graphics_Module_LReg)
    return 1
}

get_graphics_context :: proc "c" (L: ^lua.State) -> ^Graphics_Context {
    lua.getfield(L, lua.REGISTRYINDEX, "luaslove.graphics.graphics_context")

    if !lua.isuserdata(L, -1) { // if no graphics context exists, create one
        lua.pop(L, 1)
        graphics := cast(^Graphics_Context)(lua.newuserdatauv(L, size_of(Graphics_Context), 0))
        graphics^ = Graphics_Context{{1,1,1,1}}
        lua.setfield(L, lua.REGISTRYINDEX, "luaslove.graphics.graphics_context")
        lua.getfield(L, lua.REGISTRYINDEX, "luaslove.graphics.graphics_context")
    }

    graphics_context := cast(^Graphics_Context)lua.touserdata(L, -1)
    lua.pop(L, 1)
    if graphics_context == nil {
        lua.pushstring(L, "failed to access graphics context")
        lua.error(L)
    }

    return graphics_context
}


// requires the graphics module and pushes it onto the stack
require_graphics :: proc (L: ^lua.State) {
    lua.L_requiref(L, MODNAME, open_graphics, 0)
}

lua_clear :: proc "c" (L: ^lua.State) -> c.int {
    color : Color

    for i in 1..=4 {
        color[i-1] = f32(lua.L_optnumber(L, auto_cast i, 1)) // color defaults to white
    }

    rl.ClearBackground(rl.ColorFromNormalized(color))

    return 0
}

lua_circle :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()

    x := i32(lua.L_checkinteger(L, 2))
    y := i32(lua.L_checkinteger(L, 3))
    radius := f32(lua.L_checknumber(L, 4))

    mode := lutils.Lu_checkenum(L, 1, DrawMode, context.allocator)

    graphics_context := get_graphics_context(L)

    switch mode {
        case .line: rl.DrawCircleLines(x, y, radius, rl.ColorFromNormalized(graphics_context.color))
        case .fill: rl.DrawCircle(x, y, radius, rl.ColorFromNormalized(graphics_context.color))
    }

    return 0
}

lua_get_color :: proc "c" (L: ^lua.State) -> c.int {
    graphics_context := get_graphics_context(L)

    lua.pushnumber(L, lua.Number(graphics_context.color.r))
    lua.pushnumber(L, lua.Number(graphics_context.color.g))
    lua.pushnumber(L, lua.Number(graphics_context.color.b))
    lua.pushnumber(L, lua.Number(graphics_context.color.a))
    return 4
}

lua_set_color :: proc "c" (L: ^lua.State) -> c.int {
    graphics_context := get_graphics_context(L)

    for i in 1..=4 {
        graphics_context.color[i-1] = f32(lua.L_optnumber(L, auto_cast i, lua.Number(graphics_context.color[i-1])))
    }
    return 0
}

lua_new_image :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()
    filename := lua.L_checkstring(L, 1)

    texture := rl.LoadTexture(filename)

    image := cast(^Image)lua.newuserdata(L, size_of(Image))
    image.texture = texture
    image.filter = .linear

    lua.L_setmetatable(L, "luaslove.graphics.Image")

    return 1
}

lua_draw :: proc "c" (L: ^lua.State) -> c.int {
    image := cast(^Image)lua.L_checkudata(L, 1, "luaslove.graphics.Image")
    lua.L_argcheck(L, image == nil, 1, "missing image object");

    x :=  f32(lua.L_optnumber(L, 2,  0))
    y :=  f32(lua.L_optnumber(L, 3,  0))
    r :=  f32(lua.L_optnumber(L, 4,  0))
    sx := f32(lua.L_optnumber(L, 5,  1))
    sy := f32(lua.L_optnumber(L, 6, lua.Number(sx)))
    ox := f32(lua.L_optnumber(L, 7,  0))
    oy := f32(lua.L_optnumber(L, 8,  0))

    rl.DrawTexturePro(image.texture, 
        {0, 0, f32(image.texture.width), f32(image.texture.height)}, 
        {x, y, f32(image.texture.width) * sx, f32(image.texture.height) * sy,},
    {ox, oy}, r, rl.WHITE)
    return 0
}
