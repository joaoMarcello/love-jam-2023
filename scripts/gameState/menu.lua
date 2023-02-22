local Button = require "scripts.button2"
local MouseIcon = require "scripts.mouseIcon2"

---@class GameState.Menu : JM.Scene, GameState
local State = _G.JM_Love2D_Package.Scene:new(nil, nil, nil, nil, SCREEN_WIDTH, SCREEN_HEIGHT)

State.camera:toggle_debug()
State.camera:toggle_grid()
State.camera:toggle_world_bounds()
State.camera.border_color = { 0, 0, 0, 0 }

State:set_color(0.8, 0.8, 1, 1)
--============================================================================
local buttons

local time_off

---@type JM.Font.Phrase|nil
local phrase

---@type MouseIcon2
local mouse_icon

--============================================================================
State:implements {
    load = function()
        Button:load(_G.FONT_GUI)
        MouseIcon:load()
    end,
    --
    --
    init = function()
        time_off = 0.0

        ---@type Button2
        local bt_start = Button:new(State, { y = 32 * 10 })

        ---@type Button2
        local bt_credits = Button:new(State, {
            text = "Credits",
            y = bt_start.y + bt_start.h + 1
        })

        ---@type Button2
        local bt_quit = Button:new(State, {
            text = "Quit",
            y = bt_credits.y + bt_credits.h + 1
        })
        --==========================================================

        bt_start:on_event("mouse_pressed", function(x, y, button)
            CHANGE_GAME_STATE(require "scripts.gameState.howToPlay")
        end)

        bt_quit:on_event("mouse_pressed", function(x, y, button)
            collectgarbage()
            love.event.quit()
        end)

        buttons = {
            bt_start,
            bt_credits,
            bt_quit
        }

        local font = _G.JM_Font:get_font("komika text")
        if font then
            font:push()
            font:set_font_size(3)
            phrase = font:generate_phrase(
                "This game was made for <bold>Löve Jam 2023</bold no-space>.",
                0,
                32, SCREEN_WIDTH,
                "center")
            font:pop()
        end

        mouse_icon = MouseIcon:new(State)
        mouse_icon.x = 32 * 16
        mouse_icon.y = 32 * 7

        _G.PLAY_SONG("title")
    end,
    --
    --
    finish = function()
        Button:finish()
        -- buttons = nil
        phrase = nil
        local audio = _G.Pack.Sound:stop_all()
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
        if time_off <= 0.6 then
            return
        end

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
    draw = function(camera)
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
        local b1 = buttons[1]
        local b3 = buttons[3]
        local px = b1.x - 3
        local py = b1.y - 3
        local pr = b1.x + b1.w + 3
        local pb = b3.y + b3.h + 3
        local pw = pr - px
        local ph = pb - py
        love.graphics.rectangle("fill", px, py, pw, ph)

        for i = 1, #buttons do
            ---@type Button
            local button = buttons[i]

            button:draw()
        end

        if phrase then
            phrase.__font:push()
            phrase.__font:set_font_size(9)
            phrase:draw(0, SCREEN_HEIGHT - 32, "center")
            phrase.__font:pop()
        end

        mouse_icon:draw()
    end,
    --
}

return State
