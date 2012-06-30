--Macaroon, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local M = Macaroon

M.EditFrames = {}

M.EditFrameTooltips = {}

M.ObjectDataUpdates = {}

M.CurrentObject = nil

local panels, toggleOptions, flyoutData, anchorPoints = {}, {}, {}, {}

local modifyType, editMode, raiseMode, buttonEditor, macroEditor, tabsOpened, SD, MBD, pew, player = 1, false
local numShown, expandedRealm, expandedChar, selectedMacro, currVaultMacro = 20

local find = string.find
local lower = string.lower

local GetMouseFocus = _G.GetMouseFocus

local CopyTable = M.CopyTable
local ClearTable = M.ClearTable
local SpellIndex = M.SpellIndex
local GetChildrenAndRegions = M.GetChildrenAndRegions

local function insertLink(text)

	local item = GetItemInfo(text)

	if (macroEditor.flyoutedit.keyedit.edit:IsVisible()) then

		macroEditor.flyoutedit.keyedit.edit:Insert(item or text)

	elseif (macroEditor.macroedit.edit:GetText() == "") then

		if (item) then

			if (GetItemSpell(text)) then
				macroEditor.macroedit.edit:Insert(SLASH_USE1.." "..item)
			else
				macroEditor.macroedit.edit:Insert(SLASH_EQUIP1.." "..item)
			end

		else
			macroEditor.macroedit.edit:Insert(SLASH_CAST1.." "..text)
		end
	else
		macroEditor.macroedit.edit:Insert(item or text)
	end
end

local function modifiedSpellClick(button)

	local id = SpellBook_GetSpellBookSlot(GetMouseFocus())

	if (id > MAX_SPELLS) then
		return
	end

	if (CursorHasSpell() and macroEditor:IsVisible()) then
		ClearCursor()
	end

	if (IsModifiedClick("CHATLINK")) then

		if (macroEditor:IsVisible()) then

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

		if (macroEditor:IsVisible()) then

			local itemName = GetItemInfo(link)

			if (itemName) then
				insertLink(itemName)
			end

			return true
		end
	end
end

local function modifiedCompanionClick(button)

	local id = button.spellID

	if (CursorHasSpell() and macroEditor:IsVisible()) then
		ClearCursor()
	end

	if (IsModifiedClick("CHATLINK")) then

		if (macroEditor:IsVisible()) then

			local comp = GetSpellInfo(id)

			if (comp) then
				insertLink(comp.."()")
			end

			return
		end
	end

	PetPaperDollFrame_UpdateCompanions()	--Set up the highlights again

end

local function openStackSplitFrame(...)

	if (macroEditor:IsVisible()) then
		StackSplitFrame:Hide()
	end
end

local buttonTypes = { "macro", "action", "pet" }

