--Ion, a World of Warcraft® user interface addon.

local ION, DB, PEW = Ion

ION.BINDER = setmetatable({}, { __index = CreateFrame("Button") })

local BUTTON, BINDER = ION.BUTTON, ION.BINDER

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

local BTNIndex = ION.BTNIndex

local BINDIndex = ION.BINDIndex

local sIndex = ION.sIndex
local cIndex = ION.cIndex

function BINDER:GetModifier()

	local modifier

	if (IsAltKeyDown()) then
		modifier = "ALT-"
	end

	if (IsControlKeyDown()) then
		if (modifier) then
			modifier = modifier.."CTRL-";
		else
			modifier = "CTRL-";
		end
	end

	if (IsShiftKeyDown()) then
		if (modifier) then
			modifier = modifier.."SHIFT-";
		else
			modifier = "SHIFT-";
		end
	end

	return modifier
end


function BINDER:GetBindkeyList(button)

	if (not button.data) then return L.KEYBIND_NONE end

	local bindkeys = button.keys.hotKeyText:gsub(":", ", ")

	bindkeys = bindkeys:gsub("^, ", "")
	bindkeys = bindkeys:gsub(", $", "")

	if (strlen(bindkeys) < 1) then
		bindkeys = L.KEYBIND_NONE
	end

	return bindkeys
end

function BINDER:GetKeyText(key)

	local keytext

	if (key:find("Button")) then

		keytext = key:gsub("([Bb][Uu][Tt][Tt][Oo][Nn])(%d+)","m%2")

	elseif (key:find("NUMPAD")) then

		keytext = key:gsub("NUMPAD","n")
		keytext = keytext:gsub("DIVIDE","/")
		keytext = keytext:gsub("MULTIPLY","*")
		keytext = keytext:gsub("MINUS","-")
		keytext = keytext:gsub("PLUS","+")
		keytext = keytext:gsub("DECIMAL",".")

	elseif (key:find("MOUSEWHEEL")) then

		keytext = key:gsub("MOUSEWHEEL","mw")
		keytext = keytext:gsub("UP","U")
		keytext = keytext:gsub("DOWN","D")
	else
		keytext = key
	end

	keytext = keytext:gsub("ALT%-","a")
	keytext = keytext:gsub("CTRL%-","c")
	keytext = keytext:gsub("SHIFT%-","s")
	keytext = keytext:gsub("INSERT","Ins")
	keytext = keytext:gsub("DELETE","Del")
	keytext = keytext:gsub("HOME","Home")
	keytext = keytext:gsub("END","End")
	keytext = keytext:gsub("PAGEUP","PgUp")
	keytext = keytext:gsub("PAGEDOWN","PgDn")
	keytext = keytext:gsub("BACKSPACE","Bksp")
	keytext = keytext:gsub("SPACE","Spc")

	return keytext
end


function BINDER:ClearBindings(button, key)

	if (key) then

		SetOverrideBinding(button, true, key, nil)

		local newkey = key:gsub("%-", "%%-")

		button.keys.hotKeys = button.keys.hotKeys:gsub(newkey..":", "")

		local keytext = self:GetKeyText(key)

		button.keys.hotKeyText = button.keys.hotKeyText:gsub(keytext..":", "")

	else
		local bindkey = "CLICK "..button:GetName()..":LeftButton"

		while (GetBindingKey(bindkey)) do

			SetBinding(GetBindingKey(bindkey), nil)

		end

		ClearOverrideBindings(button)

		button.keys.hotKeys = ":"

		button.keys.hotKeyText = ":"

	end

	self:ApplyBindings(button)

end

function BINDER:SetIonBinding(button, key)

	local found

	gsub(button.keys.hotKeys, "[^:]+", function(binding) if(binding == key) then found = true end end)

	if (not found) then

		local keytext = self:GetKeyText(key)

		button.keys.hotKeys = button.keys.hotKeys..key..":"
		button.keys.hotKeyText = button.keys.hotKeyText..keytext..":"
	end

	self:ApplyBindings(button)
end

