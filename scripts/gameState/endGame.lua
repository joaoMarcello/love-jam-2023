local Pack = _G.JM_Love2D_Package

local Button = require "scripts.button_endgame"
local MouseIcon = require "scripts.mouseIcon2"

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

---@type MouseIcon2
local mouse_icon
--==========================================================================

State:implements {
    load = function()
        MouseIcon:load()
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

        ---@type Button
        local bt_play = Button:new(State, { x = (32 * 5), y = (32 * 11) })

        ---@type Button
        local bt_back = Button:new(State, {
            x = (32 * 12), y = (32 * 11), text = "Back to Menu"
        })

        buttons = {
            bt_play,
            bt_back,
        }

        bt_play:on_event("mouse_pressed", function(x, y, button)
            if not bt_play.pressed then
                bt_play.pressed = true
                CHANGE_GAME_STATE(gameState, true, true, false, false, false, false)
            end
        end)

        bt_back:on_event("mouse_pressed", function(x, y, button)
            if not bt_back.pressed then
                bt_back.pressed = true
                CHANGE_GAME_STATE(require "scripts.gameState.menu")
            end
        end)

        time_off = 0.0

        mouse_icon = MouseIcon:new(State)
        mouse_icon.x = 32 * 16
        mouse_icon.y = 32 * 9
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
        x, y = mouse_icon.x, mouse_icon.y

        for i = 1, #buttons do
            ---@type Button
            local bt = buttons[i]

            bt:mouse_pressed(x, y, button)
        end
    end,
    --
    --
    mousemoved = function(x, y, dx, dy, istouch)
        mouse_icon:mouse_moved(x, y, dx, dy)
    end,
    --
    --
    update = function(dt)
        mouse_icon:update(dt)

        time_off = time_off + dt
        if time_off <= 1.0 then return end

        local mx, my = mouse_icon.x, mouse_icon.y

        local one_bt_is_focused = false

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

            if button.on_focus then
                one_bt_is_focused = true
            end
        end

        mouse_icon:set_state(one_bt_is_focused and mouse_icon.States.point or mouse_icon.States.normal)
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

                    if last_hi_score < score then
                        local px = 32 * 12
                        self.__hi_score = font:generate_phrase(
                            "<font-size=12> <effect=ghost, speed=0.9, min=0.1> <color> <bold> NEW HI SCORE", px,
                            py + 32 * 5, math.huge, "left")

                        self.__hi_score:draw(px, py + 32 * 5, "left")
                    end
                    --======================================================

                    local text = color1 .. "Score: " .. color2 .. score
                    -- if last_hi_score < score then
                    --     text = text ..
                    --         " <font-size=12> <effect=ghost, speed = 0.9, min=0.1>   <color>\t NEW HI SCORE </color>"
                    -- end

                    font:printx("<color, 0, 0, 0>Score: " .. score, px + 1, py + 32 * 6.5 + 1, right, "left")
                    font:printx(text, px, py + 32 * 6.5, right, "left")

                    font:pop()
                end

                for i = 1, #buttons do
                    ---@type Button
                    local button = buttons[i]

                    button:draw()
                end

                mouse_icon:draw()
            end
        }
    }
    --
}

return State
