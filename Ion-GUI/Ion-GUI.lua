--Ion GUI, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local ION, GDB, CDB, PEW = Ion

local width, height = 775, 440

local barNames = {}

local numShown = 15

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

local LGUI = LibStub("AceLocale-3.0"):GetLocale("IonGUI")

IonGUIGDB = {
	firstRun = true,
}

IonGUICDB = {

}

local defGDB, defCDB = CopyTable(IonGUIGDB), CopyTable(IonGUICDB)

function ION:UpdateGUI()

	ION.BarListScrollFrameUpdate()
end

function ION.BarList_OnLoad(self)

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


local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Ion-GUI") then

	IonBarEditor:SetWidth(width)
	IonBarEditor:SetHeight(height)

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		PEW = true
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:SetScript("OnUpdate", controlOnUpdate)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")