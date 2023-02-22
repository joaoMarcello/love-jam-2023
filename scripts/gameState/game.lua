local love = _G.love
local Pack = _G.JM_Love2D_Package
local Utils = _G.JM_Utils
local Generator = Pack.FontGenerator

local Panel = require "scripts.panel"
local Timer = require "scripts.timer"
local DisplayLvl = require "scripts.displayLevel"
local DisplayValue = require "scripts.display_value"
local Count = require "scripts.countdown"
local Icon = require "scripts.mouseIcon"

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

---@type Game.Component.Panel|any
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

local time_endgame

---@type CountDown
local countdown

---@type MouseIcon
local mouse_icon
--=========================================================================

function State:game_get_timer()
    return timer
end

function State:game_get_panel()
    return panel
end

function State:game_get_display_level()
    return display_level
end

function State:game_get_gui_font()
    return gui_font
end

function State:game_get_mouse_icon()
    return mouse_icon
end

---@alias GameState.Game.Params "level"|"shocks"|"score"|"hi_score"|"last_hi_score"

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
        gui_font = _G.FONT_GUI

        param = {}
        param['hi_score'] = 100

        Panel:load()
        Timer:load()
        DisplayLvl:load()
        DisplayValue:load()
        Count:load()
        Icon:load()
    end,
    --
    --
    init = function()
        State.camera.x = 0

        State:game_set_param("score", 0)
        State:game_set_param("shocks", 0)
        State:game_set_param("level", 0)
        State:game_set_param("last_hi_score", param['hi_score'])

        prev_panel = nil
        panel = Panel:new(State, { x = 32 * 3 })

        timer = Timer:new(State)

        display_level = DisplayLvl:new(State)

        display_score = DisplayValue:new(State, {
            y = 32 * 5
        })

        display_hi_score = DisplayValue:new(State, {
            track = "hi_score",
            display = "HI SCORE",
            y = 32 * 7
        })

        display_shocks = DisplayValue:new(State, {
            track = "shocks",
            display = "SHOCKS",
            y = 32 * 9,
            format = "%d"
        })

        countdown = Count:new({})

        mouse_icon = Icon:new(State)

        time_endgame = 0
    end,
    --
    --
    finish = function()
        Panel:finish()
        Timer:finish()
        DisplayLvl:finish()
        DisplayValue:finish()
        Count:finish()
        Icon:finish()
    end,
    --
    --
    keypressed = function(key)
        if key == "o" then
            State.camera:toggle_grid()
            State.camera:toggle_debug()
            State.camera:toggle_world_bounds()
        end

        if not timer:time_is_up()
            and not panel:is_complete()
            and not panel:is_locked()
            and key == "return"
        then
            CHANGE_GAME_STATE(require "scripts.gameState.pause", true, false, true, true, true, false)
        end
    end,
    --
    --
    mousepressed = function(x, y, button)
        panel:mouse_pressed(x, y, button)
    end,
    --
    --
    mousemoved = function(x, y, dx, dy, istouch)
        mouse_icon:mouse_moved(x, y, dx, dy)
    end,
    --
    --
    update = function(dt, camera)
        local camera = State.camera
        camera:follow(panel.x, panel.y, 'panel')
        camera:update(dt)

        countdown:update(dt)

        mouse_icon:update(dt)

        if not countdown:is_released() then return end

        -- local score = param['score']
        -- if score > param['hi_score'] then
        --     display_score:ghost()
        -- else
        --     display_score:remove_eff_ghost()
        -- end

        -- GAME OVER
        if timer:time_is_up() then
            panel:lock()
            time_endgame = time_endgame + dt

            if not panel.is_shaking and time_endgame >= 3.0 then
                local score = param['score']
                local hi_score = param['hi_score']
                param['last_hi_score'] = hi_score

                if score > hi_score then
                    param['hi_score'] = score
                end
                State:game_set_param("level", display_level:get_value())
                -- State:game_set_param("hi_score", param['score'])
                -- State:init()
                CHANGE_GAME_STATE(require 'scripts.gameState.endGame', true, false, false, false, false, false)
                return
            end
            --return
        end

        panel:update(dt)

        display_level:update(dt)
        display_score:update(dt)
        display_hi_score:update(dt)
        display_shocks:update(dt)

        if panel:is_complete()
            and panel.complete_time >= 2.0
            and not timer:time_is_up()
        then
            prev_panel = panel

            panel = Panel:new(State, {
                x = prev_panel.x + prev_panel.w + 32 * 3
            })

            camera.target = nil
            camera.follow_speed_x = 0

            display_level:increment()
            if display_level:get_value() % 2 == 1 then
                timer:increment(15)
            end
        end

        if panel:is_locked()
            and camera:target_on_focus_x()
            and not timer:time_is_up()
        then
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
                -- mouse_icon:draw()
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
        },
        --
        --
        {
            name = "Mouse Icon",

            draw = function(self, camera)
                mouse_icon:draw()
            end
        },
        --
        --
        {
            name = "Time is up",
            factor_x = -1,
            factor_y = -1,

            draw = function()
                if not countdown:is_released() then
                    countdown:draw()
                end

                if timer:time_is_up() then
                    local px, py, pw, ph = 32 * 5, panel.y + 32 * 5, 32 * 6, 32 * 3

                    love.graphics.setColor(0, 0, 0, 1)
                    love.graphics.rectangle("fill", px, py, pw, ph)


                    local obj = gui_font:generate_phrase("<effect=wave, speed=0.6> <color, 1, 1, 0>Time is up!", px,
                        py, px + pw, "center")

                    local h = obj:text_height(obj:get_lines(px))

                    obj:draw(px, py + ph / 2 - h / 2, "center")
                end
            end
        },
    }
}

return State
