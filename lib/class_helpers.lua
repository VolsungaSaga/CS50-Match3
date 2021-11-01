--[[Implements 'is a' functionality for the class system implemented by Matthias Richter's class library for Lua.
Only works for single-inheritance structures!
]]
function is_a(instance, class)
    
    local comparator_class = getmetatable(instance)

    while (not (comparator_class == nil)) do
        if comparator_class == class then
            return true
        end

        comparator_class = comparator_class.__includes

    end

    return false



end