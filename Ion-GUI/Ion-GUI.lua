--Ion GUI, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local ION, GDB, CDB, IMM, IBE, IOE, IBTNE, MAS, PEW = Ion

local width, height = 775, 490

local barNames = {}

local numShown = 15

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

local GUIData = ION.RegisteredGUIData

local ICONS = ION.iIndex

IonGUIGDB = {
	firstRun = true,
}

IonGUICDB = {

}

local defGDB, defCDB = CopyTable(IonGUIGDB), CopyTable(IonGUICDB)

local barOpt = { chk = {}, adj = {}, pri = {}, sec = {}, swatch = {} }

local popupData = {}

local chkOptions = {

	[1] = { [0] = "AUTOHIDE", L.AUTOHIDE, 1, "AutoHideBar" },
	[2] = { [0] = "SHOWGRID", L.SHOWGRID, 1, "ShowGridSet" },
	[3] = { [0] = "SNAPTO", L.SNAPTO, 1, "SnapToBar" },
	[4] = { [0] = "UPCLICKS", L.UPCLICKS, 1, "UpClicksSet" },
	[5] = { [0] = "DOWNCLICKS", L.DOWNCLICKS, 1, "DownClicksSet" },
	[6] = { [0] = "DUALSPEC", L.DUALSPEC, 1, "DualSpecSet" },
	[7] = { [0] = "HIDDEN", L.HIDDEN, 1, "ConcealBar" },
	[8] = { [0] = "SPELLGLOW", L.SPELLGLOW, 1, "SpellGlowSet" },
	[9] = { [0] = "SPELLGLOW", L.SPELLGLOW_DEFAULT, 1, "SpellGlowSet", "default" },
	[10] = { [0] = "SPELLGLOW", L.SPELLGLOW_ALT, 1, "SpellGlowSet", "alt" },
	[11] = { [0] = "LOCKBAR", L.LOCKBAR, 1, "LockSet" },
	[12] = { [0] = "LOCKBAR", L.LOCKBAR_SHIFT, 0.9, "LockSet", "shift" },
	[13] = { [0] = "LOCKBAR", L.LOCKBAR_CTRL, 0.9, "LockSet", "ctrl" },
	[14] = { [0] = "LOCKBAR", L.LOCKBAR_ALT, 0.9, "LockSet", "alt" },
	[15] = { [0] = "TOOLTIPS", L.TOOLTIPS_OPT, 1, "ToolTipSet" },
	[16] = { [0] = "TOOLTIPS", L.TOOLTIPS_ENH, 0.9, "ToolTipSet", "enhanced" },
	[17] = { [0] = "TOOLTIPS", L.TOOLTIPS_COMBAT, 0.9, "ToolTipSet", "combat" },
}

local adjOptions = {

	[1] = { [0] = "SCALE", L.SCALE, 1, "ScaleBar", 0.01, 0.1, 4 },
	[2] = { [0] = "SHAPE", L.SHAPE, 2, "ShapeBar", nil, nil, nil, ION.BarShapes },
	[3] = { [0] = "COLUMNS", L.COLUMNS, 1, "ColumnsSet", 1 , 0},
	[4] = { [0] = "ARCSTART", L.ARCSTART, 1, "ArcStartSet", 1, 0, 359 },
	[5] = { [0] = "ARCLENGTH", L.ARCLENGTH, 1, "ArcLengthSet", 1, 0, 359 },
	[6] = { [0] = "HPAD", L.HPAD, 1, "PadHSet", 0.1 },
	[7] = { [0] = "VPAD", L.VPAD, 1, "PadVSet", 0.1 },
	[8] = { [0] = "HVPAD", L.HVPAD, 1, "PadHVSet", 0.1 },
	[9] = { [0] = "STRATA", L.STRATA, 2, "StrataSet", nil, nil, nil, ION.Stratas },
	[10] = { [0] = "ALPHA", L.ALPHA, 1, "AlphaSet", 0.01, 0, 1 },
	[11] = { [0] = "ALPHAUP", L.ALPHAUP, 2, "AlphaUpSet", nil, nil, nil, ION.AlphaUps },
	[12] = { [0] = "ALPHAUP", L.ALPHAUP_SPEED, 1, "AlphaUpSpeedSet", 0.01, 0.01, 1, nil, "%0.0f", 100, "%" },
	[13] = { [0] = "XPOS", L.XPOS, 1, "XAxisSet", 0.05, nil, nil, nil, "%0.2f", 1, "" },
	[14] = { [0] = "YPOS", L.YPOS, 1, "YAxisSet", 0.05, nil, nil, nil, "%0.2f", 1, "" },
}

local swatchOptions = {

	[1] = { [0] = "BINDTEXT", L.BINDTEXT, 1, "BindTextSet", true, nil, "bindColor" },
	[2] = { [0] = "MACROTEXT", L.MACROTEXT, 1, "MacroTextSet", true, nil, "macroColor" },
	[3] = { [0] = "COUNTTEXT", L.COUNTTEXT, 1, "CountTextSet", true, nil, "countColor" },
	[4] = { [0] = "RANGEIND", L.RANGEIND, 1, "RangeIndSet", true, nil, "rangecolor" },
	[5] = { [0] = "CDTEXT", L.CDTEXT, 1, "CDTextSet", true, true, "cdcolor1", "cdcolor2" },
	[6] = { [0] = "CDALPHA", L.CDALPHA, 1, "CDAlphaSet", nil, nil },
	[7] = { [0] = "AURATEXT", L.AURATEXT, 1, "AuraTextSet", true, true, "auracolor1", "auracolor2" },
	[8] = { [0] = "AURAIND", L.AURAIND, 1, "AuraIndSet", true, true, "buffcolor", "debuffcolor" },
}

local function round(num, idp)

      local mult = 10^(idp or 0)
      return math.floor(num * mult + 0.5) / mult

end

local function insertLink(text)

	local item = GetItemInfo(text)

	--if (IBTNE.flyoutedit and IBTNE.flyoutedit.keyedit.edit:IsVisible()) then

	--	IBTNE.flyoutedit.keyedit.edit:Insert(item or text)

	--	return

	--end

	if (IBTNE.macroedit.edit:IsVisible()) then

		IBTNE.macroedit.edit:SetFocus()

		if (IBTNE.macroedit.edit:GetText() == "") then

			if (item) then

				if (GetItemSpell(text)) then
					IBTNE.macroedit.edit:Insert(SLASH_USE1.." "..item)
				else
					IBTNE.macroedit.edit:Insert(SLASH_EQUIP1.." "..item)
				end

			else
				IBTNE.macroedit.edit:Insert(SLASH_CAST1.." "..text)
			end
		else
			IBTNE.macroedit.edit:Insert(item or text)
		end
	end
end

local function modifiedSpellClick(button)

	local id = SpellBook_GetSpellBookSlot(GetMouseFocus())

	if (id > MAX_SPELLS) then
		return
	end

	if (CursorHasSpell() and IBTNE:IsVisible()) then
		ClearCursor()
	end

	if (IsModifiedClick("CHATLINK")) then

		if (IBTNE:IsVisible()) then

			local spell, subName = GetSpellBookItemName(id, SpellBookFrame.bookType)

			if (spell and not IsPassiveSpell(id, SpellBookFrame.bookType)) then

				if (subName and #subName > 0) then
					insertLink(spell.."("..subName..")")
				else
					insertLink(spell.."()")
				end
			end
			return
		end
	end

	if (IsModifiedClick("PICKUPACTION")) then

		PickupSpell(id, SpellBookFrame.bookType)

	end
end

local function modifiedItemClick(link)

	if (IsModifiedClick("CHATLINK")) then

		if (IBTNE:IsVisible()) then

			local itemName = GetItemInfo(link)

			if (itemName) then
				insertLink(itemName)
			end

			return true
		end
	end
end

local function modifiedMountClick(self, button)

	local id = self:GetParent().spellID

	if (CursorHasSpell() and IBTNE:IsVisible()) then
		ClearCursor()
	end

	if (IsModifiedClick("CHATLINK")) then

		if (IBTNE:IsVisible()) then

			local mount = GetSpellInfo(id)

			if (mount) then
				insertLink(mount.."()")
			end

			return
		end
	end
end

local function modifiedPetJournalClick(self, button)

	local id = self:GetParent().petID

	if (IBTNE:IsVisible()) then
		ClearCursor()
	end

	if (IsModifiedClick("CHATLINK")) then

		if (IBTNE:IsVisible()) then

			local _, _, _, _, _, _, petName = C_PetJournal.GetPetInfoByPetID(id)

			if (petName) then
				insertLink(petName.."()")
			end

			return
		end
	end
end

local function openStackSplitFrame(...)

	if (IBTNE:IsVisible()) then
		StackSplitFrame:Hide()
	end
end

local function IonPanelTemplates_DeselectTab(tab)

	tab.left:Show()
	tab.middle:Show()
	tab.right:Show()

	tab.leftdisabled:Hide()
	tab.middledisabled:Hide()
	tab.rightdisabled:Hide()

	tab:Enable()
	tab:SetDisabledFontObject(GameFontDisableSmall)
	tab.text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 4))


end

local function IonPanelTemplates_SelectTab(tab)

	tab.left:Hide()
	tab.middle:Hide()
	tab.right:Hide()

	tab.leftdisabled:Show()
	tab.middledisabled:Show()
	tab.rightdisabled:Show()

	tab:Disable()
	tab:SetDisabledFontObject(GameFontHighlightSmall)
	tab.text:SetPoint("CENTER", tab, "CENTER", (tab.selectedTextX or 0), (tab.selectedTextY or 7))

	if (GameTooltip:IsOwned(tab)) then
		GameTooltip:Hide()
	end
end

