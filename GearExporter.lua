local GearExporter = _G.GearExporter
local LAD = LibStub("LibArtifactData-1.0")

local kekeke = nil

local _MAST, _CRIT, _HAST, _VERS = "Mastery", "Critical Strike", "Haste", "Versatility"
local _AGY, _STR, _INT ="Agility", "Strength", "Intellect"

SLASH_GEAREXPORTER1 = "/gearexporter"
SLASH_GEAREXPORTER2 = "/ge"


function SlashCmdList.GEAREXPORTER(msg, editbox)
	if msg ~= "" then
		kekeke = msg
	end
	Show_GE()
end

local w

function MakeMovable(frame)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end

function GetID(item)
	local item = string.match(item, "item[%-?%d:]+") -- This is something like "item:7073:0:0:0:0:0:0:0:80:0:0:0:0"
	if(item == nil) then return nil end
	if #item > string.len("item:0000") then
		item = string.sub(item, 6) -- Now I have 7073:0:0:0:0:0:0:0:80:0:0:0:0

		i = 1
		current = item:sub(0,0)
		id = ""
		--print(current)
		while current ~= ":" do
			id = id .. item:sub(i,i)
			i = i + 1
			current = item:sub(i,i)
		end
		return id
	else return nil end
end

function Show_GE()
    --print("kek")
    w = CreateFrame("Frame", "GearExporter_Window", UIParent, "ThinBorderTemplate")
    MakeMovable(w)
    w:SetSize(350,100)
    w:SetPoint("CENTER")
    w:SetFrameStrata("HIGH")

    -- Close Button
    w.close = CreateFrame("Button", "GearExporter_Window_CloseButton", w, "UIPanelCloseButton")
    w.close:SetPoint("TOPRIGHT", w)
    w.close:SetSize(34, 34)
    w.close:SetScript("OnClick", function() w:Hide() end)
    -- Texture
    w.bg = w:CreateTexture()
    w.bg:SetAllPoints(w)
    w.bg:SetTexture([[Interface\Buttons\WHITE8X8]])
    w.bg:SetVertexColor(.1,.1,.1,1)
    w:Show()


    -- Title
    w.title = w:CreateFontString("GearExporter_Window_Title", "OVERLAY", "GameFontHighlight")
    w.title:SetPoint("TOPLEFT", 10, -10)
    w.title:SetText("Lysbeth's Exporter")

    -- Button Export
    w.expt = CreateFrame("Button", "GearExporter_Window_Expt", w, "GameMenuButtonTemplate")
    w.expt:SetPoint("CENTER", -65, -10)
    w.expt:SetSize(125,35)
    w.expt:SetText("EXPORT GEAR")
    w.expt:SetScript("OnClick", function()
        if w.b and w.b:IsShown() then w.b:Hide() end
        if not w.a then
            CreateExportGearDialog(w)
        else
            if w.a:IsShown() then w.a:Hide() else w.a:Show() end
        end
        if w.a:IsShown() then
            local slots = {"HeadSlot","NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", "MainHandSlot"}
            local items = {}
            SocketInventoryItem(16)
            for i = 1, #slots do
                local slotID = GetInventorySlotInfo(slots[i])
                local itemLink = GetInventoryItemLink("player", slotID)
				if slots[i] == "BackSlot" and kekeke ~= nil then
					itemLink = kekeke
				end
                local item = GetInfo(itemLink, true)
                if slots[i] == "MainHandSlot" then
                    local _, data = LAD:GetArtifactRelics()
                    relics = {}
                    relics.relic1 = {name=data[1].name, id=data[1].itemID}
                    relics.relic2 = {name=data[2].name, id=data[2].itemID}
                    relics.relic3 = {name=data[3].name, id=data[3].itemID}
                    item.relics = relics
                end
                table.insert(items, item)
                Write_GE(items, w.a.CopyChatBox)
            end
        end
    end)

    -- Button Links
    w.link = CreateFrame("Button", "GearExporter_Window_Link", w, "GameMenuButtonTemplate")
    w.link:SetPoint("CENTER", 65, -10)
    w.link:SetSize(125,35)
    w.link:SetText("EXPORT LINKS")
    w.link:SetScript("OnClick", function()
        if w.a and w.a:IsShown() then w.a:Hide() end
        if not w.b then
            CreateExportLinkDialog(w)
        else
            if w.b:IsShown() then w.b:Hide() else w.b:Show() end
        end
        if w.b:IsShown() then

        end
    end)
