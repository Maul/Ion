--Ion Menu Bar, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local ION, GDB, CDB, PEW = Ion

ION.MENUIndex = {}

local MENUIndex = ION.MENUIndex

local menubarsGDB, menubarsCDB, menubtnsGDB, menubtnsCDB

local ANCHOR = setmetatable({}, { __index = CreateFrame("Frame") })

local STORAGE = CreateFrame("Frame", nil, UIParent)

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

IonMenuGDB = {
	menubars = {},
	menubtns = {},
	scriptProfile = false,
	firstRun = true,
}

IonMenuCDB = {
	menubars = {},
	menubtns = {},
}

local gDef = {

	snapTo = false,
	snapToFrame = false,
	snapToPoint = false,
	point = "BOTTOMRIGHT",
	x = -154.5,
	y = 50,
}

local menuElements = {}
local addonData, sortData = {}, {}

local sort = table.sort
local format = string.format

local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMemoryUsage = _G.GetAddOnMemoryUsage
local GetAddOnCPUUsage = _G.GetAddOnCPUUsage
local GetScriptCPUUsage = _G.GetScriptCPUUsage
local UpdateAddOnMemoryUsage = _G.UpdateAddOnMemoryUsage
local UpdateAddOnCPUUsage = _G.UpdateAddOnCPUUsage

local GetParentKeys = ION.GetParentKeys

local defGDB, defCDB = CopyTable(IonMenuGDB), CopyTable(IonMenuCDB)

local configData = {

	stored = false,
}

local function updateTabard(button)

	local emblem = select(10, GetGuildLogoInfo())

	if (emblem) then

		if (not button.tabard:IsShown()) then

			button:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
			button:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down")

			button.tabard:Show()
		end

		SetSmallGuildTabardTextures("player", button.tabard.emblem, button.tabard.background)

	else
		if (button.tabard:IsShown()) then

			button:SetNormalTexture("Interface\\Buttons\\UI-MicroButton-Socials-Up")
			button:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Socials-Down")
			button:SetDisabledTexture("Interface\\Buttons\\UI-MicroButton-Socials-Disabled")

			button.tabard:Hide()
		end
	end
end