local function IonPanelTemplates_TabResize(tab, padding, absoluteSize, minWidth, maxWidth, absoluteTextSize)

	local sideWidths, width, tabWidth, textWidth = 2 * tab.left:GetWidth()


	if ( absoluteTextSize ) then
		textWidth = absoluteTextSize
	else
		tab.text:SetWidth(0)
		textWidth = tab.text:GetWidth()
	end

	if ( absoluteSize ) then

		if ( absoluteSize < sideWidths) then
			width = 1
			tabWidth = sideWidths
		else
			width = absoluteSize - sideWidths
			tabWidth = absoluteSize
		end

		tab.text:SetWidth(width)
	else

		if ( padding ) then
			width = textWidth + padding
		else
			width = textWidth + 24
		end

		if ( maxWidth and width > maxWidth ) then
			if ( padding ) then
				width = maxWidth + padding
			else
				width = maxWidth + 24
			end
			tab.text:SetWidth(width)
		else
			tab.text:SetWidth(0)
		end

		if (minWidth and width < minWidth) then
			width = minWidth
		end

		tabWidth = width + sideWidths
	end

	tab.middle:SetWidth(width)
	tab.middledisabled:SetWidth(width)

	tab:SetWidth(tabWidth)
	tab.highlighttexture:SetWidth(tabWidth)

end

function ION:UpdateBarGUI(newBar)

	ION.BarListScrollFrameUpdate()

	local bar = Ion.CurrentBar

	if (bar and GUIData[bar.class]) then

		if (IBE:IsVisible()) then
			IBE.count.text:SetText(bar.objType.." "..L.COUNT..": |cffffffff"..bar.objCount.."|r")
			IBE.barname:SetText(bar.gdata.name)
		end

		if (IBE.baropt:IsVisible()) then

			local yoff, adjHeight, anchor, last = -10

			if (IBE.baropt.colorpicker:IsShown()) then
				IBE.baropt.colorpicker:Hide()
			end

			if (GUIData[bar.class].adjOpt) then
				IBE.baropt.adjoptions:SetPoint("BOTTOMLEFT", IBE.baropt.chkoptions, "BOTTOMRIGHT", 0, GUIData[bar.class].adjOpt)

				adjHeight = (height-85) - (GUIData[bar.class].adjOpt - 10)
			else
				IBE.baropt.adjoptions:SetPoint("BOTTOMLEFT", IBE.baropt.chkoptions, "BOTTOMRIGHT", 0, 30)

				adjHeight = (height-85) - 20
			end

			for i,f in ipairs(barOpt.chk) do
				f:ClearAllPoints(); f:Hide()
			end

			for i,f in ipairs(barOpt.chk) do

				if (GUIData[bar.class].chkOpt[f.option]) then

					if (bar[f.func]) then
						if (f.primary) then
							if (f.primary:GetChecked()) then
								f:Enable()
								f:SetChecked(bar[f.func](bar, f.modtext, true, nil, true))
								f.text:SetTextColor(1,0.82,0)
								f.disabled = nil
							else
								f:SetChecked(nil)
								f:Disable()
								f.text:SetTextColor(0.5,0.5,0.5)
								f.disabled = true
							end
						else
							f:SetChecked(bar[f.func](bar, f.modtext, true, nil, true))
						end
					end

					if (not f.disabled) then

						if (f.primary) then
							f:SetPoint("TOPRIGHT", f.parent, "TOPRIGHT", -10, yoff)
							yoff = yoff-f:GetHeight()-5
						else
							f:SetPoint("TOPRIGHT", f.parent, "TOPRIGHT", -10, yoff)
							yoff = yoff-f:GetHeight()-5
						end

						f:Show()


					end
				end
			end

			local yoff1, yoff2, shape = (adjHeight)/7, (adjHeight)/7

			for i,f in ipairs(barOpt.adj) do

				f:ClearAllPoints(); f:Hide()

				if (bar[f.func] and f.option == "SHAPE") then

					shape = bar[f.func](bar, nil, true, true)

					if (shape ~= L.BAR_SHAPE1) then
						yoff1 = (adjHeight)/8
					end
				end

				if (f.optData) then

					wipe(popupData)

					for k,v in pairs(f.optData) do
						popupData[k.."_"..v] = tostring(k)
					end

					ION.EditBox_PopUpInitialize(f.edit.popup, popupData)
				end
			end

			yoff = -(yoff1/2)

			for i,f in ipairs(barOpt.adj) do

				if (f.option == "COLUMNS") then

					if (shape == L.BAR_SHAPE1) then

						f:SetPoint("TOPLEFT", f.parent, "TOPLEFT", 10, yoff)
						f:Show()

						yoff = yoff-yoff1
					end

				elseif (f.option == "ARCSTART" or f.option == "ARCLENGTH") then

					if (shape ~= L.BAR_SHAPE1) then

						f:SetPoint("TOPLEFT", f.parent, "TOPLEFT", 10, yoff)
						f:Show()

						yoff = yoff-yoff1
					end

				elseif (i >= 9) then

					if (i==9) then
						yoff = -(yoff2/2)
					end

					f:SetPoint("TOPLEFT", f.parent, "TOP", 10, yoff)
					f:Show()

					yoff = yoff-yoff2
				else

					f:SetPoint("TOPLEFT", f.parent, "TOPLEFT", 10, yoff)
					f:Show()

					yoff = yoff-yoff1
				end

				if (bar[f.func]) then

					f.edit.value = nil

					if (f.format) then
						f.edit:SetText(format(f.format, bar[f.func](bar, nil, true, true)*f.mult)..f.endtext)
					else
						f.edit:SetText(bar[f.func](bar, nil, true, true))
					end
					f.edit:SetCursorPosition(0)
				end
			end

			for i,f in ipairs(barOpt.swatch) do
				f:ClearAllPoints(); f:Hide()
			end

			yoff = -10

			for i,f in ipairs(barOpt.swatch) do

				if (GUIData[bar.class].chkOpt[f.option]) then

					if (bar[f.func]) then

						local checked, color1, color2 = bar[f.func](bar, f.modtext, true, nil, true)

						f:SetChecked(checked)

						if (color1) then
							f.swatch1:GetNormalTexture():SetVertexColor((";"):split(color1))
							f.swatch1.color = color1
						else
							f.swatch1:GetNormalTexture():SetVertexColor(0,0,0)
							f.swatch1.color = "0;0;0;0"
						end

						if (color2) then
							f.swatch2:GetNormalTexture():SetVertexColor((";"):split(color2))
							f.swatch2.color = color2
						else
							f.swatch2:GetNormalTexture():SetVertexColor(0,0,0)
							f.swatch2.color = "0;0;0;0"
						end
					end

					if (i >= 5) then

						if (i == 5) then
							yoff = -10
						end

						f:SetPoint("TOPRIGHT", f.parent, "TOPRIGHT", -95, yoff)
					else

						f:SetPoint("TOPRIGHT", f.parent, "TOP", -95, yoff)
					end

					f:Show()

					yoff = yoff-f:GetHeight()-6
				end
			end
		end

		if (IBE.barstates:IsVisible()) then

			local editor = IBE.barstates.actionedit

			if (IBE.baropt.colorpicker:IsShown()) then
				IBE.baropt.colorpicker:Hide()
			end

			if (GUIData[bar.class].stateOpt) then

				editor.tab1:Enable()
				editor.tab2:Enable()
				editor.tab1.text:SetTextColor(0.85, 0.85, 0.85)
				editor.tab2.text:SetTextColor(0.85, 0.85, 0.85)

				editor.tab1:Click()

				editor:SetPoint("BOTTOMRIGHT", IBE.barstates, "TOPRIGHT", 0, -170)

			else
				editor.tab3:Click()

				editor.tab1:Disable()
				editor.tab2:Disable()
				editor.tab1.text:SetTextColor(0.4, 0.4, 0.4)
				editor.tab2.text:SetTextColor(0.4, 0.4, 0.4)

				editor:SetPoint("BOTTOMRIGHT", IBE.barstates, "TOPRIGHT", 0, -30)

			end

			for i,f in ipairs(barOpt.pri) do
				if (f.option == "stance" and (GetNumShapeshiftForms() < 1 or ION.class == "DEATHKNIGHT" or ION.class == "PALADIN" or ION.class == "HUNTER")) then
					f:SetChecked(nil)
					f:Disable()
					f.text:SetTextColor(0.5,0.5,0.5)
				else
					f:SetChecked(bar.cdata[f.option])
					f:Enable()
					f.text:SetTextColor(1,0.82,0)
				end
			end

			for i,f in ipairs(barOpt.sec) do

				if (f.stance ) then
					if (f.stance:GetChecked()) then
						f:SetChecked(bar.cdata[f.option])
						f:Enable()
						f.text:SetTextColor(1,0.82,0)
					else
						f:SetChecked(nil)
						f:Disable()
						f.text:SetTextColor(0.5,0.5,0.5)
					end
				else
					f:SetChecked(bar.cdata[f.option])
				end
			end

			wipe(popupData)

			for state, value in pairs(ION.STATES) do

				if (bar.cdata.paged and state:find("paged")) then

					popupData[value] = state:match("%d+")

				elseif (bar.cdata.stance and state:find("stance")) then

					popupData[value] = state:match("%d+")

				end
			end

			ION.EditBox_PopUpInitialize(barOpt.remap.popup, popupData)
			ION.EditBox_PopUpInitialize(barOpt.remapto.popup, popupData)

			if (newBar) then
				barOpt.remap:SetText("")
				barOpt.remapto:SetText("")
			end
		end
	end
end

function ION:UpdateObjectGUI(reset)

	for editor, data in pairs(ION.Editors) do
		if (data[1]:IsVisible()) then
			data[4](reset)
		end
	end
end

local function updateBarName(frame)

	local bar = ION.CurrentBar

	if (bar) then

		bar.gdata.name = frame:GetText()

		bar.text:SetText(bar.gdata.name)

		bar:SaveData()

		frame:ClearFocus()

		ION.BarListScrollFrameUpdate()
	end
