local MouseIcon = require "scripts.mouseIcon2"
local Affectable = _G.JM_Affectable

---@enum MouseIcon.States
local States = {
    shock = 1,
    grab = 2,
    point = 3,
    prepare = 4
}

---@class MouseIcon : JM.Template.Affectable
local Icon = setmetatable({}, Affectable)
Icon.__index = Icon
Icon.States = States

function Icon:new(state, args)
    local obj = Affectable:new()
    setmetatable(obj, self)
    Icon.__constructor__(obj, state, args)
    return obj
end

---@param state GameState.Game
function Icon:__constructor__(state, args)
    self.gamestate = state
    self.x, self.y = state:get_mouse_position()
    self.w = 16
    self.h = 16

    self.state = States.prepare

    self.mouseIcon = MouseIcon:new(state)
end

function Icon:load()
    MouseIcon:load()
end

function Icon:finish()
    MouseIcon:finish()
end

---@param state MouseIcon.States
function Icon:set_state(state)
    if self.state == state then return false end

    self.state = state

    if state == States.shock then
        local eff = self:apply_effect("earthquake", { random = true, range_x = 5, range_y = 5, duration = 0.6 })

        eff:set_final_action(function()
            self:set_state(States.prepare)
        end)
    end

    return true
end

function Icon:get_color_state()
    local Utils = _G.JM_Utils

    if self.state == States.prepare then
        return Utils:get_rgba(1, 1, 1, 1)
    elseif self.state == States.point then
        return Utils:get_rgba(0, 0, 0, 1)
    elseif self.state == States.grab then
        return Utils:get_rgba(0, 0, 1, 1)
    elseif self.state == States.shock then
        return Utils:get_rgba(1, 1, 0, 1)
    end
end

function Icon:is_in_point_mode()
    if self.state == States.shock then return false end

    local panel = self.gamestate:game_get_panel()
    if panel:is_complete()
        or self.gamestate:game_get_timer():time_is_up()
    then
        return false
    end

    for i = 1, panel.n_wires do
        ---@type Game.Component.Wire
        local wire = panel.wires_by_id[i]

        if wire and wire.plug:is_been_pointed() then
            return true
        end
    end

    return false
end

function Icon:update(dt)
    Affectable.update(self, dt)

    local mx, my = self.gamestate:get_mouse_position()

    local panel = self.gamestate:game_get_panel()

    if panel.selected_id then
        self:set_state(States.grab)

        ---@type Game.Component.Wire
        local wire = panel.wires_by_last[panel.selected_id]

        if wire then
            self.x = wire.plug.x + 32 - 10
            self.y = wire.plug.y - 10
        end
        --
        --
    elseif self.state == States.shock then
        self.x, self.y = mx, my
        --
        --
    elseif self:is_in_point_mode() then
        self:set_state(States.point)
        self.x, self.y = mx, my
        --
        --
    else
        self:set_state(States.prepare)
        self.x, self.y = mx, my
    end

    self.mouseIcon:update(dt)
    if panel.cur_socket then
        self.mouseIcon:set_state(self.mouseIcon.States.point)
    else
        self.mouseIcon:set_state(self.mouseIcon.States.normal)
    end
end

function Icon:my_draw()
    love.graphics.setColor(self:get_color_state())
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

function Icon:draw()
    Affectable.draw(self, self.my_draw)

    if self.state == States.grab then
        self.mouseIcon:draw()
    end
end

return Icon
