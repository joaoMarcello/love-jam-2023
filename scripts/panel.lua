local Utils = _G.JM_Utils
local Component = require "scripts.component"
local Wire = require "scripts.wire"

---@class Game.Component.Panel : GameComponent
local Panel = setmetatable({}, Component)
Panel.__index = Panel

---@param state GameState
---@return Game.Component.Panel
function Panel:new(state, args)
    args = args or {}
    args.x = args.x or 0
    args.y = args.y or 64
    args.w = (32 * 3 * 4) - (32 * 2)
    args.h = (32 * 2 * 3) + (32 * 4)

    local obj = Component:new(state, args)
    setmetatable(obj, self)

    Panel.__constructor__(obj, state, self)

    return obj
end

---@param state GameState.Game|GameState
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

    self.sockets = {}

    self.wires = {}

    self.wires_by_id = {}

    for i = 1, 3, 2 do
        local wire = Wire:new(state, self, { id = i })
        table.insert(self.wires, wire)
        self.wires_by_id[i] = wire
        -- break
    end

    for i = 2, 4, 2 do
        local wire = Wire:new(state, self, { id = i })
        table.insert(self.wires, wire)
        self.wires_by_id[i] = wire
        -- break
    end

    table.sort(self.wires, function(a, b)
        return a.draw_order < b.draw_order
    end)

    self.wires_by_id[1].state = Wire.States.tracking

    self.n_wires = #self.wires

    self.sockets = {}
    self.cur_socket = nil
end

--==========================================================================
do
    function Panel:load()
        Wire:load()
    end

    function Panel:init()

    end

    function Panel:finish()
        Wire:finish()
    end
end
--==========================================================================

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

    return socket_to_relative(s)
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

--=========================================================================

function Panel:update(dt)
    Component.update(self, dt)

    local mx, my = self.gamestate:get_mouse_position()

    if mx <= self.x + self.w and mx >= self.x then
        self.cur_socket = math.floor((mx - self.x) / (self.w / 4)) + 1
        self.cur_socket = Utils:clamp(self.cur_socket, 1, 4)
    end

    for i = 1, self.n_wires do
        ---@type Game.Component.Wire
        local wire = self.wires[i]
        wire:update(dt)
    end
end

function Panel:my_draw()
    love.graphics.setColor(132 / 255, 155 / 255, 228 / 255, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    love.graphics.rectangle("fill", self.x, self.y + 32 * 6, self.w, 2)

    if self.cur_socket then
        local s = socket_to_relative(self.cur_socket) - 1
        love.graphics.setColor(0, 0, 1, 0.7)
        love.graphics.rectangle("fill", self.x + s * 32, self.y + self.h, 32, 32)
    end

    for i = 1, self.n_wires do
        ---@type Game.Component.Wire
        local wire = self.wires[i]
        wire:draw()
    end
end

function Panel:draw()
    Component.draw(self, self.my_draw)
end

return Panel
