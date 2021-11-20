L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[REVENANT.name] = "Revenant"
L[TEAM_REVENANT] = "TEAM Revenant"
L["hilite_win_" .. TEAM_REVENANT] = "THE REVENANT WON"
L["win_" .. TEAM_REVENANT] = "The Revenant has won!"
L["info_popup_" .. REVENANT.name] = [[You are a Revenant, work with the innocents to win!]]
L["body_found_" .. REVENANT.abbr] = "They were a Revenant."
L["search_role_" .. REVENANT.abbr] = "This person was a Revenant!"
L["target_" .. REVENANT.name] = "Revenant"
L["ttt2_desc_" .. REVENANT.name] = [[The Revenant is an innocent role and works with the innocents to win. However if he dies he will be revived
 and turned into a Revenant, who must win by being the last man standing.]]

-- OTHER ROLE LANGUAGE STRINGS

L["ttt2_role_reven_revival_message"] = "You will be revived as a Revenant!"

L["label_reven_revival_time"] = "How long it takes to revive"
L["label_reven_damage_bonus"] = "Damage bonus"