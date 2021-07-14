-- By ALVAROPING1

---------------------------------------------------------------------------------------------
-- Initialization

tm.os.SetModTargetDeltaTime(25/60) -- Game speed

playerAmount = 0 -- Current player amount

keybinds = { -- Contains all the keybinds used
	start = "Z",
	jump = "X",
}

-- Randomness
math.randomseed(os.time())
math.random()
math.random()
math.random()

-- Game variables
gameVariables = {}
-- Highscores image, first index doesn't change
highscoresImage = {"╚═══════════════════╝"}

tm.os.Log("Mod loaded")

---------------------------------------------------------------------------------------------
-- Image generation

function overlayCharacter(_id, _line, _position, _character) -- Replaces the character at line _line and position _position with _character
	gameVariables[_id].image[_line] = string.sub(gameVariables[_id].image[_line], 1, _position) .. _character .. string.sub(gameVariables[_id].image[_line], _position+2, 10)
end


function centerText(_text, _lineLength) -- Returns the input string centered in a lineLength characters long string
	-- Calculates the amount of spaces requires for the text to be at the center
	local center = (_lineLength-string.len(_text))/2
	--Adds the left frame border
	local centeredText = "║"
	-- Adds spaces to the left of the text
	for i=1, math.ceil(center) do
		centeredText = centeredText .. " "
	end
	-- Adds the text
	centeredText = centeredText .. _text
	-- Adds spaces to the right of the text
	for i=1, math.floor(center) do
		centeredText = centeredText .. " "
	end
	-- Adds the right frame border
	centeredText = centeredText .. "║"
	return centeredText
end



function generateFrame(_id) -- Creates the base image with the frame in which other objects are overlaid
	gameVariables[_id].image[14] = "╔════════╗"
	for i=2, 13 do
		gameVariables[_id].image[i] = "║        ║"
	end
	gameVariables[_id].image[1] = "╚════════╝"
end


function generatePipes(_id) -- Overlays the pipes on the image
	generatePipe(_id, 1, 8)
	if gameVariables[_id].pipeState[2] ~= 0 then -- A pipe height of 0 is considered as the pipe not existing
		generatePipe(_id, 2, 4)
	end
end

function generatePipe(_id, _pipe, _position) -- Creates a pipe at position position with height pipeState[pipe]
	local _pipeState = gameVariables[_id].pipeState[_pipe]
	local _position = _position-gameVariables[_id].pipePosition
	-- Overlays the middle sections of the pipe
	for i=2, _pipeState-1 do
		overlayCharacter(_id, i, _position, "║")
	end
	for i=_pipeState+5, 13 do
		overlayCharacter(_id, i, _position, "║")
	end

	--Overlays the bottom of the bottom section of the pipe
	overlayCharacter(_id, 1, _position, "╩")
	--Overlays the top of the bottom section of the pipe
	overlayCharacter(_id, _pipeState, _position, "╥")
	--Overlays the bottom of the top section of the pipe
	overlayCharacter(_id, _pipeState+4, _position, "╨")
	--Overlays the top of the top section of the pipe
	overlayCharacter(_id, 14, _position, "╦")
end


function generatePlayer(_id) -- Overlays the player on the image
	overlayCharacter(_id, gameVariables[_id].altitude+1, 2, "●")
end


function generateScore(_id) -- Adds the score counter to the image
	gameVariables[_id].image[16] = centerText(tostring(gameVariables[_id].score), 17)
end


function imageFixMonoSpace(_id) -- Fixes the image so all characters have (aproximatelly) the same width, required since the UI doesn't use a monoespace font
	-- Replaces each space in the image with 2 spaces
	for i=1, 14 do
		local _image = ""
		for j=1, string.len(gameVariables[_id].image[i]) do
			local _char = string.sub(gameVariables[_id].image[i], j, j)
			if _char == " " then
				_image = _image .. "  "
			else
				_image = _image .. _char
			end
		end
		gameVariables[_id].image[i] = _image
	end
end


function printImage(_id, _lines, _image) -- Displays the generated image on the UI
	for i=_lines, 1, -1 do
		tm.playerUI.SetUIValue(_id, i, _image[i])
	end
end



