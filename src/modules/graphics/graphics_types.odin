package graphics

import "core:reflect"
import "core:c"
import "core:strings"
import "base:runtime"
import rl "vendor:raylib"
import lua "vendor:lua/5.4"
import "../../lutils"

DrawMode :: enum{
    fill,
    line,
}

Color :: rl.Vector4

FilterMode :: enum{
    nearest,
    linear,
}

WrapMode :: enum{
    repeat = 0,
    clamp,
    mirroredrepeat,
    mirroredclamp,
}

Image :: struct{
    texture: rl.Texture,
    filter: FilterMode,
    wrap: WrapMode,
}

Image_Meta :: []lua.L_Reg{
    {"getDimensions", lua_image_get_dimensions},
    {"getHeight", lua_image_get_height},
    {"getWidth", lua_image_get_width},
    {"getFilter", lua_image_get_filter},
    {"setFilter", lua_image_set_filter},
    {"getWrap", lua_image_get_wrap},
    {"setWrap", lua_image_set_wrap},
    {nil, nil},
}

register_types :: proc(L: ^lua.State) {

    // image
    lua.L_newmetatable(L, "odinslove.graphics.Image")
    lua.pushcfunction(L, delete_image)
    lua.setfield(L, -2, "__gc")
    lua.pushvalue(L, -1)
    lua.setfield(L, -2, "__index")

    lua.L_setfuncs(L, raw_data(Image_Meta), 0)

    lua.pop(L, 1)
}

lua_image_get_dimensions :: proc "c" (L: ^lua.State) -> c.int {
    image := cast(^Image)lua.L_checkudata(L, 1, "odinslove.graphics.Image")
    lua.L_argcheck(L, image == nil, 1, "missing image object");

    lua.pushnumber(L, lua.Number(image.texture.width))
    lua.pushnumber(L, lua.Number(image.texture.height))

    return 2
}

lua_image_get_width :: proc "c" (L: ^lua.State) -> c.int {
    image := cast(^Image)lua.L_checkudata(L, 1, "odinslove.graphics.Image")
    lua.L_argcheck(L, image == nil, 1, "missing image object");

    lua.pushnumber(L, lua.Number(image.texture.width))
    return 1
}

lua_image_get_height :: proc "c" (L: ^lua.State) -> c.int {
    image := cast(^Image)lua.L_checkudata(L, 1, "odinslove.graphics.Image")
    lua.L_argcheck(L, image == nil, 1, "missing image object");

    lua.pushnumber(L, lua.Number(image.texture.height))
    return 1
}

lua_image_get_filter :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()
    image := cast(^Image)lua.L_checkudata(L, 1, "odinslove.graphics.Image")
    lua.L_argcheck(L, image == nil, 1, "missing image object");

    filter_mode_text := strings.clone_to_cstring(reflect.enum_string(image.filter))
    defer delete(filter_mode_text)

    lua.pushstring(L, filter_mode_text )
    return 1
}

lua_image_set_filter :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()
    image := cast(^Image)lua.L_checkudata(L, 1, "odinslove.graphics.Image")
    lua.L_argcheck(L, image == nil, 1, "missing image object");

    image.filter = lutils.Lu_checkenum(L, 2, FilterMode, context.allocator)
    rl.SetTextureFilter(image.texture, image.filter == .nearest ? .POINT : .BILINEAR)

    return 0
}

lua_image_get_wrap:: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()
    image := cast(^Image)lua.L_checkudata(L, 1, "odinslove.graphics.Image")
    lua.L_argcheck(L, image == nil, 1, "missing image object");

    wrap_mode_text := strings.clone_to_cstring(reflect.enum_string(image.wrap))
    defer delete(wrap_mode_text)

    lua.pushstring(L, wrap_mode_text )
    return 1
}

lua_image_set_wrap :: proc "c" (L: ^lua.State) -> c.int {
    context = runtime.default_context()
    image := cast(^Image)lua.L_checkudata(L, 1, "odinslove.graphics.Image")
    lua.L_argcheck(L, image == nil, 1, "missing image object");

    image.wrap = lutils.Lu_checkenum(L, 2, WrapMode, context.allocator)
    rl.SetTextureWrap(image.texture, cast(rl.TextureWrap)image.wrap)

    return 0
}

delete_image :: proc "c" (L: ^lua.State) -> c.int {
    image := cast(^Image)lua.L_checkudata(L, 1, "odinslove.graphics.Image")
    lua.L_argcheck(L, image == nil, 1, "missing image object");

    rl.UnloadTexture(image.texture)
    return 0
}
