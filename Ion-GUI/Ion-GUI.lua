--Ion GUI, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local ION, GDB, CDB, IBE, IOE, MAS, PEW = Ion

local width, height = 775, 440

local barNames = {}

local numShown = 15

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

local LGUI = LibStub("AceLocale-3.0"):GetLocale("IonGUI")

local GUIData = ION.RegisteredGUIData

ION.Editors = {}

IonGUIGDB = {
	firstRun = true,
}

IonGUICDB = {

}

local defGDB, defCDB = CopyTable(IonGUIGDB), CopyTable(IonGUICDB)

local barOpt = { chk = {}, adj = {}, pri = {}, sec = {} }

local chkOptions = {

	[1] = { [0] = "AUTOHIDE", LGUI.AUTOHIDE, 1, "AutoHideBar" },
	[2] = { [0] = "SHOWGRID", LGUI.SHOWGRID, 1, "ShowGridSet" },
	[3] = { [0] = "SPELLGLOW", LGUI.SPELLGLOW, 1, "SpellGlowSet" },
	[4] = { [0] = "SNAPTO", LGUI.SNAPTO, 1, "SnapToBar" },
	[5] = { [0] = "DUALSPEC", LGUI.DUALSPEC, 1, "DualSpecSet" },
	[6] = { [0] = "HIDDEN", LGUI.HIDDEN, 1, "ConcealBar" },
	[7] = { [0] = "LOCKBAR", LGUI.LOCKBAR, 1, "LockSet" },
	[8] = { [0] = "LOCKBAR", LGUI.LOCKBAR_SHIFT, 0.9, "LockSet", "shift" },
	[9] = { [0] = "LOCKBAR", LGUI.LOCKBAR_CTRL, 0.9, "LockSet", "ctrl" },
	[10] = { [0] = "LOCKBAR", LGUI.LOCKBAR_ALT, 0.9, "LockSet", "alt" },
	[11] = { [0] = "TOOLTIPS", LGUI.TOOLTIPS, 1, "ToolTipSet" },
	[12] = { [0] = "TOOLTIPS", LGUI.TOOLTIPS_ENH, 0.9, "ToolTipSet", "enhanced" },
	[13] = { [0] = "TOOLTIPS", LGUI.TOOLTIPS_COMBAT, 0.9, "ToolTipSet", "combat" },
}

local adjOptions = {

	[1] = { [0] = "SHAPE", LGUI.SHAPE, 2, "ShapeBar" },
	[2] = { [0] = "COLUMNS", LGUI.COLUMNS, 1, "ColumnsSet" },
	[3] = { [0] = "ARCSTART", LGUI.ARCSTART, 1, "ArcStartSet" },
	[4] = { [0] = "ARCLENGTH", LGUI.ARCLENGTH, 1, "ArcLengthSet" },
	[5] = { [0] = "HPAD", LGUI.HPAD, 1, "PadHSet" },
	[6] = { [0] = "VPAD", LGUI.VPAD, 1, "PadVSet" },
	[7] = { [0] = "HVPAD", LGUI.HVPAD, 1, "PadHVSet" },
	[8] = { [0] = "SCALE", LGUI.SCALE, 1, "ScaleBar" },
	[9] = { [0] = "STRATA", LGUI.STRATA, 2, "StrataSet" },
	[10] = { [0] = "ALPHA", LGUI.ALPHA, 1, "AlphaSet" },
	[11] = { [0] = "ALPHAUP", LGUI.ALPHAUP, 2, "AlphaUpSet" },
	[12] = { [0] = "ALPHAUP", LGUI.ALPHAUP_SPEED, 1, "AlphaUpSpeedSet" },
}