function renderImage(_id) -- Creates and displays the image. Characters used: ═ ║ ╗ ╔ ╝ ╚ ╦ ╩ ╥ ╨ ╡ ╞ ●
	-- Generate image
	generateFrame(_id)
	generatePipes(_id)
	generatePlayer(_id)
	generateScore(_id)

	-- Display image
	imageFixMonoSpace(_id)
	printImage(_id, 18, gameVariables[_id].image)
end


function updateHighscoresScreen() -- Updates the highscore image
	-- Adds the highscore of each player to the image
	for key,player in ipairs(playerList) do
		local playerID = player.playerId
		text = tm.players.GetPlayerName(playerID) .. ": " .. gameVariables[playerID].highscore
		highscoresImage[key+1] = text
	end
	-- Adds the frame of the image
	highscoresImage[highscoreLines] = "╔═════╡Highscores╞═════╗"
end

function reloadHighscoresScreen() -- Completely reloads the highscore screen for the players in that screen
	updateHighscoresScreen()

	for key,player in ipairs(playerList) do
		local _id = player.playerId
		if gameVariables[_id].showHighscores == true then
			onLoadHighscoresScreen(_id)
		end
	end
end

---------------------------------------------------------------------------------------------
-- Game Logic
if true then
function updatePipes(_id) -- Moves the pipes 1 position to the left and creates a new one if necessary
	gameVariables[_id].pipePosition = (gameVariables[_id].pipePosition + 1) % 4
	if gameVariables[_id].pipePosition == 0 then
		gameVariables[_id].pipeState[2] = gameVariables[_id].pipeState[1]
		gameVariables[_id].pipeState[1] = math.random(2, 9)
	end
end


function updateScore(_id) -- Increases score and highscore when necessary
	if gameVariables[_id].pipePosition == 3 and gameVariables[_id].pipeState[2] ~= 0 then
		gameVariables[_id].score = gameVariables[_id].score + 1
	end

	if gameVariables[_id].score > gameVariables[_id].highscore then
		gameVariables[_id].highscore = gameVariables[_id].score
	end
end


function checkCollision(_id) -- Checks if the player has collided with a pipe
	if gameVariables[_id].pipePosition == 2 and gameVariables[_id].pipeState[2] ~=0 then
		if gameVariables[_id].altitude < gameVariables[_id].pipeState[2] or gameVariables[_id].altitude > gameVariables[_id].pipeState[2] + 2 then
			gameVariables[_id].collision = true
			tm.playerUI.SetUIValue(_id, "death", "You died, press " .. keybinds.start .. " to restart")
		end
	end
end


function updateAltitude(_id) -- Updates the altitude of the player
	gameVariables[_id].altitude = gameVariables[_id].altitude - 1
	-- Checks if the player has hit the ground
	if gameVariables[_id].altitude < 0 then
		gameVariables[_id].collision = true
		tm.playerUI.SetUIValue(_id, "death", "You died, press " .. keybinds.start .. " to restart")
	end
end

function onJump(_id) -- Increases the altitude of the player when the jump keybind is pressed
	if gameVariables[_id].showHighscores == false then
		gameVariables[_id].altitude = gameVariables[_id].altitude + 4
		-- Sets 12 as the maximum altitude
		if gameVariables[_id].altitude > 12 then
			gameVariables[_id].altitude = 12
		end
	end
end


function onStart(_id) -- Resets game variables before starting the game
	if gameVariables[_id].collision == true and gameVariables[_id].showHighscores == false then
		gameVariables[_id].start = true

		gameVariables[_id].pipeState = {0, 0} -- Height of the pipes
		gameVariables[_id].pipePosition = -1 -- Position of the pipes

		gameVariables[_id].altitude = 7 -- Altitude of the player
		gameVariables[_id].collision = false -- Collision state of the player
		tm.playerUI.SetUIValue(_id, "death", "")

		gameVariables[_id].score = 0 -- Score counter

		gameVariables[_id].image = {"", "", "", "", "", "", "", "", "", "", "", "", "", "", "╚════════╝", "", "╔═╡Score╞═╗"} -- Storage of the generated image
	end
end
end
---------------------------------------------------------------------------------------------
-- Game loop

function updateGameState(_id) -- Updates the game state for the given player if necessary
	if gameVariables[_id].collision == false then
		-- Level generation
		updatePipes(_id)

		-- Score control
		updateScore(_id)

		-- Image generation
		renderImage(_id)

		-- Collision detection
		checkCollision(_id)

		-- Altitude control
		updateAltitude(_id)
	end
