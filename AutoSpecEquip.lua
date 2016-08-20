AutoSpecEquip = LibStub("AceAddon-3.0"):NewAddon("AutoSpecEquip", "AceConsole-3.0", "AceEvent-3.0")

StaticPopupDialogs["AUTOSPECEQUIP_CONFIRM"] = {
    text = "" ,
    button1 = "YES",
    button2 = "NO",
    OnAccept = function() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

local function EventHandler(event, ...)
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        local currentSpec = GetSpecialization()
        local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or nil
        if currentSpecName then
            icon, setID, isEquipped, numItems, numEquipped, unknown, numMissing, numIgnored = GetEquipmentSetInfoByName(currentSpecName)
            if setID and not isEquipped then
                StaticPopupDialogs["AUTOSPECEQUIP_CONFIRM"].text = "Do you want to equip this set?\n"..currentSpecName
                StaticPopupDialogs["AUTOSPECEQUIP_CONFIRM"].OnAccept = function()
                    equipped = UseEquipmentSet(currentSpecName)
                    if equipped then
                        AutoSpecEquip:Print("Equipped set \"".. currentSpecName .."\"")
                    else
                        AutoSpecEquip:Print("Equipping set \"".. currentSpecName .."\" failed!")
                    end
                end
                StaticPopup_Show ("AUTOSPECEQUIP_CONFIRM")
            end
        end
    end
end

function AutoSpecEquip:OnInitialize()
    AutoSpecEquip:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", EventHandler)
end