--[[
	[1] = "",
	[2] = "CreateNewBar",
	[3] = "DeleteBar",
	[4] = "ToggleBars",
	[5] = "AddObjects",
	[6] = "RemoveObjects",
	[7] = "",
	[8] = "ToggleBindings",
	[9] = "ScaleBar",
	[10] = "SnapToBar",
	[11] = "AutoHideBar",
	[12] = "ConcealBar",
	[13] = "ShapeBar",
	[14] = "NameBar",
	[15] = "StrataSet",
	[16] = "AlphaSet",
	[17] = "AlphaUpSet",
	[18] = "ArcStartSet",
	[19] = "ArcLengthSet",
	[20] = "ColumnsSet",
	[21] = "PadHSet",
	[22] = "PadVSet",
	[23] = "PadHVSet",
	[24] = "XAxisSet",
	[25] = "YAxisSet",
	[26] = "SetState",
	[27] = "SetVisibility",
	[28] = "ShowGridSet",
	[29] = "LockSet",
	[30] = "ToolTipSet",
	[31] = "SpellGlowSet",
	[32] = "BindTextSet",
	[33] = "MacroTextSet",
	[34] = "CountTextSet",
	[35] = "CDTextSet",
	[36] = "CDAlphaSet",
	[37] = "AuraTextSet",
	[38] = "AuraIndSet",
	[39] = "UpClicksSet",
	[40] = "DownClicksSet",
	[41] = "SetTimerLimit",
	[42] = "PrintStateList",
	[43] = "PrintBarTypes",
]]--

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

function ION:UpdateBarGUI()

	ION.BarListScrollFrameUpdate()

	local bar = Ion.CurrentBar

	if (bar and GUIData[bar.class]) then

		if (IonBarEditor.baropt:IsVisible()) then

			local yoff, anchor, last, adjHeight = -10
			local editor = IonBarEditor.baropt.editor

			if (GUIData[bar.class].stateOpt) then

				editor.tab1:Enable()
				editor.tab2:Enable()

				editor.tab1:Click()

				editor:SetPoint("BOTTOMLEFT", 0, 155)

				adjHeight = 151

			else
				editor.tab3:Click()

				editor.tab1:Disable()
				editor.tab2:Disable()

				editor:SetPoint("BOTTOMLEFT", 0, 275)

				adjHeight = 271
			end

			for i,f in ipairs(barOpt.pri) do
				f:SetChecked(bar.cdata[f.option])
			end

			for i,f in ipairs(barOpt.sec) do
				f:SetChecked(bar.cdata[f.option])
			end

			for i,f in ipairs(barOpt.chk) do
				f:ClearAllPoints(); f:Hide()
			end

			for i,f in ipairs(barOpt.chk) do

				if (GUIData[bar.class].chkOpt[f.option]) then

					if (f:GetScale() < 1) then
						f:SetPoint("TOPLEFT", f.parent, "TOPLEFT", 30, (yoff/f:GetScale())+3)
						yoff = yoff-f:GetHeight()-5
					else
						f:SetPoint("TOPLEFT", f.parent, "TOPLEFT", 10, yoff)
						yoff = yoff-f:GetHeight()-8
					end

					f:Show()

					if (bar[f.func]) then
						f:SetChecked(bar[f.func](bar, f.modtext, true, nil, true))
					end
				end
			end

			local yoff1, yoff2, shape = (adjHeight)/6, (adjHeight)/6

			for i,f in ipairs(barOpt.adj) do

				f:ClearAllPoints(); f:Hide()

				if (bar[f.func] and f.option == "SHAPE") then

					shape = bar[f.func](bar, nil, true, true)

					if (shape ~= L.BAR_SHAPE1) then
						yoff1 = (adjHeight)/7
					end
				end
			end

			yoff = -(yoff1/2)

			for i,f in ipairs(barOpt.adj) do

				if (i==2) then

					if (shape == L.BAR_SHAPE1) then

						f:SetPoint("TOPLEFT", f.parent, "TOPLEFT", 10, yoff)
						f:Show()

						yoff = yoff-yoff1
					end

				elseif (i==3 or i==4) then

					if (shape ~= L.BAR_SHAPE1) then

						f:SetPoint("TOPLEFT", f.parent, "TOPLEFT", 10, yoff)
						f:Show()

						yoff = yoff-yoff1
					end

				elseif (i >= 8) then

					if (i==8) then
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
					f.edit:SetText(bar[f.func](bar, nil, true, true))
					f.edit:SetCursorPosition(0)
				end
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

function Ion:BarEditor_OnLoad(frame)

	frame:SetBackdropBorderColor(0.7, 0.7, 0.7)
	frame:SetBackdropColor(0,0,0,1)
	frame:RegisterEvent("ADDON_LOADED")
	frame:RegisterForDrag("LeftButton", "RightButton")
	frame.bottom = 0

end

function ION:BarList_OnLoad(self)

	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	self:SetBackdropColor(0,0,0,0.5)
	self:GetParent().backdrop = self

	self:SetHeight(height-55)
end

