local love = _G.love
local Pack = _G.JM_Love2D_Package
local Generator = Pack.FontGenerator

local Panel = require "scripts.panel"
local Timer = require "scripts.timer"

---@class GameState.Game : JM.Scene, GameState
local State = Pack.Scene:new(nil, nil, nil, nil, SCREEN_WIDTH, SCREEN_HEIGHT,
    {
        top = 0,
        left = 0,
        right = math.huge - 1,
        bottom = SCREEN_HEIGHT
    })

State:set_color(0.2, 0.2, 0.2, 1)

State.camera:toggle_debug()
State.camera:toggle_grid()
State.camera:toggle_world_bounds()
State.camera.border_color = { 0, 0, 0, 0 }

State.camera:set_focus_x(32 * 3 * State.camera.desired_scale)
-- State.camera.max_speed_x = 32 * 11
-- State.camera.default_initial_speed_x = 1
-- State.camera.acc_x = 32 * 4

State.camera.constant_speed_x = 32 * 11
--============================================================================
---@type Game.Component.Panel
local panel

---@type Game.Component.Panel
local prev_panel

---@type Game.Component.Timer
local timer

---@type JM.Font.Font
local gui_font

local param

function State:game_get_timer()
    return timer
end

function State:game_get_panel()
    return panel
end

function State:game_get_gui_font()
    return gui_font
end

---@alias GameState.Game.Params "level"|"shocks"|"score"|"max_score"

function State:game_set_param(index, value)
    if not param or not value then return end
    if not param[index] then return end

    param[index] = value
end

function State:game_increment_param(index, value)
    value = value or 1
    if not param then return end

    local p = param[index]
    if not p then return end

    param[index] = p + value
end

function State:game_decrement_param(index, value)
    value = math.abs(value) * ( -1)
    self:game_increment_param(index, value)
end

--============================================================================
State:implements {
    --
    --
    load = function()
        gui_font = Generator:new_by_ttf {
            path = "/data/font/Retro Gaming.ttf",
            dpi = 32,
            name = "retro gaming",
            font_size = 18,
            character_space = 2
        }

        Panel:load()
        Timer:load()
    end,
    --
    --
    init = function()
        param = {
            level = 1,
            shocks = 0,
            score = 0,
            max_score = 1000
        }

        panel = Panel:new(State, { x = 32 * 3 })
        timer = Timer:new(State)
    end,
    --
    --
    finish = function()
        Panel:finish()
        Timer:finish()
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

        if panel:is_complete() and panel.complete_time >= 2.0 then
            prev_panel = panel

            panel = Panel:new(State, {
                x = prev_panel.x + prev_panel.w + 32 * 3
            })

            camera.target = nil
            camera.follow_speed_x = 0
        end

        if panel:is_locked() and camera:target_on_focus_x() then
            panel:unlock()
        end

        if not panel:is_locked() and not panel:is_complete() then
            timer:update(dt)
        end
    end,
    --
    --
    layers = {
        {
            name = "MAIN",

            draw = function(self, cm)
                if prev_panel then
                    prev_panel:draw()
                end

                panel:draw()
            end
        },
        --
        --
        {
            name = "GUI",
            factor_x = -1,

            draw = function(self, camera)
                local Font = _G.JM_Font
                -- Font:print("Pos: " .. panel.x, 600, 32)
                -- Font:print("Pos: " .. State.camera.bounds_right, 600, 50)

                local l, t, r, b = State.camera:get_viewport_in_world_coord()
                l, t = State.camera:world_to_screen(l, t)
                r, b = State.camera:world_to_screen(r, b)

                love.graphics.setColor(121 / 255, 103 / 255, 85 / 255)
                love.graphics.rectangle('fill', 32 * 15, 0, 32 * 8, SCREEN_HEIGHT)
                timer:draw()
            end
        }
    }
}

return State