local function updateMicroButtons()

	local playerLevel = UnitLevel("player")

	if (IonCharacterButton and CharacterFrame:IsShown()) then

		IonCharacterButton:SetButtonState("PUSHED", 1)
		ION.CharacterButton_SetPushed(IonCharacterButton)

	elseif (IonCharacterButton) then

		IonCharacterButton:SetButtonState("NORMAL")
		ION.CharacterButton_SetNormal(IonCharacterButton)
	end

	if (IonSpellbookButton and SpellBookFrame:IsShown()) then

		IonSpellbookButton:SetButtonState("PUSHED", 1)

	elseif (IonSpellbookButton) then

		IonSpellbookButton:SetButtonState("NORMAL")
	end

	if (IonTalentButton and PlayerTalentFrame and PlayerTalentFrame:IsShown()) then

		IonTalentButton:SetButtonState("PUSHED", 1)

	elseif (IonTalentButton) then

		if (playerLevel < SHOW_TALENT_LEVEL) then

			IonTalentButton:GetNormalTexture():SetDesaturated(1)
			IonTalentButton:GetNormalTexture():SetVertexColor(0.5,0.5,0.5)
			IonTalentButton:GetPushedTexture():SetDesaturated(1)
			IonTalentButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Talents-Up")
			IonTalentButton:SetHighlightTexture("")
			IonTalentButton.disabledTooltip = format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_TALENT_LEVEL)

		else
			IonTalentButton:GetNormalTexture():SetDesaturated(nil)
			IonTalentButton:GetNormalTexture():SetVertexColor(1,1,1)
			IonTalentButton:GetPushedTexture():SetDesaturated(nil)
			IonTalentButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Talents-Down")
			IonTalentButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
			IonTalentButton:SetButtonState("NORMAL")
			IonTalentButton.disabledTooltip = nil
		end

	end

	if (IonQuestLogButton and QuestLogFrame:IsShown()) then

		IonQuestLogButton:SetButtonState("PUSHED", 1)

	elseif (IonQuestLogButton) then

		IonQuestLogButton:SetButtonState("NORMAL")
	end

	if (IonLatencyButton and (GameMenuFrame:IsShown() or InterfaceOptionsFrame:IsShown() or (KeyBindingFrame and KeyBindingFrame:IsShown()) or (MacroFrame and MacroFrame:IsShown()))) then

		IonLatencyButton:SetButtonState("PUSHED", 1)
		ION.LatencyButton_SetPushed(IonLatencyButton)

	elseif (IonLatencyButton) then

		IonLatencyButton:SetButtonState("NORMAL")
		ION.LatencyButton_SetNormal(IonLatencyButton)
	end

	if (IonPVPButton and PVPFrame:IsShown()) then

		IonPVPButton:SetButtonState("PUSHED", 1)
		ION.PVPButton_SetPushed(IonPVPButton)

	elseif (IonPVPButton) then

		if (playerLevel < SHOW_PVP_LEVEL) then

			IonPVPButton:GetNormalTexture():SetDesaturated(1)
			IonPVPButton:GetNormalTexture():SetVertexColor(0.5,0.5,0.5)
			IonPVPButton:GetPushedTexture():SetDesaturated(1)
			IonPVPButton.faction:SetDesaturated(1)
			IonPVPButton.faction:SetVertexColor(0.5,0.5,0.5)
			IonPVPButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
			IonPVPButton:SetHighlightTexture("")
			IonPVPButton.disabledTooltip = format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_PVP_LEVEL)

		else
			IonPVPButton:GetNormalTexture():SetDesaturated(nil)
			IonPVPButton:GetNormalTexture():SetVertexColor(1,1,1)
			IonPVPButton:GetPushedTexture():SetDesaturated(nil)
			IonPVPButton.faction:SetDesaturated(nil)
			IonPVPButton.faction:SetVertexColor(1,1,1)
			IonPVPButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down")
			IonPVPButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
			IonPVPButton:SetButtonState("NORMAL")
			IonPVPButton.disabledTooltip = nil
			ION.PVPButton_SetNormal(IonPVPButton)
		end
	end

	if (IonGuildButton and ((GuildFrame and GuildFrame:IsShown()) or (LookingForGuildFrame and LookingForGuildFrame:IsShown()))) then

		IonGuildButton:SetButtonState("PUSHED", 1)
		IonGuildButton.tabard:SetPoint("TOPLEFT", -1, -1)
		IonGuildButton.tabard:SetAlpha(0.5)

	elseif (IonGuildButton) then

		IonGuildButton:GetNormalTexture():SetDesaturated(nil)
		IonGuildButton:GetNormalTexture():SetVertexColor(1,1,1)
		IonGuildButton:GetPushedTexture():SetDesaturated(nil)
		IonGuildButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Socials-Down")
		IonGuildButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
		IonGuildButton:SetButtonState("NORMAL")
		IonGuildButton.tabard:SetPoint("TOPLEFT", 0, 0)
		IonGuildButton.tabard:SetAlpha(1.0)
		IonGuildButton.disabledTooltip = nil

		if (IsInGuild()) then
			updateTabard(IonGuildButton)
		end
	end

	if (IonLFDButton and PVEFrame and PVEFrame:IsShown())  then

		IonLFDButton:SetButtonState("PUSHED", 1)

	elseif (IonLFDButton) then

		if (playerLevel < SHOW_LFD_LEVEL) then

			IonLFDButton:GetNormalTexture():SetDesaturated(1)
			IonLFDButton:GetNormalTexture():SetVertexColor(0.5,0.5,0.5)
			IonLFDButton:GetPushedTexture():SetDesaturated(1)
			IonLFDButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-LFG-Up")
			IonLFDButton:SetHighlightTexture("")
			IonLFDButton.disabledTooltip = format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_LFD_LEVEL)

		else
			IonLFDButton:GetNormalTexture():SetDesaturated(nil)
			IonLFDButton:GetNormalTexture():SetVertexColor(1,1,1)
			IonLFDButton:GetPushedTexture():SetDesaturated(nil)
			IonLFDButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-LFG-Down")
			IonLFDButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
			IonLFDButton:SetButtonState("NORMAL")
			IonLFDButton.disabledTooltip = nil
		end

	end

	if (IonCompanionButton and PetJournalParent and PetJournalParent:IsShown())  then

		IonCompanionButton:SetButtonState("PUSHED", 1)

	elseif (IonCompanionButton) then

		IonCompanionButton:GetNormalTexture():SetDesaturated(nil)
		IonCompanionButton:GetNormalTexture():SetVertexColor(1,1,1)
		IonCompanionButton:GetPushedTexture():SetDesaturated(nil)
		IonCompanionButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Mounts-Down")
		IonCompanionButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
		IonCompanionButton:SetButtonState("NORMAL")
		IonCompanionButton.disabledTooltip = nil

	end

	if (IonEJButton and EncounterJournal and EncounterJournal:IsShown())  then

		IonEJButton:SetButtonState("PUSHED", 1)

	elseif (IonEJButton) then

		IonEJButton:GetNormalTexture():SetDesaturated(nil)
		IonEJButton:GetNormalTexture():SetVertexColor(1,1,1)
		IonEJButton:GetPushedTexture():SetDesaturated(nil)
		IonEJButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-EJ-Down")
		IonEJButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
		IonEJButton:SetButtonState("NORMAL")
		IonEJButton.disabledTooltip = nil

	end

	if (IonHelpButton and HelpFrame:IsShown()) then

		IonHelpButton:SetButtonState("PUSHED", 1)

	elseif (IonHelpButton) then

		IonHelpButton:SetButtonState("NORMAL")
	end

	if (IonAchievementButton and AchievementFrame and AchievementFrame:IsShown()) then

		IonAchievementButton:SetButtonState("PUSHED", 1)

	elseif (IonAchievementButton) then

		if ((HasCompletedAnyAchievement() or IsInGuild()) and CanShowAchievementUI()) then

			IonAchievementButton:GetNormalTexture():SetDesaturated(nil)
			IonAchievementButton:GetNormalTexture():SetVertexColor(1,1,1)
			IonAchievementButton:GetPushedTexture():SetDesaturated(nil)
			IonAchievementButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Achievement-Down")
			IonAchievementButton:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
			IonAchievementButton:SetButtonState("NORMAL")
			IonAchievementButton.disabledTooltip = nil

		else

			IonAchievementButton:GetNormalTexture():SetDesaturated(1)
			IonAchievementButton:GetNormalTexture():SetVertexColor(0.5,0.5,0.5)
			IonAchievementButton:GetPushedTexture():SetDesaturated(1)
			IonAchievementButton:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-Achievement-Up")
			IonAchievementButton:SetHighlightTexture("")
			IonAchievementButton.disabledTooltip = "Feature becomes available after you earn your first achievement"

		end
	end


