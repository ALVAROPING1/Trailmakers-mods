-- By ALVAROPING1
--
-- To use it on your mod, you need to copy all the code enclosed by the '-' lines
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


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

	---@diagnostic disable-next-line: param-type-mismatch #The game implements an override to the `-` operator for ModVector3 negation
	local _position0 = self.position + tm.vector3.op_Multiply(-deltaV, self.sizeV)

	self._pixels = {}
	for positionH=0, self.sizeH-1 do
		self._pixels[positionH] = {}
		for positionV=0, self.sizeV-1 do
			self._pixels[positionH][positionV] = {}

			---@type ModVector3
			---@diagnostic disable-next-line: assign-type-mismatch #The game implements an override to the `+` operator for ModVector3 addition
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



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Depends on "Screen Utilities"
---
---@class player
---@field position {x: number, y: number}
---@field angle number
---@field fov number
---@field moveStep number
---@field rotateStep number
---@field hitboxSize number
---
---@class raycaster
---@field map {[integer]: {[integer]: 0 | 1}}
---@field player player
---@field colors {wall: {N: integer, S: integer, E: integer, W: integer}, floor: integer, sky: integer}
---@field screen screen
---@field wallScallingFactor number
---
--- Creates a raycaster with a screen attached which can render a 2D map in 3D and display it on the screen
---
--- To create a new instance, do `instanceName = raycaster:new()`
--- - After creating an instance, you can do `instanceName.Parameter = value` to change a parameter
--- - After creating an instance, you can do `instanceName:function()` to call a function
---
--- Public parameters:
--- - `map`: 2D array defining the map where each value is either 0 (empty) or 1 (wall)
--- - `player`: player object storing information about the player
---   - `position`: table defining the x and y positions of the player
---   - `angle`: float defining the facing direction of the player in radians
---   - `fov`: float defining the field of view of the player in radians
---   - `moveStep`: float defining the distance traveled on each frame when moving
---   - `rotateStep`: float defining the angle rotated in radians on each frame when rotating
---   - `hitboxSize`: float defining the radius of the hitbox of the player
--- - `colors`: table defining the color used for each surface. For possible values, see the documentation about colors of "Screen Utilities"
---   - `wall`: table defining the color used for walls in each direction. The orientation of a wall is defined as the direction
---      a ray hitting it perpendicularly would have, with east being the positive X axis and north the positive Y axis
---   - `floor`: integer defining the color used for the floor
---   - `sky`: integer defining the color used for the sky
--- - `wallScallingFactor`: float defining the scalling factor for the height of walls
--- - `screen`: screen object used to show rendered images
---
--- Public methods:
--- - `spawn()`: spawns the screen. Returns nil
--- - `despawn()`: despawns the screen and deletes the instance. Returns nil
--- - `update(input)`: Updates the state of the player and screen according to the given
---   inputs. `input` is a table containing a boolean for each control. Returns nil
---
--- Private methods (you shouldn't need to call these):
--- - `_updateScreen()`: updates the screen. Returns nil
--- - `_castRay(angleOffset)`: casts a ray with the given offset from the player direction and
---   returns the distance from the wall it hits and the orientation of that wall
--- - `_hitWall(positionX, positionY)`: calculates and returns the distance between the player and the point while correcting for the fisheye effect
--- - `_drawScreen(rays)`: draws the next frame and pushes it to the screen. `rays` is
---   an array storing the data returned by `self:_castRay()` for each ray . Returns nil
--- - `_updatePlayer(input)`: updates the player's position and direction based on the state of the input buttons and returns
---   a boolean indicating if its position/rotation was changed. `input` is a table containing a boolean for each control
--- - `_movePlayerAbsolute(x, y)`: moves the player by the given absolute coordinates. Returns nil
--- - `_movePlayerRelative(x, y)`: moves the player by the given coordinates
---   relative to its facing direction (x is forwards while y is right). Returns nil
--- - `_rotatePlayer(angle)`: rotates the player clockwise by the given angle in radians. Returns nil
raycaster = {
	--- Defines the map where each value is either 0 (empty) or 1 (wall)
	map = {{1,1,1,1,1}, {1,0,0,0,1}, {1,0,1,0,1}, {1,0,0,0,1}, {1,1,1,1,1}},

	--- Stores information about the player
	player = {
		--- Defines the x and y positions of the player
		position = {x = 1.5, y = 1.5},
		--- Defines the facing direction of the player in radians
		angle = math.rad(45),

		--- Defines the field of view of the player in radians
		fov = math.rad(90),

		--- Defines the distance traveled on each frame when moving
		moveStep = 0.03,
		--- Defines the angle rotated in radians on each frame when rotating
		rotateStep = math.rad(2),

		--- Defines the radius of the hitbox of the player
		hitboxSize = 0.1,
	},

	--- Defines the color used for each surface. For possible values, see the documentation about colors of "Screen Utilities"
	colors = {
		--- Defines the color used for walls in each direction. The orientation of a wall is defined as the direction
		--- a ray hitting it perpendicularly would have, with east being the positive X axis and north the positive Y axis
		wall = {N = 3, S = 1, E = 2, W = 2},
		--- Defines the color used for the floor
		floor = 4,
		--- Defines the color used for the sky
		sky = 5
	},

	--- Defines the scalling factor for the height of walls
	wallScallingFactor = 15,

	--- Screen object used to show rendered images. See the documentation of "Screen Utilities" for more information
	screen = screen:new()
}

--- Function defining how to create a new instance from the prototype
---
---@param o table|nil
---@return raycaster
function raycaster:new(o)
	o = o or {} -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

--- Spawns the screen
---
---@return nil
function raycaster:spawn()
	-- Spawns the screen
	self.screen:spawn()
	-- Draws the first frame
	self:_updateScreen()
end

--- Despawns the screen and deletes the instance
---
---@return nil
function raycaster:despawn()
	self.screen:despawn()
	-- Deletes the instance
	---@diagnostic disable-next-line: cast-local-type
	self = nil
end

--- Updates the state of the player according to the given inputs and screen
---
---@param input {moveLeft: boolean, moveRight: boolean, moveForwards: boolean, moveBackwards: boolean, rotateRight: boolean, rotateLeft: boolean}
---@return nil
function raycaster:update(input)
	-- Updates the player according to the buttons pressed
	local updateScreen = self:_updatePlayer(input)

	--tm.os.Log("-----------------------------------------------------------------------------------------------------------------------------------------------")

	-- Simplifies the angle of the player
	self.player.angle = self.player.angle % (math.pi * 2)

	-- Updates the screen only if the player was moved/rotated (otherwise the rendered frame won't change)
	if updateScreen then self:_updateScreen() end
end

--- Updates the screen
---
---@return nil
function raycaster:_updateScreen()
	-- Table with the distance and position returned by each casted ray
	local rays = {}

	-- Casts a ray for every column on the screen
	for i = 0, self.screen.sizeH - 1 do
		-- Calculates the offset of the ray from the player direction based on the amount of rays and the size of the FOV
		local offset = self.player.fov * (-1/2 + 1 / (2 * self.screen.sizeH) + i / self.screen.sizeH)
		-- Casts a ray and adds the result to the rays table
		table.insert(rays, self:_castRay(offset))
	end

	-- Draws the screen with the information obtained from the rays
	self:_drawScreen(rays)
end

--- Casts a ray with the given offset from the player direction and returns
--- the distance from the wall it hits and the orientation of that wall
---
---@param angleOffset number
---@return {distance: number, orientation: "N" | "S" | "E" | "W"}
function raycaster:_castRay(angleOffset)
	local rayAngle = (self.player.angle + angleOffset) % (math.pi * 2)
	--tm.os.Log("Tracing ray at angle=" .. math.deg(rayAngle))

	-- Distance to travel horizontally to go from the player and the next vertical grid line
	local deltaX = 1 - self.player.position.x % 1
	-- Distance to travel vertically to go from the player and the next horizontal grid line
	local deltaY = 1 - self.player.position.y % 1
	-- Y coordinate of the next intersection with a horizontal grid line
	local intersectH_Y = math.floor(self.player.position.y) + 1
	-- X coordinate of the next intersection with a vertical grid line
	local intersectV_X = math.floor(self.player.position.x) + 1

	-- Distance to travel horizontally to get to the next intersection with a vertical grid line
	local tileStepX = 1
	-- Distance to travel vertically to get to the next intersection with a horizontal grid line
	local tileStepY = 1

	-- Vertical direction of the ray
	local rayDown = rayAngle > math.rad(180)
	-- Horizontal direction of the ray
	local rayLeft = rayAngle > math.rad(90) and rayAngle < math.rad(270)

	-- If the ray is going down, update deltaY and tileStepY to go to the previous horizontal
	-- grid line, and intersectH_Y to be the Y coordinate of the previous horizontal grid line
	if rayDown then
		deltaY = deltaY - 1
		intersectH_Y = intersectH_Y - 1
		tileStepY = -1
	end
	-- If the ray is going left, update deltaX and tileStepX to go to the previous vertical
	-- grid line, and intersectH_Y to be the Y coordinate of the previous vertical grid line
	if rayLeft then
		deltaX = deltaX - 1
		intersectV_X = intersectV_X - 1
		tileStepX = -1
	end

	-- X coordinate of the next intersection with a horizontal grid line
	local intersectH_X = self.player.position.x + deltaY / math.tan(rayAngle)
	-- Y coordinate of the next intersection with a vertical grid line
	local intersectV_Y = self.player.position.y + deltaX * math.tan(rayAngle)

	-- Distance to travel horizontally to get to the next intersection with a horizontal grid line
	local stepX = tileStepY / math.tan(rayAngle)
	-- Distance to travel vertically to get to the next intersection with a horizontal grid line
	local stepY = tileStepX * math.tan(rayAngle)

	-- Values to return
	local distance
	local orientation

	-- Loop control variable
	local hitWall = false
	-- While the ray hasn't hit a wall, trace it
	while not hitWall do
		-- Repeats while the next intersection happens with a vertical grid line
		while (rayDown and intersectV_Y >= intersectH_Y) or (not rayDown and intersectV_Y <= intersectH_Y) do
			--tm.os.Log("Intersection vertical grid line at X=" .. intersectV_X .. ", Y=" .. intersectV_Y)

			-- Checks if there is a wall in the tile the ray has entered
			if self.map[rayLeft and intersectV_X or intersectV_X + 1][math.floor(intersectV_Y) + 1] == 1 then
				--tm.os.Log("Vertical wall detected at X=" .. intersectV_X .. ", Y=" .. intersectV_Y)

				-- If there is a wall, calculates its distance and orientation, and exits the loop
				hitWall = true
				distance = self:_hitWall(intersectV_X, intersectV_Y)
				orientation = rayLeft and "W" or "E"
				break
			end
			-- If there isn't a wall, advances the position of the intersection with a vertical grid line to the next position
			intersectV_X = intersectV_X + tileStepX
			intersectV_Y = intersectV_Y + stepY
		end
		-- Repeats while the next intersection happens with a horizontal grid line
		while (rayLeft and intersectH_X > intersectV_X) or (not rayLeft and intersectH_X < intersectV_X) do
			--tm.os.Log("Intersection horizontal grid line at X=" .. intersectH_X .. ", Y=" .. intersectH_Y)

			-- Checks if there is a wall in the tile the ray has entered
			if self.map[math.floor(intersectH_X) + 1][rayDown and intersectH_Y or intersectH_Y + 1] == 1 then
				--tm.os.Log("Horizontal wall detected at X=" .. intersectH_X .. ", Y=" .. intersectH_Y)

				-- If there is a wall, calculates its distance and orientation, and exits the loop
				hitWall = true
				distance = self:_hitWall(intersectH_X, intersectH_Y)
				orientation = rayDown and "S" or "N"
				break
			end
			-- If there isn't a wall, advances the position of the intersection with a horizontal grid line to the next position
			intersectH_X = intersectH_X + stepX
			intersectH_Y = intersectH_Y + tileStepY
		end
	end

	--tm.os.Log("---Distance=" .. distance .. ", orientation=" .. orientation)
	return {distance = distance, orientation = orientation}
end

--- Calculates the distance between the player and the point while correcting for the fisheye effect
---
---@param positionX number
---@param positionY number
---@return number
function raycaster:_hitWall(positionX, positionY)
	-- Measures the distance in the direction of the player to prevent the fisheye effect
	local rawDistance = (positionX - self.player.position.x) * math.cos(self.player.angle) + (positionY - self.player.position.y) * math.sin(self.player.angle)
	--- Rounds the number to prevent float precision errors
	---@diagnostic disable-next-line: return-type-mismatch #rawDistance will always be a number
	return tonumber(string.format("%.10f", rawDistance))
end

--- Draws the next frame and pushes it to the screen. `rays` is an array storing the data returned by `self:_castRay()` for each ray 
---
---@param rays {[integer]: {distance: number, orientation: "N" | "S" | "E" | "W"}}
---@return nil
function raycaster:_drawScreen(rays)
	--tm.os.Log("--------- Draw ----------------------------------------------------------------------------------")

	-- Rendered frame
	local nextFrame = {}

	for positionH = 0, self.screen.sizeH - 1 do
		nextFrame[positionH] = {}

		-- Height of the wall for that column based on its distance from the player
		local wallHeight = self.wallScallingFactor / rays[positionH + 1].distance
		--tm.os.Log("Column=" .. positionH .. ", Height=" .. wallHeight)
		--tm.os.Log("0<" .. (self.screen.sizeV - wallHeight) / 2 .. "<" .. (self.screen.sizeV - wallHeight) / 2 + wallHeight .. "<infty")

		-- For each pixel in the column, sets its color to that of the floor, sky or
		-- wall depending on its Y coordinate, with the wall being centered vertically
		for positionV = 0, self.screen.sizeV - 1 do
			if positionV < (self.screen.sizeV - wallHeight) / 2 then
				-- The Y coordinate corresponds to sky
				nextFrame[positionH][positionV] = self.colors.sky
				--tm.os.Log("---Line=" .. positionV .. ", start=" .. (self.screen.sizeV - wallHeight) / 2 .. ", sky")
			elseif positionV < (self.screen.sizeV - wallHeight) / 2 + wallHeight then
				-- The Y coordinate corresponds to a wall, use the color determined by the orientation of the wall given by the ray
				nextFrame[positionH][positionV] = self.colors.wall[rays[positionH + 1].orientation]
				--tm.os.Log("---Line=" .. positionV .. ", start=" .. (self.screen.sizeV - wallHeight) / 2 .. ", wall")
			else
				-- The Y coordinate corresponds to floor
				nextFrame[positionH][positionV] = self.colors.floor
				--tm.os.Log("---Line=" .. positionV .. ", start=" .. (self.screen.sizeV - wallHeight) / 2 .. ", floor")
			end
		end
	end

	-- Pushes the rendered frame to the screen and updates it
	self.screen:setNextFrameDelta(nextFrame)
	self.screen:update()
end

--- Updates the player's position and direction based on the state of the input
--- buttons and returns a boolean indicating if its position/rotation was changed.
--- `input` is a table containing a boolean for each control
---
---@param input {moveLeft: boolean, moveRight: boolean, moveForwards: boolean, moveBackwards: boolean, rotateRight: boolean, rotateLeft: boolean}
---@return boolean
function raycaster:_updatePlayer(input)
	-- Total movement/rotation values
	local x = 0
	local y = 0
	local angle = 0

	-- Adds movement/rotation to the totals based on the inputs
	if input.moveLeft then y = y - self.player.moveStep end
	if input.moveRight then y = y + self.player.moveStep end
	if input.moveForwards then x = x + self.player.moveStep end
	if input.moveBackwards then x = x - self.player.moveStep end

	if input.rotateLeft then angle = angle - self.player.rotateStep end
	if input.rotateRight then angle = angle + self.player.rotateStep end

	-- Tries to move the player if the total movement isn't 0
	if x ~= 0 or y ~= 0 then self:_movePlayerRelative(x, y) end
	-- Rotates the player
	self:_rotatePlayer(angle)

	-- Returns if the player was moved/rotated
	return x ~= 0 or y ~= 0 or angle ~= 0
end

--- Moves the player by the given absolute coordinates
---
---@param x number
---@param y number
---@return nil
function raycaster:_movePlayerAbsolute(x, y)
	--tm.os.Log("-----------------------------------------")
	local nextPositionX = self.player.position.x + x
	local nextPositionY = self.player.position.y + y
	---@diagnostic disable-next-line: deprecated #The lua version the game uses seems to use an older version in which `math.atan(y, x)` gives the incorrect result
	local direction = math.atan2(y, x)
	--tm.os.Log("X=" .. x .. ", Y=" .. y)
	--tm.os.Log("nextX=" .. nextPositionX .. ", nextY=" .. nextPositionY)
	--tm.os.Log("angle=" .. math.deg(direction))
	-- Calculates the tile position the player would be on after being moved with an extra distance in the direction of travel for the hitbox
	local tileX = math.floor(nextPositionX + self.player.hitboxSize * math.cos(direction)) + 1
	local tileY = math.floor(nextPositionY + self.player.hitboxSize * math.sin(direction)) + 1
	--tm.os.Log("tileX=" .. tileX .. ", tileY=" .. tileY)
	-- Checks that the calculated tile is empty
	if self.map[tileX][tileY] == 0 then
		-- If it is, moves the player
		--tm.os.Log("Succesful movement")
		self.player.position.x = nextPositionX
		self.player.position.y = nextPositionY
	elseif x ~= 0 and y ~= 0 then
		--tm.os.Log("Unsuccessful movement")
		--tm.os.Log("|x| >= |y| == " .. tostring(math.abs(x) >= math.abs(y)))
		-- If it isn't, tries to move the player along the individual axes, trying first in the one in which the player would move the most
		if math.abs(x) >= math.abs(y) then
			self:_movePlayerAbsolute(x, 0)
			self:_movePlayerAbsolute(0, y)
		else
			self:_movePlayerAbsolute(0, y)
			self:_movePlayerAbsolute(x, 0)
		end
	end
end

--- Moves the player by the given coordinates relative to its facing direction (x is forwards while y is right)
---
---@param x number
---@param y number
---@return nil
function raycaster:_movePlayerRelative(x, y)
	local cosAngle = math.cos(self.player.angle)
	local sinAngle = math.sin(self.player.angle)
	-- Applies a change of basis to the input vector to transform it from a base relative to the player to a base relative to the map
	local absoluteX = x * cosAngle - y * sinAngle
	local absoluteY = x * sinAngle + y * cosAngle
	--tm.os.Log("===============================================================================================================")
	self:_movePlayerAbsolute(absoluteX, absoluteY)
end

--- Rotates the player clockwise by the given angle in radians
---
---@param angle number
---@return nil
function raycaster:_rotatePlayer(angle)
	self.player.angle = self.player.angle + angle
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- Controls
---------------------------------------------------------------------------------------------

---@class controls
---@field state {[integer]: {[string]: boolean}}
---
--- Stores the state of buttons
---
--- Use `controls.Parameter` to access a parameter
---
--- Use `controls:function()` to call a function
---
--- Parameters:
--- - `state`: table containing the state of the buttons for each player. The
---   first index is the playerId while the second index is the control name
---
--- Methods:
--- - `addControl`: adds a control to track. Returns nil
--- - `bindControlToKeybind`: binds a tracked control to a keybind for the specified player. Returns nil
controls = {
	--- Contains the state of the buttons for each player. The first
	--- index is the playerId while the second index is the control name
	state = {}
}

--- Adds a control to track
---
---@param control string Name of the control
---@return nil
function controls:addControl(control)
	-- Creates global functions to update the state of the control
	_G[control .. "Down"] = function (playerId)
		self.state[playerId][control] = true
	end
	_G[control .. "Up"] = function (playerId)
		self.state[playerId][control] = false
	end
end


--- Binds a tracked control to a keybind for the specified player
---
---@param control string Name of the control
---@param keybind string Keybind to use
---@param playerId integer ID of the player to bind the function to 
---@return nil
function controls:bindControlToKeybind(control, keybind, playerId)
	-- Binds the global functions to update the state of a control to a keybind for the specified player
	tm.input.RegisterFunctionToKeyDownCallback(playerId, control .. "Down", keybind)
	tm.input.RegisterFunctionToKeyUpCallback(playerId, control .. "Up", keybind)
	-- If no controls have been bind yet to that player, creates a table for their controls
	if self.state[playerId] == nil then self.state[playerId] = {} end
	-- Sets the default state of the control
	self.state[playerId][control] = false
end


---------------------------------------------------------------------------------------------
-- Debug controls
---------------------------------------------------------------------------------------------

--- Increases the FOV of the camera capped at 180 degrees
---
---@return nil
function increaseFov()
	local value = _raycaster.player.fov + math.rad(1)
	_raycaster.player.fov = value <= math.rad(180) and value or math.rad(180)
	_raycaster:_updateScreen()
end
--- Decreases the FOV of the camera capped at 30 degrees
---
---@return nil
function decreaseFov()
	local value = _raycaster.player.fov - math.rad(1)
	_raycaster.player.fov = value >= math.rad(30) and value or math.rad(30)
	_raycaster:_updateScreen()
end

--- Sets how much to move the player forwards/sideways when a movement key is pressed
---
---@return nil
function onSetMoveStep(callbackData)
	local value = tonumber(callbackData.value)
	if value ~= nil then
		_raycaster.player.moveStep = value
	end
end
--- Sets how much to rotate the player when a rotation key is pressed
---
---@return nil
function onSetRotateStep(callbackData)
	local value = tonumber(callbackData.value)
	if value ~= nil then
		_raycaster.player.rotateStep = math.rad(value)
	end
end
--- Sets the size of the player's hitbox
---
---@return nil
function onSetHitboxSize(callbackData)
	local value = tonumber(callbackData.value)
	if value ~= nil and value >= 0 then
		_raycaster.player.hitboxSize = value
	end
end
--- Sets how tall the walls are
---
---@return nil
function onSetWallSize(callbackData)
	local value = tonumber(callbackData.value)
	if value ~= nil and value >= 0 then
		_raycaster.wallScallingFactor = value
		_raycaster:_updateScreen()
	end
end


---------------------------------------------------------------------------------------------
-- UI
---------------------------------------------------------------------------------------------

-- Adds an UI to the host with debug information and controls
function createDebugUI(playerId)
	tm.playerUI.ClearUI(playerId)
	tm.playerUI.AddUIButton(0, "despawn", "Despawn Screen", despawnScreen)
	tm.playerUI.AddUILabel(playerId, 0, "Angle: ")
	tm.playerUI.AddUILabel(playerId, 1, "Position:")
	tm.playerUI.AddUILabel(playerId, 2, "X=")
	tm.playerUI.AddUILabel(playerId, 3, "Y=")
	tm.playerUI.AddUILabel(playerId, 4, "PositionGrid: ")
	tm.playerUI.AddUILabel(playerId, 5, "FOV: ")
	tm.playerUI.AddUILabel(playerId, 6, "Move Step:")
	tm.playerUI.AddUIText(playerId, 7, "0.03", onSetMoveStep)
	tm.playerUI.AddUILabel(playerId, 8, "Rotate Step:")
	tm.playerUI.AddUIText(playerId, 9, "2", onSetRotateStep)
	tm.playerUI.AddUILabel(playerId, 10, "Hitbox Radius:")
	tm.playerUI.AddUIText(playerId, 11, "0.1", onSetHitboxSize)
	tm.playerUI.AddUILabel(playerId, 12, "Wall Size:")
	tm.playerUI.AddUIText(playerId, 13, "15", onSetWallSize)
end

function updateDebugUI(playerId)
	tm.playerUI.SetUIValue(playerId, 0, "Angle: " .. math.deg(_raycaster.player.angle))
	tm.playerUI.SetUIValue(playerId, 2, "X=" .. _raycaster.player.position.x)
	tm.playerUI.SetUIValue(playerId, 3, "Y=" .. _raycaster.player.position.y)
	tm.playerUI.SetUIValue(playerId, 4, "PositionGrid: X=" .. math.floor(_raycaster.player.position.x) .. ", Y=" .. math.floor(_raycaster.player.position.y))
	tm.playerUI.SetUIValue(playerId, 5, "FOV: " .. math.deg(_raycaster.player.fov))
end

function createSpawnUI(playerId)
	tm.playerUI.ClearUI(playerId)
	tm.playerUI.AddUIButton(playerId, "spawn", "Spawn Screen", spawnScreen)
end

---------------------------------------------------------------------------------------------
-- Update
---------------------------------------------------------------------------------------------

function update()
	if spawned then
		_raycaster:update(controls.state[0])
		updateDebugUI(0)
	end
end

---------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------

-- Update speed
tm.os.SetModTargetDeltaTime(1/15)

-- Loads the object and the texture
tm.physics.AddTexture("cube.png", "cubePng")
tm.physics.AddMesh("cube.obj", "cubeObj")

-- Screen resolution
horizontalSize = 48 -- 80, 48
verticalSize = 36 -- 60, 36

-- Wall size
wallScallingFactor = 15 -- 75,25 for 80x60, 40,15 for 48x36

-- Keeps track of if the mod has already been loaded or not
loaded = false
-- Keeps track of if the raycaster has been spawned
spawned = false


keybinds = { -- Contains all the keybinds used
	gameControls = {
		moveLeft = "J",
		moveRight = "L",
		moveForwards = "I",
		moveBackwards = "K",
		rotateLeft = "U",
		rotateRight = "O"
	},
	increaseFov = "Y",
	decreaseFov = "H"
}

function spawnScreen()
	-- Creates a new raycaster instance
	_raycaster = raycaster:new()
	-- Modifies the map of the raycaster instance
	_raycaster.map = {
		{1,1,1,1,1,1,1,1,1,1,1},
		{1,0,1,0,0,0,0,0,0,0,1},
		{1,0,1,0,0,0,1,1,1,0,1},
		{1,0,1,0,0,0,0,0,1,0,1},
		{1,0,1,0,0,0,0,0,1,0,1},
		{1,0,0,0,0,1,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,1,0,1},
		{1,0,0,0,0,0,0,0,0,0,1},
		{1,1,1,1,1,1,1,1,1,1,1}
	}

	-- Sets the player's facing angle
	_raycaster.player.angle = math.rad(180)

	-- Sets the resolution of the screen used by the raycaster
	_raycaster.screen.sizeH = horizontalSize
	_raycaster.screen.sizeV = verticalSize
	-- Disables the collision of the screen
	_raycaster.screen.collision = false
	-- Sets the position of the screen
	---@diagnostic disable-next-line: assign-type-mismatch #The game implements an override to the `+` operator for ModVector3 addition
	_raycaster.screen.position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5)

	-- Sets the size of the walls
	_raycaster.wallScallingFactor = wallScallingFactor
	-- Spawns the screen
	_raycaster:spawn()

	-- Adds debug controls and UI
	tm.input.RegisterFunctionToKeyDownCallback(0, "increaseFov", keybinds.increaseFov)
	tm.input.RegisterFunctionToKeyDownCallback(0, "decreaseFov", keybinds.decreaseFov)
	createDebugUI(0)
	spawned = true
end

function despawnScreen()
	createSpawnUI(0)
	_raycaster:despawn()
	spawned = false
end

function onPlayerJoined()
	if not loaded then
		createSpawnUI(0)

		-- Sets the game controls to be tracked and binds them to keybinds
		for key, value in pairs(keybinds.gameControls) do
			controls:addControl(key)
			controls:bindControlToKeybind(key, value, 0)
		end

		-- Marks the mod as loaded
		loaded = true
	end
end

tm.players.OnPlayerJoined.add(onPlayerJoined)