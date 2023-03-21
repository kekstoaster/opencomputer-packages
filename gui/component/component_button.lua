local component = require("component")
local unicode = require("unicode")
local class = require("class")

local BaseComponent = require("gui/component/component_base")
local border_box = require("gui/border_box")


local Button, static, base = class(BaseComponent)

function Button:new (params)
    params = params or {}
    base.new(self, params)
    self.__padding = params.padding or 0
    self.__text = params.text or ""
end

function Button:set_text(text)
    self.__text = text
    self:get_gpu():invalidate()
end

function Button:get_height()
    return 3
end

function Button:get_width()
    return 2 + 2 * self.__padding + unicode.wlen(self.__text)
end

function Button:render()
    border_box.render_box_single(self:get_gpu(), self:get_x(), self:get_y(), self:get_width(), self:get_height())
    self:get_gpu():set(self:get_x() + self.__padding + 1, self:get_y() + 1, self.__text)
end

return static