end

function ION.CharacterButton_OnLoad(self)

	self.portrait = _G[self:GetName().."Portrait"]
	SetPortraitTexture(self.portrait, "player")

	self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
	self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down")
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	self:RegisterEvent("UPDATE_BINDINGS")
	self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
	self.newbieText = NEWBIE_TOOLTIP_CHARACTER

	menuElements[#menuElements+1] = self
end

function ION.CharacterButton_OnMouseDown(self)

	if (self.down) then
		self.down = nil
		ToggleCharacter("PaperDollFrame")
		return
	end
	ION.CharacterButton_SetPushed(self)
	self.down = 1
end

function ION.CharacterButton_OnMouseUp(self)

	if (self.down) then
		self.down = nil
		if (self:IsMouseOver()) then
			ToggleCharacter("PaperDollFrame")
		else
			updateMicroButtons()
		end
		return
	end
	if (self:GetButtonState() == "NORMAL") then
		ION.CharacterButton_SetPushed(self)
		self.down = 1
	else
		ION.CharacterButton_SetNormal(self)
		self.down = 1
	end
end

function ION.CharacterButton_OnEvent(self, event, ...)

	if (event == "UNIT_PORTRAIT_UPDATE") then

		if (... == "player") then
			SetPortraitTexture(self.portrait, ...)
		end

	elseif (event == "UPDATE_BINDINGS") then

		self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
	end
end

function ION.CharacterButton_SetPushed(self)
	self.portrait:SetTexCoord(0.2666, 0.8666, 0, 0.8333)
	self.portrait:SetAlpha(0.5)
end

function ION.CharacterButton_SetNormal(self)
	self.portrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9)
	self.portrait:SetAlpha(1.0)
end