end

local function resetBarName(frame)

	local bar = ION.CurrentBar

	if (bar) then
		frame:SetText(bar.gdata.name)
		frame:ClearFocus()
	end
end

local function countOnMouseWheel(frame, delta)

	local bar = ION.CurrentBar

	if (bar) then

		if (delta > 0) then
			bar:AddObjects()
		else
			bar:RemoveObjects()
		end
	end
end

function ION:BarEditor_OnLoad(frame)

	ION.SubFramePlainBackdrop_OnLoad(frame)

	frame:SetWidth(width)
	frame:SetHeight(height)

	frame:RegisterEvent("ADDON_LOADED")
	frame:RegisterForDrag("LeftButton", "RightButton")
	frame.bottom = 0

	frame.tabs = {}

	local function TabsOnClick(cTab, silent)

		for tab, panel in pairs(frame.tabs) do

			if (tab == cTab) then

				tab:SetChecked(1)

				if (MouseIsOver(cTab)) then
					PlaySound("igCharacterInfoTab")
				end

				panel:Show()

				ION:UpdateBarGUI()
			else
				tab:SetChecked(nil)
				panel:Hide()
			end

		end
	end

	local f = CreateFrame("CheckButton", nil, frame, "IonCheckButtonTemplate1")
	f:SetWidth(140)
	f:SetHeight(28)
	f:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -28, -8.5)
	f:SetScript("OnClick", function(self) TabsOnClick(self, true) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(nil)
	f.text:SetText("")
	frame.tab3 = f; frame.tabs[f] = frame.bargroups

	f = CreateFrame("CheckButton", nil, frame, "IonCheckButtonTemplate1")
	f:SetWidth(140)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab3, "LEFT", -5, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(nil)
	f.text:SetText(L.BAR_STATES)
	frame.tab2 = f; frame.tabs[f] = frame.barstates

	f = CreateFrame("CheckButton", nil, frame, "IonCheckButtonTemplate1")
	f:SetWidth(140)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab2, "LEFT", -5, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(1)
	f.text:SetText(L.GENERAL)
	frame.tab1 = f; frame.tabs[f] = frame.baropt

	f = CreateFrame("EditBox", nil, frame, "IonEditBoxTemplateSmall")
	f:SetWidth(160)
	f:SetHeight(26)
	f:SetPoint("RIGHT", frame.tab1, "LEFT", -3.5, 0)
	f:SetPoint("TOPLEFT", frame.barlist, "TOPRIGHT", 3.5, 0)
	f:SetScript("OnEnterPressed", updateBarName)
	f:SetScript("OnTabPressed", updateBarName)
	f:SetScript("OnEscapePressed", resetBarName)
	frame.barname = f

	ION.SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("Frame", nil, frame)
	f:SetWidth(250)
	f:SetHeight(30)
	f:SetPoint("BOTTOM", 0, 10)
	f:SetScript("OnMouseWheel", function(self, delta) countOnMouseWheel(self, delta) end)
	f:EnableMouseWheel(true)
	frame.count = f

	local text = f:CreateFontString(nil, "ARTWORK", "DialogButtonNormalText")
	text:SetPoint("CENTER")
	text:SetJustifyH("CENTER")
	text:SetText("Test Object Count: 12")
	frame.count.text = text

	f = CreateFrame("Button", nil, frame.count)
	f:SetWidth(32)
	f:SetHeight(40)
	f:SetPoint("LEFT", text, "RIGHT", 10, -1)
	f:SetNormalTexture("Interface\\AddOns\\Ion\\Images\\AdjustOptionRight-Up")
	f:SetPushedTexture("Interface\\AddOns\\Ion\\Images\\AdjustOptionRight-Down")
	f:SetHighlightTexture("Interface\\AddOns\\Ion\\Images\\AdjustOptionRight-Highlight")
	f:SetScript("OnClick", function(self) if (ION.CurrentBar) then ION.CurrentBar:AddObjects() end end)

	f = CreateFrame("Button", nil, frame.count)
	f:SetWidth(32)
	f:SetHeight(40)
	f:SetPoint("RIGHT", text, "LEFT", -10, -1)
	f:SetNormalTexture("Interface\\AddOns\\Ion\\Images\\AdjustOptionLeft-Up")
	f:SetPushedTexture("Interface\\AddOns\\Ion\\Images\\AdjustOptionLeft-Down")
	f:SetHighlightTexture("Interface\\AddOns\\Ion\\Images\\AdjustOptionLeft-Highlight")
	f:SetScript("OnClick", function(self) if (ION.CurrentBar) then ION.CurrentBar:RemoveObjects() end end)

end

function ION:BarList_OnLoad(self)

	ION.SubFrameHoneycombBackdrop_OnLoad(self)

	self:SetHeight(height-55)

end

function ION.BarListScrollFrame_OnLoad(self)

	self.offset = 0
	self.scrollChild = _G[self:GetName().."ScrollChildFrame"]

	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	self:SetBackdropColor(0,0,0,0.5)

	local button, lastButton, rowButton, count, script = false, false, false, 0

	for i=1,numShown do

		button = CreateFrame("CheckButton", self:GetName().."Button"..i, self:GetParent(), "IonScrollFrameButtonTemplate")

		button.frame = self:GetParent()
		button.numShown = numShown

		button:SetScript("OnClick",

			function(self)

				local button

				for i=1,numShown do

					button = _G["IonBarEditorBarListScrollFrameButton"..i]

					if (i == self:GetID()) then

						if (self.alt) then

							if (self.bar) then

								ION:CreateNewBar(self.bar)

								IonBarEditorCreate:Click()
							end

							self.alt = nil

						elseif (self.bar) then

							ION:ChangeBar(self.bar)

							if (IBE and IBE:IsVisible()) then
								ION:UpdateBarGUI()
							end

						end
					else
						button:SetChecked(nil)
					end

				end

			end)

		button:SetScript("OnEnter",
			function(self)
				if (self.alt) then

				elseif (self.bar) then
					self.bar:OnEnter()
				end
			end)

		button:SetScript("OnLeave",
			function(self)
				if (self.alt) then

				elseif (self.bar) then
					self.bar:OnLeave()
				end
			end)

		button:SetScript("OnShow",
			function(self)
				self:SetHeight((self.frame:GetHeight()-10)/self.numShown)
			end)

		button.name = button:CreateFontString(button:GetName().."Index", "ARTWORK", "GameFontNormalSmall")
		button.name:SetPoint("TOPLEFT", button, "TOPLEFT", 5, 0)
		button.name:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 0)
		button.name:SetJustifyH("LEFT")

		button:SetID(i)
		button:SetFrameLevel(self:GetFrameLevel()+2)
		button:SetNormalTexture("")

		if (not lastButton) then
			button:SetPoint("TOPLEFT", 8, -5)
			button:SetPoint("TOPRIGHT", -15, -5)
			lastButton = button
		else
			button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, 0)
			button:SetPoint("TOPRIGHT", lastButton, "BOTTOMRIGHT", 0, 0)
			lastButton = button
		end

	end

	ION.BarListScrollFrameUpdate()
end

