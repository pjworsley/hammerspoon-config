local lib = {}

function lib.unquote(str)
    local newStr = str:match("['\"](.-)['\"]")
        if newStr ~= nil then return newStr end
        return str
    end