end

function Write_GE(items, editbox)
    editbox:SetText("")
    local slots = {"Head", "Neck", "Shoulder", "Back", "Chest", "Wrist", "Hands", "Waist", "Legs", "Feet", "Finger1", "Finger2", "Trinket1", "Trinket2", "mainHand"}
    for i = 1, #items do
        local s = ""
        if items[i].boss then
            s = s .. items[i].boss .. "\\"
        end
        s = s .. items[i].id .. "\\"
        if items[i].slot then
            --print(items[i].slot)
            --print(items[i].slot)
            --print(items[i].armor)
            s = s .. items[i].slot .. "\\"
            if items[i].slot == "Finger" or items[i].slot == "Relic" or items[i].slot == "Trinket" then s = s .. items[i].slot .. "\\"
            else s = items[i].armor == nil and s .. items[i].slot .. "\\" or s .. items[i].armor .. "\\" end
        else s = s .. slots[i] .. "\\" end
        s = s .. items[i].name .. "\\"
        if items[i].difficulty then s = s .. items[i].difficulty .. "\\" end
        s = s .. items[i].ilvl .. "\\"
        if not items[i].type then
            if items[i].slot ~= "Trinket" then
                s = items[i].hyb == nil and s .. "0" .. "\\" or s .. items[i].hyb .. "\\"
                s = items[i].crit == nil and s .. "0" .. "\\" or s .. items[i].crit .. "\\"
                s = items[i].haste == nil and s .. "0" .. "\\" or s .. items[i].haste .. "\\"
                s = items[i].mastery == nil and s .. "0" .. "\\" or s .. items[i].mastery .. "\\"
                s = items[i].vers == nil and s .. "0" .. "\\" or s .. items[i].vers .. "\\"
                if not items[i].slot then
                    s = items[i].enchant == nil and s .. "n" .. "\\" or s .. items[i].enchant
                end
            end
        else
            s = s .. items[i].type
        end
        if items[i].tier then s = s .. items[i].tier .. "\\" end
        if slots[i] == "mainHand" then
            s = s .. "||"
            s = s .. "relic1:" .. items[i].relics.relic1.name .. "|" .. items[i].relics.relic1.id .. "*"
            s = s .. "relic2:" .. items[i].relics.relic2.name .. "|" .. items[i].relics.relic2.id .. "*"
            s = s .. "relic3:" .. items[i].relics.relic3.name .. "|" .. items[i].relics.relic3.id .. "*"
        end
        s = s .. ";"
        editbox:Insert(s)
        if #items == 1 then
            return s
        end
    end
end

function GetLine(line, token, startPoint, debug)
    local s = ""
    local j = 1
    if startPoint ~= nil then j = startPoint end
    local curr = line:sub(j, j)
    while curr ~= token and j <= #line do
        if debug then print(j .. " " ..curr) end
        s = s .. curr
        j = j + 1
        curr = line:sub(j, j)
    end
    if debug then print(s) end
    return s, j
end

function GetRelic(t)
    local _, f = t:find("Artifact Relic")
    return f
end

function GetSlot(t)
    local slots = {"Head", "Neck", "Shoulder", "Back", "Chest", "Wrist", "Hands", "Waist", "Legs", "Feet", "Finger", "Trinket"}
    for i = 1, #slots do
        if slots[i] == t then return slots[i] end
    end
    return nil
end

function GetDifficulty(t)
    local difficulties = { "Normal", "Heroic", "Mythic" }
    for i = 1, #difficulties do
        if t:lower():find(difficulties[i]:lower()) then return difficulties[i] end
    end
    return nil
end

function GetTier(t)
    return t:find("\([0-1-2-3-4-5-6]\/6\)")
end

function GetClass(t)
    local _, c = t:find("Classes: ")
    if c then
        return GetLine(t, "|", c+1)
    end
end

function printDebug(t, v)

	local g
	if v == nil then g = "n" else g = v end
	print(t.. " " .. g)
end

