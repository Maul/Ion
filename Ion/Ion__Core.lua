--Ion, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

Ion = {
	SLASHCMDS = {},
	SLASHHELP = {},
	sIndex = {},
	iIndex = { [1] = "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK" },
	cIndex = {},
	ShowGrids = {},
	HideGrids = {},
	BARIndex = {},
	BARNameIndex = {},
	BTNIndex = {},
	EDITIndex = {},
	BINDIndex = {},
	ModuleIndex = 0,
	RegisteredBarData = {},
	RegisteredGUIData = {},
	MacroDrag = {},
	StartDrag = false,
	maxActionID = 132,
	maxPetID = 10,
	OpDep = false,
}

IonGDB = {

	bars = {},
	buttons = {},

	buttonLoc = { -0.85, -111.45 },
	buttonRadius = 87.5,

	throttle = 0.2,
	timerLimit = 4,
	snapToTol = 28,

	mainbar = false,
	vehicle = false,

	firstRun = true,
}

IonCDB = {

	bars = {},
	buttons = {},

	selfCast = false,
	focusCast = false,

	layOut = 1,

	perCharBinds = false,

	debug = {},
}

IonSpec = { cSpec = 1 }

IonItemCache = {}

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

local ION, BAR = Ion

local BARIndex, BARNameIndex, BTNIndex, ICONS = ION.BARIndex, ION.BARNameIndex, ION.BTNIndex, ION.iIndex

local icons = {}

ION.Points = { R = "RIGHT", L = "LEFT", T = "TOP", B = "BOTTOM", TL = "TOPLEFT", TR = "TOPRIGHT", BL = "BOTTOMLEFT", BR = "BOTTOMRIGHT", C = "CENTER" }

ION.Stratas = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "TOOLTIP" }

ION.STATES = {

	homestate = L.HOMESTATE,
	laststate = L.LASTSTATE,
	paged1 = L.PAGED1,
	paged2 = L.PAGED2,
	paged3 = L.PAGED3,
	paged4 = L.PAGED4,
	paged5 = L.PAGED5,
	paged6 = L.PAGED6,
	pet0 = L.PET0,
	pet1 = L.PET1,
	alt0 = L.ALT0,
	alt1 = L.ALT1,
	ctrl0 = L.CTRL0,
	ctrl1 = L.CTRL1,
	shift0 = L.SHIFT0,
	shift1 = L.SHIFT1,
	stealth0 = L.STEALTH0,
	stealth1 = L.STEALTH1,
	reaction0 = L.REACTION0,
	reaction1 = L.REACTION1,
	combat0 = L.COMBAT0,
	combat1 = L.COMBAT1,
	group0 = L.GROUP0,
	group1 = L.GROUP1,
	group2 = L.GROUP2,
	fishing0 = L.FISHING0,
	fishing1 = L.FISHING1,
	vehicle0 = L.VEHICLE0,
	vehicle1 = L.VEHICLE1,
	custom0 = L.CUSTOM0,

}

ION.STATEINDEX = {

	paged = L.PAGED,
	stance = L.STANCE,
	pet = L.PET,
	alt = L.ALT,
	ctrl = L.CTRL,
	shift = L.SHIFT,
	stealth = L.STEALTH,
	reaction = L.REACTION,
	combat = L.COMBAT,
	group = L.GROUP,
	fishing = L.FISHING,
	vehicle = L.VEHICLE,
	custom = L.CUSTOM,

	[L.PAGED] = "paged",
	[L.STANCE] = "stance",
	[L.PET] = "pet",
	[L.ALT] = "alt",
	[L.CTRL] = "ctrl",
	[L.SHIFT] = "shift",
	[L.STEALTH] = "stealth",
	[L.REACTION] = "reaction",
	[L.COMBAT] = "combat",
	[L.GROUP] = "group",
	[L.FISHING] = "fishing",
	[L.VEHICLE] = "vehicle",
	[L.CUSTOM] = "custom",

}

local handler = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")

local opDepList = { "BarKeep", "Bartender4", "Dominos", "MagnetButtons", "nMainbar", "rActionBarStyler", "Orbs", "RazerNaga", "StellarBars", "Tukui", "XBar" }

local level, stanceStringsUpdated, PEW

function ION:GetParentKeys(frame)

	if (frame == nil) then
		return
	end

	local data, childData = {}, {}
	local children, regions = { frame:GetChildren() }, { frame:GetRegions() }

	for k,v in pairs(children) do
		tinsert(data, v:GetName())
		childData = ION:GetParentKeys(v)
		for key,value in pairs(childData) do
			tinsert(data, value)
		end
	end

	for k,v in pairs(regions) do
		tinsert(data, v:GetName())
	end

	return data
end

local defGDB, GDB, defCDB, CDB, defSPEC, SPEC = CopyTable(IonGDB), CopyTable(IonGDB), CopyTable(IonCDB), CopyTable(IonCDB), CopyTable(IonSpec), CopyTable(IonSpec)

local slashFunctions = {
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
}

local count = 1

