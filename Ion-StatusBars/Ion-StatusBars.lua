--Ion Status Bars, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local ION, GDB, CDB, PEW = Ion

ION.STATUSIndex = {}

local STATUSIndex = ION.STATUSIndex

local EDITIndex, OBJEDITOR = ION.EDITIndex, ION.OBJEDITOR

local statusbarsGDB, statusbarsCDB, statusbtnsGDB, statusbtnsCDB

local STATUS = setmetatable({}, { __index = CreateFrame("Button") })

local STORAGE = CreateFrame("Frame", nil, UIParent)

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

local LSTAT = LibStub("AceLocale-3.0"):GetLocale("IonStatusBars")

IonStatusGDB = {
	statusbars = {},
	statusbtns = {},
	firstRun = true,
}

IonStatusCDB = {
	statusbars = {},
	statusbtns = {},
	autoWatch = 0,
}

local format = string.format

local GetParentKeys = ION.GetParentKeys

local defGDB, defCDB = CopyTable(IonStatusGDB), CopyTable(IonStatusCDB)

local tsort = table.sort

local GetMirrorTimerProgress = _G.GetMirrorTimerProgress
local UnitCastingInfo = _G.UnitCastingInfo
local GetTime = _G.GetTime
local	UIDropDownMenu_AddButton = UIDropDownMenu_AddButton
local	UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
local MirrorTimerColors = MirrorTimerColors
local CASTING_BAR_ALPHA_STEP = CASTING_BAR_ALPHA_STEP
local CASTING_BAR_FLASH_STEP = CASTING_BAR_FLASH_STEP
local CASTING_BAR_HOLD_TIME = CASTING_BAR_HOLD_TIME

local BarTextures = {
	[1] = { "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Default_1", "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Default_2", "Default" },
	[2] = { "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Contrast_1", "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Contrast_2", "Contrast" },
	-- Following textures by Tonedef of WoWInterface
	[3] = { "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Carpaint_1", "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Carpaint_2", "Carpaint" },
	[4] = { "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Gel_1", "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Gel_2", "Gel" },
	[5] = { "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Glassed_1", "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Glassed_2", "Glassed" },
	[6] = { "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Soft_1", "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Soft_2", "Soft" },
	[7] = { "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Velvet_1", "Interface\\AddOns\\Ion-StatusBars\\Images\\BarFill_Velvet_3", "Velvet" },
}

local BarBorders = {
	[1] = { "Tooltip", "Interface\\Tooltips\\UI-Tooltip-Border", 2, 2, 3, 3, 12, 12, -2, 3, 2, -3 },
	[2] = { "Slider", "Interface\\Buttons\\UI-SliderBar-Border", 3, 3, 6, 6, 8, 8 , -1, 5, 1, -5 },
	[3] = { "Dialog", "Interface\\AddOns\\Ion-StatusBars\\Images\\Border_Dialog", 11, 12, 12, 11, 26, 26, -7, 7, 7, -7 },
	[4] = { "None", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
}

local BarOrientations = {
	[1] = "Horizontal",
	[2] = "Vertical",
}

local BarUnits = {
	[1] = "-none-",
	[2] = "player",
	[3] = "pet",
	[4] = "target",
	[5] = "targettarget",
	[6] = "focus",
	[7] = "mouseover",
	[8] = "party1",
	[9] = "party2",
	[10] = "party3",
	[11] = "party4",
}

local BarRepColors = {
	[0] = { l="a_Unknown", r=0.5, g=0.5, b=0.5, a=1.0 },
	[1] = { l="b_Hated", r=0.6, g=0.1, b=0.1, a=1.0 },
	[2] = { l="c_Hostile", r=0.7, g=0.2, b=0.2, a=1.0 },
	[3] = { l="d_Unfriendly", r=0.75, g=0.27, b=0, a=1.0 },
	[4] = { l="e_Neutral", r=0.9, g=0.7, b=0, a=1.0 },
	[5] = { l="f_Friendly", r=0.5, g=0.6, b=0.1, a=1.0 },
	[6] = { l="g_Honored", r=0.1, g=0.5, b=0.20, a=1.0 },
	[7] = { l="h_Revered", r=0.0, g=0.39, b=0.88, a=1.0 },
	[8] = { l="i_Exalted", r=0.58, g=0.0, b=0.55, a=1.0 },
}

FACTION_BAR_COLORS = BarRepColors

local CastWatch, XPWatch, RepWatch, MirrorWatch, MirrorBars, Session = {}, {}, {}, {}, {}, {}

local gDef = {

	[1] = {

		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 0,
		y = 185,
	},

	[2] = {

		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = -130,
		y = 20,
	},

	[3] = {

		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "BOTTOM",
		x = 130,
		y = 20,
	},

	[4] = {

		columns = 1,
		snapTo = false,
		snapToFrame = false,
		snapToPoint = false,
		point = "TOP",
		x = 0,
		y = -123,
	},
}

local configDef = {

	sbType = "statusbar",

	width = 200,
	height = 18,
	scale = 1,
	XOffset = 0,
	YOffset = 0
	,
	texture = 1,
	border = 1,

	orientation = 1,

	cIndex = 1,
	cColor = "1;1;1;1",

	lIndex = 1,
	lColor = "1;1;1;1",

	rIndex = 1,
	rColor = "1;1;1;1",

	mIndex = 1,
	mColor = "1;1;1;1",

	tIndex = 1,
	tColor = "1;1;1;1",

	bordercolor = "1;1;1;1",

	norestColor = "1;0;1;1",
	restColor = "0;0;1;1",

	castColor = "1;0.7;0;1",
	channelColor = "0;1;0;1",
	successColor = "0;1;0;1",
	failColor = "1;0;0;1",

	showIcon = false,
}

local dataDef = {

	unit = 2,

	repID = 0,
	repAuto = 0,
}

local configDefaults = {

	[1] = { sbType = "cast", cIndex = 1, lIndex = 2, rIndex = 3 },
	[2] = { sbType = "xp", cIndex = 2, lIndex = 1, rIndex = 1, width = 250 },
	[3] = { sbType = "rep", cIndex = 2, lIndex = 1, rIndex = 1, width = 250 },
	[4] = { sbType = "mirror", cIndex = 1, lIndex = 2, rIndex = 3 },
	[5] = { sbType = "mirror", cIndex = 1, lIndex = 2, rIndex = 3 },
	[6] = { sbType = "mirror", cIndex = 1, lIndex = 2, rIndex = 3 },
}

local sbStrings = {
	cast = {
		[1] = { "---", function(sb) return "" end },
		[2] = { "Spell", function(sb) if (CastWatch[sb.unit]) then return CastWatch[sb.unit].spell end end },
		[3] = { "Timer", function(sb) if (CastWatch[sb.unit]) then return CastWatch[sb.unit].timer end end },
	},
	xp = {
		[1] = { "---", function(sb) return "" end },
		[2] = { "Current/Next", function(sb) if (XPWatch.current) then return XPWatch.current end end },
		[3] = { "Rested Levels", function(sb) if (XPWatch.rested) then return XPWatch.rested end end },
		[4] = { "Percent", function(sb) if (XPWatch.percent) then return XPWatch.percent end end },
		[5] = { "Bubbles", function(sb) if (XPWatch.bubbles) then return XPWatch.bubbles end end },
	},
	rep = {
		[1] = { "---", function(sb) return "" end },
		[2] = { "Faction & Standing", function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].rep end end },
		[3] = { "Current/Next", function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].current end end },
		[4] = { "Percent", function(sb) if (RepWatch[sb.repID]) then return RepWatch[sb.repID].percent end end },
	},
	mirror = {
		[1] = { "---", function(sb) return "" end },
		[2] = { "Type", function(sb) if (MirrorWatch[sb.mirror]) then return MirrorWatch[sb.mirror].label end end },
		[3] = { "Timer", function(sb) if (MirrorWatch[sb.mirror]) then return MirrorWatch[sb.mirror].timer end end },
	},
}