function ION.BarListScrollFrame_OnLoad(self)

	self.offset = 0
	self.scrollChild = _G[self:GetName().."ScrollChildFrame"]

	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	self:SetBackdropColor(0,0,0,0.5)

	local button, lastButton, rowButton, count, fontString, script = false, false, false, 0

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

							if (IonBarEditor and IonBarEditor:IsVisible()) then
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

		fontString = button:CreateFontString(button:GetName().."Index", "ARTWORK", "GameFontNormalSmall")
		fontString:SetPoint("TOPLEFT", button, "TOPLEFT", 5, 0)
		fontString:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 0)
		fontString:SetJustifyH("LEFT")
		button.name = fontString

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
	button.text:SetText(LGUI.CREATE_BAR)

end

function ION:BarEditor_CreateNewBar(button)

	if (button.type == "create") then

		local data = { [LGUI.SELECT_BAR_TYPE] = "none" }

		for class,info in pairs(ION.RegisteredBarData) do
			if (info.barCreateMore) then
				data[info.barLabel] = class
			end
		end

		ION.BarListScrollFrameUpdate(nil, data, true)

		button.type = "cancel"

		button.text:SetText(LGUI.CANCEL)
	else

		ION.BarListScrollFrameUpdate()

		button.type = "create"

		button.text:SetText(LGUI.CREATE_BAR)

	end
end

function ION:DeleteButton_OnLoad(button)

	button.parent = button:GetParent()
	button.parent.delete = button
	button.type = "delete"
	button.text:SetText(LGUI.DELETE_BAR)

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
	button.title:SetText(LGUI.CONFIRM)

end

function ION:ConfirmYes_OnLoad(button)

	button.parent = button:GetParent()
	button.type = "yes"
	_G[button:GetName().."Text"]:SetText(LGUI.CONFIRM_YES)

end

function ION:BarEditor_ConfirmYes(button)

	local bar = ION.CurrentBar

	if (bar) then
		bar:DeleteBar()
	end

	IonBarEditorBarOptionsDelete:Click()

end

function ION:ConfirmNo_OnLoad(button)

	button.parent = button:GetParent()
	button.type = "no"
	_G[button:GetName().."Text"]:SetText(LGUI.CONFIRM_NO)
end

function ION:BarEditor_ConfirmNo(button)
	IonBarEditorBarOptionsDelete:Click()
end

function ION:BarOptions_OnLoad(frame)

	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)

	local f, last

	for index, options in ipairs(chkOptions) do

		f = CreateFrame("CheckButton", nil, frame, "IonOptionsCheckButtonTemplate")
		f:SetID(index)
		f:SetWidth(18)
		f:SetHeight(18)
		f:SetScript("OnShow", function() end)
		f:SetScript("OnClick", function() end)
		f:SetScale(options[2])

		f.text:SetText(options[1])
		f.option = options[0]
		f.func = options[3]
		f.modtext = options[4]
		f.parent = frame

		tinsert(barOpt.chk, f)
	end
end

