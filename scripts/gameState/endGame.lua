local Pack = _G.JM_Love2D_Package

---@class GameState.EndGame : JM.Scene, GameState
local State = _G.JM_Love2D_Package.Scene:new(nil, nil, nil, nil, SCREEN_WIDTH, SCREEN_HEIGHT)

State.camera:toggle_debug()
State.camera:toggle_grid()
State.camera:toggle_world_bounds()
State.camera.border_color = { 0, 0, 0, 0 }
--==========================================================================

---@type GameState.Game|nil
local gameState

local score, hi_score, level, shocks, last_hi_score

local text
--==========================================================================

State:implements {
    load = function()

    end,
    --
    --
    init = function()
        gameState = require "scripts.gameState.game"
        gameState:load()
        gameState:init()

        score = gameState:game_get_param("score")
        hi_score = gameState:game_get_param("hi_score")
        level = gameState:game_get_param("level")
        shocks = gameState:game_get_param("shocks")
        last_hi_score = gameState:game_get_param("last_hi_score")
    end,
    --
    --
    finish = function()
        gameState = nil
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

    end,
    --
    --
    update = function(dt)

    end,
    --
    --
    layers = {
        {
            name = "main",

            ---@param camera JM.Camera.Camera
            draw = function(self, camera)
                if gameState then
                    local font = gameState:game_get_gui_font()

                    local px, py = 32 * 4, 32 * 2
                    local right = SCREEN_WIDTH - px

                    font:push()

                    font:printf("END GAME", px, py, "center", right)

                    font:printf("Max Level " .. level, px, py + 32 * 2, "left", right)

                    font:printf("Number of shocks: " .. shocks, px, py + 32 * 3.5, "left", right)

                    font:printf("Hi Score: " .. hi_score, px, py + 32 * 5, "left", right)

                    local text = "Score: " .. score
                    if last_hi_score < score then
                        text = text ..
                            " <font-size=12> <effect=ghost, speed = 0.9, min=0.4>   <color>\t NEW HI SCORE </color>"
                    end

                    font:printx(text, px, py + 32 * 6.5, right, "left")

                    font:pop()
                end
            end
        }
    }
    --
}

return State
