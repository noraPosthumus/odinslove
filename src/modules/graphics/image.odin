package graphics

import "base:runtime"
import "core:c"
import "core:reflect"
import "core:strings"
import "odinslove:lutils"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"

TNAME_IMAGE :: MODNAME + ".Image"

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

@(private)
new_image: lua.CFunction : proc "c" (L: ^lua.State) -> c.int {
    filename := lua.L_checkstring(L, 1)

    texture := rl.LoadTexture(filename)

    image := lutils.newuserdataoftype(L, TNAME_IMAGE, Image)
    image.texture = texture
    image.filter = .linear

    return 1
}

@(private)
image_get_dimensions : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    image := lutils.checkuserdataoftype(L, 1, TNAME_IMAGE, Image)

    lua.pushnumber(L, lua.Number(image.texture.width))
    lua.pushnumber(L, lua.Number(image.texture.height))

    return 2
}

@(private)
image_get_width : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    image := lutils.checkuserdataoftype(L, 1, TNAME_IMAGE, Image)

    lua.pushnumber(L, lua.Number(image.texture.width))
    return 1
}

@(private)
image_get_height : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    image := lutils.checkuserdataoftype(L, 1, TNAME_IMAGE, Image)

    lua.pushnumber(L, lua.Number(image.texture.height))
    return 1
}

@(private)
image_get_filter : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    context = runtime.default_context()
    image := lutils.checkuserdataoftype(L, 1, TNAME_IMAGE, Image)

    filter_mode_text := strings.clone_to_cstring(reflect.enum_string(image.filter))
    defer delete(filter_mode_text)

    lua.pushstring(L, filter_mode_text)
    return 1
}

@(private)
image_set_filter : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    image := lutils.checkuserdataoftype(L, 1, TNAME_IMAGE, Image)

    image.filter = lutils.checkenum(L, 2, FilterMode)
    rl.SetTextureFilter(image.texture, image.filter == .nearest ? .POINT : .BILINEAR)

    return 0
}

@(private)
image_get_wrap : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    context = runtime.default_context()
    image := lutils.checkuserdataoftype(L, 1, TNAME_IMAGE, Image)

    wrap_mode_text := strings.clone_to_cstring(reflect.enum_string(image.wrap))
    defer delete(wrap_mode_text)

    lua.pushstring(L, wrap_mode_text)
    return 1
}

@(private)
image_set_wrap : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    image := lutils.checkuserdataoftype(L, 1, TNAME_IMAGE, Image)

    image.wrap = lutils.checkenum(L, 2, WrapMode)
    rl.SetTextureWrap(image.texture, cast(rl.TextureWrap)image.wrap)

    return 0
}

@(private)
delete_image : lua.CFunction : proc "c" (L : ^lua.State) -> c.int {
    image := lutils.checkuserdataoftype(L, 1, TNAME_IMAGE, Image)

    rl.UnloadTexture(image.texture)
    return 0
}
