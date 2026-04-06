local unicode = require("unicode")
local class = require("class")

local BaseComponent = require("gui/component/component_base")
local border_box = require("gui/border_box")


local RadioList, static, base = class(BaseComponent)

function RadioList:new (params)
    params = params or {}
    base.new(self, params)
    self.__options = {}
    self.__selected_index = 1
    self.__spacing = params.spacing or 2
    if params.select ~= nil then
        self.__select_fn = params.select
    end
end

function RadioList:value()
    return self.__options[self.__selected_index].value
end

function RadioList:add_option(name, value)
    table.insert(self.__options, {name=tostring(name), value=value})
    self:get_gpu():invalidate()
end

function RadioList:select(value)
    for i = 1,#self.__options do
        local item = self.__options[i]
        if item.value == value then
            self.__selected_index = i
            self:get_gpu():invalidate()
            break
        end
    end
end

function RadioList:get_height()
    return 3
end

function RadioList:get_width()
    local txt_len = 0
    if #self.__options > 0 then
        for k, v in ipairs(self.__options) do
            txt_len = txt_len + unicode.wlen(v.name)
        end
        txt_len = txt_len + 4 + (4 + self.__spacing) * (#self.__options - 1)
    end
    return txt_len
end

function RadioList:click(x, y)
    local clicked_index = nil
    local txt_len = 0
    local selected_value = nil
    if #self.__options > 0 then
        for k, v in ipairs(self.__options) do
            local length = unicode.wlen(v.name) + 4
            if x >= txt_len and x < txt_len + length then
                clicked_index = k
                selected_value = v.value
                break
            end
            txt_len = txt_len + unicode.wlen(v.name) + 4 + self.__spacing
        end

        if clicked_index ~= nil and clicked_index ~= self.__selected_index then
            self.__selected_index = clicked_index
            self:get_gpu():invalidate()
            if self.__select_fn ~= nil then
                self.__select_fn(selected_value)
            end
        end
    end
end

function RadioList:render()
    if #self.__options > 0 then
        local xp = 0
        for k, v in ipairs(self.__options) do
            local cb = function()
                border_box.render_box_single(self:get_gpu(), self:get_x() + xp, self:get_y(), unicode.wlen(v.name) + 4, self:get_height())
                self:get_gpu():set(self:get_x() + xp + 2, self:get_y() + 1, v.name)
            end
            if k == self.__selected_index then
                self:get_gpu():with_color(cb, 0x0000FF)
            else
                cb()
            end
            xp = xp + unicode.wlen(v.name) + 4 + self.__spacing
        end
    end
end

return static
