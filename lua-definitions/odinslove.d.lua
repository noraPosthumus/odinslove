---@meta odinslove

---@module "graphics"
---@module "audio"
---@module "window"
---@module "input"
---@module "mouse"

---@class (exact) odinslove
---@field graphics graphics
---@field audio audio
---@field window window
---@field input input
---@field mouse mouse
---@field draw fun()
---@field update fun(dt: number)
---@field load fun()
---@field quit fun()
---@field keypressed fun( key )
---@field mousemoved fun( x: number, y: number, dx: number, dy: number )
---@field mousepressed fun( x: number, y: number, button: number )
---@field wheelmoved fun( x: number, y: number )
odinslove = {}