function ION.BarListScrollFrameUpdate(frame, tableList, alt)

	if (not IonBarEditorBarList:IsVisible()) then return end

	if (not tableList) then

		wipe(barNames)

		for _,bar in pairs(ION.BARIndex) do
			if (bar.gdata.name) then
				barNames[bar.gdata.name] = bar
			end
		end

		tableList = barNames
	end

	if (not frame) then
		frame = IonBarEditorBarListScrollFrame
	end

	local dataOffset, count, data, button, text, datum = FauxScrollFrame_GetOffset(frame), 1, {}

	for k in pairs(tableList) do
		data[count] = k; count = count + 1
	end

	table.sort(data)

	frame:Show()

	frame.buttonH = frame:GetHeight()/numShown

	for i=1,numShown do

		button = _G["IonBarEditorBarListScrollFrameButton"..i]
		button:SetChecked(nil)

		count = dataOffset + i

		if (data[count]) then

			text = data[count]

			if (tableList[text] == ION.CurrentBar) then
				button:SetChecked(1)
			end

			button.alt = alt
			button.bar = tableList[text]
			button.name:SetText(text)
			button:Enable()
			button:Show()

			if (alt) then
				if (i>1) then
					button.name:SetTextColor(0,1,0)
					button.name:SetJustifyH("CENTER")
				else
					button.name:SetJustifyH("CENTER")
					button:Disable()
				end
			else
				button.name:SetTextColor(1,0.82,0)
				button.name:SetJustifyH("LEFT")
			end
		else

			button:Hide()
		end
	end

	FauxScrollFrame_Update(frame, #data, numShown, 2)
end

function ION:CreateButton_OnLoad(button)

	button.type = "create"
	button.text:SetText(L.CREATE_BAR)

end

function ION:BarEditor_CreateNewBar(button)

	if (button.type == "create") then

		local data = { [L.SELECT_BAR_TYPE] = "none" }

		for class,info in pairs(ION.RegisteredBarData) do
			if (info.barCreateMore) then
				data[info.barLabel] = class
			end
		end

		ION.BarListScrollFrameUpdate(nil, data, true)

		button.type = "cancel"

		button.text:SetText(L.CANCEL)
	else

		ION.BarListScrollFrameUpdate()

		button.type = "create"

		button.text:SetText(L.CREATE_BAR)

	end
end

function ION:DeleteButton_OnLoad(button)

	button.parent = button:GetParent()
	button.parent.delete = button
	button.type = "delete"
	button.text:SetText(L.DELETE_BAR)

end

function ION:BarEditor_DeleteBar(button)

	local bar = ION.CurrentBar

	if (bar and button.type == "delete") then

		button:Hide()
		button.parent.confirm:Show()
		button.type = "confirm"
	else
		button:Show()
		button.parent.confirm:Hide()
		button.type = "delete"
	end

end

function ION:Confirm_OnLoad(button)

	button.parent = button:GetParent()
	button.parent.confirm = button
	button.title:SetText(L.CONFIRM)

end

function ION:ConfirmYes_OnLoad(button)

	button.parent = button:GetParent()
	button.type = "yes"
	_G[button:GetName().."Text"]:SetText(L.CONFIRM_YES)

end

function ION:BarEditor_ConfirmYes(button)

	local bar = ION.CurrentBar

	if (bar) then
		bar:DeleteBar()
	end

	IonBarEditorDelete:Click()

end

function ION:ConfirmNo_OnLoad(button)

	button.parent = button:GetParent()
	button.type = "no"
	_G[button:GetName().."Text"]:SetText(L.CONFIRM_NO)
end

function ION:BarEditor_ConfirmNo(button)
	IonBarEditorDelete:Click()
end

local function chkOptionOnClick(button)

	local bar = ION.CurrentBar

	if (bar and button.func) then
		bar[button.func](bar, button.modtext, true, button:GetChecked())
	end
end

function ION:BarOptions_OnLoad(frame)

	ION.SubFrameHoneycombBackdrop_OnLoad(frame)

	local f, primary

	for index, options in ipairs(chkOptions) do

		f = CreateFrame("CheckButton", nil, frame, "IonOptionsCheckButtonTemplate")
		f:SetID(index)
		f:SetWidth(18)
		f:SetHeight(18)
		f:SetScript("OnClick", chkOptionOnClick)
		--f:SetScale(options[2])
		f:SetScale(1)
		f:SetHitRectInsets(-100, 0, 0, 0)
		f:SetCheckedTexture("Interface\\Addons\\Ion\\Images\\RoundCheckGreen.tga")

		f.option = options[0]
		f.func = options[3]
		f.modtext = options[4]
		f.parent = frame

		if (f.modtext) then
			f.text:SetFontObject("GameFontNormalSmall")
		end

		f.text:ClearAllPoints()
		f.text:SetPoint("LEFT", -120, 0)
		f.text:SetText(options[1])

		if (f.modtext) then
			f.primary = primary
		else
			primary = f
		end

		tinsert(barOpt.chk, f)
	end
end

local function adjOptionOnTextChanged(edit, frame)

	local bar = ION.CurrentBar

	if (bar) then

		if (frame.method == 1) then

		elseif (frame.method == 2 and edit.value) then

			bar[frame.func](bar, edit.value, true)

			edit.value = nil
		end
	end
end

local function adjOptionOnEditFocusLost(edit, frame)

	edit.hasfocus = nil

	local bar = ION.CurrentBar

	if (bar) then

		if (frame.method == 1) then

			bar[frame.func](bar, edit:GetText(), true)

		elseif (frame.method == 2) then

		end
	end
end

local function adjOptionAdd(frame, onupdate)

	local bar = ION.CurrentBar

	if (bar) then

		local num = bar[frame.func](bar, nil, true, true)

		if (num == L.OFF or num == "---") then
			num = 0
		else
			num = tonumber(num)
		end

		if (num and frame.inc) then

			if (frame.max and num >= frame.max) then

				bar[frame.func](bar, frame.max, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(format(frame.format, frame.max*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(frame.max)
					end
				end
			else
				bar[frame.func](bar, num+frame.inc, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(format(frame.format, (num+frame.inc)*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(num+frame.inc)
					end
				end
			end
		end
	end
end

local function adjOptionSub(frame, onupdate)

	local bar = ION.CurrentBar

	if (bar) then

		local num = bar[frame.func](bar, nil, true, true)

		if (num == L.OFF or num == "---") then
			num = 0
		else
			num = tonumber(num)
		end

		if (num and frame.inc) then

			if (frame.min and num <= frame.min) then

				bar[frame.func](bar, frame.min, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(format(frame.format, frame.min*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(frame.min)
					end
				end
			else
				bar[frame.func](bar, num-frame.inc, true, nil, onupdate)

				if (onupdate) then
					if (frame.format) then
						frame.edit:SetText(format(frame.format, (num-frame.inc)*frame.mult)..frame.endtext)
					else
						frame.edit:SetText(num-frame.inc)
					end
				end
			end
		end
	end
end

local function adjOptionOnMouseWheel(frame, delta)

	if (delta > 0) then
		adjOptionAdd(frame)
	else
		adjOptionSub(frame)
	end

end

function ION.AdjustableOptions_OnLoad(frame)

	ION.SubFrameHoneycombBackdrop_OnLoad(frame)

	for index, options in ipairs(adjOptions) do

		f = CreateFrame("Frame", "IonGUIAdjOpt"..index, frame, "IonAdjustOptionTemplate")
		f:SetID(index)
		f:SetWidth(200)
		f:SetHeight(24)
		f:SetScript("OnShow", function() end)
		f:SetScript("OnMouseWheel", function(self, delta) adjOptionOnMouseWheel(self, delta) end)
		f:EnableMouseWheel(true)

		f.text:SetText(options[1]..":")
		f.method = options[2]
		f["method"..options[2]]:Show()
		f.edit = f["method"..options[2]].edit
		f.edit.frame = f
		f.option = options[0]
		f.func = options[3]
		f.inc = options[4]
		f.min = options[5]
		f.max = options[6]
		f.optData = options[7]
		f.format = options[8]
		f.mult = options[9]
		f.endtext = options[10]
		f.parent = frame

		f.edit:SetScript("OnTextChanged", function(self) adjOptionOnTextChanged(self, self.frame) end)
		f.edit:SetScript("OnEditFocusLost", function(self) adjOptionOnEditFocusLost(self, self.frame) end)

		f.addfunc = adjOptionAdd
		f.subfunc = adjOptionSub

		tinsert(barOpt.adj, f)
	end
end

local function visOptionOnClick(button)

	local bar = ION.CurrentBar

	if (bar and button.func) then
		bar[button.func](bar, nil, true, button:GetChecked())
	end

end

local function colorPickerShow(self)

	if (self.color) then

		local frame  = IBE.baropt.colorpicker

		frame.updateFunc = function()

			local bar = ION.CurrentBar

			if (bar) then

				local r,g,b = IonColorPicker:GetColorRGB()
				local a = IonColorPicker.alpha:GetValue()

				r = round(r,2); g = round(g,2); b = round(b,2); a = 1-round(a,2)

				if (r and g and b and a) then

					local value = r..";"..g..";"..b..";"..a

					bar.gdata[self.option] = value

					bar:UpdateObjectData()

					bar:Update()
				end
			end
		end

		local r,g,b,a = (";"):split(self.color)

		if (r and g and b) then
			IonColorPicker:SetColorRGB(r,g,b)
		end

		a = tonumber(a)

		if (a) then
			IonColorPicker.alpha:SetValue(1-a)
			IonColorPicker.alphavalue:SetText(a)
		end

		frame:Show()

	end
end

function ION.VisiualOptions_OnLoad(frame)

	ION.SubFrameHoneycombBackdrop_OnLoad(frame)

	local f, primary

	for index, options in ipairs(swatchOptions) do

		f = CreateFrame("CheckButton", nil, frame, "IonOptionsCheckButtonSwatchTemplate")
		f:SetID(index)
		f:SetWidth(18)
		f:SetHeight(18)
		f:SetScript("OnClick", visOptionOnClick)
		f:SetScale(1)

		f.text:SetText(options[1]..":")
		f.option = options[0]
		f.func = options[3]
		f.parent = frame

		if (options[4]) then
			f.swatch1:Show()
			f.swatch1:SetScript("OnClick", colorPickerShow)
			f.swatch1.option = options[6]
		end

		if (options[5]) then
			f.swatch2:Show()
			f.swatch2:SetScript("OnClick", colorPickerShow)
			f.swatch2.option = options[7]
		end

		tinsert(barOpt.swatch, f)
	end
end

function ION.BarEditorColorPicker_OnLoad(frame)

	ION.SubFrameHoneycombBackdrop_OnLoad(frame)

end

function ION.BarEditorColorPicker_OnShow(frame)

	IonColorPicker.frame = frame

	IonColorPicker:ClearAllPoints()
	IonColorPicker:SetParent(frame)
	IonColorPicker:SetPoint("TOPLEFT", 0, -20)
	IonColorPicker:SetPoint("BOTTOMRIGHT")
	IonColorPicker:Show()

end

local function setBarActionState(frame)

	local bar = ION.CurrentBar

	if (bar) then
		bar:SetState(frame.option, true, frame:GetChecked())
	end
end

local function remapOnTextChanged(frame)

	local bar = ION.CurrentBar

	if (bar and bar.cdata.remap and frame.value) then

		local map, remap

		for states in gmatch(bar.cdata.remap, "[^;]+") do

			map, remap = (":"):split(states)

			if (map == frame.value) then

				barOpt.remapto.value = remap

				if (bar.cdata.paged) then
					barOpt.remapto:SetText(ION.STATES["paged"..remap])
				elseif (bar.cdata.stance) then
					barOpt.remapto:SetText(ION.STATES["stance"..remap])
				end
			end
		end
	else
		barOpt.remapto:SetText("")
	end
end

local function remapToOnTextChanged(frame)

	local bar = ION.CurrentBar

	if (bar and bar.cdata.remap and frame.value and #frame.value > 0) then

		local value = barOpt.remap.value

		bar.cdata.remap = bar.cdata.remap:gsub(value..":%d+", value..":"..frame.value)

		if (bar.cdata.paged) then
			bar.paged.registered = false
		elseif (bar.cdata.stance) then
			bar.stance.registered = false
		end

		bar.stateschanged = true

		bar:Update()
	end
end

function ION:ActionEditor_OnLoad(frame)

	ION.SubFrameHoneycombBackdrop_OnLoad(frame)

	frame.tabs = {}

	local function TabsOnClick(cTab, silent)

		for tab, panel in pairs(frame.tabs) do

			if (tab == cTab) then
				if (MouseIsOver(cTab) and not tab.selected) then
					PlaySound("igCharacterInfoTab")
				end
				panel:Show()
				tab:SetHeight(33)
				tab:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
				tab:SetBackdropColor(1,1,1,1)
				tab.text:SetTextColor(1,0.82,0)

				tab.selected = true
			else
				panel:Hide()
				tab:SetHeight(28)
				tab:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
				tab:SetBackdropColor(0.7,0.7,0.7,1)
				tab.text:SetTextColor(0.85, 0.85, 0.85)

				tab.selected = nil
			end

		end
	end

	local f = CreateFrame("CheckButton", nil, frame, "IonCheckButtonTabTemplate")
	f:SetWidth(160)
	f:SetHeight(33)
	f:SetPoint("TOPLEFT", frame, "BOTTOMLEFT",5,4)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel())
	f:SetBackdropColor(0.3,0.3,0.3,1)
	f.text:SetText(L.PRESET_STATES)
	f.selected = true
	frame.tab1 = f; frame.tabs[f] = frame.presets

	f = CreateFrame("CheckButton", nil, frame, "IonCheckButtonTabTemplate")
	f:SetWidth(160)
	f:SetHeight(28)
	f:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT",-5,4)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel())
	f.text:SetText(L.CUSTOM_STATES)
	frame.tab2 = f; frame.tabs[f] = frame.custom

	f = CreateFrame("CheckButton", nil, frame, "IonCheckButtonTabTemplate")
	f:SetWidth(160)
	f:SetHeight(28)
	f:SetPoint("TOP", frame, "BOTTOM",0,0)
	f:SetScript("OnClick", function(self) TabsOnClick(self, true) end)
	f:SetFrameLevel(frame:GetFrameLevel())
	f:Hide()
	frame.tab3 = f; frame.tabs[f] = frame.hidden

	local states, anchor, last, count, prowl = {}

	local MAS = ION.MANAGED_ACTION_STATES

	for state, values in pairs(MAS) do
		states[values.order] = state
	end

	for index,state in ipairs(states) do

		if (MAS[state].homestate) then

			f = CreateFrame("CheckButton", nil, frame.presets.primary, "IonOptionsCheckButtonTemplate")
			f:SetID(index)
			f:SetWidth(18)
			f:SetHeight(18)
			f:SetScript("OnClick", setBarActionState)
			f.text:SetText(L["GUI_"..state:upper()])
			f.option = state

			if (not anchor) then
				f:SetPoint("TOPLEFT", frame.presets.primary, "TOPLEFT", 10, -10)
				anchor = f; last = f
			else
				f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -18)
				last = f
			end

			if (state == "stance" and ION.class == "DRUID") then
				prowl = f
			end

			tinsert(barOpt.pri, f)
		end
	end

	anchor, last, count = nil, nil, 1

	for index,state in ipairs(states) do

		if (not MAS[state].homestate and state ~= "custom" and state ~= "extrabar" and state ~= "prowl") then

			f = CreateFrame("CheckButton", nil, frame.presets.secondary, "IonOptionsCheckButtonTemplate")
			f:SetID(index)
			f:SetWidth(18)
			f:SetHeight(18)
			f:SetScript("OnClick", setBarActionState)
			f.text:SetText(L["GUI_"..state:upper()])
			f.option = state

			if (not anchor) then
				f:SetPoint("TOPLEFT", frame.presets.secondary, "TOPLEFT", 10, -8)
				anchor = f; last = f
			elseif (count == 5) then
				f:SetPoint("LEFT", anchor, "RIGHT", 90, 0)
				anchor = f; last = f; count = 1
			else
				f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -8)
				last = f
			end

			count = count + 1

			tinsert(barOpt.sec, f)
		end
	end

	if (prowl) then

		f = CreateFrame("CheckButton", nil, frame.presets.secondary, "IonOptionsCheckButtonTemplate")
		f:SetID(#states+1)
		f:SetWidth(18)
		f:SetHeight(18)
		f:SetScript("OnClick", setBarActionState)
		f.text:SetText(L.GUI_PROWL)
		f.option = "prowl"
		f.stance = prowl
		f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -8)

		tinsert(barOpt.sec, f)
	end

	f = CreateFrame("EditBox", "$parentRemap", frame.presets, "IonDropDownOptionFull")
	f:SetWidth(165)
	f:SetHeight(25)
	f:SetTextInsets(7,3,0,0)
	f.text:SetText(L.REMAP)
	f:SetPoint("BOTTOMLEFT", frame.presets, "BOTTOMLEFT", 7, 8)
	f:SetPoint("BOTTOMRIGHT", frame.presets.secondary, "BOTTOM", -70, -35)
	f:SetScript("OnTextChanged", remapOnTextChanged)
	f:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
	f.popup:ClearAllPoints()
	f.popup:SetPoint("BOTTOMLEFT")
	f.popup:SetPoint("BOTTOMRIGHT")
	barOpt.remap = f

	ION.SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("EditBox", "$parentRemapTo", frame.presets, "IonDropDownOptionFull")
	f:SetWidth(160)
	f:SetHeight(25)
	f:SetTextInsets(7,3,0,0)
	f.text:SetText(L.REMAPTO)
	f:SetPoint("BOTTOMLEFT", barOpt.remap, "BOTTOMRIGHT", 25, 0)
	f:SetPoint("BOTTOMRIGHT", frame.presets.secondary, "BOTTOMRIGHT", -23, -35)
	f:SetScript("OnTextChanged", remapToOnTextChanged)
	f:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
	f.popup:ClearAllPoints()
	f.popup:SetPoint("BOTTOMLEFT")
	f.popup:SetPoint("BOTTOMRIGHT")
	barOpt.remapto = f

	ION.SubFrameBlackBackdrop_OnLoad(f)
end

--	paged = 	paged1;	paged2;	paged3;	paged4;	paged5;	paged6;

--	stance =	stance0;	stance1;	stance2;	stance3;	stance4;	stance5;	stance6;

--	modkey =	alt0;		alt1;		ctrl0;	ctrl1;	shift0;	shift1;

--	sit1 =	reaction0;	reaction1;	combat0;	combat1;	group0;	group1;	group2;

--	sit2 = 	stealth0;	stealth1;	fishing0;	fishing1;	pet0;		pet1;

--	control = 	vehicle0;	vehicle1;	possess0;	possess1;	override0;	override1;	extrabar0;	extrabar1;

function ION:VisEditor_OnLoad(frame)

	ION.SubFrameHoneycombBackdrop_OnLoad(frame)

end

function ION:StateList_OnLoad(frame)

	ION.SubFrameHoneycombBackdrop_OnLoad(frame)

end

function ION:BarStates_OnLoad(frame)

	--ION.SubFrameHoneycombBackdrop_OnLoad(frame)

end

function ION:BarGroups_OnLoad(frame)

	ION.SubFrameHoneycombBackdrop_OnLoad(frame)

end

function ION:ObjectEditor_OnLoad(frame)

	ION.SubFramePlainBackdrop_OnLoad(frame)

	frame:RegisterForDrag("LeftButton", "RightButton")
	frame.bottom = 0

	frame:SetHeight(height)
end

function ION:ObjectEditor_OnShow(frame)

	for k,v in pairs(ION.Editors) do
		v[1]:Hide()
	end

	if (ION.CurrentObject) then

		local objType = ION.CurrentObject.objType

		if (ION.Editors[objType]) then

			local editor = ION.Editors[objType][1]

			editor:SetParent(frame)
			editor:SetAllPoints(frame)
			editor:Show()

			IOE:SetWidth(ION.Editors[objType][2])
			IOE:SetHeight(ION.Editors[objType][3])
		end
	end
end

function ION:ObjectEditor_OnHide(frame)

end

function ION:ActionList_OnLoad(frame)

	ION.SubFrameHoneycombBackdrop_OnLoad(frame)

end

function ION:ActionListScrollFrame_OnLoad(frame)

	frame.offset = 0
	frame.scrollChild = _G[frame:GetName().."ScrollChildFrame"]

	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)

	local button, lastButton, rowButton, count, script = false, false, false, 0

	for i=1,numShown do

		button = CreateFrame("CheckButton", frame:GetName().."Button"..i, frame:GetParent(), "IonScrollFrameButtonTemplate")

		button.frame = frame:GetParent()
		button.numShown = numShown
		button.elapsed = 0

		button:SetScript("OnClick",

			function(self)

				IonButtonEditor.macroedit.edit:ClearFocus()

				local button

				for i=1,numShown do

					button = _G["IonBarEditorBarListScrollFrameButton"..i]

					if (i == self:GetID()) then

						if (self.bar) then
							self.bar:SetFauxState(self.state)
						end

					else
						button:SetChecked(nil)
					end

				end

			end)

		button:SetScript("OnEnter",
			function(self)

			end)

		button:SetScript("OnLeave",
			function(self)

			end)

		button:SetScript("OnShow",
			function(self)
				self.elapsed = 0; self.setheight = true
			end)

		button:SetScript("OnUpdate",

			function(self,elapsed)

				self.elapsed = self.elapsed + elapsed

				if (self.setheight and self.elapsed > 0.03) then
					self:SetHeight((self.frame:GetHeight()-10)/self.numShown)
					self.setheight = nil
				end
			end)

		button.name = button:CreateFontString(button:GetName().."Index", "ARTWORK", "GameFontNormalSmall")
		button.name:SetPoint("TOPLEFT", button, "TOPLEFT", 5, 0)
		button.name:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 0)
		button.name:SetJustifyH("LEFT")

		button:SetID(i)
		button:SetFrameLevel(frame:GetFrameLevel()+2)
		button:SetNormalTexture("")

		if (not lastButton) then
			button:SetPoint("TOPLEFT", 8, -5)
			button:SetPoint("TOPRIGHT", -15, -5)
			lastButton = button
		else
			button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, 0)
			button:SetPoint("TOPRIGHT", lastButton, "BOTTOMRIGHT", 0, 0)
			lastButton = button
		end

	end

	ION.ActionListScrollFrameUpdate()
end

local stateList = {}

function ION.ActionListScrollFrameUpdate(frame)

	if (not IonButtonEditorActionList:IsVisible()) then return end

	local bar, i

	if (ION.CurrentObject and ION.CurrentObject.bar) then

		wipe(stateList)

		bar, i = ION.CurrentObject.bar

		stateList["00"..L.HOMESTATE] = "homestate"

		for state, values in pairs(MAS) do

			if (bar.cdata[state]) then

				for index, name in pairs(ION.STATES) do

					if (index ~= "laststate" and name ~= ATTRIBUTE_NOOP and values.states:find(index)) then

						i = index:match("%d+")

						if (i) then
							i = values.order..i
						else
							i = values.order
						end

						if (values.homestate and index == values.homestate) then
							stateList["00"..name] = "homestate"; stateList["00"..L.HOMESTATE] = nil
						elseif (values.order < 10) then
							stateList["0"..i..name] = index
						else
							stateList[i..name] = index
						end
					end
				end
			end
		end

	else
		wipe(stateList)
	end

	if (not frame) then
		frame = IonButtonEditorActionListScrollFrame
	end

	local dataOffset, count, data, button, text, datum = FauxScrollFrame_GetOffset(frame), 1, {}

	for k in pairs(stateList) do
		data[count] = k; count = count + 1
	end

	table.sort(data)

	frame:Show()

	frame.buttonH = frame:GetHeight()/numShown

	for i=1,numShown do

		button = _G["IonButtonEditorActionListScrollFrameButton"..i]
		button:SetChecked(nil)

		count = dataOffset + i

		if (data[count]) then

			text = data[count]

			if (bar and stateList[text] == bar.handler:GetAttribute("fauxstate")) then
				button:SetChecked(1)
			end

			button.bar = bar
			button.state = stateList[text]
			button.name:SetText(text:gsub("^%d+",""))
			button:Enable()
			button:Show()

			button.name:SetTextColor(1,0.82,0)
			button.name:SetJustifyH("CENTER")

		else

			button:Hide()
		end
	end

	FauxScrollFrame_Update(frame, #data, numShown, 2)
end

function ION:MacroEditorUpdate()

	if (ION.CurrentObject and ION.CurrentObject.objType == "ACTIONBUTTON") then

		local button, spec, IBTNE = ION.CurrentObject, IonSpec.cSpec, IonButtonEditor
		local state = button.bar.handler:GetAttribute("fauxstate")
		local data = button.specdata[spec][state]

		if (data) then

			IBTNE.macroedit.edit:SetText(data.macro_Text)

			if (not data.macro_Icon) then
				IBTNE.macroicon.icon:SetTexture(button.iconframeicon:GetTexture())
			elseif (data.macro_Icon == "BLANK") then
				IBTNE.macroicon.icon:SetTexture("")
			else
				IBTNE.macroicon.icon:SetTexture(data.macro_Icon)
			end

			IBTNE.nameedit:SetText(data.macro_Name)
			IBTNE.noteedit:SetText(data.macro_Note)
			IBTNE.usenote:SetChecked(data.macro_UseNote)
		end
	end
end

function ION.ButtonEditorUpdate(reset)

	if (reset and ION.CurrentObject) then

		local bar = ION.CurrentObject.bar

		bar.handler:SetAttribute("fauxstate", bar.handler:GetAttribute("activestate"))

		IonButtonEditor.macroicon.icon:SetTexture("")
	end

	ION.ActionListScrollFrameUpdate()

	ION:MacroEditorUpdate()

end

function ION:ButtonEditor_OnShow(frame)

	ION.ButtonEditorUpdate(true)

end

function ION:ButtonEditor_OnHide(frame)


end

local function macroText_OnEditFocusLost(self)

	self.hasfocus = nil

	local button = ION.CurrentObject

	if (button) then

		button:UpdateFlyout()
		button:BuildStateData()
		button:SetType()

		ION:MacroEditorUpdate()
	end
end

local function macroText_OnTextChanged(self)

	if (self.hasfocus) then

		local button, spec = ION.CurrentObject, IonSpec.cSpec
		local state = button.bar.handler:GetAttribute("fauxstate")

		if (button and spec and state) then
			button.specdata[spec][state].macro_Text = self:GetText()
		end
	end
end

local function macroNameEdit_OnTextChanged(self)

	if (strlen(self:GetText()) > 0) then
		self.text:Hide()
	end

	if (self.hasfocus) then

		local button, spec = ION.CurrentObject, IonSpec.cSpec
		local state = button.bar.handler:GetAttribute("fauxstate")

		if (button and spec and state) then
			button.specdata[spec][state].macro_Name = self:GetText()
		end

	elseif (strlen(self:GetText()) <= 0) then
		self.text:Show()
	end
end

local function macroNoteEdit_OnTextChanged(self)

	if (strlen(self:GetText()) > 0) then
		self.text:Hide()
		self.cb:Show()
	else
		self.cb:Hide()
	end

	if (self.hasfocus) then

		local button, spec = ION.CurrentObject, IonSpec.cSpec
		local state = button.bar.handler:GetAttribute("fauxstate")

		if (button and spec and state) then
			button.specdata[spec][state].macro_Note = self:GetText()
		end
	end
end

local function macroOnEditFocusLost(self)

	self.hasfocus = nil

	local button = ION.CurrentObject

	if (button) then
		button:MACRO_UpdateAll(true)
	end

	if (self.text and strlen(self:GetText()) <= 0) then
		self.text:Show()
	end
end

local function macroIconOnClick(frame)

	if (frame.iconlist:IsVisible()) then
		frame.iconlist:Hide()
	else
		frame.iconlist:Show()
	end

	frame:SetChecked(nil)

end

local IconList = {}

local function updateIconList()

	wipe(IconList)

	local search

	if (IonButtonEditor.search) then
		search = IonButtonEditor.search:GetText()
		if (strlen(search) < 1) then
			search = nil
		end
	end

	for index, icon in ipairs(ICONS) do
		if (search) then
			if (icon:lower():find(search:lower()) or index == 1) then
				tinsert(IconList, icon)
			end
		else
			tinsert(IconList, icon)
		end
	end
end

function ION.MacroIconListUpdate(frame)

	if (not frame) then
		frame = IonButtonEditor.iconlist
	end

	local numIcons, offset, index, texture, blankSet = #IconList+1, FauxScrollFrame_GetOffset(frame)

	for i,btn in ipairs(frame.buttons) do

		index = (offset * 14) + i

		texture = IconList[index]

		if (index < numIcons) then

			btn.icon:SetTexture(texture)
			btn:Show()
			btn.texture = texture

		elseif (not blankSet) then

			btn.icon:SetTexture("")
			btn:Show()
			btn.texture = "BLANK"
			blankSet = true

		else
			btn.icon:SetTexture("")
			btn:Hide()
			btn.texture = ICONS[1]
		end

	end

	FauxScrollFrame_Update(frame, ceil(numIcons/14), 1, 1, nil, nil, nil, nil, nil, nil, true)

end

local function customPathOnShow(self)

	local button = ION.CurrentObject

	if (button) then

		if (button.data.macro_Icon) then

			local text = button.data.macro_Icon:gsub("INTERFACE\\", "")

			self:SetText(text)

		else
			self:SetText("")
		end
	else
		self:SetText("")
	end

	self:SetCursorPosition(0)
end

local function customDoneOnClick(self)

	local button = ION.CurrentObject

	if (button) then

		local text = self.frame.custompath:GetText()

		if (#text > 0) then

			text = "INTERFACE\\"..text:gsub("\\", "\\")

			button.data.macro_Icon = text

			button:MACRO_UpdateIcon()

			ION:UpdateObjectGUI()
		end
	end

	self:GetParent():Hide()
end

function ION:ButtonEditor_OnLoad(frame)

	frame:RegisterForDrag("LeftButton", "RightButton")

	ION.Editors.ACTIONBUTTON[1] = frame
	ION.Editors.ACTIONBUTTON[4] = ION.ButtonEditorUpdate

	frame.tabs = {}

	local f

	f = CreateFrame("Frame", nil, frame)
	f:SetPoint("TOPLEFT", frame.actionlist, "TOPRIGHT", 10, -10)
	f:SetPoint("BOTTOMRIGHT", -10, 10)
	f:SetScript("OnUpdate", function(self,elapsed) if (self.elapsed == 0) then ION:UpdateObjectGUI(true) end self.elapsed = elapsed end)
	f.elapsed = 0
	frame.macro = f

	f = CreateFrame("ScrollFrame", "$parentMacroEditor", frame.macro, "IonScrollFrameTemplate2")
	f:SetPoint("TOPLEFT", frame.macro, "TOPLEFT", 2, -95)
	f:SetPoint("BOTTOMRIGHT", -2, 20)
	f.edit:SetWidth(350)
	f.edit:SetHeight(200)
	f.edit:SetScript("OnTextChanged", macroText_OnTextChanged)
	f.edit:SetScript("OnEditFocusGained", function(self) self.hasfocus = true self:SetText(self:GetText():gsub("#autowrite\n", "")) end)
	f.edit:SetScript("OnEditFocusLost", macroText_OnEditFocusLost)
	frame.macroedit = f

	f = CreateFrame("Button", nil, frame.macro)
	f:SetPoint("TOPLEFT", frame.macroedit, "TOPLEFT", -10, 10)
	f:SetPoint("BOTTOMRIGHT", -18, 0)
	f:SetWidth(350)
	f:SetHeight(200)
	f:SetScript("OnClick", function(self) self.macroedit.edit:SetFocus() end)
	f.macroedit = frame.macroedit
	frame.macrofocus = f

	f = CreateFrame("Frame", nil, frame.macroedit)
	f:SetPoint("TOPLEFT", -10, 10)
	f:SetPoint("BOTTOMRIGHT", 4, -20)
	f:SetFrameLevel(frame.macroedit.edit:GetFrameLevel()-1)
	frame.macroeditBG = f

	ION.SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("CheckButton", nil, frame.macro, "IonMacroIconButtonTemplate")
	f:SetID(0)
	f:SetPoint("BOTTOMLEFT", frame.macroedit, "TOPLEFT", -6, 15)
	f:SetWidth(54)
	f:SetHeight(54)
	f:SetScript("OnEnter", function() end)
	f:SetScript("OnLeave", function() end)
	f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	f.slot:SetVertexColor(0.5,0.5,0.5,1)
	f.onclick_func = macroIconOnClick
	f.onupdate_func = function() end
	f.elapsed = 0
	f.click = false
	f.parent = frame
	f.iconlist = frame.iconlist
	f.iconlist:SetScript("OnShow", function(self) self.scrollbar.scrollStep = 1 IonObjectEditor.done:Hide() updateIconList() ION.MacroIconListUpdate(self) end)
	f.iconlist:SetScript("OnHide", function() IonObjectEditor.done:Show() end)
	frame.macroicon = f

	f = CreateFrame("Button", nil, frame.macro)
	f:SetPoint("BOTTOMLEFT", frame.macroicon, "BOTTOMRIGHT", 2, -7)
	f:SetWidth(34)
	f:SetHeight(34)
	f:SetScript("OnClick", function(self) end)
	f:SetNormalTexture("Interface\\AddOns\\Ion\\Images\\UI-RotationRight-Button-Up")
	f:SetPushedTexture("Interface\\AddOns\\Ion\\Images\\UI-RotationRight-Button-Down")
	f:SetHighlightTexture("Interface\\AddOns\\Ion\\Images\\UI-Common-MouseHilight")
	frame.otherspec = f

	f = CreateFrame("CheckButton", nil, frame.macro, "IonCheckButtonTemplate1")
	f:SetWidth(104)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.otherspec, "RIGHT", -1, 1.25)
	f:SetScript("OnClick", function(self) end)
	f:SetChecked(nil)
	f.text:SetText("")
	frame.macromaster = f

	f = CreateFrame("CheckButton", nil, frame.macro, "IonCheckButtonTemplate1")
	f:SetWidth(104)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.macromaster, "RIGHT", 0, 0)
	f:SetScript("OnClick", function(self) end)
	f:SetChecked(nil)
	f.text:SetText("")
	frame.snippets = f

	f = CreateFrame("CheckButton", nil, frame.macro, "IonCheckButtonTemplate1")
	f:SetWidth(104)
	f:SetHeight(33.5)
	f:SetPoint("LEFT", frame.snippets, "RIGHT", 0, 0)
	f:SetScript("OnClick", function(self) end)
	f:SetChecked(nil)
	f.text:SetText("")
	frame.somethingsomething = f

	f = CreateFrame("EditBox", nil, frame.macro)
	f:SetMultiLine(false)
	f:SetNumeric(false)
	f:SetAutoFocus(false)
	f:SetTextInsets(5,5,5,5)
	f:SetFontObject("GameFontHighlight")
	f:SetJustifyH("CENTER")
	f:SetPoint("TOPLEFT", frame.macroicon, "TOPRIGHT", 5, 3.5)
	f:SetPoint("BOTTOMRIGHT", frame.macroeditBG, "TOP", -18, 32)
	f:SetScript("OnTextChanged", macroNameEdit_OnTextChanged)
	f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.hasfocus = true end)
	f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() end macroOnEditFocusLost(self) end)
	f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	frame.nameedit = f

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	f.text:SetPoint("CENTER")
	f.text:SetJustifyH("CENTER")
	f.text:SetText(L.MACRO_NAME)

	f = CreateFrame("Frame", nil, frame.nameedit)
	f:SetPoint("TOPLEFT", 0, 0)
	f:SetPoint("BOTTOMRIGHT", 0, 0)
	f:SetFrameLevel(frame.nameedit:GetFrameLevel()-1)

	ION.SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("EditBox", nil, frame.macro)
	f:SetMultiLine(false)
	f:SetMaxLetters(50)
	f:SetNumeric(false)
	f:SetAutoFocus(false)
	f:SetJustifyH("CENTER")
	f:SetJustifyV("CENTER")
	f:SetTextInsets(5,5,5,5)
	f:SetFontObject("GameFontHighlightSmall")
	f:SetPoint("TOPLEFT", frame.nameedit, "TOPRIGHT", 0, 0)
	f:SetPoint("BOTTOMRIGHT", frame.macroeditBG, "TOPRIGHT",-16, 32)
	f:SetScript("OnTextChanged", macroNoteEdit_OnTextChanged)
	f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.hasfocus = true end)
	f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() end macroOnEditFocusLost(self) end)
	f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	frame.noteedit = f

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	f.text:SetPoint("CENTER", 10, 0)
	f.text:SetJustifyH("CENTER")
	f.text:SetText(L.MACRO_EDITNOTE)

	f = CreateFrame("Frame", nil, frame.noteedit)
	f:SetPoint("TOPLEFT", 0, 0)
	f:SetPoint("BOTTOMRIGHT", 15, 0)
	f:SetFrameLevel(frame.noteedit:GetFrameLevel()-1)

	ION.SubFrameBlackBackdrop_OnLoad(f)

	f = CreateFrame("CheckButton", nil, frame.macro, "IonOptionsCheckButtonTemplate")
	f:SetID(0)
	f:SetWidth(16)
	f:SetHeight(16)
	f:SetScript("OnShow", function() end)
	f:SetScript("OnClick", function() end)
	f:SetPoint("RIGHT", frame.noteedit, "RIGHT", 12, 0)
	f:SetFrameLevel(frame.noteedit:GetFrameLevel()+1)
	f:Hide()
	f.tooltipText = L.MACRO_USENOTE
	frame.usenote = f
	frame.noteedit.cb = f

	frame.iconlist.buttons = {}

	local count, x, y = 0, 28, -16

	for i=1,112 do

		f = CreateFrame("CheckButton", nil, frame.iconlist, "IonMacroIconButtonTemplate")
		f:SetID(i)
		f:SetFrameLevel(frame.iconlist:GetFrameLevel()+2)
		f.slot:SetVertexColor(0.5,0.5,0.5,1)
		f:SetScript("OnEnter", function(self)
							self.fl = self:GetFrameLevel()
							self:SetFrameLevel(self.fl+1)
							self:GetNormalTexture():SetPoint("TOPLEFT", -7, 7)
							self:GetNormalTexture():SetPoint("BOTTOMRIGHT", 7, -7)
							self.slot:SetPoint("TOPLEFT", -10, 10)
							self.slot:SetPoint("BOTTOMRIGHT", 10, -10)
						end)
		f:SetScript("OnLeave", function(self)
							self:SetFrameLevel(self.fl)
							self:GetNormalTexture():SetPoint("TOPLEFT", 2, -2)
							self:GetNormalTexture():SetPoint("BOTTOMRIGHT", -2, 2)
							self.slot:SetPoint("TOPLEFT", -2, 2)
							self.slot:SetPoint("BOTTOMRIGHT", 2, -2)
						end)
		f.onclick_func = function(self, button, down)

							local object = ION.CurrentObject

							if (object and object.data) then

								if (self.texture == "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK") then
									object.data.macro_Icon = false
								else
									object.data.macro_Icon = self.texture
								end

								object:MACRO_UpdateIcon()

								ION:UpdateObjectGUI()
							end

							self:SetFrameLevel(self.fl-1)
							self.click = true
							self.elapsed = 0
							self:GetParent():Hide()
							self:SetChecked(nil)
					   end

		count = count + 1

		f:SetPoint("CENTER", frame.iconlist, "TOPLEFT", x, y)

		if (count == 14) then
			x = 28; y = y - 35; count = 0
		else
			x = x + 35.5
		end

		tinsert(frame.iconlist.buttons, f)

	end

	f = CreateFrame("EditBox", nil, frame.iconlist, "IonEditBoxTemplateSmall")
	f:SetWidth(378)
	f:SetHeight(30)
	f:SetJustifyH("LEFT")
	f:SetTextInsets(22, 0, 0, 0)
	f:SetPoint("TOPLEFT", 8, 36)
	f:SetScript("OnShow", function(self) self:SetText("") end)
	f:SetScript("OnEnterPressed", function(self) updateIconList() ION.MacroIconListUpdate() self:ClearFocus() self.hasfocus = nil end)
	f:SetScript("OnTabPressed", function(self) updateIconList() ION.MacroIconListUpdate() self:ClearFocus() self.hasfocus = nil end)
	f:SetScript("OnEscapePressed", function(self) self:SetText("") updateIconList() ION.MacroIconListUpdate()  self:ClearFocus() self.hasfocus = nil end)
	f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.cancel:Show() self.hasfocus = true end)
	f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() self.cancel:Hide() end self.hasfocus = nil end)
	f:SetScript("OnTextChanged", function(self) if (strlen(self:GetText()) < 1 and not self.hasfocus) then self.text:Show() self.cancel:Hide() end end)
	frame.search = f

	ION.SubFrameBlackBackdrop_OnLoad(f)

	f.cancel = CreateFrame("Button", nil, f)
	f.cancel:SetWidth(20)
	f.cancel:SetHeight(20)
	f.cancel:SetPoint("RIGHT", -3, 0)
	f.cancel:SetScript("OnClick", function(self) self.parent:SetText("") updateIconList() ION.MacroIconListUpdate()  self.parent:ClearFocus() self.parent.hasfocus = nil end)
	f.cancel:Hide()
	f.cancel.tex = f.cancel:CreateTexture(nil, "OVERLAY")
	f.cancel.tex:SetTexture("Interface\\FriendsFrame\\ClearBroadcastIcon")
	f.cancel.tex:SetAlpha(0.7)
	f.cancel.tex:SetAllPoints()
	f.cancel.parent = f

	f.searchicon = f:CreateTexture(nil, "OVERLAY")
	f.searchicon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
	f.searchicon:SetPoint("LEFT", 6, -2)

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontDisable");
	f.text:SetPoint("LEFT", 22, 0)
	f.text:SetJustifyH("LEFT")
	f.text:SetText(L.SEARCH)

	f = CreateFrame("Button", nil, frame.iconlist, "IonCheckButtonTemplate1")
	f:SetWidth(122)
	f:SetHeight(35)
	f:SetPoint("TOPLEFT", frame.search, "TOPRIGHT", -1, 4)
	f:SetScript("OnClick", function(self) self:Hide() self.frame.search:Hide() self.frame.customdone:Show() self.frame.customcancel:Show() self.frame.custompath:Show() end)
	f.text:SetText(L.CUSTOM_ICON)
	f.frame = frame
	frame.customicon = f

	f = CreateFrame("Button", nil, frame.iconlist, "IonCheckButtonTemplate1")
	f:SetWidth(60)
	f:SetHeight(35)
	f:SetPoint("TOPLEFT", frame.search, "TOPRIGHT", -1, 4)
	f:SetScript("OnClick", function(self) self:Hide()  self.frame.customcancel:Hide() self.frame.custompath:Hide() self.frame.customicon:Show() self.frame.search:Show() customDoneOnClick(self) end)
	f:SetFrameLevel(frame.customicon:GetFrameLevel()+1)
	f:Hide()
	f.text:SetText(L.DONE)
	f.frame = frame
	frame.customdone = f

	f = CreateFrame("Button", nil, frame.iconlist, "IonCheckButtonTemplate1")
	f:SetWidth(60)
	f:SetHeight(35)
	f:SetPoint("LEFT", frame.customdone, "RIGHT", 0, 0)
	f:SetScript("OnClick", function(self) self:Hide() self.frame.customdone:Hide() self.frame.custompath:Hide() self.frame.customicon:Show() self.frame.search:Show() end)
	f:SetFrameLevel(frame.customicon:GetFrameLevel()+1)
	f:Hide()
	f.text:SetText(L.CANCEL)
	f.frame = frame
	frame.customcancel = f

	f = CreateFrame("EditBox", nil, frame.iconlist, "IonEditBoxTemplateSmall")
	f:SetWidth(378)
	f:SetHeight(30)
	f:SetJustifyH("LEFT")
	f:SetPoint("TOPLEFT",  frame.search, "TOPLEFT", 0, 0)
	f:SetScript("OnShow", customPathOnShow)
	f:SetFrameLevel(frame.search:GetFrameLevel()+1)
	f:Hide()
	f:SetScript("OnEscapePressed", function(self) ION:ButtonEditorIconList_ResetCustom(self.frame) end)
	f:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	--f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.cancel:Show() self.hasfocus = true end)
	--f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() self.cancel:Hide() end self.hasfocus = nil end)
	f:SetScript("OnTextChanged", function(self) self:SetText(self:GetText():upper()) end)
	f.frame = frame
	frame.custompath = f

	ION.SubFrameBlackBackdrop_OnLoad(f)

	f.text = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	f.text:SetPoint("LEFT", 8, 0)
	f.text:SetJustifyH("LEFT")
	f.text:SetText(L.PATH..": INTERFACE\\")

	f:SetTextInsets(f.text:GetWidth()+5, 0, 0, 0)


	f = CreateFrame("Frame", nil, frame)
	f:SetPoint("TOPLEFT", frame.actionlist, "TOPRIGHT", 10, -10)
	f:SetPoint("BOTTOMRIGHT", -10, 10)
	f:SetScript("OnUpdate", function(self,elapsed) if (self.elapsed == 0) then ION:UpdateObjectGUI(true) end self.elapsed = elapsed end)
	f:Hide()
	f.elapsed = 0
	frame.action = f

	f = CreateFrame("Frame", nil, frame)
	f:SetPoint("TOPLEFT", frame.actionlist, "TOPRIGHT", 10, -10)
	f:SetPoint("BOTTOMRIGHT", -10, 10)
	f:SetScript("OnUpdate", function(self,elapsed) if (self.elapsed == 0) then ION:UpdateObjectGUI(true) end self.elapsed = elapsed end)
	f:Hide()
	f.elapsed = 0
	frame.options = f

	local function TabsOnClick(cTab, silent)

		for tab, panel in pairs(frame.tabs) do

			if (tab == cTab) then
				tab:SetChecked(1)
				if (MouseIsOver(cTab)) then
					PlaySound("igCharacterInfoTab")
				end
				panel:Show()
			else
				tab:SetChecked(nil)
				panel:Hide()
			end

		end
	end

	local f = CreateFrame("CheckButton", nil, frame, "IonCheckButtonTemplate1")
	f:SetWidth(125)
	f:SetHeight(28)
	f:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -28, -8.5)
	f:SetScript("OnClick", function(self) TabsOnClick(self, true) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(nil)
	f.text:SetText(L.OPTIONS)
	frame.tab3 = f; frame.tabs[f] = frame.options

	f = CreateFrame("CheckButton", nil, frame, "IonCheckButtonTemplate1")
	f:SetWidth(125)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab3, "LEFT", -5, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(nil)
	f.text:SetText(L.ACTION)
	frame.tab2 = f; frame.tabs[f] = frame.action

	f = CreateFrame("CheckButton", nil, frame, "IonCheckButtonTemplate1")
	f:SetWidth(125)
	f:SetHeight(28)
	f:SetPoint("RIGHT", frame.tab2, "LEFT", -5, 0)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel()+1)
	f:SetChecked(1)
	f.text:SetText(L.MACRO)
	frame.tab1 = f; frame.tabs[f] = frame.macro



