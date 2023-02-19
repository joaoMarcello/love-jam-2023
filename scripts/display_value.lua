local Affectable = _G.JM_Affectable

---@type JM.Font.Font
local font

---@class Game.Component.DisplayValue : JM.Template.Affectable
local Display = setmetatable({}, Affectable)
Display.__index = Display

---@param state GameState.Game
function Display:new(state, args)
    args = args or {}
    args.track = args.track or "score"
    args.display = args.display or "SCORE"
    args.x = 32 * 16
    args.y = args.y or (32 * 6)

    local obj = Affectable:new()
    setmetatable(obj, self)
    Display.__constructor__(obj, state, args)
    return obj
end

---@param state GameState.Game
function Display:__constructor__(state, args)
    self.gamestate = state
    self.x = args.x
    self.y = args.y
    self.display = args.display
    self.track = args.track

    self.value = self.gamestate:game_get_param(self.track)

    font = font or state:game_get_gui_font()
end

function Display:load()

end

function Display:finish()

end

--=======================================================================
---@param eff_type JM.Effect.id_string
---@param eff_args any
---@return JM.Effect
function Display:apply_effect(eff_type, eff_args, force)
    if not self.eff_actives then self.eff_actives = {} end

    if self.eff_actives[eff_type] then
        self.eff_actives[eff_type].__remove = true
    end

    self.eff_actives[eff_type] = Affectable.apply_effect(self, eff_type, eff_args)
    return self.eff_actives[eff_type]
end

function Display:flick()
    local eff = self:apply_effect("flickering", { speed = 0.1, duration = 0.2 * 6 })
    eff:set_final_action(function()
        self:set_visible(true)
    end)
end

function Display:update(dt)
    Affectable.update(self, dt)

    self.value = self.gamestate:game_get_param(self.track)
end

function Display:my_draw()
    font:print("<color, 1, 1, 0>" .. string.format("%07d", self.value), self.x, self.y + 32)
end

function Display:draw()
    Affectable.draw(self, self.my_draw)

    font:push()
    font:set_color(_G.JM_Utils:get_rgba(1, 1, 1, 1))
    font:set_font_size(font.__font_size - 6)
    font:print(self.display,
        self.x,
        self.y + 32 - font.__font_size - font.__line_space
    )
    font:pop()
end

return Display