function GetInfo(link, gear)
    local f = CreateFrame('GameTooltip', 'GearExporter_Scanning', UIParent, 'GameTooltipTemplate')
    f:SetOwner(UIParent, 'ANCHOR_NONE')
    f:SetHyperlink(link)
    local hyb = false
    local returner = {}
    returner.id = GetID(link)
    local tierFound = false
	--print(link)
    for i = 1, f:NumLines() do
        local t = _G["GearExporter_ScanningTextLeft" .. i]:GetText()
        local s = ""
        local curr = ""
        local j = -1
        -----------------
        -- Get The Name
        -----------------
        if i == 1 then
            returner.name = GetLine(t, "")
        end




        -----------------
        -- Get Slot
        -----------------
        if not gear then
            -----------------
            -- Get Slot
            -----------------
            local slot = GetSlot(t)
            if slot ~= nil then returner.slot = slot end
            if slot then
                returner.armor = _G["GearExporter_ScanningTextRight" .. i]:GetText()
            end

            -----------------
            -- Get Relic
            -----------------
            local relic = GetRelic(t)
            if relic ~= nil then
                returner.slot = "Relic"
                returner.type = GetLine(t, " ")
            end

            -----------------
            -- Get Difficulty
            -----------------
            if GetDifficulty(t) ~= nil and returner.difficulty == nil then
                returner.difficulty = GetDifficulty(t)
            end

            -----------------
            -- Get Boss
            -----------------
            if w.b:IsShown() and not w.b.Box:IsShown() then
                returner.boss = w.b.Boss:GetText()
            end

            -----------------
            -- Get Tier and Class
            -----------------
            if GetTier(t) then
                foundTier = true
            end
            if foundTier then
                local c = GetClass(t)
                if c then
                    foundTier = false
                    returner.tier = c
                end
            end



        end

        -----------------
        -- Get Enchant
        -----------------
        if t:find("Enchanted") and gear then
            s = ""
            curr = ""
            j = 1
            while curr ~= ":" do
                curr = t:sub(j,j)
                j = j + 1
            end
            j = j + 1

            returner.enchant = GetLine(t, "|", j)
        end

        -----------------
        -- Get the ilvl
        -----------------
        if t:find("Item Level ") then
            j = 12
            curr = t:sub(j,j)
            returner.ilvl = GetLine(t, "", j)
        end

        -----------------
        -- Get Stats
        -----------------
        local f = t:sub(0,1)
        if f == "+" then
            s = ""
            curr = ""
            j = 2
            local value = 0
            value, j = GetLine(t, " ", j)
            value = value:gsub(",", "")
            local stat = GetLine(t, "", j+1)
            local insert = true
            if stat == _AGY or stat == _STR or stat == _INT then
				--print("found stat")
                stat = "hyb"
                if not hyb then hyb = true
                else insert = false end
            end
            if stat == "Stamina" then insert = false end
            if insert then
				--print("inserted " .. stat .. " with " .. value)
                if stat ~= "hyb" then stat = LowerStat(stat) end
                returner[stat] = value
            end

        -----------------
        -- Get Socket
        -----------------
        elseif f == "|" and t:find("+") and gear then
            curr = ""
            s = ""
            j = 3
            while curr ~= " " do
                curr = t:sub(j,j)
                if j == 11 then
                    if curr == "+" then j = j + 1; break; end
                end
                j = j + 1
            end

            value, j = GetLine(t, " ", j)
            stat = LowerStat(GetLine(t, "|", j+1))
			if returner[stat] == nil then returner[stat] = value
			else returner[stat] = tonumber(returner[stat]) + tonumber(value) end
        end
    end
    return returner
end

function LowerStat(stat)
    local s = ""
	if stat == _AGY or stat == _INT or stat == _STR then
		s = "hyb"
    elseif stat == _MAST then
        s = "mastery"
    elseif stat == _HAST then
        s = "haste"
    elseif stat == _CRIT then
        s = "crit"
    elseif stat == _VERS then
        s = "vers"
    end
    return s
end

function GetStat(stat, value)
    local a
    if stat == _AGY or stat == _STR or stat == _INT then
        a = {hyb = value}
    elseif stat == _MAST then
        a = {mastery = value}
    elseif stat == _HAST then
        a = {haste = value}
    elseif stat == _CRIT then
        a = {crit = value}
    elseif stat == _VERS then
        a = {vers = value}
    end
    return a
end

