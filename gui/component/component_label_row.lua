local component = require("component")
local unicode = require("unicode")
local class = require("class")
local os = require("os")

local serialization = require("serialization")

local BaseComponent = require("gui/component/component_base")
local border_box = require("gui/border_box")


local LabelRow, static, base = class(BaseComponent)

function LabelRow:new(params)
    params = params or {}
    base.new(self, params)
    self.__text = params.text or ""
    self.__old_text = self.__text
    self.__padding = params.padding or 0
    self.__align = params.align or "left"
    self:set_component(params.component)
end

function LabelRow:key_down(char, code)
    if self.child ~= nil then
        self.child:key_down(char, code)
    end
end

function LabelRow:clipboard(text)
    if self.child ~= nil then
        self.child:clipboard(text)
    end
end

function LabelRow:set_text(text)
    self.__text = text .. ""
    self:get_gpu():invalidate()
end

function LabelRow:set_component(child)
    self.child = child
    if child ~= nil then
        child:set_parent(self)
        child:set_x(self:get_child_x())
        child:set_y(0)
    end
end

function LabelRow:get_height()
    if self.child ~= nil then
        return self.child:get_height()
    else
        return 1
    end
end

function LabelRow:get_width()
    if self.child ~= nil then
        return self:get_child_x() + self.child:get_width()
    else
        return self:get_child_x()
    end

end

function LabelRow:get_child_x()
    if unicode.wlen(self.__text) > self.__padding then
        return unicode.wlen(self.__text)
    else
        return self.__padding
    end
end

function LabelRow:click(x, y)
    if self.child ~= nil and self.child:is_visible() then
        self.child:checkClicked(x, y)
    end
end

function LabelRow:blur()
    if self.has_focus then
        if self.child ~= nil then
            self.child:blur()
        end
        self.has_focus = false
        if self.blur_fn ~= nil then
            self.blur_fn()
            self:get_gpu():invalidate()
        end
    end
end

function LabelRow:align_x()
    if self.__align == "right" then
        if unicode.wlen(self.__text) > self.__padding then
            return self:get_x()
        else
            return self:get_x() + (self.__padding - unicode.wlen(self.__text))
        end
    else
        return self:get_x()
    end
end

function LabelRow:render()
    self:get_gpu():set(self:align_x(), self:get_y() + math.floor(self:get_height() / 2), self.__text)

    if unicode.wlen(self.__text) < unicode.wlen(self.__old_text) then
        if self.__align == "right" then
            self:get_gpu():fill(self:get_x(), self:get_y() + math.floor(self:get_height() / 2), unicode.wlen(self.__old_text) - unicode.wlen(self.__text), 1, " ")
        else
            self:get_gpu():fill(self:get_x() + unicode.wlen(self.__text), self:get_y() + math.floor(self:get_height() / 2), unicode.wlen(self.__old_text) - unicode.wlen(self.__text), 1, " ")
        end
    end

    self.__old_text = self.__text
    if self.child ~= nil and self.child:is_visible() then
        self.child:render()
    end
end


return static