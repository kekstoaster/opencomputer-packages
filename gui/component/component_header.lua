local component = require("component")
local unicode = require("unicode")
local class = require("class")

local BaseComponent = require("gui/component/component_base")
local border_box = require("gui/border_box")


local Header, static, base = class(BaseComponent)

function Header:new(params)
    params = params or {}
    base.new(self, params)
    self.__padding = params.padding or 5
    self.__text = params.text or ""
end

function Header:get_height()
    return 5
end

function Header:get_width()
    return 2 + 2 * self.__padding + unicode.wlen(self.__text)
end

function Header:render()
    local pw = self:get_parent():get_width()
    local sw = self:get_width()
    local x2 = (pw - sw) / 2
    border_box.render_box_double(self:get_gpu(), x2, self:get_y(), sw, self:get_height())
    self:get_gpu():set(x2 + self.__padding + 1, self:get_y() + 2, self.__text)
end

return static