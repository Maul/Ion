--Ion GUI, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local ION, GDB, CDB, PEW = Ion

local width, height = 775, 440

local numShown = 15

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

IonGUIGDB = {
	firstRun = true,
}

IonGUICDB = {

}

local defGDB, defCDB = CopyTable(IonGUIGDB), CopyTable(IonGUICDB)

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
								--M.CreateNewBar(self.bar)
							end

							self.alt = nil

						elseif (self.bar) then

							--M.ChangeBar(self.bar)

							--M.ObjListFirstBtn:Click()
						end
					else
						button:SetChecked(nil)
					end

					--M.OptionsGeneral_ModifyReset()
				end

			end)

		button:SetScript("OnEnter",
			function(self)
				if (self.alt) then

				elseif (self.bar) then
					--M.Bar_OnEnter(self.bar, true)
				end
			end)

		button:SetScript("OnLeave",
			function(self)
				if (self.alt) then

				elseif (self.bar) then
					--M.Bar_OnLeave(self.bar, true)
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

	--tinsert(M.UpdateFunctions, M.BarListScrollFrameUpdate)
end

local barNames = {}

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

	for k,v in pairs(tableList) do
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
		else

			button:Hide()
		end
	end

	FauxScrollFrame_Update(frame, #data, numShown, 2)
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