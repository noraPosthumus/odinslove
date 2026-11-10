---@meta graphics

---@alias DrawMode "fill" | "line"

---@alias FilterMode "nearest" | "linear"
---@alias WrapMode "clampzero" | "clamp" | "repeat" | "mirroredrepeat"
---@alias Drawable Image

---@class Color
---@field r number
---@field g number
---@field b number
---@field a number
Color = {}

---@class Image
---@field private texture userdata
---@field getDimensions fun(self: Image): x: number, y: number
---@field getHeight fun(self: Image): number
---@field getWidth fun(self: Image): number
---@field getFilter fun(self: Image): FilterMode
---@field setFilter fun(self: Image, filter: FilterMode)
---@field getWrap fun(self: Image) : WrapMode
---@field setWrap fun(self: Image, wrap: WrapMode)
Image = {}

---@class graphics
---@field private color Color
local graphics = {}

---@param mode   DrawMode
---@param x      number
---@param y      number
---@param radius number
function graphics.circle( mode, x, y, radius ) end

---@param r number?
---@param g number?
---@param b number?
---@param a number?
function graphics.clear( r, g, b, a ) end

---@param r number?
---@param g number?
---@param b number?
---@param a number?
function graphics.setColor( r, g, b, a) end

---@return number r
---@return number g
---@return number b
---@return number a
function graphics.getColor( ) end

---@param filename string
---@return Image
function graphics.newImage( filename ) end

---@param drawable Drawable
---@param x        number
---@param y        number
---@param r        number?
---@param sx       number?
---@param sy       number?
---@param ox       number?
---@param oy       number?
function graphics.draw( drawable, x, y, r, sx, sy, ox, oy ) end

return graphics
