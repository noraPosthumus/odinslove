---@meta graphics

---@alias DrawMode "fill" | "line"

---@alias FilterMode "nearest" | "linear"
---@alias WrapMode "repeat" | "clamp" | "mirroredrepeat" | "mirroredclamp"
---@alias Drawable Image

---@class (exact) Color
---@field r number
---@field g number
---@field b number
---@field a number

---@class Font

---@class (exact) Image
---@field private texture userdata
---@field getDimensions fun(self: Image): x: number, y: number
---@field getHeight fun(self: Image): number
---@field getWidth fun(self: Image): number
---@field getFilter fun(self: Image): FilterMode
---@field setFilter fun(self: Image, filter: FilterMode)
---@field getWrap fun(self: Image) : WrapMode
---@field setWrap fun(self: Image, wrap: WrapMode)

---@class graphics
local graphics = {}

---@param mode   DrawMode
---@param x      number
---@param y      number
---@param radius number
function graphics.circle( mode, x, y, radius ) end

---@param mode      DrawMode
---@param x         number
---@param y         number
---@param width     number
---@param height    number
---@param roundness number?
---@param segments  integer?
function graphics.rectangle( mode, x, y, width, height, roundness, segments ) end

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

---@param filename string
---@return Font
function graphics.newFont( filename ) end

---@param drawable Drawable
---@param x        number
---@param y        number
---@param r        number?
---@param sx       number?
---@param sy       number?
---@param ox       number?
---@param oy       number?
function graphics.draw( drawable, x, y, r, sx, sy, ox, oy ) end

---@return number
function graphics.getLineWidth() end

---@param width number
function graphics.setLineWidth( width ) end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
function graphics.line( x1, y1, x2, y2 ) end

---@param text      string
---@param font      Font
---@param x         number
---@param y         number
---@param r         number?
---@param fontsize  number?
---@param spacing   number?
---@param ox        number?
---@param oy        number?
function graphics.print( text, font, x, y, r, fontsize, spacing, ox, oy ) end

---@param text      string
---@param x         number
---@param y         number
---@param r         number?
---@param fontsize  number?
---@param spacing   number?
---@param ox        number?
---@param oy        number?
function graphics.print( text, x, y, r, fontsize, spacing, ox, oy ) end

return graphics
