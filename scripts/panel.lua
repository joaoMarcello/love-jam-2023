local Utils = _G.JM_Utils
local Component = require "scripts.component"
local Wire = require "scripts.wire"
local Arrow = require "scripts.arrow"
local Display = require "scripts.displayText"

---@type love.Image|any
local img_socket

---@type love.Image|any
local img_panel

---@type love.Image|any
local img_shock

---@enum Game.Component.Panel.Colors
local Colors = {
    Wire.Colors.red,
    Wire.Colors.green,
    Wire.Colors.blue,
    Wire.Colors.yellow
}

---@enum Game.Component.Panel.Events
local Events = {
    complete = 1,
    plug = 2,
    shock = 3,
    select = 4,
    unselect = 5
}
---@alias Game.Component.Panel.EventNames "complete"|"plug"|"shock"|"select"|"unselect"

---@param self Game.Component.Panel
---@param type_ Game.Component.Panel.Events
local function dispatch_event(self, type_)
    local evt = self.events and self.events[type_]
    local r = evt and evt.action(evt.args)
end

---@class Game.Component.Panel : GameComponent
local Panel = setmetatable({}, Component)
Panel.__index = Panel
Panel.Colors = Colors

---@return Game.Component.Panel
function Panel:new(state, args)
    args = args or {}
    args.x = args.x or 0
    args.y = args.y or (32 + 16 + 8)
    args.w = (32 * 3 * 4) - (32 * 2)
    args.h = (32 * 2 * 3) + (32 * 6)

    local obj = Component:new(state, args)
    setmetatable(obj, self)

    Panel.__constructor__(obj, state, self)

    return obj
end

---@param state GameState.Game
function Panel:__constructor__(state, args)
    self.gamestate = state

    self.ox = self.w / 2
    self.oy = self.h / 2

    self.matrix = {}
    self.max_column = (4 * 3) - 2
    self.max_row = (3 * 2)
    self.occupied = {}
    for i = 1, self.max_row do
        self.occupied[i] = {}
    end
    self.occupied[1][7] = true
    self.occupied[1][10] = true
    -- self.occupied[4][1] = true
    -- self.occupied[4][5] = true
    -- self.occupied[4][7] = true

    self.__lock = true

    self.n_shocks = 0

    self.sockets = {}

    self.wires = {}
    self.wires_by_id = {}
    self.wires_by_last = {}
    self.wires_by_target = {}

    for i = 1, 3, 2 do
        local wire = Wire:new(state, self, { id = i })
        table.insert(self.wires, wire)
        self.wires_by_id[i] = wire
        self.wires_by_last[wire.socket_id] = wire
        self.wires_by_target[wire.target] = wire
    end

    for i = 2, 4, 2 do
        local wire = Wire:new(state, self, { id = i })
        table.insert(self.wires, wire)
        self.wires_by_id[i] = wire
        self.wires_by_last[wire.socket_id] = wire
        self.wires_by_target[wire.target] = wire
    end

    table.sort(self.wires, function(a, b)
        return a.draw_order < b.draw_order
    end)

    self.n_wires = #self.wires

    self.sockets = {}
    self.cur_socket = nil
    self.selected_id = nil

    self.complete_time = 0.0
    self.time_bip = 0.0

    local font = state:game_get_gui_font()
    self.phrase = font:generate_phrase("<color, 1, 1, 0> <effect=flickering, speed=0.3> COMPLETE",
        self.x,
        self.y + self.h / 2 - font.__font_size, self.x + self.w,
        "center"
    )

    self.arrows = {
        Arrow:new(self.gamestate, self, self.wires_by_target[1], { id = 1 }),
        Arrow:new(self.gamestate, self, self.wires_by_target[2], { id = 2 }),
        Arrow:new(self.gamestate, self, self.wires_by_target[3], { id = 3 }),
        Arrow:new(self.gamestate, self, self.wires_by_target[4], { id = 4 }),
    }

    local Anima = _G.JM_Anima

    self.sockets_anima = Anima:new { img = img_socket }

    self.sockets_anima2 = Anima:new { img = img_socket,
        frames_list = { { 0, 32, 32, 64 } }
    }

    self.panel_anima = Anima:new {
        img = img_panel,
        max_filter = "linear"
    }

    self.shock_anima = Anima:new {
        img = img_shock,
        speed = 0.1,
        frames = 3,

    }
    self.shock_anima:set_size(nil, 32 * 6 * 2)
    self.shock_anima:set_state("random")
end

--==========================================================================
do
    function Panel:load()
        Wire:load()
        Arrow:load()
        Display:load()

        img_socket = img_socket or love.graphics.newImage('/data/image/socket.png')

        img_panel = img_panel or love.graphics.newImage('/data/image/panel.png')

        img_shock = img_shock or love.graphics.newImage('/data/image/shock-Sheet.png')
    end

    function Panel:init()

    end

    function Panel:finish()
        Wire:finish()
        Arrow:finish()
        Display:finish()

        local r = img_socket and img_socket:release()
        img_socket = nil
    end
