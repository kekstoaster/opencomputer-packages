local component = require("component")
local unicode = require("unicode")
--local math = require("math")

local component_base = require("gui/component/component_base")
local border_box = require("gui/border_box")


local component_label_row = component_base:new()
component_label_row["__index"] = component_label_row

function component_label_row:new (a)
    a = a or {}
    local o = component_base:new(a)
    o.text = a.text or ""
    o.old_text = o.text
    o.padding = a.padding or 0
    o.align = a.align or "left"

    setmetatable(o, component_label_row)
    if a.component ~= nil then
        o:set_component(a.component)
    end
    return o
end

function component_label_row:key_down(char, code)
    if self.child ~= nil then
        self.child:key_down(char, code)
    end
end

function component_label_row:clipboard(text)
    if self.child ~= nil then
        self.child:clipboard(text)
    end
end

function component_label_row:set_text(text)
    self.text = text
    self.gpu:invalidate()
end

function component_label_row:set_component(child)
    self.child = child
    child:set_parent(self)
    child.x = self:get_child_x()
    child.y = 0
end

function component_label_row:get_height()
    if self.child ~= nil then
        return self.child:get_height()
    else
        return 1
    end
end

function component_label_row:get_width()
    if self.child ~= nil then
        return self:get_child_x() + self.child:get_width()
    else
        return self:get_child_x()
    end

end

function component_label_row:get_child_x()
    if unicode.wlen(self.text) > self.padding then
        return unicode.wlen(self.text)
    else
        return self.padding
    end
end

function component_label_row:click(x, y)
    if self.child ~= nil and self.child.visible then
        self.child:checkClicked(x, y)
    end
end

function component_label_row:blur()
    if self.has_focus then
        if self.child ~= nil then
            self.child:blur()
        end
        self.has_focus = false
        if self.blur_fn ~= nil then
            self.blur_fn()
            self.gpu:invalidate()
        end
    end
end

function component_label_row:align_x()
    if self.align == "right" then
        if unicode.wlen(self.text) > self.padding then
            return self:get_x()
        else
            return self:get_x() + (self.padding - unicode.wlen(self.text))
        end
    else
        return self:get_x()
    end
end

function component_label_row:render()
    self.gpu:set(self:align_x(), self:get_y() + math.floor(self:get_height() / 2), self.text)
    if unicode.wlen(self.text) < unicode.wlen(self.old_text) then
        if self.align == "right" then
            self.gpu:fill(self:get_x(), self:get_y() + math.floor(self:get_height() / 2), unicode.wlen(self.old_text) - unicode.wlen(self.text), 1, " ")
        else
            self.gpu:fill(self:get_x() + unicode.wlen(self.text), self:get_y() + math.floor(self:get_height() / 2), unicode.wlen(self.old_text) - unicode.wlen(self.text), 1, " ")
        end
    end
    self.old_text = self.text
    if self.child ~= nil and self.child.visible then
        self.child:render()
    end
end


return component_label_row