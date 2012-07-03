--Ion Pet Action Bar, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local ION, GDB, CDB, PEW = Ion

ION.PETIndex = {}

local PETIndex = ION.PETIndex

local petbarsGDB, petbarsCDB, petbtnsGDB, petbtnsCDB

local BUTTON = setmetatable({}, { __index = CreateFrame("CheckButton") })

local STORAGE = CreateFrame("Frame", nil, UIParent)

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

local	SKIN = LibStub("Masque", true)

IonPetGDB = {
	petbars = {},
	petbtns = {},
	freeSlots = 16,
	firstRun = true,
}

IonPetCDB = {
	petbars = {},
	petbtns = {},
}

local format = string.format

local GetParentKeys = ION.GetParentKeys

local defGDB, defCDB = CopyTable(IonPetGDB), CopyTable(IonPetCDB)

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

	self.GDB = petbtnsGDB
	self.CDB = petbtnsCDB

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

	if (event == "ADDON_LOADED" and ... == "Ion-PetBar") then

		GDB = IonPetGDB; CDB = IonPetCDB

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

		petbarsGDB = GDB.petbars
		petbarsCDB = CDB.petbars

		petbtnsGDB = GDB.petbtns
		petbtnsCDB = CDB.petbtns

		ION:RegisterBarClass("pet", "Pet Bar", "Pet Button", petbarsGDB, petbarsCDB, PETIndex, petbtnsGDB, "CheckButton", "IonActionButtonTemplate", { __index = BUTTON }, 10, true, STORAGE, nil, nil, true)

		if (GDB.firstRun) then

			local bar = ION:CreateNewBar("pet", 1)

			for i=1,10 do
				ION:CreateNewObject("pet", i)
			end

			bar:AddObjects(10)

			GDB.firstRun = false

		else

			for id,data in pairs(petbarsGDB) do
				if (data ~= nil) then
					ION:CreateNewBar("pet", id)
				end
			end

			for id,data in pairs(petbtnsGDB) do
				if (data ~= nil) then
					ION:CreateNewObject("pet", id)
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