local function xpstrings_Update()

	local currXP, nextXP, restedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
	local percentXP = (currXP/nextXP)*100; percentXP = format("%.1f", percentXP)
	local bubbles = tostring(currXP/(nextXP/20)); bubbles = (bubbles):gsub("(%d*)(%.)(%d*)","%1")

	if (restedXP) then
		restedXP = tostring(restedXP/nextXP); restedXP = (restedXP):gsub("(%d*)(%.)(%d%d)(%d*)","%1%2%3")
	else
		restedXP = "0"
	end

	XPWatch.current = currXP.."/"..nextXP
	XPWatch.rested = restedXP.." lvls"
	XPWatch.percent = percentXP.."%"
	XPWatch.bubbles = bubbles

	return currXP, nextXP, GetXPExhaustion()

end

local function repstrings_Update(line)

	if (GetNumFactions() > 0) then

		local _, name, ID, min, max, value, isHeader, hasRep, standing, colors

		wipe(RepWatch)

		for i=1, GetNumFactions() do

			name, _, ID, min, max, value, _, _, isHeader, _, hasRep = GetFactionInfo(i)

			if ((not isHeader or hasRep) and not IsFactionInactive(i) and not (isHeader and ID == 8)) then

				colors = BarRepColors[ID]; standing = (colors.l):gsub("^%a%p", "")

				if (not RepWatch[i]) then
					RepWatch[i] = {}
				end

				RepWatch[i].rep = name.." - "..standing
				RepWatch[i].current = (value-min).."/"..(max-min)
				RepWatch[i].percent = floor(((value-min)/(max-min))*100).."%"
				RepWatch[i].rephour = "---"
				RepWatch[i].min = min
				RepWatch[i].max = max
				RepWatch[i].value = value
				RepWatch[i].hex = format("%02x%02x%02x", colors.r*255, colors.g*255, colors.b*255)
				RepWatch[i].r = colors.r
				RepWatch[i].g = colors.g
				RepWatch[i].b = colors.b
				RepWatch[i].l = colors.l

				if (line and (line):find(name) or CDB.autoWatch == i) then

					if (not RepWatch[0]) then
						RepWatch[0] = {}
					end

					RepWatch[0].rep = name.." - "..standing
					RepWatch[0].current = (value-min).."/"..(max-min)
					RepWatch[0].percent = floor(((value-min)/(max-min))*100).."%"
					RepWatch[0].rephour = "---"
					RepWatch[0].min = min
					RepWatch[0].max = max
					RepWatch[0].value = value
					RepWatch[0].hex = format("%02x%02x%02x", colors.r*255, colors.g*255, colors.b*255)
					RepWatch[0].r = colors.r
					RepWatch[0].g = colors.g
					RepWatch[0].b = colors.b
					RepWatch[0].l = colors.l

					--[[
					if (line and (line):find(name)) then

						local gain = tonumber(line:match("%d+"))

						if (gain) then

							if (not Session[name]) then
								Session[name] = GetTime()
							end

							local rephour = (gain/(GetTime()-Session[name]))*3600

							RepWatch[0].rephour = rephour.."/hour"

							print(rephour)
						end
					end
					-]]

					CDB.autoWatch = i
				end
			end
		end
	end
end

local function repbar_OnEvent(self, event,...)

	repstrings_Update(...)

	if (RepWatch[self.repID]) then
		self:SetStatusBarColor(RepWatch[self.repID].r,  RepWatch[self.repID].g, RepWatch[self.repID].b)
		self:SetMinMaxValues(RepWatch[self.repID].min, RepWatch[self.repID].max)
		self:SetValue(RepWatch[self.repID].value)
	else
		self:SetStatusBarColor(0.5,  0.5, 0.5)
		self:SetMinMaxValues(0, 1)
		self:SetValue(1)
	end

	self.cText:SetText(self.cFunc(self))
	self.lText:SetText(self.lFunc(self))
	self.rText:SetText(self.rFunc(self))
	self.mText:SetText(self.mFunc(self))
end