end

function ION:ButtonEditorIconList_ResetCustom(frame)

	frame.customdone:Hide()
	frame.customcancel:Hide()
	frame.custompath:Hide()

	frame.search:Show()
	frame.customicon:Show()

end


function ION.ColorPicker_OnLoad(self)

	self:SetFrameStrata("TOOLTIP")
	self.apply.text:SetText(L.APPLY)
	self.cancel.text:SetText(L.CANCEL)
end


function ION.ColorPicker_OnShow(self)
	local r,g,b = self:GetColorRGB()
	self.redvalue:SetText(r); self.redvalue:SetCursorPosition(0)
	self.greenvalue:SetText(g); self.greenvalue:SetCursorPosition(0)
	self.bluevalue:SetText(b); self.bluevalue:SetCursorPosition(0)
	self.hexvalue:SetText(string.upper(string.format("%02x%02x%02x", math.ceil((r*255)), math.ceil((g*255)), math.ceil((b*255))))); self.hexvalue:SetCursorPosition(0)
end

function ION.ColorPicker_OnColorSelect(self, r, g, b)
	self.redvalue:SetText(r)
	self.greenvalue:SetText(g)
	self.bluevalue:SetText(b)
	self.hexvalue:SetText(string.upper(string.format("%02x%02x%02x", math.ceil((r*255)), math.ceil((g*255)), math.ceil((b*255)))))
