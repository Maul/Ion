--Ion MiniMap, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local ION, GDB, CDB, PEW = Ion

ION.MINIMAPIndex = {}

local MINIMAPIndex = ION.MINIMAPIndex

local minimapbarsGDB, minimapbarsCDB, minimapbtnsGDB, minimapbtnsCDB

local ANCHOR = setmetatable({}, { __index = CreateFrame("Frame") })

local STORAGE = CreateFrame("Frame", nil, UIParent)

local L = LibStub("AceLocale-3.0"):GetLocale("Ion")

IonMiniMapGDB = {
	minimapbars = {},
	minimapbtns = {},
	firstRun = true,
}

IonMiniMapCDB = {
	minimapbars = {},
	minimapbtns = {},
}

local gDef = {

	snapTo = false,
	snapToFrame = false,
	snapToPoint = false,
	point = "TOPRIGHT",
	x = -103,
	y = -134,
}

local minimapElements = {}

local format = string.format

local GetParentKeys = ION.GetParentKeys

local defGDB, defCDB = CopyTable(IonMiniMapGDB), CopyTable(IonMiniMapCDB)

local configData = {

	stored = false,
}

local minimapChildren, minimapBackdropChildren
local GetPlayerMapPosition = _G.GetPlayerMapPosition

local minimapBoundry = {
	top = 10,
	bottom = -10,
	left = -10,
	right = 10,
}

local function minimapGetChildren()

	minimapChildren = { Minimap:GetChildren() }
	minimapBackdropChildren = { MinimapBackdrop:GetChildren() }

end

local function hideMinimapItems()

	minimapGetChildren()

	for k,v in pairs(minimapChildren) do

		name = v:GetName()

		if (name) then

			if (not name:find("GatherNote")) then

				if (name ~= "MiniMapPing" and name ~= "TimeManagerClockButton" and name ~= "PlasmaElementGlobe") then

					if (name == "MinimapBackdrop") then
						for key,value in pairs(minimapBackdropChildren) do
							value:SetAlpha(0)
						end
					elseif (name == "MiniMapCompassRing") then
						if ( GetCVar("rotateElement") == "1" ) then
							v:SetAlpha(Element:GetAlpha())
						else
							v:SetAlpha(0)
						end
					else
						v:SetAlpha(0)
					end
				end
			end
		end
	end
end

local function showMinimapItems()

	minimapGetChildren()

	for k,v in pairs(minimapChildren) do

		name = v:GetName()

		if (name) then

			if (name ~= "MiniMapPing" and name ~= "TimeManagerClockButton") then

				if (name == "MinimapBackdrop") then

					for key,value in pairs(minimapBackdropChildren) do

						if (value:GetName() == "MiniMapTrackingFrame") then

							local icon = GetTrackingTexture()

							if (icon) then
								value:SetAlpha(MinimapBackdrop:GetAlpha())
							else
								value:SetAlpha(0)
							end
						else
							value:SetAlpha(MinimapBackdrop:GetAlpha())
						end
					end
				else
					if (name == "MiniMapMailFrame") then

						if (HasNewMail()) then

							MiniMapMailFrame:SetAlpha(Minimap:GetAlpha())

						end

					elseif (name == "MiniMapBattlefieldFrame") then

						for i=1, GetMaxBattlefieldID() do

							status, _, _, _, _, _, _ = GetBattlefieldStatus(i)

							if (status == "active" or status == "queued" or status == "confirm") then
								MiniMapBattlefieldFrame:SetAlpha(Minimap:GetAlpha())
							end
						end

					elseif (name == "MiniMapCompassRing") then

						if ( GetCVar("rotateMinimap") == "1" ) then
							v:SetAlpha(Minimap:GetAlpha())
						else
							v:SetAlpha(0)
						end
					else
						v:SetAlpha(Minimap:GetAlpha())
					end
				end
			end
		end
	end
end

