package odinslove

import "base:runtime"
import "core:strings"
import "core:c"
import "core:fmt"
import "core:os"
import lua "vendor:lua/5.4"
import rl "vendor:raylib"
import graphics "modules/graphics"

Args :: struct {
	gamedir: string
}

main :: proc() {

	args := parse_args(context.allocator)
	defer free(args)
	
	rl.InitWindow(800, 600, "Odinslove")

	L := init_lua()

	result := lua.L_dofile(L, fmt.caprintf("%s/main.lua", args.gamedir))
	
	if result != c.int(lua.Status.OK) {
		error := lua.tostring(L, -1)
		rl.TraceLog(.ERROR, error)

        lua.pop(L, 1)
	}
	
	call_load(L)

	for !rl.WindowShouldClose() {
		call_update(L, rl.GetFrameTime())
		rl.BeginDrawing()
			call_draw(L)
		rl.EndDrawing()
	}

	call_quit(L)

	rl.CloseWindow()
}

parse_args :: proc(allocator: runtime.Allocator) -> ^Args {
	if len(os.args) < 2 do panic("Missing path to game files")
	result := new(Args, allocator)
	result.gamedir = os.args[1]
	return result
}

init_lua :: proc() -> ^lua.State {
	L := lua.L_newstate()

	lua.open_base(L)

	lua.newtable(L)

	graphics.require_graphics(L)
	lua.setfield(L, -2, "graphics")

	lua.setglobal(L, "odinslove")
	return L
}

call_load :: proc(L: ^lua.State) {
	lua.getglobal(L, "odinslove")
	lua.getfield(L, -1, "load")
	if lua.isfunction(L, -1) {
		err := lua.pcall(L, 0, 0, 0)
		if int(err) != int(lua.OK) {
			msg := lua.tostring(L, -1)
			lua.pop(L, 1)
			rl.TraceLog(.ERROR, "Lua Error : %s", msg)
		}
	}
	lua.pop(L, 1)
}

call_update :: proc(L: ^lua.State, delta_time: f32) {
	lua.getglobal(L, "odinslove")
	lua.getfield(L, -1, "update")
	if lua.isfunction(L, -1) {
		lua.pushnumber(L, lua.Number(delta_time))
		err := lua.pcall(L, 1, 0, 0)
		if int(err) != int(lua.OK) {
			msg := lua.tostring(L, -1)
			lua.pop(L, 1)
			rl.TraceLog(.ERROR, "Lua Error : %s", msg)
		}
	}
	lua.pop(L, 1)
}

call_draw :: proc(L: ^lua.State) {
	lua.getglobal(L, "odinslove")
	lua.getfield(L, -1, "draw")
	if lua.isfunction(L, -1) {
		err := lua.pcall(L, 0, 0, 0)
		if int(err) != int(lua.OK) {
			msg := lua.tostring(L, -1)
			lua.pop(L, 1)
			rl.TraceLog(.ERROR, "Lua Error : %s", msg)
		}
	}
	lua.pop(L, 1)
}

call_quit :: proc(L: ^lua.State) {
	lua.getglobal(L, "odinslove")
	lua.getfield(L, -1, "quit")
	if lua.isfunction(L, -1) {
		err := lua.pcall(L, 0, 0, 0)
		if int(err) != int(lua.OK) {
			msg := lua.tostring(L, -1)
			lua.pop(L, 1)
			rl.TraceLog(.ERROR, "Lua Error : %s", msg)
		}
	}
	lua.pop(L, 1)
	lua.close(L)
}
