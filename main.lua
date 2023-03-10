local love = _G.love
love.filesystem.setIdentity("WIRES")

Pack = require "jm-love2d-package.init"

math.randomseed(os.time())
love.graphics.setBackgroundColor(0, 0, 0, 1)
love.graphics.setDefaultFilter("nearest", "nearest")
love.mouse.setVisible(true)
love.mouse.setRelativeMode(true)

collectgarbage("setstepmul", 150)
collectgarbage("setpause", 250)

---@type JM.Font.Font|any
FONT_GUI = nil

---@type JM.Font.Font|any
FONT_LEVEL = nil

---@class GameState: JM.Scene
---@field load function
---@field init function
---@field finish function
---@field update function
---@field draw function
---@field keypressed function
---@field prev_state GameState|nil

--==================================================================

SCREEN_HEIGHT = Pack.Utils:round(480 + 16) -- 32*15
SCREEN_WIDTH = Pack.Utils:round(720)       -- *1.5
local initial_state = 'splash'

--==================================================================

---@type GameState
local scene

---@param new_state GameState
function CHANGE_GAME_STATE(new_state, skip_finish, skip_load, save_prev, skip_collect, skip_fadein, skip_init)
    -- local p = scene and scene:init()
    local r = scene and not skip_finish and scene:finish()
    new_state.prev_state = save_prev and scene or nil
    r = (not skip_load) and new_state:load()
    r = (not skip_init) and new_state:init()
    r = (not skip_collect) and collectgarbage()
    scene = new_state
    r = not skip_fadein and scene:fadein(nil, nil, nil)
end

function RESTART(state)
    CHANGE_GAME_STATE(state, true, true, false, false)
end

function PAUSE(state)
    CHANGE_GAME_STATE(state, true, false, true, true, true)
end

---@param state GameState
function UNPAUSE(state)
    if not state then return end
    state.prev_state.camera.desired_scale = state.camera.desired_scale
    CHANGE_GAME_STATE(state.prev_state, true, true, false, false, true, true)
end

function PLAY_SFX(name, force)
    Pack.Sound:play_sfx(name, force)
end

function PLAY_SONG(name)
    Pack.Sound:play_song(name)
end

--=========================================================================

function love.load()
    --
    FONT_GUI = Pack.FontGenerator:new_by_ttf {
        path = "/data/font/Orbitron/Orbitron-Medium.ttf",
        path_bold = "data/font/Orbitron/Orbitron-Bold.ttf",
        dpi = 32,
        name = "orbitron",
        font_size = 18,
        character_space = 0
    }

    FONT_LEVEL = Pack.FontGenerator:new_by_ttf {
        path = '/data/font/BlackOpsOne-Regular.ttf',
        dpi = 32,
        name = 'black ops one',
        font_size = 18,
        character_space = 0
    }

    local Sound = _G.JM_Love2D_Package.Sound
    Sound:add_sfx("/data/sfx/192277__lebaston100__click cutted .wav", "plug")
    Sound:add_sfx("/data/sfx/657803__the-sacha-rush__electric-shock-2-hit.wav", "shock")
    Sound:add_sfx("/data/sfx/264498__foolboymedia__tick-tock.wav", "tick tock")
    Sound:add_sfx("/data/sfx/31780__slanesh__bip-cutted.ogg", "countdown")
    Sound:add_sfx("/data/sfx/52593_michel-hollicardo_gun_shoot_cutted.ogg", "shoot", 0.1)

    Sound:add_song("/data/song/Justin-Mahar-Pumped.ogg", "title")

    CHANGE_GAME_STATE(require('scripts.gameState.' .. initial_state), true)
end

function love.keypressed(key)
    if key == "escape"
        or (key == "f4" and (love.keyboard.isDown("lalt")
        or love.keyboard.isDown("ralt")))
    then
        scene:finish()
        love.event.quit()
        return
    end

    local r = scene and scene:keypressed(key)
end

function love.keyreleased(key)
    local r = scene and scene:keyreleased(key)
end

function love.mousepressed(x, y, button, istouch, presses)
    scene:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    scene:mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    scene:mousemoved(x, y, dx, dy, istouch)
end

local km = nil
function love.update(dt)
    km = collectgarbage("count") / 1024.0
    Pack:update(dt)
    scene:update(dt)
end

function love.draw()
    scene:draw()

    -- love.graphics.setColor(0, 0, 0, 0.7)
    -- love.graphics.rectangle("fill", 0, 0, 80, 120)
    -- love.graphics.setColor(1, 1, 0, 1)
    -- love.graphics.print(string.format("Memory:\n\t%.2f Mb", km), 5, 10)
    -- love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 5, 50)
    -- local maj, min, rev, code = love.getVersion()
    -- love.graphics.print(string.format("Version:\n\t%d.%d.%d", maj, min, rev), 5, 75)
end