local function repDropDown_Initialize(frame)

	frame.statusbar = frame:GetParent()

	if (frame.statusbar) then

		local info = UIDropDownMenu_CreateInfo()
		local checked, repLine, repIndex

		info.arg1 = frame.statusbar
		info.arg2 = repbar_OnEvent
		info.text = "Auto Select"
		info.func = function(self, statusbar, func, checked)
					local faction = sbStrings.rep[2][2](statusbar.sb)
					statusbar.data.repID = self.value; statusbar.sb.repID = self.value; func(statusbar.sb, nil, faction)
				end

		if (frame.statusbar.data.repID == 0) then
			checked = 1
		else
			checked = nil
		end

		info.value = 0
		info.checked = checked

		UIDropDownMenu_AddButton(info)

		local data, _, ID, text = {}

		for k,v in pairs(RepWatch) do

			if (k > 0) then

				percent = tonumber(v.percent:match("%d+"))

				if (percent < 10) then
					percent = "0"..percent
				end

				tinsert(data, v.l..percent..":"..k..":".."|cff"..v.hex..v.rep.." - "..v.percent.."|r")
			end
		end

		tsort(data)

		for k,v in ipairs(data) do

			_, ID, text = (":"):split(v)

			ID = tonumber(ID)

			info.arg1 = frame.statusbar
			info.arg2 = repbar_OnEvent
			info.text = text
			info.func = function(self, statusbar, func, checked)
						statusbar.data.repID = self.value; statusbar.sb.repID = self.value; func(statusbar.sb)
					end

			if (frame.statusbar.data.repID == ID) then
				checked = 1
			else
				checked = nil
			end

			info.value = ID
			info.checked = checked

			UIDropDownMenu_AddButton(info)
		end
	end
end

local function mirrorbar_Start(mirror, value, maxvalue, scale, paused, label)

	if (not MirrorWatch[mirror]) then
		MirrorWatch[mirror] = { active = false, mbar = nil, label = "", timer = "" }
	end

	if (not MirrorWatch[mirror].active) then

		local mbar = tremove(MirrorBars, 1)

		if (mbar) then

			MirrorWatch[mirror].active = true
			MirrorWatch[mirror].mbar = mbar
			MirrorWatch[mirror].label = label

			mbar.sb.mirror = mirror
			mbar.sb.value = (value / 1000)
			mbar.sb.maxvalue = (maxvalue / 1000)
			mbar.sb.scale = scale

			if ( paused > 0 ) then
				mbar.sb.paused = 1
			else
				mbar.sb.paused = nil
			end

			local color = MirrorTimerColors[mirror]

			mbar.sb:SetMinMaxValues(0, (maxvalue / 1000))
			mbar.sb:SetValue(mbar.sb.value)
			mbar.sb:SetStatusBarColor(color.r, color.g, color.b)

			mbar.sb:SetAlpha(1)
			mbar.sb:Show()
		end
	end
end

local function mirrorbar_Stop(mirror)

	if (MirrorWatch[mirror] and MirrorWatch[mirror].active) then

		local mbar = MirrorWatch[mirror].mbar

		if (mbar) then

			tinsert(MirrorBars, 1, mbar)

			MirrorWatch[mirror].active = false
			MirrorWatch[mirror].mbar = nil
			MirrorWatch[mirror].label = ""
			MirrorWatch[mirror].timer = ""

			mbar.sb.mirror = nil
		end
	end
end

function STATUS:SetBorder(statusbar, config, bordercolor)

	statusbar.border:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
				edgeFile = BarBorders[config.border][2],
				tile = true,
				tileSize = BarBorders[config.border][7],
				edgeSize = BarBorders[config.border][8],
				insets = { left = BarBorders[config.border][3],
					   right = BarBorders[config.border][4],
					   top = BarBorders[config.border][5],
					   bottom = BarBorders[config.border][6]
					 }
				})

	statusbar.border:SetPoint("TOPLEFT", BarBorders[config.border][9], BarBorders[config.border][10])
	statusbar.border:SetPoint("BOTTOMRIGHT", BarBorders[config.border][11], BarBorders[config.border][12])

	statusbar.border:SetBackdropColor(0, 0, 0, 0)
	statusbar.border:SetBackdropBorderColor(bordercolor[1], bordercolor[2], bordercolor[3], 1)
	statusbar.border:SetFrameLevel(self:GetFrameLevel()+1)

	statusbar.bg:SetBackdropColor(0, 0, 0, 1)
	statusbar.bg:SetBackdropBorderColor(0, 0, 0, 0)
	statusbar.bg:SetFrameLevel(0)

	if (statusbar.barflash) then
		statusbar.barflash:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
					edgeFile = BarBorders[config.border][2],
					tile = true,
					tileSize = BarBorders[config.border][7],
					edgeSize = BarBorders[config.border][8],
					insets = { left = BarBorders[config.border][3],
						   right = BarBorders[config.border][4],
						   top = BarBorders[config.border][5],
						   bottom = BarBorders[config.border][6]
						 }
					})
	end


end

function STATUS:ChangeStatusBarType(statusbar)

	if (self.config.sbType == "xp") then
		self.config.sbType = "rep"
		self.config.cIndex = 2
		self.config.lIndex = 1
		self.config.rIndex = 1
	elseif (self.config.sbType == "rep") then
		self.config.sbType = "cast"
		self.config.cIndex = 1
		self.config.lIndex = 2
		self.config.rIndex = 3
	elseif (self.config.sbType == "cast") then
		self.config.sbType = "mirror"
		self.config.cIndex = 1
		self.config.lIndex = 2
		self.config.rIndex = 3
	else
		self.config.sbType = "xp"
		self.config.cIndex = 2
		self.config.lIndex = 1
		self.config.rIndex = 1
	end

	self:SetType()
end

function STATUS:CastBar_FinishSpell()

	self.spark:Hide()
	self.barflash:SetAlpha(0.0)
	self.barflash:Show()
	self.flash = 1
	self.fadeOut = 1
	self.casting = nil
	self.channeling = nil
end

function STATUS:CastBar_Reset()

	self.fadeOut = 1
	self.casting = nil
	self.channeling = nil
	self:SetStatusBarColor(self.castColor[1], self.castColor[2], self.castColor[3], self.castColor[4])

	if (not self.editmode) then
		self:Hide()
	end
end

