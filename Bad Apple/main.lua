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

-- Loads the object and the texture
tm.physics.AddTexture("cube.png", "cubePng")
tm.physics.AddMesh("cube.obj", "cubeObj")


function activate80x60()
	if active == false then
		-- Creates a screen instance, sets its dimensions and spawns it
		_screen = screen:new()
		_screen.position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5)
		_screen.sizeH = 80
		_screen.sizeV = 60
		_screen:spawn()

		-- Loads the video file
		video = tm.os.ReadAllText_Static("video80x60.json")
		videoData = json.parse(video)

		frame = 1
		tm.os.SetModTargetDeltaTime(60/60)
		tm.playerUI.SetUIValue(0, "state", "State: On")
		active = true
	end
end

function activate60x45()
	if active == false then
		-- Creates a screen instance, sets its dimensions and spawns it
		_screen = screen:new()
		_screen.position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5)
		_screen.sizeH = 60
		_screen.sizeV = 45
		_screen:spawn()

		-- Loads the video file
		video = tm.os.ReadAllText_Static("video60x45.json")
		videoData = json.parse(video)

		frame = 1
		tm.os.SetModTargetDeltaTime(20/60)
		tm.playerUI.SetUIValue(0, "state", "State: On")
		active = true
	end
end

function activate48x36()
	if active == false then
		-- Creates a screen instance, sets its dimensions and spawns it
		_screen = screen:new()
		_screen.position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5)
		_screen.sizeH = 48
		_screen.sizeV = 36
		_screen:spawn()

		-- Loads the video file
		video = tm.os.ReadAllText_Static("video48x36.json")
		videoData = json.parse(video)

		frame = -50 -- Adds a wait time before the video starts playing
		tm.os.SetModTargetDeltaTime(8/60)
		tm.playerUI.SetUIValue(0, "state", "State: On")
		active = true
	end
end

function activate40x30()
	if active == false then
		-- Creates a screen instance, sets its dimensions and spawns it
		_screen = screen:new()
		_screen.position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5)
		_screen.sizeH = 40
		_screen.sizeV = 30
		_screen:spawn()

		-- Loads the video file
		video = tm.os.ReadAllText_Static("video40x30.json")
		videoData = json.parse(video)

		frame = -100 -- Adds a wait time before the video starts playing
		tm.os.SetModTargetDeltaTime(4/60)
		tm.playerUI.SetUIValue(0, "state", "State: On")
		active = true
	end
end

function activate32x24()
	if active == false then
		-- Creates a screen instance, sets its dimensions and spawns it
		_screen = screen:new()
		_screen.position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5)
		_screen.sizeH = 32
		_screen.sizeV = 24
		_screen:spawn()

		-- Loads the video file
		video = tm.os.ReadAllText_Static("video32x24.json")
		videoData = json.parse(video)

		frame = -200 -- Adds a wait time before the video starts playing
		tm.os.SetModTargetDeltaTime(2/60)
		tm.playerUI.SetUIValue(0, "state", "State: On")
		active = true
	end
end


-- Stops the video and despawns the screen
function stop()
	if active == true then
		_screen:despawn()
		tm.playerUI.SetUIValue(0, "state", "State: Off")
		active = false
	end
end


-- Adds UI buttons
tm.playerUI.AddUIButton(0, "0", "Play 80x60 1fps", activate80x60)
tm.playerUI.AddUIButton(0, "1", "Play 60x45 3fps", activate60x45)
tm.playerUI.AddUIButton(0, "2", "Play 48x36 7.5fps", activate48x36)
tm.playerUI.AddUIButton(0, "3", "Play 40x30 15fps", activate40x30)
tm.playerUI.AddUIButton(0, "4", "Play 32x24 30fps", activate32x24)
tm.playerUI.AddUIButton(0, "stop", "Stop", stop)
tm.playerUI.AddUILabel(0, "state", "State: Off")



active = false

function update()
	if active == true then
		if frame < 1 then
			frame = frame + 1
		elseif frame <= videoData.total then
			_screen.nextFrameDelta = videoData.frames[frame] -- Gets the 'nextFrameDelta' from the video data for the current frame and sets it
			_screen:update() -- Updates the screen according to 'nextFrameDelta'
			frame = frame + 1
		else
			-- Despawns the screen once the video finishes playing
			_screen:despawn()
			tm.playerUI.SetUIValue(0, "state", "State: Off")
			active = false
		end
	end
end