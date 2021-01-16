print("Leaderboard script version 3.00 loaded")


function onXPChanged(player, XP, level)
	if XP.Value>=level.Value * 10 then
		XP.Value = 0 
		level.Value = level.Value + 1 
	end
end

function onLevelUp(player, XP, level)
	local m = Instance.new("Hint")
	m.Parent = game.Workspace
	m.Text = player.Name .. " has leveled up!"
	wait(3)
	m.Parent = nil
   player.Humanoid.Health = 0
end


function onPlayerRespawned(player)
	wait(5)

	player.Character.Humanoid.Health = player.Character.Humanoid.Health + player.leaderstats.Level * 10

	player.Character.Humanoid.MaxHealth = player.Character.Humanoid.MaxHealth + player.leaderstats.Level * 10

end

function onPlayerEntered(newPlayer)
	
	local stats = Instance.new("IntValue")
	stats.Name = "leaderstats"
	local stats2 = Instance.new("IntValue")
	stats2.Name = "Tycoon"


	local cash = Instance.new("IntValue")
	cash.Name = "Cash" 				
	cash.Value = 10 			
   local kills = Instance.new("IntValue")
	kills.Name = "Kills"
	kills.Value = 0

	local deaths = Instance.new("IntValue")
	deaths.Name = "Deaths"
	deaths.Value = 0

   local level = Instance.new("IntValue")
   level.Name = "Level"
   level.Value = 1

   local xp = Instance.new("IntValue")
   xp.Name = "XP" 
   xp.Value = 0
   
   cash.Parent = stats
	stats2.Parent = newPlayer	
	stats.Parent = newPlayer
	kills.Parent = stats
	deaths.Parent = stats
   level.Parent = stats
   xp.Parent = stats

	xp.Changed:connect(function() onXPChanged(newPlayer, xp, level) end)
	level.Changed:connect(function() onLevelUp(newPlayer, xp, level) end)



	while true do
		if newPlayer.Character ~= nil then break end
		wait(5)
	end

	local humanoid = newPlayer.Character.Humanoid

	humanoid.Died:connect(function() onHumanoidDied(humanoid, newPlayer) end )

	
	newPlayer.Changed:connect(function(property) onPlayerRespawn(property, newPlayer) end )


	stats.Parent = newPlayer

end

function Send_DB_Event_Died(victim, killer)
	
	local killername = "unknown"
	if killer ~= nil then killername = killer.Name end
	print(victim.Name, " was killed by ", killername)

	if shared["deaths"] ~= nil then 
		shared["deaths"](victim, killer)
		print("Death event sent.")
	end
end

function Send_DB_Event_Kill(killer, victim)
	print(killer.Name, " killed ", victim.Name)
	if shared["kills"] ~= nil then 
		shared["kills"](killer, victim)
		print("Kill event sent.")
	end
end



function onHumanoidDied(humanoid, player)
	local stats = player:findFirstChild("leaderstats")
	if stats ~= nil then
		local deaths = stats:findFirstChild("Deaths")
		deaths.Value = deaths.Value + 1

		

		local killer = getKillerOfHumanoidIfStillInGame(humanoid)


		Send_DB_Event_Died(player, killer)
		handleKillCount(humanoid, player)
	end
end

function onPlayerRespawn(property, player)
	
	
	if property == "Character" and player.Character ~= nil then
		local humanoid = player.Character.Humanoid
			local p = player
			local h = humanoid
			humanoid.Died:connect(function() onHumanoidDied(h, p) end )
	end
end

function getKillerOfHumanoidIfStillInGame(humanoid)
	
	local tag = humanoid:findFirstChild("creator")


	if tag ~= nil then
		
		local killer = tag.Value
		if killer.Parent ~= nil then 
			return killer
		end
	end

	return nil
end

function handleKillCount(humanoid, player)
	local killer = getKillerOfHumanoidIfStillInGame(humanoid)
	if killer ~= nil then
		local stats = killer:findFirstChild("leaderstats")
		if stats ~= nil then
			local kills = stats:findFirstChild("Kills")
		   local cash = stats:findFirstChild("Cash")
         local xp = stats:findFirstChild("XP")
			if killer ~= player then
				kills.Value = kills.Value + 1
            cash.Value = cash.Value + 50
            xp.Value = xp.Value + 3
				
			else
				kills.Value = kills.Value - 0
				
			end
			Send_DB_Event_Kill(killer, player)
		end
	end
end

game.Players.ChildAdded:connect(onPlayerEntered)
