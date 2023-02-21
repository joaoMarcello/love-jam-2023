local Component = require "scripts.component"
local Piece = require "scripts.wirePiece"

local check_collision = _G.JM_Love2D_Package.Physics.collision_rect

---@class WirePlug : GameComponent
local Plug = setmetatable({}, Component)
Plug.__index = Plug

---@return WirePlug
function Plug:new(state, wire, args)
    local obj = Component:new(state, args)
    setmetatable(obj, self)
    Plug.__constructor__(obj, state, wire, args)
    return obj
end

---@param state GameState.Game
---@param wire Game.Component.Wire
function Plug:__constructor__(state, wire, args)
    self.gamestate = state
    self.wire = wire
    self.panel = wire.panel
    self.socket = wire.socket

    self.x = self.panel.x + (self.socket - 1) * 32
    self.y = self.panel.y + (32 * 6)
    self.w = 32
    self.h = 32

    self.piece = Piece:new(state, wire, {
        type = "left",
        y = self.panel.y + (32 * 6),
        x = self.panel.x + (self.socket - 1) * 32
    })
    self.piece.allow_shadow = false

    self.piece2 = Piece:new(state, wire, {
        type = "left",
        y = self.panel.y + (32 * 6),
        x = self.panel.x + (self.socket - 1) * 32
    })
    self.piece2.allow_shadow = false

    self.ox = self.w / 2
    self.oy = 16

    ---@type JM.Effect|any
    self.eff_pulse = nil
end

function Plug:load()

end

function Plug:finish()

end

function Plug:pulse()
    if self.eff_pulse and not self.eff_pulse.__remove then
        return
    end
    -- if self.eff_pulse then self.eff_pulse.__remove = true end
    self.eff_pulse = self:apply_effect("pulse", { range = 0.1 })
end

function Plug:remove_pulse()
    if self.eff_pulse and not self.eff_pulse.__remove then
        self.eff_pulse.__remove = true
        self.eff_pulse = nil
    end
end

function Plug:is_tracking()
    local panel = self.panel
    return panel.selected_id and panel.selected_id == self.wire.socket_id and panel.cur_socket
end

function Plug:is_been_pointed()
    if self:is_tracking() or self:is_plugged() then return false end

    local panel = self.panel
    local w = panel.w / 4
    local mx, my = self.gamestate:get_mouse_position()

    local c = check_collision(
        panel.x + (self.wire.socket_id - 1) * w, self.y, w, self.h,
        mx, my, 0, 0
    )

    return c
end

function Plug:is_plugged()
    return self.wire:is_plugged()
end

function Plug:plug()
    self.y = self.piece.y + self.h / 2
end

function Plug:unplug()
    self.piece.x = self.panel.x + (self.socket - 1) * 32
    self.piece.y = self.panel.y + (32 * 6)

    self.x = self.piece.x
    self.y = self.piece.y
end

function Plug:update(dt)
    Component.update(self, dt)

    local panel = self.panel

    if self:is_tracking() then
        if panel.cur_socket then
            local sock = panel:socket_to_relative(panel.cur_socket)
            self.piece.x = panel.x + (sock - 1) * 32
            self.piece.y = panel.y + panel.h - 32

            self.x = self.piece.x
            self.y = self.piece.y
        end
    elseif not self:is_plugged() then
        self.piece.x = self.panel.x + (self.socket - 1) * 32
        self.piece.y = self.panel.y + (32 * 6)

        self.x = self.piece.x
        self.y = self.piece.y
    end

    if self:is_been_pointed() then
        self:pulse()
    else
        self:remove_pulse()
    end
end

function Plug:my_draw()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h / 2)
end

function Plug:draw()
    if self:is_plugged() then
        self.piece:draw()
    end

    if self:is_tracking() or self:is_plugged() then
        self.piece2:draw()
    end

    Component.draw(self, self.my_draw)

    -- local font = _G.FONT_GUI
    -- font:print(self:is_been_pointed() and "true" or "false", self.x, self.y - 20)
end

return Plug
