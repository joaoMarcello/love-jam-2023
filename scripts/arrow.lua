local Component = require "scripts.component"

---@type love.Image|any
local img_red

---@type love.Image|any
local img_green

---@type love.Image|any
local img_blue

---@type love.Image|any
local img_yellow

---@class Arrow : GameComponent
local Arrow = setmetatable({}, Component)
Arrow.__index = Arrow

---@param state GameState.Game
---@param panel Game.Component.Panel
---@return Arrow
function Arrow:new(state, panel, wire, args)
    args = args or {}
    args.x = args.x or (32 * 10)
    args.y = args.y or (panel.y + panel.h - 64)
    args.w = 32
    args.h = 32

    local obj = setmetatable(Component:new(state, args), self)
    Arrow.__constructor__(obj, state, panel, wire, args)
    return obj
end

---@param state GameState.Game
---@param panel Game.Component.Panel
---@param wire Game.Component.Wire
function Arrow:__constructor__(state, panel, wire, args)
    self.gamestate = state
    self.panel = panel
    self.id = args.id or 1
    self.x = panel.x + (panel:socket_to_relative(self.id) - 1) * 32
    self:apply_effect("float", { speed = 0.7, range = 3 })
    self:set_visible(false)

    local img_type = img_red
    img_type = wire.id == 2 and img_green or img_type
    img_type = wire.id == 3 and img_blue or img_type
    img_type = wire.id == 4 and img_yellow or img_type

    self.anima = _G.JM_Anima:new {
        img = img_type,
        max_filter = 'linear'
    }
end

function Arrow:load()
    img_red = img_red or love.graphics.newImage('/data/image/arrow red.png')
    img_green = img_green or love.graphics.newImage('/data/image/arrow green.png')
    img_blue = img_blue or love.graphics.newImage('/data/image/arrow blue.png')
    img_yellow = img_yellow or love.graphics.newImage('/data/image/arrow yellow.png')
end

function Arrow:finish()
    local r = img_red and img_red:release()
    r = img_green and img_green:release()
    r = img_blue and img_blue:release()
    r = img_yellow and img_yellow:release()
    img_red = nil
    img_green = nil
    img_blue = nil
    img_yellow = nil
end

function Arrow:update(dt)
    Component.update(self, dt)

    local panel = self.panel

    ---@type Game.Component.Wire
    local wire = self.panel.wires_by_target[self.id]

    if not panel.selected_id
        or panel:is_complete()
        or (wire and wire:is_plugged())
    then
        self:set_visible(false)
    else
        if panel.cur_socket and panel.cur_socket == self.id then
            self:set_visible(false)
        else
            self:set_visible(true)
        end
    end
end

function Arrow:my_draw()
    -- love.graphics.setColor(1, 0, 0)
    -- love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    self.anima:set_color2(0, 0, 0, 0.3)
    self.anima:set_scale(0.9, 0.9)
    self.anima:draw(self.x + self.w / 2, self.y + self.h / 2 + 5)
    self.anima:set_color2(1, 1, 1, 1)
    self.anima:set_scale(1, 1)

    self.anima:draw(self.x + self.w / 2, self.y + self.h / 2)
end

function Arrow:draw()
    Component.draw(self, self.my_draw)
end

return Arrow
