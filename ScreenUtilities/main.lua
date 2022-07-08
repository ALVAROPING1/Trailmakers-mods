-- By ALVAROPING1
--
-- To use it on your mod, you need to copy all the code enclosed by the '-' lines
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---@class screen
---@field position ModVector3
---@field orientation number
---@field pixelSize number
---@field collision boolean
---@field sizeH integer
---@field sizeV integer
---@field cubeMesh string
---@field cubeTexture string
---@field nextFrameDelta {[integer]: {position: {[1]: integer, [2]: integer}, color: integer}}
---@field _pixels {[integer]: {[integer]: {object: ModGameObject, color: integer}}}
---@field _color2Rotation ModVector3[]
---
--- Creates a screen which can display images.
---
--- To create a new instance, do `instanceName = screen:new()`
--- - After creating an instance, you can do `instanceName.Parameter = value` to change a parameter
--- - After creating an instance, you can do `instanceName:function()` to call a function
---
--- Public parameters (with the exception of `nextFrameDelta` they can only be changed before calling the `self.spawn()` function):
--- - `position`: vector3 defining the position of the bottom left corner of the screen
--- - `orientation`: float defining the orientation of the screen in degrees. For the best result, it's recommended to keep it as multiple of 90
--- - `pixelSize`: float defining the size of the individual pixels. For the best result, it's recommended to keep it as a sum of powers of 2
--- - `collision`: boolean determining if the screen has collision or not. The method used to increase the LOD distance causes the hitbox to expand far away from one of the faces of the cube.
--- - `sizeH`: horizontal resolution
--- - `sizeV`: vertical resolution
--- - `cubeMesh`: string pointing to the object to be used as the pixels. Must be loaded with `tm.physics.AddMesh(filename, string)`. You shouldn't need to use any object other than the included `cube.obj`
--- - `cubeTexture`: string pointing to the texture to be used on the pixels to determine the color/image of each rotation. Must be loaded with `tm.physics.AddTexture(filename, string)`.
---    A template with the position each color must be in is included in the file `exampleTexture.png`. If using images for the texture rather than solid colors, you need to take into
---    account that it will be flipped horizontally when shown on the screen. Note: to remove weird reflections the alpha channel must be set to 0 on all pixels. To achieve this you can
---    open the image in gimp, then do layer->Add layer mask->select 'Black (full transparency)'->export as .png
--- - `nextFrameDelta`: array containing which pixels need to be change and to which color for the next frame. Can be set manually or with the `setNextFrameDelta()` or `setPartialNextFrameDelta()` functions.
---    If set manually, the array must contain a table for each pixel which needs to change. The structure of each of this tables must be as follows:
---    ```
---    {
---        position = {positionH, positionV},
---        color = colorValue
---    }
---    ```
---    Where `positionH` and `positionV` are the coordinates of the pixel starting at 0 and with the origin being the top left pixel of the screen,
---    and `colorValue` is an integer from 0 to 5 (both included) describing the new color of the pixel
---
--- Private parameters (you shouldn't need to change these):
--- - `_pixels`: table describing the current state of the screen by storing a pointer to each pixels' object and their color. Initialized during the `self.spawn()` function
---    The structure is as follows:
---    ```
---    _pixels[positionH][positionV] = {object: ModGameObject, color: integer}
---    ```
--- - `_color2Rotation`: table containing the conversion between `colorValue` and rotation. Initialized during the `self.spawn()` function
---
--- Methods:
--- - `spawn()`: spawns the screen. Returns nil
--- - `despawn()`: despawns the screen and deletes the instance. Returns nil
--- - `setNextFrameDelta(_nextFrame)`: sets `self.nextFrameDelta` according to `_nextFrame`. `_nextFrame` must be a table containing the color of each pixel in the next frame. Returns nil
---    The structure of _nextFrame must be as follows:
---    ```
---    _nextFrame[positionH][positionV] = colorValue
---    ```
---    Where `positionH` and `positionV` are the coordinates of the pixel starting at 0 and with the origin being the top left pixel of the screen,
---    and `colorValue` is an integer from 0 to 5 (both included) describing the new color of the pixel
--- - `setPartialNextFrameDelta(_nextFrameDelta)`: sets `self.nextFrameDelta` according to `partialNextFrameDelta`. `partialNextFrameDelta` works in the same way as manually
---     setting `self.nextFrameDelta` with the exception that it can contain pixels which do not change, `setPartialNextFrameDelta()` will automatically remove those. Returns nil
--- - `update()`: updates the screen according to `self.nextFrameDelta`. Returns nil
screen = {
	--- Defines the position of the bottom left corner of the screen
	---@diagnostic disable-next-line: assign-type-mismatch #The game implements an override to the `+` operator for ModVector3 addition
	position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5),
	--- Defines the orientation of the screen in degrees. For the best result, it's recommended to keep it as multiple of 90
	orientation = 0,

	--- Defines the size of the individual pixels. For the best result, it's recommended to keep it as a sum of powers of 2
	pixelSize = 2^-4,
	--- Determines if the screen has collision or not. The method used to increase the LOD distance causes the hitbox to expand far away from one of the faces of the cube.
	collision = false,

	--- Horizontal resolution
	sizeH = 15,
	--- Vertical resolution
	sizeV = 15,

	--- String pointing to the object to be used as the pixels. Must be loaded with `tm.physics.AddMesh(filename, string)`. You shouldn't need to use any object other than the included `cube.obj`
	cubeMesh = "cubeObj",
	--- String pointing to the texture to be used on the pixels to determine the color/image of each rotation. Must be loaded with `tm.physics.AddTexture(filename, string)`.
	--- A template with the position each color must be in is included in the file `exampleTexture.png`. If using images for the texture rather than solid colors, you need to take into
	--- account that it will be flipped horizontally when shown on the screen. Note: to remove weird reflections the alpha channel must be set to 0 on all pixels. To achieve this you can
	--- open the image in gimp, then do layer->Add layer mask->select 'Black (full transparency)'->export as .png
	cubeTexture = "cubePng",

	--- Array containing which pixels need to be change and to which color for the next frame. Can be set manually or with the `setNextFrameDelta()` or `setPartialNextFrameDelta()` functions.
	--- If set manually, the array must contain a table for each pixel which needs to change. The structure of each of this tables must be as follows:
	--- ```
	--- {
	---     position = {positionH, positionV},
	---     color = colorValue
	--- }
	--- ```
	--- Where `positionH` and `positionV` are the coordinates of the pixel starting at 0 and with the origin being the top left pixel of the screen,
	--- and `colorValue` is an integer from 0 to 5 (both included) describing the new color of the pixel
	nextFrameDelta = {},

	--- Describes the current state of the screen by storing a pointer to each pixels' object and their color. Initialized during the `self.spawn()` function.
	--- The structure is as follows:
	--- ```
	--- _pixels[positionH][positionV] = {object: ModGameObject, color: integer}
	--- ```
	_pixels = {},
	--- Contains the conversion between `colorValue` and rotation. Initialized during the `self.spawn()` function
	_color2Rotation = {}
}

