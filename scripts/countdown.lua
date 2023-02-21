local Affectable = _G.JM_Affectable

---@type JM.Font.Font|any
local font

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
        font:generate_phrase("1", self.x, self.y, self.x + self.w, "center"),
        font:generate_phrase("2", self.x, self.y, self.x + self.w, "center"),
        font:generate_phrase("3", self.x, self.y, self.x + self.w, "center"),
        font:generate_phrase("<effect=scream> LET'S CONNECT!!!", self.x, self.y, self.x + self.w, "center"),
    }

    self.time = 0
    self.speed = 1
    self.n_objects = #self.objects

    self.ox = self.w / 2
    self.oy = self.h / 2

    self.current = 1
    self.lock = true
    self.__release = false

    local eff = self:apply_effect("popin", { delay = 0.4 })
    eff:set_final_action(function()
        self.lock = false
    end)
end

function Count:load()
    font = _G.FONT_GUI
end

function Count:finish()
    font = nil
end

function Count:is_released()
    return self.__release
end

function Count:update(dt)
    Affectable.update(self, dt)

    if not self.lock then
        self.time = self.time + dt

        if self.time >= self.speed and self.current < 4 then
            self.time = self.time - self.speed
            self.current = self.current + 1
            self:apply_effect("popin")
            --
        elseif self.time >= self.speed + 0.5 then
            if not self.__release then
                self.__release = true
            end
        end
    end
end

function Count:my_draw()
    ---@type JM.Font.Phrase
    local obj = self.objects[self.current]

    local h = obj:text_height(obj:get_lines(self.x))

    obj:draw(self.x, self.y + self.h / 2 - h / 2, "center")
    -- font:print(self.__release and "true" or "false", self.x, self.y - 20)
end

function Count:draw()
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    Affectable.draw(self, self.my_draw)
end

return Count
