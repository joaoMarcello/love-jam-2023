local Component = require "scripts.component"

local imgs

---@type love.Image|any
local img_light

---@class Lamp : GameComponent
local Lamp = setmetatable({}, Component)
Lamp.__index = Lamp

---@param state GameState
---@param wire Game.Component.Wire
function Lamp:new(state, wire, args)
    args = args or {}
    args.y = wire.y - 32
    args.x = wire.x
    args.w = 32
    args.h = 32

    local obj = setmetatable(Component:new(state, args), self)
    Lamp.__constructor__(obj, state, wire, args)
    return obj
end

---@param state GameState.Game|GameState
---@param wire Game.Component.Wire
---@param args any
function Lamp:__constructor__(state, wire, args)
    self.gamestate = state
    self.wire = wire

    local color = wire.color_hidden
    self.anima_off = _G.JM_Anima:new { img = imgs[color][0] }
    self.anima_on = _G.JM_Anima:new { img = imgs[color][1] }

    self.light = _G.JM_Anima:new { img = img_light }
    self.light:set_size(60, 60)
    self.light:set_color2(unpack(color))
    self.light:set_color2(nil, nil, nil, 0.8)
end

---@param wire Game.Component.Wire
function Lamp:load(wire)
    local colors = wire.Colors
    imgs = imgs or {
            [colors.red] = {
                [0] = love.graphics.newImage('/data/image/lamp red off.png'),
                [1] = love.graphics.newImage('/data/image/lamp red on.png')
            },
            --
            --
            [colors.green] = {
                [0] = love.graphics.newImage('/data/image/lamp green off.png'),
                [1] = love.graphics.newImage('/data/image/lamp green on.png')
            },
            --
            --
            [colors.blue] = {
                [0] = love.graphics.newImage('/data/image/lamp blue off.png'),
                [1] = love.graphics.newImage('/data/image/lamp blue on.png')
            },
            --
            --
            [colors.yellow] = {
                [0] = love.graphics.newImage('/data/image/lamp yellow off.png'),
                [1] = love.graphics.newImage('/data/image/lamp yellow on.png')
            },
        }

    img_light = img_light or love.graphics.newImage('/data/image/light source.png')
end

function Lamp:finish()
    local r = img_light and img_light:release()
    img_light = nil
    imgs = nil
end

function Lamp:rect()
    return self.x, self.y, self.w, self.h
end

function Lamp:update(dt)
    Component.update(self, dt)
end

function Lamp:my_draw()
    if self.wire:is_plugged() then
        self.anima_on:draw_rec(self:rect())

        love.graphics.setBlendMode("add")
        self.light:draw(self.x + self.w / 2, self.y + self.h / 2 + 6)
        love.graphics.setBlendMode("alpha")
    else
        self.anima_off:draw_rec(self:rect())
    end
end

function Lamp:draw()
    Component.draw(self, self.my_draw)
end

return Lamp