function STATUS:CastBar_OnEvent(event, ...)

	local parent, unit = self.parent, ...

	if (unit ~= self.unit) then
		return
	end

	if (not CastWatch[self.unit] ) then
		CastWatch[self.unit] = {}
	end

	if (event == "UNIT_SPELLCAST_START") then

		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID = UnitCastingInfo(unit)

		if (not name or (not self.showTradeSkills and isTradeSkill)) then
			self.parent.CastBar_Reset(self); return
		end

		self:SetStatusBarColor(self.castColor[1], self.castColor[2], self.castColor[3], self.castColor[4])

		if (self.spark) then
			self.spark:SetTexture("Interface\\AddOns\\Ion-StatusBars\\Images\\CastingBar_Spark_"..self.orientation)
			self.spark:Show()
		end

		self.value = (GetTime()-(startTime/1000))
		self.maxValue = (endTime-startTime)/1000
		self:SetMinMaxValues(0, self.maxValue)
		self:SetValue(self.value)

		self.totalTime = self.maxValue - self:GetValue()

		CastWatch[self.unit].spell = text

		if (self.showIcon) then
			self.icon:SetTexture(texture)
			self.icon:Show()
		else
			self.icon:Hide()
		end

		self:SetAlpha(1.0)
		self.holdTime = 0
		self.casting = 1
		self.castID = castID
		self.channeling = nil
		self.fadeOut = nil

		self:Show()

	elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then

		self:SetStatusBarColor(self.successColor[1], self.successColor[2], self.successColor[3], self.successColor[4])

	elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then

		if ((self.casting and event == "UNIT_SPELLCAST_STOP" and select(4, ...) == self.castID) or
		     (self.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP")) then

			self.spark:Hide()
			self.barflash:SetAlpha(0.0)
			self.barflash:Show()

			self:SetValue(self.maxValue)

			if (event == "UNIT_SPELLCAST_STOP") then
				self.casting = nil
			else
				self.channeling = nil
			end

			self.flash = 1
			self.fadeOut = 1
			self.holdTime = 0
		end

	elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") then

		if (self:IsShown() and (self.casting and select(4, ...) == self.castID) and not self.fadeOut) then

			self:SetValue(self.maxValue)

			self:SetStatusBarColor(self.failColor[1], self.failColor[2], self.failColor[3], self.failColor[4])

			if (self.spark) then
				self.spark:Hide()
			end

			if (event == "UNIT_SPELLCAST_FAILED") then
				CastWatch[self.unit].spell = FAILED
			else
				CastWatch[self.unit].spell = INTERRUPTED
			end

			self.casting = nil
			self.channeling = nil
			self.fadeOut = 1
			self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
		end

	elseif (event == "UNIT_SPELLCAST_DELAYED") then

		if (self:IsShown()) then

			local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit)

			if (not name or (not self.showTradeSkills and isTradeSkill)) then
				self.parent.CastBar_Reset(self); return
			end

			self.value = (GetTime()-(startTime/1000))
			self.maxValue = (endTime-startTime)/1000
			self:SetMinMaxValues(0, self.maxValue)

			if (not self.casting) then

				self:SetStatusBarColor(self.castColor[1], self.castColor[2], self.castColor[3], self.castColor[4])

				self.spark:Show()
				self.barflash:SetAlpha(0.0)
				self.barflash:Hide()

				self.casting = 1
				self.channeling = nil
				self.flash = 0
				self.fadeOut = 0
			end
		end

	elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then

		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit)

		if (not name or (not self.showTradeSkills and isTradeSkill)) then
			self.parent.CastBar_Reset(self); return
		end

		self:SetStatusBarColor(self.channelColor[1], self.channelColor[2], self.channelColor[3], self.channelColor[4])

		self.value = ((endTime/1000)-GetTime())
		self.maxValue = (endTime - startTime) / 1000;
		self:SetMinMaxValues(0, self.maxValue);
		self:SetValue(self.value)

		CastWatch[self.unit].spell = text

		if (self.showIcon) then
			self.icon:SetTexture(texture)
			self.icon:Show()
		else
			self.icon:Hide()
		end

		if (self.spark) then
			self.spark:Hide()
		end

		self:SetAlpha(1.0)
		self.holdTime = 0
		self.casting = nil
		self.channeling = 1
		self.fadeOut = nil

		self:Show()

	elseif (event == "UNIT_SPELLCAST_CHANNEL_UPDATE") then

		if (self:IsShown()) then

			local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit)

			if (not name or (not self.showTradeSkills and isTradeSkill)) then
				self.parent.CastBar_Reset(self); return
			end

			self.value = ((endTime/1000)-GetTime())
			self.maxValue = (endTime-startTime)/1000
			self:SetMinMaxValues(0, self.maxValue)
			self:SetValue(self.value)
		end
	else
		self.parent.CastBar_Reset(self)
	end

	self.cText:SetText(self.cFunc(self))
	self.lText:SetText(self.lFunc(self))
	self.rText:SetText(self.rFunc(self))
	self.mText:SetText(self.mFunc(self))
end

function STATUS:CastBar_OnUpdate(elapsed)

	local unit, sparkPosition, alpha = self.unit

	if (unit) then

		if (self.cbtimer.castInfo[unit]) then

			local displayName, numFormat = self.cbtimer.castInfo[unit][1], self.cbtimer.castInfo[unit][2]

			if (self.maxValue) then
				CastWatch[self.unit].timer = format(numFormat, self.value).."/"..format(numFormat, self.maxValue)
			else
				CastWatch[self.unit].timer = format(numFormat, self.value)
			end
		end

		if (self.casting) then

			self.value = self.value + elapsed

			if (self.value >= self.maxValue) then
				self:SetValue(self.maxValue); self.parent.CastBar_FinishSpell(self); return
			end

			self:SetValue(self.value)

			self.barflash:Hide()

			if (self.orientation == 1) then

				sparkPosition = (self.value/self.maxValue)*self:GetWidth()

				if (sparkPosition < 0) then
					sparkPosition = 0
				end

				self.spark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0)

			else
				sparkPosition = (self.value / self.maxValue) * self:GetHeight()

				if ( sparkPosition < 0 ) then
					sparkPosition = 0
				end

				self.spark:SetPoint("CENTER", self, "BOTTOM", 0, sparkPosition)
			end

		elseif (self.channeling) then

			self.value = self.value - elapsed

			if (self.value <= 0) then
				self.parent.CastBar_FinishSpell(self); return
			end

			self:SetValue(self.value)

			self.barflash:Hide()

		elseif (GetTime() < self.holdTime) then

			return

		elseif (self.flash) then

			alpha = self.barflash:GetAlpha() + CASTING_BAR_FLASH_STEP or 0

			if (alpha < 1) then
				self.barflash:SetAlpha(alpha)
			else
				self.barflash:SetAlpha(1.0); self.flash = nil
			end

		elseif (self.fadeOut and not self.editmode) then

			alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP

			if (alpha > 0) then
				self:SetAlpha(alpha)
			else
				self.parent.CastBar_Reset(self)
			end
		end
	end

	self.cText:SetText(self.cFunc(self))
	self.lText:SetText(self.lFunc(self))
	self.rText:SetText(self.rFunc(self))
	self.mText:SetText(self.mFunc(self))
