local Anima = _G.JM_Anima
local Component = require "scripts.component"

---@type love.Image|nil
local img

---@enum Game.Component.Piece.Types
local Types = {
    ["top-left"] = 1,
    ["left"] = 2,
    ["bottom-left"] = 3,
    ["bottom-middle"] = 4,
    ["bottom-right"] = 5,
    ["right"] = 6,
    ["top-right"] = 7,
    ["top-middle"] = 8,
}

local Map = {
    [Types["top-left"]] = { 0, 32, 0, 32 },
    [Types["left"]] = { 0, 32, 32, 64 },
    [Types["bottom-left"]] = { 0, 32, 64, (32 * 3) },
    [Types["bottom-middle"]] = { 32, 64, 64, (32 * 3) },
    [Types["bottom-right"]] = { 64, (32 * 3), 64, (32 * 3) },
    [Types["right"]] = { 64, (32 * 3), 32, (32 * 2) },
    [Types["top-right"]] = { 64, (32 * 3), 0, 32 },
    [Types["top-middle"]] = { 32, 64, 0, 32 },
}

---@class Game.Component.Piece : GameComponent
local Piece = setmetatable({}, Component)
Piece.__index = Piece
Piece.Types = Types

---@param state GameState
---@return Game.Component.Piece
function Piece:new(state, args)
    args = args or {}
    args.x = args.x or (32 * 2)
    args.y = args.y or (32 * 3)
    args.w = 32
    args.h = 32
    args.type = args.type or Types["top-middle"]

    local obj = Component:new(state, args)
    setmetatable(obj, self)
    Piece.__constructor__(obj, state, args)
    return obj
end

---@param state GameState.Game|GameState
function Piece:__constructor__(state, args)
    self.gamestate = state

    self.ox = self.w / 2
    self.oy = self.h / 2

    self.anima = Anima:new {
        img = img or '',

        frames_list = {
            Map[args.type]
        }
    }
end

function Piece:load()
    img = img or love.graphics.newImage('/data/image/wire.png')
end

function Piece:finish()
    local r = img and img:release()
    img = nil
end

function Piece:update(dt)
    Component.update(self, dt)
    self.anima:update(dt)
end

function Piece:draw()
    self.anima:draw_rec(self.x, self.y, self.w, self.h)
    love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.circle("fill", self.x, self.y, 32)
end

return Piece