function ION:StateEditor_OnLoad(frame)

	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)

	frame.tabs = {}

	local function TabsOnClick(cTab, silent)

		for tab, panel in pairs(frame.tabs) do

			if (tab == cTab) then
				IonPanelTemplates_SelectTab(tab);
				if (MouseIsOver(cTab)) then
					PlaySound("igCharacterInfoTab")
				end
				panel:Show()
			else
				IonPanelTemplates_DeselectTab(tab); panel:Hide()
			end

		end
	end

	local f = CreateFrame("CheckButton", frame:GetName().."Preset", frame, "IonTopTabTemplate")
	f:SetWidth(18)
	f:SetHeight(18)
	f:SetPoint("BOTTOMLEFT", frame, "TOPLEFT",0,-5)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel())
	f.text:SetText(LGUI.PRESET_STATES)
	frame.tab1 = f; frame.tabs[f] = frame.presets

	IonPanelTemplates_SelectTab(frame.tab1); IonPanelTemplates_TabResize(frame.tab1, 0, nil, 120, 175)

	f = CreateFrame("CheckButton", frame:GetName().."Custom", frame, "IonTopTabTemplate")
	f:SetWidth(18)
	f:SetHeight(18)
	f:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT",0,-5)
	f:SetScript("OnClick", function(self) TabsOnClick(self) end)
	f:SetFrameLevel(frame:GetFrameLevel())
	f.text:SetText(LGUI.CUSTOM_STATES)
	frame.tab2 = f; frame.tabs[f] = frame.custom

	IonPanelTemplates_DeselectTab(frame.tab2); IonPanelTemplates_TabResize(frame.tab2, 0, nil, 120, 175)

	f = CreateFrame("CheckButton", frame:GetName().."Hidden", frame, "IonTopTabTemplate")
	f:SetWidth(18)
	f:SetHeight(18)
	f:SetPoint("BOTTOM", frame, "TOP",0,-5)
	f:SetScript("OnClick", function(self) TabsOnClick(self, true) end)
	f:SetFrameLevel(frame:GetFrameLevel())
	f:Hide()
	frame.tab3 = f; frame.tabs[f] = frame.hidden

	IonPanelTemplates_DeselectTab(frame.tab3); IonPanelTemplates_TabResize(frame.tab3, 0, nil, 120, 175)

	local states, anchor, last, count = {}

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
			f:SetScript("OnShow", function() end)
			f:SetScript("OnClick", function() end)
			f.text:SetText(LGUI[state:upper()])
			f.option = state

			if (not anchor) then
				f:SetPoint("TOPLEFT", frame.presets.primary, "TOPLEFT", 10, -10)
				anchor = f; last = f
			else
				f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
				last = f
			end

			tinsert(barOpt.pri, f)
		end
	end

	anchor, last, count = nil, nil, 1

	for index,state in ipairs(states) do

		if (not MAS[state].homestate and state ~= "custom") then

			f = CreateFrame("CheckButton", nil, frame.presets.secondary, "IonOptionsCheckButtonTemplate")
			f:SetID(index)
			f:SetWidth(18)
			f:SetHeight(18)
			f:SetScript("OnShow", function() end)
			f:SetScript("OnClick", function() end)
			f.text:SetText(LGUI[state:upper()])
			f.option = state

			if (not anchor) then
				f:SetPoint("TOPLEFT", frame.presets.secondary, "TOPLEFT", 10, -10)
				anchor = f; last = f
			elseif (count == 5) then
				f:SetPoint("LEFT", anchor, "RIGHT", 90, 0)
				anchor = f; last = f; count = 1
			else
				f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
				last = f
			end

			count = count + 1

			tinsert(barOpt.sec, f)
		end
	end

	f = CreateFrame("EditBox", "$parentRemap", frame.presets, "IonDropDownOptionFull")
	f:SetWidth(165)
	f:SetHeight(25)
	f:SetTextInsets(7,3,0,0)
	f.text:SetText(LGUI.REMAP)
	f:SetPoint("BOTTOMLEFT", frame.presets, "BOTTOMLEFT", 7, 5)
	f:SetPoint("BOTTOMRIGHT", frame.presets, "BOTTOM", -20, 5)
	f:SetScript("OnTextChanged", function() end)
	f:SetScript("OnShow", function() end)
	f:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
	frame.remap = f

	f = CreateFrame("EditBox", "$parentRemapTo", frame.presets, "IonDropDownOptionFull")
	f:SetWidth(160)
	f:SetHeight(25)
	f:SetTextInsets(7,3,0,0)
	f.text:SetText(LGUI.REMAPTO)
	f:SetPoint("BOTTOMLEFT", frame.presets, "BOTTOM", 5, 5)
	f:SetPoint("BOTTOMRIGHT", frame.presets, "BOTTOMRIGHT", -28, 5)
	f:SetScript("OnTextChanged", function() end)
	f:SetScript("OnShow", function() end)
	f:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
	frame.remapto = f
end

function ION.AdjustableOptions_OnLoad(frame)

	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)

	for index, options in ipairs(adjOptions) do

		f = CreateFrame("Frame", nil, frame, "IonAdjustOptionTemplate")
		f:SetID(index)
		f:SetWidth(200)
		f:SetHeight(24)
		f:SetScript("OnShow", function() end)

		f.text:SetText(options[1]..":")
		f["method"..options[2]]:Show()
		f.edit = f["method"..options[2]].edit
		f.option = options[0]
		f.func = options[3]
		f.parent = frame

		tinsert(barOpt.adj, f)
	end
end


