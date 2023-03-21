local component = require("component")
local unicode = require("unicode")

local component_base = require("gui/component/component_base")
local border_box = require("gui/border_box")


local component_progress_bar = component_base:meta()
component_progress_bar["__index"] = component_progress_bar

function component_progress_bar:new (a)
    a = a or {}
    local o = component_base:new(a)
    o.width = a.width or 20
    o.value = a.value or 0
    o.max = a.max or 100

    setmetatable(o, component_progress_bar)
    return o
end

function component_progress_bar:current_progress()
    return math.max(0, math.min(100, math.floor(100 * self.value / self.max)))
end

function component_progress_bar:current_progress_width()
    return math.max(0, math.min(self.width, math.floor(self.width * self.value / self.max)))
end

function component_progress_bar:advance()
    self.value = self.value + 1
end

function component_progress_bar:reset()
    self.value = 0
end


function component_progress_bar:get_height()
    return 3
end

function component_progress_bar:get_width()
    return self.width + 2
end

function component_progress_bar:render()
    border_box.render_box_single(self.gpu, self:get_x(), self:get_y(), self:get_width(), self:get_height())
    local crop = math.floor((self.width - 3) / 2)

    if (self:current_progress_width() < crop) then
        self.gpu:with_color(function()
            self.gpu:fill(self:get_x() + 1, self:get_y() + 1, self:current_progress_width(), 1, " ")
        end, 0x000000, 0xFFFFFF)

        if self:current_progress() < 10 then
            self.gpu:set(self:get_x() + crop + 2, self:get_y() + 1, self:current_progress() .. "%")
        else
            self.gpu:set(self:get_x() + crop + 1, self:get_y() + 1, self:current_progress() .. "%")
        end
    else
        self.gpu:with_color(function()
            self.gpu:fill(self:get_x() + 1, self:get_y() + 1, crop, 1, " ")
        end, 0x000000, 0xFFFFFF)

        if (self:current_progress_width() < crop + 3) then
            -- erste stelle
            self.gpu:with_color(function()
                if self:current_progress() < 10 then
                    self.gpu:set(self:get_x() + crop + 1, self:get_y() + 1, " ")
                else
                    self.gpu:set(self:get_x() + crop + 1, self:get_y() + 1, "" .. math.floor(self:current_progress() / 10))
                end
            end, 0x000000, 0xFFFFFF)

            if (self:current_progress_width() > crop) then
                self.gpu:with_color(function()
                    self.gpu:set(self:get_x() + crop + 2, self:get_y() + 1, "" .. (self:current_progress() % 10))
                end, 0x000000, 0xFFFFFF)
            else
                self.gpu:set(self:get_x() + crop + 2, self:get_y() + 1, "" .. (self:current_progress() % 10))
            end

            self.gpu:set(self:get_x() + crop + 3, self:get_y() + 1, "%")
        else
            self.gpu:with_color(function()
                if self:current_progress() < 10 then
                    self.gpu:set(self:get_x() + crop + 1, self:get_y() + 1, " " .. self:current_progress() .. "%")
                elseif self:current_progress() == 100 then
                    self.gpu:set(self:get_x() + crop, self:get_y() + 1, "100%")
                else
                    self.gpu:set(self:get_x() + crop + 1, self:get_y() + 1, self:current_progress() .. "%")
                end
            end, 0x000000, 0xFFFFFF)

            if self:current_progress_width() > crop + 3 then
                self.gpu:with_color(function()
                    self.gpu:fill(self:get_x() + crop + 4, self:get_y() + 1, self:current_progress_width() - crop - 3, 1, " ")
                end, 0x000000, 0xFFFFFF)
            end
        end
    end
end


return component_progress_bar