for index,func in ipairs(slashFunctions) do

	ION.SLASHCMDS[L["SLASH_CMD"..index]:lower()] = { L["SLASH_CMD"..index], L["SLASH_CMD"..index.."_DESC"], func }

	if (func and #func > 0) then
		ION.SLASHHELP[count] = "       |cff00ff00"..L["SLASH_CMD"..index].."|r: "..L["SLASH_CMD"..index.."_DESC"]
		count = count + 1
	end
end

-- "()" indexes added because the Blizzard macro parser uses that to determine the difference of a spell versus a usable item if the two happen to have the same name.
-- I forgot this fact and removed using "()" and it made some macros not represent the right spell /sigh. This note is here so I do not forget again :P

function ION:UpdateSpellIndex()

	local i, spellName, subName, altName, spellID, spellType, spellLvl, isPassive, icon, cost, powerType, curSpell, _ = 1

	repeat
		spellName, subName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
		spellType, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
		spellLvl = GetSpellAvailableLevel(i, BOOKTYPE_SPELL)
		icon = GetSpellBookItemTexture(i, BOOKTYPE_SPELL)
		isPassive = IsPassiveSpell(i, BOOKTYPE_SPELL)

		if (spellName and spellType ~= "FUTURESPELL") then

			altName, _, _, cost, _, powerType = GetSpellInfo(spellID)

			if (subName and #subName > 0) then

				if (not ION.sIndex[(spellName.."("..subName..")"):lower()]) then
					ION.sIndex[(spellName.."("..subName..")"):lower()] = {}
				end

				curSpell = ION.sIndex[(spellName.."("..subName..")"):lower()]

				curSpell.index = i
				curSpell.booktype = BOOKTYPE_SPELL
				curSpell.spellName = spellName
				curSpell.subName = subName
				curSpell.spellID = spellID
				curSpell.spellType = spellType
				curSpell.spellLvl = spellLvl
				curSpell.spellCost = cost
				curSpell.isPassive = isPassive
				curSpell.icon = icon
				curSpell.powerType = powerType

			else

				if (not ION.sIndex[(spellName):lower()]) then
					ION.sIndex[(spellName):lower()] = {}
				end

				curSpell = ION.sIndex[(spellName):lower()]

				curSpell.index = i
				curSpell.booktype = BOOKTYPE_SPELL
				curSpell.spellName = spellName
				curSpell.subName = subName
				curSpell.spellID = spellID
				curSpell.spellType = spellType
				curSpell.spellLvl = spellLvl
				curSpell.spellCost = cost
				curSpell.isPassive = isPassive
				curSpell.icon = icon
				curSpell.powerType = powerType

				if (not ION.sIndex[(spellName):lower().."()"]) then
					ION.sIndex[(spellName):lower().."()"] = {}
				end

				curSpell = ION.sIndex[(spellName):lower().."()"]

				curSpell.index = i
				curSpell.booktype = BOOKTYPE_SPELL
				curSpell.spellName = spellName
				curSpell.subName = subName
				curSpell.spellID = spellID
				curSpell.spellType = spellType
				curSpell.spellLvl = spellLvl
				curSpell.spellCost = cost
				curSpell.isPassive = isPassive
				curSpell.icon = icon
				curSpell.powerType = powerType
			end

			if (altName and altName ~= spellName) then

				if (subName and #subName > 0) then

					if (not ION.sIndex[(altName.."("..subName..")"):lower()]) then
						ION.sIndex[(altName.."("..subName..")"):lower()] = {}
					end

					curSpell = ION.sIndex[(altName.."("..subName..")"):lower()]

					curSpell.index = i
					curSpell.booktype = BOOKTYPE_SPELL
					curSpell.spellName = spellName
					curSpell.subName = subName
					curSpell.spellID = spellID
					curSpell.spellType = spellType
					curSpell.spellLvl = spellLvl
					curSpell.spellCost = cost
					curSpell.isPassive = isPassive
					curSpell.icon = icon
					curSpell.powerType = powerType

				else

					if (not ION.sIndex[(altName):lower()]) then
						ION.sIndex[(altName):lower()] = {}
					end

					curSpell = ION.sIndex[(altName):lower()]

					curSpell.index = i
					curSpell.booktype = BOOKTYPE_SPELL
					curSpell.spellName = spellName
					curSpell.subName = subName
					curSpell.spellID = spellID
					curSpell.spellType = spellType
					curSpell.spellLvl = spellLvl
					curSpell.spellCost = cost
					curSpell.isPassive = isPassive
					curSpell.icon = icon
					curSpell.powerType = powerType

					if (not ION.sIndex[(altName):lower().."()"]) then
						ION.sIndex[(altName):lower().."()"] = {}
					end

					curSpell = ION.sIndex[(altName):lower().."()"]

					curSpell.index = i
					curSpell.booktype = BOOKTYPE_SPELL
					curSpell.spellName = spellName
					curSpell.subName = subName
					curSpell.spellID = spellID
					curSpell.spellType = spellType
					curSpell.spellLvl = spellLvl
					curSpell.spellCost = cost
					curSpell.isPassive = isPassive
					curSpell.icon = icon
					curSpell.powerType = powerType
				end
			end

			if (spellID) then

				if (not ION.sIndex[spellID]) then
					ION.sIndex[spellID] = {}
				end

				curSpell = ION.sIndex[spellID]

				curSpell.index = i
				curSpell.booktype = BOOKTYPE_SPELL
				curSpell.spellName = spellName
				curSpell.subName = subName
				curSpell.spellID = spellID
				curSpell.spellType = spellType
				curSpell.spellLvl = spellLvl
				curSpell.spellCost = cost
				curSpell.isPassive = isPassive
				curSpell.icon = icon
				curSpell.powerType = powerType
			end

	   		if (icon and not icons[icon:upper()]) then
	   			ICONS[#ICONS+1] = icon:upper(); icons[icon:upper()] = true
	   		end
   		end

   		i = i + 1

   	until (not spellName)

	i = 1

	repeat
		spellName, subName = GetSpellBookItemName(i, BOOKTYPE_PET)
		spellType, spellID = GetSpellBookItemInfo(i, BOOKTYPE_PET)
		spellLvl = GetSpellAvailableLevel(i, BOOKTYPE_PET)
		icon = GetSpellBookItemTexture(i, BOOKTYPE_PET)
		isPassive = IsPassiveSpell(i, BOOKTYPE_PET)

		if (spellName and spellType ~= "FUTURESPELL") then

			_, _, icon, cost, _, powerType = GetSpellInfo(spellName)

			if (subName and #subName > 0) then

				if (not ION.sIndex[(spellName.."("..subName..")"):lower()]) then
					ION.sIndex[(spellName.."("..subName..")"):lower()] = {}
				end

				curSpell = ION.sIndex[(spellName.."("..subName..")"):lower()]

				curSpell.index = i
				curSpell.booktype = BOOKTYPE_PET
				curSpell.spellName = spellName
				curSpell.subName = subName
				curSpell.spellID = spellID
				curSpell.spellType = spellType
				curSpell.spellLvl = spellLvl
				curSpell.spellCost = cost
				curSpell.isPassive = isPassive
				curSpell.icon = icon
				curSpell.powerType = powerType
			else

				if (not ION.sIndex[(spellName):lower()]) then
					ION.sIndex[(spellName):lower()] = {}
				end

				curSpell = ION.sIndex[(spellName):lower()]

				curSpell.index = i
				curSpell.booktype = BOOKTYPE_PET
				curSpell.spellName = spellName
				curSpell.subName = subName
				curSpell.spellID = spellID
				curSpell.spellType = spellType
				curSpell.spellLvl = spellLvl
				curSpell.spellCost = cost
				curSpell.isPassive = isPassive
				curSpell.icon = icon
				curSpell.powerType = powerType

				if (not ION.sIndex[(spellName):lower().."()"]) then
					ION.sIndex[(spellName):lower().."()"] = {}
				end

				curSpell = ION.sIndex[(spellName):lower().."()"]

				curSpell.index = i
				curSpell.booktype = BOOKTYPE_PET
				curSpell.spellName = spellName
				curSpell.subName = subName
				curSpell.spellID = spellID
				curSpell.spellType = spellType
				curSpell.spellLvl = spellLvl
				curSpell.spellCost = cost
				curSpell.isPassive = isPassive
				curSpell.icon = icon
				curSpell.powerType = powerType
			end

			if (spellID) then

				if (not ION.sIndex[spellID]) then
					ION.sIndex[spellID] = {}
				end

				curSpell = ION.sIndex[spellID]

				curSpell.index = i
				curSpell.booktype = BOOKTYPE_PET
				curSpell.spellName = spellName
				curSpell.subName = subName
				curSpell.spellID = spellID
				curSpell.spellType = spellType
				curSpell.spellLvl = spellLvl
				curSpell.spellCost = cost
				curSpell.isPassive = isPassive
				curSpell.icon = icon
				curSpell.powerType = powerType
			end

	   		if (icon and not icons[icon:upper()]) then
	   			ICONS[#ICONS+1] = icon:upper(); icons[icon:upper()] = true
	   		end
   		end

   		i = i + 1

   	until (not spellName)

	-- a lot of work to associate the Call Pet spell with the pet's name so that tooltips work on Call Pet spells. /sigh
	local _, _, numSlots, isKnown = GetFlyoutInfo(9)
	local petIndex, petName

	for i=1, numSlots do

		spellID, isKnown = GetFlyoutSlotInfo(9, i)
		petIndex, petName = GetCallPetSpellInfo(spellID)

		if (isKnown and petIndex and petName and #petName > 0) then

			spellName = GetSpellInfo(spellID)

			for k,v in pairs(ION.sIndex) do

				if (v.spellName:find(petName.."$")) then

					if (not ION.sIndex[(spellName):lower()]) then
						ION.sIndex[(spellName):lower()] = {}
					end

					curSpell = ION.sIndex[(spellName):lower()]

					curSpell.index = v.index
					curSpell.booktype = v.booktype
					curSpell.spellName = v.spellName
					curSpell.subName = v.subName
					curSpell.spellID = spellID
					curSpell.spellType = v.spellType
					curSpell.spellLvl = v.spellLvl
					curSpell.spellCost = v.spellCost
					curSpell.isPassive = v.isPassive
					curSpell.icon = v.icon
					curSpell.powerType = v.powerType

					if (not ION.sIndex[(spellName):lower().."()"]) then
						ION.sIndex[(spellName):lower().."()"] = {}
					end

					curSpell = ION.sIndex[(spellName):lower().."()"]

					curSpell.index = v.index
					curSpell.booktype = v.booktype
					curSpell.spellName = v.spellName
					curSpell.subName = v.subName
					curSpell.spellID = spellID
					curSpell.spellType = v.spellType
					curSpell.spellLvl = v.spellLvl
					curSpell.spellCost = v.spellCost
					curSpell.isPassive = v.isPassive
					curSpell.icon = v.icon
					curSpell.powerType = v.powerType

					if (not ION.sIndex[spellID]) then
						ION.sIndex[spellID] = {}
					end

					curSpell = ION.sIndex[spellID]

					curSpell.index = v.index
					curSpell.booktype = v.booktype
					curSpell.spellName = v.spellName
					curSpell.subName = v.subName
					curSpell.spellID = spellID
					curSpell.spellType = v.spellType
					curSpell.spellLvl = v.spellLvl
					curSpell.spellCost = v.spellCost
					curSpell.isPassive = v.isPassive
					curSpell.icon = v.icon
					curSpell.powerType = v.powerType

				end
			end
		end
	end

	-- maybe a temp fix to get the Sunfire spell to show for balance druids
	if (ION.class == "DRUID") then

		local spellName, _, icon, cost, _, powerType = GetSpellInfo(93402)

		if (ION.sIndex[8921]) then

			if (not ION.sIndex[(spellName):lower()]) then
				ION.sIndex[(spellName):lower()] = {}
			end

			curSpell = ION.sIndex[(spellName):lower()]

			curSpell.index = ION.sIndex[8921].index
			curSpell.booktype = ION.sIndex[8921].booktype
			curSpell.spellName = spellName
			curSpell.subName = nil
			curSpell.spellID = 93402
			curSpell.spellType = "SPELL"
			curSpell.spellLvl = ION.sIndex[8921].spellLvl
			curSpell.spellCost = cost
			curSpell.isPassive = nil
			curSpell.icon = icon
			curSpell.powerType = powerType

			if (not ION.sIndex[(spellName):lower().."()"]) then
				ION.sIndex[(spellName):lower().."()"] = {}
			end

			curSpell = ION.sIndex[(spellName):lower().."()"]

			curSpell.index = ION.sIndex[8921].index
			curSpell.booktype = ION.sIndex[8921].booktype
			curSpell.spellName = spellName
			curSpell.subName = nil
			curSpell.spellID = 93402
			curSpell.spellType = "SPELL"
			curSpell.spellLvl = ION.sIndex[8921].spellLvl
			curSpell.spellCost = cost
			curSpell.isPassive = nil
			curSpell.icon = icon
			curSpell.powerType = powerType

			if (not ION.sIndex[93402]) then
				ION.sIndex[93402] = {}
			end

			curSpell = ION.sIndex[(spellName):lower().."()"]

			curSpell.index = ION.sIndex[8921].index
			curSpell.booktype = ION.sIndex[8921].booktype
			curSpell.spellName = spellName
			curSpell.subName = nil
			curSpell.spellID = 93402
			curSpell.spellType = "SPELL"
			curSpell.spellLvl = ION.sIndex[8921].spellLvl
			curSpell.spellCost = cost
			curSpell.isPassive = nil
			curSpell.icon = icon
			curSpell.powerType = powerType
		end
	end
end

function ION:UpdateCompanionData()

	local creatureID, creatureName, spellID, icon, spell, curComp

	for i=1,GetNumCompanions("CRITTER") do

		creatureID, creatureName, spellID, icon = GetCompanionInfo("CRITTER", i)

		if (spellID) then

			spell = GetSpellInfo(spellID)

			if (spell) then

				if (not ION.cIndex[spell:lower()]) then
					ION.cIndex[spell:lower()] = {}
				end

				curComp = ION.cIndex[spell:lower()]

				curComp.creatureType = "CRITTER"
				curComp.index = i
				curComp.creatureID = creatureID
				curComp.creatureName = creatureName
				curComp.spellID = spellID
				curComp.icon = icon

				if (not ION.cIndex[spell:lower().."()"]) then
					ION.cIndex[spell:lower().."()"] = {}
				end

				curComp = ION.cIndex[spell:lower().."()"]

				curComp.creatureType = "CRITTER"
				curComp.index = i
				curComp.creatureID = creatureID
				curComp.creatureName = creatureName
				curComp.spellID = spellID
				curComp.icon = icon

				if (not ION.cIndex[spellID]) then
					ION.cIndex[spellID] = {}
				end

				curComp = ION.cIndex[spellID]

				curComp.creatureType = "CRITTER"
				curComp.index = i
				curComp.creatureID = creatureID
				curComp.creatureName = creatureName
				curComp.spellID = spellID
				curComp.icon = icon

		   		if (icon and not icons[icon:upper()]) then
		   			ICONS[#ICONS+1] = icon:upper(); icons[icon:upper()] = true
		   		end
			end
		end
	end

	for i=1,GetNumCompanions("MOUNT") do

		creatureID, creatureName, spellID, icon = GetCompanionInfo("MOUNT", i)

		if (spellID) then

			spell = GetSpellInfo(spellID)

			if (spell) then

				if (not ION.cIndex[spell:lower()]) then
					ION.cIndex[spell:lower()] = {}
				end

				curComp = ION.cIndex[spell:lower()]

				curComp.creatureType = "MOUNT"
				curComp.index = i
				curComp.creatureID = creatureID
				curComp.creatureName = creatureName
				curComp.spellID = spellID
				curComp.icon = icon

				if (not ION.cIndex[spell:lower().."()"]) then
					ION.cIndex[spell:lower().."()"] = {}
				end

				curComp = ION.cIndex[spell:lower().."()"]

				curComp.creatureType = "MOUNT"
				curComp.index = i
				curComp.creatureID = creatureID
				curComp.creatureName = creatureName
				curComp.spellID = spellID
				curComp.icon = icon

				if (not ION.cIndex[spellID]) then
					ION.cIndex[spellID] = {}
				end

				curComp = ION.cIndex[spellID]

				curComp.creatureType = "MOUNT"
				curComp.index = i
				curComp.creatureID = creatureID
				curComp.creatureName = creatureName
				curComp.spellID = spellID
				curComp.icon = icon

		   		if (icon and not icons[icon:upper()]) then
		   			ICONS[#ICONS+1] = icon:upper(); icons[icon:upper()] = true
		   		end
			end
		end
	end
end

local temp = {}

function ION:UpdateIconIndex()

	local icon

	wipe(temp)

	GetMacroIcons(temp)
	--GetMacroItemIcons(temp)

	for k,v in ipairs(temp) do

		icon = "INTERFACE\\ICONS\\"..v:upper()

   		if (not icons[icon:upper()]) then
   			ICONS[#ICONS+1] = icon:upper(); icons[icon:upper()] = true
   		end
   	end
end

function ION:UpdateStanceStrings()

	if (ION.class == "DRUID" or
	    ION.class == "PRIEST" or
	    ION.class == "ROGUE" or
	    ION.class == "WARRIOR" or
	    ION.class == "WARLOCK") then

		local _, name

		for i=1,GetNumShapeshiftForms() do

			_, name = GetShapeshiftFormInfo(i)

			if (name) then
				ION.STATES["stance"..i] = name
			end
		end

		if (not stanceStringsUpdated) then

			if (ION.class == "DRUID") then

				ION.STATES.stance0 = L.DRUID_STANCE0

				ION.STATES.stance8 = L.DRUID_PROWL

			end

			if (ION.class == "PRIEST") then

				ION.STATES.stance0 = L.PRIEST_HEALER

			end

			if (ION.class == "ROGUE") then

				ION.STATES.stance0 = L.ROGUE_ATTACK

				ION.MAS.stance.states = ION.MAS.stance.states:gsub("%[stance:1%]", "[stance:1/2]")

			end

			if (ION.class == "WARLOCK") then

				ION.STATES.stance0 = L.WARLOCK_CASTER

			end

			if (ION.class == "WARRIOR") then

				ION.STATES.stance0 = ATTRIBUTE_NOOP

				ION.MAS.stance.homestate = "stance1"
			end

			stanceStringsUpdated = true
		end
	end
end

local function printSlashHelp()

	print(L.SLASH_HINT1)
	print(L.SLASH_HINT2)

	for k,v in ipairs(ION.SLASHHELP) do
		print(v)
	end
end

local commands = {}

local function slashHandler(msg)

	wipe(commands)

	if ((not msg) or (strlen(msg) <= 0)) then

		printSlashHelp()

		return
	end

	(msg):gsub("(%S+)", function(cmd) tinsert(commands, cmd) end)

	if (ION.SLASHCMDS[commands[1]:lower()]) then

		local command

		for k,v in ipairs(commands) do
			if (k ~= 1) then
				if (not command) then
					command = v
				else
					command = command.." "..v
				end
			end
		end

		if (commands) then

			local func = ION.SLASHCMDS[commands[1]:lower()][3]
			local bar = ION.CurrentBar

			if (ION[func]) then

				ION[func](ION, command)

			elseif (bar and bar[func]) then

				bar[func](bar, command)

			else
				print(L.SELECT_BAR)
			end

		end
	else
		printSlashHelp()
	end

end


function ION:EditBox_PopUpInitialize(popupFrame, data)

	popupFrame.func = ION.PopUp_Update
	popupFrame.data = data

	ION.PopUp_Update(popupFrame)
end

function ION:PopUp_Update(popupFrame)

	local data, columns, optionText = popupFrame.data, 1
	local count, height, width, widthMult, option, lastOption, lastAnchor = 1,0, popupFrame:GetParent():GetWidth(), 1, nil, nil, nil

	if (popupFrame.options) then
		for k,v in pairs(popupFrame.options) do
			v:Hide()
		end
	end

	popupFrame.array = {}

	if (not data) then
		return
	end

	for k,v in pairs(data) do

		if (type(v) == "string") then
			popupFrame.array[count] = k..","..v
		else
			popupFrame.array[count] = k
		end

		count = count + 1
	end

	table.sort(popupFrame.array)

	count = 1

	columns = (math.ceil(#popupFrame.array/20)) or 1

	for i=1,#popupFrame.array do

		popupFrame.array[i] = gsub(popupFrame.array[i], "%s+", " ")
		popupFrame.array[i] = gsub(popupFrame.array[i], "^%s+", "")

		if (not popupFrame.options[i]) then
			option = CreateFrame("Button", popupFrame:GetName().."Option"..i, popupFrame, "IonPopupButtonTemplate")
			option:SetHeight(14)

			popupFrame.options[i] = option
		else
			option = _G[popupFrame:GetName().."Option"..i]
			popupFrame.options[i] = option
		end

		optionText = _G[option:GetName().."Text"]

		local text = popupFrame.array[i]:match("^[^,]+") or ""

		text = text:gsub("^%d+_", "")

		optionText:SetText(text)

		option.value = popupFrame.array[i]:match("[^,]+$")

		if (optionText:GetWidth()+20 > width and optionText:GetWidth()+20 < 250) then
			width = _G[option:GetName().."Text"]:GetWidth() + 20
		end

		option:ClearAllPoints()

		if (count == 1) then
			if (lastAnchor) then
				option:SetPoint("LEFT", lastAnchor, "RIGHT", 0, 0)
				lastOption = option
				lastAnchor = option

			else
				option:SetPoint("TOPLEFT", popupFrame, "TOPLEFT", 0, -5)
				lastOption = option
				lastAnchor = option
			end
		else
			option:SetPoint("TOP", lastOption, "BOTTOM", 0, -1)
			lastOption = option
		end

		if (widthMult == 1) then
			height = height + 15
		end

		count = count + 1

		if (count > math.ceil(#popupFrame.array/columns) and widthMult < columns and columns > 1) then
			widthMult = widthMult + 1
			count = 1
		end

		option:Show()
	end

	if (popupFrame.options) then
		for k,v in pairs(popupFrame.options) do
			v:SetWidth(width)
		end
	end

	popupFrame:SetWidth(width * widthMult)

	if (popupFrame:GetParent():GetHeight() > height + 10) then
		popupFrame:SetHeight(popupFrame:GetParent():GetHeight())
	else
		popupFrame:SetHeight(height + 10)
	end
end

--From wowwiki.com
local minimapShapes = {

	-- quadrant booleans (same order as SetTexCoord)
	-- {upper-left, lower-left, upper-right, lower-right}
	-- true = rounded, false = squared

	["ROUND"] 			= {true, true, true, true},
	["SQUARE"] 			= {false, false, false, false},
	["CORNER-TOPLEFT"] 		= {true, false, false, false},
	["CORNER-TOPRIGHT"] 		= {false, false, true, false},
	["CORNER-BOTTOMLEFT"] 		= {false, true, false, false},
	["CORNER-BOTTOMRIGHT"]	 	= {false, false, false, true},
	["SIDE-LEFT"] 			= {true, true, false, false},
	["SIDE-RIGHT"] 			= {false, false, true, true},
	["SIDE-TOP"] 			= {true, false, true, false},
	["SIDE-BOTTOM"] 		= {false, true, false, true},
	["TRICORNER-TOPLEFT"] 		= {true, true, true, false},
	["TRICORNER-TOPRIGHT"] 		= {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"] 	= {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"] 	= {false, true, true, true},
}

local function updatePoint(self, elapsed)

	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > 0.025) then

		self.l = self.l + 0.0625
		self.r = self.r + 0.0625

		if (self.r > 1) then
			self.l = 0
			self.r = 0.0625
			self.b = self.b + 0.0625
		end

		if (self.b > 1) then
			self.l = 0
			self.r = 0.0625
			self.b = 0.0625
		end

		self.t = self.b - (0.0625 * self.tadj)

		if (self.t < 0) then self.t = 0 end
		if (self.t > 1) then self.t = 1 end

		self.texture:SetTexCoord(self.l, self.r, self.t, self.b)

		self.elapsed = 0
	end
end

local function createMiniOrb(parent, index, prefix)

	local point = CreateFrame("Frame", prefix..index, parent, "IonMiniOrbTemplate")

	point:SetScript("OnUpdate", updatePoint)
	point.tadj = 1
	point.elapsed = 0

	local row, col = random(0,15), random(0,15)

	point.l = 0.0625 * row; point.r = point.l + 0.0625
	point.t = 0.0625 * col; point.b = point.t + 0.0625

	point.texture:SetTexture("Interface\\AddOns\\Ion\\Images\\seq_smoke")
	point.texture:SetTexCoord(point.l, point.r, point.t, point.b)

	return point
end

function ION:DragFrame_OnUpdate(x, y)

	local pos, quad, round, radius = nil, nil, nil, GDB.buttonRadius - IonMinimapButton:GetWidth()/math.pi
	local sqRad = sqrt(2*(radius)^2)

	local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()

	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = minimapShapes[minimapShape]

	local xpos, ypos = x, y

	if (not xpos or not ypos) then
		xpos, ypos = GetCursorPosition()
	end

	xpos = xmin - xpos / Minimap:GetEffectiveScale() + radius
	ypos = ypos / Minimap:GetEffectiveScale() - ymin - radius

	pos = math.deg(math.atan2(ypos,xpos))

	xpos = cos(pos)
	ypos = sin(pos)

	if (xpos > 0 and ypos > 0) then
		quad = 1 --topleft
	elseif (xpos > 0 and ypos < 0) then
		quad = 2 --bottomleft
	elseif (xpos < 0 and ypos > 0) then
		quad = 3 --topright
	elseif (xpos < 0 and ypos < 0) then
		quad = 4 --bottomright
	end

	round = quadTable[quad]

	if (round) then
		xpos = xpos * radius
		ypos = ypos * radius
	else
		xpos = max(-radius, min(xpos * sqRad, radius))
		ypos = max(-radius, min(ypos * sqRad, radius))
	end

	IonMinimapButton:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 52-xpos, ypos-55)

	GDB.buttonLoc = { 52-xpos, ypos-55 }
end

function ION:MinimapButton_OnLoad(minimap)

	minimap:RegisterForClicks("AnyUp")
	minimap:RegisterForDrag("LeftButton")
	minimap:RegisterEvent("PLAYER_LOGIN")
	minimap.elapsed = 0
	minimap.x = 0
	minimap.y = 0
	minimap.count = 1
	minimap.angle = 0
	minimap:SetFrameStrata(MinimapCluster:GetFrameStrata())
	minimap:SetFrameLevel(MinimapCluster:GetFrameLevel()+3)
	minimap:GetHighlightTexture():SetAlpha(0.3)

end

function ION:MinimapButton_OnEvent(minimap)

	minimap.orb = createMiniOrb(minimap, 1, "IonMinimapOrb")
	minimap.orb:SetPoint("CENTER", minimap, "CENTER", 0.5, 0.5)
	minimap.orb:SetScale(2)
	minimap.orb:SetFrameLevel(minimap:GetFrameLevel())
	minimap.orb.texture:SetVertexColor(1,0,0)

	ION:MinimapButton_OnDragStop(minimap)

end

function ION:MinimapButton_OnDragStart(minimap)

	minimap:LockHighlight()
	minimap:StartMoving()
	IonMinimapButtonDragFrame:Show()
end

function ION:MinimapButton_OnDragStop(minimap)

	if (minimap) then

		minimap:UnlockHighlight()
		minimap:StopMovingOrSizing()
		minimap:SetUserPlaced(false)
		minimap:ClearAllPoints()
		if (GDB and GDB.buttonLoc) then
			minimap:SetPoint("TOPLEFT", "Minimap","TOPLEFT", GDB.buttonLoc[1], GDB.buttonLoc[2])
		end
		IonMinimapButtonDragFrame:Hide()
	end
end

function ION:MinimapButton_OnShow(minimap)

	if (GDB) then
		ION:MinimapButton_OnDragStop(minimap)
	end
end

function ION:MinimapButton_OnHide(minimap)

	minimap:UnlockHighlight()
	IonMinimapButtonDragFrame:Hide()
end

function ION:MinimapButton_OnEnter(minimap)


	GameTooltip:Show()
end

function ION:MinimapButton_OnLeave(minimap)

	GameTooltip:Hide()
end

function ION:MinimapButton_OnClick(minimap, button)

	PlaySound("igChatScrollDown")

	if (InCombatLockdown()) then return end

	if (button == "RightButton") then
		ION:ToggleEditFrames()
	elseif (IsAltKeyDown()) then
		ION:ToggleBindings()
	else
		ION:ToggleBars()
	end
end

function ION:MinimapMenuClose()
	IonMinimapButton.popup:Hide()
end

function ION:UpdateData(data, defaults)

	-- Add new vars
	for key,value in pairs(defaults) do

		if (data[key] == nil) then

			if (data[key:lower()] ~= nil) then

				data[key] = data[key:lower()]
				data[key:lower()] = nil
			else
				data[key] = value
			end
		end
	end
	-- Add new vars

	-- Var fixes

		---none

	-- Var fixes

	-- Kill old vars
	for key,value in pairs(data) do
		if (defaults[key] == nil) then
			data[key] = nil
		end
	end
	-- Kill old vars
end

function ION:ToggleMainMenu(on)

	if (ION.OpDep) then return end

	if (on) then

		ActionBarButtonEventsFrame_OnLoad(ActionBarButtonEventsFrame)
		ActionBarActionEventsFrame_OnLoad(ActionBarActionEventsFrame)

		MainMenuBar:SetPoint("BOTTOM", 0, 0)
		MainMenuBar_OnLoad(MainMenuBar)
		MainMenuBar:Show()

		MainMenuBar_OnLoad(MainMenuBarArtFrame)

		PossessBar_OnLoad(PossessBarFrame)

		UnregisterStateDriver(MainMenuBar, "visibility")
		UnregisterStateDriver(PossessBarFrame, "visibility")

	else

		ActionBarButtonEventsFrame:UnregisterAllEvents()
		ActionBarActionEventsFrame:UnregisterAllEvents()

		MainMenuBar:SetPoint("BOTTOM", 0, -200)
		MainMenuBar:UnregisterAllEvents()
		MainMenuBar:Hide()

		MainMenuBarArtFrame:UnregisterEvent("BAG_UPDATE");
		MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED");

		PossessBarFrame:UnregisterAllEvents()
		PossessBarFrame:Hide()

		RegisterStateDriver(MainMenuBar, "visibility", "hide")
		RegisterStateDriver(PossessBarFrame, "visibility", "hide")

	end
end

function ION:ToggleVehicleBar(on)

	if (ION.OpDep) then return end

	if (on) then

		local button
		for i=1, NUM_OVERRIDE_BUTTONS do
			button = _G["OverrideActionBarButton"..i]
			handler:WrapScript(button, "OnShow", [[
				local key = GetBindingKey("ACTIONBUTTON"..self:GetID())
				if (key) then
					self:SetBindingClick(true, key, self:GetName())
				end
			]])
			handler:WrapScript(button, "OnHide", [[
				local key = GetBindingKey("ACTIONBUTTON"..self:GetID())
				if (key) then
					self:ClearBinding(key)
				end
			]])
		end

		MainMenuBarArtFrame:RegisterEvent("UNIT_ENTERING_VEHICLE")
		MainMenuBarArtFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
		MainMenuBarArtFrame:RegisterEvent("UNIT_EXITING_VEHICLE")
		MainMenuBarArtFrame:RegisterEvent("UNIT_EXITED_VEHICLE")
		MainMenuBarArtFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

	else

		local button
		for i=1, NUM_OVERRIDE_BUTTONS do
			button = _G["OverrideActionBarButton"..i]
			handler:UnwrapScript(button, "OnShow")
			handler:UnwrapScript(button, "OnHide")
		end

		MainMenuBarArtFrame:UnregisterEvent("UNIT_ENTERING_VEHICLE")
		MainMenuBarArtFrame:UnregisterEvent("UNIT_ENTERED_VEHICLE")
		MainMenuBarArtFrame:UnregisterEvent("UNIT_EXITING_VEHICLE")
		MainMenuBarArtFrame:UnregisterEvent("UNIT_EXITED_VEHICLE")
		MainMenuBarArtFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end

end

function ION:CreateBar(index, class, id)

	local data, show = ION.RegisteredBarData[class]

	if (data) then

		if (not id) then

			id = 1

			for _ in ipairs(data.GDB) do
				id = id + 1
			end

			newBar = true
		end

		local bar

		if (_G["Ion"..data.barType..id]) then
			bar = _G["Ion"..data.barType..id]
		else
			bar = CreateFrame("CheckButton", "Ion"..data.barType..id, UIParent, "IonBarTemplate")
		end

		for key,value in pairs(data) do
			bar[key] = value
		end

		setmetatable(bar, { __index = BAR })

		bar.index = index
		bar.class = class
		bar.stateschanged = true
		bar.vischanged =true
		bar.elapsed = 0
		bar.click = nil
		bar.dragged = false
		bar.selected = false
		bar.toggleframe = bar
		bar.microAdjust = false
		bar.vis = {}
		bar.text:Hide()
		bar.message:Hide()
		bar.messagebg:Hide()

		bar:SetID(id)
		bar:SetWidth(375)
		bar:SetHeight(40)
		bar:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 12, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
		bar:SetBackdropColor(0,0,0,0.4)
		bar:SetBackdropBorderColor(0,0,0,0)
		bar:SetFrameLevel(2)
		bar:RegisterForClicks("AnyDown", "AnyUp")
		bar:RegisterForDrag("LeftButton")
		bar:SetMovable(true)
		bar:EnableKeyboard(false)
		bar:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)

		bar:SetScript("OnClick", BAR.OnClick)
		bar:SetScript("OnDragStart", BAR.OnDragStart)
		bar:SetScript("OnDragStop", BAR.OnDragStop)
		bar:SetScript("OnEnter", BAR.OnEnter)
		bar:SetScript("OnLeave", BAR.OnLeave)
		bar:SetScript("OnEvent", BAR.OnEvent)
		bar:SetScript("OnKeyDown", BAR.OnKeyDown)
		bar:SetScript("OnKeyUp", BAR.OnKeyUp)
		bar:SetScript("OnMouseWheel", BAR.OnMouseWheel)
		bar:SetScript("OnShow", BAR.OnShow)
		bar:SetScript("OnHide", BAR.OnHide)
		bar:SetScript("OnUpdate", BAR.OnUpdate)

		bar:RegisterEvent("ACTIONBAR_SHOWGRID")
		bar:RegisterEvent("ACTIONBAR_HIDEGRID")
		bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

		bar:CreateDriver()
		bar:CreateHandler()

		bar:LoadData()

		if (not newBar) then
			bar:Hide()
		end

		BARIndex[index] = bar

		BARNameIndex[bar:GetName()] = bar

		return bar, newBar
	end
end

function ION:CreateNewBar(class, id, firstRun)

	if (class and ION.RegisteredBarData[class]) then

		local index = 1

		for _ in ipairs(BARIndex) do
			index = index + 1
		end

		local bar, newBar = ION:CreateBar(index, class, id)

		if (firstRun) then
			bar:SetDefaults(bar.gDef, bar.cDef)
		end

		if (newBar) then
			bar:Load(); ION:ChangeBar(bar)
		end

		return bar
	else
		ION.PrintBarTypes()
	end
end

function ION:CreateNewObject(class, id, firstRun)

	local data = ION.RegisteredBarData[class]

	if (data) then

		local index = 1

		for _ in ipairs(data.objTable) do
			index = index + 1
		end

		object = CreateFrame(data.objFrameT, data.objPrefix..id, UIParent, data.objTemplate)

		setmetatable(object, data.objMetaT)

		object.elapsed = 0

		local objects = ION:GetParentKeys(object)

		for k,v in pairs(objects) do
			local name = (v):gsub(object:GetName(), "")
			object[name:lower()] = _G[v]
		end

		object.class = class
		object.id = id
		object:SetID(0)
		object.objTIndex = index
		object.objType = data.objType:gsub("%s", ""):upper()

		object:LoadData(GetActiveSpecGroup(), "homestate")

		if (firstRun) then
			object:SetDefaults(object:GetDefaults())
		end

		object:LoadAux()

		data.objTable[index] = { object, 1 }

		return object
	end
end

function ION:ChangeBar(bar)

	local newBar = false

	if (PEW) then

		if (bar and ION.CurrentBar ~= bar) then

			ION.CurrentBar = bar

			bar.selected = true
			bar.action = nil

			bar:SetFrameLevel(3)

			if (bar.gdata.hidden) then
				bar:SetBackdropColor(1,0,0,0.6)
			else
				bar:SetBackdropColor(0,0,1,0.5)
			end

			newBar = true
		end

		if (not bar) then
			ION.CurrentBar = nil
		elseif (bar.text) then
			bar.text:Show()
		end

		for k,v in pairs(BARIndex) do
			if (v ~= bar) then

				if (v.gdata.hidden) then
					v:SetBackdropColor(1,0,0,0.4)
				else
					v:SetBackdropColor(0,0,0,0.4)
				end

				v:SetFrameLevel(2)
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

		if (ION.CurrentBar) then
			ION.CurrentBar:OnEnter()
		end
	end

	return newBar
end

function ION:ToggleBars(show, hide)

	if (PEW) then

		if ((ION.BarsShown or hide) and not show) then

			ION.BarsShown = nil

			for index, bar in pairs(BARIndex) do
				bar:Hide(); bar:Update(nil, true)
			end

			ION:ChangeBar(nil)

			if (IonBarEditor)then
				IonBarEditor:Hide()
			end
		else

			ION:ToggleEditFrames(nil, true)

			ION.BarsShown = true

			for index, bar in pairs(BARIndex) do
				bar:Show(); bar:Update(true)
			end
		end
	end

	if (ION.BarsShown)then
		IonMinimapButton:SetFrameStrata("TOOLTIP")
		IonMinimapButton:SetFrameLevel(MinimapCluster:GetFrameLevel()+3)
	else
		IonMinimapButton:SetFrameStrata(MinimapCluster:GetFrameStrata())
		IonMinimapButton:SetFrameLevel(MinimapCluster:GetFrameLevel()+3)
	end
end

function ION:ToggleButtonGrid(show, hide)

	for id,btn in pairs(BTNIndex) do
		btn[1]:SetGrid(show, hide)
	end
end

function ION:PrintStateList()

	local data, list = {}

	for k,v in pairs(ION.MANAGED_ACTION_STATES) do
		if (ION.STATEINDEX[k]) then
			data[v.order] = ION.STATEINDEX[k]
		end
	end

	for k,v in ipairs(data) do

		if (not list) then
			list = L.VALIDSTATES..v
		else
			list = list..", "..v
		end
	end

	print(list..L.CUSTOM_OPTION)
end

function ION:PrintBarTypes()

	local data, index, high = {}, 1, 0

	for k,v in pairs(ION.RegisteredBarData) do

		if (v.barCreateMore) then

			index = tonumber(v.createMsg:match("%d+"))
			barType = v.createMsg:gsub("%d+","")

			if (index and barType) then
				data[index] = { k, barType }
				if (index > high) then high = index end
			end
		end
	end

	for i=1,high do if (not data[i]) then data[i] = 0 end end

	print(L.BARTYPES_USAGE)
	print(L.BARTYPES_TYPES)

	for k,v in ipairs(data) do
		if (type(v) == "table") then
			print("       |cff00ff00"..v[1].."|r: "..format(L.BARTYPES_LINE, v[2]))
		end
	end

end

function ION:RegisterBarClass(class, ...)

	ION.ModuleIndex = ION.ModuleIndex + 1

	ION.RegisteredBarData[class] = {
		barType = select(1,...):gsub("%s+", ""),
		barLabel = select(1,...),
		barReverse = select(11,...),
		barCreateMore = select(15,...),
		GDB = select(3,...),
		CDB = select(4,...),
		gDef = select(13,...),
		cDef = select(14,...),
		objTable = select(5,...),
		objGDB = select(6,...),
		objPrefix = "Ion"..select(2,...):gsub("%s+", ""),
		objFrameT = select(7,...),
		objTemplate = select(8,...),
		objMetaT = select(9,...),
		objType = select(2,...),
		objMax = select(10,...),
		objStorage = select(12,...),
		createMsg = ION.ModuleIndex..select(2,...),
	}

end

function ION:RegisterGUIOptions(class, ...)

	ION.RegisteredGUIData[class] = {
		chkOpt = select(1,...),
		stateOpt = select(2,...),
	}
end

function ION:SetTimerLimit(msg)

	local limit = tonumber(msg:match("%d+"))

	if (limit and limit > 0) then
		GDB.timerLimit = limit
		print(format(L.TIMERLIMIT_SET, GDB.timerLimit))
	else
		print(L.TIMERLIMIT_INVALID)
	end
end



local events = {}

local firstevent = false

local function control_OnEvent(self, event, ...)

	--if (not IonDB.debug.events) then IonDB.debug.events = {}
	--elseif (not firstevent) then wipe(IonDB.debug.events) firstevent = true end
	--tinsert(IonDB.debug.events, { event, GetActiveSpecGroup() })

	ION.CurrEvent = event

	if (event == "PLAYER_REGEN_DISABLED") then

		ION:ToggleEditFrames(nil, true)
		ION:ToggleBindings(nil, true)
		ION:ToggleBars(nil, true)

	elseif (event == "ADDON_LOADED" and ... == "Ion") then

		ION.MAS = Ion.MANAGED_ACTION_STATES
		ION.MBS = Ion.MANAGED_BAR_STATES

		BAR = ION.BAR

		ION.player, ION.class, ION.realm = UnitName("player"), select(2, UnitClass("player")), GetRealmName()

		if (ION.class == "SHAMAN") then
			ION.maxActionID = 144
		end

		if (ION.class == "DRUID") then
			ION.MAS.stealth = { states = "[nostance:3,stealth] stealth1; laststate", rangeStart = 1, rangeStop = 1, order = 7 }
		end

		for k,v in pairs(opDepList) do
			if (IsAddOnLoaded(v)) then
				ION.OpDep = true
			end
		end

		GDB = IonGDB; CDB = IonCDB; SPEC = IonSpec

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

		for k,v in pairs(defSPEC) do
			if (SPEC[k] == nil) then
				SPEC[k] = v
			end
		end

		ION:UpdateStanceStrings()

	elseif (event == "VARIABLES_LOADED") then

		local index, button, texture = 1

		SlashCmdList["ION"] = slashHandler
		SLASH_ION1 = L.SLASH1

		InterfaceOptionsFrame:SetFrameStrata("HIGH")

	elseif (event == "PLAYER_LOGIN") then


	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		GDB.firstRun = false

		ION:UpdateSpellIndex()
		ION:UpdateStanceStrings()
		ION:UpdateCompanionData()
		ION:UpdateIconIndex()

		ION:ToggleMainMenu(GDB.mainbar)
		ION:ToggleVehicleBar(GDB.vehicle)

		collectgarbage(); PEW = true

	elseif (event == "PLAYER_TALENT_UPDATE" or event == "PLAYER_LOGOUT" or event == "PLAYER_LEAVING_WORLD") then

		SPEC.cSpec = GetActiveSpecGroup()

	elseif (event == "ACTIVE_TALENT_GROUP_CHANGED" or
		  event == "SKILL_LINES_CHANGED" or
		  event == "LEARNED_SPELL_IN_TAB" or
		  event == "CHARACTER_POINTS_CHANGED") then

		ION:UpdateSpellIndex()
		ION:UpdateStanceStrings()

	elseif (event == "PET_UI_CLOSE" or event == "COMPANION_LEARNED" or event == "COMPANION_UPDATE") then

		ION:UpdateCompanionData()
	end
end

local frame = CreateFrame("Frame", "IonControl", UIParent)

frame.elapsed = 0
frame:SetScript("OnEvent", control_OnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
frame:RegisterEvent("SKILL_LINES_CHANGED")
frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
frame:RegisterEvent("CURSOR_UPDATE")
frame:RegisterEvent("PET_UI_CLOSE")
frame:RegisterEvent("COMPANION_LEARNED")
frame:RegisterEvent("COMPANION_UPDATE")
--frame:RegisterAllEvents()

frame = CreateFrame("GameTooltip", "IonTooltipScan", UIParent, "GameTooltipTemplate")
frame:SetOwner(UIParent, "ANCHOR_NONE")
frame:SetFrameStrata("TOOLTIP")
frame:Hide()
