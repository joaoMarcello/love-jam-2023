local Component = require "scripts.component"

---@class Arrow : GameComponent
local Arrow = setmetatable({}, Component)
Arrow.__index = Arrow

---@param state GameState.Game
---@param panel Game.Component.Panel
---@return Arrow
function Arrow:new(state, panel, args)
    args = args or {}
    args.x = args.x or (32 * 10)
    args.y = args.y or (panel.y + panel.h - 64)
    args.w = 32
    args.h = 32

    local obj = setmetatable(Component:new(state, args), self)
    Arrow.__constructor__(obj, state, panel, args)
    return obj
end

---@param state GameState.Game
---@param panel Game.Component.Panel
function Arrow:__constructor__(state, panel, args)
    self.gamestate = state
    self.panel = panel
    self.id = args.id or 1
    self.x = panel.x + (panel:socket_to_relative(self.id) - 1) * 32
    self:apply_effect("float", { speed = 0.7, range = 3 })
    self:set_visible(false)
end

function Arrow:load()

end

function Arrow:finish()

end

function Arrow:update(dt)
    Component.update(self, dt)

    local panel = self.panel

    ---@type Game.Component.Wire
    local wire = self.panel.wires_by_id[self.id]

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
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

function Arrow:draw()
    Component.draw(self, self.my_draw)
end

return Arrow
