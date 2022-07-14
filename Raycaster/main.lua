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
---@class Raycaster
raycaster = {
	map = {{1,1,1,1,1}, {1,0,0,0,1}, {1,0,0,0,1}, {1,0,0,0,1}, {1,1,1,1,1}},
	player = {
		position = {x = 2.5, y = 2.5},
		angle = math.rad(45),
		fov = math.rad(90),
		_hitboxSize = 0.1,
		moveStep = 0.03,
		rotateStep = math.rad(2),
	},
	_wallScallingFactor = 15,
	screen = screen:new({collision = false})
}

--- Function defining how to create a new instance from the prototype
---
---@param o table|nil
---@return Raycaster
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
	-- Sets the position of the screen and spawns it
	---@diagnostic disable-next-line: assign-type-mismatch #The game implements an override to the `+` operator for ModVector3 addition
	self.screen.position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5)
	self.screen:spawn()
end

--- Updates the screen
---
---@return nil
function raycaster:update()
	--tm.os.Log("-----------------------------------------------------------------------------------------------------------------------------------------------")

	-- Simplifies the angle of the player
	self.player.angle = self.player.angle % (math.pi * 2)

	-- Table with the distance and position returned by each casted ray
	local rays = {}

	-- Casts a ray for every column on the screen
	for i = 0, self.screen.sizeH - 1 do
		-- Calculates the offset of the ray from the player direction based on the amount of rays and the size of the FOV
		local offset = self.player.fov * (-1/2 + 1 / (2 * self.screen.sizeH) + i / self.screen.sizeH)
		table.insert(rays, self:_castRay(offset))
	end

	-- Draws the screen with the information obtained from the rays
	self:_drawScreen(rays)
end

--- Casts a ray with the given offset from the player direction and returns
--- the distance from the wall it hits and the orientation of that wall
---
---@param angleOffset number
---@return {[1]: number, [2]: integer}
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
				orientation = 2
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
				orientation = rayDown and 1 or 3
				break
			end
			-- If there isn't a wall, advances the position of the intersection with a horizontal grid line to the next position
			intersectH_X = intersectH_X + stepX
			intersectH_Y = intersectH_Y + tileStepY
		end
	end

	--tm.os.Log("---Distance=" .. distance .. ", orientation=" .. orientation)
	return {distance, orientation}
end

--- Calculates the distance between the player and the collision point while correcting for the fisheye effect
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

--- Draws the next frame and updates the screen with it
---
---@param rays {[integer]: {[1]: number, [2]: integer}}
---@return nil
function raycaster:_drawScreen(rays)
	--tm.os.Log("--------- Draw ----------------------------------------------------------------------------------")

	-- Rendered frame
	local nextFrame = {}

	for positionH = 0, self.screen.sizeH - 1 do
		nextFrame[positionH] = {}

		-- Height of the wall for that column based on its distance from the player
		local wallHeight = self._wallScallingFactor / rays[positionH + 1][1]
		--tm.os.Log("Column=" .. positionH .. ", Height=" .. wallHeight)
		--tm.os.Log("0<" .. (self.screen.sizeV - wallHeight) / 2 .. "<" .. (self.screen.sizeV - wallHeight) / 2 + wallHeight .. "<infty")

		-- For each pixel in the column, sets its color to that of the floor, sky or
		-- wall depending on its Y coordinate, with the wall being centered vertically
		for positionV = 0, self.screen.sizeV - 1 do
			if positionV < (self.screen.sizeV - wallHeight) / 2 then
				-- The Y coordinate corresponds to sky
				nextFrame[positionH][positionV] = 5
				--tm.os.Log("---Line=" .. positionV .. ", start=" .. (self.screen.sizeV - wallHeight) / 2 .. ", sky")
			elseif positionV < (self.screen.sizeV - wallHeight) / 2 + wallHeight then
				-- The Y coordinate corresponds to a wall, use the color given by the ray
				nextFrame[positionH][positionV] = rays[positionH + 1][2]
				--tm.os.Log("---Line=" .. positionV .. ", start=" .. (self.screen.sizeV - wallHeight) / 2 .. ", wall")
			else
				-- The Y coordinate corresponds to floor
				nextFrame[positionH][positionV] = 4
				--tm.os.Log("---Line=" .. positionV .. ", start=" .. (self.screen.sizeV - wallHeight) / 2 .. ", floor")
			end
		end
	end

	-- Pushes the rendered frame to the screen and updates it
	self.screen:setNextFrameDelta(nextFrame)
	self.screen:update()
end

--- Moves the player by the given absolute coordinates
---
---@param x number
---@param y number
---@return nil
function raycaster:movePlayerAbsolute(x, y)
	local nextPositionX = self.player.position.x + x
	local nextPositionY = self.player.position.y + y
	-- Checks that the next position is an empty tile
	--tm.os.Log("check collision")
	if self.map[math.floor(nextPositionX + (x>0 and 1 or -1) * 0.1) + 1][math.floor(nextPositionY + (y>0 and 1 or -1) * 0.1) + 1] == 0 then
		--tm.os.Log("no collision")
		self.player.position.x = nextPositionX
		self.player.position.y = nextPositionY
	end
end

--- Moves the player by the given coordinates relative to its facing direction
---
---@param x number
---@param y number
---@return nil
function raycaster:movePlayerRelative(x, y)
	local cosAngle = math.cos(self.player.angle)
	local sinAngle = math.sin(self.player.angle)
	local absoluteX = x * cosAngle - y * sinAngle
	local absoluteY = x * sinAngle + y * cosAngle
	self:movePlayerAbsolute(absoluteX, absoluteY)
