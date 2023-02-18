local Component = require "scripts.component"
local Piece = require "scripts.wirePiece"

---@enum Game.Component.Wire.States
local States = {
    inactive = 1,
    tracking = 2,
    plugged = 3
}

---@enum Game.Component.Wire.Colors
local Colors = {
    red = { 1, 0, 0, 1 },
    green = { 0, 1, 0, 1 },
    blue = { 0, 0, 1, 1 },
    yellow = { 1, 1, 0, 1 },
    white = { 1, 1, 1, 1 }
}

local img

---@class Game.Component.Wire: GameComponent
local Wire = setmetatable({}, Component)
Wire.__index = Wire
Wire.States = States
Wire.Colors = Colors

---@param state GameState
---@param panel Game.Component.Panel
---@return Game.Component.Wire
function Wire:new(state, panel, args)
    args = args or {}
    args.x = args.x or 32
    args.y = panel.y
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

    self.color__ = Colors.white

    self.id = args.id
    self.pos_init = ((self.id - 1) * 3) + 1
    self.x = self.panel.x + 32 * (self.pos_init - 1)

    ---@type Game.Component.Wire.States
    self.state = States.inactive

    self.pieces = {}

    self.pos = {}
    self.socket, self.socket_id = panel:get_socket(self)

    if self:is_even() then
        self.pos[1] = panel:get_path(2, self, self.pos_init)
        self.pos[2] = panel:get_path(4, self, self.pos[1])
        self.pos[3] = self.socket
    else
        self.pos[1] = panel:get_path(1, self, self.pos_init)
        self.pos[2] = panel:get_path(3, self, self.pos[1])
        self.pos[3] = self.socket
    end

    -- self.path = {
    --     { 1, 5 },
    --     { 5, 5 },
    --     { 5, 9 },
    --     { 9, 9 },
    --     { 9, 7 },
    --     { 7, 7 }
    -- }

    self.path = {}

    if self.id % 2 ~= 0 then
        for i = 1, 3 do
            if i == 1 then
                self.path[1] = { self.pos_init, self.pos[i] }
            else
                self.path[(i + (i - 1))] = { self.pos[i - 1], self.pos[i] }
            end

            self.path[i + i] = { self.pos[i], self.pos[i] }
        end
        --
    else
        for i = 1, 3 do
            if i == 1 then
                self.path[1] = { self.pos_init, self.pos_init }
                self.path[2] = { self.pos_init, self.pos[i] }
                self.path[3] = { self.pos[i], self.pos[i] }
            elseif i == 2 then
                self.path[4] = { self.pos[i - 1], self.pos[i] }
                self.path[5] = { self.pos[i], self.pos[i] }
            elseif i == 3 then
                self.path[6] = { self.pos[i - 1], self.pos[i] }
            end
        end
    end
    -- self.path = {
    --     { 7, 7 },
    --     { 7, 7 },
    --     { 7, 4 },
    --     { 4, 4 },
    --     { 4, 1 },
    --     { 1, 1 }
    -- }

    -- self.path = {
    --     { 4, 4 },
    --     { 4, 2 },
    --     { 2, 2 },
    --     { 2, 6 },
    --     { 6, 6 },
    --     { 6, 1 }
    -- }

    -- self.path = {
    --     { 10, 10 },
    --     { 10, 1 },
    --     { 1,  1 },
    --     { 1,  5 },
    --     { 5,  5 },
    --     { 5,  4 }
    -- }

    local get_node = function(p)
        local first, second = p[1], p[2]
        local left = first < second and first or second
        local right = left == first and second or first
        return {
            first = first,
            second = second,
            left = left,
            right = right
        }
    end

    local last = nil

    for i, p in ipairs(self.path) do
        local node = get_node(p)
        local prev = self.path[i - 1] and get_node(self.path[i - 1])
        local next = self.path[i + 1] and get_node(self.path[i + 1])

        for k = node.left, node.right do
            local type_ = "top-middle"


            if node.left == node.right then
                if last and last:match("left") then
                    type_ = "left"
                elseif last and last:match("right") then
                    type_ = "right"
                else
                    type_ = "left"
                end
            else
                if k == node.right then
                    if next and (next.right == node.right
                        or next.left == node.right)
                    then
                        type_ = "top-right"
                    end

                    if prev and (prev.left == node.right
                        or prev.right == node.right)
                    then
                        type_ = "bottom-right"
                    end
                    --
                elseif k == node.left then
                    if prev and (prev.left == node.left
                        or prev.right == node.left)
                    then
                        type_ = "bottom-left"
                    end

                    if next and (next.left == node.left
                        or next.right == node.left)
                    then
                        type_ = "top-left"
                    end
                end
            end -- END Linha IMPAR

            -- FIRST PIECE
            if i == 1 and k == self.pos_init then
                if node.first < node.second then
                    type_ = "bottom-left"
                elseif node.first > node.second then
                    type_ = "bottom-right"
                else
                    type_ = "left"
                end
            end

            -- LAST PIECE
            if i == #(self.path) and k == node.second then
                if node.first > node.second then
                    type_ = "top-left"
                elseif node.first < node.second then
                    type_ = "top-right"
                else
                    type_ = "left"
                end
            end
            --

            last = type_

            local piece = Piece:new(state, self, {
                x = self.panel.x + (32 * (k - 1)),
                y = self.panel.y + (32 * (i - 1)),
                type = type_
            })

            table.insert(self.pieces, piece)
        end
        -- break
    end

    self.n_pieces = #self.pieces

    self.pieces_track = nil

    -- self:plug(self.id)
