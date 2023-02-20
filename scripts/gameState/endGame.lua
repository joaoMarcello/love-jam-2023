local Pack = _G.JM_Love2D_Package

local Button = require "scripts.button_endgame"

---@class GameState.EndGame : JM.Scene, GameState
local State = _G.JM_Love2D_Package.Scene:new(nil, nil, nil, nil, SCREEN_WIDTH, SCREEN_HEIGHT)

State.camera:toggle_debug()
State.camera:toggle_grid()
State.camera:toggle_world_bounds()
State.camera.border_color = { 0, 0, 0, 0 }

State:set_color(0.8, 0.8, 1, 1)
--==========================================================================

---@type GameState.Game|nil
local gameState

local score, hi_score, level, shocks, last_hi_score

local buttons

local time_off
--==========================================================================

State:implements {
    load = function()

    end,
    --
    --
    init = function()
        gameState = require "scripts.gameState.game"
        -- gameState:load()
        -- gameState:init()

        score = gameState:game_get_param("score")
        hi_score = gameState:game_get_param("hi_score")
        level = gameState:game_get_param("level")
        shocks = gameState:game_get_param("shocks")
        last_hi_score = gameState:game_get_param("last_hi_score")

        Button:load(gameState:game_get_gui_font())

        buttons = {
            Button:new(State, { x = (32 * 5), y = (32 * 11) }),
            Button:new(State, { x = (32 * 12), y = (32 * 11), text = "Back to Menu" }),
        }

        local button

        ---@type Button
        button = buttons[1]
        button:on_event("mouse_pressed", function(x, y, button)
            if not buttons[1].pressed then
                buttons[1].pressed = true
                CHANGE_GAME_STATE(gameState, true, true, false, false, false, false)
            end
        end)

        time_off = 0.0
    end,
    --
    --
    finish = function()
        gameState = nil
        Button:finish()
    end,
    --
    --
    keypressed = function(key)
        if key == "o" then
            State.camera:toggle_grid()
            State.camera:toggle_debug()
            State.camera:toggle_world_bounds()
        end
    end,
    --
    --
    mousepressed = function(x, y, button)
        for i = 1, #buttons do
            ---@type Button
            local bt = buttons[i]

            bt:mouse_pressed(x, y, button)
        end
    end,
    --
    --
    update = function(dt)
        time_off = time_off + dt
        if time_off <= 1.0 then return end

        local mx, my = State:get_mouse_position()

        for i = 1, #buttons do
            ---@type Button
            local button = buttons[i]

            if button:check_collision(mx, my, 0, 0) then
                if not button.on_focus then
                    button:set_focus(true)
                end
            elseif button.on_focus then
                button:set_focus(false)
            end

            buttons[i]:update(dt)
        end
    end,
    --
    --
    layers = {
        {
            name = "main",

            ---@param camera JM.Camera.Camera
            draw = function(self, camera)
                love.graphics.setColor(109 / 255, 117 / 255, 141 / 255, 1)
                local w = SCREEN_WIDTH - 32 * 3 * 2
                local h = 32 * 13
                love.graphics.rectangle("fill", SCREEN_WIDTH / 2 - w / 2, 32, w, h)

                if gameState then
                    local font = gameState:game_get_gui_font()

                    local px, py = 32 * 4, 32 * 2
                    local right = SCREEN_WIDTH - px

                    local color1 = "<color, 1, 1, 1>"
                    local color2 = "<color, 1, 1, 0>"

                    font:push()

                    font:printf("END GAME", px, py, "center", right)

                    --======================================================
                    font:printf("<color, 0, 0, 0> Max Level: " .. level, px + 1, py + 32 * 2 + 1, "left", right)

                    font:printf(color1 .. "Max Level: " .. color2 .. level, px, py + 32 * 2, "left", right)
                    --======================================================

                    font:printf("<color, 0, 0, 0>Number of shocks: " .. shocks, px + 1, py + 32 * 3.5 + 1, "left", right)

                    font:printf(color1 .. "Number of shocks: " .. color2 .. shocks, px, py + 32 * 3.5, "left", right)
                    --======================================================

                    font:printf("<color, 0, 0, 0>Hi Score: " .. hi_score, px + 1, py + 32 * 5 + 1, "left", right)

                    font:printf(color1 .. "Hi Score: " .. color2 .. hi_score, px, py + 32 * 5, "left", right)
                    --======================================================

                    local text = color1 .. "Score: " .. color2 .. score
                    if last_hi_score < score then
                        text = text ..
                            " <font-size=12> <effect=ghost, speed = 0.9, min=0.1>   <color>\t NEW HI SCORE </color>"
                    end

                    font:printx("<color, 0, 0, 0>Score: " .. score, px + 1, py + 32 * 6.5 + 1, right, "left")
                    font:printx(text, px, py + 32 * 6.5, right, "left")

                    font:pop()
                end

                for i = 1, #buttons do
                    ---@type Button
                    local button = buttons[i]

                    button:draw()
                end
            end
        }
    }
    --
}

return State
