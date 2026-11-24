---@meta input

---@alias GamepadButton "a" | "b" | "x" | "y" | "back" | "guide" | "start" | "leftstick" | "rightstick" | "leftshoulder" | "lefttrigger" | "rightshoulder" | "righttrigger" | "dpup" | "dpdown" | "dpleft" | "dpright"

---@class Gamepad
Gamepad = {}

---@param duration number # duration of the vibration in seconds
---@param left any # left motor intensity
---@param right? any # right motor intensity (defaults to left)
function Gamepad:setVibration( duration, left, right ) end

---@return string
function Gamepad:getName() end

---@return integer
function Gamepad:getID() end

---@return boolean
function Gamepad:isConnected() end

---@return integer
function Gamepad:getAxisCount() end

---@param axis integer
---@return number
function Gamepad:getAxis( axis ) end

---@return number ...
function Gamepad:getAxes() end

---@param button GamepadButton
---@param ... GamepadButton
---@return boolean
function Gamepad:isDown( button, ... ) end

---@param button GamepadButton
---@param ... GamepadButton
---@return boolean
function Gamepad:isUp( button, ... ) end

---@class input
local input = {}

---@alias KeyConstant "'" | "," | "-" | "." | "/" | "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | ";" | "=" | "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z" | "[" | "\\" | "]" | "`" | " " | "escape" | "enter" | "tab" | "backspace" | "insert" | "delete" | "right" | "left" | "down" | "up" | "pageup" | "pagedown" | "apphome" | "end" | "capslock" | "scrolllock" | "numlock" | "printscreen" | "pause" | "f1" | "f2" | "f3" | "f4" | "f5" | "f6" | "f7" | "f8" | "f9" | "f10" | "f11" | "f12" | "lshift" | "lctrl" | "lalt" | "lgui" | "rshift" | "rctrl" | "ralt" | "rgui" | "menu" | "kp0" | "kp1" | "kp2" | "kp3" | "kp4" | "kp5" | "kp6" | "kp7" | "kp8" | "kp9" | "kp." | "kp/" | "kp*" | "kp-" | "kp+" | "kpenter" | "kp=" | "" | "back" | "volume+" | "volume-" | "menu"

---@param key KeyConstant
---@param ... KeyConstant
---@return boolean
function input.isKeyDown( key, ... ) end

---@param key KeyConstant
---@param ... KeyConstant
---@return boolean
function input.isKeyUp( key, ... ) end

---@return table<integer, Gamepad> # List of all available gamepads.
function input.getGamepads() end

return input