function ION:ObjectEditor_OnLoad(frame)

	frame:SetBackdropBorderColor(0.7, 0.7, 0.7);
	frame:SetBackdropColor(0,0,0,1);
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
			ION.Editors[objType][1]:Show()
			IOE:SetWidth(ION.Editors[objType][2])
			IOE:SetHeight(ION.Editors[objType][3])
		end
	end

end

function ION:ObjectEditor_OnHide(frame)

end

function ION:ActionList_OnLoad(frame)

	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)
	frame:GetParent().backdrop = frame

end

function ION:ActionListScrollFrame_OnLoad(frame)

	frame.offset = 0
	frame.scrollChild = _G[frame:GetName().."ScrollChildFrame"]

	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)

	local button, lastButton, rowButton, count, fontString, script = false, false, false, 0

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

		fontString = button:CreateFontString(button:GetName().."Index", "ARTWORK", "GameFontNormalSmall")
		fontString:SetPoint("TOPLEFT", button, "TOPLEFT", 5, 0)
		fontString:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 0)
		fontString:SetJustifyH("LEFT")
		button.name = fontString

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
			else
				IBTNE.macroicon.icon:SetTexture(data.macro_Icon)
			end

			IBTNE.nameedit:SetText(data.macro_Name)
			IBTNE.noteedit:SetText(data.macro_Note)
			IBTNE.usenote:SetChecked(data.macro_UseNote)

		else
			if (state) then
				print("State: "..state)
			else
				print("no state")
			end

			if (spec) then
				print("Spec: "..spec)
			else
				print("no spec")
			end
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

function macroText_OnEditFocusLost(self)

	self.hasfocus = nil

	local button = ION.CurrentObject

	if (button) then

		button:UpdateFlyout()
		button:BuildStateData()
		button:SetType()

		ION:MacroEditorUpdate()
	end
end

function macroText_OnTextChanged(self)

	if (self.hasfocus) then

		local button, spec = ION.CurrentObject, IonSpec.cSpec
		local state = button.bar.handler:GetAttribute("fauxstate")

		if (button and spec and state) then
			button.specdata[spec][state].macro_Text = self:GetText()
		end
	end
end

function macroNameEdit_OnTextChanged(self)

	if (strlen(self:GetText()) > 0) then
		self.text:Hide()
	end

	if (self.hasfocus) then

		local button, spec = ION.CurrentObject, IonSpec.cSpec
		local state = button.bar.handler:GetAttribute("fauxstate")

		if (button and spec and state) then
			button.specdata[spec][state].macro_Name = self:GetText()
		end
	end
end

function macroNoteEdit_OnTextChanged(self)

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

function macroOnEditFocusLost(self)

	self.hasfocus = nil

	local button = ION.CurrentObject

	if (button) then
		button:MACRO_UpdateAll(true)
	end

	if (self.text and strlen(self:GetText()) <= 0) then
		self.text:Show()
	end
end

