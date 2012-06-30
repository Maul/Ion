--Macaroon, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local M = Macaroon

M.CurrentBar = nil
M.EditorWidth = 775
M.EditorHeight = 440

local barShapes = {
	[1] = M.Strings.BARSHAPE_1,
	[2] = M.Strings.BARSHAPE_2,
	[3] = M.Strings.BARSHAPE_3,
}

local barStates = {
	[1] = { "pagedbar" },
	[2] = { "stance" },
	[3] = { "companion" },
	[4] = { "stealth" },
	[5] = { "vehicle" },
	[6] = { "possess" },
	[7] = { "fishing" },
	[8] = { "combat" },
	[9] = { "reaction" },
	[10] = { "group" },
	[11] = { "alt" },
	[12] = { "ctrl" },
	[13] = { "shift" },
	[14] = { "custom" },
}

local alphaUpValues = {
	[1] = M.Strings.ALPHAUP_NONE,
	[2] = M.Strings.ALPHAUP_BATTLE,
	[3] = M.Strings.ALPHAUP_MOUSEOVER,
	[4] = M.Strings.ALPHAUP_BATTLEMOUSE,
	[5] = M.Strings.ALPHAUP_RETREAT,
	[6] = M.Strings.ALPHAUP_RETREATMOUSE,
}

local frameStratas = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "TOOLTIP" }

local arcPresets = {
	[1] = { M.Strings.ARC_PRESET_1, 173, 180 },
	[2] = { M.Strings.ARC_PRESET_2, 353, 180 },
	[3] = { M.Strings.ARC_PRESET_3, 262, 180 },
	[4] = { M.Strings.ARC_PRESET_4, 82, 180 },
	[5] = { M.Strings.ARC_PRESET_5, 90, 360 },
}

local targetNames = { "-none-", "player", "pet", "target", "targettarget", "focus", "focustarget", "mouseover", "party1", "party2", "party3", "party4" }

local editMode, alphaTimer, SD, pew, showFrame = false, 0
local numShown = 15

local find = string.find
local lower = string.lower
local format = string.format
local gsub = string.gsub
local match = string.match
local strlen = strlen

local GetMouseFocus = _G.GetMouseFocus

local SpellIndex = M.SpellIndex
local ManagedStates = M.ManagedStates
local ClearTable = M.ClearTable

local ssdmUpdate = SecureStateDriverManager:GetScript("OnEvent")

local function getBindkeyList(bar)

	local bindkeys = gsub(bar.config.hotKeyText, "_", ", ")

	bindkeys = gsub(bindkeys, "^, ", "")
	bindkeys = gsub(bindkeys, ", $", "")

	if (strlen(bindkeys) < 1) then
		bindkeys = M.Strings.KEYBIND_NONE
	end

	return bindkeys
end

local function getStateList(bar)

	local states = ""

	for state,values in pairs(ManagedStates) do
		for k,v in pairs(barStates) do
			if (bar.config[state] and v[1] == state) then
				states = states..v[2]..", "
			end
		end
	end

	states = gsub(states, ", $", "")

	if (strlen(states) < 1) then
		states = M.Strings.KEYBIND_NONE
	end

	return states
end

local function updateScale(bar, delta)

	if (not delta) then
		return format("%0.2f", bar.config.scale)
	end

	if (delta > 0) then
		bar.config.scale = bar.config.scale + 0.01
	else
		bar.config.scale = bar.config.scale - 0.01
		if (bar.config.scale < 0.2) then
			bar.config.scale = 0.2
		end
	end

	bar.updateBar(bar, nil, true, true)
end

local function updateAlpha(bar, delta)

	if (not delta) then
		return (format("%0.0f", bar.config.alpha*100)).."%"
	end

	if (delta > 0) then
		bar.config.alpha = bar.config.alpha + 0.01
		if (bar.config.alpha > 1) then
			bar.config.alpha = 1
		end
	else
		bar.config.alpha = bar.config.alpha - 0.01
		if (bar.config.alpha < 0) then
			bar.config.alpha = 0
		end
	end

	bar.updateBar(bar, true)
end

