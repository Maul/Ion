--Ion, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

Ion.MANAGED_ACTION_STATES = {

	paged = {
		homestate = "paged1",
		states = "[bar:1] paged1; [bar:2] paged2; [bar:3] paged3; [bar:4] paged4; [bar:5] paged5; [bar:6] paged6",
		rangeStart = 2,
		rangeStop = 6,
		order = 1,
	},

	stance = {
		homestate = "stance0",
		states = "[stance:0] stance0; [stance:1] stance1; [stance:2] stance2; [stance:3] stance3; [stance:4] stance4; [stance:5] stance5; [stance:6] stance6; [stance:7] stance7",
		rangeStart = 1,
		rangeStop = 8,
		order = 2,
	},

	pet = {
		homestate = "pet1",
		states = "[nopet] pet1; [@pet,exists,nodead] pet2",
		rangeStart = 2,
		rangeStop = 3,
		order = 3,
	},

	alt = {
		states = "[mod:alt] alt1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 4,
	},

	ctrl = {
		states = "[mod:ctrl] ctrl1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 5,
	},

	shift = {
		states = "[mod:shift] shift1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 6,
	},

	stealth = {
		states = "[stealth] stealth1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 7,
	},

	reaction = {
		states = "[@target,harm] reaction1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 8,
	},

	combat = {
		states = "[combat] combat1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 9,
	},

	group = {
		states = "[group:raid] group1; [group:party] group2; laststate",
		rangeStart = 1,
		rangeStop = 2,
		order = 10,
	},

	fishing = {
		states = "[worn:fishing pole] fishing1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 11,
	},

	custom = {
		states = "",
		rangeStart = 1,
		rangeStop = 1,
		order = 12,
	},

	vehicle = {
		states = "[vehicleui] vehicle1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 13,
	},

	possess = {
		states = "[possessbar] possess1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 14,
	},

	override = {
		states = "[overridebar] override1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 15,
	},

	extrabar = {
		states = "[extrabar] extrabar1; laststate",
		rangeStart = 1,
		rangeStop = 1,
		order = 16,
	},

}

Ion.MANAGED_BAR_STATES = {

	paged = {
		homestate = "paged1",
		states = "[bar:1] paged1; [bar:2] paged2; [bar:3] paged3; [bar:4] paged4; [bar:5] paged5; [bar:6] paged6",
		rangeStart = 2,
		rangeStop = 6,
		order = 1,
	},

	stance = {
		homestate = "stance0",
		states = "[stance:0] stance0; [stance:1] stance1; [stance:2] stance2; [stance:3] stance3; [stance:4] stance4; [stance:5] stance5; [stance:6] stance6; [stance:7] stance7",
		rangeStart = 1,
		rangeStop = 8,
		order = 2,
	},

	pet = {
		homestate = "pet0",
		states = "[vehicleui] pet0; [possessbar] pet0; [overridebar] pet0; [nopet] pet0; [pet] pet1",
		rangeStart = 2,
		rangeStop = 3,
		order = 3,
	},

	alt = {
		states = "[nomod:alt] alt0; [mod:alt] alt1",
		rangeStart = 1,
		rangeStop = 1,
		order = 4,
	},

	ctrl = {
		states = "[nomod:ctrl] ctrl0; [mod:ctrl] ctrl1",
		rangeStart = 1,
		rangeStop = 1,
		order = 5,
	},

	shift = {
		states = "[nomod:shift] shift0; [mod:shift] shift1",
		rangeStart = 1,
		rangeStop = 1,
		order = 6,
	},

	stealth = {
		states = "[nomod:stealth] stealth0; [stealth] stealth1",
		rangeStart = 1,
		rangeStop = 1,
		order = 7,
	},

	reaction = {
		states = "[@target,help] reaction0; [@target,harm] reaction1",
		rangeStart = 1,
		rangeStop = 1,
		order = 8,
	},

	combat = {
		states = "[nocombat] combat0; [combat] combat1",
		rangeStart = 1,
		rangeStop = 1,
		order = 9,
	},

	group = {
		states = "[nogroup] group0; [group:raid] group1; [group:party] group2",
		rangeStart = 1,
		rangeStop = 2,
		order = 10,
	},

	fishing = {
		states = "[noworn:fishing pole] fishing0; [worn:fishing pole] fishing1",
		rangeStart = 1,
		rangeStop = 1,
		order = 11,
	},

	custom = {
		states = "",
		rangeStart = 1,
		rangeStop = 1,
		order = 12,
	},

	vehicle = {
		states = "[novehicleui] vehicle0; [vehicleui] vehicle1",
		rangeStart = 1,
		rangeStop = 1,
		order = 13,
	},

	possess = {
		states = "[nopossessbar] possess0; [possessbar] possess1",
		rangeStart = 1,
		rangeStop = 1,
		order = 13,
	},

	override = {
		states = "[nooverridebar] override0; [overridebar] override1",
		rangeStart = 1,
		rangeStop = 1,
		order = 13,
	},

	extrabar = {
		states = "[noextrabar] extrabar0; [extrabar] extrabar1",
		rangeStart = 1,
		rangeStop = 1,
		order = 13,
	},
}