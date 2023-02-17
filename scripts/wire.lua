local Component = require "scripts.component"

---@class Game.Component.Wire: GameComponent
local Wire = setmetatable({}, Component)
Wire.__index = Wire

---@param state GameState
function Wire:new(state, args)

end

function Wire:__constructor__()

end

function Wire:load()

end

function Wire:init()

end

function Wire:finish()

end

function Wire:update(dt)

end

function Wire:draw()

end

return Wire
