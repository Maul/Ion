--Ion Macraoon Macro Grabber, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

local ION, GDB, PEW = {}

IonMMGGDB = { index = {}, macros = {} }

local tempMacro = {
	macro_Text = "",
	macro_Icon = false,
	macro_Name = "",
	macro_Auto = false,
	macro_Watch = false,
	macro_Equip = false,
	macro_Note = "",
	macro_UseNote = false,
}


local function controlOnEvent(self, event, ...)

	if (event == "ADDON_LOADED" and ... == "Ion-MMG") then

		ION.player, ION.class, ION.realm = UnitName("player"), select(2, UnitClass("player")), GetRealmName()

		GDB = IonMMGGDB

		if (not GDB.index[ION.realm]) then
			GDB.index[ION.realm] = {}
		end

		if (not GDB.index[ION.realm][ION.player]) then
			GDB.index[ION.realm][ION.player] = {}
		end

		if (not GDB.macros[ION.realm]) then
			GDB.macros[ION.realm] = {}
		end

		if (not GDB.macros[ION.realm][ION.player]) then
			GDB.macros[ION.realm][ION.player] = {}
		end

		if (MacaroonMacroVault) then

			for realm,characters in pairs(MacaroonMacroVault) do

				if (not GDB.macros[realm]) then
					GDB.macros[realm] = {}
				end

				if (not GDB.index[realm]) then
					GDB.index[realm] = {}
				end

				if (type(characters) == "table") then

					for character,macros in pairs(characters) do

						if (not GDB.macros[realm][character]) then
							GDB.macros[realm][character] = {}
						end

						if (not GDB.index[realm][character]) then
							GDB.index[realm][character] = {}
						end

						if (type(macros) == "table") then

							for index,macro in pairs(macros) do

								if (not GDB.index[realm][character][index] and type(macro) == "table") then

									if (macro[1] and type(macro[1]) == "string" and #macro[1] > 0 and not macro[1]:find("#autowrite")) then

										tempMacro.macro_Text = macro[1]

										if (type(macro[2]) == "string") then
											if (macro[2] == "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK") then
												tempMacro.macro_Icon = false
											else
												tempMacro.macro_Icon = macro[2]
											end
										else
											tempMacro.macro_Icon = false
										end

										tempMacro.macro_Name = macro[3]
										tempMacro.macro_Note = macro[4]
										tempMacro.macro_UseNote = macro[5]

										tinsert(GDB.macros[realm][character], CopyTable(tempMacro))

										GDB.index[realm][character][index] = true
									end
								end
							end
						end
					end
				end
			end
		end

		if (MacaroonSavedState and MacaroonSavedState.buttons) then

			local index

			for id, data in pairs(MacaroonSavedState.buttons) do

				for spec, macro in pairs(data) do

					if (type(macro) == "table") then

						index = "Button "..id..": Spec "..spec

						if (index and not GDB.index[ION.realm][ION.player][index]) then

							if (macro.macro and type(macro.macro) == "string" and #macro.macro > 0 and not macro.macro:find("#autowrite")) then

								tempMacro.macro_Text = macro.macro

								if (type(macro.macroIcon) == "string") then
									if (macro.macroIcon == "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK") then
										tempMacro.macro_Icon = false
									else
										tempMacro.macro_Icon = macro.macroIcon
									end
								else
									tempMacro.macro_Icon = false
								end

								tempMacro.macro_Name = macro.macroName
								tempMacro.macro_Note = macro.macroNote
								tempMacro.macro_UseNote = macro.macroUseNote
								tempMacro.macro_Auto = macro.macroAuto

								tinsert(GDB.macros[ION.realm][ION.player], CopyTable(tempMacro))

								GDB.index[ION.realm][ION.player][index] = true
							end
						end
					end
				end
			end
		end

	elseif (event == "PLAYER_ENTERING_WORLD" and not PEW) then

		PEW = true
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", controlOnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")