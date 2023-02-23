local Component = require "scripts.component"

local imgs

---@class Lamp : GameComponent
local Lamp = setmetatable({}, Component)
Lamp.__index = Lamp

---@param state GameState.Game
---@param wire Game.Component.Wire
function Lamp:new(state, wire, args)
    local obj = setmetatable(Component:new(state, args), self)
    Lamp.__constructor__(obj, state, wire, args)
    return obj
end

---@param state GameState.Game
---@param wire Game.Component.Wire
---@param args any
function Lamp:__constructor__(state, wire, args)
    self.gamestate = state
    self.wire = wire

    self.anima_off = _G.JM_Anima:new { img = imgs[wire.Colors.red][0] }
    self.anima_on = _G.JM_Anima:new { img = imgs[wire.Colors.red][1] }
end

---@param wire Game.Component.Wire
function Lamp:load(wire)
    local colors = wire.Colors
    imgs = imgs or {
            [colors.red] = {
                [0] = love.graphics.newImage('/data/image/lamp red off.png'),
                [1] = love.graphics.newImage('/data/image/lamp red on.png')
            },
        }
end

function Lamp:finish()
    imgs = nil
end

function Lamp:update(dt)
    Component.update(self, dt)
end

function Lamp:my_draw()
    if self.wire:is_plugged() then
        self.anima_on:draw_rec(self.wire.x, self.wire.y, 32, 32)
    else
        self.anima_off:draw_rec(self.wire.x, self.wire.y, 32, 32)
    end
end

function Lamp:draw()
    Component.draw(self, self.my_draw)
end

return Lamp
