--Ion, a World of Warcraft® user interface addon.

local ION, DB, PEW = Ion

ION.OBJEDITOR = setmetatable({}, { __index = CreateFrame("Button") })

ION.Editors = {}

local BUTTON, OBJEDITOR = ION.BUTTON, ION.OBJEDITOR

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

local BARIndex, BTNIndex, EDITIndex = ION.BARIndex, ION.BTNIndex, ION.EDITIndex

local sIndex = ION.sIndex
local cIndex = ION.cIndex

function OBJEDITOR:OnShow()

	local object = self.object

	if (object) then

		if (object.bar) then
			self:SetFrameLevel(object.bar:GetFrameLevel()+1)
		end
	end
end

function OBJEDITOR:OnHide()


end

function OBJEDITOR:OnEnter()

	local object = self.object

	self.select:Show()

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	GameTooltip:Show()

end

function OBJEDITOR:OnLeave()

	if (self.object ~= ION.CurrentObject) then
		self.select:Hide()
	end

	GameTooltip:Hide()

end

function OBJEDITOR:OnClick(button)

	local newObj, newEditor = ION:ChangeObject(self.object)

	if (button == "RightButton") then

		if (not IsAddOnLoaded("Ion-GUI")) then
			LoadAddOn("Ion-GUI")
		end

		if (IonObjectEditor) then
			if (not newObj and IonObjectEditor:IsVisible()) then
				IonObjectEditor:Hide()
			elseif (newObj and newEditor) then
				ION:ObjectEditor_OnShow(IonObjectEditor); IonObjectEditor:Show()
			else
				IonObjectEditor:Show()
			end
		end

	elseif (newObj and newEditor and IonObjectEditor:IsVisible()) then
		ION:ObjectEditor_OnShow(IonObjectEditor); IonObjectEditor:Show()
	end

	if (IonObjectEditor and IonObjectEditor:IsVisible()) then
		ION:UpdateObjectGUI()
	end
end

function OBJEDITOR:ACTIONBAR_SHOWGRID(...)

	if (not InCombatLockdown() and self:IsVisible()) then
		self:Hide(); self.showgrid = true
	end

end

function OBJEDITOR:ACTIONBAR_HIDEGRID(...)

	if (not InCombatLockdown() and self.showgrid) then
		self:Show(); self.showgrid = nil
	end

end

function OBJEDITOR:OnEvent(event, ...)

	if (self[event]) then
		self[event](self, ...)
	end

end

local OBJEDITOR_MT = { __index = OBJEDITOR }

function BUTTON:CreateEditFrame(index)

	local EDITOR = CreateFrame("Button", self:GetName().."EditFrame", self, "IonEditFrameTemplate")

	setmetatable(EDITOR, OBJEDITOR_MT)

	EDITOR:EnableMouseWheel(true)
	EDITOR:RegisterForClicks("AnyDown")
	EDITOR:SetAllPoints(self)
	EDITOR:SetScript("OnShow", OBJEDITOR.OnShow)
	EDITOR:SetScript("OnHide", OBJEDITOR.OnHide)
	EDITOR:SetScript("OnEnter", OBJEDITOR.OnEnter)
	EDITOR:SetScript("OnLeave", OBJEDITOR.OnLeave)
	EDITOR:SetScript("OnClick", OBJEDITOR.OnClick)
	EDITOR:SetScript("OnEvent", OBJEDITOR.OnEvent)
	EDITOR:RegisterEvent("ACTIONBAR_SHOWGRID")
	EDITOR:RegisterEvent("ACTIONBAR_HIDEGRID")

	EDITOR.type:SetText(L.EDITFRAME_EDIT)
	EDITOR.object = self
	EDITOR.editType = "button"

	self.OBJEDITOR = EDITOR

	EDITIndex["BUTTON"..index] = EDITOR

	EDITOR:Hide()

end

function ION:ChangeObject(object)

	local newObj, newEditor = false, false

	if (PEW) then

		if (object and object ~= ION.CurrentObject) then

			if (ION.CurrentObject and ION.CurrentObject.OBJEDITOR.editType ~= object.OBJEDITOR.editType) then
				newEditor = true
			end

			if (ION.CurrentObject and ION.CurrentObject.bar ~= object.bar) then

				local bar = ION.CurrentObject.bar

				if (bar.handler:GetAttribute("assertstate")) then
					bar.handler:SetAttribute("state-"..bar.handler:GetAttribute("assertstate"), bar.handler:GetAttribute("activestate") or "homestate")
				end

				object.bar.handler:SetAttribute("fauxstate", bar.handler:GetAttribute("activestate"))

			end

			ION.CurrentObject = object

			object.OBJEDITOR.select:Show()

			object.selected = true
			object.action = nil

			newObj = true
		end

		if (not object) then
			ION.CurrentObject = nil
		end

		for k,v in pairs(EDITIndex) do
			if (not object or v ~= object.OBJEDITOR) then
				v.select:Hide()
			end
		end
	end

	return newObj, newEditor
end

function ION:ToggleEditFrames(show, hide)

	if (ION.EditFrameShown or hide) then

		ION.EditFrameShown = false

		for index, OBJEDITOR in pairs(EDITIndex) do
			OBJEDITOR:Hide(); OBJEDITOR.object.editmode = ION.EditFrameShown
			OBJEDITOR:SetFrameStrata("LOW")
		end

		for _,bar in pairs(BARIndex) do
			bar:UpdateObjectGrid(ION.EditFrameShown)
			if (bar.handler:GetAttribute("assertstate")) then
				bar.handler:SetAttribute("state-"..bar.handler:GetAttribute("assertstate"), bar.handler:GetAttribute("activestate") or "homestate")
			end
		end

		ION:ChangeObject()

		if (IsAddOnLoaded("Ion-GUI")) then
			IonObjectEditor:Hide()
		end

		collectgarbage()

	else

		ION:ToggleMainMenu(nil, true)
		ION:ToggleBars(nil, true)
		ION:ToggleBindings(nil, true)

		ION.EditFrameShown = true

		for index, OBJEDITOR in pairs(EDITIndex) do
			OBJEDITOR:Show(); OBJEDITOR.object.editmode = ION.EditFrameShown

			if (OBJEDITOR.object.bar) then
				OBJEDITOR:SetFrameStrata(OBJEDITOR.object.bar:GetFrameStrata())
				OBJEDITOR:SetFrameLevel(OBJEDITOR.object.bar:GetFrameLevel()+4)
			end
		end

		for _,bar in pairs(BARIndex) do
			bar:UpdateObjectGrid(ION.EditFrameShown)
		end
	end
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Ion") then

		ION.Editors.ACTIONBUTTON = { nil, 550, 350, nil }

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		PEW = true
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")