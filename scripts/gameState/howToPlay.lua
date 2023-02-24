local MouseIcon = require 'scripts.mouseIcon2'
local Button = require 'scripts.button_endgame'

---@class GameState.HowToPlay : JM.Scene, GameState
local State = _G.JM_Love2D_Package.Scene:new(nil, nil, nil, nil, SCREEN_WIDTH, SCREEN_HEIGHT)

State.camera:toggle_debug()
State.camera:toggle_grid()
State.camera:toggle_world_bounds()
State.camera.border_color = { 0, 0, 0, 0 }

State:set_color(0.9, 0.9, 0.9, 1)
--===========================================================================
---@type MouseIcon2|any
local mouse_icon

---@type Button|any
local button_skip

local text_obj
--===========================================================================
State:implements {
    load = function()
        MouseIcon:load()
        Button:load(FONT_GUI)
    end,

    init = function()
        button_skip = Button:new(State, {
            text = "Done"
        })
        button_skip.y = SCREEN_HEIGHT - button_skip.h - 32
        button_skip.x = SCREEN_WIDTH - button_skip.w - 64

        button_skip:on_event("mouse_pressed", function(x, y)
            CHANGE_GAME_STATE(require 'scripts.gameState.game')
        end)

        mouse_icon = MouseIcon:new(State)
        mouse_icon.x = button_skip.x - mouse_icon.w - 32
        mouse_icon.y = button_skip.y - mouse_icon.h

        local font = FONT_GUI
        local pw, ph
        local how_to, pw, ph = font:generate_phrase("<bold> <color> <effect=ghost, min=0.2, speed=1.3>HOW TO PLAY", 0, 0,
            SCREEN_WIDTH, "center")

        local objective_py = 16 + ph + 3
        local objective, pw, ph = font:generate_phrase(
            "<color, 0, 0, 1> <font-size=16>Objective</font-size></color no-space>:", 32,
            objective_py, SCREEN_WIDTH, "left")

        local objective_text_py = objective_py + ph + 3
        local objective_text, pw, ph = font:generate_phrase(
            "- Watch the <bold>lamp's color</bold> at the top of the screen and connect all the <bold>plugs</bold> in the appropriated <bold>socket</effect></bold no-space>.",
            64,
            16 + ph + font.__line_space,
            SCREEN_WIDTH, "left"
        )

        local control_py = objective_text_py + ph + 20
        local control, pw, ph = font:generate_phrase("<color, 0, 0, 1> <font-size=16>Controls</color no-space>:", 32,
            control_py,
            SCREEN_WIDTH, "left")

        local control_text_py = control_py + ph + 3
        local control_text = font:generate_phrase(
            "- Move the <bold>glove</bold> with mouse.\n - Click the mouse's left button to grab a plug (click again to connect it to a socket). \n - Release the plug pressing the mouse's right button.",
            64, control_text_py, SCREEN_WIDTH,
            "left")

        text_obj = {
            { obj = how_to,         x = 32,           y = 16,                size = font.__font_size },
            --
            { obj = objective,      y = objective_py, align = "left" },
            --
            { obj = objective_text, x = 64,           y = objective_text_py, align = "left" },
            --
            { obj = control,        x = 32,           y = control_py,        align = "left" },
            --
            { obj = control_text,   x = 64,           y = control_text_py,   align = "left" }
        }
    end,

    finish = function()
        mouse_icon = nil
        button_skip = nil
        text_obj = nil
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

    mousemoved = function(x, y, dx, dy, istouch)
        mouse_icon:mouse_moved(x, y, dx, dy)
    end,

    mousepressed = function(x, y, button)
        x, y = mouse_icon.x, mouse_icon.y
        button_skip:mouse_pressed(x, y, button)
    end,

    update = function(dt)
        mouse_icon:update(dt)

        local mx, my = mouse_icon.x, mouse_icon.y

        local button = button_skip
        local one_bt_is_focused = false

        if button:check_collision(mx, my, 0, 0) then
            if not button.on_focus then
                button:set_focus(true)
            end
        elseif button.on_focus then
            button:set_focus(false)
        end

        button:update(dt)

        if button.on_focus then
            one_bt_is_focused = true
        end

        mouse_icon:set_state(one_bt_is_focused and mouse_icon.States.point or mouse_icon.States.normal)
    end,
    --
    --
    ---@param camera JM.Camera.Camera
    draw = function(camera)
        button_skip:draw()

        for i = 1, #text_obj do
            ---@type JM.Font.Phrase
            local phrase = text_obj[i].obj

            phrase:draw(text_obj[i].x or 32, text_obj[i].y or 0, text_obj[i].align or "center")
        end

        mouse_icon:draw()
    end
}

return State