--- Function defining how to create a new instance from the prototype
---
---@param o table|nil
---@return screen
function screen:new(o)
	o = o or {} -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

--- Spawns the screen
---
---@return nil
function screen:spawn()
	local deltaHOrientation = tm.vector3.Create(math.cos(math.rad(self.orientation)), 0, math.sin(math.rad(self.orientation))) -- Creates a unit vector defining the direction of the horizontal axis according to 'orientation'

	-- Table with the conversion between colorValue and rotation
	self._color2Rotation = {
		tm.vector3.Create(0, 0-self.orientation, 0),
		tm.vector3.Create(0, 90-self.orientation, 0),
		tm.vector3.Create(0, -90-self.orientation, 0),
		tm.vector3.Create(0, 180-self.orientation, 0),
		tm.vector3.Create(-90, 0-self.orientation, 180),
		tm.vector3.Create(-90, 0-self.orientation, 0),
	}

	-- Vectors defining the space between pixels' positions
	local deltaH = tm.vector3.op_Multiply(deltaHOrientation, self.pixelSize*2)
	local deltaV = tm.vector3.Create(0, -self.pixelSize*2, 0)

	-- Position of the top left pixel on the screen
	local _position0 = self.position + tm.vector3.op_Multiply(-deltaV, self.sizeV)

	self._pixels = {}
	-- Creates each pixels' object
	for positionH=0, self.sizeH-1 do
		self._pixels[positionH] = {}
		for positionV=0, self.sizeV-1 do
			self._pixels[positionH][positionV] = {} -- Creates table to store the state of the pixel as well as its object reference

			local position = _position0 + tm.vector3.op_Multiply(deltaH, positionH) + tm.vector3.op_Multiply(deltaV, positionV) -- Calculates the position of the pixel

			-- Spawns the pixel and sets its size, default rotation and if it has collisions or not
			self._pixels[positionH][positionV].object = tm.physics.SpawnCustomObjectRigidbody(position, self.cubeMesh, self.cubeTexture, true, 1)
			self._pixels[positionH][positionV].object.GetTransform().SetScale(self.pixelSize)
			self._pixels[positionH][positionV].object.GetTransform().SetRotation(self._color2Rotation[1])
			if self.collision == false then
				self._pixels[positionH][positionV].object.SetIsTrigger(true)
			end

			self._pixels[positionH][positionV].color = 0 -- Stores the default color

		end
	end