local function updateButtonType(button, delta, value, raw)

	if (value ~= nil) then
		button.config.type = values
		M.SetButtonType(button)
		return
	end

	local index

	for k,v in pairs(buttonTypes) do
		if (button.config.type == v) then
			index = k
		end
	end

	if (not index) then
		index = 1
	end

	if (not delta) then
		return M.Strings["TYPES_"..index]
	end

	if (delta > 0) then

		if (index == #buttonTypes) then
			index = 1
		else
			index = index + 1
		end

		button.config.type = buttonTypes[index]

	else
		if (index == 1) then
			index = #buttonTypes
		else
			index = index - 1
		end

		button.config.type = buttonTypes[index]
	end

	if (raw) then
		return button.config.type
	end

	M.SetButtonType(button)
end

local function updateUpClicks(button, delta, value, raw)

	if (value ~= nil) then
		button.config.upClicks = value; return
	end

	if (not delta) then
		return button.config.upClicks
	end

	local toggle = button.config.upClicks

	if (toggle) then
		button.config.upClicks = false
	else
		button.config.upClicks = true
	end

	if (raw) then
		return button.config.upClicks
	end
end

local function updateDownClicks(button, delta, value, raw)

	if (value ~= nil) then
		button.config.downClicks = value; return
	end

	if (not delta) then
		return button.config.downClicks
	end

	local toggle = button.config.downClicks

	if (toggle) then
		button.config.downClicks = false
	else
		button.config.downClicks = true
	end

	if (raw) then
		return button.config.downClicks
	end
end

local function updateCopyDrag(button, delta, value, raw)

	if (value ~= nil) then
		button.config.copyDrag = value; return
	end

	if (not delta) then
		return button.config.copyDrag
	end

	local toggle = button.config.copyDrag

	if (toggle) then
		button.config.copyDrag = false
	else
		button.config.copyDrag = true
	end

	if (raw) then
		return button.config.copyDrag
	end
end

local function updateMuteSFX(button, delta, value, raw)

	if (value ~= nil) then
		button.config.muteSFX = value; return
	end

	if (not delta) then
		return button.config.muteSFX
	end

	local toggle = button.config.muteSFX

	if (toggle) then
		button.config.muteSFX = false
	else
		button.config.muteSFX = true
	end

	if (raw) then
		return button.config.muteSFX
	end

end

local function updateClearFeedback(button, delta, value, raw)

	if (value ~= nil) then
		button.config.clearerrors = value; return
	end

	if (not delta) then
		return button.config.clearerrors
	end

	local toggle = button.config.clearerrors

	if (toggle) then
		button.config.clearerrors = false
	else
		button.config.clearerrors = true
	end

	if (raw) then
		return button.config.clearerrors
	end

end

local function updateCooldownAlpha(button, delta, value, raw)

	if (value ~= nil) then
		button.config.cooldownAlpha = value; return
	end

	if (not delta) then
		return (format("%0.0f", button.config.cooldownAlpha*100)).."%"
	end

	if (delta > 0) then
		button.config.cooldownAlpha = button.config.cooldownAlpha + 0.01
		if (button.config.cooldownAlpha > 1) then
			button.config.cooldownAlpha = 1
		end
	else
		button.config.cooldownAlpha = button.config.cooldownAlpha - 0.01
		if (button.config.cooldownAlpha < 0.01) then
			button.config.cooldownAlpha = 0
		end
	end

	if (raw) then
		return button.config.cooldownAlpha
	end

end

local function updateKeybindText(button, delta, value, raw)

	if (value ~= nil) then
		button.config.bindText = value; return
	end

	if (not delta) then
		return button.config.bindText, button.config.bindColor
	end

	if (delta>0) then
		button.config.bindText = true
	else
		button.config.bindText = false
	end

	if (raw) then
		return button.config.bindText, button.config.bindColor
	end

end

local function updateCountText(button, delta, value, raw)

	if (value ~= nil) then
		button.config.countText = value; return
	end

	if (not delta) then
		return button.config.countText, button.config.countColor
	end

	if (delta>0) then
		button.config.countText = true
	else
		button.config.countText = false
	end

	if (raw) then
		return button.config.countText, button.config.countColor
	end

end

local function updateMacroText(button, delta, value, raw)

	if (value ~= nil) then
		button.config.macroText = value; return
	end

	if (not delta) then
		return button.config.macroText, button.config.macroColor
	end

	if (delta>0) then
		button.config.macroText = true
	else
		button.config.macroText = false
	end

	if (raw) then
		return button.config.macroText, button.config.macroColor
	end

end

local function updateCooldownText(button, delta, value, raw)

	if (value ~= nil) then
		button.config.cdText = value; return
	end

	if (not delta) then
		return button.config.cdText, button.config.cdcolor1, button.config.cdcolor2
	end

	if (delta>0) then
		button.config.cdText = true
	else
		button.config.cdText = false
	end

	if (raw) then
		return button.config.cdText, button.config.cdcolor1, button.config.cdcolor2
	end

end

local function updateAuraText(button, delta, value, raw)

	if (value ~= nil) then
		button.config.auraText = value; return
	end

	if (not delta) then
		return button.config.auraText, button.config.auracolor1, button.config.auracolor2
	end

	if (delta>0) then
		button.config.auraText = true
	else
		button.config.auraText = false
	end

	if (raw) then
		return button.config.auraText, button.config.auracolor1, button.config.auracolor2
	end

end

local function updateAuraIndicator(button, delta, value, raw)

	if (value ~= nil) then
		button.config.auraInd = value; return
	end

	if (not delta) then
		return button.config.auraInd, button.config.buffcolor, button.config.debuffcolor
	end

	if (delta>0) then
		button.config.auraInd = true
	else
		button.config.auraInd = false
	end

	if (raw) then
		return button.config.auraInd, button.config.buffcolor, button.config.debuffcolor
	end

end

local function updateRangeIndicator(button, delta, value, raw)

	if (value ~= nil) then
		button.config.rangeInd = value; return
	end

	if (not delta) then
		return button.config.rangeInd, button.config.rangecolor
	end

	if (delta>0) then
		button.config.rangeInd = true
	else
		button.config.rangeInd = false
	end

	if (raw) then
		return button.config.rangeInd, button.config.rangecolor
	end

end

local function updateScale(button, delta)

	if (not delta) then
		return format("%0.2f", button.config.scale)
	end

	if (not button.anchoredBar) then

		if (delta>0) then
			button.config.scale = button.config.scale + 0.01
		else
			button.config.scale = button.config.scale - 0.01
			if (button.config.scale < 0.2) then
				button.config.scale = 0.2
			end
		end
	end

	button.bar.updateBar(button.bar, nil, true, true)

end

local function updateAlpha(button, delta)

	if (not delta) then
		return (format("%0.0f", button.config.alpha*100)).."%"
	end

	if (delta > 0) then
		button.config.alpha = button.config.alpha + 0.01
		if (button.config.alpha > 1) then
			button.config.alpha = 1
		end
	else
		button.config.alpha = button.config.alpha - 0.01
		if (button.config.alpha < 0.01) then
			button.config.alpha = 0
		end
	end

	button.bar.updateBar(button.bar, nil, true, true)
end

local function updateXOffset(button, delta)

	if (not delta) then
		return format("%0.1f", button.config.XOffset)
	end

	if (delta>0) then
		button.config.XOffset = button.config.XOffset + 0.5
	else
		button.config.XOffset = button.config.XOffset - 0.5
	end

	button.bar.updateBar(button.bar, nil, true, true)

end

local function updateYOffset(button, delta)

	if (not delta) then
		return format("%0.1f", button.config.YOffset)
	end

	if (delta>0) then
		button.config.YOffset = button.config.YOffset + 0.5
	else
		button.config.YOffset = button.config.YOffset - 0.5
	end

	button.bar.updateBar(button.bar, nil, true, true)

end

local function updateHHitBox(button, delta)

	if (not delta) then
		return format("%0.1f", ceil(button:GetWidth()/2)-button.config.HHitBox)
	end

	button.hitbox:Show()

	if (delta>0) then
		button.config.HHitBox = button.config.HHitBox - 0.5
	else
		button.config.HHitBox = button.config.HHitBox + 0.5
		if (button.config.HHitBox > button:GetWidth()/2) then
			button.config.HHitBox = ceil(button:GetWidth()/2)
		end
	end
end

local function updateVHitBox(button, delta)

	if (not delta) then
		return format("%0.1f", ceil(button:GetHeight()/2)-button.config.VHitBox)
	end

	button.hitbox:Show()

	if (delta>0) then
		button.config.VHitBox = button.config.VHitBox - 0.5
	else
		button.config.VHitBox = button.config.VHitBox + 0.5
		if (button.config.VHitBox > button:GetHeight()/2) then
			button.config.VHitBox = ceil(button:GetHeight()/2)
		end
	end
end

local function updateSpellCounts(button, delta)

	if (not delta) then
		return button.config.spellCounts
	end

	local toggle = button.config.spellCounts

	if (toggle) then
		button.config.spellCounts = false
	else
		button.config.spellCounts = true
	end
end

local function updateComboCounts(button, delta)

	if (not delta) then
		return button.config.comboCounts
	end

	local toggle = button.config.comboCounts

	if (toggle) then
		button.config.comboCounts = false
	else
		button.config.comboCounts = true
	end
end

local types = { "Do Not Scan", "Scan", "Scan Tooltips" }

local function updateFlyoutSpell(button, delta)

	local scanned

	if (not flyoutData.spell) then
		scanned = 1
	elseif (flyoutData.spell:find("+")) then
		scanned = 3
	else
		scanned = 2
	end

	if (not delta) then
		return types[scanned]
	end

	if (delta > 0) then

		scanned = scanned + 1

		if (scanned > #types) then
			scanned = 1
		end
	else

		scanned = scanned - 1

		if (scanned < 1) then
			scanned = #types
		end
	end

	if (scanned == 1) then
		flyoutData.spell = nil
	elseif (scanned == 2) then
		flyoutData.spell = "spell"
	elseif (scanned == 3) then
		flyoutData.spell = "spell+"
	end

end

local function updateFlyoutItem(button, delta)

	local scanned

	if (not flyoutData.item) then
		scanned = 1
	elseif (flyoutData.item:find("+")) then
		scanned = 3
	else
		scanned = 2
	end

	if (not delta) then
		return types[scanned]
	end

	if (delta > 0) then

		scanned = scanned + 1

		if (scanned > #types) then
			scanned = 1
		end
	else

		scanned = scanned - 1

		if (scanned < 1) then
			scanned = #types
		end
	end

	if (scanned == 1) then
		flyoutData.item = nil
	elseif (scanned == 2) then
		flyoutData.item = "item"
	elseif (scanned == 3) then
		flyoutData.item = "item+"
	end

end

local function updateFlyoutCompanion(button, delta)

	local scanned

	if (not flyoutData.companion) then
		scanned = 1
	elseif (flyoutData.companion:find("+")) then
		scanned = 3
	else
		scanned = 2
	end

	if (not delta) then
		return types[scanned]
	end

	if (delta > 0) then

		scanned = scanned + 1

		if (scanned > #types) then
			scanned = 1
		end
	else

		scanned = scanned - 1

		if (scanned < 1) then
			scanned = #types
		end
	end

	if (scanned == 1) then
		flyoutData.companion = nil
	elseif (scanned == 2) then
		flyoutData.companion = "companion"
	elseif (scanned == 3) then
		flyoutData.companion = "companion+"
	end

end

local function updateFlyoutShape(button, delta)


	if (not flyoutData.shape or not flyoutData.shape:find("^[lc]")) then
		flyoutData.shape = "linear"
	elseif (flyoutData.shape:find("^c")) then
		flyoutData.shape = "circle"
	elseif (flyoutData.shape:find("^l")) then
		flyoutData.shape = "linear"
	end

	if (not delta) then
		if (flyoutData.shape == "linear") then
			return M.Strings.BARSHAPE_1
		elseif (flyoutData.shape == "circle") then
			return M.Strings.BARSHAPE_2
		else
			return "---"
		end
	end

	if (flyoutData.shape == "linear") then
		flyoutData.shape = "circle"
	else
		flyoutData.shape = "linear"
	end

end

local function updateFlyoutColumns(button, delta)

	if (not flyoutData.columns) then
		flyoutData.columns = 6
	end

	if (not delta) then
		return flyoutData.columns
	end

	if (delta > 0) then

		flyoutData.columns = flyoutData.columns + 1

	else

		flyoutData.columns = flyoutData.columns - 1

		if (flyoutData.columns < 1) then
			flyoutData.columns = 1
		end
	end

end

local function updateFlyoutAnchor1(button, delta)

	local index

	if (not flyoutData.anchor1) then
		flyoutData.anchor1 = "RIGHT"
	end

	for i,point in ipairs(anchorPoints) do
		if (point[1]:lower() == flyoutData.anchor1:lower() or point[2]:lower() == flyoutData.anchor1:lower()) then
			index = i
		end
	end

	if (not delta) then
		return anchorPoints[index][2]
	end

	if (delta > 0) then

		index = index + 1

		if (index > #anchorPoints) then
			index = 1
		end
	else

		index = index - 1

		if (index < 1) then
			index = #anchorPoints
		end
	end

	flyoutData.anchor1 = anchorPoints[index][2]

end

local function updateFlyoutAnchor2(button, delta)

	local index

	if (not flyoutData.anchor2) then
		flyoutData.anchor2 = "LEFT"
	end

	for i,point in ipairs(anchorPoints) do
		if (point[1]:lower() == flyoutData.anchor2:lower() or point[2]:lower() == flyoutData.anchor2:lower()) then
			index = i
		end
	end

	if (not delta) then
		return anchorPoints[index][2]
	end

	if (delta > 0) then

		index = index + 1

		if (index > #anchorPoints) then
			index = 1
		end
	else

		index = index - 1

		if (index < 1) then
			index = #anchorPoints
		end
	end

	flyoutData.anchor2 = anchorPoints[index][2]

end

local function updateFlyoutMode(button, delta)

	if (not flyoutData.mode or not flyoutData.mode:find("^[cm]")) then
		flyoutData.mode = "click"
	elseif (flyoutData.mode:find("^c")) then
		flyoutData.mode = "click"
	elseif (flyoutData.mode:find("^m")) then
		flyoutData.mode = "mouse"
	end

	if (not delta) then
		return M.Strings[flyoutData.mode:upper().."_ANCHOR"]
	end

	if (flyoutData.mode == "click") then
		flyoutData.mode = "mouse"
	else
		flyoutData.mode = "click"
	end

end

local actionTable = {
	--[M.Strings.BTN_EDIT_GENERAL_1] = { updateButtonType, true },
	[M.Strings.BTN_EDIT_GENERAL_1] = { updateUpClicks, true },
	[M.Strings.BTN_EDIT_GENERAL_2] = { updateDownClicks, true },
	[M.Strings.BTN_EDIT_GENERAL_3] = { updateCopyDrag, true },
	[M.Strings.BTN_EDIT_GENERAL_4] = { updateMuteSFX, true },
	[M.Strings.BTN_EDIT_GENERAL_5] = { updateClearFeedback, true },
	[M.Strings.BTN_EDIT_GENERAL_6] = { updateCooldownAlpha, true },

	[M.Strings.BTN_EDIT_GENERAL_CHK_1] = { updateKeybindText, true },
	[M.Strings.BTN_EDIT_GENERAL_CHK_2] = { updateCountText, true },
	[M.Strings.BTN_EDIT_GENERAL_CHK_3] = { updateMacroText, true },
	[M.Strings.BTN_EDIT_GENERAL_CHK_4] = { updateCooldownText, true },
	[M.Strings.BTN_EDIT_GENERAL_CHK_5] = { updateAuraText, true },
	[M.Strings.BTN_EDIT_GENERAL_CHK_6] = { updateAuraIndicator, true },
	[M.Strings.BTN_EDIT_GENERAL_CHK_7] = { updateRangeIndicator, true },

	[M.Strings.BTN_EDIT_ADVANCED_1] = { updateScale, false },
	[M.Strings.BTN_EDIT_ADVANCED_2] = { updateAlpha, false },
	[M.Strings.BTN_EDIT_ADVANCED_3] = { updateXOffset, false },
	[M.Strings.BTN_EDIT_ADVANCED_4] = { updateYOffset, false },
	[M.Strings.BTN_EDIT_ADVANCED_5] = { updateHHitBox, false },
	[M.Strings.BTN_EDIT_ADVANCED_6] = { updateVHitBox, false },
	[M.Strings.BTN_EDIT_ADVANCED_7] = { updateSpellCounts, false },
	[M.Strings.BTN_EDIT_ADVANCED_COMBO] = { updateComboCounts, false },

	[M.Strings.BTN_EDIT_FLYOUT_1] = { updateFlyoutSpell, false },
	[M.Strings.BTN_EDIT_FLYOUT_2] = { updateFlyoutItem, false },
	[M.Strings.BTN_EDIT_FLYOUT_3] = { updateFlyoutCompanion, false },
	[M.Strings.BTN_EDIT_FLYOUT_4] = { updateFlyoutShape, false },
	[M.Strings.BTN_EDIT_FLYOUT_5] = { updateFlyoutColumns, false },
	[M.Strings.BTN_EDIT_FLYOUT_6] = { updateFlyoutAnchor1, false },
	[M.Strings.BTN_EDIT_FLYOUT_7] = { updateFlyoutAnchor2, false },
	[M.Strings.BTN_EDIT_FLYOUT_8] = { updateFlyoutMode, false },
}

local textColorVars = {
	[M.Strings.BTN_EDIT_GENERAL_CHK_1] = "bindColor",
	[M.Strings.BTN_EDIT_GENERAL_CHK_2] = "countColor",
	[M.Strings.BTN_EDIT_GENERAL_CHK_3] = "macroColor",
	[M.Strings.BTN_EDIT_GENERAL_CHK_4] = "cdcolor1;cdcolor2",
	[M.Strings.BTN_EDIT_GENERAL_CHK_5] = "auracolor1;auracolor2",
	[M.Strings.BTN_EDIT_GENERAL_CHK_6] = "buffcolor;debuffcolor",
	[M.Strings.BTN_EDIT_GENERAL_CHK_7] = "rangecolor",
}

local function updateValues(button, delta, action)

	if (button and button.config) then

		if (actionTable[action]) then

			if (actionTable[action][2] and button == MBD) then

				return actionTable[action][1](MBD, delta)

			elseif (actionTable[action][2] and (modifyType == 1 or modifyType == 2)) then

				local value, color1, color2 = actionTable[action][1](button, delta, nil, true); button.updateData(button, button.bar, button.config.showstates)

				local bar, btn = button.bar

				if (bar and delta) then

					for state, btnIDs in pairs(bar.config.buttonList) do

						for btnID in gmatch(btnIDs, "[^;]+") do

							btn = _G[bar.btnType..btnID]

							if (btn) then

								if (modifyType == 1) then
									actionTable[action][1](btn, nil, value); btn.updateData(btn, bar, btn.config.showstates)
								elseif (modifyType == 2) then
									if (btn.config.showstates == button.config.showstates) then
										actionTable[action][1](btn, nil, value); btn.updateData(btn, bar, btn.config.showstates)
									end
								end
							end
						end
					end

					return
				end

				return value, color1, color2

			elseif (button ~= MBD) then

				local value, color1, color2 = actionTable[action][1](button, delta); button.updateData(button, button.bar, button.config.showstates)

				return value, color1, color2

			else
				return "---"
			end
		end
	else
		return "---"
	end
end

function M.SaveMacro(button)

	if (button) then

		local text = macroEditor.macroedit.edit:GetText()

		if (text) then
			button.config.macro = text; M.SetButtonType(button)
		end

		local realm, character, index = GetRealmName(), UnitName("player")

		if (button.bar and button.bar.config.name) then
			index = button.bar.config.name..": Button "..button.config.barPos
		end

		if (realm and character and index) then

			if (not MacaroonMacroVault[realm]) then
				MacaroonMacroVault[realm] = {}
			end

			if (not MacaroonMacroVault[realm][character]) then
				MacaroonMacroVault[realm][character] = {}
			end

			MacaroonMacroVault[realm][character][index] = {
				button.config.macro,
				button.config.macroIcon,
				button.config.macroName,
				button.config.macroNote,
				button.config.macroUseNote,
			}
		end
	end
end

function M.RaiseButtons(off, on)

	if (InCombatLockdown()) then
		return
	end

	if (not off) then
		M.ButtonBind(true)
		M.ObjectEdit(true)
	end

	if (not raiseMode and off) then
		return
	end

	if ((raiseMode or off) and not on) then

		raiseMode = false

		for k,v in pairs(M.Buttons) do
			v[1].updateData(v[1], v[1].bar, v[1].config.showstates)
		end

		M.Save()

	else

		raiseMode = true

		for k,v in pairs(M.Buttons) do
			if (v[1].bar and v[1].bar:IsVisible()) then
				v[1]:SetFrameStrata(v[1].bar.config.barStrata)
				v[1]:SetFrameLevel(v[1].bar:GetFrameLevel()+4)
				v[1].iconframe:SetFrameLevel(v[1].bar:GetFrameLevel()+2)
				v[1].iconframecooldown:SetFrameLevel(v[1].bar:GetFrameLevel()+3)
				v[1].iconframeaurawatch:SetFrameLevel(v[1].bar:GetFrameLevel()+3)
			end
		end
	end
end

function M.ObjectEdit(off, on)

	if (InCombatLockdown()) then
		return
	end

	if (not off) then
		M.ButtonBind(true)
		M.RaiseButtons(true)
	end

	if (not editMode and off) then
		return
	end

	if ((editMode or off) and not on) then

		editMode = false

		for k,v in pairs(M.EditFrames) do
			v:Hide()
			v:SetFrameStrata("LOW")
			k.editmode = false
			if (k.hitbox) then
				k.hitbox:Hide()
			end
		end

		if (not off) then
			for k,v in pairs(M.BarIndex) do
				v.updateBarTarget(v)
				v.updateBarLink(v)
				v.updateBarHidden(v)
			end
			for k,v in pairs(M.HideGrids) do
				v(nil, true)
			end
		end

		MacaroonObjectEditor.shrink = true

		M.CurrentObject = nil

		M.Save()

		collectgarbage()

	else

		editMode = true

		for k,v in pairs(M.EditFrames) do
			v:Show()
			v:SetFrameStrata(k.bar:GetFrameStrata())
			v:SetFrameLevel(k.bar:GetFrameLevel()+4)
			k.editmode = true
		end

		if (not off) then
			for k,v in pairs(M.BarIndex) do
				v.updateBarHidden(v, true)
				v.updateBarTarget(v, true)
			end
			for k,v in pairs(M.ShowGrids) do
				v(nil, true)
			end
		end
	end
end

function M.ObjectEdit_AddPanel(panel, index)
	panels[index] = panel
end

function M.ChangeObject(object, editor)

	local newObj = false

	if (pew) then

		if (object and M.CurrentObject ~= object) then

			M.CurrentObject = object

			newObj = true

			if (object.editframe) then
				object.editframe.select:Show()
				object.editframe.selected = true
				object.editframe.action = nil
			end

			if (object.bar) then
				M.ChangeBar(object.bar)
			end

		end

		if (not object) then
			M.CurrentObject = nil
		end

		for k,v in pairs(M.EditFrames) do
			if (k ~= object) then

				v.select:Hide()
				v.selected = false
				v.action = nil
				v.mousewheelfunc = nil
				v.message:SetText("")

				if (k.hitbox) then
					k.hitbox:Hide()
				end
			end
		end

		if (object) then
			M.ObjectEditorUpdateData(object)
		end
	end

	return newObj
end

function M.EditFrame_OnLoad(self)

	self:RegisterForClicks("AnyDown","AnyUp")
	self.elapsed = 0
	self.pushed = 0
	self.message = _G[self:GetName().."Message"]
	self:SetBackdropColor(0,0,0,0)
	self:SetBackdropBorderColor(0,0,0,0)
end

function M.EditFrame_OnClick(self, click, down, object)

	if (not down) then
		self.newObj = M.ChangeObject(object)
	end

	self.elapsed = 0; self.click = click; self.down = down; self.pushed = 0

	if (click == "MiddleButton") then

		if (down) then

			if (self.action) then
				self.hover = nil
				self.elapsed = 1
			end
		end

	elseif (not down) then

		if (click == "RightButton") then

			if (not MacaroonBarEditor:IsVisible()) then

				self.message:SetText("")

				self.mousewheelfunc = nil

				if (not self.newObj and MacaroonObjectEditor:IsVisible()) then
					M.ObjectEditorHide()
				elseif (MacaroonButtonStorage:IsVisible()) then
					M.ObjectEditorShow(MacaroonButtonStorage, InterfaceOptionsFrame, "TOPLEFT", "TOPRIGHT", 0, 0, 0.01, 1, true)
				elseif (not MacaroonObjectEditor:IsVisible()) then
					M.ObjectEditorShow(UIParent, MacaroonPanelMover, "CENTER", "CENTER", 0, 0, 0.01, 1, true)
				end
			end

		else

			if (not self.newObj and object.leftclick) then
				object.leftclick(object); M.ObjectEditorUpdateData(object)
			end
		end
	end

	M.OptionsGeneral_ModifyReset()
end

function M.EditFrame_OnMouseWheel(self, delta, button)

	self.elapsed = 0

end

function M.EditFrame_OnEnter(object)

	macroEditor.macroedit.edit:ClearFocus()

	if (SD.checkButtons[108]) then
		M.ObjectEditorUpdateData(object)
	end

	if (GetCVar("UberTooltips") == "1") then
		GameTooltip_SetDefaultAnchor(GameTooltip, object)
	else
		GameTooltip:SetOwner(object, "ANCHOR_RIGHT")
	end

	object.editframe.select:Show()

	local btnType = object.config.type

	if (M.EditFrameTooltips[btnType]) then
		M.EditFrameTooltips[btnType](object, true)
	end

	GameTooltip:Show()

	object.editframe.hover = true
end

function M.EditFrame_OnLeave(object)

	if (SD.checkButtons[108]) then
		M.ObjectEditorUpdateData()
	end

	object.UpdateTooltip = nil

	if (object ~= M.CurrentObject) then
		object.editframe.select:Hide()
	end

	GameTooltip:Hide()

	if (object.editframe:GetButtonState() ~= "PUSHED") then
		object.editframe.hover = nil
	end
end

function M.EditFrame_OnUpdate(self, elapsed)

	if (self.elapsed) then

		self.elapsed = self.elapsed + elapsed

		if (self.hover) then
			self.elapsed = 0
		end

		if (GetMouseFocus() == self) then
			self:EnableMouseWheel(true)
		else
			self:EnableMouseWheel(false)
		end
	end
end

function M.ButtonOptionsClose_OnUpdate(self, elapsed)

	if (SD.checkButtons[104]) then

		self.alpha = 255
		self.elapsed = self.elapsed + elapsed

		if (self.elapsed > 0.5) then
			self.sign = -self.sign
		end

		self.elapsed = mod(self.elapsed, 0.5)

		if (self.sign == 1) then
			self.text:SetTextColor(1,0.82,0)
			self.arrowline1:SetVertexColor(1,0.82,0)
			self.arrowline2:SetVertexColor(1,0.82,0)
			self.arrowhead:SetVertexColor(1,0.82,0)
			self.alpha = (55+(self.elapsed * 400))/255
		else
			self.text:SetTextColor(1,1,1)
			self.arrowline1:SetVertexColor(1,1,1)
			self.arrowline2:SetVertexColor(1,1,1)
			self.arrowhead:SetVertexColor(1,1,1)
			self.alpha = (255-(self.elapsed * 400))/255
		end

		self.text:SetAlpha(self.alpha)
		self.arrowline1:SetAlpha(self.alpha)
		self.arrowline2:SetAlpha(self.alpha)
		self.arrowhead:SetAlpha(self.alpha)

	elseif (self.text:GetAlpha() < 1) then

		self.text:SetTextColor(1,0.82,0)
		self.text:SetAlpha(1)

		self.arrowline1:SetVertexColor(1,0.82,0)
		self.arrowline1:SetAlpha(1)

		self.arrowline2:SetVertexColor(1,0.82,0)
		self.arrowline2:SetAlpha(1)

		self.arrowhead:SetVertexColor(1,0.82,0)
		self.arrowhead:SetAlpha(1)
	end
end

function M.OptionsTab_OnLoad(self, parent, frame, option)

	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self.frame = frame
	self.text:SetText(M.Strings["BTN_EDIT_TAB_"..option])

	self.leftSelected:SetVertexColor(1, 0.82, 0, 0.7)
	self.middleSelected:SetVertexColor(1, 0.82, 0, 0.7)
	self.rightSelected:SetVertexColor(1, 0.82, 0, 0.7)

	self.leftHighlight:SetVertexColor(1, 0.82, 0, 0.7)
	self.middleHighlight:SetVertexColor(1, 0.82, 0, 0.7)
	self.rightHighlight:SetVertexColor(1, 0.82, 0, 0.7)

	self.glow:SetVertexColor(1, 0.82, 0, 0.7)

	if (self:GetID() == 1) then
		self:GetFontString():SetTextColor(1, 0.82, 0)
	else
		self:GetFontString():SetTextColor(0.5, 0.5, 0.5)

		self.leftSelected:Hide()
		self.middleSelected:Hide()
		self.rightSelected:Hide()
	end

	if (not parent.optionTabs) then
		parent.optionTabs = {}
	end

	tinsert(parent.optionTabs, self)

end

function M.OptionsTab_OnClick(self, parent, button)

	PlaySound("UChatScrollButton")

	if (self:GetID() == 1 and self.selected) then

		if (tabsOpened) then

			self.frame:Hide(); tabsOpened = nil

			for k,v in pairs(parent.optionTabs) do
				if (v ~= self) then
					v:Disable()
					v:GetFontString():SetTextColor(0.5, 0.5, 0.5)
				end
			end

			buttonEditor.options:SetHeight(50)
			buttonEditor.closed:Show()

			M.ObjectEditorUpdateData(M.CurrentObject)

			return
		else
			self.frame:Show(); tabsOpened = true

			for k,v in pairs(parent.optionTabs) do
				if (v ~= self) then
					v:Enable()
				end
			end

			buttonEditor.options:SetHeight(175)
			buttonEditor.closed:Hide()

			M.ObjectEditorUpdateData(M.CurrentObject)
		end

	end

	for k,v in pairs(parent.optionTabs) do
		if (v.frame == self.frame) then
			v.leftSelected:Show()
			v.middleSelected:Show()
			v.rightSelected:Show()
			v:GetFontString():SetTextColor(1, 0.82, 0)
			v.frame:Show()
			v.selected = true
		else
			v.leftSelected:Hide()
			v.middleSelected:Hide()
			v.rightSelected:Hide()
			v:GetFontString():SetTextColor(1, 1, 1)
			v.frame:Hide()
			v.selected = nil
		end
	end
end

function M.ActionEditSlider_OnShow(self, button, update)

	if (not button) then
		button = M.CurrentObject
	end

	self.update = true

	if (button and button ~= MBD) then

		if (button.config.type == "action") then

			self:Enable()
			self:SetMinMaxValues(1, M.maxActionID)
			self.low:SetText(1)
			self.high:SetText(M.maxActionID)
			self:SetValue(button.config.action)
			macroEditor.actionedit.slideredit:SetText(button.config.action)

		elseif (button.config.type == "pet") then

			self:Enable()
			self:SetMinMaxValues(1, M.maxPetID)
			self.low:SetText(1)
			self.high:SetText(M.maxPetID)
			self:SetValue(button.config.petaction)
			macroEditor.actionedit.slideredit:SetText(button.config.petaction)

		else
			self:Disable()
			self.low:SetText("---")
			self.high:SetText("---")
			macroEditor.actionedit.slideredit:SetText("---")
		end

	else
		self:Disable()
		self.low:SetText("---")
		self.high:SetText("---")
		macroEditor.actionedit.slideredit:SetText("---")
	end

	self.update = nil

end

function M.ActionEditSlider_OnValueChanged(self)

	if (self:IsVisible() and not self.update) then

		local button = buttonEditor and buttonEditor.CurrentObject

		if (not button) then
			button = M.CurrentObject
		end

		if (button and button ~= MBD and macroEditor) then

			if (button.config.type == "action" and button.config.action and button.config.action ~= self:GetValue()) then
				button.config.action = self:GetValue()
				macroEditor.actionedit.slideredit:SetText(button.config.action)

			elseif (button.config.type == "pet" and button.config.petaction and button.config.petaction ~= self:GetValue()) then
				button.config.petaction = self:GetValue()
				macroEditor.actionedit.slideredit:SetText(button.config.petaction)
			end

			M.SetButtonType(button)

		elseif (macroEditor) then
			macroEditor.actionedit.slideredit:SetText("---")
		end
	end
end

function M.ActionEditRadiate_OnClick(self)

	local button = M.CurrentObject

	if (button and button ~= MBD) then

		for index,btn in pairs(M.Buttons) do

			if (button ~= btn[1] and button.config.type == btn[1].config.type and button.config.showstates == btn[1].config.showstates and button.bar == btn[1].bar) then

				local offset = button.config.barPos - btn[1].config.barPos

				if (btn[1].config.type == "action") then

					btn[1].config.action = button.config.action - offset

					if (btn[1].config.action < 1) then
						btn[1].config.action = 1
					end

					while (btn[1].config.action > M.maxActionID) do
						btn[1].config.action = btn[1].config.action - M.maxActionID
					end

				elseif (btn[1].config.type == "pet") then

					btn[1].config.petaction = button.config.petaction - offset

					if (btn[1].config.petaction < 1) then
						btn[1].config.petaction = 1
					end

					while (btn[1].config.petaction > M.maxPetID) do
						btn[1].config.petaction = btn[1].config.petaction - M.maxPetID
					end
				end

				M.SetButtonType(btn[1])
			end
		end
	end
end

local function resetFlyoutData()

	local button = M.CurrentObject

	if (button) then

		M.ClearTable(flyoutData)

		flyoutData.button = button

		if (button.cmds) then

			local types = { (","):split(button.cmds[1]:lower()) }

			for _, getTypes in pairs(types) do

				if (getTypes:find("^s")) then
					flyoutData.spell = getTypes
				elseif (getTypes:find("^i")) then
					flyoutData.item = getTypes
				elseif (getTypes:find("^c")) then
					flyoutData.companion = getTypes
				end
			end

			flyoutData.keys = button.cmds[2]:gsub(",", "\n")
			flyoutData.shape = button.cmds[3]
			flyoutData.anchor1 = button.cmds[4]
			flyoutData.anchor2 = button.cmds[5]
			flyoutData.columns = button.cmds[6]
			flyoutData.mode = button.cmds[7]
			flyoutData.postCmds = button.postCmds or ""

		end
	end
end

function M.FlyoutEditor_OnClick(self)

	if (self.type == "flyout") then

		self.parent.macroedit.macrovault:Hide()
		self.parent.macroedit.flyoutedit:Show()
		self.text:SetText(M.Strings.CANCEL)
		self.type = "done"

		resetFlyoutData()
	else
		self.parent.macroedit.flyoutedit:Hide()
		self.text:SetText(M.Strings.CREATE_FLYOUT)
		self.type = "flyout"
	end
end

function M.FlyoutEditor_CreateFlyout(self)

	if (flyoutData.button and flyoutData.keys) then

		local macro, scan, keys = "/flyout ", "", ""

		if (flyoutData.spell) then
			scan = scan..flyoutData.spell..","
		end

		if (flyoutData.item) then
			scan = scan..flyoutData.item..","
		end

		if (flyoutData.companion) then
			scan = scan..flyoutData.companion
		end

		scan = scan:gsub(",$", "")
		keys = flyoutData.keys:gsub("\n", ",")
		keys = keys:gsub(",$", "")

		if (scan and #scan>0 and keys and #keys>0) then

			flyoutData.button.config.type = "macro"
			flyoutData.button.config.macroAuto = false
			flyoutData.button.config.macro = "/flyout "..scan..":"..keys..":"..flyoutData.shape..":"..flyoutData.anchor1..":"..flyoutData.anchor2..":"..flyoutData.columns..":"..flyoutData.mode.."\n"..flyoutData.postCmds

			M.SetButtonType(flyoutData.button)
			M.FlyoutEditor_OnClick(buttonEditor.flyoutBtn)
			M.ObjectEditorUpdateData(flyoutData.button)
		end
	else
		print("No flyout keys defined")
	end
end

function M.FlyoutEditor_Update(editor, button)

	if (not button) then
		button = M.CurrentObject
	end

	if (button and not editor) then
		editor = button.editor
	end

	if (editor and button) then

		if (button ~= flyoutData.button) then
			resetFlyoutData()
		end

		if (editor.flyoutBtns) then

			local count, value, height, lastFrame = 0

			for k,v in pairs(editor.flyoutBtns) do
				if (v.adjBtn and v:IsShown()) then
					count = count + 1
				end
			end

			height = (editor.macroedit.flyoutedit:GetHeight()-20)/count

			for k,v in ipairs(editor.flyoutBtns) do

				value = updateValues(button, nil, v.action)

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

		if (editor.flyoutkeylistedit) then
			editor.flyoutkeylistedit:SetText(flyoutData.keys or "")
		end

		if (editor.flyoutpostcmdedit) then
			editor.flyoutpostcmdedit:SetText(flyoutData.postCmds or "")
		end
	end
end

function M.FlyoutEditor_OnHide(self)
	M.ClearTable(flyoutData)
end

function M.FlyoutEditor_OnSizeChanged(self, w, h)
	M.FlyoutEditor_Update()
end

-------------------------------------------------------

local function anchorChild_OnShow(self)

	local button = M.CurrentObject

	if (button) then

		local data = { ["-none-"] = "none" }

		for k,v in pairs(M.BarIndexByName) do
			data[k] = v
		end

		M.EditBox_PopUpInitialize(self.popup, data)
	end
end

local function anchorChild_OnTextChanged(self)

	local button, text = M.CurrentObject, self:GetText()

	if (button and text) then

		if (text == "-none-") then
			button.config.anchoredBar = false
		else
			button.config.anchoredBar = text
		end

		M.UpdateAnchor(button)
	end


end

local function delayEdit_OnShow(self)

	local button = M.CurrentObject

	if (button) then

		if (button.config.anchorDelay) then
			self:SetText(button.config.anchorDelay)
		else
			self:SetText("-none-")
		end
	end
end

local function delayEdit_OnTextChanged(self)

	local button, text = M.CurrentObject, tonumber(self:GetText())

	if (button) then

		if (not text or (text and text <= 0)) then
			button.config.anchorDelay = false
		else
			button.config.anchorDelay = text
		end

		M.UpdateAnchor(button)
	end

end

function M.AnchorOptions_OnShow(self)

	local button = M.CurrentObject

	if (button) then

		self.clickanchor:SetChecked(button.config.clickAnchor)
		self.mouseanchor:SetChecked(button.config.mouseAnchor)

		if (button.config.anchoredBar) then
			self.anchorchild:SetText(button.config.anchoredBar)
		else
			self.anchorchild:SetText("-none-")
		end

		self.anchorchild:SetCursorPosition(0)
		self.delay:SetCursorPosition(0)
	end

end

--------------------------------------------------------------

function M.ButtonAdjOptions_OnClick(self, click, down, action, parent)

	local button = M.CurrentObject

	if (button) then

		self.click = click
		self.pushed = 0

		for k,v in pairs(parent.buttons) do
			if (v ~= self) then
				M.AdjustOptionButton_OnShow(v)
			end
		end
	end
end

function M.ButtonAdjOptions_Reset(self)

	local button = M.CurrentObject

	if (button and button.action) then

		if (button.selected) then
			self:SetBackdropColor(0,0,1,0.4)
		else
			self:SetBackdropColor(0,0,0,0.2)
		end
	end
end

function M.ObjectColorSwatch_OnClick(self, button, down)

	local button = M.CurrentObject

	if (button) then

		MacaroonColorPicker:SetParent(self.parent)
		MacaroonColorPicker:SetFrameStrata("TOOLTIP")
		MacaroonColorPicker:SetPoint("TOPLEFT", self:GetParent().parent.options.general.bg2, "TOPLEFT")
		MacaroonColorPicker:SetPoint("BOTTOMRIGHT", self:GetParent().parent.options.general.bg2, "BOTTOMRIGHT")
		MacaroonColorPicker:Show()

		MacaroonColorPicker.updateFunc = function(picker)

			local r,g,b = picker:GetColorRGB()
			local bar = button.bar

			if (modifyType == 4) then

				MBD.config[self.var] = r..";"..g..";"..b..";1"

			elseif (modifyType < 3) then

				local btn

				if (bar) then

					for state, btnIDs in pairs(bar.config.buttonList) do

						for btnID in gmatch(btnIDs, "[^;]+") do

							btn = _G[bar.btnType..btnID]

							if (btn) then

								if (modifyType == 1) then
									btn.config[self.var] = r..";"..g..";"..b..";1"
								elseif (modifyType == 2) then
									if (btn.config.showstates == button.config.showstates) then
										btn.config[self.var] = r..";"..g..";"..b..";1"
									end
								end
							end
						end
					end
				else
					button.config[self.var] = r..";"..g..";"..b..";1"
				end

			else
				button.config[self.var] = r..";"..g..";"..b..";1"
			end

			if (bar) then
				button.bar.updateBar(button.bar, nil, true, true)
			end

			M.ObjectEditorUpdateData(button)

		end

		local _, color1, color2 = updateValues(button, nil, self.action)

		if (color1 and self:GetID() == 1) then
			MacaroonColorPicker:SetColorRGB((";"):split(color1))
		elseif (color2 and self:GetID() == 2) then
			MacaroonColorPicker:SetColorRGB((";"):split(color2))
		end
	end
end

local function updateModifyOptions(editor)

	if (M.LastObject) then
		M.ChangeObject(M.LastObject); M.LastObject = nil
	end

	for i,frame in ipairs(editor.modifyBtns) do

		if (frame:GetID() == modifyType) then

			frame:SetChecked(1)

			if (frame:GetID() == 1 and not M.CurrentObject) then

				local bar, btn = M.CurrentBar

				if (bar) then

					for state, btnIDs in pairs(bar.config.buttonList) do

						for btnID in gmatch(btnIDs, "[^;]+") do

							btn = _G[bar.btnType..btnID]

							if (btn and btn.config.barPos == 1 and btn.config.showstates:find("homestate")) then
								M.ChangeObject(btn)
							end
						end
					end
				end
			end

			if (frame:GetID() == 2 and not M.CurrentObject) then

				local bar, btn = M.CurrentBar

				if (bar) then

					for state, btnIDs in pairs(bar.config.buttonList) do

						for btnID in gmatch(btnIDs, "[^;]+") do

							btn = _G[bar.btnType..btnID]

							if (btn and btn.config.barPos == 1 and btn.config.showstates == M.CurrentObject.config.showstates) then
								M.ChangeObject(btn)
							end
						end
					end
				else
					M.OptionsGeneral_ModifyReset()
				end
			end

			if (frame:GetID() == 3 and not M.CurrentObject) then
				M.OptionsGeneral_ModifyReset()
			end

			if (frame:GetID() == 4) then
				M.LastObject = M.CurrentObject; M.ChangeObject(MBD)
			end
		else
			frame:SetChecked(nil)
		end
	end
end

local function adjoptButton_OnUpdate(self, elapsed, button, dir)

	if (button and self.action and self:GetButtonState() == "PUSHED") then

		self.pushed = self.pushed + elapsed

		if (self.pushed > 0.45) then

			if (dir) then
				updateValues(button, 1, self.action)
			else
				updateValues(button, -1, self.action)
			end

			M.ObjectEditorUpdateData()
		end
	else
		self.pushed = 0
	end
end

local function macroEditIcon_OnClick(self, button, down)

	PlaySound("gsTitleOptionOK")

	local frame = macroEditor.macroiconlist

	if (frame) then

		if (frame:IsVisible()) then
			frame:Hide()
		else
			frame:Show()
		end

		self.click = true
		self.elapsed = 0
	end
end

local function macroEditIcon_OnEnter(self)

	self.enter = 1;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(M.Strings.MACRO_ICON)
end

local function macroEditIcon_OnLeave(self)

	self.updateTooltip = nil
	GameTooltip:Hide()
end

local function macroEditGetButtonTexture(button)

	local texture = button.iconframeicon:GetTexture()

	if (texture) then
		macroEditor.macroicon.icon:SetTexture(texture)
		macroEditor.macroicon.update = nil
	else
		macroEditor.macroicon.update = button
	end

end

local function macroEditIcon_OnUpdate(self, elapsed)

	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > 0.1 and self.click) then
		self.click = false
		self:SetChecked(nil)
	end

	if (self.update) then
		macroEditGetButtonTexture(self.update)
	end
end

local function macroEditUpdateIcon(self, button)

	if (not button) then
		button = M.CurrentObject
	end

	if (button and button.config.macroIcon) then

		local icon = button.config.macroIcon

		if (type(icon) == "table") then
			macroEditor.macroicon.icon:SetTexture(icon[6])
		else
			if (strlen(button.config.macro) < 1) then
				macroEditor.macroicon.icon:SetTexture("")
			elseif (icon == "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK") then
				macroEditGetButtonTexture(button)
			else
				macroEditor.macroicon.icon:SetTexture(icon)
			end
		end
	else
		macroEditor.macroicon.icon:SetTexture("")
	end
end

function M.MacroIconListUpdate()

	local frame = macroEditor.macroiconlist
	local numIcons, offset, index, texture, blankSet = #M.IconIndex+1, FauxScrollFrame_GetOffset(frame)

	for i,btn in ipairs(frame.buttons) do

		if (tabsOpened and i > 60) then

			btn.icon:SetTexture("")
			btn:Hide()
			btn.texture = M.IconIndex[1]

		else

			index = (offset * 12) + i

			texture = M.IconIndex[index]

			if (index < numIcons) then

				btn.icon:SetTexture(texture)
				btn:Show()
				btn.texture = texture

			elseif (not blankSet) then

				btn.icon:SetTexture("")
				btn:Show()
				btn.texture = ""
				blankSet = true

			else
				btn.icon:SetTexture("")
				btn:Hide()
				btn.texture = M.IconIndex[1]
			end
		end
	end

	FauxScrollFrame_Update(frame, ceil(numIcons/12), 1, 1)
end

local function macroEdit_OnShow(self, button)

	self:ClearFocus()

	if (not button) then
		button = M.CurrentObject
	end

	if (button and button.config.macro) then
		self:SetText(button.config.macro)
	else
		self:SetText("")
	end

end

local function macroEdit_OnHide(self)
	self:ClearFocus()
end

local function macroEdit_OnFocusGained(self)

	self:GetParent().focus:Hide(); self.text:Show()

	if (M.CurrentObject and M.CurrentObject ~= MBD) then
		M.CurrentObject.config.macroAuto = false
		self:SetText(gsub(self:GetText(), "#autowrite\n", ""))
	else
		self:ClearFocus()
	end

end

local function macroEdit_OnFocusLost(self)

	self:GetParent().focus:Show(); self.text:Hide()

	local button = M.CurrentObject

	if (button and button ~= MBD) then
		M.SaveMacro(button)
		M.ObjectEditorUpdateData(button)
	end
end

local function noteEdit_OnShow(self, button)

	self:ClearFocus()

	if (not button) then
		button = M.CurrentObject
	end

	if (button and button ~= MBD) then

		if (button.config.macroNote and strlen(button.config.macroNote) > 0) then
			self:SetText(button.config.macroNote); self.text:Hide()
		else
			self:SetText(""); self.text:Show()
		end
	else
		self:SetText(""); self.text:Show()
	end
end

local function noteEdit_OnEditFocusGained(self)

	if (M.CurrentObject and M.CurrentObject ~= MBD) then
		self.text:Hide()
	else
		self:ClearFocus()
	end
end

local function noteEdit_OnEditFocusLost(self)

	local button = M.CurrentObject

	if (button and button ~= MBD) then

		button.config.macroNote = self:GetText()

		if (strlen(button.config.macroNote) < 1) then
			self.text:Show()
		end
	end
end

local function nameEdit_OnShow(self, button)

	self:SetCursorPosition(0)
	self:ClearFocus()

	if (not button) then
		button = M.CurrentObject
	end

	if (button and button ~= MBD) then

		if (button.config.macroName and strlen(button.config.macroName) > 0) then
			self:SetText(button.config.macroName); self.text:Hide()
		else
			self:SetText(""); self.text:Show()
		end
	else
		self:SetText(""); self.text:Show()
	end
end

local function nameEdit_OnEditFocusGained(self)

	if (M.CurrentObject and M.CurrentObject ~= MBD) then
		self.text:Hide()
	else
		self:ClearFocus()
	end
end

local function nameEdit_OnEditFocusLost(self)

	local button = M.CurrentObject

	if (button and button ~= MBD) then

		button.config.macroName = self:GetText()

		if (strlen(button.config.macroName) < 1) then
			self.text:Show()
		end
	end
end

local function useNoteAsTooltip_OnShow(self, button)

	if (not button) then
		button = M.CurrentObject
	end

	if (button and button ~= MBD) then
		self:SetChecked(button.config.macroUseNote)
	else
		self:SetChecked(nil)
	end

end

local function useNoteAsTooltip_OnClick(self)

	local button = M.CurrentObject

	if (button and button ~= MBD) then
		if (self:GetChecked()) then
			button.config.macroUseNote = true
		else
			button.config.macroUseNote = false
		end
	end
end

local function macroEditorAddToVault_OnClick(self, button, down)

	if (self.category:IsVisible()) then
		self.category:Hide()
	else
		self.category:Show()
	end
end

local function vaultCategoryEdit_OnShow(self)

	local button = M.CurrentObject

	if (button) then

		local data = {}

		for k,v in pairs(MacaroonMacroVault["Main Vault"]) do
			data[k] = k
		end

		M.EditBox_PopUpInitialize(self.popup, data)

		self:SetText("")
		self.text:Show()
	end
end

local function vaultIndexEdit_OnShow(self)

	local button = M.CurrentObject

	if (button) then

		self:SetText(button.config.macroName)

		local text = self:GetText()

		if (text and #text > 0) then
			self.text:Hide()
		else
			self.text:Show()
		end
	end
end

local function vaultAddMainVaultMacro(category, index)

	local button = M.CurrentObject

	if (button and category and index) then

		if (not MacaroonMacroVault["Main Vault"][category]) then
			MacaroonMacroVault["Main Vault"][category] = {}
		end

		MacaroonMacroVault["Main Vault"][category][index] = {
			button.config.macro,
			button.config.macroIcon,
			button.config.macroName,
			button.config.macroNote,
			button.config.macroUseNote,
		}

		macroEditor.addtovault.category:Hide()
		macroEditor.addtovault.category.add.confirm:Hide()

		MacaroonMessageFrame:AddMessage(format(M.Strings.MACRO_VAULTADDMSG, "|cff00ff00"..index.."|r", "|cff00ff00"..category.."|r"))
	end
end

local function vaultAdd_OnClick(self)

	local category, index = macroEditor.addtovault.category.edit:GetText(), macroEditor.addtovault.category.index:GetText()

	if (not index or #index < 1) then

		self.confirm.left:Hide()
		self.confirm.right:Show()
		self.confirm.right.text:SetText(M.Strings.OKAY)
		self.confirm.message:SetText(M.Strings.MACRO_INVALIDNAME)
		self.confirm.message:SetJustifyH("LEFT")
		self.confirm:Show()
		return

	end

	if (not category or #category < 1) then

		self.confirm.left:Hide()
		self.confirm.right:Show()
		self.confirm.right.text:SetText(M.Strings.OKAY)
		self.confirm.message:SetText(M.Strings.MACRO_INVALIDCAT)
		self.confirm.message:SetJustifyH("LEFT")
		self.confirm:Show()
		return

	end

	if (category and not MacaroonMacroVault["Main Vault"][category]) then
		MacaroonMacroVault["Main Vault"][category] = {}
	end

	if (category and index and MacaroonMacroVault["Main Vault"][category] and MacaroonMacroVault["Main Vault"][category][index]) then

		self.confirm.left:Show()
		self.confirm.left.text:SetText(M.Strings.CONFIRM_YES)
		self.confirm.left:SetScript("OnClick", function(self) vaultAddMainVaultMacro(self.category, self.index) end)
		self.confirm.left:SetScript("PostClick", function(self) self:SetScript("OnClick", nil) end)
		self.confirm.left.category = category
		self.confirm.left.index = index

		self.confirm.right:Show()
		self.confirm.right.text:SetText(M.Strings.CONFIRM_NO)

		self.confirm.message:SetText(format(M.Strings.MACRO_SAVE_CONFIRM, "|cff00ff00"..index.."|r"))
		self.confirm.message:SetJustifyH("CENTER")
		self.confirm:Show()
		return
	end

	if (category and index and MacaroonMacroVault["Main Vault"][category] and not MacaroonMacroVault["Main Vault"][category][index]) then
		vaultAddMainVaultMacro(category, index)
		return
	end

	macroEditor.addtovault.category:Hide()
	macroEditor.addtovault.category.add.confirm:Hide()
end

local function macroVaultCategoryEdit_OnShow(self)

	local data = {}

	for k,v in pairs(MacaroonMacroVault["Main Vault"]) do
		data[k] = k
	end

	M.EditBox_PopUpInitialize(self.popup, data)

	self:SetText("")
	self.text:Show()
end

local function macroVaultIndexEdit_OnShow(self)

	local name = selectedMacro

	if (name) then

		self:SetText(name)

		local text = self:GetText()

		if (text and #text > 0) then
			self.text:Hide()
		else
			self.text:Show()
		end
	end
end


local function macroVaultAddMainVaultMacro(category, index)

	if (currVaultMacro and category and index) then

		if (not MacaroonMacroVault["Main Vault"][category]) then
			MacaroonMacroVault["Main Vault"][category] = {}
		end

		MacaroonMacroVault["Main Vault"][category][index] = CopyTable(currVaultMacro)

		macroEditor.macrovault.addtovault.category:Hide()
		macroEditor.macrovault.addtovault.category.add.confirm:Hide()

		MacaroonMessageFrame:AddMessage(format(M.Strings.MACRO_VAULTADDMSG, "|cff00ff00"..index.."|r", "|cff00ff00"..category.."|r"))

		M.MacroVaultScrollFrameUpdate()
	end
end

local function macroVaultAdd_OnClick(self)

	local category, index = macroEditor.macrovault.addtovault.category.edit:GetText(), macroEditor.macrovault.addtovault.category.index:GetText()

	if (not index or #index < 1) then

		self.confirm.left:Hide()
		self.confirm.right:Show()
		self.confirm.right.text:SetText(M.Strings.OKAY)
		self.confirm.message:SetText(M.Strings.MACRO_INVALIDNAME)
		self.confirm.message:SetJustifyH("LEFT")
		self.confirm:Show()
		return

	end

	if (not category or #category < 1) then

		self.confirm.left:Hide()
		self.confirm.right:Show()
		self.confirm.right.text:SetText(M.Strings.OKAY)
		self.confirm.message:SetText(M.Strings.MACRO_INVALIDCAT)
		self.confirm.message:SetJustifyH("LEFT")
		self.confirm:Show()
		return

	end

	if (category and not MacaroonMacroVault["Main Vault"][category]) then
		MacaroonMacroVault["Main Vault"][category] = {}
	end

	if (category and index and MacaroonMacroVault["Main Vault"][category] and MacaroonMacroVault["Main Vault"][category][index]) then

		self.confirm.left:Show()
		self.confirm.left.text:SetText(M.Strings.CONFIRM_YES)
		self.confirm.left:SetScript("OnClick", function(self) macroVaultAddMainVaultMacro(self.category, self.index) end)
		self.confirm.left:SetScript("PostClick", function(self) self:SetScript("OnClick", nil) end)
		self.confirm.left.category = category
		self.confirm.left.index = index

		self.confirm.right:Show()
		self.confirm.right.text:SetText(M.Strings.CONFIRM_NO)

		self.confirm.message:SetText(format(M.Strings.MACRO_SAVE_CONFIRM, "|cff00ff00"..index.."|r"))
		self.confirm.message:SetJustifyH("CENTER")
		self.confirm:Show()
		return
	end

	if (category and index and MacaroonMacroVault["Main Vault"][category] and not MacaroonMacroVault["Main Vault"][category][index]) then
		macroVaultAddMainVaultMacro(category, index)
		return
	end

	macroEditor.macrovault.addtovault.category:Hide()
	macroEditor.macrovault.addtovault.category.add.confirm:Hide()

	M.MacroVaultScrollFrameUpdate()
end

function M.ButtonEditor_OnEvent(self)

	M.ObjectEdit_AddPanel(self, "button")

	self.buttons = {}
	self.generalBtns = {}
	self.generalChks = {}
	self.advancedBtns = {}
	self.modifyBtns = {}
	self.flyoutBtns = {}

	buttonEditor = self; macroEditor = self.macroedit

	local index, count, yOffset, iOffset, frame, fontStr, lastFrame, anchorF1, anchorF2, x, y = 1, 0, 0

	local toggles = {
		["BTN_EDIT_GENERAL_1"] = true,
		["BTN_EDIT_GENERAL_2"] = true,
		["BTN_EDIT_GENERAL_3"] = true,
		["BTN_EDIT_GENERAL_4"] = true,
		["BTN_EDIT_GENERAL_5"] = true,
		["BTN_EDIT_ADVANCED_7"] = true,
		["BTN_EDIT_ADVANCED_COMBO"] = true,
	}

	index, lastFrame = 1, nil

	while (M.Strings["BTN_EDIT_GENERAL_"..index]) do

		frame = CreateFrame("CheckButton", "$parentGeneral"..index, self.options.general, "MacaroonAdjustOptionButtonTemplate")
		frame:SetID(index)
		frame:SetWidth(190)
		frame:SetHeight(20)
		frame.adjBtn = true

		if (toggles["BTN_EDIT_GENERAL_"..index]) then
			frame.toggle_func = function(self, button, down) self.pushed = 0 updateValues(M.CurrentObject, true, self.action) M.ObjectEditorUpdateData() end
		else
			frame.onclick_func = function(self, button, down) M.ButtonAdjOptions_OnClick(self, click, down, self.action, self.parent) end
		end

		frame.onshow_func = function(self) M.ButtonAdjOptions_Reset(self) end
		frame.onenter_func = function(self) if (SD.checkButtons[104]) then self.tooltip = M.Strings.ADJUSTBTN_BEGIN_TOOLTIP else self.tooltip = nil end end
		frame.text:SetText(M.Strings["BTN_EDIT_GENERAL_"..index])
		frame.action = frame.text:GetText()
		frame.parent = self

		frame.add.onclick_func = function(self, button, down, parent) self.pushed = 0 updateValues(M.CurrentObject, 1, self.action) M.ObjectEditorUpdateData() end
		frame.add.onupdate_func = function(self, elapsed) adjoptButton_OnUpdate(self, elapsed, M.CurrentObject, true) end
		frame.add.action = frame.text:GetText()
		frame.add.editor = self

		frame.sub.onclick_func = function(self, button, down, parent) self.pushed = 0 updateValues(M.CurrentObject, -1, self.action) M.ObjectEditorUpdateData()end
		frame.sub.onupdate_func = function(self, elapsed) adjoptButton_OnUpdate(self, elapsed, M.CurrentObject, nil) end
		frame.sub.action = frame.text:GetText()
		frame.sub.editor = self

		tinsert(self.buttons, frame); tinsert(self.generalBtns, frame)

		if (lastFrame) then
			frame:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, -(frame:GetHeight()))
			frame:SetPoint("TOPRIGHT", lastFrame, "TOPRIGHT", 0, -(frame:GetHeight()))
		else
			frame:SetPoint("TOPLEFT", self.options.general, "TOPLEFT", 7, -10)
			frame.anchor = true
		end

		lastFrame = frame

		index = index + 1
	end

	index, lastFrame = 1, nil

	while (M.Strings["BTN_EDIT_GENERAL_CHK_"..index]) do

		frame = CreateFrame("CheckButton", "$parentGeneralCheck"..index, self.options.general, "MacaroonOptionCBColorSwatchTemplate")
		frame:SetID(index)

		frame:SetScript("OnClick", function(self, button, down)  if (self:GetChecked()) then self.checked = 1 else self.checked = -1 end updateValues(M.CurrentObject, self.checked, self.action) M.ObjectEditorUpdateData() end)
		frame.text:SetText(M.Strings["BTN_EDIT_GENERAL_CHK_"..index])
		frame.action = frame.text:GetText()
		frame.parent = self

		local color1, color2 = (";"):split(textColorVars[frame.action])

		frame.swatch1:SetScript("OnClick", function(self, button, down) M.ObjectColorSwatch_OnClick(self, button, down) end)
		frame.swatch1:SetID(1)
		frame.swatch1.action = frame.action
		frame.swatch1.parent = self.options.general
		frame.swatch1.var = color1

		frame.swatch2:SetScript("OnClick", function(self, button, down) M.ObjectColorSwatch_OnClick(self, button, down) end)
		frame.swatch2:SetID(2)
		frame.swatch2.action = frame.action
		frame.swatch2.parent = self.options.general
		frame.swatch2.var = color2

		if (index < 4 or index == 7) then
			frame.swatch2:Hide()
		end

		tinsert(self.generalChks, frame)

		if (lastFrame) then
			frame:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, -(frame:GetHeight()))
			frame:SetPoint("TOPRIGHT", lastFrame, "TOPRIGHT", 0, -(frame:GetHeight()))
		else
			frame:SetPoint("TOPRIGHT", self.options.general, "TOPRIGHT", -75, -9)
			frame.anchor = true
		end

		lastFrame = frame

		index = index + 1
	end

	frame = CreateFrame("CheckButton", "$parentEntireBar", self.options.general, "MacaroonOptionRadioButtonTemplate")
	frame:SetID(1)
	frame:SetChecked(1)
	frame:SetPoint("LEFT", self.options.general.modify, "RIGHT", 5, 0)
	frame:SetScript("OnClick", function(self) modifyType = self:GetID() updateModifyOptions(buttonEditor) end)
	frame.text:SetText(M.Strings.BTN_EDIT_GENERAL_ENTIREBAR)
	tinsert(self.modifyBtns, frame)

	frame = CreateFrame("CheckButton", "$parentStateOnly", self.options.general, "MacaroonOptionRadioButtonTemplate")
	frame:SetID(2)
	frame:SetPoint("LEFT", self.modifyBtns[1].text, "RIGHT", 10, 0)
	frame:SetScript("OnClick", function(self) modifyType = self:GetID() updateModifyOptions(buttonEditor) end)
	frame.text:SetText(M.Strings.BTN_EDIT_GENERAL_CURRSTATE)
	tinsert(self.modifyBtns, frame)

	frame = CreateFrame("CheckButton", "$parentButtonOnly", self.options.general, "MacaroonOptionRadioButtonTemplate")
	frame:SetID(3)
	frame:SetPoint("LEFT", self.modifyBtns[2].text, "RIGHT", 10, 0)
	frame:SetScript("OnClick", function(self) modifyType = self:GetID() updateModifyOptions(buttonEditor) end)
	frame.text:SetText(M.Strings.BTN_EDIT_GENERAL_CURRBTN)
	tinsert(self.modifyBtns, frame)

	frame = CreateFrame("CheckButton", "$parentDefaultSettings", self.options.general, "MacaroonOptionRadioButtonTemplate")
	frame:SetID(4)
	frame:SetPoint("LEFT", self.modifyBtns[3].text, "RIGHT", 10, 0)
	frame:SetScript("OnClick", function(self) modifyType = self:GetID() updateModifyOptions(buttonEditor) end)
	frame.text:SetText(M.Strings.BTN_EDIT_GENERAL_DEFAULTS)
	tinsert(self.modifyBtns, frame)

	index, lastFrame = 1, nil

	while (M.Strings["BTN_EDIT_ADVANCED_"..index]) do

		frame = CreateFrame("CheckButton", "$parentGeneral"..index, self.options.advanced, "MacaroonAdjustOptionButtonTemplate")
		frame:SetID(index)
		frame:SetWidth(160)
		frame:SetHeight(20)
		frame.adjBtn = true

		if (toggles["BTN_EDIT_ADVANCED_"..index]) then
			frame.toggle_func = function(self, button, down) self.pushed = 0 updateValues(M.CurrentObject, true, self.action) M.ObjectEditorUpdateData() end
		else
			if (index == 5 or index == 6) then
				frame.onclick_func = function(self, button, down)

					M.ButtonAdjOptions_OnClick(self, click, down, self.action, self.parent)

					if (M.CurrentObject and M.CurrentObject.hitbox) then
						if (self:GetChecked()) then
							M.CurrentObject.hitbox:Show()
							M.CurrentObject.editframe:Hide()
							M.CurrentObject.editframehidden = true
						else
							M.CurrentObject.hitbox:Hide()
							M.CurrentObject.editframe:Show()
							M.CurrentObject.editframehidden = nil
						end
						self.add:HookScript("OnHide", function()
												if (M.CurrentObject) then
													M.CurrentObject.hitbox:Hide()
													if (M.CurrentObject.editframehidden) then
														M.CurrentObject.editframe:Show()
													end
												end end)
					end
				end

				frame.limit = 30
			else
				frame.onclick_func = function(self, button, down) M.ButtonAdjOptions_OnClick(self, click, down, self.action, self.parent) end
			end
		end

		frame.onshow_func = function(self) M.ButtonAdjOptions_Reset(self) end
		frame.onenter_func = function(self) if (SD.checkButtons[104]) then self.tooltip = M.Strings.ADJUSTBTN_BEGIN_TOOLTIP else self.tooltip = nil end end

		if (index == 7 and (UnitClass("player") == M.Strings.DRUID or UnitClass("player") == M.Strings.ROGUE)) then

			--replace spell counts with combo counts if a rogue. Add both if a druid.

			if (UnitClass("player") == M.Strings.DRUID) then
				frame.text:SetText(M.Strings["BTN_EDIT_ADVANCED_"..index])
				M.Strings.BTN_EDIT_ADVANCED_8 = M.Strings.BTN_EDIT_ADVANCED_COMBO
				toggles.BTN_EDIT_ADVANCED_8 = true
				actionTable[M.Strings.BTN_EDIT_ADVANCED_8] = { updateComboCounts, false }
			else
				frame.text:SetText(M.Strings["BTN_EDIT_ADVANCED_COMBO"])
				frame.toggle_func = function(self, button, down) self.pushed = 0 updateValues(M.CurrentObject, true, self.action) M.ObjectEditorUpdateData() end
				frame.onclick_func = nil
			end
		else
			frame.text:SetText(M.Strings["BTN_EDIT_ADVANCED_"..index])
		end

		frame.action = frame.text:GetText()
		frame.parent = self

		frame.add.onclick_func = function(self, button, down, parent) self.pushed = 0 updateValues(M.CurrentObject, 1, self.action) M.ObjectEditorUpdateData() end
		frame.add.onupdate_func = function(self, elapsed) adjoptButton_OnUpdate(self, elapsed, M.CurrentObject, true) end
		frame.add.action = frame.text:GetText()
		frame.add.editor = self

		frame.sub.onclick_func = function(self, button, down, parent) self.pushed = 0 updateValues(M.CurrentObject, -1, self.action) M.ObjectEditorUpdateData()end
		frame.sub.onupdate_func = function(self, elapsed) adjoptButton_OnUpdate(self, elapsed, M.CurrentObject, nil) end
		frame.sub.action = frame.text:GetText()
		frame.sub.editor = self

		tinsert(self.buttons, frame); tinsert(self.advancedBtns, frame)

		if (lastFrame) then
			frame:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, -(frame:GetHeight()))
			frame:SetPoint("TOPRIGHT", lastFrame, "TOPRIGHT", 0, -(frame:GetHeight()))
		else
			frame:SetPoint("TOPLEFT", self.options.advanced, "TOPLEFT", 7, -10)
			frame.anchor = true
		end

		lastFrame = frame

		index = index + 1
	end

	frame = CreateFrame("Frame", nil, macroEditor)
	frame:SetPoint("TOPLEFT", 0, 0)
	frame:SetPoint("BOTTOMRIGHT", macroEditor, "TOPRIGHT", -66, -70)
	frame:SetFrameLevel(macroEditor:GetFrameLevel())
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)
	macroEditor.iconbg = frame

	frame = CreateFrame("CheckButton", nil, macroEditor, "MacaroonMacroButtonTemplate")
	frame:SetID(0)
	frame:SetPoint("TOPLEFT", 9, -9)
	frame:SetWidth(52)
	frame:SetHeight(52)
	frame:SetScript("OnShow", macroEditUpdateIcon)
	frame:SetScript("OnEnter", macroEditIcon_OnEnter)
	frame:SetScript("OnLeave", macroEditIcon_OnLeave)
	frame.onclick_func = macroEditIcon_OnClick
	frame.onupdate_func = macroEditIcon_OnUpdate
	frame.elapsed = 0
	frame.click = false
	frame.parent = macroEditor
	macroEditor.macroicon = frame

	frame = CreateFrame("ScrollFrame", "$parentMacroEditor", macroEditor, "MacaroonScrollFrameTemplate2")
	frame:SetPoint("TOPLEFT", macroEditor.iconbg, "BOTTOMLEFT", 10, -10)
	frame:SetPoint("BOTTOMRIGHT", -70, 20)
	frame.edit:SetWidth(350)
	frame.edit:SetScript("OnShow", macroEdit_OnShow)
	frame.edit:SetScript("OnHide", macroEdit_OnHide)
	frame.edit:SetScript("OnEditFocusGained", macroEdit_OnFocusGained)
	frame.edit:SetScript("OnEditFocusLost", macroEdit_OnFocusLost)
	macroEditor.macroedit = frame

	frame = CreateFrame("Frame", nil, macroEditor.macroedit)
	frame:SetPoint("TOPLEFT", -10, 10)
	frame:SetPoint("BOTTOMRIGHT", 4, -20)
	frame:SetFrameLevel(macroEditor.macroedit.edit:GetFrameLevel()-1)
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)
	macroEditor.macroeditBG = frame

	fontStr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("BOTTOM", 0, 4)
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(M.Strings.MACRO_SAVE_INSTR)
	fontStr:Hide()
	macroEditor.macroedit.edit.text = fontStr

	frame = CreateFrame("EditBox", nil, macroEditor)
	frame:SetMultiLine(false)
	frame:SetNumeric(false)
	frame:SetAutoFocus(false)
	frame:SetTextInsets(5,5,5,5)
	frame:SetFontObject("GameFontHighlight")
	frame:SetJustifyH("CENTER")
	frame:SetPoint("TOPLEFT", macroEditor.macroicon, "TOPRIGHT", 5, 2)
	frame:SetPoint("BOTTOMRIGHT", macroEditor.iconbg, "TOP", 5, -35)
	frame:SetScript("OnShow", nameEdit_OnShow)
	frame:SetScript("OnHide", nameEdit_OnEditFocusLost)
	frame:SetScript("OnEditFocusGained", nameEdit_OnEditFocusGained)
	frame:SetScript("OnEditFocusLost", nameEdit_OnEditFocusLost)
	frame:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	frame:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	macroEditor.nameedit = frame

	fontStr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("CENTER")
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(M.Strings.MACRO_NAME)
	frame.text = fontStr

	frame = CreateFrame("Frame", nil, macroEditor.nameedit)
	frame:SetPoint("TOPLEFT", 0, 0)
	frame:SetPoint("BOTTOMRIGHT", 0, 0)
	frame:SetFrameLevel(macroEditor.nameedit:GetFrameLevel()-1)
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)

	frame = CreateFrame("Button", nil, macroEditor, "MacaroonButtonTemplate1")
	frame:SetWidth(1)
	frame:SetHeight(25)
	frame:SetPoint("TOPLEFT", macroEditor.nameedit, "BOTTOMLEFT", 0, -2)
	frame:SetPoint("TOPRIGHT", macroEditor.nameedit, "BOTTOMRIGHT", 0, -2)
	frame:SetScript("OnClick", macroEditorAddToVault_OnClick)
	frame:SetScript("OnHide", function(self) self.category:Hide() end)
	frame.text:SetText(M.Strings.MACRO_ADDTOVAULT)
	macroEditor.addtovault = frame

	frame = CreateFrame("Frame", nil, macroEditor.addtovault)
	frame:SetPoint("BOTTOMLEFT", macroEditor.addtovault, "BOTTOMLEFT", 0, -8)
	frame:SetPoint("TOPRIGHT", macroEditor.iconbg, "TOPRIGHT", 0, 0)
	frame:SetFrameLevel(macroEditor.macroedit.edit:GetFrameLevel()+1)
	frame:SetBackdrop({
		bgFile = "Interface\\FriendsFrame\\UI-Toast-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	frame:SetBackdropColor(0,0,0,1)
	frame:Hide()
	macroEditor.addtovault.category = frame

	frame = CreateFrame("EditBox", "$parentCatEdit", macroEditor.addtovault.category, "MacaroonEditBoxTemplate1")
	frame:SetWidth(200)
	frame:SetHeight(26)
	frame:SetTextInsets(7,3,0,0)
	frame.text:SetText("")
	frame:SetPoint("TOPLEFT", 7, -7)
	frame:SetScript("OnEditFocusGained", function(self) self.text:Hide() end)
	frame:SetScript("OnEditFocusLost", function(self) local text = self:GetText() if (text and #text > 0) then self.text:Hide() else self.text:Show() end end)
	frame:SetScript("OnShow", vaultCategoryEdit_OnShow)
	macroEditor.addtovault.category.edit = frame

	fontStr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("CENTER")
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(M.Strings.MACRO_CATEGORYEDIT)
	frame.text = fontStr

	frame = CreateFrame("EditBox", nil,  macroEditor.addtovault.category)
	frame:SetWidth(200)
	frame:SetHeight(26)
	frame:SetMultiLine(false)
	frame:SetNumeric(false)
	frame:SetAutoFocus(false)
	frame:SetTextInsets(5,5,5,5)
	frame:SetFontObject("GameFontHighlight")
	frame:SetJustifyH("CENTER")
	frame:SetPoint("BOTTOMLEFT", 7, 7)
	frame:SetScript("OnShow", vaultIndexEdit_OnShow)
	frame:SetScript("OnEditFocusGained", function(self) self.text:Hide() end)
	frame:SetScript("OnEditFocusLost", function(self) local text = self:GetText() if (text and #text > 0) then self.text:Hide() else self.text:Show() end end)
	frame:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	frame:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	macroEditor.addtovault.category.index = frame

	fontStr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("CENTER")
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(M.Strings.MACRO_INDEXEDIT)
	frame.text = fontStr

	frame = CreateFrame("Frame", nil, macroEditor.addtovault.category.index)
	frame:SetPoint("TOPLEFT", 0, 0)
	frame:SetPoint("BOTTOMRIGHT", 0, 0)
	frame:SetFrameLevel(macroEditor.addtovault.category.index:GetFrameLevel()-1)
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)

	frame = CreateFrame("Button", nil, macroEditor.addtovault.category, "MacaroonButtonTemplate1")
	frame:SetWidth(85)
	frame:SetHeight(25)
	frame:SetPoint("BOTTOMRIGHT", -7, 7)
	frame:SetScript("OnClick", function(self) self:GetParent():Hide() end)
	frame.text:SetText(M.Strings.CANCEL)
	macroEditor.addtovault.category.cancel = frame

	frame = CreateFrame("Button", nil, macroEditor.addtovault.category, "MacaroonButtonTemplate1")
	frame:SetWidth(85)
	frame:SetHeight(25)
	frame:SetPoint("TOPRIGHT", -7, -7)
	frame:SetScript("OnClick", vaultAdd_OnClick)
	frame.text:SetText(M.Strings.ADD)
	macroEditor.addtovault.category.add = frame

	frame = CreateFrame("Frame", nil, macroEditor.addtovault.category.add)
	frame:SetPoint("BOTTOMLEFT", macroEditor.addtovault, "BOTTOMLEFT", 0, -8)
	frame:SetPoint("TOPRIGHT", macroEditor.iconbg, "TOPRIGHT", 0, 0)
	frame:SetFrameLevel(macroEditor.addtovault.category.add:GetFrameLevel()+2)
	frame:EnableMouse(true)
	frame:SetBackdrop({
		bgFile = "Interface\\FriendsFrame\\UI-Toast-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	frame:SetBackdropColor(0,0,0,1)
	frame:Hide()
	macroEditor.addtovault.category.add.confirm = frame

	frame = CreateFrame("Button", nil, macroEditor.addtovault.category.add.confirm, "MacaroonButtonTemplate1")
	frame:SetWidth(60)
	frame:SetHeight(25)
	frame:SetPoint("LEFT", 7, 0)
	frame:SetScript("OnClick", function(self) self:GetParent():Hide() end)
	frame:Hide()
	macroEditor.addtovault.category.add.confirm.left = frame

	frame = CreateFrame("Button", nil, macroEditor.addtovault.category.add.confirm, "MacaroonButtonTemplate1")
	frame:SetWidth(60)
	frame:SetHeight(25)
	frame:SetPoint("RIGHT", -7, 0)
	frame:SetScript("OnClick", function(self) self:GetParent():Hide() end)
	frame:Hide()
	macroEditor.addtovault.category.add.confirm.right = frame

	fontStr = macroEditor.addtovault.category.add.confirm:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	fontStr:SetPoint("TOP", -10, 0)
	fontStr:SetPoint("BOTTOM", 10, 0)
	fontStr:SetPoint("LEFT", macroEditor.addtovault.category.add.confirm.left, "RIGHT", 10, 0)
	fontStr:SetPoint("RIGHT", macroEditor.addtovault.category.add.confirm.right, "LEFT", -10, 0)
	fontStr:SetJustifyH("CENTER")
	fontStr:SetJustifyV("CENTER")
	macroEditor.addtovault.category.add.confirm.message = fontStr

	frame = CreateFrame("EditBox", nil, macroEditor)
	frame:SetMultiLine(true)
	frame:SetMaxLetters(75)
	frame:SetNumeric(false)
	frame:SetAutoFocus(false)
	frame:SetJustifyH("CENTER")
	frame:SetJustifyV("CENTER")
	frame:SetTextInsets(5,5,5,5)
	frame:SetFontObject("GameFontNormalSmall")
	frame:SetPoint("TOPLEFT", macroEditor.nameedit, "TOPRIGHT", 2, 0)
	frame:SetPoint("BOTTOMRIGHT", macroEditor.iconbg, "BOTTOMRIGHT", -7, 21)
	frame:SetScript("OnShow", noteEdit_OnShow)
	frame:SetScript("OnHide", noteEdit_OnEditFocusLost)
	frame:SetScript("OnEditFocusGained", noteEdit_OnEditFocusGained)
	frame:SetScript("OnEditFocusLost", noteEdit_OnEditFocusLost)
	frame:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	frame:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	macroEditor.noteedit = frame

	fontStr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("CENTER")
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(M.Strings.MACRO_EDITNOTE)
	frame.text = fontStr

	frame = CreateFrame("Frame", nil, macroEditor.noteedit)
	frame:SetPoint("TOPLEFT", 0, 0)
	frame:SetPoint("BOTTOMRIGHT", macroEditor.iconbg, "BOTTOMRIGHT", -5, 5)
	frame:SetFrameLevel(macroEditor.noteedit:GetFrameLevel()-1)
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)
	frame.line = frame:CreateTexture(nil, "OVERLAY")
	frame.line:SetHeight(1)
	frame.line:SetPoint("LEFT", 8, -8)
	frame.line:SetPoint("RIGHT", -8, -8)
	frame.line:SetTexture(0.3, 0.3, 0.3)
	macroEditor.noteeditBG = frame

	frame = CreateFrame("CheckButton", "$parentUseNote", macroEditor, "MacaroonOptionRadioButtonTemplate")
	frame:SetID(0)
	frame:SetWidth(14)
	frame:SetHeight(14)
	frame:SetScript("OnShow", useNoteAsTooltip_OnShow)
	frame:SetScript("OnClick", useNoteAsTooltip_OnClick)
	frame.text = _G[frame:GetName().."Text"]
	frame.text:SetText(M.Strings.MACRO_USENOTE)
	local xoff = (frame:GetWidth()+frame.text:GetWidth())/2
	frame:SetPoint("BOTTOM", macroEditor.noteeditBG, "BOTTOM", -(xoff-5), 5)
	frame:SetFrameLevel(macroEditor.noteeditBG:GetFrameLevel()+1)
	macroEditor.usenote = frame

	frame = CreateFrame("EditBox", "$parentSliderEdit", macroEditor.actionedit, "MacaroonEditBoxTemplate3")
	frame:SetID(0)
	frame:SetWidth(33)
	frame:SetPoint("LEFT", macroEditor.actionedit.slider, "RIGHT", 1, 0)
	frame:SetScript("OnTabPressed", function(self) local num = tonumber(self:GetText()) if(num) then self.slider:SetValue(num) end self:ClearFocus() end)
	frame:SetScript("OnEnterPressed", function(self) local num = tonumber(self:GetText()) if(num) then self.slider:SetValue(num) end self:ClearFocus() end)
	frame.slider = macroEditor.actionedit.slider
	macroEditor.actionedit.slideredit = frame

	frame = CreateFrame("ScrollFrame", "$parentFlyoutKeyList", macroEditor.flyoutedit, "MacaroonScrollFrameTemplate2")
	frame:SetPoint("TOPLEFT", 15, -25)
	frame:SetPoint("BOTTOMRIGHT", -285, 110)
	frame:SetToplevel(true)
	frame.edit:SetFont("Fonts\\FRIZQT__.TTF", 12)
	frame.edit:SetWidth(136)
	frame.edit:SetSpacing(5)
	frame.edit:SetScript("OnTextChanged", function(self) flyoutData.keys = self:GetText() end)
	macroEditor.flyoutedit.keyedit = frame
	self.flyoutkeylistedit = frame.edit

	frame = CreateFrame("Frame", nil, macroEditor.flyoutedit.keyedit)
	frame:SetPoint("TOPLEFT", -10, 20)
	frame:SetPoint("BOTTOMRIGHT", 5, -10)
	frame:SetFrameLevel(macroEditor.flyoutedit.keyedit:GetFrameLevel()-1)
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)
	macroEditor.flyouteditBG = frame

	fontStr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("TOP", frame, "TOP", -5, -6)
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(M.Strings.FLYOUT_KEYS)
	macroEditor.flyoutedit.keyedit.text = fontStr

	frame = CreateFrame("ScrollFrame", "$parentFlyoutPostCmds", macroEditor.flyoutedit, "MacaroonScrollFrameTemplate2")
	frame:SetPoint("TOPLEFT", macroEditor.flyoutedit.keyedit, "BOTTOMLEFT", 0, -30)
	frame:SetPoint("BOTTOMRIGHT", -285, 15)
	frame:SetToplevel(true)
	frame.edit:SetFont("Fonts\\FRIZQT__.TTF", 12)
	frame.edit:SetWidth(136)
	frame.edit:SetSpacing(5)
	frame.edit:SetScript("OnTextChanged", function(self) self:SetText((self:GetText()):gsub("/", "#")) self:SetText((self:GetText()):gsub("^\n", "")) flyoutData.postCmds = self:GetText() end)
	macroEditor.flyoutedit.postcmds = frame
	self.flyoutpostcmdedit = frame.edit

	frame = CreateFrame("Frame", nil, macroEditor.flyoutedit.postcmds)
	frame:SetPoint("TOPLEFT", -10, 20)
	frame:SetPoint("BOTTOMRIGHT", 5, -10)
	frame:SetFrameLevel(macroEditor.flyoutedit.postcmds:GetFrameLevel()-1)
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)
	macroEditor.flyouteditPCBG = frame

	fontStr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("TOP", frame, "TOP", -5, -6)
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(M.Strings.FLYOUT_POSTCMDS)
	macroEditor.flyoutedit.postcmds.text = fontStr

	index, lastFrame = 1, nil

	while (M.Strings["BTN_EDIT_FLYOUT_"..index]) do

		frame = CreateFrame("CheckButton", "$parentFlyoutOpt"..index, macroEditor.flyoutedit, "MacaroonAdjustOptionButtonTemplate")
		frame:SetID(index)
		frame:SetWidth(200)
		frame:SetHeight(22)
		frame.adjBtn = true

		if (toggles["BTN_EDIT_FLYOUT_"..index]) then
			frame.toggle_func = function(self, button, down) self.pushed = 0 updateValues(M.CurrentObject, true, self.action) M.ObjectEditorUpdateData() end
		else
			frame.onclick_func = function(self, button, down) M.ButtonAdjOptions_OnClick(self, click, down, self.action, self.parent) end
		end

		frame.onshow_func = function(self) M.ButtonAdjOptions_Reset(self) end
		frame.onenter_func = function(self) if (SD.checkButtons[104]) then self.tooltip = M.Strings.ADJUSTBTN_BEGIN_TOOLTIP else self.tooltip = nil end end
		frame.text:SetText(M.Strings["BTN_EDIT_FLYOUT_"..index])
		frame.action = frame.text:GetText()
		frame.parent = self

		frame.add.onclick_func = function(self, button, down, parent) self.pushed = 0 updateValues(M.CurrentObject, 1, self.action) M.ObjectEditorUpdateData() end
		frame.add.onupdate_func = function(self, elapsed) adjoptButton_OnUpdate(self, elapsed, M.CurrentObject, true) end
		frame.add.action = frame.text:GetText()
		frame.add.editor = self

		frame.sub.onclick_func = function(self, button, down, parent) self.pushed = 0 updateValues(M.CurrentObject, -1, self.action) M.ObjectEditorUpdateData()end
		frame.sub.onupdate_func = function(self, elapsed) adjoptButton_OnUpdate(self, elapsed, M.CurrentObject, nil) end
		frame.sub.action = frame.text:GetText()
		frame.sub.editor = self

		tinsert(self.buttons, frame); tinsert(self.flyoutBtns, frame)

		if (lastFrame) then
			frame:SetPoint("TOPLEFT", lastFrame, "TOPLEFT", 0, -(frame:GetHeight()))
			frame:SetPoint("TOPRIGHT", lastFrame, "TOPRIGHT", 0, -(frame:GetHeight()))
		else
			frame:SetPoint("TOPLEFT", macroEditor.flyouteditBG, "TOPRIGHT", 1, -5)
			frame:SetPoint("TOPRIGHT", macroEditor.flyoutedit, "TOPRIGHT", -8, -5)
			frame.anchor = true
		end

		lastFrame = frame

		index = index + 1
	end

	frame = CreateFrame("Frame", nil, macroEditor.macrovault)
	frame:SetPoint("TOPLEFT", 0, -20)
	frame:SetPoint("BOTTOMRIGHT", macroEditor.macrovault, "TOPLEFT", 388, -90)
	frame:SetFrameLevel(macroEditor.macrovault:GetFrameLevel()+1)
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)
	macroEditor.macrovault.iconbg = frame

	frame = CreateFrame("CheckButton", "MacaroonMacroVaultFauxButton", macroEditor.macrovault, "MacaroonActionButtonTemplate")
	frame:SetID(0)
	frame:SetPoint("TOPLEFT", macroEditor.macrovault.iconbg, "TOPLEFT", 5, -5)
	frame:SetWidth(60)
	frame:SetHeight(60)
	frame:SetScript("OnClick", function(self) self:SetChecked(nil) end)
	frame:SetScript("OnDragStop", nil)
	frame:SetScript("OnDragStart", nil)
	frame:SetScript("OnReceiveDrag", nil)
	frame:Show()
	frame.hasAction = "Interface\\Buttons\\UI-EmptySlot"
	frame.noAction = "Interface\\Buttons\\UI-EmptySlot"
	frame.config = {
		type = "macro",
		macro = " ",
		macroIcon = 1,
		macroName = "",
		macroNote = "",
		macroUseNote = false,
	}
	local objects = M.GetChildrenAndRegions(frame)
	for k,v in pairs(objects) do
		local name = (v):gsub(frame:GetName(), "")
		frame[name:lower()] = _G[v]
	end
	frame:SetFrameLevel(macroEditor.macrovault.iconbg:GetFrameLevel()+1)
	frame.iconframe:SetFrameLevel(macroEditor.macrovault.iconbg:GetFrameLevel()+2)
	frame.iconframe:SetPoint("TOPLEFT", 7, -7)
	frame.iconframe:SetPoint("BOTTOMRIGHT", -7, 7)
	frame.iconframeicon:SetTexCoord(0, 1, 0, 1)
	M.SetButtonUpdate(frame, "macro")
	macroEditor.macrovault.macroicon = frame

	frame = CreateFrame("ScrollFrame", "$parentmacroEditor.macrovault", macroEditor.macrovault, "MacaroonScrollFrameTemplate2")
	frame:SetPoint("TOPLEFT", macroEditor.macrovault.iconbg, "BOTTOMLEFT", 10, -10)
	frame:SetPoint("BOTTOMRIGHT", macroEditor.macrovault, "BOTTOMLEFT", 383, 20)
	frame.edit:SetWidth(350)
	frame.edit:SetScript("OnEditFocusGained", function(self) if (not selectedMacro) then self:ClearFocus() else self.text:Show() end end)
	frame.edit:SetScript("OnEditFocusLost", function(self) self.text:Hide() end)
	frame.edit:SetScript("OnTextChanged", function(self) if (currVaultMacro) then currVaultMacro[1] = self:GetText() end end)
	macroEditor.macrovault.macroedit = frame

	frame = CreateFrame("Frame", nil, macroEditor.macrovault.macroedit)
	frame:SetPoint("TOPLEFT", -10, 10)
	frame:SetPoint("BOTTOMRIGHT", 4, -20)
	frame:SetFrameLevel(macroEditor.macrovault.macroedit.edit:GetFrameLevel()-1)
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)
	macroEditor.macrovault.macroeditBG = frame

	fontStr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("BOTTOM", 0, 4)
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(M.Strings.MACRO_SAVE_INSTR)
	fontStr:Hide()
	macroEditor.macrovault.macroedit.edit.text = fontStr

	frame = CreateFrame("EditBox", nil, macroEditor.macrovault)
	frame:SetMultiLine(false)
	frame:SetNumeric(false)
	frame:SetAutoFocus(false)
	frame:SetTextInsets(5,5,5,5)
	frame:SetFontObject("GameFontHighlight")
	frame:SetJustifyH("CENTER")
	frame:SetPoint("TOPLEFT", macroEditor.macrovault.macroicon, "TOPRIGHT", 1, -2)
	frame:SetPoint("BOTTOMRIGHT", macroEditor.macrovault.iconbg, "TOP", 5, -35)
	frame:SetScript("OnShow", nil)
	frame:SetScript("OnHide", nil)
	frame:SetScript("OnEditFocusGained", function(self) if (not selectedMacro) then self:ClearFocus() else self.text:Hide() end end)
	frame:SetScript("OnEditFocusLost", function(self) local text = self:GetText() if (text and #text >0) then self.text:Hide() else self.text:Show() end end)
	frame:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	frame:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	frame:SetScript("OnTextChanged", function(self)
								local text = self:GetText()
								if (text and #text >0) then
									if (currVaultMacro) then
										currVaultMacro[3] = self:GetText()
									end
									self.text:Hide()
								else
									self.text:Show()
								end end)
	macroEditor.macrovault.nameedit = frame

	fontStr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("CENTER")
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(M.Strings.MACRO_NAME)
	frame.text = fontStr

	frame = CreateFrame("Frame", nil, macroEditor.macrovault.nameedit)
	frame:SetPoint("TOPLEFT", 0, 0)
	frame:SetPoint("BOTTOMRIGHT", 0, 0)
	frame:SetFrameLevel(macroEditor.macrovault.nameedit:GetFrameLevel()-1)
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)

	frame = CreateFrame("Button", nil, macroEditor.macrovault, "MacaroonButtonTemplate1")
	frame:SetWidth(1)
	frame:SetHeight(25)
	frame:SetPoint("TOPLEFT", macroEditor.macrovault.nameedit, "BOTTOMLEFT", 0, -2)
	frame:SetPoint("TOPRIGHT", macroEditor.macrovault.nameedit, "BOTTOMRIGHT", 0, -2)
	frame:SetScript("OnClick", macroEditorAddToVault_OnClick)
	frame:SetScript("OnHide", function(self) self.category:Hide() end)
	frame.text:SetText(M.Strings.MACRO_ADDTOVAULT)
	macroEditor.macrovault.addtovault = frame

	frame = CreateFrame("Frame", nil, macroEditor.macrovault.addtovault)
	frame:SetPoint("BOTTOMLEFT", macroEditor.macrovault.addtovault, "BOTTOMLEFT", 0, -8)
	frame:SetPoint("TOPRIGHT", macroEditor.macrovault.iconbg, "TOPRIGHT", 0, 0)
	frame:SetFrameLevel(macroEditor.macrovault.macroedit.edit:GetFrameLevel()+1)
	frame:SetBackdrop({
		bgFile = "Interface\\FriendsFrame\\UI-Toast-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	frame:SetBackdropColor(0,0,0,1)
	frame:Hide()
	macroEditor.macrovault.addtovault.category = frame

	frame = CreateFrame("EditBox", "$parentCatEdit", macroEditor.macrovault.addtovault.category, "MacaroonEditBoxTemplate1")
	frame:SetWidth(200)
	frame:SetHeight(26)
	frame:SetTextInsets(7,3,0,0)
	frame.text:SetText("")
	frame:SetPoint("TOPLEFT", 7, -7)
	frame:SetScript("OnShow", macroVaultCategoryEdit_OnShow)
	frame:SetScript("OnEditFocusGained", function(self) self.text:Hide() end)
	frame:SetScript("OnEditFocusLost", function(self) local text = self:GetText() if (text and #text > 0) then self.text:Hide() else self.text:Show() end end)
	macroEditor.macrovault.addtovault.category.edit = frame

	fontStr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("CENTER")
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(M.Strings.MACRO_CATEGORYEDIT)
	frame.text = fontStr

	frame = CreateFrame("EditBox", nil,  macroEditor.macrovault.addtovault.category)
	frame:SetWidth(200)
	frame:SetHeight(26)
	frame:SetMultiLine(false)
	frame:SetNumeric(false)
	frame:SetAutoFocus(false)
	frame:SetTextInsets(5,5,5,5)
	frame:SetFontObject("GameFontHighlight")
	frame:SetJustifyH("CENTER")
	frame:SetPoint("BOTTOMLEFT", 7, 7)
	frame:SetScript("OnShow", macroVaultIndexEdit_OnShow)
	frame:SetScript("OnEditFocusGained",  function(self) self.text:Hide() end)
	frame:SetScript("OnEditFocusLost", function(self) local text = self:GetText() if (text and #text > 0) then self.text:Hide() else self.text:Show() end end)
	frame:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	frame:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	macroEditor.macrovault.addtovault.category.index = frame

	fontStr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("CENTER")
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(M.Strings.MACRO_INDEXEDIT)
	frame.text = fontStr

	frame = CreateFrame("Frame", nil, macroEditor.macrovault.addtovault.category.index)
	frame:SetPoint("TOPLEFT", 0, 0)
	frame:SetPoint("BOTTOMRIGHT", 0, 0)
	frame:SetFrameLevel(macroEditor.macrovault.addtovault.category.index:GetFrameLevel()-1)
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)

	frame = CreateFrame("Button", nil, macroEditor.macrovault.addtovault.category, "MacaroonButtonTemplate1")
	frame:SetWidth(85)
	frame:SetHeight(25)
	frame:SetPoint("BOTTOMRIGHT", -7, 7)
	frame:SetScript("OnClick", function(self) self:GetParent():Hide() end)
	frame.text:SetText(M.Strings.CANCEL)
	macroEditor.macrovault.addtovault.category.cancel = frame

	frame = CreateFrame("Button", nil, macroEditor.macrovault.addtovault.category, "MacaroonButtonTemplate1")
	frame:SetWidth(85)
	frame:SetHeight(25)
	frame:SetPoint("TOPRIGHT", -7, -7)
	frame:SetScript("OnClick", macroVaultAdd_OnClick)
	frame.text:SetText(M.Strings.ADD)
	macroEditor.macrovault.addtovault.category.add = frame

	frame = CreateFrame("Frame", nil, macroEditor.macrovault.addtovault.category.add)
	frame:SetPoint("BOTTOMLEFT", macroEditor.macrovault.addtovault, "BOTTOMLEFT", 0, -8)
	frame:SetPoint("TOPRIGHT", macroEditor.macrovault.iconbg, "TOPRIGHT", 0, 0)
	frame:SetFrameLevel(macroEditor.macrovault.addtovault.category.add:GetFrameLevel()+2)
	frame:EnableMouse(true)
	frame:SetBackdrop({
		bgFile = "Interface\\FriendsFrame\\UI-Toast-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	frame:SetBackdropColor(0,0,0,1)
	frame:Hide()
	macroEditor.macrovault.addtovault.category.add.confirm = frame

	frame = CreateFrame("Button", nil, macroEditor.macrovault.addtovault.category.add.confirm, "MacaroonButtonTemplate1")
	frame:SetWidth(60)
	frame:SetHeight(25)
	frame:SetPoint("LEFT", 7, 0)
	frame:SetScript("OnClick", function(self) self:GetParent():Hide() end)
	frame:Hide()
	macroEditor.macrovault.addtovault.category.add.confirm.left = frame

	frame = CreateFrame("Button", nil, macroEditor.macrovault.addtovault.category.add.confirm, "MacaroonButtonTemplate1")
	frame:SetWidth(60)
	frame:SetHeight(25)
	frame:SetPoint("RIGHT", -7, 0)
	frame:SetScript("OnClick", function(self) self:GetParent():Hide() end)
	frame:Hide()
	macroEditor.macrovault.addtovault.category.add.confirm.right = frame

	fontStr = macroEditor.macrovault.addtovault.category.add.confirm:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	fontStr:SetPoint("TOP", -10, 0)
	fontStr:SetPoint("BOTTOM", 10, 0)
	fontStr:SetPoint("LEFT", macroEditor.macrovault.addtovault.category.add.confirm.left, "RIGHT", 10, 0)
	fontStr:SetPoint("RIGHT", macroEditor.macrovault.addtovault.category.add.confirm.right, "LEFT", -10, 0)
	fontStr:SetJustifyH("CENTER")
	fontStr:SetJustifyV("CENTER")
	macroEditor.macrovault.addtovault.category.add.confirm.message = fontStr

	frame = CreateFrame("EditBox", nil, macroEditor.macrovault)
	frame:SetMultiLine(true)
	frame:SetMaxLetters(75)
	frame:SetNumeric(false)
	frame:SetAutoFocus(false)
	frame:SetJustifyH("CENTER")
	frame:SetJustifyV("CENTER")
	frame:SetTextInsets(5,5,5,5)
	frame:SetFontObject("GameFontNormalSmall")
	frame:SetPoint("TOPLEFT", macroEditor.macrovault.nameedit, "TOPRIGHT", 2, 0)
	frame:SetPoint("BOTTOMRIGHT", macroEditor.macrovault.iconbg, "BOTTOMRIGHT", -7, 21)
	frame:SetScript("OnShow", nil)
	frame:SetScript("OnHide", nil)
	frame:SetScript("OnEditFocusGained", function(self) if (not selectedMacro) then self:ClearFocus() else self.text:Hide() end end)
	frame:SetScript("OnEditFocusLost", function(self) local text = self:GetText() if (text and #text >0) then self.text:Hide() else self.text:Show() end end)
	frame:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	frame:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
	frame:SetScript("OnTextChanged", function(self)
								local text = self:GetText()
								if (text and #text >0) then
									if (currVaultMacro) then
										currVaultMacro[4] = self:GetText()
									end
									self.text:Hide()
								else
									self.text:Show()
								end end)
	macroEditor.macrovault.noteedit = frame

	fontStr = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
	fontStr:SetPoint("CENTER")
	fontStr:SetJustifyH("CENTER")
	fontStr:SetText(M.Strings.MACRO_EDITNOTE)
	frame.text = fontStr

	frame = CreateFrame("Frame", nil, macroEditor.macrovault.noteedit)
	frame:SetPoint("TOPLEFT", 0, 0)
	frame:SetPoint("BOTTOMRIGHT", macroEditor.macrovault.iconbg, "BOTTOMRIGHT", -5, 5)
	frame:SetFrameLevel(macroEditor.macrovault.noteedit:GetFrameLevel()-1)
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },})
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	frame:SetBackdropColor(0,0,0,0.5)
	frame.line = frame:CreateTexture(nil, "OVERLAY")
	frame.line:SetHeight(1)
	frame.line:SetPoint("LEFT", 8, -8)
	frame.line:SetPoint("RIGHT", -8, -8)
	frame.line:SetTexture(0.3, 0.3, 0.3)
	macroEditor.macrovault.noteeditBG = frame

	frame = CreateFrame("CheckButton", "$parentUseNote", macroEditor.macrovault, "MacaroonOptionRadioButtonTemplate")
	frame:SetID(0)
	frame:SetWidth(14)
	frame:SetHeight(14)
	frame:SetScript("OnClick", function(self)
						if (currVaultMacro) then
							if (self:GetChecked()) then
								currVaultMacro[5] = true
							else
								currVaultMacro[5] = false
							end
						end end)
	frame.text = _G[frame:GetName().."Text"]
	frame.text:SetText(M.Strings.MACRO_USENOTE)
	local xoff = (frame:GetWidth()+frame.text:GetWidth())/2
	frame:SetPoint("BOTTOM", macroEditor.macrovault.noteeditBG, "BOTTOM", -(xoff-5), 5)
	frame:SetFrameLevel(macroEditor.macrovault.noteeditBG:GetFrameLevel()+1)
	macroEditor.macrovault.usenote = frame
	--[[

	function M.BuildAnchorOptions(self)

	frame = CreateFrame("CheckButton", "$parentCheck301", self, "MacaroonOptionCBTemplate")
	frame:SetID(301)
	frame.text:SetText(M.Strings.CLICK_ANCHOR)
	frame:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -8)
	self.clickanchor = frame

	frame = CreateFrame("CheckButton", "$parentCheck302", self, "MacaroonOptionCBTemplate")
	frame:SetID(302)
	frame.text:SetText(M.Strings.MOUSE_ANCHOR)
	frame:SetPoint("LEFT", self.clickanchor, "RIGHT", 85, 0)
	self.mouseanchor = frame

	frame = CreateFrame("EditBox", "$parentAnchorChild", self, "MacaroonEditBoxTemplate1")
	frame:SetWidth(90)
	frame:SetHeight(20)
	frame:SetTextInsets(7,3,0,0)
	frame.text:SetText(M.Strings.ANCHOR_CHILD)
	frame:SetPoint("TOPLEFT", self.clickanchor, "BOTTOMLEFT", 0, -5)
	frame:SetScript("OnTextChanged", anchorChild_OnTextChanged)
	frame:SetScript("OnShow", anchorChild_OnShow)
	frame:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
	self.anchorchild = frame

	frame = CreateFrame("EditBox", "$parentDelayEdit", self, "MacaroonEditBoxTemplate2")
	frame:SetWidth(54)
	frame:SetHeight(20)
	frame:SetTextInsets(7,3,0,0)
	frame:SetJustifyH("CENTER")
	frame.text:SetText(M.Strings.ANCHOR_DELAY)
	frame:SetPoint("LEFT", self.anchorchild, "RIGHT", 55, 0)
	frame:SetScript("OnTextChanged", delayEdit_OnTextChanged)
	frame:SetScript("OnShow", delayEdit_OnShow)
	frame:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
	self.delay = frame

	self.clickanchor.mouseanchor = self.mouseanchor
	self.clickanchor.anchorchild = self.anchorchild
	self.clickanchor.delay = self.delay

	self.mouseanchor.clickanchor = self.clickanchor
	self.mouseanchor.anchorchild = self.anchorchild
	self.mouseanchor.delay = self.delay


	--]]



	macroEditor.macroiconlist.buttons = {}; count = 0; x = 21; y = -19

	for i=1,108 do

		frame = CreateFrame("CheckButton", nil, macroEditor.macroiconlist, "MacaroonMacroButtonTemplate")
		frame:SetID(i)
		frame:SetFrameLevel(macroEditor.macroiconlist:GetFrameLevel()+2)
		frame:SetScript("OnEnter", function(self) self.fl = self:GetFrameLevel() self:SetFrameLevel(self.fl+1) self:GetNormalTexture():SetPoint("TOPLEFT", -7, 7) self:GetNormalTexture():SetPoint("BOTTOMRIGHT", 9, -9) end)
		frame:SetScript("OnLeave", function(self) self:SetFrameLevel(self.fl) self:GetNormalTexture():SetPoint("TOPLEFT", 1, -1) self:GetNormalTexture():SetPoint("BOTTOMRIGHT", 1, -1) end)
		frame.onclick_func = function(self, button, down)
							if (button == "LeftButton" and M.CurrentObject) then
								M.CurrentObject.config.macroIcon = self.texture; macroEditUpdateIcon(); M.SetButtonType(M.CurrentObject)
							end
							self:SetFrameLevel(self.fl-1)
							self:GetNormalTexture():SetWidth(29)
							self:GetNormalTexture():SetHeight(29)
							self.click = true
							self.elapsed = 0
							self:GetParent():Hide()
							self:SetChecked(nil)
					   end

		count = count + 1

		frame:SetPoint("CENTER", macroEditor.macroiconlist, "TOPLEFT", x, y)

		if (count == 12) then
			x = 21; y = y - 33; count = 0
		else
			x = x + 35
		end

		tinsert(macroEditor.macroiconlist.buttons, frame)

	end
end

local function buttonDataUpdate(editor, object)

	if (not editor:IsVisible()) then
		return
	end

	if (editor.generalBtns) then

		local count, value, height, lastFrame = 0

		for k,v in pairs(editor.generalBtns) do
			if (v.adjBtn and v:IsShown()) then
				count = count + 1
			end
		end

		height = (editor.options:GetHeight()-65)/count

		for k,v in ipairs(editor.generalBtns) do

			value = updateValues(object, nil, v.action)

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

	if (editor.generalChks) then

		local count, value, color1, color2, height, lastFrame = 0

		for k,v in pairs(editor.generalChks) do
			if (v:IsShown()) then
				count = count + 1
			end
		end

		height = (editor.options:GetHeight()-60)/count

		for k,v in ipairs(editor.generalChks) do

			value, color1, color2 = updateValues(object, nil, v.action)

			if (value == "---") then
				v:SetChecked(nil)
			elseif (value) then
				v:SetChecked(1)
			else
				v:SetChecked(nil)
			end

			if (color1) then
				v.swatch1:GetNormalTexture():SetVertexColor((";"):split(color1))
			else
				v.swatch1:GetNormalTexture():SetVertexColor(0,0,0)
			end

			if (color2) then
				v.swatch2:GetNormalTexture():SetVertexColor((";"):split(color2))
			else
				v.swatch2:GetNormalTexture():SetVertexColor(0,0,0)
			end

			if (v:IsShown()) then
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

	if (editor.advancedBtns) then

		local count, value, height, lastFrame = 0

		for k,v in pairs(editor.advancedBtns) do
			if (v.adjBtn and v:IsShown()) then
				count = count + 1
			end
		end

		height = (editor.options:GetHeight()-40)/count

		for k,v in ipairs(editor.advancedBtns) do

			value = updateValues(object, nil, v.action)

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

	macroEditUpdateIcon(nil, object)

	macroEdit_OnShow(macroEditor.macroedit.edit, object)

	nameEdit_OnShow(macroEditor.nameedit, object)

	noteEdit_OnShow(macroEditor.noteedit, object)

	useNoteAsTooltip_OnShow(macroEditor.usenote, object)

	M.ActionEditSlider_OnShow(macroEditor.actionedit.slider, object, true)

	macroEditor.addtovault.category:Hide()

	if (macroEditor.flyoutedit:IsVisible()) then
		M.FlyoutEditor_Update(editor, object)
	end

	if (macroEditor.macroiconlist:IsVisible()) then
		M.MacroIconListUpdate()
	end
end

function M.ObjectEditorUpdateData(object)

	if (not object) then
		object = M.CurrentObject
	end

	if (object) then

		local editor = object.editor

		if (not editor and object == MBD) then
			editor = M.ButtonEditor
		elseif (not editor) then
			return
		end

		if (editor.height) then
			MacaroonObjectEditor:SetHeight(editor.height)
		end

		for k,v in pairs(M.ObjectDataUpdates) do
			if (v[1] == editor) then
				editor.CurrentObject = object
				editor:Show()
				v[2](editor, object)
			else
				v[1]:Hide()
			end
		end

		M.ObjectListScrollFrameUpdate()
	end
end

function M.OptionsGeneral_ModifyReset()
	if (modifyType > 1) then
		modifyType = 1; updateModifyOptions(buttonEditor)
	end
end

function M.ObjectEditorShow(parent, frame, point, relPoint, x, y, scale, alpha, done)

	if (done) then
		MacaroonObjectEditor.done:Show()
	else
		MacaroonObjectEditor.done:Hide()
	end

	MacaroonObjectEditor.grow = true
	MacaroonObjectEditor.shrink = false
	MacaroonObjectEditor.scale = scale
	MacaroonObjectEditor:SetParent(parent)
	MacaroonObjectEditor:SetBackdropBorderColor(0.7, 0.7, 0.7, alpha)
	MacaroonObjectEditor:SetBackdropColor(0,0,0,alpha)
	MacaroonObjectEditor:ClearAllPoints()
	MacaroonObjectEditor:SetPoint(point, frame, relPoint, x, y)
	MacaroonObjectEditor:SetScale(scale)
	MacaroonObjectEditor:Show()
end

function M.ObjectEditorHide()

	MacaroonObjectEditor:ClearAllPoints()
	MacaroonObjectEditor:SetPoint("CENTER", MacaroonPanelMover, "CENTER")
	MacaroonObjectEditor.grow = false
	MacaroonObjectEditor.shrink = true

end

function M.ObjectEditor_OnLoad(self)

	self:SetBackdropBorderColor(0.7, 0.7, 0.7);
	self:SetBackdropColor(0,0,0,1);
	self:RegisterForDrag("LeftButton", "RightButton")
	self.bottom = 0

	self:SetHeight(M.EditorHeight)

	M.ButtonEditor = self.btnEditor
	M.ButtonEditor.height = M.EditorHeight

end

function M.ObjectEditor_OnUpdate(self, elasped)

	if (self.grow) then

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

	elseif (self.shrink) then

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
end

function M.MacroVault_OnClick(self)

	if (self.type == "mvopen") then

		self.bareditorW = MacaroonBarEditor:GetWidth()
		self.objeditorW = MacaroonObjectEditor:GetWidth()

		if (MacaroonBarEditor:IsVisible()) then
			MacaroonBarEditor:SetWidth(self.bareditorW + 120)
		end

		MacaroonObjectEditor:SetWidth(self.objeditorW + 120)

		self.parent.flyoutBtn:Hide()
		self.parent.macroedit.macrovault:Show()
		self.text:SetText(M.Strings.DONE)
		self.type = "done"

		resetFlyoutData()

		--MacaroonObjectEditor.done:Hide()
	else

		if (self.bareditorW and MacaroonBarEditor:IsVisible()) then
			MacaroonBarEditor:SetWidth(self.bareditorW)
		end

		if (self.objeditorW) then
			MacaroonObjectEditor:SetWidth(self.objeditorW)
		end

		self.parent.flyoutBtn:Show()
		self.parent.macroedit.macrovault:Hide()
		self.text:SetText(M.Strings.MACRO_VAULT)
		self.type = "mvopen"

		--MacaroonObjectEditor.done:Show()
	end

end

function M.VaultList_OnLoad(self)

	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	self:SetBackdropColor(0,0,0,0.5)
	self:GetParent().backdrop = self

	self:SetHeight(self:GetParent():GetHeight()-100)
end

function M.MacroVaultScrollFrame_OnLoad(self)

	self.offset = 0
	self.scrollbar = _G[self:GetName().."ScrollBar"]
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

				if (self.index == "realm") then

					if (self.text == expandedRealm) then
						expandedRealm = nil; expandedChar = nil; selectedMacro = nil
					else
						expandedRealm = self.text
					end

				elseif (self.index == "char") then

					if (self.text == expandedChar) then
						expandedChar = nil; selectedMacro = nil
					else
						expandedChar = self.text
					end

				elseif (self.index == "macro") then

					if (self.text == selectedMacro) then
						selectedMacro = nil
					else
						selectedMacro = self.text
					end
				end

				M.MacroVaultScrollFrameUpdate()
			end)

		button:SetScript("OnEnter",
			function(self)

			end)

		button:SetScript("OnLeave",
			function(self)

			end)

		fontString = button:CreateFontString(button:GetName().."Index", "ARTWORK", "GameFontNormalSmall")
		fontString:SetPoint("TOPLEFT", button, "TOPLEFT", 5, 0)
		fontString:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 0)
		fontString:SetJustifyH("LEFT")
		button.name = fontString

		button:SetID(i)
		button:SetFrameLevel(self:GetFrameLevel()+2)
		button:SetNormalTexture("")

		button.toggle:SetHitRectInsets(button.toggle:GetWidth()/2, button.toggle:GetWidth()/2, button.toggle:GetHeight()/2, button.toggle:GetHeight()/2)

		if (not lastButton) then
			button:SetPoint("TOPLEFT", 5, -5)
			button:SetPoint("TOPRIGHT", -25, -5)
			self.topbutton = button
			lastButton = button
		else
			button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, 0)
			button:SetPoint("TOPRIGHT", lastButton, "BOTTOMRIGHT", 0, 0)
			lastButton = button
		end

	end

	M.MacroVaultScrollFrameUpdate()

end

function M.MacroVaultScrollFrameUpdate()

	if (not macroEditor or not macroEditor.macrovault:IsVisible()) then return end

	local frame = macroEditor.macrovault.vaultlist.scrollframe
	local macrobutton = MacaroonMacroVaultFauxButton

	currVaultMacro = nil

	macroEditor.macrovault.macroedit.edit:SetText("")
	macroEditor.macrovault.nameedit:SetText("")
	macroEditor.macrovault.noteedit:SetText("")
	macroEditor.macrovault.usenote:SetChecked(nil)

	macrobutton.macrospell = nil
	macrobutton.spellID = nil
	macrobutton.macroitem = nil
	macrobutton.macroshow = nil
	macrobutton.macrospecial = nil
	macrobutton.macroparse = " "
	macrobutton.config.macro = " "
	macrobutton.iconframeicon:SetTexCoord(0,1,0,1)
	macrobutton.update(macrobutton)

	if (expandedRealm == "Main Vault") then
		macroEditor.macrovault.addtovault:Disable()
	else
		macroEditor.macrovault.addtovault:Enable()
	end

	if (selectedMacro == nil) then

		macroEditor.macrovault.options.copy:Disable()
		macroEditor.macrovault.addtovault:Disable()
		macroEditor.macrovault.usenote:Disable()

		if (expandedChar == nil) then
			macroEditor.macrovault.options.delete:Disable()
			macroEditor.macrovault.options.delete.text:SetText(format(M.Strings.MACRO_DELETEFROMVAULT, M.Strings.TYPES_1))
			macroEditor.macrovault.options.delete.type = "delmacro"
		else
			macroEditor.macrovault.options.delete:Enable()
			macroEditor.macrovault.options.delete.text:SetText(format(M.Strings.MACRO_DELETEFROMVAULT, M.Strings.CATEGORY))
			macroEditor.macrovault.options.delete.type = "delcategory"
		end
	else
		macroEditor.macrovault.options.copy:Enable()
		macroEditor.macrovault.options.delete:Enable()
		macroEditor.macrovault.options.delete.text:SetText(format(M.Strings.MACRO_DELETEFROMVAULT, M.Strings.TYPES_1))
		macroEditor.macrovault.options.delete.type = "delmacro"
		macroEditor.macrovault.usenote:Enable()
	end

	local dataOffset, count, data, button, index, text, color = FauxScrollFrame_GetOffset(frame), 1, {}

	for realm in next,MacaroonMacroVault do

		data[count] = "realm;"..realm; count = count + 1

		if (realm == expandedRealm) then

			for character in next,MacaroonMacroVault[realm] do

				data[count] = "char;"..character; count = count + 1

				if (character == expandedChar) then

					for macro in next,MacaroonMacroVault[realm][character] do

						data[count] = "macro;"..macro; count = count + 1

					end
				end
			end
		end
	end

	frame:Show(); frame.buttonH = frame:GetHeight()/numShown

	for i=1,numShown do

		button = _G[frame:GetName().."Button"..i]
		button:SetChecked(nil)
		button:SetHeight(frame.buttonH)
		button.toggle:SetButtonState("NORMAL")

		count = dataOffset + i

		if (data[count]) then

			index, text = (";"):split(data[count])

			color = ""

			if (index and text) then

				if (text == expandedRealm or text == expandedChar) then
					button.toggle:SetButtonState("PUSHED", 1)
					if (text == expandedChar) then
						button:SetChecked(1)
					end
				end

				if (text == selectedMacro) then

					button:SetChecked(1)

					if (expandedRealm and expandedChar and selectedMacro) then

						currVaultMacro = MacaroonMacroVault[expandedRealm][expandedChar][selectedMacro]

						if (currVaultMacro) then

							macroEditor.macrovault.macroedit.edit:SetText(currVaultMacro[1] or "")
							macroEditor.macrovault.nameedit:SetText(currVaultMacro[3] or "")
							macroEditor.macrovault.noteedit:SetText(currVaultMacro[4] or "")
							macroEditor.macrovault.usenote:SetChecked(currVaultMacro[5])

							if (macrobutton) then
								macrobutton.macroparse = currVaultMacro[1]
								macrobutton.config.macro = currVaultMacro[1]
								macrobutton.update(macrobutton)
							end
						end
					end
				end

				if (index == "realm") then
					button.toggle:Show()
					button.name:SetFont(STANDARD_TEXT_FONT, 12)
				elseif (index == "char") then
					button.toggle:Show()
					button.name:SetFont(STANDARD_TEXT_FONT, 10)
					color = "  |cffffffff"
				else
					button.toggle:Hide()
					button.name:SetFont(STANDARD_TEXT_FONT, 10)
					color = "   |cff00ff00"
				end

				button.index = index
				button.text = text

				if (#color > 0) then
					button.name:SetText(color..text.."|r")
				else
					button.name:SetText(text)
				end

				button:Enable()
				button:Show()
			end
		else

			button:Hide()
		end
	end

	FauxScrollFrame_Update(frame, #data, numShown, 2)

	if (frame.scrollbar:IsVisible()) then
		frame.topbutton:SetPoint("TOPRIGHT", -20, -5)
	else
		frame.topbutton:SetPoint("TOPRIGHT", -5, -5)
	end

end

function M.MacroVaultConfirmYes_OnClick(self)

	if (self.type == "copy") then

		local button = M.CurrentObject

		if (button) then

			button.config.macro = currVaultMacro[1]
			button.config.macroIcon = currVaultMacro[2]
			button.config.macroName = currVaultMacro[3]
			button.config.macroNote = currVaultMacro[4]
			button.config.macroUseNote = currVaultMacro[5]

			M.SetButtonType(button)
		end
	end

	if (self.type == "delmacro") then

		if (expandedRealm and expandedChar and selectedMacro) then
			MacaroonMacroVault[expandedRealm][expandedChar][selectedMacro] = nil
			M.MacroVaultScrollFrameUpdate()
		end
	end

	if (self.type == "delcategory") then

		if (expandedRealm and expandedChar) then
			MacaroonMacroVault[expandedRealm][expandedChar] = nil
			M.MacroVaultScrollFrameUpdate()
		end
	end

	self.parent:GetParent().options:Show()
	self.parent:Hide()
end

function M.MacroVaultCopy_OnClick(self)

	self.parent:GetParent().confirm.yes.type = self.type

	self.parent:GetParent().confirm:Show()
	self.parent:Hide()
end

function M.MacroVaultDelete_OnClick(self)

	self.parent:GetParent().confirm.yes.type = self.type

	self.parent:GetParent().confirm:Show()
	self.parent:Hide()
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Macaroon") then

		SD = MacaroonSavedState; MBD = MacaroonButtonDefaults

		hooksecurefunc("SpellButton_OnModifiedClick", modifiedSpellClick)
		hooksecurefunc("HandleModifiedItemClick", modifiedItemClick)
		hooksecurefunc("SpellBookCompanionButton_OnModifiedClick", modifiedCompanionClick)
		hooksecurefunc("OpenStackSplitFrame", openStackSplitFrame)

		player = UnitClass("player")

		GameMenuFrame:HookScript("OnShow", function(self) if (editMode) then HideUIPanel(self) M.ObjectEdit() end end)

		for k,v in pairs(M.Points) do
			tinsert(anchorPoints, {k,v})
		end

		table.sort(anchorPoints, function(a,b) return a[2]>b[2] end)

	elseif (event == "PLAYER_ENTERING_WORLD" and not pew) then

		tinsert(M.ObjectDataUpdates, { M.ButtonEditor, buttonDataUpdate })

		pew = true

	elseif (event == "ACTIONBAR_SHOWGRID") then

		if (editMode) then
			for k,v in pairs(M.EditFrames) do
				if (v:IsVisible()) then
					v:GetParent().editmode = nil
					v.showgrid = true
					v:Hide()
				end
			end
		end

	elseif (event == "ACTIONBAR_HIDEGRID") then

		if (editMode) then
			for k,v in pairs(M.EditFrames) do
				if (v.showgrid) then
					v:Show()
					v.showgrid = nil
					v:GetParent().editmode = true
				end
			end
		end
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ACTIONBAR_SHOWGRID")
frame:RegisterEvent("ACTIONBAR_HIDEGRID")