local function updateAlphaUp(bar, delta)

	if (not delta) then
		return bar.config.alphaUp
	end

	local currValue = 1

	for k,v in pairs(alphaUpValues) do
		if (bar.config.alphaUp == v) then
			currValue = k
		end
	end

	if (delta > 0) then

		currValue = currValue + 1

		if (currValue > #alphaUpValues) then
			currValue = #alphaUpValues
		end

		bar.config.alphaUp = alphaUpValues[currValue]

	else

		currValue = currValue - 1

		if (currValue < 1) then
			currValue = 1
		end

		bar.config.alphaUp = alphaUpValues[currValue]
	end

	bar.updateBar(bar, true)
end

local function updateAlphaUpFadeSpd(bar, delta)

	if (not delta) then
		return (bar.config.fadeSpeed*100).."%"
	end

	if (delta > 0) then
		bar.config.fadeSpeed = bar.config.fadeSpeed + 0.01
		if (bar.config.fadeSpeed > 1) then
			bar.config.fadeSpeed = 1
		end
	else
		bar.config.fadeSpeed = bar.config.fadeSpeed - 0.01
		if (bar.config.fadeSpeed < 0.01) then
			bar.config.fadeSpeed = 0.01
		end
	end

	bar.updateBar(bar, true)
end

local function updateStratas(bar, delta)

	if (not delta) then
		return bar.config.buttonStrata
	end

	local currStrata = 1

	for k,v in pairs(frameStratas) do
		if (bar.config.buttonStrata == v) then
			currStrata = k
		end
	end

	if (delta > 0) then

		if (currStrata >= 5) then
			bar.config.buttonStrata = frameStratas[5]
			bar.config.barStrata = frameStratas[6]
		else
			bar.config.buttonStrata = frameStratas[currStrata+1]
			bar.config.barStrata = frameStratas[currStrata+2]
		end
	else

		if (currStrata <= 1) then
			bar.config.buttonStrata = frameStratas[1]
			bar.config.barStrata = frameStratas[2]
		else
			bar.config.buttonStrata = frameStratas[currStrata-1]
			bar.config.barStrata = frameStratas[currStrata]
		end
	end

	bar.updateBar(bar, true, true)
end

local function checkArcOptions(bar)

	for k,v in ipairs(MacaroonBarEditor.buttons) do
		if(v.arcBtn) then
			if (bar.config.shape == 2 or bar.config.shape == 3) then
				v:Show()
			else
				v:SetHeight(0); v:Hide()
			end
		end
	end
end

local function updateShape(bar, delta)

	if (not delta) then

		checkArcOptions(bar)

		return barShapes[bar.config.shape]
	end

	if (delta > 0) then

		bar.config.shape = bar.config.shape + 1

		if (bar.config.shape > #barShapes) then
			bar.config.shape = #barShapes
		end
	else

		bar.config.shape = bar.config.shape - 1

		if (bar.config.shape < 1) then
			bar.config.shape = 1
		end
	end

	checkArcOptions(bar)

	bar.updateBar(bar, nil, true, true)
end

local function updateAutohide(bar, delta)

	if (not delta) then
		return bar.config.autoHide
	end

	M.AutohideBar(nil, true)

	bar.updateBar(bar, nil, true, true)

end

local function updateShowgrid(bar, delta)

	if (not delta) then
		return bar.config.showGrid
	end

	M.ShowgridSet(nil, true)

	bar.updateBar(bar, nil, true, true)

end

local function updateSnapto(bar, delta)

	if (not delta) then
		return bar.config.snapTo
	end

	M.SnapToBar(nil, true)

	bar.updateBar(bar, nil, true, true)

end

local function updateSnaptoPad(bar, delta)

	if (not delta) then
		return format("%0.1f", bar.config.snapToPad)
	end

	if (delta > 0) then
		bar.config.snapToPad = bar.config.snapToPad + 0.5
	else
		bar.config.snapToPad = bar.config.snapToPad - 0.5
	end

end

local function updateHidden(bar, delta)

	if (not delta) then
		return bar.config.hidden
	end

	M.HideBar(nil, true)

	bar.updateBar(bar, nil, true, true)

end

local function checkDualSpec(bar)

	for k,v in ipairs(MacaroonBarEditor.buttons) do
		if (v.dualBtn) then
			if (MacaroonSpecProfiles.enabled) then
				v:SetHeight(0); v:Hide()
			else
				v:Show()
			end
		end
	end
end

local function updateDualSpec(bar, delta)

	if (not delta) then

		checkDualSpec(bar)

		return bar.config.dualSpec
	end

	M.DualSpec(nil, true)

	checkDualSpec(bar)

	bar.updateBar(bar, nil, true, true)

end

local function updateArcStart(bar, delta)

	local state = bar.handler:GetAttribute("state-current")

	if (not bar.config.arcData[state]) then
		bar.config.arcData[state] = "0:359"
	end

	local arcStart, arcLength = (":"):split(bar.config.arcData[state])

	if (not delta) then
		return arcStart
	end

	arcStart = tonumber(arcStart); arcLength = tonumber(arcLength)

	if (delta > 0) then

		arcStart = arcStart + 1

		if (arcStart > 359) then
			arcStart = 0
		end
	else

		arcStart = arcStart - 1

		if (arcStart < 0) then
			arcStart = 359
		end
	end

	bar.config.arcData[state] = arcStart..":"..arcLength
	bar.updateBar(bar, nil, true, true)

end

local function updateArcLength(bar, delta)

	local state = bar.handler:GetAttribute("state-current")

	if (not bar.config.arcData[state]) then
		bar.config.arcData[state] = "0:359"
	end

	local arcStart, arcLength = (":"):split(bar.config.arcData[state])

	if (not delta) then
		return arcLength
	end

	arcStart = tonumber(arcStart); arcLength = tonumber(arcLength)

	if (delta > 0) then

		arcLength = arcLength + 1

		if (arcLength > 359) then
			arcLength = 0
		end
	else

		arcLength = arcLength - 1

		if (arcLength < 0) then
			arcLength = 359
		end
	end

	bar.config.arcData[state] = arcStart..":"..arcLength
	bar.updateBar(bar, nil, true, true)

end

local function updateArcPreset(bar, delta)

	local state = bar.handler:GetAttribute("state-current")

	if (not bar.config.arcData[state]) then
		bar.config.arcData[state] = "0:359"
	end

	local arcStart, arcLength = (":"):split(bar.config.arcData[state])
	local index = 5

	arcStart = tonumber(arcStart); arcLength = tonumber(arcLength)

	if (not delta) then

		index = 0

		for k,v in pairs(arcPresets) do
			if (v[2] == arcStart and v[3] == arcLength) then
				index = k
			end
		end

		if (arcPresets[index]) then
			return arcPresets[index][1]
		else
			return M.Strings.ARC_PRESET_0
		end
	end

	for k,v in pairs(arcPresets) do
		if (v[2] == arcStart) then
			index = k
		end
	end

	if (delta > 0) then

		index = index + 1

		if (index > #arcPresets) then
			index = 1
		end
	else

		index = index - 1

		if (index < 1) then
			index = #arcPresets
		end
	end

	bar.config.arcData[state] = arcPresets[index][2]..":"..arcPresets[index][3]
	bar.updateBar(bar, nil, true, true)
end

local function updateColumns(bar, delta)

	if (not delta) then
		return bar.config.columns
	end

	if (delta > 0) then

		if (not bar.config.columns) then
			bar.config.columns = bar[bar.config.currentstate].buttonCount or 0
		end

		bar.config.columns = bar.config.columns + 1

	else
		if (not bar.config.columns) then
			bar.config.columns = bar[bar.config.currentstate].buttonCount or 2
		end

		bar.config.columns = bar.config.columns - 1

		if (bar.config.columns < 1) then
			bar.config.columns = false
		end
	end

	bar.updateBar(bar, nil, true, true)

end

local function updateButtonCount(bar, delta)

	if (not delta) then

		local state, count = bar.handler:GetAttribute("state-current")

		if (state and M.Strings.STATES[state]) then
			if (bar[state]) then
				count = bar[state].buttonCount or "0"
			else
				count = "0"
			end
		end

		return count
	end

	if (delta > 0) then
		M.AddButton()
	else
		M.RemoveButton()
	end

	bar.updateBar(bar, nil, true, true)
end

local function updatePadH(bar, delta)

	local state = bar.handler:GetAttribute("state-current")

	if (not bar.config.padData[state]) then
		bar.config.padData[state] = "0:0"
	end

	local padH, padV = (":"):split(bar.config.padData[state])

	if (not delta) then
		return padH
	end

	padH = tonumber(padH); padV = tonumber(padV)

	if (delta > 0) then
		padH = padH + 0.5
	else
		padH = padH - 0.5
	end

	bar.config.padData[state] = padH..":"..padV
	bar.updateBar(bar, nil, true, true)
end

local function updatePadV(bar, delta)

	local state = bar.handler:GetAttribute("state-current")

	if (not bar.config.padData[state]) then
		bar.config.padData[state] = "0:0"
	end

	local padH, padV = (":"):split(bar.config.padData[state])

	if (not delta) then
		return padV
	end

	padH = tonumber(padH); padV = tonumber(padV)

	if (delta > 0) then
		padV = padV + 0.5
	else
		padV = padV - 0.5
	end

	bar.config.padData[state] = padH..":"..padV
	bar.updateBar(bar, nil, true, true)

end

local function updatePadHV(bar, delta)

	local state = bar.handler:GetAttribute("state-current")

	if (not bar.config.padData[state]) then
		bar.config.padData[state] = "0:0"
	end

	local padH, padV = (":"):split(bar.config.padData[state])

	if (not delta) then
		return ""
	end

	padH = tonumber(padH); padV = tonumber(padV)

	if (delta > 0) then
		padH = padH + 0.5
		padV = padV + 0.5
	else
		padH = padH - 0.5
		padV = padV - 0.5
	end

	bar.config.padData[state] = padH..":"..padV
	bar.updateBar(bar, nil, true, true)
end

--updateBar(bar, options, shape, size, pos)

local cycleOrder = {}

local stateOrder = {
	[1] = "companion0",
	[2] = "companion1",
	[3] = "stealth1",
	[4] = "vehicle1",
	[5] = "possess1",
	[6] = "fishing1",
	[7] = "combat1",
	[8] = "reaction1",
	[9] = "group1",
	[10] = "group2",
	[11] = "alt1",
	[12] = "ctrl1",
	[13] = "shift1",
}

local function updateCycleOrder(bar)

	ClearTable(cycleOrder)

	local index = 1

	cycleOrder[index] = "homestate"
	index = index + 1

	for i=1,NUM_ACTIONBAR_PAGES do
		cycleOrder[index] = "pagedbar"..i
		index = index + 1
	end

	if (UnitClass("player") ~= M.Strings.WARRIOR and GetNumShapeshiftForms() ~= 0) then
		cycleOrder[index] = "stance0"
		index = index + 1
	end

	for i=1,GetNumShapeshiftForms() do
		cycleOrder[index] = "stance"..i
		index = index + 1
	end

	if (bar.config.prowl) then
		cycleOrder[index] = "stance8"
		index = index + 1
	end

	for k,v in ipairs(stateOrder) do
		cycleOrder[index] = v
		index = index + 1
	end

	if (bar.config.custom and bar.config.customRange) then

		local start = tonumber(match(bar.config.customRange, "^%d+"))
		local stop = tonumber(match(bar.config.customRange, "%d+$"))

		if (start and stop) then
			for i=start,stop do
				cycleOrder[index] = "custom"..i
				index = index + 1
			end
		end
	end
end

local function updateState(bar, delta)

	local currState, homestate = bar.handler:GetAttribute("state-current"), bar.handler:GetAttribute("handler-homestate")

	if (not delta) then

		local text = M.GetBarStateText(bar, currState)

		if (text) then
			return "|cff00ff00"..text.."|r"
		end
	end

	local range, newState, index, found = 1

	for k,v in ipairs(cycleOrder) do
		if (v == currState) then
			index = k
		end
	end

	if (index) then

		local count = 1

		while (not found and count <= #cycleOrder) do

			if (delta > 0) then

				index = index + 1

				if (index > #cycleOrder) then
					index = range
				end
			else
				index = index - 1

				if (index < range) then
					index = #cycleOrder
				end
			end

			newState = match(cycleOrder[index], "%a+")

			if (bar.config[newState]) then

				newState = cycleOrder[index]

				if (newState == homestate) then
					count = count - 1
				else
					found = true
				end
			end

			count = count + 1
		end
	end

	bar.handler:SetAttribute("state-current", newState)
	bar.updateBar(bar, nil, true, true)
end

local actionTable = {
	[M.Strings.BAR_EDIT_ADJUSTBTN_1] = updateScale,
	[M.Strings.BAR_EDIT_ADJUSTBTN_2] = updateAlpha,
	[M.Strings.BAR_EDIT_ADJUSTBTN_3] = updateAlphaUp,
	[M.Strings.BAR_EDIT_ADJUSTBTN_4] = updateAlphaUpFadeSpd,
	[M.Strings.BAR_EDIT_ADJUSTBTN_5] = updateStratas,
	[M.Strings.BAR_EDIT_ADJUSTBTN_6] = updateAutohide,
	[M.Strings.BAR_EDIT_ADJUSTBTN_7] = updateShowgrid,
	[M.Strings.BAR_EDIT_ADJUSTBTN_8] = updateSnapto,
	[M.Strings.BAR_EDIT_ADJUSTBTN_9] = updateSnaptoPad,
	[M.Strings.BAR_EDIT_ADJUSTBTN_10] = updateHidden,
	[M.Strings.BAR_EDIT_ADJUSTBTN_11] = updateDualSpec,
	[M.Strings.BAR_EDIT_ADJUSTBTN_12] = updateShape,

	[M.Strings.BAR_EDIT_ARC_ADJUSTBTN_1] = updateArcStart,
	[M.Strings.BAR_EDIT_ARC_ADJUSTBTN_2] = updateArcLength,
	[M.Strings.BAR_EDIT_ARC_ADJUSTBTN_3] = updateArcPreset,

	[M.Strings.BAR_EDIT_OBJECT_ADJUSTBTN_1] = updateState,
	[M.Strings.BAR_EDIT_OBJECT_ADJUSTBTN_2] = updateButtonCount,
	[M.Strings.BAR_EDIT_OBJECT_ADJUSTBTN_3] = updateColumns,
	[M.Strings.BAR_EDIT_OBJECT_ADJUSTBTN_4] = updatePadH,
	[M.Strings.BAR_EDIT_OBJECT_ADJUSTBTN_5] = updatePadV,
	[M.Strings.BAR_EDIT_OBJECT_ADJUSTBTN_6] = updatePadHV,
}

local function updateValues(bar, delta, action)

	if (bar) then
		if (actionTable[action]) then
			return actionTable[action](bar, delta)
		end
	else
		return "---"
	end
end

function M.ConfigBars(off, on)

	if (InCombatLockdown()) then
		return
	end

	if (not editMode and MacaroonObjectEditor:IsVisible()) then

		M.ObjectEdit()

	elseif ((editMode or off) and not on) then

		for k,v in pairs(M.BarIndex) do
			v:Hide()
			v.handler:SetAttribute("editmode", false)
		end

		M.ChangeBar()

		editMode = false

		if (not off) then
			for k,v in pairs(M.HideGrids) do
				v(true)
			end
		end

		M.ObjectEdit(true)
		M.ButtonBind(true)
		M.RaiseButtons(true)

		MacaroonBarEditor.shrink = true

		M.Save()

		MacaroonMinimapButton:SetFrameStrata(MinimapCluster:GetFrameStrata())
		MacaroonMinimapButton:SetFrameLevel(MinimapCluster:GetFrameLevel()+3)

		if (SD.checkButtons[107] and IsAddOnLoaded("Align")) then
			Grid_Hide()
		end

		collectgarbage()

	else

		local bars

		editMode = true

		for k,v in pairs(M.BarIndex) do
			v:Show(); bars = true
		end

		if (not off) then
			for k,v in pairs(M.ShowGrids) do
				v(true)
			end
		end

		if (not bars) then
			M.BarEditorShow()
		end

		MacaroonMinimapButton:SetFrameStrata("TOOLTIP")

		if (SD.checkButtons[107] and IsAddOnLoaded("Align")) then
			Grid_Show()
		end
	end
end

function M.ChangeBar(self)

	local newBar = false

	if (pew) then

		if (self and M.CurrentBar ~= self) then

			newBar = true
			M.CurrentBar = self
			self.selected = true
			self.action = nil

			self:SetFrameLevel(3)

			if (self.config.hidden) then
				self:SetBackdropColor(1,0,0,0.6)
			else
				self:SetBackdropColor(0,0,1,0.4)
			end

			updateCycleOrder(self)
		end

		if (not self) then
			M.CurrentBar = nil
		elseif (self.text) then
			self.text:Show()
		end

		for k,v in pairs(M.BarIndex) do
			if (v ~= self) then

				if (v.config.hidden) then
					v:SetBackdropColor(1,0,0,0.4)
				else
					v:SetBackdropColor(0,0,0,0.2)
				end

				v:SetFrameLevel(2)
				v:SetBackdropBorderColor(0.3,0.3,0.3,0.3)
				v.selected = false
				v.microAdjust = false
				v:EnableKeyboard(false)
				v.text:Hide()
				v.message:Hide()
				v.messagebg:Hide()
				v.mousewheelfunc = nil
				v.action = nil
			end
		end

		if (M.CurrentBar) then
			M.Bar_OnEnter(M.CurrentBar)
		end

		if (MacaroonBarEditor:IsVisible()) then
			M.BarEditorUpdateData(MacaroonBarEditor)
		end
	end

	return newBar
end

function M.Bar_OnLoad(self)

	self:RegisterForClicks("AnyDown", "AnyUp")
	self:RegisterForDrag("LeftButton")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	--self:SetBackdropColor(0,0,0,0.2)
	--self:SetBackdropBorderColor(0.3,0.3,0.3,0.3)
	self:SetBackdropColor(0,0,0,0)
	self:SetBackdropBorderColor(0.3,0.3,0.3,0)
	self:EnableKeyboard(false)
	self:SetFrameLevel(2)

	self.elapsed = 0
	self.click = nil
	self.dragged = false
	self.selected = false
	self.toggleframe = self
	self.microAdjust = false
	self.text:Hide()
	self.message:Hide()
	self.messagebg:Hide()
end

function M.Bar_OnEvent(self, event)

end

function M.Bar_OnClick(self, click, down)

	if (not down) then
		self.newBar = M.ChangeBar(self)
	end

	self.click = click
	self.dragged = false
	self.elapsed = 0
	self.pushed = 0

	if (IsShiftKeyDown() and not down) then

		if (self.microAdjust) then
			self.microAdjust = false
			self:EnableKeyboard(false)
			self.message:Hide()
			self.messagebg:Hide()
		else
			self.config.snapTo = false
			self.config.snapToPoint = false
			self.config.snapToFrame = false
			self.microAdjust = 1
			self:EnableKeyboard(true)
			self.message:Show()
			self.message:SetText(self.config.point:lower().."     x: "..format("%0.2f", self.config.x).."     y: "..format("%0.2f", self.config.y))
			self.messagebg:Show()
			self.messagebg:SetWidth(self.message:GetWidth()*1.05)
			self.messagebg:SetHeight(self.message:GetHeight()*1.1)
		end

	elseif (click == "MiddleButton") then

		if (GetMouseFocus() ~= M.CurrentBar) then
			self.newBar = M.ChangeBar(self)
		end

		if (down) then
			M.HideBar(nil, true)
		end

	elseif (click == "RightButton" and not self.action and not down) then

		self.mousewheelfunc = nil

		if (not self.newBar and MacaroonBarEditor:IsVisible()) then
			M.BarEditorHide()
		else
			M.BarEditorShow()
		end

	elseif (not down) then

		if (not self.newBar) then
			updateState(self, 1)
		end

		M.BarEditorUpdateData(MacaroonBarEditor)
	end

	M.OptionsGeneral_ModifyReset()
end

function M.Bar_OnDoubleClick(self, button, down)

end

function M.Bar_OnDragStart(self)

	M.ChangeBar(self)

	self:SetFrameStrata(self.config.barStrata)
	self:EnableKeyboard(false)

	self.adjusting = true
	self.selected = true
	self.isMoving = true

	self.config.snapToPoint = false
	self.config.snapToFrame = false

	self:StartMoving()
end

function M.Bar_OnDragStop(self)

      local point

	self:StopMovingOrSizing()

	for k,v in pairs(M.BarIndex) do

		if (not point and self.config.snapTo and v.config.snapTo and self ~= v) then

			point = M.SnapTo.Stick(self, v, SD.snapToTol, self.config.snapToPad, self.config.snapToPad)

			if (point) then
				self.config.snapToPoint = point
				self.config.snapToFrame = v:GetName()
				self.config.point = "SnapTo: "..point
				self.config.x = 0
				self.config.y = 0
			end
		end
	end

	if (not point) then
		self.config.snapToPoint = false
		self.config.snapToFrame = false
		self.config.point, self.config.x, self.config.y = M.GetPosition(self)
		M.SetPosition(self)
	end

	if (self.config.snapTo and not self.config.snapToPoint) then
		M.SnapTo.StickToEdge(self)
	end

	self.isMoving = false
	self.dragged = true
	self.elapsed = 0

	self.updateBar(self, nil, nil, nil, true)

end

function M.Bar_OnKeyDown(self, key, onupdate)

	if (self.microAdjust) then

		self.keydown = key

		if (not onupdate) then
			self.elapsed = 0
		end

		self.config.point, self.config.x, self.config.y = M.GetPosition(self)

		self:SetUserPlaced(false)

		self:ClearAllPoints()

		if (key == "UP") then
			self.config.y = self.config.y + .1 * self.microAdjust
		elseif (key == "DOWN") then
			self.config.y = self.config.y - .1 * self.microAdjust
		elseif (key == "LEFT") then
			self.config.x = self.config.x - .1 * self.microAdjust
		elseif (key == "RIGHT") then
			self.config.x = self.config.x + .1 * self.microAdjust
		elseif (not key:find("SHIFT")) then
			self.microAdjust = false
			self:EnableKeyboard(false)
		end

		M.SetPosition(self)
	end
end

function M.Bar_OnKeyUp(self, key)

	if (self.microAdjust and not key:find("SHIFT")) then

		self.microAdjust = 1
		self.keydown = nil
		self.elapsed = 0

		if (self.func1) then
			self.func1(self)
		end
	end
end

function M.Bar_OnEnter(self, hilightOnly)

	if (MacaroonBarEditorCreate.type == "cancel") then
		MacaroonBarEditorCreate:Click()
	end

	if (SD.checkButtons[108]) then
		M.BarEditorUpdateData(MacaroonBarEditor, self)
	end

	if (self.config and not self.selected) then
		if (self.config.hidden) then
			self:SetBackdropColor(1,0,0,0.6)
		else
			self:SetBackdropColor(0,0,1,0.4)
		end
		self.text:Show()
	end

	if (hilightOnly) then return end

	if (SD.checkButtons[104]) then

		if ( GetCVar("UberTooltips") == "1" ) then
			GameTooltip_SetDefaultAnchor(GameTooltip, self)
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		end

		local current = ""

		if (self == M.CurrentBar) then
			current = M.Strings.BARTOOLTIP_3
		end

		GameTooltip:AddDoubleLine(self.config.name, current, 1.0, 1.0, 1.0)

		if (self == M.CurrentBar) then
			GameTooltip:AddLine(M.Strings.BARTOOLTIP_4)
		else
			GameTooltip:AddLine(M.Strings.BARTOOLTIP_5)
		end

		GameTooltip:AddLine(M.Strings.BARTOOLTIP_6)
		GameTooltip:AddLine(M.Strings.BARTOOLTIP_7)
		GameTooltip:AddLine(M.Strings.BARTOOLTIP_8)

		GameTooltip:Show()
	end

	self.hover = true

end

function M.Bar_OnLeave(self, hilightOnly)

	if (SD.checkButtons[108]) then
		M.BarEditorUpdateData(MacaroonBarEditor)
	end

	if (self.config and not self.selected) then
		if (self.config.hidden) then
			self:SetBackdropColor(1,0,0,0.4)
		else
			self:SetBackdropColor(0,0,0,0.2)
		end

		self.text:Hide()
	end

	if (hilightOnly) then return end

	GameTooltip:Hide()

	self.hover = nil
end

local function pulseBar(self, elapsed)

	alphaTimer = alphaTimer + elapsed * 2

	if (alphaDir == 1) then
		if (1-alphaTimer <= 0) then
			alphaDir = 0; alphaTimer = 0
		end
	else
		if (alphaTimer >= 1) then
			alphaDir = 1; alphaTimer = 0
		end
	end

	if (alphaDir == 1) then
		if ((1-(alphaTimer)) >= 0) then
			self:SetAlpha(1-(alphaTimer))
		end
	else
		if ((alphaTimer) <= 1) then
			self:SetAlpha((alphaTimer))
		end
	end

	self.pulse = true
end


function M.Bar_OnUpdate(self, elapsed)

	if (self.elapsed) then

		self.elapsed = self.elapsed + elapsed

		if (self.elapsed > 10) then
			self.elapsed = 0.75
		end

		if (self.microAdjust and not self.action) then

			pulseBar(self, elapsed)

			if (self.keydown and self.elapsed >= 0.5) then
				self.microAdjust = self.microAdjust + 1
				M.Bar_OnKeyDown(self, self.keydown, self.microAdjust)
			end

		elseif (self.pulse) then
			self:SetAlpha(1)
			self.pulse = nil
		end

		if (self.hover) then
			self.elapsed = 0
		end
	end

	if (GetMouseFocus() == self) then
		self:EnableMouseWheel(true)
	else
		self:EnableMouseWheel(false)
	end
end

function M.Bar_OnShow(self)

	if (editMode and self.handler) then
		self.config_current = self.handler:GetAttribute("state-current")
		self.config_last = self.handler:GetAttribute("state-last")
	end

	if (self.handler) then
		self.handler:SetAttribute("editmode", true)
		self.text:SetParent(self.handler)
		self.message:SetParent(self.handler)
		self.messagebg:SetParent(self.handler)
	end

	if (self.config and self.config.hidden) then
		if (not self.selected) then
			--self:SetBackdropColor(1,0,0,0.5)
		else
			--self:SetBackdropColor(1,0,0,0.6)
		end
	else
		if (not self.selected) then
			--self:SetBackdropColor(0,0,0,0.2)
		else
			--self:SetBackdropColor(0,0,1,0.4)
		end
	end

	if (not self.showgrid) then

		if (self.updateBar) then
			self.updateBar(self, nil, nil, true)
		end

		if (self.updateBarTarget) then
			self.updateBarTarget(self)
		end

		--if (self.updateFunc) then
		--	self.updateFunc(self, self.handler:GetAttribute("state-current"))
		--end
	end
end

function M.Bar_OnHide(self)

	if (editMode and self.handler) then
		self:SetFrameLevel(2)
		self.handler:SetAttribute("state-current", self.config_current)
		self.handler:SetAttribute("state-last", self.config_last)
	end

	if (not self.showgrid) then

		if (self.updateBarTarget) then
			self.updateBarTarget(self)
		end

		if (self.updateBarLink) then
			self.updateBarLink(self)
		end

		if (self.updateBarHidden) then
			self.updateBarHidden(self, nil, true)
		end

		--if (self.updateFunc) then
		--	self.updateFunc(self, self.handler:GetAttribute("state-current"))
		--end

		if (self.updateBar) then
			self.updateBar(self, nil, true, true)
		end

		self.text:SetParent(self)
		self.message:SetParent(self)
		self.messagebg:SetParent(self)

		self.click = nil
	end
end

local barStack = {}
local stackWatch = CreateFrame("Frame", nil, UIParent)
stackWatch:SetScript("OnUpdate", function(self) self.bar = GetMouseFocus():GetName() if (not M.BarIndex[self.bar]) then M.ClearTable(barStack); self:Hide() end end)
stackWatch:Hide()

function M.Bar_OnMouseWheel(self, delta)

	stackWatch:Show()

	MacaroonTooltipScan:SetFrameStack()

	local objects = M.GetChildrenAndRegions(MacaroonTooltipScan)
	local _, bar, level, text, added

	for k,v in pairs(objects) do

		if (_G[v]:IsObjectType("FontString")) then

			text = _G[v]:GetText()

			if (text and text:find("%p%d+%p")) then

				_, level, text = (" "):split(text)

				if (text and M.BarIndex[text]) then

					level = tonumber(level:match("%d+"))

					if (level and level < 3) then

						added = nil
						bar = M.BarIndex[text]

						for k,v in pairs(barStack) do
							if (bar == v) then
								added = true
							end
						end

						if (not added) then
							tinsert(barStack, bar)
						end
					end
				end
			end
		end
	end

	bar = tremove(barStack, 1)

	if (bar) then
		M.ChangeBar(bar)
	end
end

local miscOptions = {
	[M.Strings.MISC_OPTION_1] = "barLock",
	[M.Strings.MISC_OPTION_2] = "barLockAlt",
	[M.Strings.MISC_OPTION_3] = "barLockCtrl",
	[M.Strings.MISC_OPTION_4] = "barLockShift",
	[M.Strings.MISC_OPTION_5] = "tooltips",
	[M.Strings.MISC_OPTION_6] = "tooltipsEnhanced",
	[M.Strings.MISC_OPTION_7] = "tooltipsCombat",
	[M.Strings.MISC_OPTION_8] = "spellGlow",
	--[M.Strings.MISC_OPTION_8] = "copyDrag",
}

function M.MiscOptions_OnClick(self, checked, option)

	local bar = M.CurrentBar

	if (checked) then
		bar.config[option] = true
	else
		bar.config[option] = false
	end

	M.BarEditorUpdateData(MacaroonBarEditor)
end

function M.CheckOptions_OnClick(self, action, state)

	local bar, checked, index, frame = M.CurrentBar, self:GetChecked(), 1

	if (bar and action) then

		bar.action = action

		for k,v in pairs(barStates) do

			if (v[2] == action) then

				if (v[1] == "custom") then

					if (checked) then

						bar.config.custom = ""
						bar.config.customRange = ""
						bar.config.customNames = {}

						for kk,vv in pairs(barStates) do
							if (vv[1] ~= "custom") then
								bar.config[vv[1]] = false
							end
						end

					else
						bar.config.custom = false
						bar.config.customRange = false
						bar.config.customNames = false
					end
				else
					if (checked) then
						bar.config[v[1]] = true
						bar.config.custom = false
						bar.config.customRange = false
						bar.config.customNames = false
					else
						bar.config[v[1]] = false
					end
				end

				state = v[1]
			end
		end

		if (state) then

			if (state == "preset") then

				if (checked) then
					bar.config.custom = false
					bar.config.customRange = false
					bar.config.customNames = false
				end

				M.SetBarStates("custom", true, true)

			elseif (state == "prowl") then

				if (not bar.stance or not bar.stance.registered) then
					self:SetChecked(nil)
					bar.config.prowl = false
				else
					bar.stance.registered = false
				end

				M.SetBarStates("stance", true, true)

			else

				M.SetBarStates(state, true, true)
			end
		end

		updateCycleOrder(bar)

		M.BarEditorUpdateData(MacaroonBarEditor)
	end
end

function M.AdjOptions_OnClick(self, click, down, action, parent)

	local bar = M.CurrentBar

	if (bar) then

		self.click = click
		self.pushed = 0

		for k,v in pairs(parent.buttons) do
			if (v ~= self) then
				M.AdjustOptionButton_OnShow(v)
			end
		end

		if (action) then
			bar.action = action
		end
	end
end

function M.AdjOptions_Reset(self)

	local bar = M.CurrentBar

	if (bar and bar.action) then

		bar.action = nil

		if (bar.selected) then
			self:SetBackdropColor(0,0,1,0.4)
		else
			self:SetBackdropColor(0,0,0,0.2)
		end
	end
end

local function adjoptButton_OnUpdate(self, elapsed, bar, dir)

	if (bar and self.action and self:GetButtonState() == "PUSHED") then

		self.pushed = self.pushed + elapsed

		if (self.pushed > 0.45) then

			if (dir) then
				updateValues(bar, 1, self.action)
			else
				updateValues(bar, -1, self.action)
			end

			M.BarEditorUpdateData(self.editor)
		end
	else
		self.pushed = 0
	end
end

local function nameEdit_OnTextChanged(self)

	if (MacaroonBarEditor.elapsed < 0.1) then
		return
	end

	local bar = MacaroonBarEditor.CurrentBar

	if (not bar) then
		bar = M.CurrentBar
	end

	if (bar) then
		local changed = M.NameBar(self:GetText(), bar)

		if (not changed) then
			self:SetTextColor(1,0,0)
		else
			self:SetTextColor(1,1,1)
		end
	end
end

local function nameEdit_OnEditFocusLost(self)

	local bar = MacaroonBarEditor.CurrentBar

	if (not bar) then
		bar = M.CurrentBar
	end

	if (bar) then
		self:SetText(bar.config.name)
		self:SetTextColor(1,1,1)
	end

	self:HighlightText(0, 0)

end

local function target_OnShow(self)

	local bar = MacaroonBarEditor.CurrentBar

	if (not bar) then
		bar = M.CurrentBar
	end

	if (bar) then

		local data = {}

		for k,v in pairs(targetNames) do
			data[v] = k
		end

		M.EditBox_PopUpInitialize(self.popup, data)
	end
end

local function target_OnTextChanged(self)

	if (MacaroonBarEditor.elapsed < 0.1) then
		return
	end

	local bar = MacaroonBarEditor.CurrentBar

	if (not bar) then
		bar = M.CurrentBar
	end

	if (bar) then

		if (self:GetText() == "-none-") then
			bar.config.target = false
		else
			bar.config.target = self:GetText()
		end

		if (bar.reaction) then
			bar.reaction.registered = false
		end
		bar.stateschanged = true
		bar.updateBar(bar, true)

		M.UpdateAutoMacros()
	end
end

local function linkedBar_OnShow(self)

	local bar = MacaroonBarEditor.CurrentBar

	if (not bar) then
		bar = M.CurrentBar
	end

	if (bar) then

		local data = { ["-none-"] = "none" }

		for k,v in pairs(M.BarIndexByName) do
			if (v ~= bar) then
				data[k] = v
			end
		end

		M.EditBox_PopUpInitialize(self.popup, data)
	end
end

local function linkedBar_OnTextChanged(self)

	if (MacaroonBarEditor.elapsed < 0.1) then
		return
	end

	local bar, stateString = M.BarIndexByName[self:GetText()]

	if (bar) then

		local data = { ["-none-"] = "none" }

		for k,v in pairs(barStates) do

			if (bar.config[v[1]]) then

				for state, states in pairs(M.Strings.STATES) do

					stateString = match(state, "^%a+")

					if (stateString == v[1]) then
						data[states] = v[1]
					end
				end
			end

			if (ManagedStates[v[1]] and not ManagedStates[v[1]].homestate) then
				data[M.Strings.STATES.homestate] = v[1]
			end
		end

		M.EditBox_PopUpInitialize(self.statePopup.popup, data)
	end

	local text = self:GetText()

	bar = M.CurrentBar

	if (bar) then

		if (text == "-none-") then
			bar.config.barLink = false
			bar.config.showstates = false
			self.statePopup:SetText("-none-")
			M.EditBox_PopUpInitialize(self.statePopup.popup, nil)
		else
			bar.config.barLink = text
		end

		bar.updateBar(bar, true)
	end
end

local function linkedState_OnShow(self)

	local bar = MacaroonBarEditor.CurrentBar

	if (not bar) then
		bar = M.CurrentBar
	end

	if (bar) then
		if (bar.config.showstates) then
			self:SetText(bar.config.showstates)
		else
			self:SetText("-none-")
		end
	end
end

local function linkedState_OnTextChanged(self)

	if (MacaroonBarEditor.elapsed < 0.1) then
		return
	end

	local bar = MacaroonBarEditor.CurrentBar

	if (not bar) then
		bar = M.CurrentBar
	end

	local text = self:GetText()

	if (bar) then

		if (text == "-none-") then
			bar.config.showstates = false
		else
			bar.config.showstates = text
		end

		bar.updateBar(bar, true, nil, nil)
	end

	self:SetCursorPosition(0)
end

local function barMap_OnShow(self)

	self.value = nil

	local bar = MacaroonBarEditor.CurrentBar

	if (not bar) then
		bar = M.CurrentBar
	end

	if (bar) then

		local data = {}

		for k,v in pairs(M.Strings.STATES) do

			if (bar.config.pagedbar and find(k, "pagedbar")) then

				data[v] = match(k, "%d+")

			elseif (bar.config.stance and find(k, "stance")) then

				data[v] = match(k, "%d+")

			end
		end

		M.EditBox_PopUpInitialize(self.popup, data)
	end

	self:SetText("")
end

local function barMap_OnTextChanged(self)

	if (MacaroonBarEditor.elapsed < 0.1) then
		return
	end

	local bar = MacaroonBarEditor.CurrentBar

	if (not bar) then
		bar = M.CurrentBar
	end

	if (bar and self.value and bar.config.remap) then

		local map, remap

		for states in gmatch(bar.config.remap, "[^;]+") do

			map, remap = (":"):split(states)

			if (map == self.value) then

				MacaroonBarEditor.remapto.value = remap

				if (bar.config.pagedbar) then
					MacaroonBarEditor.remapto:SetText(M.Strings.STATES["pagedbar"..remap])
				elseif (bar.config.stance) then
					MacaroonBarEditor.remapto:SetText(M.Strings.STATES["stance"..remap])
				end
			end
		end
	else
		MacaroonBarEditor.remapto:SetText("")
	end

end

local function remapTo_OnShow(self)

	self.value = nil

	local bar = MacaroonBarEditor.CurrentBar

	if (not bar) then
		bar = M.CurrentBar
	end

	if (bar) then

		local data = {}

		for k,v in pairs(M.Strings.STATES) do

			if (bar.config.pagedbar and find(k, "pagedbar")) then

				data[v] = match(k, "%d+")

			elseif (bar.config.stance and find(k, "stance")) then

				data[v] = match(k, "%d+")

			end
		end

		M.EditBox_PopUpInitialize(self.popup, data)
	end
end

local function remapTo_OnTextChanged(self)

	if (MacaroonBarEditor.elapsed < 0.1) then
		return
	end

	local bar = MacaroonBarEditor.CurrentBar

	if (not bar) then
		bar = M.CurrentBar
	end

	if (bar and bar.config.remap and self.value) then

		local value = MacaroonBarEditor.barmap.value

		bar.config.remap = gsub(bar.config.remap, value..":%d+", value..":"..self.value)

		if (bar.config.pagedbar) then
			bar.pagedbar.registered = false
		elseif (bar.config.stance) then
			bar.stance.registered = false
		end

		bar.stateschanged = true

		bar.updateBar(bar, true)
	end

end

local function customStates_Update(self)

	local bar = MacaroonBarEditor.CurrentBar

	if (not bar) then
		bar = M.CurrentBar
	end

	if (bar and bar.config.custom and self:GetText()) then

		local states = "custom "..self:GetText()

		states = states:gsub("\n", ";"); states = states:gsub("[;]+", ";")

		if (bar.custom) then
			bar.custom.registered = false
		end

		M.SetBarStates(states, true, true)

		updateCycleOrder(bar)
	end

	self:ClearFocus()

	self:GetParent().focus:Show()
end

function M.BarEditor_OnEvent(self)

	local index, lastIndex, count, yOffset, iOffset, frame, lastFrame, anchorF1, anchorF2, prowlSet = 1, 14, 0, 0

	self.buttons = {}
	self.optionBtns = {}
	self.miscopts = {}

	self:SetWidth(SD.EditorWidth)
	self:SetHeight(SD.EditorHeight)

	frame = CreateFrame("EditBox", "$parentNameEdit", self.baropt, "MacaroonEditBoxTemplate2")
	frame:SetWidth(200)
	frame:SetHeight(25)
	frame:SetTextInsets(7,3,0,0)
	frame:SetJustifyH("CENTER")
	frame.text:SetText(M.Strings.TEXTEDIT_NAME)
	frame:SetPoint("TOPLEFT", self.barlist, "TOPRIGHT", 5, -15)
	frame:SetScript("OnTextChanged", nameEdit_OnTextChanged)
	frame:SetScript("OnEditFocusLost", nameEdit_OnEditFocusLost)
	self.name = frame

	frame = CreateFrame("EditBox", "$parentTarget", self.baropt, "MacaroonEditBoxTemplate1")
	frame:SetWidth(115)
	frame:SetHeight(25)
	frame:SetTextInsets(7,3,0,0)
	frame.text:SetText(M.Strings.TEXTEDIT_TARGET)
	frame:SetPoint("LEFT", "$parentNameEdit", "RIGHT", 5, 0)
	frame:SetScript("OnTextChanged", target_OnTextChanged)
	frame:SetScript("OnShow", target_OnShow)
	self.target = frame

	frame = CreateFrame("EditBox", "$parentLinkedBar", self.baropt, "MacaroonEditBoxTemplate1")
	frame:SetWidth(115)
	frame:SetHeight(25)
	frame:SetTextInsets(7,3,0,0)
	frame.text:SetText(M.Strings.TEXTEDIT_LTO)
	frame:SetPoint("LEFT", "$parentTarget", "RIGHT", 22, 0)
	frame:SetScript("OnTextChanged", linkedBar_OnTextChanged)
	frame:SetScript("OnShow", linkedBar_OnShow)
	frame:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
	self.linkbar = frame

	frame = CreateFrame("EditBox", "$parentLinkedState", self.baropt, "MacaroonEditBoxTemplate1")
	frame:SetWidth(115)
	frame:SetHeight(25)
	frame:SetTextInsets(7,3,0,0)
	frame.text:SetText(M.Strings.TEXTEDIT_LSTATE)
	frame:SetPoint("LEFT", "$parentLinkedBar", "RIGHT", 22, 0)
	frame:SetScript("OnTextChanged", linkedState_OnTextChanged)
	frame:SetScript("OnShow", linkedState_OnShow)
	frame:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
	self.linkstate = frame
	self.linkbar.statePopup = frame

	while (M.Strings["MISC_OPTION_"..index]) do

		frame = CreateFrame("CheckButton", "$parentMiscOption"..index, self.baropt, "MacaroonOptionCBTemplate")
		frame:SetID(index)
		frame:SetScript("OnClick", function(self, button) M.MiscOptions_OnClick(self, self:GetChecked(), miscOptions[self.option])  end)
		frame.text = _G[frame:GetName().."Text"]
		frame.text:SetText(M.Strings["MISC_OPTION_"..index])
		frame.option = frame.text:GetText()

		tinsert(self.miscopts, frame)

		if (index == 1) then
			frame:SetPoint("TOPLEFT", self.baropt.miscopt, "TOPLEFT", 15, -13)
			anchorF1 = frame
		elseif (index < 5) then
			frame:SetPoint("LEFT", lastFrame.text, "RIGHT", 23, 0)
		elseif (index == 5 or index == 8) then
			frame:SetPoint("TOPLEFT", anchorF1, "BOTTOMLEFT", 0, -8)
			anchorF1 = frame
		else
			frame:SetPoint("LEFT", lastFrame.text, "RIGHT", 12, 0)
		end

		lastFrame = frame

		index = index + 1

	end

	index, lastFrame = 1, nil

	local toggles = {
		["BAR_EDIT_ADJUSTBTN_6"] = true,
		["BAR_EDIT_ADJUSTBTN_7"] = true,
		["BAR_EDIT_ADJUSTBTN_8"] = true,
		["BAR_EDIT_ADJUSTBTN_10"] = true,
		["BAR_EDIT_ADJUSTBTN_11"] = true,
	}

	while (M.Strings["BAR_EDIT_ADJUSTBTN_"..index]) do

		local function setScripts(frame, text, i)

			if (toggles[text..i]) then
				frame.toggle_func = function(self, button, down) self.pushed = 0 updateValues(M.CurrentBar, true, self.action) M.BarEditorUpdateData(self.parent) end
			else
				frame.onclick_func = function(self, button, down) M.AdjOptions_OnClick(self, click, down, self.action, self.parent) end
			end
			frame.onshow_func = function(self) M.AdjOptions_Reset(self) end
			frame.onenter_func = function(self) if (SD.checkButtons[104]) then self.tooltip = M.Strings.ADJUSTBTN_BEGIN_TOOLTIP else self.tooltip = nil end end
			frame.text:SetText(M.Strings[text..i])
			frame.action = frame.text:GetText()
			frame.parent = self

			frame.add.onclick_func = function(self, button, down, parent) self.pushed = 0 updateValues(M.CurrentBar, 1, self.action) M.BarEditorUpdateData(self.editor) end
			frame.add.onupdate_func = function(self, elapsed) adjoptButton_OnUpdate(self, elapsed, M.CurrentBar, true) end
			frame.add.action = frame.text:GetText()
			frame.add.editor = self

			frame.sub.onclick_func = function(self, button, down, parent) self.pushed = 0 updateValues(M.CurrentBar, -1, self.action) M.BarEditorUpdateData(self.editor)end
			frame.sub.onupdate_func = function(self, elapsed) adjoptButton_OnUpdate(self, elapsed, M.CurrentBar, nil) end
			frame.sub.action = frame.text:GetText()
			frame.sub.editor = self

			tinsert(self.buttons, frame)
		end

		if (index == 12) then

			count = 1

			while (M.Strings["BAR_EDIT_ARC_ADJUSTBTN_"..count]) do

				frame = CreateFrame("CheckButton", "$parentAdjOptButton"..count, self.baropt, "MacaroonAdjustOptionButtonTemplate")
				frame:SetID(count)
				frame:SetWidth(180)
				frame:SetHeight(0.1)
				frame.adjBtn = true
				frame.arcBtn = true

				setScripts(frame, "BAR_EDIT_ARC_ADJUSTBTN_", count)

				frame:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, -(frame:GetHeight()))
				frame:SetPoint("TOPRIGHT", lastFrame, "TOPRIGHT", 0, -(frame:GetHeight()))

				frame:Hide()

				lastFrame = frame

				count = count + 1
			end
		end

		frame = CreateFrame("CheckButton", "$parentAdjOptButton"..index, self.baropt, "MacaroonAdjustOptionButtonTemplate")
		frame:SetID(index)
		frame:SetWidth(180)
		frame:SetHeight(25)
		frame.adjBtn = true
		frame.toggle_check = true
		if (index == 11) then
			frame.dualBtn = true
		end

		setScripts(frame, "BAR_EDIT_ADJUSTBTN_", index)

		if (lastFrame) then
			frame:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, -(frame:GetHeight()))
			frame:SetPoint("TOPRIGHT", lastFrame, "TOPRIGHT", 0, -(frame:GetHeight()))
		else
			frame:SetPoint("TOPLEFT", self.baropt.adjopt, "TOPLEFT", 7, -10)
			frame:SetPoint("TOPRIGHT", self.baropt.adjopt, "TOPRIGHT", -7, -10)
			frame.anchor = true
		end

		lastFrame = frame

		index = index + 1
	end

	index, lastFrame = 1, nil

	while (M.Strings["BAR_EDIT_OBJECT_ADJUSTBTN_"..index]) do

		frame = CreateFrame("CheckButton", "$parentObjectAdjButton"..index, self.baropt, "MacaroonAdjustOptionButtonTemplate")
		frame:SetID(index)
		frame:SetWidth(180)
		frame:SetHeight(25)

		frame.onclick_func = function(self, button, down) M.AdjOptions_OnClick(self, click, down, self.action, self.parent) end
		frame.onshow_func = function(self) M.AdjOptions_Reset(self) end
		frame.onenter_func = function(self) if (SD.checkButtons[104]) then self.tooltip = M.Strings.ADJUSTBTN_BEGIN_TOOLTIP else self.tooltip = nil end end
		frame.text:SetText(M.Strings["BAR_EDIT_OBJECT_ADJUSTBTN_"..index])
		frame.action = frame.text:GetText()
		frame.parent = self

		frame.add.onclick_func = function(self, button, down, parent) self.pushed = 0 updateValues(M.CurrentBar, 1, self.action) M.BarEditorUpdateData(self.editor) end
		frame.add.onupdate_func = function(self, elapsed) adjoptButton_OnUpdate(self, elapsed, M.CurrentBar, true) end
		frame.add.action = frame.text:GetText()
		frame.add.editor = self

		frame.sub.onclick_func = function(self, button, down, parent) self.pushed = 0 updateValues(M.CurrentBar, -1, self.action) M.BarEditorUpdateData(self.editor)end
		frame.sub.onupdate_func = function(self, elapsed) adjoptButton_OnUpdate(self, elapsed, M.CurrentBar, nil) end
		frame.sub.action = frame.text:GetText()
		frame.sub.editor = self

		tinsert(self.buttons, frame)

		if (index == 1) then
			frame:SetPoint("TOPLEFT", self.baropt.statedata, "TOPLEFT", 7, -7)
			frame:SetPoint("TOPRIGHT", self.baropt.statedata, "TOPRIGHT", -7, -7)
			anchorF1 = frame
		elseif (index == 2) then
			frame:SetPoint("TOPLEFT", lastFrame, "BOTTOM", 47, 0)
			frame:SetPoint("TOPRIGHT", lastFrame, "BOTTOMRIGHT", -5, -25)
			anchorF2 = frame
		elseif (index == 3) then
			frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
			frame:SetPoint("TOPRIGHT", lastFrame, "BOTTOMRIGHT", 0, 0)
		elseif (index == 4) then
			frame:SetPoint("TOPLEFT", anchorF1, "BOTTOMLEFT", 0, 0)
			frame:SetPoint("TOPRIGHT", anchorF1, "BOTTOM", -65, 0)
			self.hpad = frame
		elseif (index == 5) then
			frame:SetPoint("LEFT", self.hpad, "RIGHT", -3, 0)
			frame:SetPoint("RIGHT", anchorF2, "LEFT", 0, 0)
			self.vpad = frame
		elseif (index == 6) then
			frame:SetPoint("TOPLEFT", self.hpad, "BOTTOMLEFT", 0, 0)
			frame:SetPoint("TOPRIGHT", self.vpad, "BOTTOMRIGHT", 5, 0)
			frame.text:SetPoint("RIGHT", -24, 0)
			frame.text:SetJustifyH("CENTER")
		elseif (index == 7) then
			frame:SetParent(self.objopt)
			frame:SetWidth(215)
			frame:SetHeight(15)
			frame:SetPoint("TOPRIGHT", -40, -8)
		end

		lastFrame = frame

		index = index + 1
	end

	frame = CreateFrame("EditBox", "$parentBarMap", self.baropt, "MacaroonEditBoxTemplate1")
	frame:SetWidth(165)
	frame:SetHeight(25)
	frame:SetTextInsets(7,3,0,0)
	frame.text:SetText(M.Strings.TEXTEDIT_BSTATE)
	frame:SetPoint("BOTTOMLEFT", self.baropt.statedata, "TOPLEFT", 0, 5)
	frame:SetPoint("BOTTOMRIGHT", self.baropt.statedata, "TOP", -20, 5)
	frame:SetScript("OnTextChanged", barMap_OnTextChanged)
	frame:SetScript("OnShow", barMap_OnShow)
	frame:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
	self.barmap = frame

	frame = CreateFrame("EditBox", "$parentRemapTo", self.baropt, "MacaroonEditBoxTemplate1")
	frame:SetWidth(160)
	frame:SetHeight(25)
	frame:SetTextInsets(7,3,0,0)
	frame.text:SetText(M.Strings.TEXTEDIT_REMAP)
	frame:SetPoint("BOTTOMLEFT", self.baropt.statedata, "TOP", 5, 5)
	frame:SetPoint("BOTTOMRIGHT", self.baropt.statedata, "TOPRIGHT", -20, 5)
	frame:SetScript("OnTextChanged", remapTo_OnTextChanged)
	frame:SetScript("OnShow", remapTo_OnShow)
	frame:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
	self.remapto = frame

	frame = CreateFrame("CheckButton", "$parentRadioPresetStates", self.baropt, "MacaroonOptionRadioButtonTemplate")
	frame:SetID(0)
	frame:SetPoint("BOTTOMLEFT", self.baropt.editor, "TOPLEFT", 5, 2)
	frame.onclick_func = function(self, button) M.CheckOptions_OnClick(self, self.action, "preset")  end
	frame.text = _G[frame:GetName().."Text"]
	frame.text:SetText(M.Strings.BARSTATE_PRESET)
	frame.action = frame.text:GetText()
	tinsert(self.optionBtns, frame)

	index = 1

	if (UnitClass("player") == M.Strings.DRUID) then

		local origString, nextString = "prowl"

		while (M.Strings["BARSTATE_"..index]) do

			if (not barStates[index]) then
				barStates[index] = { "" }
			end

			lastIndex = index

			index = index + 1
		end

		index = 4

		while (M.Strings["BARSTATE_"..index]) do

			nextString = barStates[index][1]

			barStates[index][1] = origString

			origString = nextString

			index = index + 1
		end

		prowlSet = true
	end

	index = 1

	while (M.Strings["BARSTATE_"..index]) do
		barStates[index][2] = M.Strings["BARSTATE_"..index]
		index = index + 1

	end

	index, count = 1, 0

	while (M.Strings["BARSTATE_"..index]) do

		if (index < lastIndex and M.Strings["BARSTATE_"..index] ~= "exclude") then

			if (index < 4) then
				frame = CreateFrame("CheckButton", "$parentRadioCheck"..index, self.baropt.editor.presets, "MacaroonOptionRadioButtonTemplate")
			else
				frame = CreateFrame("CheckButton", "$parentRadioCheck"..index, self.baropt.editor.presets, "MacaroonOptionCBTemplate")
			end
			frame:SetID(index)
			frame:SetScript("OnClick", function(self, button) M.CheckOptions_OnClick(self, self.action)  end)
			frame.text = _G[frame:GetName().."Text"]
			frame.text:SetText(M.Strings["BARSTATE_"..index])
			frame.action = frame.text:GetText()

			tinsert(self.optionBtns, frame)

			if (index == 1) then

				frame:SetPoint("TOPLEFT", self.baropt.editor.presets, "TOPLEFT", 15, -13)
				anchorF1 = frame; lastFrame = frame

			elseif (index < 4) then

				frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -9)
				lastFrame = frame

			elseif (index == 4) then

				frame:SetPoint("LEFT", anchorF1, "RIGHT", 90, 5)
				frame.prowl = prowlSet
				anchorF1 = frame; lastFrame = frame; count = count + 1

			elseif (count == 4) then

				frame:SetPoint("LEFT", anchorF1, "RIGHT", 65, 0)
				anchorF1 = frame; lastFrame = frame;

				if (prowlSet) then
					count = 1
				else
					count = 2
				end

			else
				frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -4.5)
				lastFrame = frame; count = count + 1
			end

		end

		index = index + 1
	end

	frame = CreateFrame("CheckButton", "$parentRadioCheck"..lastIndex, self.baropt, "MacaroonOptionRadioButtonTemplate")
	frame:SetID(lastIndex)
	frame:SetPoint("BOTTOMLEFT", self.baropt.editor, "TOP", 5, 2)
	frame.onclick_func = function(self, button) M.CheckOptions_OnClick(self, self.action)  end
	frame.text = _G[frame:GetName().."Text"]
	frame.text:SetText(M.Strings["BARSTATE_"..lastIndex])
	frame.action = frame.text:GetText()
	tinsert(self.optionBtns, frame)

	frame = CreateFrame("ScrollFrame", "$parentCustomStates", self.baropt.editor.custom, "MacaroonScrollFrameTemplate2")
	frame:SetPoint("TOPLEFT", 10, -10)
	frame:SetPoint("BOTTOMRIGHT", -5, 10)
	frame:SetToplevel(true)
	frame.edit:SetScript("OnEscapePressed", customStates_Update)
	frame.edit:SetScript("OnTabPressed", customStates_Update)
	frame.edit:SetScript("OnEditFocusLost", customStates_Update)
	frame.edit:SetScript("OnHide", customStates_Update)
	self.custom = frame.edit

	self.elapsed = 0

	self:Hide()

end

local function updateText(frame, text)

	if (not frame or not text) then return end

	frame:SetText(text)
	frame:SetCursorPosition(0)
end

function M.BarEditorUpdateData(self, bar)

	if (not self:IsVisible()) then
		return
	end

	if (InterfaceOptionsFrame:IsVisible()) then
		InterfaceOptionsFrameOkay_OnClick()
	end

	local index, frame = 1

	if (not bar) then
		bar = M.CurrentBar
	end

	if (bar) then

		self.CurrentBar = bar

		if (self.name) then
			updateText(self.name, bar.config.name)
		end

		if (self.target) then
			if (bar.config.target) then
				updateText(self.target, bar.config.target)
			else
				updateText(self.target, "-none-")
			end
		end

		if (self.linkbar) then
			if (bar.config.barLink) then
				updateText(self.linkbar, bar.config.barLink)
				updateText(self.linkstate, bar.config.showstates)
			else
				updateText(self.linkbar, "-none-")
				updateText(self.linkstate, "-none-")
			end
		end

		if (self.barmap) then
			barMap_OnShow(self.barmap)
			remapTo_OnShow(self.remapto)
		end

		if (self.miscopts) then

			for i,frame in ipairs(self.miscopts) do

				if (bar.config[miscOptions[frame.option]]) then
					frame:SetChecked(1)
				else
					frame:SetChecked(nil)
				end

				if (miscOptions[frame.option] == "tooltipsEnhanced" or miscOptions[frame.option] == "tooltipsCombat") then
					if (bar.config.tooltips) then
						frame:Enable()
						frame.text:SetTextColor(1, 0.82, 0)
					else
						frame:Disable()
						frame.text:SetTextColor(0.5, 0.5, 0.5)
					end
				end

				if (miscOptions[frame.option] == "barLockAlt" or miscOptions[frame.option] == "barLockCtrl" or miscOptions[frame.option] == "barLockShift") then
					if (bar.config.barLock) then
						frame:Enable()
						frame.text:SetTextColor(1, 0.82, 0)
					else
						frame:Disable()
						frame.text:SetTextColor(0.5, 0.5, 0.5)
					end
				end
			end
		end

		if (self.buttons) then

			local count, value, height, lastFrame = 0

			checkArcOptions(bar)

			for k,v in pairs(self.buttons) do
				if (v.adjBtn and v:IsShown()) then
					count = count + 1
				end
			end

			height = (self.baropt.adjopt:GetHeight()-20)/count

			for k,v in ipairs(self.buttons) do

				value = updateValues(bar, nil, v.action)

				if (value == true) then
					v.textR:SetText("|cff00ff00"..M.Strings.BARTOOLTIP_1.."|r")
				elseif (value == false) then
					v.textR:SetText("|cfff00000"..M.Strings.BARTOOLTIP_2.."|r")
				else
					v.textR:SetText(value)
				end

				if (v.adjBtn and v:IsShown()) then
					if (v.anchor) then
						v:SetHeight(height)
						lastFrame = v
					else
						v:SetHeight(height)
						v:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, -(v:GetHeight()))
						v:SetPoint("TOPRIGHT", lastFrame, "TOPRIGHT", 0, -(v:GetHeight()))
						lastFrame = v
					end
				end
			end
		end

		if (self.optionBtns) then

			for i,frame in ipairs(self.optionBtns) do

				if (i == 1) then

					if (bar.config.custom) then
						frame:SetChecked(nil)
						self.baropt.editor.presets:Hide()
						self.baropt.editor.custom:Show()
					else
						frame:SetChecked(1)
						self.baropt.editor.presets:Show()
						self.baropt.editor.custom:Hide()
					end

				elseif (frame.prowl) then

					if (bar.config.prowl) then
						frame:SetChecked(1)
					else
						frame:SetChecked(nil)
					end

					if (bar.config.stance) then
						frame.text:SetTextColor(1, 0.82, 0)
						frame:Enable()
					else
						frame.text:SetTextColor(0.5,0.5,0.5)
						frame:Disable()
					end

				else

					for k,v in pairs(barStates) do
						if (v[2] == frame.action) then
							if (bar.config[v[1]]) then
								frame:SetChecked(1)
							else
								frame:SetChecked(nil)
							end
						end
					end
				end
			end
		end

		if (bar.config.custom) then

			local string = ""

			for i=1,select('#',(";"):split(bar.config.custom)) do
				local text = gsub(select(i,(";"):split(bar.config.custom)), "%s+%S+$", "")
				text = gsub(text, "^%s+", "")
				string = string..text.."\n"
			end

			updateText(self.custom, string)

		else
			updateText(self.custom, "-none-")
		end

		bar.action = nil
	end

	M.BarListScrollFrameUpdate(); M.ObjectListScrollFrameUpdate()
