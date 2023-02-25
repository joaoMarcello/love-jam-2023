local MouseIcon = require 'scripts.mouseIcon2'
local Button = require 'scripts.button_endgame'

---@class GameState.Credits : JM.Scene, GameState
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

---@type JM.Font.Phrase|any
local text_obj

---@type JM.Font.Font
local font
--===========================================================================
State:implements {
    load = function()
        MouseIcon:load()
        font = _G.FONT_GUI
        Button:load(_G.FONT_GUI)
    end,

    init = function()
        button_skip = Button:new(State, {
            text = "Done"
        })
        button_skip.y = SCREEN_HEIGHT - button_skip.h - 32
        button_skip.x = SCREEN_WIDTH - button_skip.w - 64

        button_skip:on_event("mouse_pressed", function(x, y)
            local menu = require 'scripts.gameState.menu'
            local icon = menu:menu_get_mouse_icon()
            icon.x = mouse_icon.x
            icon.y = mouse_icon.y
            CHANGE_GAME_STATE(menu, nil, true, nil, nil, nil, true)
        end)

        local blue = string.format("<color, %.2f, %.2f, %.2f>", 88 / 255, 141 / 255, 190 / 255)
        text_obj = font:generate_phrase(
            string.format(
                "Game made for <bold>Löve Jam 2023</effect></bold no-space>. Code and art by <bold>%sJoão Moreira</color></bold no-space>.\n \n Music and SFX were taken from free sources (<font-size=10>freesound.org, musonpen.org</font-size>).\n \n <bold>Song</bold no-space>:\n \t'Pumped' by %s<bold>Justin Mahar</bold></color no-space>.\n \n <bold>SFX</bold no-space>: \n \t'Click' by <bold>%slebaston100</color></bold no-space>.\n \t'Tick-Tock' by <bold> %s FoolBoyMedia </color></bold no-space>.\n \t'Electric Shock 2 Hit</font-size no-space>' by <bold>%sThe-Sacha-Rush</color></bold no-space>.\n \t'Bip' by <bold>%sSlanesh</color></bold no-space>.\n \t'Gun Shoot' by <bold>%sMichel Hollicardo</color></bold no-space>.\n \n <bold> Fonts</bold>(<font-size=9>from Google Fonts</font-size>):\n \t'Black Ops One'</bold> by <bold>%sJames Grieshaber</color></bold> and <bold>%sEben Sorkin</bold></color no-space>.\n \t'Orbitron'</bold> by <bold>%sMatt McInerney</color></bold no-space>.",
                blue, blue, blue, blue, blue, blue, blue, blue, blue, blue), 32, 32,
            SCREEN_WIDTH, "left")

        mouse_icon = MouseIcon:new(State)
        mouse_icon.x = button_skip.x - mouse_icon.w - 32
        mouse_icon.y = button_skip.y - mouse_icon.h
    end,


    finish = function()
        button_skip = nil
        mouse_icon = nil
        text_obj = nil
    end,


    mousepressed = function(x, y, button)
        x, y = mouse_icon.x, mouse_icon.y
        button_skip:mouse_pressed(x, y, button)
    end,

    mousemoved = function(x, y, dx, dy, istouch)
        mouse_icon:mouse_moved(x, y, dx, dy)
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

    ---@param camera JM.Camera.Camera
    draw = function(camera)
        button_skip:draw()

        font:push()
        font:set_font_size(11)
        text_obj:draw(32, 32, "left")
        font:pop()
        mouse_icon:draw()
    end
}

return State
