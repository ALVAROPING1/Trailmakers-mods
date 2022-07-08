-- By ALVAROPING1

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function update()
	if active == true then
		playerList = tm.players.CurrentPlayers()

		for key,player in ipairs(playerList) do
			-- Creates a new table inside 'pathTracker' for the playerId if it doesn't exist
			if pathTracker[player.playerId] == nil then
				pathTracker[player.playerId] = {}
			end

			-- Appends the current position of the player to the end of 'pathTracker[player.playerId]'
			table.insert(pathTracker[player.playerId], tm.players.GetPlayerTransform(player.playerId).GetPosition())

			-- If 'pathTracker[player.playerId]' has length greater than 'maxPositions', removes the first element
			if #pathTracker[player.playerId] > maxPositions then
				table.remove(pathTracker[player.playerId], 1)
			end
		end
	end
end


-- Resets the saved data and starts recording
function start()
	active = true
	pathTracker = {}

	-- Replaces the UI
	tm.playerUI.ClearUI(0)
	tm.playerUI.AddUIButton(0, "stop", "Stop", stop)
	tm.playerUI.AddUILabel(0, "speed", "Tracking Speed (fps): " .. speed)
	tm.playerUI.AddUILabel(0, "maxPositions", "Max positions per player: " .. maxPositions)
end

-- Stops the recording
function stop()
	active = false

	-- Replaces the UI
	tm.playerUI.ClearUI(0)
	tm.playerUI.AddUIButton(0, "start", "Start", start)
	tm.playerUI.AddUIButton(0, "show", "Show Path", show)
	tm.playerUI.AddUILabel(0, "speed", "Tracking Speed (fps)")
	tm.playerUI.AddUIText(0, "setSpeed", tostring(speed), onSetSpeed)
	tm.playerUI.AddUILabel(0, "maxPositions", "Max positions per player")
	tm.playerUI.AddUIText(0, "setmaxPositions", tostring(maxPositions), onSetMaxPositions)
end



-- Spawns objects to show the path on the map
function show()
	for key, playerPositionArray in pairs(pathTracker) do
		for key2, playerPosition in pairs(playerPositionArray) do
			local pos = tm.vector3.Create(playerPosition.x, -10000, playerPosition.z)
			tm.physics.SpawnObject(pos, "PFB_Beacon")
		end
	end

	-- Replaces the UI
	tm.playerUI.ClearUI(0)
	tm.playerUI.AddUIButton(0, "hide", "Hide Path", hide)
end

-- Despawns the objects
function hide()
	tm.physics.ClearAllSpawns()

	-- Replaces the UI
	tm.playerUI.ClearUI(0)
	tm.playerUI.AddUIButton(0, "start", "Start", start)
	tm.playerUI.AddUIButton(0, "show", "Show Path", show)
	tm.playerUI.AddUILabel(0, "speed", "Tracking Speed (fps)")
	tm.playerUI.AddUIText(0, "setSpeed", tostring(speed), onSetSpeed)
	tm.playerUI.AddUILabel(0, "maxPositions", "Max positions per player")
	tm.playerUI.AddUIText(0, "setmaxPositions", tostring(maxPositions), onSetMaxPositions)
end


-- Sets the update speed
function onSetSpeed(callbackData)
	speed = tonumber(callbackData.value)

	if speed ~= nil then
		-- Makes sure speed is between 0 and 60
		if speed > 60 then
			speed = 60
		elseif speed <= 0 then
			speed = 1
		end

		tm.os.SetModTargetDeltaTime(1/speed)
	end
end

-- Updates the max length of 'pathTracker[player.playerId]'
function onSetMaxPositions(callbackData)
	local value = tonumber(callbackData.value)
	if value ~= nil then
		-- Makes sure 'maxPositions' is an int greater than or equal to 1
		if value < 1 then
			value = 1
		end

		maxPositions = math.floor(value)
	end
end


-- Initialization
tm.playerUI.AddUIButton(0, "start", "Start", start)
tm.playerUI.AddUIButton(0, "3", "Show", show)
tm.playerUI.AddUILabel(0, "speed", "Tracking Speed (fps)")
tm.playerUI.AddUIText(0, "setSpeed", "1", onSetSpeed)
tm.playerUI.AddUILabel(0, "maxPositions", "Max stored positions per player")
tm.playerUI.AddUIText(0, "setmaxPositions", "300", onSetMaxPositions)

speed = 1
tm.os.SetModTargetDeltaTime(60/60)
maxPositions = 300
active = false

tm.os.Log("Mod Loaded")