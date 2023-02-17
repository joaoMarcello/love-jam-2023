local Component = require "scripts.component"
local Piece = require "scripts.wirePiece"

local img

---@class Game.Component.Wire: GameComponent
local Wire = setmetatable({}, Component)
Wire.__index = Wire

---@param state GameState
---@param panel Game.Component.Panel
---@return Game.Component.Wire
function Wire:new(state, panel, args)
    args = args or {}
    args.x = args.x or 32
    args.y = args.y or (32 * 2)
    args.id = args.id or 1

    local obj = Component:new(state, args)
    setmetatable(obj, self)
    Wire.__constructor__(obj, state, panel, args)
    return obj
end

---@param state GameState.Game|GameState
---@param panel Game.Component.Panel
function Wire:__constructor__(state, panel, args)
    self.gamestate = state
    self.panel = panel

    self.id = args.id
    self.pos_init = ((self.id - 1) * 3) + 1

    self.pieces = {}
    self.pos = { 5, 9, 7 }


    self.pieces[1] = Piece:new(state, {
        x = self.x,
        y = self.y,
        type = "bottom-left"
    })
    self.pieces[2] = Piece:new(state, {
        x = self.x + 32,
        y = self.y
    })

    self.n_pieces = #self.pieces
end

function Wire:load()
    Piece:load()

    img = img or {
            -- ["wire"] = love.graphics.newImage('/data/image/wire.png')
        }
end

function Wire:init()

end

function Wire:finish()
    Piece:finish()

    if img then
        local r = img['wire'] and img['wire']:release()
    end
    img = nil
end

function Wire:update(dt)
    for i = 1, self.n_pieces do
        ---@type Game.Component.Piece
        local piece = self.pieces[i]
        piece:update(dt)
    end
end

function Wire:draw()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", self.x, self.y, 32, 32)

    for i = 1, self.n_pieces do
        ---@type Game.Component.Piece
        local piece = self.pieces[i]
        piece:draw()
    end
    Pack.Font:print(self.pos_init, self.x, self.y - 20)
end

return Wire
