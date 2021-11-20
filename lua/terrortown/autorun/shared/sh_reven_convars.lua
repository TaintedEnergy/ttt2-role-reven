CreateConVar("ttt2_reven_revival_time", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
CreateConVar("ttt2_reven_damage_bonus", 0.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

hook.Add("TTTUlxDynamicRCVars", "ttt2_ulx_dynamic_wrath_convars", function(tbl)
	tbl[ROLE_REVENANT] = tbl[ROLE_REVENANT] or {}

	table.insert(tbl[ROLE_REVENANT], {
		cvar = "ttt2_reven_revival_time",
		slider = true,
		min = 0,
		max = 100,
		decimal = 0,
		desc = "ttt2_reven_revival_time (def. 15)"
	})

	table.insert(tbl[ROLE_REVENANT], {
		cvar = "ttt2_reven_damage_bonus",
		slider = true,
		min = 0,
		max = 5,
		decimal = 1,
		desc = "ttt2_reven_damage_bonus (def. 0.5)"
	})
end)