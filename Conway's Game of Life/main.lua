-- By ALVAROPING1

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Screen prototype. Documentation and examples can be found on the standalone 'Screen Utilities' mod here: https://steamcommunity.com/sharedfiles/filedetails/?id=2511989739
screen = {
	---@diagnostic disable-next-line: assign-type-mismatch #The game implements an override to the `+` operator for ModVector3 addition
	position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5),
	orientation = 0,

	pixelSize = 2^-4,
	collision = false,

	sizeH = 15,
	sizeV = 15,

	cubeMesh = "cubeObj",
	cubeTexture = "cubePng",

	nextFrameDelta = {},

	_pixels = {},
	_color2Rotation = {}
}

function screen:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function screen:spawn()
	local deltaHOrientation = tm.vector3.Create(math.cos(math.rad(self.orientation)), 0, math.sin(math.rad(self.orientation)))

	self._color2Rotation = {
		tm.vector3.Create(0, 0-self.orientation, 0),
		tm.vector3.Create(0, 90-self.orientation, 0),
		tm.vector3.Create(0, -90-self.orientation, 0),
		tm.vector3.Create(0, 180-self.orientation, 0),
		tm.vector3.Create(-90, 0-self.orientation, 180),
		tm.vector3.Create(-90, 0-self.orientation, 0),
	}

	local deltaH = tm.vector3.op_Multiply(deltaHOrientation, self.pixelSize*2)
	local deltaV = tm.vector3.Create(0, -self.pixelSize*2, 0)

	local _position0 = self.position + tm.vector3.op_Multiply(-deltaV, self.sizeV)

	self._pixels = {}
	for positionH=0, self.sizeH-1 do
		self._pixels[positionH] = {}
		for positionV=0, self.sizeV-1 do
			self._pixels[positionH][positionV] = {}

			local position = _position0 + tm.vector3.op_Multiply(deltaH, positionH) + tm.vector3.op_Multiply(deltaV, positionV)

			self._pixels[positionH][positionV].object = tm.physics.SpawnCustomObjectRigidbody(position, self.cubeMesh, self.cubeTexture, true, 1)
			self._pixels[positionH][positionV].object.GetTransform().SetScale(self.pixelSize)
			self._pixels[positionH][positionV].object.GetTransform().SetRotation(self._color2Rotation[1])
			if self.collision == false then
				self._pixels[positionH][positionV].object.SetIsTrigger(true)
			end

			self._pixels[positionH][positionV].color = 0

		end
	end
end

function screen:despawn()
	for positionH=0, self.sizeH-1 do
		for positionV=0, self.sizeV-1 do
			self._pixels[positionH][positionV].object.Despawn()
		end
	end
	---@diagnostic disable-next-line: cast-local-type
	self = nil
end

function screen:setNextFrameDelta(_nextFrame)
	self.nextFrameDelta = {}

	for positionH=0, self.sizeH-1 do
		for positionV=0, self.sizeV-1 do
			if self._pixels[positionH][positionV].color ~= _nextFrame[positionH][positionV] then
				local pixelState = {position = {positionH, positionV}, color = _nextFrame[positionH][positionV]}
				table.insert(self.nextFrameDelta, pixelState)
			end
		end
	end
end

function screen:setPartialNextFrameDelta(partialNextFrameDelta)
	self.nextFrameDelta = {}

	for key, pixelState in pairs(partialNextFrameDelta) do
		local positionH = pixelState.position[1]
		local positionV = pixelState.position[2]
		local color = pixelState.color

		if self._pixels[positionH][positionV].color ~= color then
			table.insert(self.nextFrameDelta, pixelState)
		end
	end
end

function screen:update()
	for key, value in pairs(self.nextFrameDelta) do
		local positionH = value.position[1]
		local positionV = value.position[2]
		local color = value.color

		self._pixels[positionH][positionV].object.GetTransform().SetRotation(self._color2Rotation[color+1])
		self._pixels[positionH][positionV].color = color
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Sets the horizontal resolution of the screen
function setHorizontalSize(callbackData)
	local value = tonumber(callbackData.value)
	if value ~= nil then
		-- Makes sure 'horizontalSize' is an int greater than or equal to 1
		if value < 1 then
			value = 1
		end

		horizontalSize = math.floor(value)
	end
end

-- Sets the vertical resolution of the screen
function setVerticalSize(callbackData)
	local value = tonumber(callbackData.value)
	if value ~= nil then
		-- Makes sure 'verticalSize' is an int greater than or equal to 1
		if value < 1 then
			value = 1
		end

		verticalSize = math.floor(value)
	end
end

-- Sets the update speed
function setSpeed(callbackData)
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


