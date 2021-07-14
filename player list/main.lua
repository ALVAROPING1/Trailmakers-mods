function onPlayerJoined(player)
	local playerID = player.playerId
	tm.os.Log("Player joined. ID: " .. playerID)
	playerList = tm.players.CurrentPlayers()
	print_table(playerList)
end

tm.players.OnPlayerJoined.add(onPlayerJoined)

function print_table(_table)
	for key,value in pairs(_table) do
		out = "[" .. key .. "] = \"" .. tostring(value) .. "\""
		tm.os.Log(out)
	end
end