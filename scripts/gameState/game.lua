local love = _G.love
local Pack = _G.JM_Love2D_Package
local Utils = _G.JM_Utils
local Generator = Pack.FontGenerator

local Panel = require "scripts.panel"
local Timer = require "scripts.timer"
local DisplayLvl = require "scripts.displayLevel"
local DisplayValue = require "scripts.display_value"

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

---@type Game.Component.DisplayLvl
local display_level

---@type Game.Component.DisplayValue
local display_score

---@type Game.Component.DisplayValue
local display_hi_score

---@type Game.Component.DisplayValue
local display_shocks

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

---@alias GameState.Game.Params "level"|"shocks"|"score"|"hi_score"

---@param index GameState.Game.Params
function State:game_get_param(index)
    return param and param[index]
end

---@param index GameState.Game.Params
function State:game_set_param(index, value)
    if not param or not value then return end
    param[index] = value
end

---@param index GameState.Game.Params
function State:game_increment_param(index, value)
    value = value or 1
    if not param then return end

    local p = param[index]
    if not p then return end

    param[index] = Utils:clamp(p + value, 0, math.huge)
end

---@param index GameState.Game.Params
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

        param = {}
        param['hi_score'] = 2000

        Panel:load()
        Timer:load()
        DisplayLvl:load()
        DisplayValue:load()
    end,
    --
    --
    init = function()
        State:game_set_param("score", 0)
        State:game_set_param("shocks", 0)
        State:game_set_param("level", 0)

        panel = Panel:new(State, { x = 32 * 3 })
        timer = Timer:new(State)

        display_level = DisplayLvl:new(State)
        display_score = DisplayValue:new(State)

        display_hi_score = DisplayValue:new(State, {
            track = "hi_score",
            display = "HI SCORE",
            y = 32 * 8
        })

        display_shocks = DisplayValue:new(State, {
            track = "shocks",
            display = "SHOCKS",
            y = 32 * 10,
            format = "%d"
        })
    end,
    --
    --
    finish = function()
        Panel:finish()
        Timer:finish()
        DisplayLvl:finish()
        DisplayValue:finish()
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

        local score = param['score']
        if score > param['hi_score'] then
            display_score:ghost()
        else
            display_score:remove_eff_ghost()
        end

        -- GAME OVER
        if timer:time_is_up() then
            panel:lock()
            State:game_set_param("level", display_level:get_value())
        end

        panel:update(dt)

        display_level:update(dt)
        display_score:update(dt)
        display_hi_score:update(dt)
        display_shocks:update(dt)

        if panel:is_complete() and panel.complete_time >= 2.0 then
            prev_panel = panel

            panel = Panel:new(State, {
                x = prev_panel.x + prev_panel.w + 32 * 3
            })

            camera.target = nil
            camera.follow_speed_x = 0

            display_level:increment()
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

                display_level:draw()
                timer:draw()
                display_score:draw()
                display_hi_score:draw()
                display_shocks:draw()
            end
        }
    }
}

return State