local function controlOnUpdate(self, elapsed)

	local x, y = GetPlayerMapPosition("player")

	if(x == 0 and y == 0) then
		self.coord:SetText("")
	else
		self.coord:SetText(format("%i, %i", x*100, y*100))
	end

	if (Minimap:IsMouseOver(minimapBoundry.top, minimapBoundry.bottom, minimapBoundry.left, minimapBoundry.right) or InterfaceOptionsFrame:IsVisible()) then
		if (not self.shown) then
			showMinimapItems()
			minimapBoundry.top = 65
			minimapBoundry.bottom = -65
			minimapBoundry.left = -65
			minimapBoundry.right = 65
			self.shown = true
		end

	else
		if (self.shown) then
			hideMinimapItems()
			minimapBoundry.top = -50
			minimapBoundry.bottom = 10
			minimapBoundry.left = 10
			minimapBoundry.right = -10
			self.shown = false

		end
	end

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

	self.GDB = minimapbtnsGDB
	self.CDB = minimapbtnsCDB

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

	if (minimapElements[self.id]) then

		self:SetWidth(minimapElements[self.id]:GetWidth()+5)
		self:SetHeight(minimapElements[self.id]:GetHeight()+5)
		self:SetHitRectInsets(self:GetWidth()/2, self:GetWidth()/2, self:GetHeight()/2, self:GetHeight()/2)

		self.element = minimapElements[self.id]

		local objects = ION:GetParentKeys(self.element)

		for k,v in pairs(objects) do
			local name = v:gsub(self.element:GetName(), "")
			self[name:lower()] = _G[v]
		end

		self.element:ClearAllPoints()
		self.element:SetParent(self)
		self.element:Show()
		self.element:SetPoint("CENTER", self, "CENTER", -8, -3)
		self.element:SetScale(1)

	end
end

local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Ion-MiniMap") then

		minimapElements[1] = MinimapCluster

 		MinimapZoneTextButton:Hide()
 		--MinimapToggleButton:Hide()
 		MinimapBorderTop:Hide()
 		--MinimapZoomOut:SetPoint("CENTER",60, -34)
		--MiniMapBattlefieldFrame:ClearAllPoints()
		--MiniMapBattlefieldFrame:SetPoint("RIGHT", "MinimapBackdrop", -57, 99)
		--MiniMapMeetingStoneFrame:ClearAllPoints()
		--MiniMapMeetingStoneFrame:SetPoint("RIGHT", "MinimapBackdrop", 7, 12)
		MiniMapWorldMapButton:ClearAllPoints()
		MiniMapWorldMapButton:SetPoint("RIGHT", "MinimapBackdrop", 7, 39)
		MiniMapMailFrame:ClearAllPoints()
		MiniMapMailFrame:SetPoint("RIGHT", "MinimapBackdrop", -32, 90)
		GameTimeFrame:SetParent("MinimapBackdrop")

		self.coord = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		self.coord:SetPoint("BOTTOM", "Minimap", 0, 10)

		GDB = IonMiniMapGDB; CDB = IonMiniMapCDB

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

		minimapbarsGDB = GDB.minimapbars
		minimapbarsCDB = CDB.minimapbars

		minimapbtnsGDB = GDB.minimapbtns
		minimapbtnsCDB = CDB.minimapbtns

		ION:RegisterBarClass("minimap", "MiniMap Bar", "MiniMap", minimapbarsGDB, minimapbarsCDB, MINIMAPIndex, minimapbtnsGDB, "CheckButton", "IonAnchorButtonTemplate", { __index = ANCHOR }, #minimapElements, false, STORAGE, gDef)

		if (GDB.firstRun) then

			local bar, object = ION:CreateNewBar("minimap", 1, true)

			for i=1,#minimapElements do
				object = ION:CreateNewObject("minimap", i)
				bar:AddObjectToList(object)
			end

			GDB.firstRun = false

		else

			for id,data in pairs(minimapbarsGDB) do
				if (data ~= nil) then
					ION:CreateNewBar("minimap", id)
				end
			end

			for id,data in pairs(minimapbtnsGDB) do
				if (data ~= nil) then
					ION:CreateNewObject("minimap", id)
				end
			end
		end

		STORAGE:Hide()

	elseif (event == "PLAYER_LOGIN") then


	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		hideMinimapItems()

		PEW = true
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:SetScript("OnUpdate", controlOnUpdate)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")