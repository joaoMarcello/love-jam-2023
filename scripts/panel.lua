local Component = require "scripts.component"
local Wire = require "scripts.wire"

---@class Game.Component.Panel : GameComponent
local Panel = setmetatable({}, Component)
Panel.__index = Panel

---@param state GameState
---@return Game.Component.Panel
function Panel:new(state, args)
    args = args or {}
    args.x = args.x or 64
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

    self.wires = {}

    self.wires[1] = Wire:new(state, self, {
        x = self.x,
        y = self.y,
        id = 1
    })

    self.wires[2] = Wire:new(state, self, {
        x = self.x,
        y = self.y,
        id = 2
    })

    self.wires[3] = Wire:new(state, self, {
        x = self.x,
        y = self.y,
        id = 3
    })

    self.wires[4] = Wire:new(state, self, {
        x = self.x,
        y = self.y,
        id = 4
    })

    table.sort(self.wires, function(a, b)
        return a.draw_order < b.draw_order
    end)
    -- self.wires[3] = Wire:new(state, self, {
    --     x = self.x,
    --     y = self.y,
    --     id = 3
    -- })

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

function Panel:update(dt)
    Component.update(self, dt)

    for i = 1, self.n_wires do
        ---@type Game.Component.Wire
        local wire = self.wires[i]
        wire:update(dt)
    end
end

function Panel:my_draw()
    love.graphics.setColor(0, 0, 1, 0.2)
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
