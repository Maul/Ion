--Ion, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

--/flyout command based on Gello's addon "Select"

local ION, GDB, CDB, PEW, SPEC, btnGDB, btnCDB, control, A_UPDATE = Ion

local BAR, BUTTON = ION.BAR, ION.BUTTON

local STORAGE = CreateFrame("Frame", nil, UIParent)

local FOBARIndex, FOBTNIndex, ANCHORIndex = {}, {}, {}

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

local	SKIN = LibStub("Masque", true)

local GetContainerNumSlots = _G.GetContainerNumSlots
local GetContainerItemLink = _G.GetContainerItemLink
local GetSpellBookItemName = _G.GetSpellBookItemName
local GetItemInfo = _G.GetItemInfo

local sIndex = ION.sIndex
local cIndex = ION.cIndex
local iIndex = ION.iIndex
local ItemCache = IonItemCache

local tooltipScan = IonTooltipScan
local tooltipScanTextLeft2 = IonTooltipScanTextLeft2
local tooltipStrings = {}

local BOOKTYPE_SPELL = BOOKTYPE_SPELL
local BOOKTYPE_PET = BOOKTYPE_PET

local itemTooltips, itemLinks, spellTooltips, companionTooltips = {}, {}, {}, {}
local needsUpdate, scanData = {}, {}

local array = {}

local function keySort(list)

	wipe(array)

	local i = 0

	for n in pairs(list) do
		tinsert(array, n)
	end

	table.sort(array)

	local sorter = function()

		i = i + 1

		if (array[i] == nil) then
			return nil
		else
			return array[i], list[array[i]]
		end
	end

	return sorter
end