-- Spawns the screen and initializes the game state and the UI
function spawnScreen()
	-- Creates a new screen, sets its resolution and position and spawns it
	_screen = screen:new()
	_screen.sizeH = horizontalSize
	_screen.sizeV = verticalSize
	_screen.position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5)
	_screen:spawn()

	-- Creates a 2D table to store the state of the game
	state = {}
	for positionH=0, horizontalSize - 1 do
		state[positionH] = {}
		for positionV=0, verticalSize - 1 do
			state[positionH][positionV] = 0
		end
	end

	screenSpawned = true

	pause()
end

-- Despawns the screen and resets everything
function despawnScreen()
	active = false
	screenSpawned = false

	-- Despawns the screen and resets the game state
	_screen:despawn()
	state = nil

	-- Resets the UI
	tm.playerUI.ClearUI(0)

	tm.playerUI.AddUIButton(0, "spawn", "Spawn Screen", spawnScreen)
	tm.playerUI.AddUILabel(0, "sizeH", "Horizontal resolution:")
	tm.playerUI.AddUIText(0, "sizeHText", tostring(horizontalSize), setHorizontalSize)
	tm.playerUI.AddUILabel(0, "sizeV", "Vertical resolution:")
	tm.playerUI.AddUIText(0, "sizeVText", tostring(verticalSize), setVerticalSize)

	-- Resets the cursor
	cursorPosition = {0, 0}
	cursorColor = 2
end


-- Starts the game
function start()
	-- Starts the game
	active = true

	-- Removes the cursor from the screen
	oldPixel = {
		position = cursorPosition,
		color = state[cursorPosition[1]][cursorPosition[2]]
	}
	_screen.nextFrameDelta = {oldPixel}
	_screen:update()

	-- Clears the UI and creates a new one with the button to pause the game
	tm.playerUI.ClearUI(0)
	tm.playerUI.AddUILabel(0, "state", "State: ON")
	tm.playerUI.AddUILabel(0, "state", "Game Speed: " .. tostring(speed))
	tm.playerUI.AddUIButton(0, "pause", "Pause", pause)
	tm.playerUI.AddUIButton(0, "spawn", "Despawn Screen", despawnScreen)
end

-- Pauses the game
function pause()
	-- Stops the game if it was running
	active = false

	-- Clears the UI and creates a new one with the button to start the game and the controls for the cursor
	tm.playerUI.ClearUI(0)

	tm.playerUI.AddUILabel(0, "state", "State: OFF")
	tm.playerUI.AddUIButton(0, "start", "Start", start)
	tm.playerUI.AddUIButton(0, "spawn", "Despawn Screen", despawnScreen)
	tm.playerUI.AddUILabel(0, "speed", "Game Speed (fps)")
	tm.playerUI.AddUIText(0, "setSpeed", tostring(speed), setSpeed)
	tm.playerUI.AddUILabel(0, "move", "Move cursor: " .. keybinds.moveUp .. keybinds.moveLeft .. keybinds.moveDown .. keybinds.moveRight)
	tm.playerUI.AddUILabel(0, "toggeState", "Toggle cell state: " .. keybinds.toggleCell)

	-- Renders the cursor on the screen
	setCursorColor(cursorPosition)
	newPixel = {position = cursorPosition, color = cursorColor}
	_screen.nextFrameDelta = {newPixel}
	_screen:update()
end


-- Moves the cursor up
function onMoveUp()
	moveCursor(2, -1)
end

-- Moves the cursor down
function onMoveDown()
	moveCursor(2, 1)
end

-- Moves the cursor left
function onMoveLeft()
	moveCursor(1, -1)
end

-- Moves the cursor right
function onMoveRight()
	moveCursor(1, 1)
end

-- Moves the cursor in the given axis and direction. Axis: 1 for horizontal, 2 for vertical. Direction: positive for down and right, negative for up and left
function moveCursor(axis, direction)
	if active == false and screenSpawned == true then
		-- Removes the cursor from the previous position
		oldPixel = {
			position = {cursorPosition[1], cursorPosition[2]}, -- Position values must be passed individually to pass them by value, lua always passes tables by reference
			color = state[cursorPosition[1]][cursorPosition[2]]
		}

		local length
		if axis == 1 then
			length = horizontalSize
		else
			length = verticalSize
		end

		-- Updates the cursor position and color
		cursorPosition[axis] = (cursorPosition[axis] + direction) % length
		setCursorColor(cursorPosition)

		-- Updates the screen by adding the cursor to the new position and removing it from the previous position
		newPixel = {position = cursorPosition, color = cursorColor}
		_screen.nextFrameDelta = {newPixel, oldPixel}
		_screen:update()
	end