end

function M.BarEditorShow()

	MacaroonBarEditor:ClearAllPoints()
	MacaroonBarEditor:SetPoint("CENTER", MacaroonPanelMover, "CENTER")
	MacaroonBarEditor:Hide()
	MacaroonBarEditor:SetScale(0.01)
	MacaroonBarEditor.scale = 0.01
	MacaroonBarEditor.grow = true
	MacaroonBarEditor.shrink = false
	MacaroonBarEditor:Show()

end

function M.BarEditorHide()

	MacaroonBarEditor:ClearAllPoints()
	MacaroonBarEditor:SetPoint("CENTER", MacaroonPanelMover, "CENTER")
	MacaroonBarEditor.grow = false
	MacaroonBarEditor.shrink = true

end

function Macaroon.BarEditor_OnHide(self)

	MacaroonBarEditor.objedit.type = "editbars"
	MacaroonBarEditor.objedit:Click()

end

function M.BarEditor_OnUpdate(self, elapsed)

	self.elapsed = self.elapsed + elapsed

	if (self.grow) then

		self.elapsed = 0

		if (SD.checkButtons[103]) then

			if (self.scale < SD.panelScale) then
				self.scale = self.scale + 0.1
				self:SetScale(self.scale)
			else
				self:SetScale(SD.panelScale)
				self.grow = false
			end
		else
			self:SetScale(SD.panelScale)
			self.grow = false
		end

		self.growing = true

	elseif (self.shrink) then

		self.elapsed = 0

		if (SD.checkButtons[103]) then

			if (self.scale > 0.1) then
				self.scale = self.scale - 0.1
				self:SetScale(self.scale)
			else
				self:SetScale(0.01)
				self:Hide()
				self.shrink = false
			end
		else
			self:SetScale(0.01)
			self:Hide()
			self.shrink = false
		end
	end

	if (self.growing and not self.grow) then

		self.growing = nil

		M.BarEditorUpdateData(self)
	end