end
--==========================================================================

---@param name Game.Component.Panel.EventNames
---@param action function
---@param args any
function Panel:on_event(name, action, args)
    local evt_type = Events[name]
    if not evt_type then return end

    self.events = self.events or {}

    self.events[evt_type] = {
        type = evt_type,
        action = action,
        args = args
    }
end

---@param name Game.Component.Panel.EventNames
---@return table|nil
function Panel:get_event(name)
    local evt_type = Events[name]
    if not evt_type then return end

    local evt = self.events and self.events[evt_type]
    return evt
end

function Panel:is_locked()
    return self.__lock
end

function Panel:lock()
    if not self.__lock then
        self.__lock = true
    end
end

function Panel:unlock()
    if self.__lock then self.__lock = false end
end

function Panel:shake()
    if not self.is_shaking then
        self.is_shaking = true

        local eff = self:apply_effect("earthquake", {
            duration = 0.6,
            random = true,
            range_x = 3,
            range_y = 3
        })
        eff:set_final_action(function()
            self.is_shaking = false
        end)
    end
end

local function socket_to_relative(n)
    return ((n - 1) * 3) + 1
end

function Panel:socket_to_relative(n)
    return socket_to_relative(n)
end

---@param wire Game.Component.Wire
function Panel:get_socket(wire)
    local min = 1
    local max = 4

    local s = math.random(min, max)

    if not self.sockets[s] then
        self.sockets[s] = true
    else
        for i = 1, 4 do
            if not self.sockets[i] then
                self.sockets[i] = true
                s = i
                break
            end
        end
    end

    return socket_to_relative(s), s
end

local target_result = {}
function Panel:get_target()
    local min = 1
    local max = 4

    local check_reset = function()
        local complete = true
        for i = min, max do
            if not target_result[i] then
                complete = false
            end
        end
        if complete then target_result = {} end
    end

    local result = math.random(min, max)

    if not target_result[result] then
        target_result[result] = true
    else
        for i = min, max do
            if not target_result[i] then
                target_result[i] = true
                result = i
                break
            end
        end
    end

    check_reset()
    return result
end

---@param wire Game.Component.Wire
function Panel:get_path(row, wire, last)
    -- internal function
    local lock_x = function(a, b)
        local min = a < b and a or b
        local max = min == a and b or a

        for j = min, max do
            self.occupied[row][j] = true
        end
    end

    local column = 1

    local min_column = 1
    local max_column = self.max_column

    if wire.id == 1 then
        max_column = 6
    elseif wire.id == 2 then
        max_column = 7
    end

    column = math.random(min_column, max_column)

    if not self.occupied[row][column] then
        lock_x(last, column)
    else
        column = self.max_column

        for j = self.max_column, 1, -1 do
            if not self.occupied[row][j] then
                if math.random() > 0.5 then
                    column = j
                end
            else
                break
            end
        end

        lock_x(last, column)
    end

    return column
end

---@return Game.Component.Wire|nil
function Panel:selected_wire()
    if not self.selected_id then return nil end

    return self.wires_by_last[self.selected_id]
end

function Panel:is_complete()
    for i = 1, self.n_wires do
        ---@type Game.Component.Wire
        local wire = self.wires[i]
        if not wire:is_plugged() then return false end
    end
    return true
end

function Panel:show_text(text, x, y)
    if not x then
        local mouseIcon = self.gamestate:game_get_mouse_icon()
        x = mouseIcon.x
        y = mouseIcon.y - 64
    end
    self.gamestate:game_add_component(
        Display:new(self.gamestate, { text = text, x = x, y = y })
    )
end