end

function ION:MainMenu_OnLoad(frame)

	ION.SubFrameHoneycombBackdrop_OnLoad(frame)

	frame:SetWidth(width)
	frame:SetHeight(height)

	frame:RegisterEvent("ADDON_LOADED")
	frame:RegisterForDrag("LeftButton", "RightButton")

end

--not an optimal solution, but it works for now
local function hookHandler(handler)

	handler:HookScript("OnAttributeChanged", function(self,name,value)

		if (IonObjectEditor:IsVisible() and self == ION.CurrentObject.bar.handler and name == "activestate" and not IonButtonEditor.macroedit.edit.hasfocus) then
			IonButtonEditor.macro.elapsed = 0
		end

	end)
end

local function runUpdater(self, elapsed)

	self.elapsed = elapsed

	if (self.elapsed > 0) then

		ION:UpdateBarGUI()
		ION:UpdateObjectGUI()

		self:Hide()
	end
end

local updater = CreateFrame("Frame", nil, UIParent)
updater:SetScript("OnUpdate", runUpdater)
updater.elapsed = 0
updater:Hide()

local function hookMountButtons()

	if (MountJournal.ListScrollFrame.buttons) then

		for i,btn in pairs(MountJournal.ListScrollFrame.buttons) do
			btn.DragButton:HookScript("OnClick", modifiedMountClick)
		end
	end
