local Pack = _G.Pack
local MouseIcon = require "scripts.mouseIcon2"
local Button = require "scripts.button2"


---@class GameState.Pause: JM.Scene, GameState
local State = Pack.Scene:new(nil, nil, nil, nil, SCREEN_WIDTH, SCREEN_HEIGHT)
State.camera:toggle_debug()
State.camera:toggle_grid()
State.camera:toggle_world_bounds()
--=========================================================================

local buttons

---@type MouseIcon2
local mouse_icon

local time_off

--=========================================================================
State:implements {
    load = function()
        MouseIcon:load()
        Button:load(_G.FONT_GUI)
        State.prev_state.camera.desired_scale = 1
    end,

    init = function()
        local resume = Button:new(State, {
            text = "Resume",
            y = 32 * 6
        })

        local restart = Button:new(State, {
            text = "Restart",
            y = resume.y + resume.h + 1
        })

        local back = Button:new(State, {
            text = "To Title Screen",
            y = restart.y + restart.h + 1
        })

        local quit = Button:new(State, {
            text = "Quit",
            y = back.y + back.h + 1
        })

        resume:on_event("mouse_pressed", function()
            UNPAUSE(State)
        end)

        restart:on_event("mouse_pressed", function()
            UNPAUSE(State)
            CHANGE_GAME_STATE(require 'scripts.gameState.game', true, true, false, nil, nil, nil)
        end)

        back:on_event("mouse_pressed", function()
            UNPAUSE(State)
            CHANGE_GAME_STATE(require 'scripts.gameState.menu', nil, nil, nil, nil, nil, nil)
        end)

        quit:on_event("mouse_pressed", function()
            love.event.quit()
        end)

        buttons = {
            resume,
            restart,
            back,
            quit
        }

        time_off = 0.0

        local game = require 'scripts.gameState.game'

        mouse_icon = MouseIcon:new(State)
        mouse_icon.x = game:game_get_mouse_icon().x
        mouse_icon.y = game:game_get_mouse_icon().y
    end,

    finish = function()

    end,

    keypressed = function(key)
        if key == "o" then
            State.camera:toggle_grid()
            State.camera:toggle_debug()
            State.camera:toggle_world_bounds()
        end

        if key == "return" then
            UNPAUSE(State)
        end
    end,

    mousepressed = function(x, y, button)
        x, y = mouse_icon.x, mouse_icon.y

        for i = 1, #buttons do
            ---@type Button2
            local bt = buttons[i]

            bt:mouse_pressed(x, y, button)
            if not buttons then break end
        end
    end,

    mousemoved = function(x, y, dx, dy, istouch)
        mouse_icon:mouse_moved(x, y, dx, dy)
    end,

    update = function(dt, camera)
        mouse_icon:update(dt)

        time_off = time_off + dt
        if time_off <= 0.6 then return end

        local mx, my = mouse_icon.x, mouse_icon.y

        local one_bt_is_focused = false

        for i = 1, #buttons do
            ---@type Button2
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

    layers = {
        {
            draw = function(self, camera)
                if State.prev_state then
                    love.graphics.push()
                    love.graphics.translate(
                        -(State.offset_x), State.prev_state.camera.y)
                    State.prev_state:draw(camera)
                    love.graphics.pop()
                end

                love.graphics.setColor(0.9, 0.9, 0.9, 0.9)
                love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH,
                    SCREEN_HEIGHT)

                love.graphics.setColor(0.1, 0.1, 0.1, 1)
                local b1 = buttons[1]
                local b3 = buttons[4]
                local px = b1.x - 3
                local py = b1.y - 3
                local pr = b1.x + b1.w + 3
                local pb = b3.y + b3.h + 3
                local pw = pr - px
                local ph = pb - py
                love.graphics.rectangle("fill", px, py, pw, ph)

                for i = 1, #buttons do
                    ---@type Button2
                    local button = buttons[i]

                    button:draw()
                end

                mouse_icon:draw()
            end
        }
    },

    ---@param camera JM.Camera.Camera
    draw = function(camera)
        local l, t, r, b = camera:get_viewport_in_world_coord()
        r, b = camera:world_to_screen(r, b)

        local Font = FONT_GUI
        Font:push()
        Font:set_font_size(32)
        Font:printx("<color, 0.1, 0.1, 0.1> PAUSED", 0, 32 * 3, SCREEN_WIDTH,
            "center")
        -- Font:set_font_size(12)
        -- Font:printx("<color, 1, 1, 1>Press ESC if you want to quit", 0, 32 * 5, SCREEN_WIDTH, "center")
        Font:pop()
    end
}

return State
