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
function Piece:new(state, wire, args)
    args = args or {}
    args.x = args.x or (32 * 2)
    args.y = args.y or (32 * 3)
    args.w = 32
    args.h = 32
    args.id = args.type or "top-middle"
    args.type = Types[args.type]

    local obj = Component:new(state, args)
    setmetatable(obj, self)
    Piece.__constructor__(obj, state, wire, args)
    return obj
end

---@param state GameState.Game|GameState
---@param wire Game.Component.Wire
function Piece:__constructor__(state, wire, args)
    self.gamestate = state
    self.wire = wire

    self.ox = self.w / 2
    self.oy = self.h / 2

    ---@type string
    self.id = args.id

    self.anima = Anima:new {
        img = img or '',

        frames_list = {
            Map[args.type]
        }
    }

    self.anima:set_color2(unpack(wire.color__))
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
    if self.id:match("middle") or true then
        self:draw_shadow()
    end

    self.anima:set_color2(unpack(self.wire.color__))
    self.anima:draw_rec(self.x, self.y, self.w, self.h)
end

function Piece:draw_shadow()
    self.anima:set_color2(0, 0, 0, 0.3)
    self.anima:draw_rec(self.x, self.y + 5, self.w, self.h)
end

return Piece