end

local function hookPetJournalButtons()

	if (PetJournal.listScroll.buttons) then

		for i,btn in pairs(PetJournal.listScroll.buttons) do
			btn.dragButton:HookScript("OnClick", modifiedPetJournalClick)
		end
	end
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Ion-GUI") then

		IMM = IonMainMenu
		IBE = IonBarEditor
		IOE = IonObjectEditor
		IBTNE = IonButtonEditor

		MAS = ION.MANAGED_ACTION_STATES

		for _,bar in pairs(ION.BARIndex) do
			hookHandler(bar.handler)
		end

		hooksecurefunc("SpellButton_OnModifiedClick", modifiedSpellClick)
		hooksecurefunc("HandleModifiedItemClick", modifiedItemClick)
		hooksecurefunc("OpenStackSplitFrame", openStackSplitFrame)

		if (MountJournal) then
			hookMountButtons(); hookPetJournalButtons()
		end

	elseif (event == "ADDON_LOADED" and ... == "Blizzard_PetJournal") then

		hookMountButtons()
		hookPetJournalButtons()

	elseif (event == "PLAYER_SPECIALIZATION_CHANGED") then

		updater.elapsed = 0
		updater:Show()

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		PEW = true
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
--frame:SetScript("OnUpdate", controlOnUpdate)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")