function CreateExportGearDialog(w)
    w.a = CreateFrame("Frame", "GearExporter_Window_Dialog", w, "ThinBorderTemplate")
    w.a:SetSize(325,300)
    w.a:SetFrameStrata("MEDIUM")
    w.a:SetPoint("BOTTOM", w, "BOTTOM", 0, -w.a:GetHeight()+10)

    w.a.instructions = w.a:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    w.a.instructions:SetPoint("BOTTOM", 0, 10)
    w.a.instructions:SetText("CTRL+A -> CTRL+C")

    -- Texture
    w.a.bg = w:CreateTexture()
    w.a.bg:SetParent(w.a)
    w.a.bg:SetAllPoints(w.a)
    w.a.bg:SetTexture([[Interface\Buttons\WHITE8X8]])
    w.a.bg:SetVertexColor(.1,.1,.1,.8)

    w.a.CopyChat = CreateFrame('Frame', 'nChatCopy', w.a)
    w.a.CopyChat:SetWidth(300)
    w.a.CopyChat:SetHeight(250)
    w.a.CopyChat:SetPoint('TOP', w.a, 'TOP', 0, -20)
    w.a.CopyChat:SetFrameStrata('HIGH')
    --CopyChat:Hide()
    w.a.CopyChat:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]],
        insets = {left = 3, right = 3, top = 4, bottom = 3
    }})
    w.a.CopyChat:SetBackdropColor(0, 0, 0, 0.7)

    --CreateBorder(CopyChat, 12, 1, 1, 1)

    w.a.CopyChatBox = CreateFrame('EditBox', 'nChatCopyBox', w.a.CopyChat)
    w.a.CopyChatBox:SetMultiLine(true)
    w.a.CopyChatBox:EnableMouse(true)
    w.a.CopyChatBox:SetMaxLetters(99999)
    w.a.CopyChatBox:SetFontObject("GameFontNormal")
    w.a.CopyChatBox:SetWidth(280)
    w.a.CopyChatBox:SetHeight(280)
    w.a.CopyChatBox:SetAutoFocus(false)
    w.a.CopyChatBox:SetScript('OnEscapePressed', function() w.a.CopyChatBox:EnableKeyboard(false); w.a.CopyChatBox:ClearFocus() end)
    w.a.CopyChatBox:SetScript("OnMouseDown", function() w.a.CopyChatBox:EnableKeyboard(true) end)

    w.a.Scroll = CreateFrame('ScrollFrame', 'nChatCopyScroll', w.a.CopyChat, 'UIPanelScrollFrameTemplate')
    w.a.Scroll:SetPoint('TOPLEFT', w.a.CopyChat, 'TOPLEFT', 8, -15)
    w.a.Scroll:SetPoint('BOTTOMRIGHT', w.a.CopyChat, 'BOTTOMRIGHT', -30, 8)
    w.a.Scroll:SetScrollChild(w.a.CopyChatBox)
end

