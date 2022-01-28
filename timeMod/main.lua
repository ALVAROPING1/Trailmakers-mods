-- By ALVAROPING1

-----------------------------------------------------------------------------------------------------------

function update()
	if frameAdvanceToggle and frameAdvance then -- Advances the physics 1 frame after onFrameAdvance() is called if frameAdvanceToggle is true
		frameAdvance = false
		tm.physics.SetTimeScale(0)

		-- Updates the time elapsed UI
		frames = frames + 1
		tm.playerUI.SetUIValue(0, "frames", "Frames: " .. frames)
		tm.playerUI.SetUIValue(0, "time", "Seconds: " .. string.format("%.16f", frames/60))
	end
end

-----------------------------------------------------------------------------------------------------------

-- Changes between the 2 modes of operation
function changeMode()
	tm.playerUI.ClearUI(0)
	if mode == 0 then -- If the mode is 0 (frame advance), switches to change time speed
		mode = 1
		generateChangeTimeSpeedUI()
	else -- Else, switches to frame advance
		mode = 0
		generateFrameAdvanceUI()
	end
end

-- Activates the respective mode
function onToggleActivate()
	if mode == 0 then
		onToggleFrameAdvance()
	else
		onToggleTimeSpeed()
	end
end


---------------------------------------------------------------------------------------------
-- Frame advance mode
---------------------------------------------------------------------------------------------

-- Toggles frameAdvanceToggle
function onToggleFrameAdvance()
	tm.playerUI.ClearUI(0)

	if frameAdvanceToggle then -- If frameAdvanceToggle is deactivated resets the game speed, hides most of the UI and resets the amount of frames elapsed
		frameAdvanceToggle = false
		tm.physics.SetTimeScale(1)

		generateFrameAdvanceUI()

		frames = 0
	else -- If frameAdvanceToggle is activated shows the full UI and sets the game speed to 0
		frameAdvanceToggle = true
		tm.physics.SetTimeScale(0)

		tm.playerUI.AddUILabel(0, "mode", "")
		tm.playerUI.AddUILabel(0, "toggle", "Toggle Frame Advance (ON): " .. keybinds.toggleActivate)
		tm.playerUI.AddUILabel(0, "advance", "Advance Frame: " .. keybinds.frameAdvance)
		tm.playerUI.AddUILabel(0, "resetTime", "Reset Time: " .. keybinds.timeReset)
		tm.playerUI.AddUILabel(0, "", "")
		tm.playerUI.AddUILabel(0, "timeElapsed", "---------------Time elapsed---------------")
		tm.playerUI.AddUILabel(0, "frames", "Frames: 0")
		tm.playerUI.AddUILabel(0, "time", "Seconds: 0.0000000000000000")
	end
end

-- Resets the game speed if frameAdvanceToggle is true, it will be set back to 0 on the next update() execution
function onFrameAdvance()
    if frameAdvanceToggle then
		frameAdvance = true
		tm.physics.SetTimeScale(1)
	end
end

-- Resets the time elapsed
function onTimeReset()
	if frameAdvanceToggle then
		frames = 0
		tm.playerUI.SetUIValue(0, "frames", "Frames: 0")
		tm.playerUI.SetUIValue(0, "time", "Seconds: 0.0000000000000000")
	end
end


---------------------------------------------------------------------------------------------
-- Change time speed mode
---------------------------------------------------------------------------------------------

-- Toggles the specified time speed
function onToggleTimeSpeed()
	tm.playerUI.ClearUI(0)

	if timeSpeedToggle then -- If timeSpeedToggle is deactivated resets the game speed
		timeSpeedToggle = false
		tm.physics.SetTimeScale(1)

		generateChangeTimeSpeedUI()
	else -- If timeSpeedToggle is activated removes the change mode button and changes the time speed
		timeSpeedToggle = true
		tm.physics.SetTimeScale(timeSpeed)

		tm.playerUI.AddUILabel(0, "mode", "")
		tm.playerUI.AddUILabel(0, "toggle", "Toggle Time Speed (ON): " .. keybinds.toggleActivate)
		tm.playerUI.AddUILabel(0, "timeSpeed", "Time speed")
		tm.playerUI.AddUIText(0, "timeSpeedStr", tostring(timeSpeed), onSetTimeSpeed)
	end
end

-- Sets the time speed
function onSetTimeSpeed(callbackData)
	timeSpeed = tonumber(callbackData.value)

	if timeSpeed ~= nil then
		if timeSpeed <= 0 then -- Makes sure speed is positive
			timeSpeed = 1
		end

		if timeSpeedToggle then -- If timeSpeedToggle is activated, applies the modified speed instantly
			tm.physics.SetTimeScale(timeSpeed)
		end
	end
end

---------------------------------------------------------------------------------------------
-- UI
---------------------------------------------------------------------------------------------

function generateFrameAdvanceUI()
	tm.playerUI.AddUIButton(0, "mode", "Mode: Frame Advance", changeMode)
	tm.playerUI.AddUILabel(0, "toggle", "Toggle Frame Advance (OFF): " .. keybinds.toggleActivate)
end

function generateChangeTimeSpeedUI()
	tm.playerUI.AddUIButton(0, "mode", "Mode: Change Time Speed", changeMode)
	tm.playerUI.AddUILabel(0, "toggle", "Toggle Time Speed (OFF): " .. keybinds.toggleActivate)
	tm.playerUI.AddUILabel(0, "timeSpeed", "Time speed")
	tm.playerUI.AddUIText(0, "timeSpeedStr", tostring(timeSpeed), onSetTimeSpeed)
end

-----------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------

-- Variables
frameAdvanceToggle = false
timeSpeedToggle = false
frames = 0
timeSpeed = 1
mode = 0

-- Update speed
tm.os.SetModTargetDeltaTime(1/60)

-- Keybinds
keybinds = { -- Contains all the keybinds used
	toggleActivate = "N",
	frameAdvance = "M",
	timeReset = "-"
}

tm.input.RegisterFunctionToKeyDownCallback(0, "onToggleActivate", keybinds.toggleActivate)
tm.input.RegisterFunctionToKeyDownCallback(0, "onFrameAdvance", keybinds.frameAdvance)
tm.input.RegisterFunctionToKeyDownCallback(0, "onTimeReset", keybinds.timeReset)

-- UI
generateFrameAdvanceUI()

-- Log message
tm.os.Log("Mod loaded")