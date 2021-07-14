-- By ALVAROPING1

---------------------------------------------------------------------------------------------

function update()
	if frameAdvanceToggle == true and frameAdvance == true then -- Advances the physics 1 frame after onFrameAdvance() is called if frameAdvanceToggle is true
		frameAdvance = false
		tm.physics.SetTimeScale(0)

		-- Updates the time elapsed UI
		frames = frames + 1
		tm.playerUI.SetUIValue(0, "frames", "Frames: " .. frames)
		tm.playerUI.SetUIValue(0, "time", "Seconds: " .. string.format("%.16f", frames/60))
	end
end

---------------------------------------------------------------------------------------------

function onToggleFrameAdvance() -- Toggles frameAdvanceToggle
	tm.playerUI.ClearUI(0)

	if frameAdvanceToggle == true then -- If frameAdvanceToggle is deactivated resets the game speed, hides most of the UI and resets the amount of frames elapsed
		frameAdvanceToggle = false
		tm.physics.SetTimeScale(1)

		tm.playerUI.AddUILabel(0, "toggle", "Toggle Frame Advance (OFF): " .. keybinds.toggleFrameAdvance)

		frames = 0
	else -- If frameAdvanceToggle is activated shows the full UI and sets the game speed to 0
		frameAdvanceToggle = true
		tm.physics.SetTimeScale(0)

		tm.playerUI.AddUILabel(0, "toggle", "Toggle Frame Advance (ON): " .. keybinds.toggleFrameAdvance)
		tm.playerUI.AddUILabel(0, "advance", "Advance Frame: " .. keybinds.frameAdvance)
		tm.playerUI.AddUILabel(0, "resetTime", "Reset Time: " .. keybinds.timeReset)
		tm.playerUI.AddUILabel(0, "", "")
		tm.playerUI.AddUILabel(0, "timeElapsed", "---------------Time elapsed---------------")
		tm.playerUI.AddUILabel(0, "frames", "Frames: 0")
		tm.playerUI.AddUILabel(0, "time", "Seconds: 0.0000000000000000")
	end
end


function onFrameAdvance() -- Resets the game speed if frameAdvanceToggle is true, it will be set back to 0 on the next update() execution
    if frameAdvanceToggle == true then
		frameAdvance = true
		tm.physics.SetTimeScale(1)
	end
end


function onTimeReset() -- Resets the time elapsed
	if frameAdvanceToggle == true then
		frames = 0
		tm.playerUI.SetUIValue(0, "frames", "Frames: 0")
		tm.playerUI.SetUIValue(0, "time", "Seconds: 0.0000000000000000")
	end
end

---------------------------------------------------------------------------------------------

keybinds = { -- Contains all the keybinds used
	toggleFrameAdvance = "N",
	frameAdvance = "M",
	timeReset = "-"
}

frames = 0
loaded = false
tm.os.SetModTargetDeltaTime(1/60)

function onPlayerJoined() -- Only loads the mod once for the host
	if loaded == false then
		tm.playerUI.AddUILabel(0, "toggle", "Toggle Frame Advance (OFF): " .. keybinds.toggleFrameAdvance)

		tm.input.RegisterFunctionToKeyDownCallback(0, "onToggleFrameAdvance", keybinds.toggleFrameAdvance)
		tm.input.RegisterFunctionToKeyDownCallback(0, "onFrameAdvance", keybinds.frameAdvance)
		tm.input.RegisterFunctionToKeyDownCallback(0, "onTimeReset", keybinds.timeReset)

		loaded = true
		tm.os.Log("Mod loaded")
	end
end

tm.players.OnPlayerJoined.add(onPlayerJoined)