end

--- Despawns the screen and deletes the instance
---
---@return nil
function screen:despawn()
	for positionH=0, self.sizeH-1 do
		for positionV=0, self.sizeV-1 do
			self._pixels[positionH][positionV].object.Despawn()
		end
	end
	-- Deletes the instance
	---@diagnostic disable-next-line: cast-local-type
	self = nil
end

--- Sets `self.nextFrameDelta` according to `_nextFrame`. `_nextFrame` must be a table containing the color of each pixel in the next frame
--- The structure of _nextFrame must be as follows:
--- ```
--- _nextFrame[positionH][positionV] = colorValue
--- ```
--- Where `positionH` and `positionV` are the coordinates of the pixel starting at 0 and with the origin being the top left pixel of the screen,
--- and `colorValue` is an integer from 0 to 5 (both included) describing the new color of the pixel
---
---@param _nextFrame {[integer]: {[integer]: integer}}
---@return nil
function screen:setNextFrameDelta(_nextFrame)
	self.nextFrameDelta = {} -- Clears 'self.nextFrameDelta'

	for positionH=0, self.sizeH-1 do
		for positionV=0, self.sizeV-1 do
			if self._pixels[positionH][positionV].color ~= _nextFrame[positionH][positionV] then -- Checks if the new color is the same as the previous color, if it isn't adds the change to 'self.nextFrameDelta'
				local pixelState = {position = {positionH, positionV}, color = _nextFrame[positionH][positionV]}
				table.insert(self.nextFrameDelta, pixelState)
			end
		end
	end
end

--- Sets `self.nextFrameDelta` according to `partialNextFrameDelta`. `partialNextFrameDelta` works in the same way as manually setting `self.nextFrameDelta`
--- with the exception that it can contain pixels which do not change, `setPartialNextFrameDelta()` will automatically remove those
---
---@param partialNextFrameDelta {[integer]: {position: {[1]: integer, [2]: integer}, color: integer}}
---@return nil
function screen:setPartialNextFrameDelta(partialNextFrameDelta)
	self.nextFrameDelta = {} -- Clears 'self.nextFrameDelta'

	for key, pixelState in pairs(partialNextFrameDelta) do
		local positionH = pixelState.position[1]
		local positionV = pixelState.position[2]
		local color = pixelState.color

		if self._pixels[positionH][positionV].color ~= color then -- Checks if the new color is the same as the previous color, if it isn't adds the change to 'self.nextFrameDelta'
			table.insert(self.nextFrameDelta, pixelState)
		end
	end
end

--- Updates the screen according to `self.nextFrameDelta`
---
---@return nil
function screen:update()
	for key, value in pairs(self.nextFrameDelta) do -- Applies the pixel changes described in 'self.nextFrameDelta'
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
tm.physics.AddTexture("exampleTexture.png", "examplePng")
tm.physics.AddMesh("cube.obj", "cubeObj")

tm.os.SetModTargetDeltaTime(30/60)


