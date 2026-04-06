local function nullable(class)
    if class ~= nil then
        return class
    end

    class = {}
    local chainable = function()
        return class
    end
    setmetatable(class, {["__call"]=chainable, ["__index"]=function(_, key)
        return chainable
    end})

    return class
end



return nullable
