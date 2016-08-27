local L = LibStub("AceLocale-3.0"):NewLocale("AutoSpecEquip", "enGB", true)
if L then
    L["ADDONNAME"] = "AutoSpecEquip"
    
    L["YES"] = "Yes"
    L["NO"] = "No"
    L["CONFIRMATION_MESSAGE"] =  function(icon, currentSpecSetName)
        return "Do you want to equip this set?\n".."|T"..icon..":0|t "..currentSpecSetName
    end
    
    L["EQUIP_SET_SUCCESS"] = function(icon, currentSpecSetName)
        return "Equipped set " .. "|T" .. icon .. ":0|t " .. currentSpecSetName
    end
    L["EQUIP_SET_FAILED"] = function(icon, currentSpecSetName)
        return "Equipping set " .. "|T" .. icon .. ":0|t " .. currentSpecSetName .. " failed!"
    end
    
    L["OPTION_CONFIRMATION"] = "Show confirmation dialog"
    L["OPTION_CONFIRMATION_DESC"] = "If checked you will be asked for confirmation before a set is equipped"
    L["OPTION_SPEC_ENABLED"] = "enabled"
    L["OPTION_SPEC_ENABLED_DESC"] =  "If checked, the selected set will be equipped when you change to this spec"
end