function BINDER:ApplyBindings(button)

	button:SetAttribute("hotkeypri", button.keys.hotKeyPri)

	if (button:IsVisible() or button:GetParent():GetAttribute("concealed")) then
		gsub(button.keys.hotKeys, "[^:]+", function(key) SetOverrideBindingClick(button, button.keys.hotKeyPri, key, button:GetName()) end)
	end

	button:SetAttribute("hotkeys", button.keys.hotKeys)

	button.hotkey:SetText(button.keys.hotKeyText:match("^:([^:]+)") or "")

	if (button.bindText) then
		button.hotkey:Show()
	else
		button.hotkey:Hide()
	end

	if (GetCurrentBindingSet() > 0 and GetCurrentBindingSet() < 3) then SaveBindings(GetCurrentBindingSet()) end
end


function BINDER:ProcessBinding(key, button)

	if (button and button.keys and button.keys.hotKeyLock) then
		UIErrorsFrame:AddMessage(L.BINDINGS_LOCKED, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		return
	end

	if (key == "ESCAPE") then

		self:ClearBindings(button)

	elseif (key) then

		for index,binder in pairs(BINDIndex) do
			if (button ~= binder.button and binder.button.keys and not binder.button.keys.hotKeyLock) then
				binder.button.keys.hotKeys:gsub("[^:]+", function(binding) if (key == binding) then self:ClearBindings(binder.button, binding) self:ApplyBindings(binder.button) end end)
			end
		end

		self:SetIonBinding(button, key)

	end

	if (self:IsVisible()) then
		self:OnEnter()
	end

	button:SaveData()

end

function BINDER:OnShow()

	local button = self.button

	if (button) then

		if (button.bar) then
			self:SetFrameLevel(button.bar:GetFrameLevel()+1)
		end

		local priority = ""

		if (button.keys.hotKeyPri) then
			priority = "|cff00ff00"..L.BINDFRAME_PRIORITY.."|r\n"
		end

		if (button.keys.hotKeyLock) then
			self.type:SetText(priority.."|cfff00000"..L.BINDFRAME_LOCKED.."|r")
		else
			self.type:SetText(priority.."|cffffffff"..L.BINDFRAME_BIND.."|r")
		end
	end
end

function BINDER:OnHide()


end

function BINDER:OnEnter()

	local button = self.button

	self.select:Show()

	IonBindingsEditor:ClearLines()
	IonBindingsEditor:SetText(L.BINDER_NOTICE)
	IonBindingsEditor:AddDoubleLine(L.KEYBIND_TOOLTIP1, self.bindType:gsub("^%l", string.upper).." "..button.id, 1.0, 1.0, 1.0, 0, 1, 0)
	IonBindingsEditor:AddLine(" ")
	IonBindingsEditor:AddLine(format(L.KEYBIND_TOOLTIP2, self.bindType, self.bindType, self.bindType), 1.0, 1.0, 1.0)
	IonBindingsEditor:AddLine(" ")
	IonBindingsEditor:AddDoubleLine(L.KEYBIND_TOOLTIP3, self:GetBindkeyList(button), 1.0, 1.0, 1.0, 0, 1, 0)
	IonBindingsEditor:AddLine(" ")

	IonBindingsEditor:Show()

end

function BINDER:OnLeave()

	IonBindingsEditor:ClearLines()
	IonBindingsEditor:SetText(L.BINDER_NOTICE)

	self.select:Hide()

end

function BINDER:OnUpdate()

	if (self:IsMouseOver()) then
		self:EnableKeyboard(true)
	else
		self:EnableKeyboard(false)
	end
end

function BINDER:OnClick(button)

	if (button == "LeftButton") then

		if (self.button.keys.hotKeyLock) then
			self.button.keys.hotKeyLock = false
		else
			self.button.keys.hotKeyLock = true
		end

		self:OnShow()

		return
	end

	if (button == "RightButton") then

		if (self.button.keys.hotKeyPri) then
			self.button.keys.hotKeyPri = false
		else
			self.button.keys.hotKeyPri = true
		end

		self:ApplyBindings(self.button)

		self:OnShow()

		return
	end

	local modifier, key = self:GetModifier()

	if (button == "MiddleButton") then
		key = "Button3"
	else
		key = button
	end

	if (modifier) then
		key = modifier..key
	end

	self:ProcessBinding(key, self.button)

end

function BINDER:OnKeyDown(key)

	if (key:find("ALT") or key:find("SHIFT") or key:find("CTRL") or key:find("PRINTSCREEN")) then
		return
	end

	local modifier = self:GetModifier()

	if (modifier) then
		key = modifier..key
	end

	self:ProcessBinding(key, self.button)

end

function BINDER:OnMouseWheel(delta)

	local modifier, key, action = self:GetModifier()

	if (delta > 0) then
		key = "MOUSEWHEELUP"
		action = "MousewheelUp"
	else
		key = "MOUSEWHEELDOWN"
		action = "MousewheelDown"
	end

	if (modifier) then
		key = modifier..key
	end

	self:ProcessBinding(key, self.button)

end


local BINDER_MT = { __index = BINDER }

function BUTTON:CreateBindFrame(index)

	local binder = CreateFrame("Button", self:GetName().."BindFrame", self, "IonBindFrameTemplate")

	setmetatable(binder, BINDER_MT)

	binder:EnableMouseWheel(true)
	binder:RegisterForClicks("AnyDown")
	binder:SetAllPoints(self)
	binder:SetScript("OnShow", BINDER.OnShow)
	binder:SetScript("OnHide", BINDER.OnHide)
	binder:SetScript("OnEnter", BINDER.OnEnter)
	binder:SetScript("OnLeave", BINDER.OnLeave)
	binder:SetScript("OnClick", BINDER.OnClick)
	binder:SetScript("OnKeyDown", BINDER.OnKeyDown)
	binder:SetScript("OnMouseWheel", BINDER.OnMouseWheel)
	binder:SetScript("OnUpdate", BINDER.OnUpdate)

	binder.type:SetText(L.BINDFRAME_BIND)
	binder.button = self
	binder.bindType = "button"

	self.binder = binder
	self:SetAttribute("hotkeypri", self.keys.hotKeyPri)
	self:SetAttribute("hotkeys", self.keys.hotKeys)

	BINDIndex[self.class..index] = binder

	binder:Hide()

end

function ION:BindingsEditor_OnLoad(frame)

	--this line was causing a crash on the beta
      ION.SubFrameHoneycombBackdrop_OnLoad(frame)

	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.8)

	frame:RegisterForDrag("LeftButton")

	for i = 1, select("#", frame:GetRegions()) do
		local region = select(i, frame:GetRegions())
		if (region and region.SetJustifyH) then
			region:SetJustifyH("CENTER")
			region:SetJustifyV("CENTER")
		end
	end

	IonBindingsEditorTextLeft1:ClearAllPoints()
	IonBindingsEditorTextLeft1:SetPoint("TOP", 0, -10)

	IonBindingsEditorTextLeft2:ClearAllPoints()
	IonBindingsEditorTextLeft2:SetPoint("TOPLEFT", 10, -50)

	IonBindingsEditorTextRight2:ClearAllPoints()
	IonBindingsEditorTextRight2:SetPoint("TOPRIGHT", -10, -62)
	IonBindingsEditorTextRight2:SetFontObject("GameFontNormal")

