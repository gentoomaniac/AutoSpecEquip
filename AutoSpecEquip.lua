AutoSpecEquip = LibStub("AceAddon-3.0"):NewAddon("AutoSpecEquip", "AceConsole-3.0", "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("AutoSpecEquip", false)

local defaults = {
    char = { confirmation_enabled = true }
}

StaticPopupDialogs["AUTOSPECEQUIP_CONFIRM"] = {
    text = "" ,
    button1 = L["YES"],
    button2 = L["NO"],
    OnAccept = function() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

local function ChangeSpec(icon, currentSpecSetName)
    equipped = UseEquipmentSet(currentSpecSetName)
    if equipped then
        AutoSpecEquip:Print(L["EQUIP_SET_SUCCESS"](icon, currentSpecSetName))
    else
        AutoSpecEquip:Print(L["EQUIP_SET_FAILED"](icon, currentSpecSetName))
    end
end

local function EventHandler(event, ...)
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        local who = ...
        if who == "player" then
            local currentSpec = GetSpecialization()
            local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or nil
            if currentSpecName then
                if strlenutf8(currentSpecName) > 16 then
                    currentSpecSetName = string.utf8sub(currentSpecName, 0, 16)
                else
                    currentSpecSetName = currentSpecName
                end
                icon, setID, isEquipped, numItems, numEquipped, unknown, numMissing, numIgnored = GetEquipmentSetInfoByName(currentSpecSetName)
                if setID and not isEquipped then
                    if AutoSpecEquip.db.char.confirmation_enabled then
                        StaticPopupDialogs["AUTOSPECEQUIP_CONFIRM"].text = L["CONFIRMATION_MESSAGE"](icon, currentSpecSetName)
                        StaticPopupDialogs["AUTOSPECEQUIP_CONFIRM"].OnAccept = function()
                            ChangeSpec(icon, currentSpecSetName)
                        end
                        StaticPopup_Show ("AUTOSPECEQUIP_CONFIRM")
                    else
                        ChangeSpec(icon, currentSpecSetName)
                    end
                end
            end
        end
    end
end

function AutoSpecEquip:OnInitialize()
    AutoSpecEquip.db = LibStub("AceDB-3.0"):New("AutoSpecEquip_DB", defaults)
    
    local options = {
        name = "AutoSpecEquip", handler = AutoSpecEquip, type = "group",
        args = {
            enable = {
                type = "toggle",
                name = L["OPTION_CONFIRMATION"],
                desc = L["OPTION_CONFIRMATION_DESC"],
                get = function() return AutoSpecEquip.db.char.confirmation_enabled end,
                set = function(info, value) AutoSpecEquip.db.char.confirmation_enabled = value end,
                width = "double",
                order = 1,
            }
        }
    }
    AceConfig:RegisterOptionsTable("AutoSpecEquip", options)
    AutoSpecEquip.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AutoSpecEquip", "AutoSpecEquip")
    
    AutoSpecEquip:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", EventHandler)
end