end

--=======================================================================
do
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
end
--=======================================================================

local get_node = function(p)
    local first, second = p[1], p[2]
    local left = first < second and first or second
    local right = left == first and second or first
    return {
        first = first,
        second = second,
        left = left,
        right = right
    }
end

local result_track_pieces = setmetatable({}, { __mode = 'k' })

---@param socket number|nil
function Wire:get_track_pieces(socket)
    if not socket then return end

    local result = result_track_pieces[self]
        and result_track_pieces[self][socket]

    if result then return result end

    local pieces = {}
    local socket_position = self.panel:socket_to_relative(socket)

    ---@type Game.Component.Piece
    local last_piece = self.pieces[self.n_pieces]

    local prev = last_piece

    local curve_id = self.socket_id

    for i = 1, 4 do
        if i == curve_id then
            local node = get_node { self.socket, socket_position }

            for j = node.left, node.right do
                local type_ = "bottom-middle"

                -- The last piece
                if j == node.right and j == self.socket then
                    if self.socket > socket_position then
                        type_ = "bottom-right"
                    elseif self.socket < socket_position then
                        type_ = "bottom-left"
                    else
                        type_ = prev.id:match("left") and "left" or "right"
                    end
                    --
                elseif j == node.right then
                    type_ = "top-right"
                end


                if j == node.left and j == self.socket then
                    if self.socket < socket_position then
                        type_ = "bottom-left"
                    elseif self.socket > socket_position then
                        type_ = "bottom-right"
                    else
                        type_ = prev.id:match("left") and "left" or "right"
                    end
                    --
                elseif j == node.left then
                    type_ = "top-left"
                end

                local piece = Piece:new(self.gamestate, self, {
                    x = self.panel.x + (32 * (j - 1)),
                    y = self.panel.y + (32 * 7) + (32 * (i - 1)),
                    type = type_
                })

                prev = piece
                table.insert(pieces, piece)
            end
        else
            local px = self.panel.x + (32 * (socket_position - 1))

            if i <= curve_id then
                local s = self.socket - 1
                px = self.panel.x + 32 * s
            end

            local piece = Piece:new(self.gamestate, self, {
                x = px,
                y = self.panel.y + (32 * 7) + (32 * (i - 1)),
                type = prev.id:match("left") and "left" or "right"
            })

            prev = piece
            table.insert(pieces, piece)
        end
    end

    result_track_pieces[self] = result_track_pieces[self]
        or setmetatable({}, { __mode = 'v' })

    result_track_pieces[self][socket] = pieces
    return pieces
end

function Wire:set_hidden_color(color)
    self.color_hidden = color
end

function Wire:is_even()
    return self.id % 2 == 0
end

function Wire:is_odd()
    return self.id % 2 ~= 0
end

function Wire:is_plugged()
    return self.state == States.plugged
end

function Wire:plug(socket)
    if self.state ~= States.plugged then
        if socket ~= self.id then
            return false
        end

        self.state = States.plugged
        self.pieces_track = self:get_track_pieces(self.id)
        self.color__ = self.color_hidden or Colors.white
        return true
    end
end

---@param self Game.Component.Wire
local function tracking_update(self, dt)
    self.pieces_track = self:get_track_pieces(self.panel.cur_socket)
end

function Wire:update(dt)
    for i = 1, self.n_pieces do
        ---@type Game.Component.Piece
        local piece = self.pieces[i]
        piece:update(dt)
    end

    if self.state == States.tracking then
        tracking_update(self, dt)
    end
end

function Wire:draw()
    love.graphics.setColor(0, 0, 0, 0.5)
    -- love.graphics.rectangle("fill", self.x, self.y, 32, 32)

    for i = 1, self.n_pieces do
        ---@type Game.Component.Piece
        local piece = self.pieces[i]
        piece:draw()
    end

    if self.state ~= States.inactive then
        if self.pieces_track then
            for i = 1, #(self.pieces_track) do
                ---@type Game.Component.Piece
                local piece = self.pieces_track[i]
                piece:draw()
            end
        end
    end

    Pack.Font:print("" .. self.pos[1] .. "-" .. self.pos[2] .. "-" .. self.pos[3], self.x, self.y - 20)

    Pack.Font:print(self.pos_init, self.x, self.y - 40)
end

return Wire