-- Spawns a screen in which all colors appear in order using the example texture
function debugColors()
	if active == false then
		-- Creates a screen instance, sets its dimensions and pixel size, removes collisions and spawns it
		_screen = screen:new()
		_screen.position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5)
		_screen.sizeH = 6
		_screen.sizeV = 1
		_screen.pixelSize = 1
		_screen.collision = false
		--_screen.cubeTexture = "examplePng"
		_screen:spawn()

		-- Creates an image to display on the screen in which all colors appear in order
		local img = {}
		for positionH=0, 5 do
			img[positionH] = {}
			img[positionH][0] = positionH
		end

		-- Displays the generated image on the screen
		_screen:setNextFrameDelta(img)
		_screen:update()

		tm.playerUI.SetUIValue(0, "state", "State: On")
		active = true
	end
end


-- Play video by manually setting 'self.nextFrameDelta'
function activateVideo1()
	if active == false then
		-- Creates a screen instance, sets its dimensions and pixel size, removes collisions and spawns it
		_screen = screen:new()
		_screen.position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5)
		_screen.sizeH = 3
		_screen.sizeV = 3
		_screen.pixelSize = 2^-2
		_screen.collision = false
		_screen:spawn()

		local img = {}
		for positionH=0, _screen.sizeH-1 do
			for positionV=0, _screen.sizeV-1 do
				table.insert(img, {position = {positionH, positionV}, color = 5})
			end
		end
		_screen.nextFrameDelta = img
		_screen:update()

		-- Loads the video file
		video = tm.os.ReadAllText_Static("video.json")
		videoData = json.parse(video)

		frame = 0
		tm.playerUI.SetUIValue(0, "state", "State: On")
		playMethod = 1 -- Used to determine in the update function which playback method will be used
		active = true
	end
end


-- Play video by using 'setNextFrameDelta()'
function activateVideo2()
	if active == false then
		-- Creates a screen instance, sets its dimensions and pixel size, removes collisions and spawns it
		_screen = screen:new()
		_screen.position = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0, 0.05, 5)
		_screen.sizeH = 6
		_screen.sizeV = 6
		_screen.pixelSize = 2^-2
		_screen.collision = false
		_screen:spawn()

		frame = 0
		tm.playerUI.SetUIValue(0, "state", "State: On")
		playMethod = 2 -- Used to determine in the update function which playback method will be used
		active = true
	end
end


-- Despawn screen
function stop()
	if active == true then
		tm.playerUI.SetUIValue(0, "state", "State: Off")
		_screen:despawn()
		playMethod = 0
		active = false
	end
end


-- Loads the UI
tm.playerUI.AddUIButton(0, "debugColors", "Spawn Color Tester", debugColors)
tm.playerUI.AddUIButton(0, "0", "Activate video 1", activateVideo1)
tm.playerUI.AddUIButton(0, "1", "Activate video 2", activateVideo2)
tm.playerUI.AddUIButton(0, "stop", "Stop", stop)
tm.playerUI.AddUILabel(0, "state", "State: Off")



playMethod = 0
active = false

function update()
	if active == true then
		if playMethod == 1 then -- Play video by manually setting 'self.nextFrameDelta'
			_screen.nextFrameDelta = videoData.frames[frame+1]
			_screen:update()
			frame = (frame + 1) % videoData.total
		elseif playMethod == 2 then -- Play video by using 'setNextFrameDelta()'
			local img = renderFrame(frame)
			_screen:setNextFrameDelta(img)
			_screen:update()
			frame = (frame + 1) % 11
		end
	end
end

-- Creates the image that will be displayed on the screen
function renderFrame(_frame)
	local _img = {}

	for positionH=0, _screen.sizeH-1 do
		_img[positionH] = {}
		for positionV=0, _screen.sizeV-1 do
			i = positionH + positionV

			if i == _frame then
				_img[positionH][positionV] = 0
			elseif i == (_frame - 1) % 11 then
				_img[positionH][positionV] = 1
			elseif i == (_frame - 2) % 11 then
				_img[positionH][positionV] = 2
			elseif i == (_frame - 3) % 11 then
				_img[positionH][positionV] = 3
			elseif i == (_frame - 4) % 11 then
				_img[positionH][positionV] = 4
			else
				_img[positionH][positionV] = 5
			end
		end
	end

	return _img
end