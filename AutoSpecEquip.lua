AutoSpecEquip = LibStub("AceAddon-3.0"):NewAddon("AutoSpecEquip", "AceConsole-3.0", "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("AutoSpecEquip", false)

local oldSpecName = ""

local defaults = {
    char = {
        confirmation_enabled = true,
        ['*'] = {
            equipmentSetName = "",
            enabled = true
        }
    }
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
            local specIndex = GetSpecialization()
            local currentSpecName = specIndex and select(2, GetSpecializationInfo(specIndex)) or nil
            -- work around to ignore events from switching talents
            if oldSpecName == currentSpecName then
                return
            else
                oldSpecName = currentSpecName
            end
            if AutoSpecEquip.db.char["spec_"..specIndex].enabled then
                if AutoSpecEquip.db.char["spec_"..specIndex].equipmentSetName ~= "" then
                    currentSpecSetName = AutoSpecEquip.db.char["spec_"..specIndex].equipmentSetName
                elseif currentSpecName then
                    if strlenutf8(currentSpecName) > 16 then
                        currentSpecSetName = string.utf8sub(currentSpecName, 0, 16)
                    else
                        currentSpecSetName = currentSpecName
                    end
                end
                if currentSpecSetName and currentSpecSetName ~= "" then
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
end

local function GetEquipmentSetList()
    local l = {}
    for setNum=1,GetNumEquipmentSets(),1 do
        local name, icon, lessIndex = GetEquipmentSetInfo(setNum)
        l[name] = icon and "|T"..icon..":0|t "..name or name
    end
    return l
end

local function GenOptions()
    local options = {
        name = "AutoSpecEquip", handler = AutoSpecEquip, type = "group",
        args = {
            enable = {
                type = "toggle",
                name = L["OPTION_CONFIRMATION"],
                desc = L["OPTION_CONFIRMATION_DESC"],
                get = function() return AutoSpecEquip.db.char.confirmation_enabled end,
                set = function(info, value) AutoSpecEquip.db.char.confirmation_enabled = value end,
                width = "full",
                order = 1,
            }
        }
    }
    for specIndex=1,4,1 do
        local id, name, description, icon, background, role = GetSpecializationInfo(specIndex)
        if not id then break end
        
        local specEntry = {
            order = 10+2*specIndex,
            type = "select",
            name = name,
            desc = description,
            values = GetEquipmentSetList,
            get = function() return AutoSpecEquip.db.char["spec_"..specIndex].equipmentSetName end,
            set = function(info, value) AutoSpecEquip.db.char["spec_"..specIndex].equipmentSetName = value end,
            width = "single",
        }
        local specEnabled = {
            order = 10+2*specIndex+1,
            type = "toggle",
            name = L["OPTION_SPEC_ENABLED"],
            desc = L["OPTION_SPEC_ENABLED_DESC"],
            get = function() return AutoSpecEquip.db.char["spec_"..specIndex].enabled end,
            set = function(info, value) AutoSpecEquip.db.char["spec_"..specIndex].enabled = value end,
            width = "double",
        }
        options.args["spec_"..specIndex] = specEntry
        options.args["spec_"..specIndex.."enabled"] = specEnabled
    end
    return options
end

function AutoSpecEquip:OnInitialize()
    AutoSpecEquip.db = LibStub("AceDB-3.0"):New("AutoSpecEquip_DB", defaults)
    
    AceConfig:RegisterOptionsTable("AutoSpecEquip", GenOptions)
    AutoSpecEquip.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AutoSpecEquip", "AutoSpecEquip")
    
    AutoSpecEquip:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", EventHandler)
    
    local specIndex = GetSpecialization()
    oldSpecName = specIndex and select(2, GetSpecializationInfo(specIndex)) or nil
end