function ION.SpellbookButton_OnLoad(self)

	self:SetAttribute("type", "macro")
	self:SetAttribute("*macrotext*", "/click SpellbookMicroButton")
	self:RegisterEvent("UPDATE_BINDINGS")

	LoadMicroButtonTextures(self, "Spellbook")
	menuElements[#menuElements+1] = self
end

function ION.SpellbookButton_OnClick(self)
	if (not InCombatLockdown()) then
		ToggleSpellBook(BOOKTYPE_SPELL)
	end
end

function ION.SpellbookButton_OnEnter(self)
	self.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
	GameTooltip_AddNewbieTip(self, self.tooltipText, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_SPELLBOOK)
end

function ION.SpellbookButton_OnEvent(self, event, ...)
	self.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
end

function ION.TalentButton_OnLoad(self)

	LoadMicroButtonTextures(self, "Talents")

	self:SetAttribute("type", "macro")
	self:SetAttribute("*macrotext*", "/click TalentMicroButton")

	self.tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
	self.newbieText = NEWBIE_TOOLTIP_TALENTS
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("UPDATE_BINDINGS")
	self:RegisterEvent("UNIT_LEVEL")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:HookScript("OnEnter", function(self) if (self.disabledTooltip) then GameTooltip:AddLine(self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true) GameTooltip:Show() end end)

	menuElements[#menuElements+1] = self
end

function ION.TalentButton_OnEvent(self, event, ...)

	if (event == "PLAYER_LEVEL_UP") then

		UpdateMicroButtons()

		if (not CharacterFrame:IsShown()) then
			SetButtonPulse(self, 60, 1)
		end

	elseif (event == "UNIT_LEVEL" or event == "PLAYER_ENTERING_WORLD") then

		UpdateMicroButtons()

	elseif (event == "UPDATE_BINDINGS") then

		self.tooltipText =  MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
	end
end

function ION.AchievementButton_OnLoad(self)
	LoadMicroButtonTextures(self, "Achievement")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_BINDINGS")

	menuElements[#menuElements+1] = self
end

function ION.AchievementButton_OnEvent(self, event, ...)

	if (event == "PLAYER_ENTERING_WORLD") then
		AchievementMicroButton_OnEvent(self, event, ...)
	elseif (event == "UPDATE_BINDINGS") then
		self.tooltipText =  MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
	end
end

function ION.AchievementButton_OnClick(self)
	ToggleAchievementFrame()
end

function ION.AchievementButton_OnEnter(self)
	self.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
	GameTooltip_AddNewbieTip(self, self.tooltipText, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_ACHIEVEMENT)
	if (self.disabledTooltip) then
		GameTooltip:AddLine("\n"..self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
	end
	GameTooltip:Show()
end

function ION.QuestLogButton_OnLoad(self)
	LoadMicroButtonTextures(self, "Quest")
	self.tooltipText = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
	self.newbieText = NEWBIE_TOOLTIP_QUESTLOG

	menuElements[#menuElements+1] = self
end

function ION.QuestLogButton_OnEvent(self, event, ...)
	self.tooltipText = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
end

function ION.QuestLogButton_OnClick(self)
	ToggleFrame(QuestLogFrame)
end

--		IonGuildButton.tabard:SetPoint("TOPLEFT", -1, -1) IonGuildButton.tabard:SetAlpha(0.5)

function ION.GuildButton_OnLoad(self)

	self:SetAttribute("type", "macro")
	self:SetAttribute("*macrotext*", "/click GuildMicroButton")
	self:SetScript("OnMouseDown", function(self) self.tabard:SetPoint("TOPLEFT", -1, -1) self.tabard:SetAlpha(0.5) end)
	self:RegisterEvent("UPDATE_BINDINGS")
	self:RegisterEvent("PLAYER_GUILD_UPDATE")

	LoadMicroButtonTextures(self, "Socials")
	self.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
	self.newbieText = NEWBIE_TOOLTIP_GUILDTAB

	self:HookScript("OnEnter", function(self) if (self.disabledTooltip) then GameTooltip:AddLine(self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true) GameTooltip:Show() end end)

	updateTabard(self)

	menuElements[#menuElements+1] = self
end

function ION.GuildButton_OnEvent(self, event, ...)
	if (event == "UPDATE_BINDINGS") then
		self.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
	elseif (event == "PLAYER_GUILD_UPDATE") then
		UpdateMicroButtons()
	end
end

function ION.PVPButton_OnLoad(self)

	self:RegisterEvent("UPDATE_BINDINGS")
	self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
	self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down")
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight")
	self.faction = _G[self:GetName().."Faction"]

	local factionGroup = UnitFactionGroup("player")

	if (factionGroup) then
		self.factionGroup = factionGroup
		self.faction:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..self.factionGroup)
	end

	self.tooltipText = MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")
	self.newbieText = NEWBIE_TOOLTIP_PVP

	self:HookScript("OnEnter", function(self) if (self.disabledTooltip) then GameTooltip:AddLine(self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true) GameTooltip:Show() end end)

	menuElements[#menuElements+1] = self
end

function ION.PVPButton_OnEvent(self, event, ...)
	self.tooltipText = MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")
	self.newbieText = NEWBIE_TOOLTIP_PVP
end

function ION.PVPButton_OnMouseDown(self)

	if (self.disabledTooltip) then
		self.faction:SetVertexColor(1,1,1)
		return
	end

	if (self.down) then
		self.down = nil
		if (PVPFrame) then
			ToggleFrame(PVPFrame)
		end
		return
	end

	ION.PVPButton_SetPushed(self)

	self.down = 1
end

function ION.PVPButton_OnMouseUp(self)

	if (self.disabledTooltip) then
		self.faction:SetVertexColor(0.5,0.5,0.5)
		return
	end

	if (self.down) then
		self.down = nil
		if (self:IsMouseOver() and PVPFrame) then
			ToggleFrame(PVPFrame)
		else
			updateMicroButtons()
		end
		return
	end

	if (self:GetButtonState() == "NORMAL") then
		ION.PVPButton_SetPushed(self)
	else
		ION.PVPButton_SetNormal(self)
	end

	self.down = 1
end

function ION.PVPButton_SetPushed(self)
	self.faction:SetPoint("TOP", self, "TOP", 5, -31)
	self.faction:SetAlpha(0.5)
end

function ION.PVPButton_SetNormal(self)
	self.faction:SetPoint("TOP", self, "TOP", 6, -30)
	self.faction:SetAlpha(1.0)
end

function ION.LFDButton_OnLoad(self)

	self:RegisterEvent("UPDATE_BINDINGS")
	self.tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLELFGPARENT")
	self.newbieText = NEWBIE_TOOLTIP_LFGPARENT

	LoadMicroButtonTextures(self, "LFG")

	self:HookScript("OnEnter", function(self) if (self.disabledTooltip) then GameTooltip:AddLine(self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true) GameTooltip:Show() end end)

	menuElements[#menuElements+1] = self
end

function ION.LFDButton_OnEvent(self, event, ...)
	self.tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLELFGPARENT")
	self.newbieText = NEWBIE_TOOLTIP_LFGPARENT
end

function ION.LFDButton_OnClick(self)

	if (self.disabledTooltip) then
		return
	end

	if (ToggleLFDParentFrame) then
		ToggleLFDParentFrame()
	elseif (ToggleLFDParentFrame) then
		ToggleLFDParentFrame()
	end
end

function ION.CompanionButton_OnLoad(self)

	self:RegisterEvent("UPDATE_BINDINGS")
	self.tooltipText = MicroButtonTooltipText(MOUNTS_AND_PETS, "TOGGLEMOUNTJOURNAL")
	self.newbieText = NEWBIE_TOOLTIP_MOUNTS_AND_PETS

	LoadMicroButtonTextures(self, "Mounts")

	self:HookScript("OnEnter", function(self) if (self.disabledTooltip) then GameTooltip:AddLine(self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true) GameTooltip:Show() end end)

	menuElements[#menuElements+1] = self

end

function ION.CompanionButton_OnEvent(self, event, ...)

	self.tooltipText = MicroButtonTooltipText(MOUNTS_AND_PETS, "TOGGLEMOUNTJOURNAL")
	self.newbieText = NEWBIE_TOOLTIP_MOUNTS_AND_PETS
end

function ION.CompanionButton_OnClick(self)

	TogglePetJournal()
end

function ION.EJButton_OnLoad(self)

	self:RegisterEvent("UPDATE_BINDINGS")
	self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
	self.newbieText = NEWBIE_TOOLTIP_ENCOUNTER_JOURNAL

	LoadMicroButtonTextures(self, "EJ")

	self:HookScript("OnEnter", function(self) if (self.disabledTooltip) then GameTooltip:AddLine(self.disabledTooltip, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true) GameTooltip:Show() end end)

	menuElements[#menuElements+1] = self

end

function ION.EJButton_OnEvent(self, event, ...)

	self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
	self.newbieText = NEWBIE_TOOLTIP_ENCOUNTER_JOURNAL

end

function ION.EJButton_OnClick(self)

	if (self.disabledTooltip) then
		return
	end

	if (not EncounterJournal) then
		EncounterJournal_LoadUI()
	end

	if (EncounterJournal) then
		ToggleFrame(EncounterJournal)
	end
end

function ION.HelpButton_OnLoad(self)
	LoadMicroButtonTextures(self, "Help")
	self.tooltipText = HELP_BUTTON
	self.newbieText = NEWBIE_TOOLTIP_HELP

	menuElements[#menuElements+1] = self
end

function ION.HelpButton_OnClick(self)
	ToggleHelpFrame()
end

function ION.LatencyButton_OnLoad(self)

	self.hover = nil
	self.elapsed = 0
	self.overlay = _G[self:GetName().."Overlay"]
	self.overlay:SetWidth(self:GetWidth()+1)
	self.overlay:SetHeight(self:GetHeight())
	self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
	self.newbieText = NEWBIE_TOOLTIP_MAINMENU
	self:RegisterForClicks("LeftButtonDown", "RightButtonDown", "LeftButtonUp", "RightButtonUp")
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("UPDATE_BINDINGS")

	menuElements[#menuElements+1] = self

end

function ION.LatencyButton_OnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ...=="Ion-MenuBar") then
		self.lastStart = 0
		if (GDB) then
			self.enabled = GDB.scriptProfile
		end
		GameMenuFrame:HookScript("OnShow", ION.LatencyButton_SetPushed)
		GameMenuFrame:HookScript("OnHide", ION.LatencyButton_SetNormal)
	end

	self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
end

function ION.LatencyButton_OnClick(self, button, down)

	if (button == "RightButton") then

		if (IsShiftKeyDown()) then

			if (GDB.scriptProfile) then

				SetCVar("scriptProfile", "0")
				GDB.scriptProfile = false
			else

				SetCVar("scriptProfile", "1")
				GDB.scriptProfile = true

			end

			ReloadUI()

		end

		if (not down) then

			if (self.alt_tooltip) then
				self.alt_tooltip = false
			else
				self.alt_tooltip = true
			end

			ION.LatencyButton_SetNormal()
		else
			ION.LatencyButton_SetPushed()
		end

		ION.LatencyButton_OnEnter(self)

	elseif (IsShiftKeyDown()) then

		ReloadUI()

	else

		if (self.down) then
			self.down = nil;
			if (not GameMenuFrame:IsShown()) then
				CloseMenus()
				CloseAllWindows()
				PlaySound("igMainMenuOpen")
				ShowUIPanel(GameMenuFrame)
			else
				PlaySound("igMainMenuQuit")
				HideUIPanel(GameMenuFrame)
				ION.LatencyButton_SetNormal()
			end
			if (InterfaceOptionsFrame:IsShown()) then
				InterfaceOptionsFrameCancel:Click()
			end
			return;
		end
		if (self:GetButtonState() == "NORMAL") then
			ION.LatencyButton_SetPushed()
			self.down = 1;
		else

			self.down = 1;
		end
	end
end

function ION.LatencyButton_OnUpdate(self, elapsed)

	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > 2.5) then

		local r, g, rgbValue
		local bandwidthIn, bandwidthOut, latency = GetNetStats()

		if (latency <= 1000) then
			rgbValue = math.floor((latency/1000)*100)
		else
			rgbValue = 100
		end

		if (rgbValue < 50) then
			r=rgbValue/50; g=1-(rgbValue/100)
		else
			r=1; g=abs((rgbValue/100)-1)
		end

		self.overlay:SetVertexColor(r, g, 0)

		if (self.hover) then
			ION.LatencyButton_OnEnter(self)
		end

		if (self.enabled) then

			UpdateAddOnCPUUsage()
			UpdateAddOnMemoryUsage()

			self.lastUsage = self.currUsage or 0

			self.currUsage = GetScriptCPUUsage()

			self.usage = self.currUsage - self.lastUsage
		end

		self.elapsed = 0
	end
end

function ION.LatencyButton_OnEnter(self)

	self.hover = 1

	if (self.alt_tooltip and not IonMenuBarTooltip.wasShown) then

		ION.LatencyButton_AltOnEnter(self)
		IonMenuBarTooltip:AddLine("\nLatency Button by LedMirage of MirageUI")
		GameTooltip:Hide()
		IonMenuBarTooltip:Show()

	elseif (self:IsMouseOver()) then

		MainMenuBarPerformanceBarFrame_OnEnter(self)

		local objects = ION:GetParentKeys(GameTooltip)

		local foundion, text

		for k,v in pairs(objects) do
			if (_G[v]:IsObjectType("FontString")) then
				text = _G[v]:GetText()
				if (text) then
					foundion = text:match("%s+Ion$")
				end
			end
		end

		if (not foundion) then
			for i=1, GetNumAddOns() do
				if (select(1,GetAddOnInfo(i)) == "Ion") then
					local mem = GetAddOnMemoryUsage(i)
					if (mem > 1000) then
						mem = mem / 1000
					end
					GameTooltip:AddLine(format(ADDON_MEM_MB_ABBR, mem, select(1,GetAddOnInfo(i))), 1.0, 1.0, 1.0)
				end
			end
		end

		GameTooltip:AddLine("\nLatency Button by LedMirage of MirageUI")

		IonMenuBarTooltip:Hide()
		GameTooltip:Show()
	end
end

function ION.LatencyButton_AltOnEnter(self)

	if (not IonMenuBarTooltip:IsVisible()) then
		IonMenuBarTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
	end

	if (self.enabled) then

		IonMenuBarTooltip:SetText("Script Profiling is |cff00ff00Enabled|r", 1, 1, 1)
		IonMenuBarTooltip:AddLine("(Shift-RightClick to Disable)", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		IonMenuBarTooltip:AddLine("\n|cfff00000Warning:|r Script Profiling Affects Game Performance\n", 1, 1, 1, 1)

		for i=1, GetNumAddOns() do

			local name,_,_,enabled = GetAddOnInfo(i)

			if (not addonData[i]) then
				addonData[i] = { name = name, enabled = enabled	}
			end

			local addon = addonData[i]

			addon.currMem = GetAddOnMemoryUsage(i)

			if (not addon.maxMem or addon.maxMem < addon.currMem) then
				addon.maxMem = addon.currMem
			end

			local currCPU = GetAddOnCPUUsage(i)

			if (addon.lastUsage) then

				addon.currCPU = (currCPU - addon.lastUsage)/2.5

				if (not addon.maxCPU or addon.maxCPU < addon.currCPU) then
					addon.maxCPU = addon.currCPU
				end
			else
				addon.currCPU = currCPU
			end

			if (self.usage > 0) then
				addon.percentCPU = addon.currCPU/self.usage * 100
			else
				addon.percentCPU = 0
			end

			addon.lastUsage = currCPU

			if (self.lastStart > 0) then
				addon.avgCPU = currCPU / self.lastStart
			end
		end

		if (self.usage) then
			IonMenuBarTooltip:AddLine("|cffffffff("..format("%.2f",(self.usage) / 2.5).."ms)|r Total Script CPU Time\n", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		end

		wipe(sortData)

		for i,v in ipairs(addonData) do

			if (addonData[i].enabled) then

				local addLine = ""

				if (addonData[i].currCPU and addonData[i].currCPU > 0) then

					addLine = addLine..format("%.2f", addonData[i].currCPU).."ms/"..format("%.1f", addonData[i].percentCPU).."%)|r "

					local num = tonumber(addLine:match("^%d+"))

					if (num and num < 10) then
						addLine = "0"..addLine
					end

					if (addonData[i].name) then
						addLine = "|cffffffff("..addLine..addonData[i].name.." "
					end

					tinsert(sortData, addLine)
				end
			end
		end

		sort(sortData, function(a,b) return a>b end)

		for i,v in ipairs(sortData) do
			IonMenuBarTooltip:AddLine(v, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		end
	else

		IonMenuBarTooltip:SetText("Script Profiling is |cfff00000Disabled|r", 1, 1, 1)
		IonMenuBarTooltip:AddLine("(Shift-RightClick to Enable)", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		IonMenuBarTooltip:AddLine("\n|cfff00000Warning:|r Script Profiling Affects Game Performance\n", 1, 1, 1, 1)
	end
end

function ION.LatencyButton_OnLeave(self)

	if (GameTooltip:IsVisible()) then
		self.hover = nil
		GameTooltip:Hide()
	end
end

function ION.LatencyButton_SetPushed()
	IonLatencyButtonOverlay:SetPoint("CENTER", IonLatencyButton, "CENTER", -1, -2)
end

function ION.LatencyButton_SetNormal()
	IonLatencyButtonOverlay:SetPoint("CENTER", IonLatencyButton, "CENTER", 0, -0.5)
end

function ANCHOR:SetData(bar)

	if (bar) then

		self.bar = bar

		self:SetFrameStrata(bar.gdata.objectStrata)
		self:SetScale(bar.gdata.scale)
	end

	self:SetFrameLevel(4)
end

function ANCHOR:SaveData()

	-- empty

end

function ANCHOR:LoadData(spec, state)

	local id = self.id

	self.GDB = menubtnsGDB
	self.CDB = menubtnsCDB

	if (self.GDB and self.CDB) then

		if (not self.GDB[id]) then
			self.GDB[id] = {}
		end

		if (not self.GDB[id].config) then
			self.GDB[id].config = CopyTable(configData)
		end

		if (not self.CDB[id]) then
			self.CDB[id] = {}
		end

		if (not self.CDB[id].data) then
			self.CDB[id].data = {}
		end

		self.config = self.GDB [id].config

		self.data = self.CDB[id].data
	end
end

function ANCHOR:SetGrid(show, hide)

	--empty

end

function ANCHOR:SetAux()

	-- empty

end

function ANCHOR:LoadAux()

	-- empty

end

function ANCHOR:SetDefaults()

	-- empty

end

function ANCHOR:GetDefaults()

	--empty

end

function ANCHOR:SetType(save)

	if (menuElements[self.id]) then

		self:SetWidth(menuElements[self.id]:GetWidth()*0.90)
		self:SetHeight(menuElements[self.id]:GetHeight()/1.60)
		self:SetHitRectInsets(self:GetWidth()/2, self:GetWidth()/2, self:GetHeight()/2, self:GetHeight()/2)

		self.element = menuElements[self.id]

		local objects = ION:GetParentKeys(self.element)

		for k,v in pairs(objects) do
			local name = v:gsub(self.element:GetName(), "")
			self[name:lower()] = _G[v]
		end

		self.element.normaltexture = self.element:CreateTexture("$parentNormalTexture", "OVERLAY", "IonCheckButtonTextureTemplate")
		self.element.normaltexture:ClearAllPoints()
		self.element.normaltexture:SetPoint("CENTER", 0, 0)
		self.element.icontexture = self.element:GetNormalTexture()
		self.element:ClearAllPoints()
		self.element:SetParent(self)
		self.element:Show()
		self.element:SetPoint("BOTTOM", self, "BOTTOM", 0, -1)
		self.element:SetHitRectInsets(3, 3, 23, 3)

	end
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Ion-MenuBar") then

		hooksecurefunc("UpdateMicroButtons", updateMicroButtons)

		GDB = IonMenuGDB; CDB = IonMenuCDB

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

		menubarsGDB = GDB.menubars
		menubarsCDB = CDB.menubars

		menubtnsGDB = GDB.menubtns
		menubtnsCDB = CDB.menubtns

		ION:RegisterBarClass("menu", "Menu Bar", "Menu Button", menubarsGDB, menubarsCDB, MENUIndex, menubtnsGDB, "CheckButton", "IonAnchorButtonTemplate", { __index = ANCHOR }, #menuElements, false, STORAGE, gDef, nil, true)

		ION:RegisterGUIOptions("menu", { AUTOHIDE = true, SHOWGRID = false, SPELLGLOW = false, SNAPTO = true, DUALSPEC = false, HIDDEN = true, LOCKBAR = false, TOOLTIPS = true }, false, false)

		if (GDB.firstRun) then

			local bar, object = ION:CreateNewBar("menu", 1, true)

			for i=1,#menuElements do
				object = ION:CreateNewObject("menu", i)
				bar:AddObjectToList(object)
			end

			GDB.firstRun = false

		else

			for id,data in pairs(menubarsGDB) do
				if (data ~= nil) then
					ION:CreateNewBar("menu", id)
				end
			end

			for id,data in pairs(menubtnsGDB) do
				if (data ~= nil) then
					ION:CreateNewObject("menu", id)
				end
			end
		end

		STORAGE:Hide()

	elseif (event == "PLAYER_LOGIN") then

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		PEW = true
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
