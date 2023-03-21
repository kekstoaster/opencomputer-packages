function nullable(class)
    if class ~= nil then
        return class
    end

    class = {}
    local chainable = function()
        return class
    end
    setmetatable(class, {["__call"]=chainable})

    return class
end



return nullable