end

-- Toggles the cell state between alive (1) and dead (0)
function onToggleCell()
	if active == false and screenSpawned == true then
		-- Toggles the cell state
		local pixelState = state[cursorPosition[1]][cursorPosition[2]]
		state[cursorPosition[1]][cursorPosition[2]] = notInt[pixelState]

		-- Updates the cursor color and renders the cursor again
		setCursorColor(cursorPosition)
		newPixel = {position = cursorPosition, color = cursorColor}
		_screen.nextFrameDelta = {newPixel}
		_screen:update()
	end
end

-- Sets the cursor color depending on if it's on an alive or dead cell
function setCursorColor(position)
	if state[position[1]][position[2]] == 0 then -- If the cell is dead the cursor color is 2, if it's alive the cursor color is 3
		cursorColor = 2
	else
		cursorColor = 3
	end
end


-- Updates the game state and the screen
function update()
	if active == true then
		-- Copies the state table into a new table so all changes take place at the same time
		newState = copy2DTable(state)

		-- For each cell on the screen
		for H=0, horizontalSize - 1 do
			for V=0, verticalSize - 1 do
				-- Counts the number of neighbors, cells on opposite sides of the screen are considered adjacent
				neighborsNumber = state[(H - 1) % horizontalSize][(V - 1) % verticalSize] +
								  state[(H)     % horizontalSize][(V - 1) % verticalSize] +
								  state[(H + 1) % horizontalSize][(V - 1) % verticalSize] +
								  state[(H - 1) % horizontalSize][(V)     % verticalSize] +
								  state[(H + 1) % horizontalSize][(V)     % verticalSize] +
								  state[(H - 1) % horizontalSize][(V + 1) % verticalSize] +
								  state[(H)     % horizontalSize][(V + 1) % verticalSize] +
								  state[(H + 1) % horizontalSize][(V + 1) % verticalSize]

				-- Checks if the state of the cell needs to change
				if state[H][V] == 0 and neighborsNumber == 3 then -- If the cell is dead and has 3 neighbors it becomes alive
					newState[H][V] = 1
				elseif state[H][V] == 1 and (neighborsNumber < 2 or neighborsNumber > 3) then -- If the cell is alive and has less than 2 or more than 3 neighbors it becomes dead
					newState[H][V] = 0
				end
			end
		end

		-- Copies the table back to the original state table
		state = copy2DTable(newState)

		-- Updates the screen with the new game state
		_screen:setNextFrameDelta(state)
		_screen:update()
	end
end

-- Copies a 2D table by value rather than by reference
function copy2DTable(_table)
	local out = {}

	for key0, value0 in pairs(_table) do
		out[key0] = {}
		for key1, value1 in pairs(value0) do
			out[key0][key1] = value1
		end
	end

	return out
end


-- Initialization

-- Loads the object and the texture
tm.physics.AddTexture("cube.png", "cubePng")
tm.physics.AddMesh("cube.obj", "cubeObj")

-- Keybinds used
keybinds = {
	moveUp = "I",
	moveDown = "K",
	moveLeft = "J",
	moveRight = "L",

	toggleCell = "-"
}

-- Cursor state
cursorPosition = {0, 0}
cursorColor = 2

-- Screen resolution
horizontalSize = 50
verticalSize = 50

active = false
screenSpawned = false

speed = 10 -- Speed of the game

notInt={[0]=1, [1]=0} -- NOT operator for integers

-- Adds the initial UI
tm.playerUI.AddUIButton(0, "spawn", "Spawn Screen", spawnScreen)
tm.playerUI.AddUILabel(0, "sizeH", "Horizontal resolution:")
tm.playerUI.AddUIText(0, "sizeHText", tostring(horizontalSize), setHorizontalSize)
tm.playerUI.AddUILabel(0, "sizeV", "Vertical resolution:")
tm.playerUI.AddUIText(0, "sizeVText", tostring(verticalSize), setVerticalSize)

-- Binds the keybinds to their respective functions
tm.input.RegisterFunctionToKeyDownCallback(0, "onMoveUp", keybinds.moveUp)
tm.input.RegisterFunctionToKeyDownCallback(0, "onMoveDown", keybinds.moveDown)
tm.input.RegisterFunctionToKeyDownCallback(0, "onMoveLeft", keybinds.moveLeft)
tm.input.RegisterFunctionToKeyDownCallback(0, "onMoveRight", keybinds.moveRight)
tm.input.RegisterFunctionToKeyDownCallback(0, "onToggleCell", keybinds.toggleCell)

tm.os.SetModTargetDeltaTime(6/60)
tm.os.Log("Mod Loaded")