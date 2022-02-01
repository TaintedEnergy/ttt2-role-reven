if SERVER then
	AddCSLuaFile()

	-- Icon Materials
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_reven.vmt")
end

roles.InitCustomTeam(ROLE.name, {
    icon = "vgui/ttt/dynamic/roles/icon_reven",
    color = Color(47, 34, 72, 255)
})

-- General settings
function ROLE:PreInitialize()
	self.color = Color(47, 34, 72, 255) -- role colour

	-- settings for the role iself
	self.abbr = "reven"                     -- Abbreviation
	self.survivebonus = 1                   -- points for surviving longer
	self.preventFindCredits = true          -- can't take credits from bodies
	self.preventKillCredits = true          -- does not get awarded credits for kills
	self.preventTraitorAloneCredits = true  -- no credits.
	self.preventWin = false                 -- cannot win unless he switches roles
	self.score.killsMultiplier = 2          -- gets points for killing enemies of their team
	self.score.teamKillsMultiplier = -8     -- loses points for killing teammates
	self.defaultEquipment = INNO_EQUIPMENT  -- here you can set up your own default equipment
	self.disableSync = true                 -- dont tell the player about his role

	-- settings for this roles teaminteraction
	self.unknownTeam = true -- Doesn't know his teammates -> Is innocent also disables voicechat
	self.defaultTeam = TEAM_INNOCENT -- Is part of team innocent

	-- ULX convars
	self.conVarData = {
		pct = 0.17,                         -- necessary: percentage of getting this role selected (per player)
		maximum = 1,                        -- maximum amount of roles in a round
		minPlayers = 8,                     -- minimum amount of players until this role is able to get selected
		credits = 0,                        -- the starting credits of a specific role
		shopFallback = SHOP_DISABLED,       -- Setting wether the role has a shop and who's shop it will use if no custom shop is set
		togglable = true,                   -- option to toggle a role for a client if possible (F1 menu)
		random = 33                         -- percentage of the chance that this role will be in a round (if set to 100 it will spawn in all rounds)
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_INNOCENT)
end

if SERVER then

	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		if ply.revenant_state == nil or ply.revenant_state == 0 then
			ply.revenant_state = 1
			ply.isRevenantWorldspawn = false
		end
	end

	hook.Add("TTT2PostPlayerDeath", "RevenantDeath", function(ply, infl, attacker)
		if ply:GetSubRole() ~= ROLE_REVENANT or ply.revenant_state == 2 then return end
		if SpecDM and (ply.IsGhost and ply:IsGhost() or (attacker.IsGhost and attacker:IsGhost())) then return end

		local spawnpoint = plyspawn.GetRandomSafePlayerSpawnPoint(ply)

		ply:Revive(GetConVar("ttt2_reven_revival_time"):GetInt(),
			function(p)
				ply.revenant_state = 2
				ply:UpdateTeam(TEAM_REVENANT)
				ply:ResetConfirmPlayer()
				SendFullStateUpdate()
				if ply.isRevenantWorldspawn or GetConVar('ttt2_reven_worldspawn'):GetBool() then
					ply:SetPos(spawnpoint.pos)
					ply:SetAngles(spawnpoint.ang)
				end
			end,
			nil,
			false,
			REVIVAL_BLOCK_ALL
		)
		if not GetConVar('ttt2_reven_worldspawn'):GetBool() then
			ply:SendRevivalReason("ttt2_role_reven_revival_message_spawn_option")
		else
			ply:SendRevivalReason("ttt2_role_reven_revival_message")
		end
	end)

	hook.Add("TTT2SpecialRoleSyncing", "TTT2RoleRevenMod", function(ply, tbl)
		for rev in pairs(tbl) do
			if rev:GetSubRole() == ROLE_REVENANT and rev.revenant_state < 2 then
				if ply == rev then
					tbl[rev] = {ROLE_INNOCENT, TEAM_INNOCENT}
				else
					tbl[rev] = {ROLE_NONE, TEAM_NONE}
				end
			end
		end
	end)

	hook.Add("TTTCanSearchCorpse", "TTT2RevenChangeCorpseToInnocent", function(ply, corpse)
		if IsValid(corpse) and corpse.was_role == ROLE_REVENANT and CORPSE.GetPlayer(corpse).revenant_state < 2 then
			corpse.was_role = ROLE_INNOCENT
			corpse.role_color = INNOCENT.color
			corpse.is_hidden_reven_corpse = true
		end
	end)

	hook.Add("TTT2ConfirmPlayer", "TTT2RevenChangeRoleTeam", function(confirmed, finder, corpse)
		if IsValid(confirmed) and corpse and corpse.is_hidden_reven_corpse then
			confirmed:ConfirmPlayer(true)
			SendRoleListMessage(ROLE_INNOCENT, TEAM_INNOCENT, {confirmed:EntIndex()})
			events.Trigger(EVENT_BODYFOUND, finder, corpse)

			return false
		end
	end)

	hook.Add("ScalePlayerDamage", "RevenantDamageScale", function(ply, hitgroup, dmginfo)
		local attacker = dmginfo:GetAttacker()
		if attacker:GetSubRole() == ROLE_REVENANT and ply.revenant_state == 2 then
            local bonus = GetConVar("ttt2_reven_damage_bonus"):GetFloat()
            dmginfo:ScaleDamage(1 + bonus)
        end
	end)

	local function ResetRevenants() 
		if not REVENANT then return end
		for _, p in ipairs(player.GetAll()) do
		  if IsValid(p) then p.revenant_state = 0 end
		end
	  end
	
	  hook.Add("TTTEndRound", "DuelistEndRound", ResetRevenants)
	  hook.Add("TTTPrepareRound", "DuelistPrepareRound", ResetRevenants)

	  hook.Add("KeyPress", "TTT2RevenantDoWorldSpawn", function (ply, key)
		if ply:GetSubRole() ~= ROLE_REVENANT then return end
		if not ply.isReviving then return end
		if key ~= IN_RELOAD then return end
		if ply.isRevenantWorldspawn or GetConVar("ttt2_reven_worldspawn"):GetBool() then return end

		ply.isRevenantWorldspawn = true
		ply:SendRevivalReason("ttt2_role_reven_revival_message")

	  end)
	
end

if CLIENT then
	function ROLE:AddToSettingsMenu(parent)
		local form = vgui.CreateTTT2Form(parent, "header_roles_additional")

		form:MakeSlider({
			serverConvar = "ttt2_reven_revival_time",
			label = "label_reven_revival_time",
			min = 0,
			max = 100,
			decimal = 0
		})

		form:MakeSlider({
			serverConvar = "ttt2_reven_damage_bonus",
			label = "label_reven_damage_bonus",
			min = 0,
			max = 5,
			decimal = 1
		})

		form:MakeCheckbox({
			serverConvar = "ttt2_reven_worldspawn",
			label = "label_reven_worldspawn",
		})
	end
end