function BUTTON:GetSpellFromName(data, spell)

	local keys, found, mandatory, optional, excluded = self.flyout.keys, 0, 0, 0

	for ckey in gmatch(keys, "[^,]+") do

		local cmd, key = (ckey):match("(%p*)(%P+)")

		if (not cmd or #cmd < 1) then
			mandatory = mandatory + 1
		elseif (cmd == "~") then
			optional = 1
		end

   		if (key and spell:lower():find(key)) then

   			if (cmd == "!") then
				excluded = true
   			else
   				found = found + 1
   			end
   		end
   	end

	if (found >= (mandatory+optional) and not excluded) then
		data[spell] = "spell"
	end
end

function BUTTON:GetSpellFromTooltip(data, spell, cmds)

	if (spellTooltips[spell:lower()]) then

		local keys, found, mandatory, optional, excluded  = self.flyout.keys, 0, 0, 0

		for ckey in gmatch(keys, "[^,]+") do

			local cmd, key = (ckey):match("(%p*)(%P+)")

			if (not cmd or #cmd < 1) then
				mandatory = mandatory + 1
			elseif (cmd == "~") then
				optional = 1
			end

			if (key and (spellTooltips[spell:lower()]):find(key)) then

   				if (cmd == "!") then
					excluded = true
   				else
   					found = found + 1
   				end
			end
		end

		if (found >= (mandatory+optional) and not excluded) then
			data[spell] = "spell"
		end
	end
end

function BUTTON:GetSpellData(data, tooltip)

	local i, spell = 1

	for k,v in pairs(ION.sIndex) do

		if (type(k) == "string" and not k:find("%(") and v.spellType ~= "FLYOUT" and v.spellLvl <= ION.level and not v.isPassive) then

			if (v.subName and #v.subName > 0) then
				spell = v.spellName.."("..v.subName..")"
			else
				spell = v.spellName
			end

			if (tooltip and tooltip == "+") then
				self:GetSpellFromTooltip(data, spell)
			else
				self:GetSpellFromName(data, spell)
			end
		end
	end

	return data
end

function BUTTON:GetItemFromLink(data, link)

	local name = GetItemInfo(link)

	if (name) then

		local keys, found, mandatory, optional, excluded = self.flyout.keys, 0, 0, 0

		local _, itemID = link:match("(item:)(%d+)")

		if (itemID and not ItemCache[name]) then
			ItemCache[name] = itemID
		end

		for ckey in gmatch(keys, "[^,]+") do

			local cmd, key = ckey:match("(%p*)(%P+)")

			if (cmd ~= "#") then

				if (not cmd or #cmd < 1) then
					mandatory = mandatory + 1
				elseif (cmd == "~") then
					optional = 1
				end

				if (key and name:lower():find(key)) then

   					if (cmd == "!") then
						excluded = true
   					else
   						found = found + 1
   					end
				end
			end
		end

		if (found >= (mandatory+optional) and not excluded) then
			data[name] = "item"
		end
	end
end

function BUTTON:GetItemFromTooltip(data, link)

	local name, _ = GetItemInfo(link)

	if (name) then

		_, itemID = link:match("(item:)(%d+)")

		if (itemID and not ItemCache[name]) then
			ItemCache[name] = itemID
		end
	end

	if (name and itemTooltips[name:lower()]) then

		local keys, found, mandatory, optional, excluded = self.flyout.keys, 0, 0, 0

		for ckey in gmatch(keys, "[^,]+") do

			local cmd, key = ckey:match("(%p*)(%P+)")

			if (cmd ~= "#") then

				if (not cmd or #cmd < 1) then
					mandatory = mandatory + 1
				elseif (cmd == "~") then
					optional = 1
				end

				if (key and itemTooltips[name:lower()]:find("[%s%p]+"..key.."[%s%p]+")) then

   					if (cmd == "!") then
						excluded = true
   					else
   						found = found + 1
   					end
				end
			end
		end

		if (found >= (mandatory+optional) and not excluded) then
			data[name] = "item"
		end
	end
end

function BUTTON:GetItemData(data, tooltip)

	local link

	for i=0,4 do

		for j=1,GetContainerNumSlots(i) do

			link = GetContainerItemLink(i,j)

			if (link) then

				if (tooltip and tooltip == "+") then
					self:GetItemFromTooltip(data, link, cmds)
				else
					self:GetItemFromLink(data, link, cmds)
				end
			end
		end
	end

	for i=0,19 do

		link = GetInventoryItemLink("player",i)

		if (link) then

			if (tooltip and tooltip == "+") then
				self:GetItemFromTooltip(data, link, cmds)
			else
				self:GetItemFromLink(data, link, cmds)
			end
		end
	end

	return data
end

function BUTTON:GetCompanionFromName(data, name)

	local keys, found, mandatory, optional, excluded = self.flyout.keys, 0, 0, 0

	for ckey in gmatch(keys, "[^,]+") do

		local cmd, key = (ckey):match("(%p*)(%P+)")

		if (cmd ~= "#") then

			if (not cmd or #cmd < 1) then
				mandatory = mandatory + 1
			elseif (cmd == "~") then
				optional = 1
			end

   			if (key and name:lower():find(key)) then

   				if (cmd == "!") then
					excluded = true
   				else
   					found = found + 1
   				end
   			end
   		end
   	end

	if (found >= (mandatory+optional) and not excluded) then
		data[name] = "companion"
	end
end

function BUTTON:GetCompanionFromTooltip(data, name)

	if (companionTooltips[name:lower()]) then

		local keys, found, mandatory, optional, excluded = self.flyout.keys, 0, 0, 0

		for ckey in gmatch(keys, "[^,]+") do

			local cmd, key = ckey:match("(%p*)(%P+)")

			if (cmd ~= "#") then

				if (not cmd or #cmd < 1) then
					mandatory = mandatory + 1
				elseif (cmd == "~") then
					optional = 1
				end

				if (key and find(companionTooltips[name:lower()], "[%s%p]+"..key.."[%s%p]+")) then

   					if (cmd == "!") then
						excluded = true
   					else
   						found = found + 1
   					end
				end
			end
		end

		if (found >= (mandatory+optional) and not excluded) then
			data[name] = "companion"
		end
	end
end

function BUTTON:GetCompanionData(data, tooltip)

	local keys, count, mode, _, name, spellID, isOwned = self.flyout.keys, 0

	for key in gmatch(keys, "[^,]+") do
		if (("#CRITTER"):find(key:upper()) or ("#MOUNT"):find(key:upper())) then
			mode = key:gsub("#",""):upper()
		end
		count = count + 1
	end

	if (mode) then

		if (mode == "MOUNT") then

			for i=1,GetNumCompanions(mode) do

				_, _, spellID = GetCompanionInfo(mode, i)

				if (spellID) then

					name = GetSpellInfo(spellID)

					if (name and count > 1) then

						if (tooltip and tooltip == "+") then
							self:GetCompanionFromTooltip(data, name)
						else
							self:GetCompanionFromName(data, name)
						end

					elseif (name) then

						data[name] = "companion"

					end
				end
			end

		elseif (mode == "CRITTER") then

			--[[

			for i=1,select(1, C_PetJournal.GetNumPets(false)) do

				_, _, isOwned, _, _, _, _, name = C_PetJournal.GetPetInfoByIndex(i)

				if (isOwned) then

					if (name and count > 1) then

						if (tooltip and tooltip == "+") then
							self:GetCompanionFromTooltip(data, name)
						else
							self:GetCompanionFromName(data, name)
						end

					elseif (name) then

						data[name] = "companion"

					end
				end
			end

			]]--
		end
	else

		for i=1,GetNumCompanions("MOUNT") do

			_, _, spellID = GetCompanionInfo("MOUNT", i)

			if (spellID) then

				name = GetSpellInfo(spellID)

				if (name) then

					if (tooltip and tooltip == "+") then
						self:GetCompanionFromTooltip(data, name)
					else
						self:GetCompanionFromName(data, name)
					end
				end
			end
		end

		--[[

		for i=1,select(1, C_PetJournal.GetNumPets(false)) do

			_, _, isOwned, _, _, _, _, name = C_PetJournal.GetPetInfoByIndex(i)

			if (isOwned) then

				if (name and count > 1) then

					if (tooltip and tooltip == "+") then
						self:GetCompanionFromTooltip(data, name)
					else
						self:GetCompanionFromName(data, name)
					end

				elseif (name) then

					data[name] = "companion"

				end
			end
		end

		]]--
	end

	return data
end

function BUTTON:GetBlizzData(data)

	local visible, spellID, isKnown, petIndex, petName, spell, subName
	local _, _, numSlots = GetFlyoutInfo(self.flyout.keys)

	for i=1, numSlots do

		visible = true

		spellID, _, isKnown = GetFlyoutSlotInfo(self.flyout.keys, i)
		petIndex, petName = GetCallPetSpellInfo(spellID)

		if (petIndex and (not petName or petName == "")) then
			visible = false
		end

		if (isKnown and visible) then

			spell, subName = GetSpellInfo(spellID)

			if (subName and #subName > 0) then
				spell = spell.."("..subName..")"
			end

			data[spell] = "blizz"
		end
	end

	return data
end

function BUTTON:GetEquipSetFromName(data, name, icon)

	local keys, found, mandatory, optional, excluded = self.flyout.keys, 0, 0, 0

	for ckey in gmatch(keys, "[^,]+") do

		local cmd, key = (ckey):match("(%p*)(%P+)")

		if (cmd ~= "#") then

			if (not cmd or #cmd < 1) then
				mandatory = mandatory + 1
			elseif (cmd == "~") then
				optional = 1
			end

   			if (key and name:lower():find(key)) then

   				if (cmd == "!") then
					excluded = true
   				else
   					found = found + 1
   				end
   			end
   		end
   	end

	if (found >= (mandatory+optional) and not excluded) then
		data[name] = "equipset;"..icon
	end
end

function BUTTON:GetEquipSetData(data)

	local keys, found, mandatory, optional, excluded, name, icon = self.flyout.keys, 0, 0, 0

	if (keys and (keys:lower():find("#all") or #keys < 1)) then

		for i=1,GetNumEquipmentSets() do

			name, icon = GetEquipmentSetInfo(i)

			if (name) then
				data[name] = "equipset;"..icon
			end
		end

	else
		for i=1,GetNumEquipmentSets() do

			name, icon = GetEquipmentSetInfo(i)

			if (name and icon) then
				self:GetEquipSetFromName(data, name, icon)
			end
		end

	end

	return data
end

function BUTTON:GetDataList(options)

	local tooltip

	wipe(scanData)

	for types in gmatch(self.flyout.types, "%a+[%+]*") do

		tooltip = types:match("%+")

		if (types:find("^b")) then

			return self:GetBlizzData(scanData)

		elseif (types:find("^e")) then

			return self:GetEquipSetData(scanData)

		elseif (types:find("^s")) then

			self:GetSpellData(scanData, tooltip)

		elseif (types:find("^i")) then

			self:GetItemData(scanData, tooltip)

		elseif (types:find("^c")) then

			self:GetCompanionData(scanData, tooltip)

		end
	end

	return scanData
end

local barsToUpdate = {}

local function updateFlyoutBars(self, elapsed)

	local bar = tremove(barsToUpdate)

	if (bar) then
		bar:SetObjectLoc()
		bar:SetPerimeter()
		bar:SetSize()
	else
		self:Hide()
	end
end

local flyoutBarUpdater = CreateFrame("Frame", nil, UIParent)
	flyoutBarUpdater:SetScript("OnUpdate", updateFlyoutBars)
	flyoutBarUpdater:Hide()

function BUTTON:Flyout_UpdateButtons(init)

	if (self.flyout) then

		local flyout, count, list, button, prefix, macroSet  = self.flyout, 0, ""

		local data = self:GetDataList(flyout.options)

		for _,button in pairs(flyout.buttons) do
			self:Flyout_ReleaseButton(button)
		end

		if (data) then

			for spell, source in keySort(data) do

				button = self:Flyout_GetButton()

				if (source == "spell" or source =="blizz") then

					if (spell:find("%(")) then
						button.macroshow = spell
					else
						button.macroshow = spell.."()"
					end

					button:SetAttribute("prefix", "/cast ")
					button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")

					prefix = "/cast "

				elseif (source == "companion") then

					if (spell:find("%(")) then
						button.macroshow = spell
					else
						button.macroshow = spell.."()"
					end

					button:SetAttribute("prefix", "/use ")
					button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")

					prefix = "/use "

				elseif (source == "item") then

					button.macroshow = spell

					if (IsEquippableItem(spell)) then

						if (self.flyout.keys:find("#%d+")) then
							slot = self.flyout.keys:match("%d+").." "
						end

						if (slot) then
							prefix = "/equipslot "
							button:SetAttribute("slot", slot.." ")
						else
							prefix = "/equip "
						end
					else
						prefix = "/use "
					end

					button:SetAttribute("prefix", prefix)

					if (slot) then
						button:SetAttribute("showtooltip", "#showtooltip "..button:GetAttribute("slot").."\n")
					else
						button:SetAttribute("showtooltip", "#showtooltip "..button.macroshow.."\n")
					end

				elseif (source:find("equipset")) then

					local _, icon = (";"):split(source)

					button.macroshow = spell

					button.data.macro_Equip = spell

					button:SetAttribute("prefix", "/equipset ")
					button:SetAttribute("showtooltip", "")

					prefix = "/equipset "

					if (icon) then
						button.data.macro_Icon = icon
					else
						button.data.macro_Icon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
					end

				else
					--should never get here
					button.macroshow = ""
					button:SetAttribute("prefix", "")
					button:SetAttribute("showtooltip", "")
				end

				if (slot) then
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..button:GetAttribute("slot"))
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..button:GetAttribute("slot")..button.macroshow)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..button:GetAttribute("slot").."\n/stopmacro [nobtn:2]\n/flyout "..options)
				else
					button:SetAttribute("macro_Text", button:GetAttribute("prefix").."[nobtn:2] "..button.macroshow)
					button:SetAttribute("*macrotext1", prefix.."[nobtn:2] "..button.macroshow)
					button:SetAttribute("flyoutMacro", button:GetAttribute("showtooltip")..button:GetAttribute("prefix").."[nobtn:2] "..button.macroshow.."\n/stopmacro [nobtn:2]\n/flyout "..flyout.options)
				end

				if (not macroSet and not self.data.macro_Text:find("nobtn:2")) then
					self.data.macro_Text = button:GetAttribute("flyoutMacro"); macroSet = true
				end

				button.data.macro_Text = button:GetAttribute("macro_Text")

				button:MACRO_UpdateParse()
				button:MACRO_Reset()
				button:MACRO_UpdateAll(true)

				list = list..button.id..";"

				count = count + 1
			end
		end

		flyout.bar.objCount = count
		flyout.bar.gdata.objectList = list

		if (not init) then

			tinsert(barsToUpdate, flyout.bar)

			flyoutBarUpdater:Show()
		end
	end
end

function BUTTON:Flyout_UpdateBar()

	self.flyouttop:Hide()
	self.flyoutbottom:Hide()
	self.flyoutleft:Hide()
	self.flyoutright:Hide()

	local flyout, pointA, pointB, hideArrow, shape, columns, pad = self.flyout

	if (flyout.shape and flyout.shape:lower():find("^c")) then
		shape = 2
	else
		shape = 1
	end

	if (flyout.point) then
		pointA = flyout.point:match("%a+"):upper() pointA = ION.Points[pointA] or "RIGHT"
	end

	if (flyout.relPoint) then
		pointB = flyout.relPoint:upper() pointB = ION.Points[pointB] or "LEFT"
	end

	if (flyout.colrad and tonumber(flyout.colrad)) then
		if (shape == 1) then
			columns = tonumber(flyout.colrad)
		elseif (shape == 2) then
			pad = tonumber(flyout.colrad)
		end
	end

	if (flyout.mode and flyout.mode:lower():find("^m")) then
		flyout.mode = "mouse"
	else
		flyout.mode = "click"
	end

	if (flyout.hideArrow and flyout.hideArrow:lower():find("^h")) then
		hideArrow = true
	end

	if (shape) then
		flyout.bar.gdata.shape = shape
	else
		flyout.bar.gdata.shape = 1
	end

	if (columns) then
		flyout.bar.gdata.columns = columns
	else
		flyout.bar.gdata.columns = 12
	end

	if (pad) then
		flyout.bar.gdata.padH = pad
		flyout.bar.gdata.padV = pad
	else
		flyout.bar.gdata.padH = 0
		flyout.bar.gdata.padV = 0
	end

	flyout.bar:ClearAllPoints()
	flyout.bar:SetPoint(pointA, self, pointB, 0, 0)
	flyout.bar:SetFrameStrata(self:GetFrameStrata())
	flyout.bar:SetFrameLevel(self:GetFrameLevel()+1)

	if (not hideArrow) then
		if (pointB == "TOP") then
			self.flyout.arrowPoint = "TOP"
			self.flyout.arrowX = 0
			self.flyout.arrowY = 5
			self.flyout.arrow = self.flyouttop
			self.flyout.arrow:Show()
		elseif (pointB == "BOTTOM") then
			self.flyout.arrowPoint = "BOTTOM"
			self.flyout.arrowX = 0
			self.flyout.arrowY = -5
			self.flyout.arrow = self.flyoutbottom
			self.flyout.arrow:Show()
		elseif (pointB == "LEFT") then
			self.flyout.arrowPoint = "LEFT"
			self.flyout.arrowX = -5
			self.flyout.arrowY = 0
			self.flyout.arrow = self.flyoutleft
			self.flyout.arrow:Show()
		elseif (pointB == "RIGHT") then
			self.flyout.arrowPoint = "RIGHT"
			self.flyout.arrowX = 5
			self.flyout.arrowY = 0
			self.flyout.arrow = self.flyoutright
			self.flyout.arrow:Show()
		end
	end

	self:Anchor_Update()

	tinsert(barsToUpdate, flyout.bar)

	flyoutBarUpdater:Show()

end

function BUTTON:Flyout_RemoveButtons()

	for _,button in pairs(self.flyout.buttons) do
		self:Flyout_ReleaseButton(button)
	end

end

function BUTTON:Flyout_RemoveBar()

	self.flyouttop:Hide()
	self.flyoutbottom:Hide()
	self.flyoutleft:Hide()
	self.flyoutright:Hide()

	self:Anchor_Update(true)

	self:Flyout_ReleaseBar(self.flyout.bar)

end

function BUTTON:UpdateFlyout(init)

	local options = self.data.macro_Text:match("/flyout%s(%C+)")

	if (self.flyout) then
		self:Flyout_RemoveButtons()
		self:Flyout_RemoveBar()
	end

	if (options) then

		if (not self.flyout) then
			self.flyout = { buttons = {} }
		end

		local flyout = self.flyout

		flyout.bar = self:Flyout_GetBar()
		flyout.options = options
		flyout.types = select(1, (":"):split(options))
		flyout.keys = select(2, (":"):split(options))
		flyout.shape = select(3, (":"):split(options))
		flyout.point = select(4, (":"):split(options))
		flyout.relPoint = select(5, (":"):split(options))
		flyout.colrad = select(6, (":"):split(options))
		flyout.mode = select(7, (":"):split(options))
		flyout.hideArrow = select(8, (":"):split(options))

		self:Flyout_UpdateButtons(init)
		self:Flyout_UpdateBar()

		if (not self.bar.watchframes) then
			self.bar.watchframes = {}
		end

		self.bar.watchframes[flyout.bar.handler] = true

		ANCHORIndex[self] = true

	else
		ANCHORIndex[self] = nil; self.flyout = nil
	end
end

function BUTTON:Flyout_ReleaseButton(button)

	self.flyout.buttons[button.id] = nil

	button.stored = true

	button.data.macro_Text = ""
	button.data.macro_Equip = false
	button.data.macro_Icon = false

	button.macrospell = nil
	button.macroitem = nil
	button.macroshow = nil
	button.macroBtn = nil
	button.bar = nil

	button:SetAttribute("*macrotext1", nil)
	button:SetAttribute("flyoutMacro", nil)

	button:ClearAllPoints()
	button:SetParent(STORAGE)
	button:SetPoint("CENTER")
	button:Hide()

end

function BUTTON:Flyout_SetData(bar)

	if (bar) then

		self.bar = bar

		self.tooltips = true
		self.tooltipsEnhanced = true
		--self.tooltipsCombat = bar.cdata.tooltipsCombat

		--self:SetFrameStrata(bar.gdata.objectStrata)

		--self:SetScale(bar.gdata.scale)

	end

	self.hotkey:Hide()
	self.macroname:Hide()
	self.count:Show()

	self:RegisterForClicks("AnyUp")

	self.equipcolor = { 0.1, 1, 0.1, 1 }
	self.cdcolor1 = { 1, 0.82, 0, 1 }
	self.cdcolor2 = { 1, 0.1, 0.1, 1 }
	self.auracolor1 = { 0, 0.82, 0, 1 }
	self.auracolor2 = { 1, 0.1, 0.1, 1 }
	self.buffcolor = { 0, 0.8, 0, 1 }
	self.debuffcolor = { 0.8, 0, 0, 1 }
	self.manacolor = { 0.5, 0.5, 1.0 }
	self.rangecolor = { 0.7, 0.15, 0.15, 1 }

	self:SetFrameLevel(4)
	self.iconframe:SetFrameLevel(2)
	self.iconframecooldown:SetFrameLevel(3)
	self.iconframeaurawatch:SetFrameLevel(3)

	self:GetSkinned()
end

function BUTTON:Flyout_PostClick()

	button = self.anchor

	button.data.macro_Text = self:GetAttribute("flyoutMacro")
	button.data.macro_Icon = false

	button:MACRO_UpdateParse()
	button:MACRO_Reset()
	button:MACRO_UpdateAll(true)

	self:MACRO_UpdateState()

end

function BUTTON:Flyout_GetButton()

	local id = 1

	for _,button in ipairs(FOBTNIndex) do

		if (button.stored) then

			button.anchor = self
			button.bar = self.flyout.bar
			button.stored = false

			self.flyout.buttons[button.id] = button

			button:Show()

			return button

		end

		id = id + 1
	end

	local button = CreateFrame("CheckButton", "IonFlyoutButton"..id, UIParent, "IonActionButtonTemplate")

	setmetatable(button, { __index = BUTTON })

	button.elapsed = 0

	local objects = ION:GetParentKeys(button)

	for k,v in pairs(objects) do
		local name = (v):gsub(button:GetName(), "")
		button[name:lower()] = _G[v]
	end

	button.class = "flyout"
	button.id = id
	button:SetID(0)
	button:SetToplevel(true)
	button.objTIndex = id
	button.objType = "FLYOUTBUTTON"
	button.data = { macro_Text = "" }

	button.anchor = self
	button.bar = self.flyout.bar
	button.stored = false

	SecureHandler_OnLoad(button)

	button:SetAttribute("type1", "macro")
	button:SetAttribute("*macrotext1", "")

	button:SetScript("PostClick", BUTTON.Flyout_PostClick)
	button:SetScript("OnEnter", BUTTON.MACRO_OnEnter)
	button:SetScript("OnLeave", BUTTON.MACRO_OnLeave)
	button:SetScript("OnEvent", self:GetScript("OnEvent"))
	--button:SetScript("OnUpdate", self:GetScript("OnUpdate"))

	button:HookScript("OnShow", function(self) self:MACRO_UpdateButton() self:MACRO_UpdateIcon() self:MACRO_UpdateState() end)
	button:HookScript("OnHide", function(self) self:MACRO_UpdateButton() self:MACRO_UpdateIcon() self:MACRO_UpdateState() end)

	button:WrapScript(button, "OnClick", [[

			local button = self:GetParent():GetParent()

			button:SetAttribute("macroUpdate", true)
			button:SetAttribute("*macrotext*", self:GetAttribute("flyoutMacro"))

			self:GetParent():Hide()
	]])

	button.SetData = BUTTON.Flyout_SetData

	button:SetData(self.flyout.bar)

	button:SetSkinned(true)

	button:Show()

	self.flyout.buttons[id] = button

	FOBTNIndex[id] = button

	return button

end

function BUTTON:Flyout_ReleaseBar(bar)

	self.flyout.bar = nil

	bar.stored = true

	bar:SetWidth(43)
	bar:SetHeight(43)

	bar:ClearAllPoints()
	bar:SetParent(STORAGE)
	bar:SetPoint("CENTER")

	self.bar.watchframes[bar.handler] = nil

end

function BUTTON:Flyout_GetBar()

	local id = 1

	for _,bar in ipairs(FOBARIndex) do

		if (bar.stored) then

			bar.stored = false

			bar:SetParent(UIParent)

			return bar

		end

		id = id + 1
	end

	local bar = CreateFrame("CheckButton", "IonFlyoutBar"..id, UIParent, "IonBarTemplate")

	setmetatable(bar, { __index = BAR })

	bar.index = id
	bar.class = "bar"
	bar.elapsed = 0
	bar.gdata = { scale = 1 }
	bar.objPrefix = "IonFlyoutButton"

	bar.text:Hide()
	bar.message:Hide()
	bar.messagebg:Hide()

	bar:SetID(id)
	bar:SetWidth(43)
	bar:SetHeight(43)
	bar:SetFrameLevel(2)

	bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar:SetScript("OnEvent", function(self) self:SetObjectLoc() self:SetPerimeter() self:SetSize() end)

	bar:Hide()

	bar.handler = CreateFrame("Frame", "IonFlyoutHandler"..id, UIParent, "SecureHandlerStateTemplate, SecureHandlerShowHideTemplate")
	bar.handler:SetAttribute("state-current", "homestate")
	bar.handler:SetAttribute("state-last", "homestate")
	bar.handler:SetAttribute("showstates", "homestate")
	bar.handler:SetScript("OnShow", function() end)
	bar.handler:SetAllPoints(bar)
	bar.handler.bar = bar
	bar.handler.elapsed = 0

	--bar.handler:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
	--bar.handler:SetBackdropColor(0,0,0,1)
	--bar.handler:SetBackdropBorderColor(0,0,0,1)

	bar.handler:Hide()

	FOBARIndex[id] = bar

	return bar

end

function BUTTON:Anchor_RemoveChild()

	local child = self.flyout.bar and self.flyout.bar.handler

	if (child) then

		self:UnwrapScript(self, "OnEnter")
		self:UnwrapScript(self, "OnLeave")
		self:UnwrapScript(self, "OnClick")
		self:SetAttribute("click-show", nil)

		child:SetAttribute("timedelay", nil)
		child:SetAttribute("_childupdate-onmouse", nil)
		child:SetAttribute("_childupdate-onclick", nil)

		child:UnwrapScript(child, "OnShow")
		child:UnwrapScript(child, "OnHide")
	end
end

function BUTTON:Anchor_UpdateChild()

	local child = self.flyout.bar and self.flyout.bar.handler

	if (child) then

		local mode, delay = self.flyout.mode

		if (mode == "click") then

			self:SetAttribute("click-show", "hide")

			self:WrapScript(self, "OnClick", [[

							if (button == "RightButton") then

								if (self:GetAttribute("click-show") == "hide") then
									self:SetAttribute("click-show", "show")
								else
									self:SetAttribute("click-show", "hide")
								end

								control:ChildUpdate("onclick", self:GetAttribute("click-show"))
							end

							]])

			child:WrapScript(child, "OnShow", [[
							if (self:GetAttribute("timedelay")) then
								self:RegisterAutoHide(self:GetAttribute("timedelay"))
							else
								self:UnregisterAutoHide()
							end
							]])

			child:WrapScript(child, "OnHide", [[ self:GetParent():SetAttribute("click-show", "hide") self:UnregisterAutoHide() ]])

			child:SetAttribute("timedelay", tonumber(delay) or 0)
			child:SetAttribute("_childupdate-onclick", [[ if (message == "show") then self:Show() else self:Hide() end ]] )

			child:SetParent(self)

		elseif (mode == "mouse") then

			self:WrapScript(self, "OnEnter", [[ control:ChildUpdate("onmouse", "enter") ]])
			self:WrapScript(self, "OnLeave", [[ if (not self:IsUnderMouse(true)) then control:ChildUpdate("onmouse", "leave") end ]])

			child:SetAttribute("timedelay", tonumber(delay) or 0)
			child:SetAttribute("_childupdate-onmouse", [[ if (message == "enter") then self:Show() elseif (message == "leave") then self:Hide() end ]] )

			child:WrapScript(child, "OnShow", [[
							if (self:GetAttribute("timedelay")) then
								self:RegisterAutoHide(self:GetAttribute("timedelay"))
							else
								self:UnregisterAutoHide()
							end
							]])

			child:WrapScript(child, "OnHide", [[ self:UnregisterAutoHide() ]])

			child:SetParent(self)
		end
	end
end

function BUTTON:Anchor_Update(reMove)

	if (reMove) then
		self:Anchor_RemoveChild()
	else
		self:Anchor_UpdateChild()
	end
end

local function updateAnchors(self, elapsed)

	if (not InCombatLockdown()) then

		local anchor = tremove(needsUpdate)

		if (anchor) then
			anchor:Flyout_UpdateButtons(nil)
		else
			--collectgarbage() not really needed, but some users complain about memory usage and if they go wild in changing
			--their inventory often and have an item-based flyout then see the huge memory usage spike, they will holler
			--without this call, the Lua garbage collector takes care of the garbage in short time, but a user watching will see it
			self:Hide(); collectgarbage()
		end
	end
end

local anchorUpdater = CreateFrame("Frame", nil, UIParent)
	anchorUpdater:SetScript("OnUpdate", updateAnchors)
	anchorUpdater:Hide()

local function linkScanOnUpdate(self, elapsed)

	self.elapsed = self.elapsed + elapsed

	-- scan X items per frame draw, where X is the for limit
	for i=1,2 do

		self.link = itemLinks[self.index]

		if (self.link) then

			local name = GetItemInfo(self.link)

			if (name) then

				local tooltip, text = " "

				tooltipScan:SetOwner(control,"ANCHOR_NONE")
				tooltipScan:SetHyperlink(self.link)

				for i,string in ipairs(tooltipStrings) do
					text = string:GetText()
					if (text) then
						tooltip = tooltip..text..","
					end
				end

				itemTooltips[name:lower()] = tooltip:lower()

				self.count = self.count + 1
			end
		end

		self.index = next(itemLinks, self.index)

		if not (self.index) then
			--print("Scanned "..self.count.." items in "..self.elapsed.." seconds")
			self:Hide(); anchorUpdater:Show()
		end
	end
end

local itemScanner = CreateFrame("Frame", nil, UIParent)
	itemScanner:SetScript("OnUpdate", linkScanOnUpdate)
	itemScanner:Hide()

function ION:ItemTooltips_Update()

	wipe(itemTooltips); wipe(itemLinks)

	local link, name, tooltip

	for i=0,4 do

		for j=1,GetContainerNumSlots(i) do

			link = GetContainerItemLink(i,j)

			if (link) then
				tinsert(itemLinks, link)
			end
		end
	end

	for i=0,19 do

		link = GetInventoryItemLink("player",i)

		if (link) then
			tinsert(itemLinks, link)
		end
	end

	itemScanner.index = next(itemLinks)

	itemScanner.count = 0
	itemScanner.elapsed = 0

	itemScanner:Show()
end

function ION:SpellTooltips_Update()

	local sIndexMax = 0

	for i=1,8 do

		local _, _, _, numSlots = GetSpellTabInfo(i)

		sIndexMax = sIndexMax + numSlots
	end

	wipe(spellTooltips)

	tooltipScan:SetOwner(control,"ANCHOR_NONE")

	local tooltip, spell, spellType, text = ""

	for i=1,sIndexMax do

		spell = GetSpellBookItemName(i, BOOKTYPE_SPELL); spellType = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)

		if (spell and spellType ~= "FLYOUT") then
			tooltip = " "
			tooltipScan:SetSpellBookItem(i, BOOKTYPE_SPELL)
			for i,string in ipairs(tooltipStrings) do
				text = string:GetText()
				if (text) then
					tooltip = tooltip..text..","
				end
			end
			spellTooltips[spell:lower()] = tooltip:lower()
   		end

   	end

	for i = 1, select("#", GetProfessions()) do

		local index = select(i, GetProfessions())

		if (index) then

			local _, _, _, _, numSpells, spelloffset = GetProfessionInfo(index)

			for i=1,numSpells do

				spell = GetSpellBookItemName(i+spelloffset, BOOKTYPE_PROFESSION); spellType = GetSpellBookItemInfo(i+spelloffset, BOOKTYPE_PROFESSION)

				if (spell and spellType ~= "FLYOUT") then
					tooltip = " "
					tooltipScan:SetSpellBookItem(i+spelloffset, BOOKTYPE_PROFESSION)
					for i,string in ipairs(tooltipStrings) do
						text = string:GetText()
						if (text) then
							tooltip = tooltip..text..","
						end
					end
					spellTooltips[spell:lower()] = tooltip:lower()
   				end
   			end
   		end
   	end

	local numPetSpells = HasPetSpells() or 0

	for i=1,numPetSpells do

		spellName, subName = GetSpellBookItemName(i, BOOKTYPE_PET)
		spell = GetSpellBookItemName(i, BOOKTYPE_PET); spellType = GetSpellBookItemInfo(i, BOOKTYPE_PET)

		if (spell and spellType ~= "FLYOUT") then

			tooltip = " "
			tooltipScan:SetSpellBookItem(i, BOOKTYPE_PET)
			for i,string in ipairs(tooltipStrings) do
				text = string:GetText()
				if (text) then
					tooltip = tooltip..text..","
				end
			end
			spellTooltips[spell:lower()] = tooltip:lower()
   		end

   		i = i + 1

   	end
end

function ION:CompanionTooltips_Update()

	wipe(companionTooltips)

	tooltipScan:SetOwner(control,"ANCHOR_NONE")

	local _, name, spellID, tooltip, text

	for i=1,GetNumCompanions("CRITTER") do

		_, name, spellID = GetCompanionInfo("CRITTER", i)

		if (name) then

			tooltip = " "
			tooltipScan:SetHyperlink("spell:"..spellID)
			for i,string in ipairs(tooltipStrings) do
				text = string:GetText()
				if (text) then
					tooltip = tooltip..text..","
				end
			end
			companionTooltips[name:lower()] = tooltip:lower()
		end
	end

	for i=1,GetNumCompanions("MOUNT") do

		_, name, spellID = GetCompanionInfo("MOUNT", i)

		if (name) then

			tooltip = " "
			tooltipScan:SetHyperlink("spell:"..spellID)
			for i,string in ipairs(tooltipStrings) do
				text = string:GetText()
				if (text) then
					tooltip = tooltip..text..","
				end
			end

			--fixes for inconsistancy in creature name vs actual spell to summon
			name = gsub(name, "Drake Mount", "Drake")
			name = gsub(name, "Thalassian Warhorse", "Summon Warhorse")

			companionTooltips[name:lower()] = tooltip:lower()
		end
	end
end

local function button_PostClick(self,button,down)

	self.macroBtn.config.macro = self:GetAttribute("newMacro")
	self.macroBtn.config.macroIcon = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
	self.macroBtn.macroparse = self:GetAttribute("newMacro")
	self.macroBtn.update(self.macroBtn)

end

local function command_flyout(options)

	if (true) then return end

	if (InCombatLockdown()) then
		return
	end

	local button = ION.ClickedButton

	if (button) then
		if (not button.options or button.options ~= options) then
			button:UpdateFlyout(options)
		end
	end
end

local extensions = {
	["/flyout"] = command_flyout,
}

local function ANCHOR_DelayedUpdate(self, elapsed)

	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > 10) then

		for anchor in pairs(ANCHORIndex) do
			tinsert(needsUpdate, anchor)
		end

		anchorUpdater:Show()

		self:Hide()
	end
end

local ANCHOR_LOGIN_Updater = CreateFrame("Frame", nil, UIParent)
	ANCHOR_LOGIN_Updater:SetScript("OnUpdate", ANCHOR_DelayedUpdate)
	ANCHOR_LOGIN_Updater:Hide()
	ANCHOR_LOGIN_Updater.elapsed = 0

local function controlOnEvent(self, event, ...)

	local unit = ...

	if (event == "EXECUTE_CHAT_LINE") then

		local command, options = (...):match("(/%a+)%s(.+)")

		if (extensions[command]) then extensions[command](options) end

	elseif (event == "BAG_UPDATE" or event =="PLAYER_INVENTORY_CHANGED" and PEW) then

		ION:ItemTooltips_Update()

		for anchor in pairs(ANCHORIndex) do

			for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
				if (types:find("^i")) then
					tinsert(needsUpdate, anchor)
				end
			end
		end

	elseif (event == "LEARNED_SPELL_IN_TAB" or
	        event == "CHARACTER_POINTS_CHANGED" or
	        event == "PET_STABLE_UPDATE" and PEW) then

		ION:SpellTooltips_Update()

		for anchor in pairs(ANCHORIndex) do

			for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
				if (types:find("^s") or types:find("^b")) then
					tinsert(needsUpdate, anchor)
				end
			end
		end

		anchorUpdater:Show()

	elseif (event == "COMPANION_LEARNED" or event == "COMPANION_UPDATE" and PEW) then

		ION:CompanionTooltips_Update()

		for anchor in pairs(ANCHORIndex) do

			for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
				if (types:find("^c")) then
					tinsert(needsUpdate, anchor)
				end
			end
		end

		anchorUpdater:Show()

	elseif (event == "EQUIPMENT_SETS_CHANGED" and PEW) then

		for anchor in pairs(ANCHORIndex) do

			for types in gmatch(anchor.flyout.types, "%a+[%+]*") do
				if (types:find("^e")) then
					tinsert(needsUpdate, anchor)
				end
			end
		end

		anchorUpdater:Show()

	elseif (event == "ADDON_LOADED" and ... == "Ion") then

		local strings = { tooltipScan:GetRegions() }

		for k,v in pairs(strings) do
			if (v:GetObjectType() == "FontString") then
				tinsert(tooltipStrings, v)
			end
		end

		STORAGE:Hide()

	elseif (event == "PLAYER_LOGIN") then

		ION:ItemTooltips_Update(true)
		ION:SpellTooltips_Update()
		ION:CompanionTooltips_Update()

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		PEW = true

	--try to delay item flyouts as late as possible so items are recognized as being in inventory
	elseif (event == "UPDATE_INVENTORY_DURABILITY" and not A_UPDATE) then

		ANCHOR_LOGIN_Updater:Show()

		A_UPDATE = true
	end
end

control = CreateFrame("Frame", nil, UIParent)
control:SetScript("OnEvent", controlOnEvent)
control:RegisterEvent("ADDON_LOADED")
control:RegisterEvent("PLAYER_LOGIN")
control:RegisterEvent("PLAYER_ENTERING_WORLD")
control:RegisterEvent("EXECUTE_CHAT_LINE")
control:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
control:RegisterEvent("BAG_UPDATE")
control:RegisterEvent("PLAYER_INVENTORY_CHANGED")
control:RegisterEvent("COMPANION_LEARNED")
control:RegisterEvent("SKILL_LINES_CHANGED")
control:RegisterEvent("LEARNED_SPELL_IN_TAB")
control:RegisterEvent("CHARACTER_POINTS_CHANGED")
control:RegisterEvent("PET_STABLE_UPDATE")
control:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
control:RegisterEvent("EQUIPMENT_SETS_CHANGED")


--[[


/flyout command -

	This command allows for the creation of a popup menu of items/spells for flyoution to be used by the macro button

		Format -

			/flyout <types>:<keys>:<shape>:<attach point>:<relative point>:<columns|radius>:<click|mouse>

			/flyout s+,i+:teleport,!drake:linear:top:bottom:1:click

		Examples -

			/flyout item:quest item:linear:right:left:6:mouse

			/flyout item+:quest item:circular:center:center:15:click

			/flyout companion:mount:linear:right:left:6

			Most options may be abbreviated -

			/flyout i+:quest item:c:c:c:15:c

		Types:

			item
			spell
			companion

			add + to scan the type's tooltip instead of the type's data

		Keys:

			Comma deliminate as many keys as you want (ex: "quest item,use")

			The "companion" type must have "critter" or "mount" in the key list

			! before a key excludes that key

			~ before a key makes the key optional

		Shapes:

			linear
			circular

		Points:

			left
			right
			top
			bottom
			topleft
			topright
			bottomleft
			bottomright
			center


]]--