end

function STATUS:CastBarTimer_OnEvent(event, ...)

	local unit = select(1, ...)

	if (unit) then

		if (event == "UNIT_SPELLCAST_START") then

			local _, _, text = UnitCastingInfo(unit)

			if (not self.castInfo[unit]) then self.castInfo[unit] = {} end
			self.castInfo[unit][1] = text
			self.castInfo[unit][2] = "%0.1f"

		elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then

			local _, _, text = UnitChannelInfo(unit)

			if (not self.castInfo[unit]) then self.castInfo[unit] = {} end
			self.castInfo[unit][1] = text
			self.castInfo[unit][2] = "%0.1f"
		end
	end
end

function STATUS:XPBar_OnEvent()

	local currXP, nextXP, restedXP = xpstrings_Update()

	if (restedXP) then
		self:SetStatusBarColor(self.restColor[1], self.restColor[2], self.restColor[3], self.restColor[4])
	else
		self:SetStatusBarColor(self.norestColor[1], self.norestColor[2], self.norestColor[3], self.norestColor[4])
	end

	self:SetMinMaxValues(0, nextXP)
	self:SetValue(currXP)

	self.cText:SetText(self.cFunc(self))
	self.lText:SetText(self.lFunc(self))
	self.rText:SetText(self.rFunc(self))
	self.mText:SetText(self.mFunc(self))
end

function STATUS:RepBar_DropDown_OnLoad()
	UIDropDownMenu_Initialize(self.dropdown, repDropDown_Initialize, "MENU")
end

function STATUS:MirrorBar_OnUpdate(elapsed)

	if (self.mirror) then

		self.value = GetMirrorTimerProgress(self.mirror)/1000

		if (self.value > self.maxvalue) then

			self.alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP

			if (self.alpha > 0) then
				self:SetAlpha(self.alpha)
			else
				self:Hide()
			end

		else

			self:SetValue(self.value)

			if (self.value >= 60) then
				self.value = format("%0.1f", self.value/60)
				self.value = self.value.."m"
			else
				self.value = format("%0.0f", self.value)
				self.value = self.value.."s"
			end

			MirrorWatch[self.mirror].timer = self.value

		end

	elseif (not self.editmode) then

		self.alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP

		if (self.alpha > 0) then
			self:SetAlpha(self.alpha)
		else
			self:Hide()
		end
	end

	self.cText:SetText(self.cFunc(self))
	self.lText:SetText(self.lFunc(self))
	self.rText:SetText(self.rFunc(self))
	self.mText:SetText(self.mFunc(self))
end

function STATUS:OnClick(button, down)

	if (button == "RightButton") then

		if (DropDownList1:IsVisible()) then
			DropDownList1:Hide()
		else
			repstrings_Update()

			ToggleDropDownMenu(1, nil, self.dropdown, self, 0, 0)

			DropDownList1:ClearAllPoints()
			DropDownList1:SetPoint("LEFT", self, "RIGHT", 3, 0)
			DropDownList1:SetClampedToScreen(true)

			PlaySound("igMainMenuOptionCheckBoxOn")
		end
	end
end

function STATUS:OnEnter()

	if (self.config.mIndex > 1) then
		self.sb.cText:Hide()
		self.sb.lText:Hide()
		self.sb.rText:Hide()
		self.sb.mText:Show()
		self.sb.mText:SetText(self.sb.mFunc(self.sb))
	end

	if (self.config.tIndex > 1) then

		if (self.bar) then

			if (self.bar.config.tooltipsCombat and InCombatLockdown()) then
				return
			end

			if (self.bar.config.tooltips) then

				if (self.bar.config.tooltipsEnhanced) then
					GameTooltip_SetDefaultAnchor(GameTooltip, self)
				else
					GameTooltip:SetOwner("STATUS_RIGHT")
				end

				GameTooltip:SetText(self.sb.tFunc(self.sb) or "", self.tColor[1] or 1, self.tColor[2] or 1, self.tColor[3] or 1, self.tColor[4] or 1)
				GameTooltip:Show()
			end
		end
	end
end

function STATUS:OnLeave()

	if (self.config.mIndex > 1) then
		self.sb.cText:Show()
		self.sb.lText:Show()
		self.sb.rText:Show()
		self.sb.mText:Hide()
		self.sb.cText:SetText(self.sb.cFunc(self.sb))
		self.sb.lText:SetText(self.sb.lFunc(self.sb))
		self.sb.rText:SetText(self.sb.rFunc(self.sb))
	end

	if (self.config.tIndex > 1) then
		GameTooltip:Hide()
	end
end

function STATUS:UpdateWidth(statusbar, delta, timer)

	if (not delta) then
		return self.config.width
	end

	if (timer) then
		timer = ceil(timer/0.5)
		if (timer <= 0) then
			timer = 1
		end
	else
		timer = 1
	end

	if (delta > 0 ) then
		self.config.width = self.config.width + 0.5 * timer
	else
		self.config.width = self.config.width - 0.5 * timer
		if (self.config.width < 10) then
			self.config.width = 10
		end
	end

	self.bar:Update()

end

function STATUS:UpdateHeight(statusbar, delta, timer)

	if (not delta) then
		return self.config.height
	end

	if (timer) then
		timer = ceil(timer/0.5)
		if (timer <= 0) then
			timer = 1
		end
	else
		timer = 1
	end

	if (delta > 0 ) then
		self.config.height = self.config.height + 0.5 * timer
	else
		self.config.height = self.config.height - 0.5 * timer
		if (self.config.height < 4) then
			self.config.height = 4
		end
	end

	self.bar:Update()
end

