local component = require("component")
local unicode = require("unicode")
local class = require("class")

local BaseComponent = require("gui/component/component_base")
local border_box = require("gui/border_box")


local ProgressBar, static, base = class(BaseComponent)

function ProgressBar:new(params)
    params = params or {}
    base.new(self, params)
    self.__width = params.width or 20
    self.__value = params.value or 0
    self.__max = params.max or 100
end

function ProgressBar:current_progress()
    return math.max(0, math.min(100, math.floor(100 * self.__value / self.__max)))
end

function ProgressBar:current_progress_width()
    return math.max(0, math.min(self.__width, math.floor(self.__width * self.__value / self.__max)))
end

function ProgressBar:advance()
    self.__value = self.__value + 1
    self:get_gpu():invalidate()
end

function ProgressBar:reset()
    self.__value = 0
    self:get_gpu():invalidate()
end

function ProgressBar:set_max(value)
    self.__max = value
end

function ProgressBar:get_height()
    return 3
end

function ProgressBar:get_width()
    return self.__width + 2
end

function ProgressBar:render()
    border_box.render_box_single(self:get_gpu(), self:get_x(), self:get_y(), self:get_width(), self:get_height())
    local crop = math.floor((self.__width - 3) / 2)

    if (self:current_progress_width() < crop) then
        self:get_gpu():with_color(function()
            self:get_gpu():fill(self:get_x() + 1, self:get_y() + 1, self:current_progress_width(), 1, " ")
        end, 0x000000, 0xFFFFFF)

        if self:current_progress() < 10 then
            self:get_gpu():set(self:get_x() + crop + 2, self:get_y() + 1, self:current_progress() .. "%")
        else
            self:get_gpu():set(self:get_x() + crop + 1, self:get_y() + 1, self:current_progress() .. "%")
        end
    else
        self:get_gpu():with_color(function()
            self:get_gpu():fill(self:get_x() + 1, self:get_y() + 1, crop, 1, " ")
        end, 0x000000, 0xFFFFFF)

        if (self:current_progress_width() < crop + 3) then
            -- erste stelle
            self:get_gpu():with_color(function()
                if self:current_progress() < 10 then
                    self:get_gpu():set(self:get_x() + crop + 1, self:get_y() + 1, " ")
                else
                    self:get_gpu():set(self:get_x() + crop + 1, self:get_y() + 1, "" .. math.floor(self:current_progress() / 10))
                end
            end, 0x000000, 0xFFFFFF)

            if (self:current_progress_width() > crop) then
                self:get_gpu():with_color(function()
                    self:get_gpu():set(self:get_x() + crop + 2, self:get_y() + 1, "" .. (self:current_progress() % 10))
                end, 0x000000, 0xFFFFFF)
            else
                self:get_gpu():set(self:get_x() + crop + 2, self:get_y() + 1, "" .. (self:current_progress() % 10))
            end

            self:get_gpu():set(self:get_x() + crop + 3, self:get_y() + 1, "%")
        else
            self:get_gpu():with_color(function()
                if self:current_progress() < 10 then
                    self:get_gpu():set(self:get_x() + crop + 1, self:get_y() + 1, " " .. self:current_progress() .. "%")
                elseif self:current_progress() == 100 then
                    self:get_gpu():set(self:get_x() + crop, self:get_y() + 1, "100%")
                else
                    self:get_gpu():set(self:get_x() + crop + 1, self:get_y() + 1, self:current_progress() .. "%")
                end
            end, 0x000000, 0xFFFFFF)

            if self:current_progress_width() > crop + 3 then
                self:get_gpu():with_color(function()
                    self:get_gpu():fill(self:get_x() + crop + 4, self:get_y() + 1, self:current_progress_width() - crop - 3, 1, " ")
                end, 0x000000, 0xFFFFFF)
            end
        end
    end
end


return static