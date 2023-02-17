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

    self.sockets = {}

    self.wires = {}

    for i = 1, 4, 1 do
        local wire = Wire:new(state, self, { id = i })
        table.insert(self.wires, wire)
    end

    table.sort(self.wires, function(a, b)
        return a.draw_order < b.draw_order
    end)

    self.n_wires = #self.wires
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

function Panel:get_socket()
    local s = 1
    for i = 2, 4 do
        if math.random() > 0.5 then
            s = i
        end
    end

    if not self.sockets[s] then
        self.sockets[s] = true
        -- return s
    else
        for i = 1, 4 do
            if not self.sockets[i] then
                self.sockets[i] = true
                s = i
                break
                -- return i
            end
        end
    end

    return ((s - 1) * 3) + 1
end

---@param wire Game.Component.Wire
function Panel:get_path(row, wire, last)
    local column = 1

    local max_column = self.max_column

    if wire.id == 1 then
        max_column = 6
    elseif wire.id == 2 then
        max_column = 7
    end

    for i = 1, max_column do
        if math.random() > 0.5 then
            column = i
        end
    end

    local lock_x = function(a, b)
        local min = a < b and a or b
        local max = min == a and b or a

        for j = min, max do
            self.occupied[row][j] = true
        end
    end

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
        -- for j = 1, column do
        --     self.occupied[row][j] = true
        -- end
    end

    return column
end

function Panel:update(dt)
    Component.update(self, dt)

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