end

function ION:BindingsEditor_OnShow(frame)

end

function ION:BindingsEditor_OnHide(frame)

end

function ION:ToggleBindings(show, hide)

	if (ION.BindingMode or hide) then

		ION.BindingMode = false

		for index, binder in pairs(BINDIndex) do
			binder:Hide(); binder.button.editmode = ION.BindingMode
			binder:SetFrameStrata("LOW")
			if (not ION.BarsShown) then
				binder.button:SetGrid()
			end
		end

		IonBindingsEditor:Hide()

	else

		ION:ToggleMainMenu(nil, true)
		ION:ToggleEditFrames(nil, true)

		ION.BindingMode = true

		for index, binder in pairs(BINDIndex) do
			binder:Show(); binder.button.editmode = ION.BindingMode

			if (binder.button.bar) then
				binder:SetFrameStrata(binder.button.bar:GetFrameStrata())
				binder:SetFrameLevel(binder.button.bar:GetFrameLevel()+4)
				binder.button:SetGrid(true)
			end
		end

		IonBindingsEditor:SetOwner(UIParent, "ANCHOR_PRESERVE")
		IonBindingsEditor:SetText(L.BINDER_NOTICE)
		IonBindingsEditor:Show()

		--for i = 1, select("#", IonBindingsEditor:GetRegions()) do
		--	local region = select(i, IonBindingsEditor:GetRegions())
		--	if (region) then
		--		print(region:GetName())
		--	end
		--end
	end
end