function STATUS:UpdateTexture(statusbar, delta)

	if (not delta) then
		return BarTextures[self.config.texture][3]
	end

	local index = self.config.texture

	if (delta > 0) then

		if (index == #BarTextures) then
			index = 1
		else
			index = index + 1
		end

		self.config.texture = index

	else

		if (index == 1) then
			index = #BarTextures
		else
			index = index - 1
		end

		self.config.texture = index
	end

	self:SetData(self.bar)
end

function STATUS:UpdateBorder(statusbar, delta)

	if (not delta) then
		return BarBorders[self.config.border][1]
	end

	local index = self.config.border

	if (delta > 0) then

		if (index == #BarBorders) then
			index = 1
		else
			index = index + 1
		end

		self.config.border = index

	else
		if (index == 1) then
			index = #BarBorders
		else
			index = index - 1
		end

		self.config.border = index
	end

	self:SetData(self.bar)
end

function STATUS:UpdateOrientation(statusbar, delta)

	if (not delta) then
		return BarOrientations[self.config.orientation]
	end

	local index = self.config.orientation

	if (delta > 0) then

		if (index == #BarOrientations) then
			index = 1
		else
			index = index + 1
		end

		self.config.orientation = index

	else

		if (index == 1) then
			index = #BarOrientations
		else
			index = index - 1
		end

		self.config.orientation = index
	end

	local width, height = self.config.width,  self.config.height

	self.config.width = height;  self.config.height = width
	self.bar:Update()
end

function STATUS:UpdateCenterText(statusbar, delta)

	if (not sbStrings[self.config.sbType]) then
		return "---"
	end

	if (not delta) then
		return sbStrings[self.config.sbType][self.config.cIndex][1]
	end

	local index = self.config.cIndex

	if (delta > 0) then

		if (index == #sbStrings[self.config.sbType]) then
			index = 1
		else
			index = index + 1
		end

	else

		if (index == 1) then
			index = #sbStrings[self.config.sbType]
		else
			index = index - 1
		end

	end

	self.config.cIndex = index

	self:SetData(self.bar)

end

function STATUS:UpdateLeftText(statusbar, delta)

	if (not sbStrings[self.config.sbType]) then
		return "---"
	end

	if (not delta) then
		return sbStrings[self.config.sbType][self.config.lIndex][1]
	end

	local index = self.config.lIndex

	if (delta > 0) then

		if (index == #sbStrings[self.config.sbType]) then
			index = 1
		else
			index = index + 1
		end

	else

		if (index == 1) then
			index = #sbStrings[self.config.sbType]
		else
			index = index - 1
		end

	end

	self.config.lIndex = index

	self:SetData(self.bar)

end

function STATUS:UpdateRightText(statusbar, delta)

	if (not sbStrings[self.config.sbType]) then
		return "---"
	end

	if (not delta) then
		return sbStrings[self.config.sbType][self.config.rIndex][1]
	end

	local index = self.config.rIndex

	if (delta > 0) then

		if (index == #sbStrings[self.config.sbType]) then
			index = 1
		else
			index = index + 1
		end

	else

		if (index == 1) then
			index = #sbStrings[self.config.sbType]
		else
			index = index - 1
		end

	end

	self.config.rIndex = index

	self:SetData(self.bar)

end

function STATUS:UpdateMouseover(statusbar, delta)

	if (not sbStrings[self.config.sbType]) then
		return "---"
	end

	if (not delta) then
		return sbStrings[self.config.sbType][self.config.mIndex][1]
	end

	local index = self.config.mIndex

	if (delta > 0) then

		if (index == #sbStrings[self.config.sbType]) then
			index = 1
		else
			index = index + 1
		end

	else

		if (index == 1) then
			index = #sbStrings[self.config.sbType]
		else
			index = index - 1
		end

	end

	self.config.mIndex = index

	self:SetData(self.bar)

end

function STATUS:UpdateTooltip(statusbar, delta)

	if (not sbStrings[self.config.sbType]) then
		return "---"
	end

	if (not delta) then
		return sbStrings[self.config.sbType][self.config.tIndex][1]
	end

	local index = self.config.tIndex

	if (delta > 0) then

		if (index == #sbStrings[self.config.sbType]) then
			index = 1
		else
			index = index + 1
		end

	else

		if (index == 1) then
			index = #sbStrings[self.config.sbType]
		else
			index = index - 1
		end

	end

	self.config.tIndex = index

	self:SetData(self.bar)

end

function STATUS:SetData(bar)

	if (bar) then

		self.bar = bar
		self.alpha = bar.gdata.alpha
		self.showGrid = bar.gdata.showGrid

		self:SetFrameStrata(bar.gdata.objectStrata)
		self:SetScale(bar.gdata.scale)

	end

	self:SetWidth(self.config.width)
	self:SetHeight(self.config.height)

	self.bordercolor = { (";"):split(self.config.bordercolor) }

	self.cColor = { (";"):split(self.config.cColor) }
	self.lColor = { (";"):split(self.config.lColor) }
	self.rColor = { (";"):split(self.config.rColor) }
	self.mColor = { (";"):split(self.config.mColor) }
	self.tColor = { (";"):split(self.config.tColor) }

	self.sb.parent = self

	self.sb.cText:SetTextColor(self.cColor[1], self.cColor[2], self.cColor[3], self.cColor[4])
	self.sb.lText:SetTextColor(self.lColor[1], self.lColor[2], self.lColor[3], self.lColor[4])
	self.sb.rText:SetTextColor(self.rColor[1], self.rColor[2], self.rColor[3], self.rColor[4])
	self.sb.mText:SetTextColor(self.mColor[1], self.mColor[2], self.mColor[3], self.mColor[4])

	if (sbStrings[self.config.sbType]) then

		if (not sbStrings[self.config.sbType][self.config.cIndex]) then
			self.config.cIndex = 1
		end
		self.sb.cFunc = sbStrings[self.config.sbType][self.config.cIndex][2]

		if (not sbStrings[self.config.sbType][self.config.lIndex]) then
			self.config.lIndex = 1
		end
		self.sb.lFunc = sbStrings[self.config.sbType][self.config.lIndex][2]

		if (not sbStrings[self.config.sbType][self.config.rIndex]) then
			self.config.rIndex = 1
		end
		self.sb.rFunc = sbStrings[self.config.sbType][self.config.rIndex][2]

		if (not sbStrings[self.config.sbType][self.config.mIndex]) then
			self.config.mIndex = 1
		end
		self.sb.mFunc = sbStrings[self.config.sbType][self.config.mIndex][2]

		if (not sbStrings[self.config.sbType][self.config.tIndex]) then
			self.config.tIndex = 1
		end
		self.sb.tFunc = sbStrings[self.config.sbType][self.config.tIndex][2]

	else
		self.sb.cFunc = function() return "" end
		self.sb.lFunc = function() return "" end
		self.sb.rFunc = function() return "" end
		self.sb.mFunc = function() return "" end
		self.sb.tFunc = function() return "" end
	end

	self.sb.cText:SetText(self.sb.cFunc(self.sb))
	self.sb.lText:SetText(self.sb.lFunc(self.sb))
	self.sb.rText:SetText(self.sb.rFunc(self.sb))
	self.sb.mText:SetText(self.sb.mFunc(self.sb))

	self.sb.norestColor = { (";"):split(self.config.norestColor) }
	self.sb.restColor = { (";"):split(self.config.restColor) }

	self.sb.castColor = { (";"):split(self.config.castColor) }
	self.sb.channelColor = { (";"):split(self.config.channelColor) }
	self.sb.successColor = { (";"):split(self.config.successColor) }
	self.sb.failColor = { (";"):split(self.config.failColor) }

	self.sb.orientation = self.config.orientation
	self.sb:SetOrientation(BarOrientations[self.config.orientation]:upper())
	self.editframe.feedback:SetOrientation(BarOrientations[self.config.orientation]:upper())

	if (BarTextures[self.config.texture]) then
		self.sb:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
		self.editframe.feedback:SetStatusBarTexture(BarTextures[self.config.texture][self.config.orientation])
	else
		self.sb:SetStatusBarTexture(BarTextures[1][self.config.orientation])
		self.editframe.feedback:SetStatusBarTexture(BarTextures[1][self.config.orientation])
	end

	self:SetBorder(self.sb, self.config, self.bordercolor)
	self:SetBorder(self.editframe.feedback, self.config, self.bordercolor)

	self:SetFrameLevel(4)

	self.editframe:SetFrameLevel(self:GetFrameLevel()+10)
	self.editframe.feedback:SetFrameLevel(self.sb:GetFrameLevel()+10)
	self.editframe.feedback.bg:SetFrameLevel(self.sb.bg:GetFrameLevel()+10)
	self.editframe.feedback.border:SetFrameLevel(self.sb.border:GetFrameLevel()+10)

end

function STATUS:SaveData()

	-- empty

end

function STATUS:LoadData(spec, state)

	local id = self.id

	self.GDB = statusbtnsGDB
	self.CDB = statusbtnsCDB

	if (self.GDB and self.CDB) then

		if (not self.GDB[id]) then
			self.GDB[id] = {}
		end

		if (not self.GDB[id].config) then
			self.GDB[id].config = CopyTable(configDef)
		end

		if (not self.CDB[id]) then
			self.CDB[id] = {}
		end

		if (not self.CDB[id].data) then
			self.CDB[id].data = CopyTable(dataDef)
		end

		ION:UpdateData(self.GDB[id].config, configDef)
		ION:UpdateData(self.CDB[id].data, dataDef)

		self.config = self.GDB [id].config

		self.data = self.CDB[id].data
	end
end

function STATUS:SetGrid(show, hide)

	if (show) then

		self.editmode = true

		self.editframe:Show()

	else
		self.editmode = nil

		self.editframe:Hide()
	end

	--empty

end

function STATUS:SetAux()

	-- empty

end

function STATUS:LoadAux()

	self:CreateEditFrame(self.objTIndex)

	-- empty

end

function STATUS:SetDefaults(config)

	if (config) then
		for k,v in pairs(config) do
			self.config[k] = v
		end
	end

end

function STATUS:GetDefaults()

	return configDefaults[self.id]

end

function STATUS:StatusBar_Reset()

	self:RegisterForClicks("")
	self:SetScript("OnClick", function() end)
	self:SetScript("OnEnter", function() end)
	self:SetScript("OnLeave", function() end)
	self:SetHitRectInsets(self:GetWidth()/2, self:GetWidth()/2, self:GetHeight()/2, self:GetHeight()/2)

	self.sb:UnregisterAllEvents()
	self.sb:SetScript("OnEvent", function() end)
	self.sb:SetScript("OnUpdate", function() end)
	self.sb:SetScript("OnShow", function() end)
	self.sb:SetScript("OnHide", function() end)

	self.sb.unit = nil
	self.sb.rep = nil
	self.sb.showIcon = nil

	self.sb.cbtimer:UnregisterAllEvents()
	self.sb.cbtimer:SetScript("OnEvent", nil)

	for index, sb in ipairs(MirrorBars) do
		if (sb == statusbar) then
			tremove(MirrorBars, index)
		end
	end
end

function STATUS:SetType(save)

	if (InCombatLockdown()) then
		return
	end

	self:StatusBar_Reset()

	if (kill) then

		self:SetScript("OnEvent", function() end)
		self:SetScript("OnUpdate", function() end)
	else

		if (self.config.sbType == "cast") then

			self.sb:RegisterEvent("UNIT_SPELLCAST_START")
			self.sb:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
			self.sb:RegisterEvent("UNIT_SPELLCAST_STOP")
			self.sb:RegisterEvent("UNIT_SPELLCAST_FAILED")
			self.sb:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
			self.sb:RegisterEvent("UNIT_SPELLCAST_DELAYED")
			self.sb:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
			self.sb:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
			self.sb:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

			self.sb.unit = BarUnits[self.data.unit]
			self.sb.showIcon = self.config.showIcon

			self.sb.showTradeSkills = true
			self.sb.casting = nil
			self.sb.channeling = nil
			self.sb.holdTime = 0

			self.sb:SetScript("OnEvent", STATUS.CastBar_OnEvent)
			self.sb:SetScript("OnUpdate", STATUS.CastBar_OnUpdate)

			if (not self.sb.cbtimer.castInfo) then
				self.sb.cbtimer.castInfo = {}
			else
				wipe(self.sb.cbtimer.castInfo)
			end

			self.sb.cbtimer:RegisterEvent("UNIT_SPELLCAST_START")
			self.sb.cbtimer:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
			self.sb.cbtimer:RegisterEvent("UNIT_SPELLCAST_STOP")
			self.sb.cbtimer:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
			self.sb.cbtimer:SetScript("OnEvent", STATUS.CastBarTimer_OnEvent)

			self.CastBar_OnEvent(self.sb)

			self.sb:Hide()

		elseif (self.config.sbType == "xp") then

			self:SetAttribute("hasaction", true)

			self:SetScript("OnEnter", STATUS.OnEnter)
			self:SetScript("OnLeave", STATUS.OnLeave)
			self:SetHitRectInsets(0, 0, 0, 0)

			self.sb:RegisterEvent("PLAYER_XP_UPDATE")
			self.sb:RegisterEvent("UPDATE_EXHAUSTION")
			self.sb:RegisterEvent("PLAYER_ENTERING_WORLD")

			self.sb:SetScript("OnEvent", STATUS.XPBar_OnEvent)

			self.sb:Show()

		elseif (self.config.sbType == "rep") then

			self.sb.repID = self.data.repID

			self:SetAttribute("hasaction", true)

			self:RegisterForClicks("RightButtonUp")
			self:SetScript("OnClick", STATUS.OnClick)
			self:SetScript("OnEnter", STATUS.OnEnter)
			self:SetScript("OnLeave", STATUS.OnLeave)
			self:SetHitRectInsets(0, 0, 0, 0)

			self:RepBar_DropDown_OnLoad()

			self.sb:RegisterEvent("UPDATE_FACTION")
			self.sb:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
			self.sb:RegisterEvent("PLAYER_ENTERING_WORLD")

			self.sb:SetScript("OnEvent", repbar_OnEvent)

			self.sb:Show()

		elseif (self.config.sbType == "mirror") then

			self.sb:SetScript("OnUpdate",  STATUS.MirrorBar_OnUpdate)

			tinsert(MirrorBars, self)

			self.sb:Hide()

		end

		self.editframe.feedback.text:SetText(LSTAT[self.config.sbType:upper().."_BAR"])

	end

	self:SetData(self.bar)

end

function STATUS:SetFauxState(state)

	-- empty

end

local OBJEDITOR_MT = { __index = OBJEDITOR }

function STATUS:CreateEditFrame(index)

	local OBJEDITOR = CreateFrame("Button", self:GetName().."EditFrame", self, "IonEditFrameTemplate")

	setmetatable(OBJEDITOR, OBJEDITOR_MT)

	OBJEDITOR:EnableMouseWheel(true)
	OBJEDITOR:RegisterForClicks("AnyDown")
	OBJEDITOR:SetAllPoints(self)
	OBJEDITOR:SetScript("OnShow", OBJEDITOR.OnShow)
	OBJEDITOR:SetScript("OnHide", OBJEDITOR.OnHide)
	OBJEDITOR:SetScript("OnEnter", OBJEDITOR.OnEnter)
	OBJEDITOR:SetScript("OnLeave", OBJEDITOR.OnLeave)
	OBJEDITOR:SetScript("OnClick", OBJEDITOR.OnClick)

	OBJEDITOR.type:SetText("")
	OBJEDITOR.object = self
	OBJEDITOR.editType = "status"

	self.OBJEDITOR = OBJEDITOR

	EDITIndex["STATUS"..index] = OBJEDITOR

	OBJEDITOR:Hide()

end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Ion-StatusBars") then

		CastingBarFrame:UnregisterAllEvents()
		CastingBarFrame:Hide()

		UIParent:UnregisterEvent("MIRROR_TIMER_START")
		MirrorTimer1:UnregisterAllEvents()
		MirrorTimer2:UnregisterAllEvents()
		MirrorTimer3:UnregisterAllEvents()

		GDB = IonStatusGDB; CDB = IonStatusCDB

		for k,v in pairs(defGDB) do
			if (GDB[k] == nil) then
				GDB[k] = v
			end
		end

		for k,v in pairs(defCDB) do
			if (CDB[k] == nil) then
				CDB[k] = v
			end
		end

		statusbarsGDB = GDB.statusbars
		statusbarsCDB = CDB.statusbars

		statusbtnsGDB = GDB.statusbtns
		statusbtnsCDB = CDB.statusbtns

		ION:RegisterBarClass("status", "Status Bar Group", "Status Bar", statusbarsGDB, statusbarsCDB, STATUSIndex, statusbtnsGDB, "Button", "IonStatusBarTemplate", { __index = STATUS }, false, false, STORAGE, nil, nil, true)

		ION:RegisterGUIOptions("status", { AUTOHIDE = true, SHOWGRID = false, SPELLGLOW = false, SNAPTO = true, DUALSPEC = false, HIDDEN = true, LOCKBAR = false, TOOLTIPS = true }, false)

		if (GDB.firstRun) then

			local oid, offset = 1, 0

			for id, defaults in ipairs(gDef) do

				ION.RegisteredBarData["status"].gDef = defaults

				local bar, object = ION:CreateNewBar("status", id, true)

				if (id == 4) then
					for i=1,3 do
						object = ION:CreateNewObject("status", oid+offset, true)
						bar:AddObjectToList(object)
						offset = offset + 1
					end
				else
					object = ION:CreateNewObject("status", oid+offset, true)
					bar:AddObjectToList(object)
					offset = offset + 1
				end

				ION.RegisteredBarData["status"].gDef = nil
			end

			GDB.firstRun = false

		else

			for id,data in pairs(statusbarsGDB) do
				if (data ~= nil) then
					ION:CreateNewBar("status", id)
				end
			end

			for id,data in pairs(statusbtnsGDB) do
				if (data ~= nil) then
					ION:CreateNewObject("status", id)
				end
			end
		end

		STORAGE:Hide()

	elseif (event == "PLAYER_LOGIN") then

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		local timer, value, maxvalue, scale, paused, label

		for i=1,MIRRORTIMER_NUMTIMERS do

			timer, value, maxvalue, scale, paused, label = GetMirrorTimerInfo(i)

			if (timer ~= "UNKNOWN") then
				mbStart(timer, value, maxvalue, scale, paused, label)
			end
		end

		PEW = true

	elseif (event == "PLAYER_XP_UPDATE" or event == "UPDATE_EXHAUSTION") then

		xpstrings_Update()

	elseif (event == "UPDATE_FACTION" or event == "CHAT_MSG_COMBAT_FACTION_CHANGE") then

		repstrings_Update(...)

	elseif (event == "MIRROR_TIMER_START") then

		mirrorbar_Start(...)

	elseif (event == "MIRROR_TIMER_STOP") then

		mirrorbar_Stop(select(1,...))

	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
--xp
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("UPDATE_EXHAUSTION")
--rep
frame:RegisterEvent("UPDATE_FACTION")
frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
--mirror
frame:RegisterEvent("MIRROR_TIMER_START")
frame:RegisterEvent("MIRROR_TIMER_STOP")
