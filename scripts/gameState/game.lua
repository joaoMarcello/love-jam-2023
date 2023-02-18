local love = _G.love
local Pack = _G.JM_Love2D_Package

local Panel = require "scripts.panel"

---@class GameState.Game : JM.Scene, GameState
local State = Pack.Scene:new(nil, nil, nil, nil, SCREEN_WIDTH, SCREEN_HEIGHT,
    {
        top = 0,
        left = 0,
        right = math.huge - 1,
        bottom = SCREEN_HEIGHT
    })

State.camera:toggle_debug()
State.camera:toggle_grid()
State.camera:toggle_world_bounds()
State.camera.border_color = { 0, 0, 0, 0 }

State.camera:set_focus_x(32 * 3 * State.camera.desired_scale)
-- State.camera.max_speed_x = 32 * 7
-- State.camera.default_initial_speed_x = 1
-- State.camera.acc_x = 32 * 4
State.camera.constant_speed_x = 32 * 11
--============================================================================
---@type Game.Component.Panel
local panel

---@type Game.Component.Panel
local prev_panel

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
        panel = Panel:new(State, { x = 32 * 3 })
        --panel:on_event("complete", on_complete_action)
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
    mousepressed = function(x, y, button)
        panel:mouse_pressed(x, y, button)
    end,
    --
    --
    update = function(dt, camera)
        local camera = State.camera
        camera:follow(panel.x, panel.y, 'panel')
        camera:update(dt)

        panel:update(dt)

        if panel:is_complete() and panel.complete_time >= 0.8 then
            prev_panel = panel

            panel = Panel:new(State, {
                x = prev_panel.x + prev_panel.w + 32 * 3
            })

            camera.target = nil
            camera.follow_speed_x = 0
        end
    end,
    --
    --
    layers = {
        {
            factor_x = -1,

            draw = function(self, camera)
                local Font = _G.JM_Font
                Font:print("Pos: " .. panel.x, 600, 32)
                Font:print("Pos: " .. State.camera.bounds_right, 600, 50)
            end
        }
    },
    --
    --
    draw = function(camera)
        if prev_panel then
            prev_panel:draw()
        end

        panel:draw()

        -- local Font = _G.JM_Font
        -- Font:print(panel:is_complete() and "COMPLETE" or "NOT", panel.x, 32 * 10)
    end
}

return State
