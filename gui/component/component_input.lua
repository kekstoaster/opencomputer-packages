local component = require("component")
local event = require("event")
local unicode = require("unicode")

local component_base = require("gui/component/component_base")
local border_box = require("gui/border_box")


local component_input = component_base:new()
component_input["__index"] = component_input

function component_input:new (a)
    a = a or {}
    local o = component_base:new(a)
    o.padding = a.padding or 0
    o.text = a.text or ""
    --o.text2 = ""
    o.input_size = a.size or 20
    o.curser_pos = 1
    o.offset = 0
    o.blink = false
    o.blink_id = nil
    o.old_text = nil
    if a.change ~= nil then
        o.change_fn = change
    end
    if a.update ~= nil then
        o.update_fn = a.update
    end
    setmetatable(o, component_input)
    return o
end

function component_input:get_height()
    return 3
end

function component_input:get_width()
    return 4 + self.input_size
end

function component_input:get_text()
    return self.text
end

function component_input:set_text(value)
    self.text = value
    self.curser_pos = unicode.wlen(self.text) + 1
    if self.change_fn ~= nil then
        self.change_fn(self.text)
    end
    self.gpu:invalidate()
end

function component_input:left()
    if self.curser_pos > 1 then
        self.curser_pos = self.curser_pos - 1
        if self.offset > self.curser_pos - 1 then
            self.offset = self.curser_pos - 1
        end
        if unicode.wlen(self.text) - self.input_size - self.offset + 1 < 0 then
            self.offset = (unicode.wlen(self.text) - self.input_size + 1)
            if self.offset < 0 then
                self.offset = 0
            end
        end
    end
end

function component_input:right()
    if self.curser_pos <= unicode.wlen(self.text) then
        self.curser_pos = self.curser_pos + 1
        if self.curser_pos - self.input_size - self.offset > 0 then
            self.offset = self.offset + (self.curser_pos - self.input_size - self.offset)
        end
    end
end

function component_input:click(x, y)
    if y == 1 and x > 1 and x < self:get_width() - 2 then
        self.curser_pos = x - 1 + self.offset
        if self.curser_pos > unicode.wlen(self.text) then
            self.curser_pos = unicode.wlen(self.text) + 1
        end
    end
    if self.click_fn ~= nil then
        self.click_fn(x, y)
    end
    self.gpu:invalidate()
end

function component_input:update()
    if self.update_fn ~= nil then
        self.update_fn(self.text)
    end
end

function component_input:clipboard(text)
    if unicode.wlen(text) > 0 then
        self:insert(text)
    end
end

function component_input:insert(text)
    if self.curser_pos > unicode.wlen(self.text) then
        self.text = self.text .. text
    else
        self.text = unicode.sub(self.text, 1, self.curser_pos - 1) .. text .. unicode.sub(self.text, self.curser_pos)
    end
    self.curser_pos = self.curser_pos + unicode.wlen(text)
    if self.curser_pos - self.input_size - self.offset > 0 then
        self.offset = self.offset + (self.curser_pos - self.input_size - self.offset)
    end
end

function component_input:key_down(char, code)
    --print("key_down", char, code)
    if self.has_focus then
        -- self.text2 = char .. " - " .. code .. " cp: " .. self.curser_pos .. " off: " .. self.offset .. " l:" .. unicode.wlen(self.text)
        if char == 8 and unicode.wlen(self.text) > 0 then  -- backspace
            if self.curser_pos > 1 then
                if self.curser_pos > unicode.wlen(self.text) then
                    self.text = unicode.sub(self.text, 1, -2)
                else
                    self.text = unicode.sub(self.text, 1, self.curser_pos - 2) .. unicode.sub(self.text, self.curser_pos)
                end
                self:left()
            end
        elseif char == 0 and code == 203 then  -- left
            self:left()
        elseif char == 13 then  -- enter
            self:blur()
        elseif char == 0 and code == 199 then  -- Pos1/Home
            self.offset = 0
            self.curser_pos = 1
        elseif char == 0 and code == 207 then  -- End
            self.curser_pos = unicode.wlen(self.text) + 1
            if self.curser_pos - self.input_size - self.offset > 0 then
                self.offset = self.offset + (self.curser_pos - self.input_size - self.offset)
            end
        elseif char == 0 and code == 205 then  -- Right
            self:right()
        elseif char == 127 then
            if self.curser_pos <= unicode.wlen(self.text) then
                self.text = unicode.sub(self.text, 1, self.curser_pos - 1) .. unicode.sub(self.text, self.curser_pos + 1)
            end
        elseif char >= 32 and unicode.wlen(unicode.char(char)) > 0 then
            self:insert(unicode.char(char))
        end

        self.gpu:invalidate()
    end
end

function component_input:focus()
    if not self.has_focus then
        self.has_focus = true
        if self.focus_fn ~= nil then
            self.focus_fn()
        end
        local x, y = self.gpu:find_coord(2, 1)
        local blink_fn = function()
            if self.blink then
                self.blink = false
            else
                self.blink = true
            end
            self.gpu:invalidate()
        end

        if self.blink_id == nil then
            self.blink_id = event.timer(.5, blink_fn, math.huge)
        end

        self.old_text = self.text

        self.gpu:invalidate()
    end
end

function component_input:blur()
    if self.has_focus then
        self.has_focus = false
        if self.blur_fn ~= nil then
            self.blur_fn()
        end
        self.blink = false
        if self.blink_id ~= nil then
            event.cancel(self.blink_id)
            self.blink_id = nil
        end
        if self.change_fn ~= nil then
            self.change_fn(self.text)
        end
        self.gpu:invalidate()
    end
end

function component_input:render()
    local border_cb = function()
        border_box.render_box_block(self.gpu, self:get_x(), self:get_y(), self:get_width(), self:get_height())
    end
    if self.has_focus then
        self.gpu:with_color(border_cb, 0xFFFF80)
    else
        border_cb()
    end
    if self.blink then
        --local blink_char = function()
        --    self.gpu:set(self:get_x() + 2, self:get_y() + 1, string.sub(self.text, 1, 1))
        --end
        if self.curser_pos > unicode.wlen(self.text) then
            local blink_char = function()
                self.gpu:set(self:get_x() + 1 + self.curser_pos - self.offset, self:get_y() + 1, " ")
            end
            self.gpu:with_color(blink_char, 0x000000, 0xFFFFFF)
            self.gpu:set(self:get_x() + 2, self:get_y() + 1, unicode.sub(self.text, 1 + self.offset, self.offset + self.input_size))
        else
            local blink_char = function()
                self.gpu:set(self:get_x() + 1 + self.curser_pos - self.offset, self:get_y() + 1, unicode.sub(self.text, self.curser_pos, self.curser_pos))
            end
            self.gpu:set(self:get_x() + 2, self:get_y() + 1, unicode.sub(self.text, 1 + self.offset, self.curser_pos - 1))
            self.gpu:with_color(blink_char, 0x000000, 0xFFFFFF)
            self.gpu:set(self:get_x() + 2 + self.curser_pos - self.offset, self:get_y() + 1, unicode.sub(self.text, self.curser_pos + 1, self.offset + self.input_size))
        end

        --self.gpu:set(self:get_x() + 3, self:get_y() + 1, string.sub(self.text, 2))
    else
        self.gpu:set(self:get_x() + 2, self:get_y() + 1, unicode.sub(self.text, 1 + self.offset, self.offset + self.input_size))
    end

    --self.gpu:set(self:get_x() + 2, self:get_y() + 4, self.text2)
end

return component_input