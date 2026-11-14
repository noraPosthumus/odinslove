package lutils

import "base:runtime"
import "core:fmt"
import "core:reflect"
import "core:strings"
import lua "vendor:lua/5.4"

checkenum :: proc "c" (L: ^lua.State, idx: i32, $Enum_Type: typeid) -> Enum_Type {
    context = runtime.default_context()

    options: [dynamic]cstring

    for enum_option in reflect.enum_field_names(Enum_Type) {
        append_elem(&options, strings.clone_to_cstring(enum_option, context.temp_allocator))
    }
    append_elem(&options, nil)

    result := (Enum_Type)(lua.L_checkoption(L, idx, nil, raw_data(options)))

    delete(options)

    return result
}

checkudataoftype :: proc "c" (L: ^lua.State, idx: i32, $T: typeid, modname: string) -> ^T {
    context = runtime.default_context()

    typeinfo, ok := type_info_of(T).variant.(reflect.Type_Info_Named)
    assert(ok, "Unnamed type")
    name := typeinfo.name

    value := cast(^T)lua.L_checkudata(
        L,
        idx,
        fmt.caprint(modname, ".", name, sep = "", allocator = context.temp_allocator),
    )
    lua.L_argcheck(
        L,
        value == nil,
        idx,
        fmt.caprintf("cannot access module context (%s.%s)", modname, name, allocator = context.temp_allocator),
    )

    return value
}

getmodcontext :: proc "c" (L: ^lua.State, modname: string, $T: typeid, def: Maybe(T)) -> ^T {
    context = runtime.default_context()

    typeinfo, ok := type_info_of(T).variant.(reflect.Type_Info_Named)
    assert(ok, "Tried to pass an anonymous type to getcontext.")
    name := fmt.caprint(modname, ".", typeinfo.name, sep = "", allocator = context.temp_allocator)

    lua.getfield(L, lua.REGISTRYINDEX, name)

    if !lua.isuserdata(L, -1) {
        lua.pop(L, 1)

        new_module_context := cast(^T)(lua.newuserdatauv(L, size_of(T), 0))

        switch default_value in def {
        case nil:
            new_module_context^ = {}
        case T:
            new_module_context^ = default_value
        }

        lua.setfield(L, lua.REGISTRYINDEX, name)
        lua.getfield(L, lua.REGISTRYINDEX, name)
    }

    module_context := cast(^T)lua.touserdata(L, -1)

    lua.pop(L, 1)
    if module_context == nil {
        lua.pushstring(L, "failed to access context")
        lua.error(L)
    }

    return module_context
}
