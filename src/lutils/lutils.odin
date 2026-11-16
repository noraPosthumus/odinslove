package lutils

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:reflect"
import "core:strings"
import lua "vendor:lua/5.4"

// checkenum reads the string argument at idx and converts it to a value of Enum_Type.
// The accepted strings are the enum's field names. Raises
// an argument error when the value at idx is not one of those names.
//
// Returns the enum value corresponding to the supplied field name.
checkenum :: proc "contextless" (L: ^lua.State, idx: c.int, $Enum_Type: typeid) -> Enum_Type {
    context = runtime.default_context()

    options: [dynamic]cstring

    for enum_option in reflect.enum_field_names(Enum_Type) {
        append_elem(&options, strings.clone_to_cstring(enum_option, context.temp_allocator))
    }
    append_elem(&options, nil)

    result_idx := (Enum_Type)(lua.L_checkoption(L, idx, nil, raw_data(options)))
    result, ok := reflect.enum_from_name(Enum_Type, string(options[result_idx]))
    lua.L_argcheck(
        L,
        !ok,
        idx,
        fmt.caprintf("Failed to parse enum value %s.", options[result_idx], allocator = context.temp_allocator),
    )
    delete(options)

    return result
}

// Retrieves argument at idx as a pointer to T. The argument must be of type userdata.
// Raises an argument error if the value at idx is not userdata matching the specified type T.
// Typechecking is done by accessing the userdatas "meta.__name" against "modname.type" where type is the
// reflected name of T (This means T must be a named type!).
checkudataoftype :: proc "contextless" (L: ^lua.State, idx: c.int, $T: typeid, modname: string) -> ^T {
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

// Gets the module-specific context userdata stored in the Lua registry under the key "modname.type" where type is the
// reflected name of T (This means T must be a named type!).
// If no context data is found it initializes a new one with a default value of def.
//
// Example:
// 	L := lua.newstate()
// 	MyModuleContext :: struct{
// 		value: int
// 	}
// 	context := lutils.getmodcontext(L, "myModule", MyModuleContext, {5})
// 	fmt.printfln("%d", context.value) // 5
getmodcontext :: proc "contextless" (L: ^lua.State, modname: string, $T: typeid, def: Maybe(T)) -> ^T {
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

// Creates and returns a new refrences to the object on top of the stack in the table at t (and pops the object). Because this creates a weak refrence,
// the object isn't kept alive by this refrence. If no other refrences to the object exist, luas garbage collector can collect it.
// To retrieve an object from a weak refrence, use "lutils.getweakref".
weakref :: proc "contextless" (L: ^lua.State, t: c.int=lua.REGISTRYINDEX) -> c.int {
    // create container +1
    lua.newtable(L)

    // create metatable +0
    lua.newtable(L)
    lua.pushliteral(L, "v")
    lua.setfield(L, -2, "__mode")
    lua.setmetatable(L, -2)
    
    lua.pushvalue(L, -2)
    lua.rawseti(L, -2, 1)
    refrence := lua.L_ref(L, t)
    lua.pop(L, 1)

    return refrence
}

// Releases a reference in t, previously created by calling weakref.
weakunref :: proc "contextless" (L: ^lua.State, t: c.int=lua.REGISTRYINDEX, ref: c.int) {
    lua.L_unref(L, t, ref)
}

// Pushes onto the stack the value that a weak refrence, created using *lutils.weakref* points to.
// t is the index to the table the refrence was created in.
// Returns the type of the pushed value.
getweakref :: proc "contextless" (L: ^lua.State, t: c.int=lua.REGISTRYINDEX, ref: c.int) -> lua.Type {
    lua.rawgeti(L, t, lua.Integer(ref))
    resulting_type := lua.rawgeti(L, -1, 1)
    lua.remove(L, lua.gettop(L) - 1) // remove the outer table from the stack

    return lua.Type(resulting_type)
}