function ION:ButtonEditor_OnLoad(frame)

	frame:RegisterForDrag("LeftButton", "RightButton")

	ION.Editors.ACTIONBUTTON = { frame, 550, 350, ION.ButtonEditorUpdate }

	frame.panels = {}

	local f, fontStr

	f = CreateFrame("Frame", nil, frame)
	f:SetPoint("TOPLEFT", frame.actionlist, "TOPRIGHT", 10, -10)
	f:SetPoint("BOTTOMRIGHT", -10, 10)
	f:SetScript("OnUpdate", function(self,elapsed) if (self.elapsed == 0) then ION:UpdateObjectGUI(true) end self.elapsed = elapsed end)
	f.elapsed = 0
	frame.macro = f

	tinsert(frame.panels, f)

	f = CreateFrame("ScrollFrame", "$parentMacroEditor", frame.macro, "IonScrollFrameTemplate2")
	f:SetPoint("TOPLEFT", frame.macro, "TOPLEFT", 2, -115)
	f:SetPoint("BOTTOMRIGHT", -2, 20)
	f.edit:SetWidth(350)
	f.edit:SetScript("OnTextChanged", macroText_OnTextChanged)
	f.edit:SetScript("OnEditFocusGained", function(self) self.hasfocus = true end)
	f.edit:SetScript("OnEditFocusLost", macroText_OnEditFocusLost)
	frame.macroedit = f

	f = CreateFrame("Frame", nil, frame.macroedit)
	f:SetPoint("TOPLEFT", -10, 10)
	f:SetPoint("BOTTOMRIGHT", 4, -20)
	f:SetFrameLevel(frame.macroedit.edit:GetFrameLevel()-1)
	f:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	f:SetBackdropBorderColor(0.5, 0.5, 0.5)
	f:SetBackdropColor(0,0,0,0.5)
	frame.macroeditBG = f

	f = CreateFrame("CheckButton", nil, frame.macro, "IonMacroIconButtonTemplate")
	f:SetID(0)
	f:SetPoint("BOTTOMLEFT", frame.macroedit, "TOPLEFT", -6, 17)
	f:SetWidth(44)
	f:SetHeight(44)
	f:SetScript("OnShow", function() end)
	f:SetScript("OnEnter", function() end)
	f:SetScript("OnLeave", function() end)
	f.onclick_func = function() end
	f.onupdate_func = function() end
	f.elapsed = 0
	f.click = false
	f.parent = frame
	frame.macroicon = f

	f = CreateFrame("EditBox", nil, frame.macro)
	f:SetMultiLine(false)
	f:SetNumeric(false)
	f:SetAutoFocus(false)
	f:SetTextInsets(5,5,5,5)
	f:SetFontObject("GameFontHighlight")
	f:SetJustifyH("CENTER")
	f:SetPoint("TOPLEFT", frame.macroicon, "TOPRIGHT", 5, 2)
	f:SetPoint("BOTTOMRIGHT", frame.macroeditBG, "TOP", -20, 25)
	f:SetScript("OnTextChanged", macroNameEdit_OnTextChanged)
	f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.hasfocus = true end)
	f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() end macroOnEditFocusLost(self) end)
	f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	frame.nameedit = f

	fontStr = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("CENTER")
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(LGUI.MACRO_NAME)
	f.text = fontStr

	f = CreateFrame("Frame", nil, frame.nameedit)
	f:SetPoint("TOPLEFT", 0, 0)
	f:SetPoint("BOTTOMRIGHT", 0, 0)
	f:SetFrameLevel(frame.nameedit:GetFrameLevel()-1)
	f:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	f:SetBackdropBorderColor(0.5, 0.5, 0.5)
	f:SetBackdropColor(0,0,0,0.5)

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
	f:SetPoint("BOTTOMRIGHT", frame.macroeditBG, "TOPRIGHT",-15, 25)
	f:SetScript("OnTextChanged", macroNoteEdit_OnTextChanged)
	f:SetScript("OnEditFocusGained", function(self) self.text:Hide() self.hasfocus = true end)
	f:SetScript("OnEditFocusLost", function(self) if (strlen(self:GetText()) < 1) then self.text:Show() end macroOnEditFocusLost(self) end)
	f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	f:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	frame.noteedit = f

	fontStr = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("CENTER", 10, 0)
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(LGUI.MACRO_EDITNOTE)
	f.text = fontStr

	f = CreateFrame("Frame", nil, frame.noteedit)
	f:SetPoint("TOPLEFT", 0, 0)
	f:SetPoint("BOTTOMRIGHT", 15, 0)
	f:SetFrameLevel(frame.noteedit:GetFrameLevel()-1)
	f:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	f:SetBackdropBorderColor(0.5, 0.5, 0.5)
	f:SetBackdropColor(0,0,0,0.5)

	f = CreateFrame("CheckButton", nil, frame.macro, "IonOptionsCheckButtonTemplate")
	f:SetID(0)
	f:SetWidth(16)
	f:SetHeight(16)
	f:SetScript("OnShow", function() end)
	f:SetScript("OnClick", function() end)
	f:SetPoint("RIGHT", frame.noteedit, "RIGHT", 12, 0)
	f:SetFrameLevel(frame.noteedit:GetFrameLevel()+1)
	f:Hide()
	f.tooltipText = LGUI.MACRO_USENOTE
	frame.usenote = f
	frame.noteedit.cb = f

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

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Ion-GUI") then

		IonBarEditor:SetWidth(width)
		IonBarEditor:SetHeight(height)

		IBE = IonBarEditor
		IOE = IonObjectEditor

		MAS = ION.MANAGED_ACTION_STATES

		for _,bar in pairs(ION.BARIndex) do
			hookHandler(bar.handler)
		end

	elseif (event == "PLAYER_SPECIALIZATION_CHANGED") then

		updater.elapsed = 0
		updater:Show()

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		PEW = true
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:SetScript("OnUpdate", controlOnUpdate)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")