end

function M.BarEditor_CreateNewBar(self)

	if (self.type == "create") then

		local data, index, high = {}, 1, 0

		for k,v in pairs(M.CreateBarTypes) do
			index = match(v[11], "%D+")
			if (index) then
				data["|cff00ff00"..index.."|r"] = k
			end
		end

		M.BarListScrollFrameUpdate(nil, data, true)

		self.type = "cancel"

		self.text:SetText(M.Strings.CANCEL)
	else

		M.BarListScrollFrameUpdate()

		self.type = "create"

		self.text:SetText(M.Strings.CREATE_BAR)

	end
end

function Macaroon.BarEditor_DeleteBar(self)

	local bar = M.CurrentBar

	if (bar and self.type == "delete") then

		self:Hide()
		self.parent.confirm:Show()
		self.type = "confirm"
	else
		self:Show()
		self.parent.confirm:Hide()
		self.type = "delete"
	end
end

function Macaroon.BarEditor_ConfirmYes(self)

	local bar = M.CurrentBar

	if (bar) then
		M.DeleteBar(bar)
	end

	MacaroonBarEditorBarOptionsDelete:Click()

end

function Macaroon.BarEditor_ConfirmNo(self)

	MacaroonBarEditorBarOptionsDelete:Click()

end

function M.BarEditor_EditObjects(self)

	if (self.type == "editobjs") then

		self.text:SetText(M.Strings.EDIT_BARS)

		MacaroonBarEditorBarOptions:Hide()
		MacaroonBarEditorObjectOptions:Show()

		M.ObjectEditorShow(MacaroonBarEditorObjectOptions, MacaroonBarEditorObjectOptionsList, "TOPLEFT", "TOPRIGHT", -5, 10, SD.panelScale, 0)

		M.ObjectEdit(nil, true)

		M.ObjListFirstBtn:Click()

		M.ObjectEditorUpdateData()

		self.type = "editbars"

	else

		self.text:SetText(M.Strings.EDIT_BUTTONS)

		MacaroonBarEditorBarOptions:Show()
		MacaroonBarEditorObjectOptions:Hide()

		M.ObjectEdit(true)

		M.BarEditorUpdateData(MacaroonBarEditor)

		self.type = "editobjs"

	end
