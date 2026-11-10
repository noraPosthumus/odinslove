package lutils

import "base:runtime"
import "core:reflect"
import "core:strings"
import lua "vendor:lua/5.4"

Lu_checkenum :: proc(L: ^lua.State, idx: i32, $Enum_Type: typeid, allocator: runtime.Allocator) -> Enum_Type {
    options := make([dynamic]cstring, allocator)
    defer delete(options)

    for enum_option in reflect.enum_field_names(Enum_Type) {
        append_elem(&options, strings.clone_to_cstring(enum_option, allocator))
    }
    append_elem(&options, nil)

    result := (Enum_Type)(lua.L_checkoption(L, idx, nil, raw_data(options)))

    for option in options do delete(option, allocator)

    return result
}