end


function update()
	playerList = tm.players.CurrentPlayers()

	for key,player in ipairs(playerList) do
		local playerID = player.playerId
		if gameVariables[playerID].showHighscores == false then
			updateGameState(playerID)
		else
			printImage(playerID, highscoreLines, highscoresImage)
		end
	end

	if reload == true then
		reloadHighscoresScreen()
		reload = false
	else
		updateHighscoresScreen()
	end
end

---------------------------------------------------------------------------------------------
-- UI Screens

function onLoadGameScreen(callbackData) -- Loads the game screen
	local playerID
	if type(callbackData) == "number" then
        playerID = callbackData
    else
        playerID = callbackData.playerId
    end

	-- Clears the UI
	tm.playerUI.ClearUI(playerID)

	-- Adds the UILabels used to display the image
	for i=17, 1, -1 do
		tm.playerUI.AddUILabel(playerID, i, gameVariables[playerID].image[i])
	end
	-- Adds UILabels with the controls as well as an empty line
	tm.playerUI.AddUILabel(playerID, "death", "")
	tm.playerUI.AddUILabel(playerID, "controls", "Controls:")
	tm.playerUI.AddUILabel(playerID, "start", "Start: " .. keybinds.start)
	tm.playerUI.AddUILabel(playerID, "jump", "Jump: " .. keybinds.jump)
	-- Adds the "See highscores" button
	tm.playerUI.AddUIButton(playerID, "highscore", "See Highscores", onLoadHighscoresScreen)

	if gameVariables[playerID].start == true and gameVariables[playerID].collision == true then
		tm.playerUI.SetUIValue(playerID, "death", "You died, press " .. keybinds.start .. " to restart")
	end
	-- Sets UI state
	gameVariables[playerID].showHighscores = false
end


function onLoadHighscoresScreen(callbackData) -- Loads the highscores screen
	local playerID
	if type(callbackData) == "number" then
        playerID = callbackData
    else
        playerID = callbackData.playerId
    end

	-- Clears the UI
	tm.playerUI.ClearUI(playerID)

	-- Adds the UILabels used to display the image
	for i=highscoreLines, 1, -1 do
		tm.playerUI.AddUILabel(playerID, i, "")
	end
	-- Adds the "Go Back" button
	tm.playerUI.AddUIButton(playerID, "Back", "Go Back", onLoadGameScreen)

	-- Sets UI state
	gameVariables[playerID].showHighscores = true
end

---------------------------------------------------------------------------------------------
-- Events (onPlayerJoined() and onPlayerLeft())

function onPlayerJoined(player)
	local playerID = player.playerId

	-- Initialize game variables for new player
	gameVariables[playerID] = {
		id = playerID,
		start = false,

		pipeState = {0, 0}, -- Height of the pipes
		pipePosition = -1, -- Position of the pipes

		altitude = 7, -- Altitude of the player
		collision = true, -- Collision state of the player

		score = 0, -- Score counter
		highscore = 0, -- Highscore counter

		image = {"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""}, -- Storage of the generated image

		showHighscores = false -- UI state
	}

	-- Loads the game screen (default screen)
	onLoadGameScreen(playerID)
	-- Binds the keybinds with the respective functions
	tm.input.RegisterFunctionToKeyDownCallback(playerID, "onStart", keybinds.start)
	tm.input.RegisterFunctionToKeyDownCallback(playerID, "onJump", keybinds.jump)

	-- Sets a flag to reload the highscore UI in the next update() for the players in that screen
	reload = true

	-- Keeps track of how many players are in the server
	playerAmount = playerAmount + 1
	highscoreLines = playerAmount + 2

	highscoresImage[highscoreLines-1] = ""

	tm.os.Log("Player joined. ID: " .. playerID)
end

function onPlayerLeft(player)
	-- Sets a flag to reload the highscore UI in the next update() for the players in that screen
	reload = true
	-- Keeps track of how many players are in the server
	playerAmount = playerAmount - 1
	highscoreLines = playerAmount + 2

	tm.os.Log("Player left. ID: " .. player.playerId)
end

tm.players.OnPlayerJoined.add(onPlayerJoined)
tm.players.OnPlayerLeft.add(onPlayerLeft)