function CreateExportLinkDialog(w)
    w.b = CreateFrame("Frame", "GearExporter_Window_Links", w, "ThinBorderTemplate")
    w.b:SetSize(325,300)
    w.b:SetFrameStrata("MEDIUM")
    w.b:SetPoint("BOTTOM", w, "BOTTOM", 0, -w.b:GetHeight()+10)

    w.b.instructions = w.b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    w.b.instructions:SetPoint("BOTTOM", 0, 10)
    w.b.instructions:SetText("CTRL+A -> CTRL+C")

    -- Texture
    w.b.bg = w:CreateTexture()
    w.b.bg:SetParent(w.b)
    w.b.bg:SetAllPoints(w.b)
    w.b.bg:SetTexture([[Interface\Buttons\WHITE8X8]])
    w.b.bg:SetVertexColor(.8,.8,.8,.8)

    w.b.Boss = CreateFrame("EditBox", "GearExporter_Window_Links_Boss", w.b)
    w.b.Boss:SetHeight(25)
    w.b.Boss:SetWidth(300)
    w.b.Boss:SetFontObject("GameFontNormal")
    w.b.Boss:SetAutoFocus(false)
    w.b.Boss:SetScript('OnEscapePressed', function() w.b.Boss:ClearFocus() end)
    w.b.Boss:SetPoint("TOP", w.b, 3, -20)
    w.b.Boss:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]],
        insets = {left = -3, right = 3, top = 4, bottom = 3
    }})
    w.b.Boss:SetBackdropColor(0, 0, 0, 0.7)



    w.b.CopyChat = CreateFrame('Frame', 'nbChatCopy', w.b)
    w.b.CopyChat:SetWidth(300)
    w.b.CopyChat:SetHeight(200)
    w.b.CopyChat:SetPoint('BOTTOM', w.b.Boss, 0, -w.b.CopyChat:GetHeight()-10)
    w.b.CopyChat:SetFrameStrata('HIGH')
    --CopyChat:Hide()
    w.b.CopyChat:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]],
        insets = {left = -3, right = 3, top = 4, bottom = 3
    }})
    w.b.CopyChat:SetBackdropColor(0, 0, 0, 0.7)

    w.b.Box = CreateFrame("Frame", "GearExporter_Window_Links_Box", w.b.CopyChat)
    w.b.Box:SetWidth(w.b.CopyChat:GetWidth())
    w.b.Box:SetHeight(w.b.CopyChat:GetHeight())
    w.b.Box:SetPoint("CENTER", w.b.CopyChat)
    w.b.Box:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8x8]],
        insets = {left = -3, right = 3, top = 4, bottom = 3
    }})
    w.b.Box:SetBackdropColor(.8,.8,.8, 1)
    w.b.Box:SetFrameStrata("HIGH")
    --CreateBorder(CopyChat, 12, 1, 1, 1)

    w.b.Box.Text = w.b.Box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    --w.b.Box.Text:SetTextHeight(15)
    w.b.Box.Text:SetText("YOU NEED A BOSS NAME\nBEFORE EXPORTING THE GEAR")
    w.b.Box.Text:SetPoint("CENTER", w.b.Box)

    w.b.CopyChatBox = CreateFrame('EditBox', 'nbChatCopyBox', w.b.CopyChat)
    w.b.CopyChatBox:SetEnabled(false)
    w.b.CopyChatBox:SetMultiLine(true)
    w.b.CopyChatBox:EnableMouse(true)
    w.b.CopyChatBox:SetMaxLetters(99999)
    w.b.CopyChatBox:SetFontObject("GameFontNormal")
    w.b.CopyChatBox:SetWidth(280)
    w.b.CopyChatBox:SetHeight(180)
    w.b.CopyChatBox:SetAutoFocus(false)
    w.b.CopyChatBox:SetScript('OnEscapePressed', function() w.b.CopyChatBox:EnableKeyboard(false); w.b.CopyChatBox:ClearFocus() end)
    w.b.CopyChatBox:SetScript("OnMouseDown", function() w.b.CopyChatBox:EnableKeyboard(true) end)

    w.b.Scroll = CreateFrame('ScrollFrame', 'nbChatCopyScroll', w.b.CopyChat, 'UIPanelScrollFrameTemplate')
    w.b.Scroll:SetPoint('TOPLEFT', w.b.CopyChat, 'TOPLEFT', 0, -15)
    w.b.Scroll:SetPoint('BOTTOMRIGHT', w.b.CopyChat, 'BOTTOMRIGHT', -30, 8)
    w.b.Scroll:SetScrollChild(w.b.CopyChatBox)
    w.b.Scroll:Hide()

    w.b.Boss:SetScript("OnTextChanged", function()
        if #w.b.Boss:GetText() >= 3 then
            w.b.Box:Hide()
            w.b.Scroll:Show()
            w.b.CopyChatBox:SetEnabled(true)
        else
            w.b.Box:Show()
            w.b.Scroll:Hide()
            w.b.CopyChatBox:SetEnabled(false)
            w.b.CopyChatBox:SetText("")
        end
    end)
end

function print_r(arr, indentLevel)
    local str = ""
    local indentStr = "#"

    if(indentLevel == nil) then
        print(print_r(arr, 0))
        return
    end

    for i = 0, indentLevel do
        indentStr = indentStr.."   "
    end

    for index,value in pairs(arr) do
        if type(value) == "table" then
            str = str..indentStr..index..": \n"..print_r(value, (indentLevel + 1))
        else
            str = str..indentStr..index..": "..value.."\n"
        end
    end
    return str
end
--Show()

-- Hook the encounter
local originalM
function Journal_Click_GE(self, elapsed)
	originalM(self, elapsed)
	if w and w.b then
		if IsShiftKeyDown() and w.b:IsShown() then
			if w.b.CopyChatBox:HasFocus() then
                local item = GetInfo(self.link)

                local cText = w.b.CopyChatBox:GetText()
                local aText = Write_GE({item}, w.b.CopyChatBox)
                local eText = cText .. aText
                w.b.CopyChatBox:SetText(eText)
				--w.b.CopyChatBox:SetText(w.b.CopyChatBox:GetText() .. self.link .. ";")
			end
		end
	end
end
function EncounterJournal_Show()
	originalM = EncounterJournal_Loot_OnClick
	EncounterJournal_Loot_OnClick = Journal_Click_GE
end
hooksecurefunc("EncounterJournal_LoadUI", EncounterJournal_Show)
