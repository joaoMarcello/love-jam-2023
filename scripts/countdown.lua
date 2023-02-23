local Affectable = _G.JM_Affectable

---@type JM.Font.Font|any
local font

---@type love.Image|any
local img

---@class CountDown: JM.Template.Affectable
local Count = setmetatable({}, Affectable)
Count.__index = Count

function Count:new(args)
    args = args or {}
    local obj = Affectable:new()
    setmetatable(obj, self)
    Count.__constructor__(obj, args)
    return obj
end

function Count:__constructor__(args)
    self.x = args.x or (32 * 5)
    self.y = 32 * 6
    self.w = 32 * 6
    self.h = 32 * 3

    self.objects = {
        font:generate_phrase("<bold>1", self.x, self.y, self.x + self.w, "center"),
        font:generate_phrase("<bold>2", self.x, self.y, self.x + self.w, "center"),
        font:generate_phrase("<bold>3", self.x, self.y, self.x + self.w, "center"),
        font:generate_phrase("<bold><effect=scream> LET'S CONNECT!!!", self.x, self.y, self.x + self.w, "center"),
    }

    self.time = 0
    self.speed = 1
    self.n_objects = #self.objects

    self.ox = self.w / 2
    self.oy = self.h / 2

    self.current = 1
    self.lock = true
    self.__release = false

    local eff = self:apply_effect("popin", { delay = 0.9 })
    eff:set_final_action(function()
        self.lock = false
        PLAY_SFX("countdown")
    end)

    self.anima = _G.JM_Anima:new {
        img = img,
        max_filter = 'linear'
    }

    self.anima:apply_effect('float', { range = 3, speed = 1 })
    self:apply_effect('float', { range = 3, speed = 1 })
end

function Count:load()
    font = _G.FONT_GUI
    img = img or love.graphics.newImage('/data/image/placa.png')
end

function Count:finish()
    font = nil
    local r = img and img:release()
    img = nil
end

function Count:is_released()
    return self.__release
end

function Count:update(dt)
    Affectable.update(self, dt)
    self.anima:update(dt)

    if not self.lock then
        self.time = self.time + dt

        if self.time >= self.speed and self.current < 4 then
            self.time = self.time - self.speed
            self.current = self.current + 1
            self:apply_effect("popin")

            if self.current ~= 4 then
                PLAY_SFX("countdown")
            else
                PLAY_SFX('shoot')
            end
            --
        elseif self.time >= self.speed + 0.5 then
            if not self.__release then
                self.__release = true
                -- _G.PLAY_SONG("game")
            end
        end
    end
end

function Count:draw_shadow()
    self.anima:set_color2(0, 0, 0, 0.3)
    self.anima:set_scale(0.95, 0.95)
    self.anima:draw(self.x + self.w / 2, self.y + self.h / 2 + 15)
    self.anima:set_scale(1, 1)
    self.anima:set_color2(1, 1, 1, 1)
end

function Count:my_draw()
    ---@type JM.Font.Phrase
    local obj = self.objects[self.current]

    local h = obj:text_height(obj:get_lines(self.x))

    obj:draw(self.x, self.y + self.h / 2 - h / 2, "center")
    -- font:print(self.__release and "true" or "false", self.x, self.y - 20)
end

function Count:draw()
    self:draw_shadow()
    self.anima:draw(self.x + self.w / 2, self.y + self.h / 2)

    -- love.graphics.setColor(0.9, 0.9, 0.9)
    -- love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- love.graphics.setColor(0, 0, 0, 1)
    -- love.graphics.rectangle("line", self.x, self.y, self.w, self.h)


    Affectable.draw(self, self.my_draw)
end

return Count