--=========================================================================
function Panel:mouse_pressed(x, y, button)
    if self.is_shaking or self.__lock or self:is_complete() then return end

    if button == 2 then
        local wire = self:selected_wire()

        if wire then
            wire:turn_inactive()
        end
        self.selected_id = nil
        return
    end

    if self.selected_id and self.cur_socket then
        local wire = self:selected_wire()

        if wire then
            local success = wire:try_plug(self.cur_socket)

            if not success then
                _G.PLAY_SFX("shock")

                wire:turn_inactive()

                self:shake()
                local timer = self.gamestate:game_get_timer()
                local mouseIcon = self.gamestate:game_get_mouse_icon()

                mouseIcon:set_state(mouseIcon.States.shock)

                timer:decrement(5 + self.n_shocks)
                timer:pause(0.2 * 6)

                if not timer:time_is_up() then
                    PLAY_SFX("tick tock", true)
                else
                    local audio = _G.JM_Love2D_Package.Sound:get_sfx('tick tock')
                    if audio then audio.source:stop() end
                end

                self.n_shocks = self.n_shocks + 1
                self.gamestate:game_decrement_param("score", 150)
                self.gamestate:game_increment_param("shocks", 1)
                self:show_text( -150)
                dispatch_event(self, Events.shock)
                --
            elseif self:is_complete() then
                PLAY_SFX("plug")
                -- PLAY_SFX('countdown')

                dispatch_event(self, Events.complete)
                local level = self.gamestate:game_get_display_level()
                local bonus = 0 --(level:get_value() - 1) * 100

                local score = 300 + bonus
                self.gamestate:game_increment_param("score", score)
                self:show_text(score)
                --
            else
                _G.PLAY_SFX("plug")

                dispatch_event(self, Events.plug)

                local score = 100
                self.gamestate:game_increment_param("score", score)

                local mouseIcon = self.gamestate:game_get_mouse_icon()
                self:show_text(score)
            end

            self.selected_id = nil
            self.cur_socket = nil
        end
        return
    end

    local mouseIcon = self.gamestate:game_get_mouse_icon()
    x = mouseIcon.x
    y = mouseIcon.y

    if x <= (self.x + self.w + 16) and x >= (self.x - 16)
        and y >= (self.y + 32 * 6 - 16) and y <= (self.y + 32 * 7)
    then
        local wire = self:selected_wire()

        if wire then
            wire:turn_inactive()
        end

        self.selected_id = math.floor((x - self.x) / ((self.w) / 4)) + 1
        self.selected_id = Utils:clamp(self.selected_id, 1, 4)

        wire = self:selected_wire()
        if wire and wire:is_plugged() then self.selected_id = nil end
    end
end

function Panel:update(dt)
    Component.update(self, dt)
    if self.__lock then return end

    if self:is_complete() then
        self.complete_time = self.complete_time + dt
        self.time_bip = self.time_bip + dt
        if self.gamestate:game_get_panel() == self then
            if self.time_bip >= 0.6 then
                -- PLAY_SFX('countdown', true)
                self.time_bip = self.time_bip - 0.6
            end
        end
    end

    local mx, my = self.gamestate:get_mouse_position()


    local mouseIcon2 = self.gamestate:game_get_mouse_icon().mouseIcon
    mx, my = mouseIcon2.x, mouseIcon2.y

    if mx <= (self.x + self.w + 16) and mx >= (self.x - 16)
        and my >= (self.y + self.h - 32 * 2)
    then
        self.cur_socket = math.floor((mx - self.x - 16) / ((self.w + 16) / 4)) + 1
        self.cur_socket = Utils:clamp(self.cur_socket, 1, 4)

        ---@type Game.Component.Wire
        local wire = self.wires_by_target[self.cur_socket]
        if wire and wire:is_plugged() then self.cur_socket = nil end
    else
        self.cur_socket = nil
    end

    if self.selected_id and self.cur_socket then
        local wire = self:selected_wire()

        if wire then
            wire:turn_tracking()
        end
    end

    for i = 1, self.n_wires do
        ---@type Game.Component.Wire
        local wire = self.wires[i]
        wire:update(dt)
    end

    for i = 1, #self.arrows do
        ---@type Arrow
        local obj = self.arrows[i]

        obj:update(dt)
    end

    if self.is_shaking then
        self.shock_anima:update(dt)
    end
end

function Panel:my_draw()
    self.panel_anima:draw_rec(self.x, self.y, self.w, self.h + 64)

    for i = 1, 4 do
        self.sockets_anima:draw_rec(self.x + (socket_to_relative(i) - 1) * 32, self.y + self.h, 32, 32)
    end

    for i = 1, self.n_wires do
        ---@type Game.Component.Wire
        local wire = self.wires[i]
        wire:draw()
    end

    for i = 1, 4 do
        self.sockets_anima2:draw_rec(self.x + (socket_to_relative(i) - 1) * 32, self.y + self.h, 32, 32)
    end

    if not self.gamestate:game_get_timer():time_is_up() then
        for i = 1, #self.arrows do
            ---@type Arrow
            local obj = self.arrows[i]

            obj:draw()
        end
    end

    if self:is_complete()
        and self.gamestate:game_get_panel() == self
    then
        love.graphics.setColor(0, 0, 0, 1)
        local w = 32 * 6
        love.graphics.rectangle("fill", self.x + self.w / 2 - w / 2,
            self.y + 32 * 5 - 20,
            w, 64)
        self.phrase:draw(self.x, self.y + 32 * 5, "center")
    end
end

function Panel:draw()
    Component.draw(self, self.my_draw)

    -- if self.is_shaking and not self.__lock then
    --     self.shock_anima:draw(self.x, self.y)
    -- end
end

return Panel
