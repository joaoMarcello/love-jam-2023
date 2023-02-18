local love = _G.love
local Pack = _G.JM_Love2D_Package

local Panel = require "scripts.panel"

---@class GameState.Game : JM.Scene, GameState
local State = Pack.Scene:new(nil, nil, nil, nil, SCREEN_WIDTH, SCREEN_HEIGHT,
    {
        top = 0,
        left = 0,
        width = 32 * 40,
        bottom = SCREEN_HEIGHT
    })

State.camera:toggle_debug()
State.camera:toggle_grid()
State.camera:toggle_world_bounds()
State.camera.border_color = { 0, 0, 0, 0 }
--============================================================================
---@type Game.Component.Panel
local panel
--============================================================================
State:implements {
    --
    --
    load = function()
        Panel:load()
    end,
    --
    --
    init = function()
        panel = Panel:new(State, { x = 32 * 4 })
    end,
    --
    --
    finish = function()
        Panel:finish()
    end,
    --
    --
    keypressed = function(key)
        if key == "o" then
            State.camera:toggle_grid()
            State.camera:toggle_debug()
            State.camera:toggle_world_bounds()
        end

        if key == "r" then
            State:init()
        end
    end,
    --
    --
    update = function(dt)
        panel:update(dt)
    end,
    --
    --
    draw = function(camera)
        panel:draw()
    end
}

return State
