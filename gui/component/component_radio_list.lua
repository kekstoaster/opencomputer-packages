local component = require("component")
local unicode = require("unicode")

local component_base = require("gui/component/component_base")
local border_box = require("gui/border_box")


local component_radio_list = component_base:new()
component_radio_list["__index"] = component_radio_list

function component_radio_list:new (a)
    a = a or {}
    local o = component_base:new(a)
    o.options = {}
    o.selected_index = 1
    o.spacing = a.spacing or 2
    if a.select ~= nil then
        o.select_fn = a.select
    end
    setmetatable(o, component_radio_list)
    return o
end

function component_radio_list:value()
    return self.options[self.selected_index].value
end

function component_radio_list:add_option(name, value)
    table.insert(self.options, {name=tostring(name), value=value})
    self.gpu:invalidate()
end

function component_radio_list:select(value)
    for i = 1,#self.options do
        local item = self.options[i]
        if item.value == value then
            self.selected_index = i
            self.gpu:invalidate()
            break
        end
    end
end

function component_radio_list:get_height()
    return 3
end

function component_radio_list:get_width()
    local txt_len = 0
    if #self.options > 0 then
        for k, v in ipairs(self.options) do
            txt_len = txt_len + unicode.wlen(v.name)
        end
        txt_len = txt_len + 4 + (4 + self.spacing) * (#self.options - 1)
    end
    return txt_len
end

function component_radio_list:click(x, y)
    local clicked_index = nil
    local txt_len = 0
    local selected_value = nil
    if #self.options > 0 then
        for k, v in ipairs(self.options) do
            local length = #v.name + 4
            if x >= txt_len and x < txt_len + length then
                clicked_index = k
                selected_value = v.value
                break
            end
            txt_len = txt_len + unicode.wlen(v.name) + 4 + self.spacing
        end

        if clicked_index ~= nil and clicked_index ~= self.selected_index then
            self.selected_index = clicked_index
            self.gpu:invalidate()
            if self.select_fn ~= nil then
                self.select_fn(selected_value)
            end
        end
    end
end

function component_radio_list:render()
    if #self.options > 0 then
        local xp = 0
        for k, v in ipairs(self.options) do
            local cb = function()
                border_box.render_box_single(self.gpu, self:get_x() + xp, self:get_y(), unicode.wlen(v.name) + 4, self:get_height())
                self.gpu:set(self:get_x() + xp + 2, self:get_y() + 1, v.name)
            end
            if k == self.selected_index then
                self.gpu:with_color(cb, 0x0000FF)
            else
                cb()
            end
            xp = xp + unicode.wlen(v.name) + 4 + self.spacing
        end
    end
end

return component_radio_list