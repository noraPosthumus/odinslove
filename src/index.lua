---@meta odinslove

---@module "graphics"
---@module "audio"

---@class (exact) odinslove
---@field graphics graphics
---@field audio audio
---@field draw fun()
---@field update fun(dt: number)
---@field load fun()
---@field quit fun()
---@field keypressed fun( key )
---@field mousemoved fun( x: number, y: number, dx: number, dy: number )
---@field mousepressed fun( x: number, y: number, button: number )
---@field wheelmoved fun( x: number, y: number )
odinslove = {}
