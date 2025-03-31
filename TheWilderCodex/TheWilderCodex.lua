local TheWilderCodex = CreateFrame("Frame")
TheWilderCodex:RegisterEvent("ZONE_CHANGED_NEW_AREA")
TheWilderCodex:RegisterEvent("PLAYER_ENTERING_WORLD")
TheWilderCodex:SetScript("OnEvent", function() TheWilderCodex:ScanPets() end)

-- UI Frame for Missing Pets List
local frame = CreateFrame("Frame", "TheWilderCodexFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(250, 300)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
frame.title:SetPoint("TOP", 0, -10)
frame.title:SetText("Missing Pets")
frame:Hide()

-- Scroll Frame for Listing Pets
local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -40)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
local content = CreateFrame("Frame", nil, scrollFrame)
scrollFrame:SetScrollChild(content)
content:SetSize(200, 1)
frame.content = content

-- List Missing Pets
function TheWilderCodex:ScanPets()
    local zoneID = C_Map.GetBestMapForUnit("player")
    if not zoneID then return end
    local zoneInfo = C_Map.GetMapInfo(zoneID)
    if not zoneInfo then return end

    local missingPets = {}
    for i = 1, C_PetJournal.GetNumPets(false) do
        local petID, _, owned, _, _, _, _, speciesName = C_PetJournal.GetPetInfoByIndex(i)
        if petID and not owned then
            local petZones = C_PetJournal.GetPetZoneInfo(petID)
            if petZones and petZones[zoneID] then
                table.insert(missingPets, speciesName)
            end
        end
    end

    TheWilderCodex:UpdateUI(missingPets)
end

-- Update UI with Missing Pets
function TheWilderCodex:UpdateUI(petList)
    for _, child in ipairs({frame.content:GetChildren()}) do
        child:Hide()
    end
    
    local lastEntry
    for i, petName in ipairs(petList) do
        local entry = frame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        entry:SetText(petName)
        entry:SetPoint("TOPLEFT", 10, -20 * i)
        lastEntry = entry
    end

    frame.content:SetSize(200, #petList * 20)
    frame:SetHeight(math.max(100, #petList * 20 + 50))
    
    if #petList > 0 then
        frame:Show()
    else
        frame:Hide()
    end
end

-- Tooltip Highlighting for Missing Pets
GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    local name, unit = self:GetUnit()
    if not unit or not UnitIsWildBattlePet(unit) then return end

    local speciesID = C_PetJournal.FindPetIDByName(name)
    if speciesID then
        local _, _, owned = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
        if not owned then
            self:AddLine("|cffff0000Missing Pet!|r")
        end
    end
end)
