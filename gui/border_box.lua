--print("│ ─  ┘ └ ┌ ┐  ┤ ┴ ├ ┬  ┼")
--print("║ ═  ╝ ╚ ╔ ╗  ╣ ╩ ╠ ╦  ╬")

local border_list_single = {
    "│","│","─","─","┘","└","┌","┐","┤","┴","├","┬","┼",
}

local border_list_double = {
    "║","║","═","═","╝","╚","╔","╗","╣","╩","╠","╦","╬",
}

local border_list_block = {
    "▌","▐","▀","▄","▟","▙","▛","▜","█","█","█","█","█",
}

function render_box(gpu, x, y, w, h, border_list)
    if w < 2 or h < 2 then return end
    gpu:set(x, y, border_list[7])
    gpu:set(x + w - 1, y, border_list[8])
    gpu:set(x, y + h - 1, border_list[6])
    gpu:set(x + w - 1, y + h - 1, border_list[5])

    if w > 2 then
        gpu:fill(x + 1, y, w - 2, 1, border_list[3])
        gpu:fill(x + 1, y + h - 1, w - 2, 1, border_list[4])
    end

    if h > 2 then
        gpu:fill(x, y + 1, 1, h - 2, border_list[1])
        gpu:fill(x + w - 1, y + 1, 1, h - 2, border_list[2])
    end

    if w > 2 and h > 2 then
        gpu:fill(x + 1, y + 1, w - 2, h - 2, " ")
    end
end

function render_box_single(gpu, x, y, w, h)
    render_box(gpu, x, y, w, h, border_list_single)
end

function render_box_double(gpu, x, y, w, h)
    render_box(gpu, x, y, w, h, border_list_double)
end

function render_box_block(gpu, x, y, w, h)
    render_box(gpu, x, y, w, h, border_list_block)
end


return {
    render_box_single=render_box_single,
    render_box_double=render_box_double,
    render_box_block=render_box_block
}