package graphics

import "base:runtime"
import "core:c"
import "core:reflect"
import "core:strings"
import "odinslove:lutils"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

DrawMode :: enum {
    fill,
    line,
}

Color :: rl.Vector4

FilterMode :: enum {
    nearest,
    linear,
}

WrapMode :: enum {
    repeat = 0,
    clamp,
    mirroredrepeat,
    mirroredclamp,
}

AlignMode :: enum {
    left,
    center,
    right,
}

Image :: struct {
    texture : rl.Texture,
    filter :  FilterMode,
    wrap :    WrapMode,
}

@(private)
Image_Methods :: []lua.L_Reg {
    {"getDimensions", image_get_dimensions},
    {"getHeight", image_get_height},
    {"getWidth", image_get_width},
    {"getFilter", image_get_filter},
    {"setFilter", image_set_filter},
    {"getWrap", image_get_wrap},
    {"setWrap", image_set_wrap},
    {"__gc", delete_image},
    {nil, nil},
}

Font :: rl.Font

Font_Methods :: []lua.L_Reg {
    {"__gc", delete_font},
    {nil,nil},
}

// Register all types defined by the graphics module
register_types :: proc "c" (L : ^lua.State) {

    // Image
    lua.L_newmetatable(L, "odinslove.graphics.Image")
    lua.pushvalue(L, -1)
    lua.setfield(L, -2, "__index")

    lua.L_setfuncs(L, raw_data(Image_Methods), 0)

    lua.pop(L, 1)

    // Font
    lua.L_newmetatable(L, "odinslove.graphics.Font")
    lua.pushvalue(L, -1)
    lua.setfield(L, -2, "__index")

    lua.L_setfuncs(L, raw_data(Font_Methods), 0)

    lua.pop(L, 1)
}

@(private)
image_get_dimensions : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    image := lutils.Lu_checkudataoftype(L, 1, Image, MODNAME)

    lua.pushnumber(L, lua.Number(image.texture.width))
    lua.pushnumber(L, lua.Number(image.texture.height))

    return 2
}

@(private)
image_get_width : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    image := lutils.Lu_checkudataoftype(L, 1, Image, MODNAME)

    lua.pushnumber(L, lua.Number(image.texture.width))
    return 1
}

@(private)
image_get_height : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    image := lutils.Lu_checkudataoftype(L, 1, Image, MODNAME)

    lua.pushnumber(L, lua.Number(image.texture.height))
    return 1
}

@(private)
image_get_filter : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    context = runtime.default_context()
    image := lutils.Lu_checkudataoftype(L, 1, Image, MODNAME)

    filter_mode_text := strings.clone_to_cstring(reflect.enum_string(image.filter))
    defer delete(filter_mode_text)

    lua.pushstring(L, filter_mode_text)
    return 1
}

@(private)
image_set_filter : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    image := lutils.Lu_checkudataoftype(L, 1, Image, MODNAME)

    image.filter = lutils.Lu_checkenum(L, 2, FilterMode)
    rl.SetTextureFilter(image.texture, image.filter == .nearest ? .POINT : .BILINEAR)

    return 0
}

@(private)
image_get_wrap : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    context = runtime.default_context()
    image := lutils.Lu_checkudataoftype(L, 1, Image, MODNAME)

    wrap_mode_text := strings.clone_to_cstring(reflect.enum_string(image.wrap))
    defer delete(wrap_mode_text)

    lua.pushstring(L, wrap_mode_text)
    return 1
}

@(private)
image_set_wrap : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    image := lutils.Lu_checkudataoftype(L, 1, Image, MODNAME)

    image.wrap = lutils.Lu_checkenum(L, 2, WrapMode)
    rl.SetTextureWrap(image.texture, cast(rl.TextureWrap)image.wrap)

    return 0
}

@(private)
delete_image : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    image := lutils.Lu_checkudataoftype(L, 1, Image, MODNAME)

    rl.UnloadTexture(image.texture)
    return 0
}

@(private)
delete_font : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    font := lutils.Lu_checkudataoftype(L, 1, Font, MODNAME)

    rl.UnloadFont(font^)
    return 0
}
