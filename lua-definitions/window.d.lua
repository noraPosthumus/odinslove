---@meta window

---@class (exact) WindowFlags
---@field fullscreen boolean # whether the window is fullscreen
---@field vsync boolean # whether vsync is enabled
---@field resizable boolean # whether the window is resizable
---@field borderless boolean # whether the window is in borderless window mode
---@field topmost boolean # alway on top
---@field alwaysrun boolean # wether the window should keep running while minimized
---@field display integer # index of the display the window is on
---@field refreshrate integer # the current refreshrate of the monitor
---@field x number # x position of the window on the display
---@field y number # y position of the window on the display

---@class window
local window = {}

---Gets whether the window is fullscreen.
---@return boolean
function window.getFullscreen() end

---Gets information about the window.
---@return number width # window width
---@return number height # window height
---@return WindowFlags flags # window [flags](lua://WindowFlags)
function window.getMode() end

---Gets the position of the window on the display.
---@return number x # display x position of the window
---@return number y # display y position of the window
---@return integer display # index of the display the window is on
function window.getPosition() end

---Gets whether the window has Focus.
function window.hasFocus() end

---Maximizes the window
function window.maximize() end

---Minimizes the window
function window.minimize() end

---Restores the window to its original size (before maxi- or minimizing)
function window.restore() end

---Sets the window title.
function window.setTitle( title ) end

---Sets the windows position on the display.
function window.setPosition( x, y ) end

---Sets the windows width, height and [flags](lua://WindowFlags).
function window.setMode( width, height, flags ) end

return window
