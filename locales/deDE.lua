local L = LibStub("AceLocale-3.0"):NewLocale("AutoSpecEquip", "deDe")
if L then
    L["ADDONNAME"] = "AutoSpecEquip"
    
    L["YES"] = "Ja"
    L["NO"] = "Nein"
    L["CONFIRMATION_MESSAGE"] =  function(icon, currentSpecSetName)
        return "Willst du dieses Set anlegen?\n".."|T"..icon..":0|t "..currentSpecSetName
    end
    
    L["EQUIP_SET_SUCCESS"] = function(icon, currentSpecSetName)
        return "Set " .. "|T" .. icon .. ":0|t " .. currentSpecSetName .. "angelegt"
    end
    L["EQUIP_SET_FAILED"] = function(icon, currentSpecSetName)
        return "Anlegen von " .. "|T" .. icon .. ":0|t " .. currentSpecSetName .. " fehlgeschlagen!"
    end
    
    L["OPTION_CONFIRMATION"] = "Bestätigungsdialog anzeigen"
    L["OPTION_CONFIRMATION_DESC"] = "Aktiviert/Deaktiviert den Dialog zur Bestätigung bevor ein Set angelegt wird"
    L["OPTION_SPEC_ENABLED"] = "aktiviert"
    L["OPTION_SPEC_ENABLED_DESC"] =  "Aktiviert/Deaktiviert das Anlegen des ausgewählten Sets für diese Spezialisierung"
end