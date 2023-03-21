local component = require("component")
local event = require("event")
local unicode = require("unicode")

local class = require("class")

local BaseComponent = require("gui/component/component_base")
local border_box = require("gui/border_box")


local TextInput, static, base = class(BaseComponent)

function TextInput:new (params)
    params = params or {}
    base.new(self, params)
    self.__text = params.text or ""
    self.__input_size = params.size or 20
    self.__curser_pos = 1
    self.__offset = 0
    self.__blink = false
    self.__blink_id = nil
    if params.change ~= nil then
        self.__change_fn = params.change
    end
    if params.update ~= nil then
        self.__update_fn = params.update
    end
end

function TextInput:get_height()
    return 3
end

function TextInput:get_width()
    return 4 + self.__input_size
end

function TextInput:get_text()
    return self.__text
end

function TextInput:set_text(value)
    self.__text = value
    self.__curser_pos = unicode.wlen(self.__text) + 1
    if self.__change_fn ~= nil then
        self.__change_fn(self.__text)
    end
    self:get_gpu():invalidate()
end

function TextInput:left()
    if self.__curser_pos > 1 then
        self.__curser_pos = self.__curser_pos - 1
        if self.__offset > self.__curser_pos - 1 then
            self.__offset = self.__curser_pos - 1
        end
        if unicode.wlen(self.__text) - self.__input_size - self.__offset + 1 < 0 then
            self.__offset = (unicode.wlen(self.__text) - self.__input_size + 1)
            if self.__offset < 0 then
                self.__offset = 0
            end
        end
    end
end

function TextInput:right()
    if self.__curser_pos <= unicode.wlen(self.__text) then
        self.__curser_pos = self.__curser_pos + 1
        if self.__curser_pos - self.__input_size - self.__offset > 0 then
            self.__offset = self.__offset + (self.__curser_pos - self.__input_size - self.__offset)
        end
    end
end

function TextInput:click(x, y)
    if y == 1 and x > 1 and x < self:get_width() - 2 then
        self.__curser_pos = x - 1 + self.__offset
        if self.__curser_pos > unicode.wlen(self.__text) then
            self.__curser_pos = unicode.wlen(self.__text) + 1
        end
    end
    if self.click_fn ~= nil then
        self.click_fn(x, y)
    end
    self:get_gpu():invalidate()
end

function TextInput:update()
    if self.__update_fn ~= nil then
        self.__update_fn(self.__text)
    end
end

function TextInput:clipboard(text)
    if unicode.wlen(text) > 0 then
        self:insert(text)
    end
end

function TextInput:insert(text)
    if self.__curser_pos > unicode.wlen(self.__text) then
        self.__text = self.__text .. text
    else
        self.__text = unicode.sub(self.__text, 1, self.__curser_pos - 1) .. text .. unicode.sub(self.__text, self.__curser_pos)
    end
    self.__curser_pos = self.__curser_pos + unicode.wlen(text)
    if self.__curser_pos - self.__input_size - self.__offset > 0 then
        self.__offset = self.__offset + (self.__curser_pos - self.__input_size - self.__offset)
    end
end

function TextInput:key_down(char, code)
    --print("key_down", char, code)
    if self.__has_focus then
        if char == 8 and unicode.wlen(self.__text) > 0 then  -- backspace
            if self.__curser_pos > 1 then
                if self.__curser_pos > unicode.wlen(self.__text) then
                    self.__text = unicode.sub(self.__text, 1, -2)
                else
                    self.__text = unicode.sub(self.__text, 1, self.__curser_pos - 2) .. unicode.sub(self.__text, self.__curser_pos)
                end
                self:left()
            end
        elseif char == 0 and code == 203 then  -- left
            self:left()
        elseif char == 13 then  -- enter
            self:blur()
        elseif char == 0 and code == 199 then  -- Pos1/Home
            self.__offset = 0
            self.__curser_pos = 1
        elseif char == 0 and code == 207 then  -- End
            self.__curser_pos = unicode.wlen(self.__text) + 1
            if self.__curser_pos - self.__input_size - self.__offset > 0 then
                self.__offset = self.__offset + (self.__curser_pos - self.__input_size - self.__offset)
            end
        elseif char == 0 and code == 205 then  -- Right
            self:right()
        elseif char == 127 then
            if self.__curser_pos <= unicode.wlen(self.__text) then
                self.__text = unicode.sub(self.__text, 1, self.__curser_pos - 1) .. unicode.sub(self.__text, self.__curser_pos + 1)
            end
        elseif char >= 32 and unicode.wlen(unicode.char(char)) > 0 then
            self:insert(unicode.char(char))
        end

        self:get_gpu():invalidate()
    end
end

function TextInput:focus()
    if not self.__has_focus then
        self.__has_focus = true
        if self.focus_fn ~= nil then
            self.focus_fn()
        end
        local x, y = self:get_gpu():find_coord(2, 1)
        local blink_fn = function()
            if self.__blink then
                self.__blink = false
            else
                self.__blink = true
            end
            self:get_gpu():invalidate()
        end

        if self.__blink_id == nil then
            self.__blink_id = event.timer(.5, blink_fn, math.huge)
        end

        self:get_gpu():invalidate()
    end
end

function TextInput:blur()
    if self.__has_focus then
        self.__has_focus = false
        if self.blur_fn ~= nil then
            self.blur_fn()
        end
        self.__blink = false
        if self.__blink_id ~= nil then
            event.cancel(self.__blink_id)
            self.__blink_id = nil
        end
        if self.__change_fn ~= nil then
            self.__change_fn(self.__text)
        end
        self:get_gpu():invalidate()
    end
end

function TextInput:render()
    local border_cb = function()
        border_box.render_box_block(self:get_gpu(), self:get_x(), self:get_y(), self:get_width(), self:get_height())
    end
    if self.__has_focus then
        self:get_gpu():with_color(border_cb, 0xFFFF80)
    else
        border_cb()
    end
    if self.__blink then
        if self.__curser_pos > unicode.wlen(self.__text) then
            local blink_char = function()
                self:get_gpu():set(self:get_x() + 1 + self.__curser_pos - self.__offset, self:get_y() + 1, " ")
            end
            self:get_gpu():with_color(blink_char, 0x000000, 0xFFFFFF)
            self:get_gpu():set(self:get_x() + 2, self:get_y() + 1, unicode.sub(self.__text, 1 + self.__offset, self.__offset + self.__input_size))
        else
            local blink_char = function()
                self:get_gpu():set(self:get_x() + 1 + self.__curser_pos - self.__offset, self:get_y() + 1, unicode.sub(self.__text, self.__curser_pos, self.__curser_pos))
            end
            self:get_gpu():set(self:get_x() + 2, self:get_y() + 1, unicode.sub(self.__text, 1 + self.__offset, self.__curser_pos - 1))
            self:get_gpu():with_color(blink_char, 0x000000, 0xFFFFFF)
            self:get_gpu():set(self:get_x() + 2 + self.__curser_pos - self.__offset, self:get_y() + 1, unicode.sub(self.__text, self.__curser_pos + 1, self.__offset + self.__input_size))
        end
    else
        self:get_gpu():set(self:get_x() + 2, self:get_y() + 1, unicode.sub(self.__text, 1 + self.__offset, self.__offset + self.__input_size))
    end
end

return static