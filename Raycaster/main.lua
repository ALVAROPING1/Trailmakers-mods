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
		fov = math.rad(90)
	},
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
	---@diagnostic disable-next-line: assign-type-mismatch #The game implements an override to the `+` operator for ModVector3 addition
	self.screen.position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5)
	self.screen:spawn()
end

--- Updates the screen
---
---@return nil
function raycaster:update()
	local rays = {}

	for i = 0, self.screen.sizeH - 1 do
		table.insert(rays, self:_castRay(self.player.fov * (-1/2 + 1 / (2 * self.screen.sizeH) + i / self.screen.sizeH)))
	end

	self:_drawScreen(rays)
end

---@param angleOffset number
---@return {[1]: number, [2]: integer}
function raycaster:_castRay(angleOffset)
	local rayAngle = (self.player.angle + angleOffset) % (math.pi * 2)
	--tm.os.Log("Tracing ray at angle=" .. math.deg(rayAngle))

	local deltaY = 1 - self.player.position.y % 1
	local deltaX = 1 - self.player.position.x % 1
	local intersectH_Y = math.floor(self.player.position.y) + 1
	local intersectV_X = math.floor(self.player.position.x) + 1
	local tileStepX = 1
	local tileStepY = 1


	local rayDown = rayAngle > math.rad(180)
	local rayLeft = rayAngle > math.rad(90) and rayAngle < math.rad(270)

	if rayDown then
		deltaY = deltaY - 1
		intersectH_Y = intersectH_Y - 1
		tileStepY = -1
	end
	if rayLeft then
		deltaX = deltaX - 1
		intersectV_X = intersectV_X - 1
		tileStepX = -1
	end

	local intersectH_X = self.player.position.x + deltaY / math.tan(rayAngle)
	local intersectV_Y = self.player.position.y + deltaX * math.tan(rayAngle)
	local stepX = tileStepY / math.tan(rayAngle)
	local stepY = tileStepX * math.tan(rayAngle)
	local hitWall = false

	local distance
	local orientation

	while not hitWall do
		while (rayDown and intersectV_Y >= intersectH_Y) or (not rayDown and intersectV_Y <= intersectH_Y) do
			--tm.os.Log("Intersection vertical grid line at X=" .. intersectV_X .. ", Y=" .. intersectV_Y)
			if self.map[rayLeft and intersectV_X or intersectV_X + 1][math.floor(intersectV_Y) + 1] == 1 then
				--tm.os.Log("Wall detected")
				hitWall = true
				distance = self:_hitWall(intersectV_X, intersectV_Y)
				orientation = 2
				break
			else
				intersectV_X = intersectV_X + tileStepX
				intersectV_Y = intersectV_Y + stepY
			end
		end
		while (rayLeft and intersectH_X > intersectV_X) or (not rayLeft and intersectH_X < intersectV_X) do
			--tm.os.Log("Intersection horizontal grid line at X=" .. intersectH_X .. ", Y=" .. intersectH_Y)
			if self.map[math.floor(intersectH_X) + 1][rayDown and intersectH_Y or intersectH_Y + 1] == 1 then
				--tm.os.Log("Wall detected")
				hitWall = true
				distance = self:_hitWall(intersectH_X, intersectH_Y)
				orientation = rayLeft and 3 or 3
				break
			else
				intersectH_X = intersectH_X + stepX
				intersectH_Y = intersectH_Y + tileStepY
			end
		end
	end

	return {distance, orientation}
end

---@param positionX number
---@param positionY number
---@return number
function raycaster:_hitWall(positionX, positionY)
	return (positionX - self.player.position.x) * math.cos(self.player.angle) + (positionY - self.player.position.y) * math.sin(self.player.angle)
end

---@param rays {[integer]: {[1]: number, [2]: integer}}
---@return nil
function raycaster:_drawScreen(rays)
	local nextFrame = {}
	local wallScallingFactor = 15 -- 75 for 80x60, 40 for 48x36
	for positionH = 0, self.screen.sizeH - 1 do
		nextFrame[positionH] = {}
		local wallHeight = wallScallingFactor / rays[positionH + 1][1]
		for positionV = 0, self.screen.sizeV - 1 do
			if positionV < (self.screen.sizeV - wallHeight) / 2 then
				nextFrame[positionH][positionV] = 5
			elseif positionV < (self.screen.sizeV - wallHeight) / 2 + wallHeight then
				nextFrame[positionH][positionV] = rays[positionH + 1][2]
			else
				nextFrame[positionH][positionV] = 4
			end
		end
	end
	self.screen:setNextFrameDelta(nextFrame)
	self.screen:update()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Initialization

-- Loads the object and the texture
tm.physics.AddTexture("cube.png", "cubePng")
tm.physics.AddMesh("cube.obj", "cubeObj")

-- Screen resolution
horizontalSize = 48 -- 80, 48
verticalSize = 36 -- 60, 36

_raycaster = raycaster:new()
_raycaster.screen.sizeH = horizontalSize
_raycaster.screen.sizeV = verticalSize
_raycaster:spawn()
_raycaster:update()

value = 5

function increaseAngle()
	_raycaster.player.angle = _raycaster.player.angle + math.rad(value)
	_raycaster:update()
end

function changeValue(callbackData)
	value = tonumber(callbackData.value)
end

tm.playerUI.AddUIText(0, 1, "5", changeValue)
tm.input.RegisterFunctionToKeyDownCallback(0, "increaseAngle", "n")