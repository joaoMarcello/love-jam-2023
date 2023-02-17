local love = _G.love
local Pack = _G.Pack

---@class GameState.Game : JM.Scene, GameState
local State = Pack.Scene:new(nil, nil, nil, nil, SCREEN_WIDTH, SCREEN_HEIGHT,
    {
        top = 0,
        left = 0,
        width = 32 * 40,
        bottom = SCREEN_HEIGHT
    })

State.camera:toggle_debug()
State.camera:toggle_grid()
State.camera:toggle_world_bounds()
State.camera.border_color = { 0, 0, 0, 0 }

--============================================================================
State:implements({
    keypressed = function(key)
        if key == "o" then
            State.camera:toggle_grid()
            State.camera:toggle_debug()
            State.camera:toggle_world_bounds()
        end
    end,
    --
    --
    update = function(dt)

    end,
    --
    --
    draw = function(camera)

    end
})

return State