end

--- Rotates the player by the given angle in radians
---
---@param angle number
---@return nil
function raycaster:rotatePlayer(angle)
	self.player.angle = self.player.angle + angle
end

--- Updates the player's position and direction based on the state of the input buttons
---
---@param input {moveLeft: boolean, moveRight: boolean, moveForwards: boolean, moveBackwards: boolean, rotateRight: boolean, rotateLeft: boolean}
---@return nil
function raycaster:updatePlayer(input)
	local x = 0
	local y = 0
	local angle = 0

	if input.moveLeft then y = y - self.player.moveStep end
	if input.moveRight then y = y + self.player.moveStep end
	if input.moveForwards then x = x + self.player.moveStep end
	if input.moveBackwards then x = x - self.player.moveStep end

	if input.rotateLeft then angle = angle - self.player.rotateStep end
	if input.rotateRight then angle = angle + self.player.rotateStep end

	self:movePlayerRelative(x, y)
	self:rotatePlayer(angle)
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function update()
	_raycaster:updatePlayer(controls)
	_raycaster:update()
	tm.playerUI.SetUIValue(0, 0, "Angle: " .. math.deg(_raycaster.player.angle))
	tm.playerUI.SetUIValue(0, 2, "X=" .. _raycaster.player.position.x)
	tm.playerUI.SetUIValue(0, 3, "Y=" .. _raycaster.player.position.y)
	tm.playerUI.SetUIValue(0, 4, "PositionGrid: X=" .. math.floor(_raycaster.player.position.x) .. ", Y=" .. math.floor(_raycaster.player.position.y))
end

---------------------------------------------------------------------------------------------
-- Controls
---------------------------------------------------------------------------------------------

controls = {
	moveLeft = false,
	moveRight = false,
	moveForwards = false,
	moveBackwards = false,
	rotateRight = false,
	rotateLeft = false
}

function moveLeftDown()
	controls.moveLeft = true
end
function moveLeftUp()
	controls.moveLeft = false
end
function moveRightDown()
	controls.moveRight = true
end
function moveRightUp()
	controls.moveRight = false
end
function moveForwardsDown()
	controls.moveForwards = true
end
function moveForwardsUp()
	controls.moveForwards = false
end
function moveBackwardsDown()
	controls.moveBackwards = true
end
function moveBackwardsUp()
	controls.moveBackwards = false
end

function rotateLeftDown()
	controls.rotateLeft = true
end
function rotateLeftUp()
	controls.rotateLeft = false
end
function rotateRightDown()
	controls.rotateRight = true
end
function rotateRightUp()
	controls.rotateRight = false
end

---------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------

-- Loads the object and the texture
tm.physics.AddTexture("cube.png", "cubePng")
tm.physics.AddMesh("cube.obj", "cubeObj")

-- Screen resolution
horizontalSize = 48 -- 80, 48
verticalSize = 36 -- 60, 36

-- Wall size
wallScallingFactor = 15 -- 75,25 for 80x60, 40,15 for 48x36

-- Keybinds
keybinds = { -- Contains all the keybinds used
	moveLeft = "J",
	moveRight = "L",
	moveForwards = "I",
	moveBackwards = "K",
	rotateLeft = "U",
	rotateRight = "O"
}

-- Update speed
tm.os.SetModTargetDeltaTime(1/15)

_raycaster = raycaster:new()
_raycaster.screen.sizeH = horizontalSize
_raycaster.screen.sizeV = verticalSize
_raycaster._wallScallingFactor = wallScallingFactor
_raycaster:spawn()


function onPlayerJoined()
	tm.input.RegisterFunctionToKeyDownCallback(0, "moveRightDown", keybinds.moveRight)
	tm.input.RegisterFunctionToKeyUpCallback(0, "moveRightUp", keybinds.moveRight)
	tm.input.RegisterFunctionToKeyDownCallback(0, "moveLeftDown", keybinds.moveLeft)
	tm.input.RegisterFunctionToKeyUpCallback(0, "moveLeftUp", keybinds.moveLeft)
	tm.input.RegisterFunctionToKeyDownCallback(0, "moveForwardsDown", keybinds.moveForwards)
	tm.input.RegisterFunctionToKeyUpCallback(0, "moveForwardsUp", keybinds.moveForwards)
	tm.input.RegisterFunctionToKeyDownCallback(0, "moveBackwardsDown", keybinds.moveBackwards)
	tm.input.RegisterFunctionToKeyUpCallback(0, "moveBackwardsUp", keybinds.moveBackwards)
	tm.input.RegisterFunctionToKeyDownCallback(0, "rotateRightDown", keybinds.rotateRight)
	tm.input.RegisterFunctionToKeyUpCallback(0, "rotateRightUp", keybinds.rotateRight)
	tm.input.RegisterFunctionToKeyDownCallback(0, "rotateLeftDown", keybinds.rotateLeft)
	tm.input.RegisterFunctionToKeyUpCallback(0, "rotateLeftUp", keybinds.rotateLeft)
	tm.playerUI.AddUILabel(0, 0, "Angle: ")
	tm.playerUI.AddUILabel(0, 1, "Position:")
	tm.playerUI.AddUILabel(0, 2, "X=")
	tm.playerUI.AddUILabel(0, 3, "Y=")
	tm.playerUI.AddUILabel(0, 4, "PositionGrid: ")
end

tm.players.OnPlayerJoined.add(onPlayerJoined)