--Ion Alert Action Bar, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local ION, GDB, CDB, PEW = Ion

ION.ALERTIndex = {}

local ALERTIndex = ION.ALERTIndex

local alertbarsGDB, alertbarsCDB, alertbtnsGDB, alertbtnsCDB

local BUTTON = setmetatable({}, { __index = CreateFrame("CheckButton") })

local STORAGE = CreateFrame("Frame", nil, UIParent)

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

local	SKIN = LibStub("Masque", true)

IonAlertGDB = {
	alertbars = {},
	alertbtns = {},
	freeSlots = 16,
	firstRun = true,
}

IonAlertCDB = {
	alertbars = {},
	alertbtns = {},
}

local format = string.format

local GetParentKeys = ION.GetParentKeys

local defGDB, defCDB = CopyTable(IonAlertGDB), CopyTable(IonAlertCDB)

local configData = {

	stored = false,
}


function BUTTON:SetSkinned()

	if (SKIN) then

		local bar = self.bar

		if (bar) then

			wipe(btnData)

			btnData.Icon = self.element.icon

			SKIN:Group("Ion", bar.gdata.name):AddButton(self.element, btnData)
		end
	end
end

function BUTTON:SetData(bar)

	if (bar) then

		self.bar = bar

		self:SetFrameStrata(bar.gdata.objectStrata)
		self:SetScale(bar.gdata.scale)

	end

	self:SetFrameLevel(4)
end

function BUTTON:LoadData(spec, state)

	local id = self.id

	self.GDB = alertbtnsGDB
	self.CDB = alertbtnsCDB

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

function BUTTON:LoadAux()


end

function BUTTON:SetDefaults()

end

function BUTTON:SetType(save)


end

local function controlOnEvent(self, event, ...)

	if (true) then return end

	if (event == "ADDON_LOADED" and ... == "Ion-AlertBars") then

		GDB = IonAlertGDB; CDB = IonAlertCDB

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

		alertbarsGDB = GDB.alertbars
		alertbarsCDB = CDB.alertbars

		alertbtnsGDB = GDB.alertbtns
		alertbtnsCDB = CDB.alertbtns

		ION:RegisterBarClass("alert", "Alert Bar", "Alert Frame", alertbarsGDB, alertbarsCDB, ALERTIndex, alertbtnsGDB, "CheckButton", "IonAnchorButtonTemplate", { __index = BUTTON }, 10, true, STORAGE, nil, nil, true)

		ION:RegisterGUIOptions("alert", { AUTOHIDE = true, SHOWGRID = false, SPELLGLOW = false, SNAPTO = true, DUALSPEC = false, HIDDEN = true, LOCKBAR = false, TOOLTIPS = true }, false, false)

		if (GDB.firstRun) then

			local bar = ION:CreateNewBar("alert", 1)

			for i=1,10 do
				ION:CreateNewObject("alert", i)
			end

			bar:AddObjects(10)

			GDB.firstRun = false

		else

			for id,data in pairs(alertbarsGDB) do
				if (data ~= nil) then
					ION:CreateNewBar("alert", id)
				end
			end

			for id,data in pairs(alertbtnsGDB) do
				if (data ~= nil) then
					ION:CreateNewObject("alert", id)
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