end

function M.AdjustableOptions_OnLoad(self)

	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	self:SetBackdropColor(0,0,0,0.5)
end

function M.BarList_OnLoad(self)

	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	self:SetBackdropColor(0,0,0,0.5)
	self:GetParent().backdrop = self

	self:SetHeight(M.EditorHeight-55)
end

function M.BarListScrollFrame_OnLoad(self)

	self.offset = 0
	self.scrollChild = _G[self:GetName().."ScrollChildFrame"]

	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	self:SetBackdropColor(0,0,0,0.5)

	local button, lastButton, rowButton, count, fontString, script = false, false, false, 0

	for i=1,numShown do

		button = CreateFrame("CheckButton", self:GetName().."Button"..i, self:GetParent(), "MacaroonScrollFrameButtonTemplate")

		button.frame = self:GetParent()
		button.numShown = numShown

		button:SetScript("OnClick",
			function(self)

				local button

				for i=1,numShown do

					button = _G["MacaroonBarEditorBarListScrollFrameButton"..i]

					if (i == self:GetID()) then

						if (self.alt) then

							if (self.bar) then
								M.CreateNewBar(self.bar)
							end

							--MacaroonBarEditorCreate:Click()

							self.alt = nil

						elseif (self.bar) then
							M.ChangeBar(self.bar)
							M.ObjListFirstBtn:Click()
						end
					else
						button:SetChecked(nil)
					end

					M.OptionsGeneral_ModifyReset()
				end

			end)

		button:SetScript("OnEnter",
			function(self)
				if (self.alt) then

				elseif (self.bar) then
					M.Bar_OnEnter(self.bar, true)
				end
			end)

		button:SetScript("OnLeave",
			function(self)
				if (self.alt) then

				elseif (self.bar) then
					M.Bar_OnLeave(self.bar, true)
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

	M.BarListScrollFrameUpdate()

	tinsert(M.UpdateFunctions, M.BarListScrollFrameUpdate)
end

function M.BarListScrollFrameUpdate(frame, tableList, alt)

	if (not MacaroonBarEditorBarList:IsVisible()) then return end

	if (not tableList) then
		tableList = M.BarIndexByName
	end

	if (not frame) then
		frame = MacaroonBarEditorBarListScrollFrame
	end

	local dataOffset, count, data, button, text, datum = FauxScrollFrame_GetOffset(frame), 1, {}

	for k,v in pairs(tableList) do
		data[count] = k; count = count + 1
	end

	table.sort(data)

	frame:Show()

	frame.buttonH = frame:GetHeight()/numShown

	for i=1,numShown do

		button = _G["MacaroonBarEditorBarListScrollFrameButton"..i]
		button:SetChecked(nil)

		count = dataOffset + i

		if (data[count]) then

			text = data[count]

			if (tableList[text] == M.CurrentBar) then
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

function M.ObjectList_OnLoad(self)

	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	self:SetBackdropColor(0,0,0,0.5)
	self:GetParent().backdrop = self

	self:SetHeight(M.EditorHeight-55)
end

function M.ObjectListScrollFrame_OnLoad(self)

	self.offset = 0
	self.scrollChild = _G[self:GetName().."ScrollChildFrame"]

	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	self:SetBackdropColor(0,0,0,0.5)

	local button, lastButton, rowButton, count, fontString, script = false, false, false, 0

	for i=1,numShown do

		button = CreateFrame("CheckButton", "MacaroonObjectListScrollFrameButton"..i, self:GetParent(), "MacaroonScrollFrameButtonTemplate")

		if (i == 1) then
			M.ObjListFirstBtn = button
		end

		button.frame = self:GetParent()
		button.numShown = numShown

		button:SetScript("OnClick",
			function(self)

				local button

				for i=1,numShown do

					button = _G["MacaroonObjectListScrollFrameButton"..i]

					if (i == self:GetID()) then

						if (self.object and self:GetChecked()) then
							M.ChangeObject(self.object)
						else
							M.ChangeObject()
						end
					else
						button:SetChecked(nil)
					end
				end

				M.OptionsGeneral_ModifyReset()
			end)

		button:SetScript("OnEnter",
			function(self)
				if (self.object) then
					M.EditFrame_OnEnter(self.object, true)
				end
			end)

		button:SetScript("OnLeave",
			function(self)
				if (self.object) then
					M.EditFrame_OnLeave(self.object, true)
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

	M.ObjectListScrollFrameUpdate()

	tinsert(M.UpdateFunctions, M.ObjectListScrollFrameUpdate)

end

function M.ObjectListScrollFrameUpdate(frame, tableList)

	if (not MacaroonBarEditorObjectOptionsList:IsVisible()) then return end

	local bar = M.CurrentBar

	if (bar) then

		if (not frame) then
			frame = MacaroonBarEditorObjectOptionsListScrollFrame
		end

		local state = bar.handler:GetAttribute("state-current")

		if (bar.config.buttonList[state]) then

			local btnIDs = bar.config.buttonList[state]

			if (not tableList) then
				tableList = {}
			end

			for btnID in gmatch(btnIDs, "[^;]+") do
				button = _G[bar.btnType..btnID]
				tableList[button.config.barPos] = button
			end

			local dataOffset, count, data, button, text, datum = FauxScrollFrame_GetOffset(frame), 1, {}

			for k,v in pairs(tableList) do
				data[count] = k; count = count + 1
			end

			table.sort(data)

			frame:Show()

			frame.buttonH = frame:GetHeight()/numShown

			for i=1,numShown do

				button = _G["MacaroonObjectListScrollFrameButton"..i]
				button:SetChecked(nil)

				count = dataOffset + i

				if (data[count]) then

					text = bar.objtype.." "..data[count]

					if (tableList[data[count]] == M.CurrentObject) then
						button:SetChecked(1);
					end

					button.object = tableList[data[count]]
					button.name:SetText(text)
					button:Enable()
					button:Show()
				else

					button:Hide()
				end
			end

			FauxScrollFrame_Update(frame, #data, numShown, 2)
		end
	end
end

local function controlOnUpdate(self, elapsed)

	self.bar = M.BarIndex[editMode]
	if (self.bar) then self.bar:Show() end
	editMode = next(M.BarIndex, editMode)
	if not (editMode) then editMode = true; self:Hide() end
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Macaroon") then

		SD = MacaroonSavedState

		GameMenuFrame:HookScript("OnShow", function(self) if (editMode) then HideUIPanel(self) M.ConfigBars() end end)

	elseif (event == "PLAYER_ENTERING_WORLD" and not pew) then

		pew = true

	elseif (editMode and event == "PLAYER_REGEN_DISABLED") then

		M.ConfigBars()

	elseif (event == "ACTIONBAR_SHOWGRID") then

		if (editMode) then
			for k,v in pairs(M.BarIndex) do
				if (v:IsVisible()) then
					v.showgrid = true
					v:Hide()
				end
			end
		end

	elseif (event == "ACTIONBAR_HIDEGRID") then

		if (editMode) then
			for k,v in pairs(M.BarIndex) do
				if (v.showgrid) then
					v:Show()
					v.showgrid = nil
				end
			end
		end
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:SetScript("OnUpdate", controlOnUpdate)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("ACTIONBAR_SHOWGRID")
frame:RegisterEvent("ACTIONBAR_HIDEGRID")
showFrame = frame
frame:Hide()
