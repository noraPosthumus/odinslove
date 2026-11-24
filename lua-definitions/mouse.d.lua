---@meta mouse

---@class mouse
local mouse = {}

---@return number x
---@return number y
function mouse.getPosition () end

---@return number
function mouse.getX () end

---@return number
function mouse.getY () end

---@param button integer
---@param ... integer
---@return boolean
function mouse.isDown ( button, ... ) end

---@param button integer
---@param ... integer
---@return boolean
function mouse.isUp ( button, ... ) end

---@param x number
---@param y number
function mouse.setPosition ( x, y ) end

---@param x number
function mouse.setX ( x ) end

---@param y number
function mouse.setY ( y ) end

---@return boolean
function mouse.isVisible () end

---@param visible boolean
function mouse.setVisible ( visible ) end

return mouse
