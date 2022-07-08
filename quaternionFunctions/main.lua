-- By ALVAROPING1

-- Each section is enclosed by 2 '-' lines
-- To use a specific function in your mod, you need to copy all the code from the section it is in. It's not required to copy the code from other sections to use it.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Rotates a vector with a given rotation.
---
---@param _bodyRot ModVector3 Euler angles defining the rotation
---@param _vector ModVector3 Vector to rotate
---
---@return ModVector3 _rotatedVector Rotated vector
function getVectorRotation(_bodyRot, _vector)
	local q = tm.quaternion.Create(_bodyRot)

	local qInverse = tm.quaternion.Create(-q.x, -q.y, -q.z, q.w)

	local p = tm.quaternion.Create(_vector.x, _vector.y, _vector.z, 0)

	local pRotated = q.Multiply(p).Multiply(qInverse)

	local mod = math.sqrt(pRotated.x^2 + pRotated.y^2 + pRotated.z^2)
	local _rotatedVector = tm.vector3.Create(pRotated.x/mod, pRotated.y/mod, pRotated.z/mod)

	mod = _rotatedVector.Magnitude()
	_rotatedVector = tm.vector3.op_Division(_rotatedVector, mod)
	mod = _rotatedVector.Magnitude()
	_rotatedVector = tm.vector3.op_Division(_rotatedVector, mod)

	return _rotatedVector
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Rotates a child object given the rotation of the parent and the relative rotation between the rotations of both objects. Can also be interpreted as applying rotation transformation to a rotation
---
---@param _bodyRot ModVector3 Euler angles defining the rotation of the parent or the rotation transformation
---@param _qRelative ModQuaternion Relative quaternion between the rotations or quaternion defining the starting rotation the transformation will be applied to
--- Can be obtained with `tm.quaternion.Create(_offsetRotationChild)` where `_offsetRotationChild` is either the rotation in euler angles of the child object when the parent's rotation is (0, 0, 0) or
--- the starting rotation the transformation will be applied to, or with `getRelativeRotation(_bodyRot, _childRot, true)` where `_bodyRot` is the rotation of the parent object and '_childRot' is the
--- rotation of the child object, both in euler angles
---@param _getQuaternion boolean Defines if the output will be a quaternion (`true`) or euler angles (`false`)
---
---@return ModVector3|ModQuaternion _ChildRot Euler angles or quaternion (depending on `_getQuaternion`) defining the rotation of the child
function getChildRotation(_bodyRot, _qRelative, _getQuaternion)
	local _qParent = tm.quaternion.Create(_bodyRot)

	local _ChildRot = _qParent.Multiply(_qRelative)

	if _getQuaternion == false then
		_ChildRot = _ChildRot.GetEuler()
	end

	return _ChildRot
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Gets the relative rotation between 2 given rotations
---
---@param _sourceRotation ModVector3 Euler angles defining the initial rotation
---@param _targetRotation ModVector3 Euler angles defining the target rotation
---@param _getQuaternion boolean Defines if the output will be a quaternion (`true`) or euler angles (`false`)
---
---@return ModVector3 _relativeRotation Euler angles or quaternion (depending on `_getQuaternion`) defining the relative rotation
function getRelativeRotation(_sourceRotation, _targetRotation, _getQuaternion)
	local _qTarget = tm.quaternion.Create(_targetRotation)

	local _qTargetInverse = tm.quaternion.Create(-_qTarget.x, -_qTarget.y, -_qTarget.z, _qTarget.w)

	local _qSource = tm.quaternion.Create(_sourceRotation)

	local _relativeRotation = _qTargetInverse.Multiply(_qSource)

	if _getQuaternion == false then
		_relativeRotation = _relativeRotation.GetEuler()
	end

	return _relativeRotation
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---@class interpolateQuaternions
---@field startRotation ModQuaternion
---@field finalRotation ModQuaternion
---@field totalSteps integer
---@field _currentRotation ModQuaternion
---@field _currentStep integer
---@field _relativeStep number
---@field _currentPosition number
---@field _finished boolean
---
--- Interpolates between 2 quaternions
---
--- To create a new instance, do `instanceName = interpolateQuaternions:new()`
--- - After creating an instance, you can do `instanceName.Parameter = value` to change a parameter
--- - After creating an instance, you can do `instanceName:function()` to call a function
---
--- Public parameters:
--- - `startRotation`: quaternion defining the starting rotation, can be obtained from the euler angles with `tm.quaternion.Create(tm.vector3.Create(eulerAngles))`.
--- - `finalRotation`: quaternion defining the final rotation, can be obtained from the euler angles with `tm.quaternion.Create(tm.vector3.Create(eulerAngles))`.
--- - `totalSteps`: amount of steps the rotation is going to take
---
--- Private parameters (you shouldn't need to change these):
--- - `_currentRotation`: quaternion defining the current rotation
--- - `_currentStep`: current step in the interpolation
--- - `_relativeStep`: `_currentStep/totalSteps`
--- - `_currentPosition`: current position in the interpolation
--- - `_finished`: boolean determining if the interpolation has finished or not
---
--- Methods:
--- - `positionFunction()`: makes `_currentPosition` be a function of `_relativeStep`, called once in each step (you shouldn't need to call it manually). Returns nil.
---    To change it do:
---    ```
---    instanceName.positionFunction = function (self)
---        self._currentPosition = <expresion>
---    end
---    ```
---    Where `<expresion>` is a function of `self._relativeStep`
--- - `update()`: advances 1 step the interpolation. Returns `_currentRotation, _finished`
interpolateQuaternions = {
	--- Defines the starting rotation, can be obtained from the euler angles with `tm.quaternion.Create(tm.vector3.Create(eulerAngles))`.
	startRotation = tm.quaternion.Create(tm.vector3.Create(90, 0, 0)),
	--- Defines the final rotation, can be obtained from the euler angles with `tm.quaternion.Create(tm.vector3.Create(eulerAngles))`.
	finalRotation = tm.quaternion.Create(tm.vector3.Create(-90, 0, 0)),
	--- Amount of steps the rotation is going to take
	totalSteps = 360,

	--- Defines the current rotation
	_currentRotation = tm.quaternion.Create(tm.vector3.Create(90, 0, 0)),

	--- Current step in the interpolation
	_currentStep = 0,
	--- `_currentStep/totalSteps`
	_relativeStep = 0,
	--- Current position in the interpolation
	_currentPosition = 0,

	--- Determines if the interpolation has finished or not
	_finished = false
}

-- Function defining how to create a new instance from the prototype
---
---@param o table|nil
---@return interpolateQuaternions
function interpolateQuaternions:new(o)
	o = o or {} -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

--- Makes `self._currentPosition` be a function of `_relativeStep`, called once in each step (you shouldn't need to call it manually). Returns nil.
---
--- To change it do:
--- ```
--- instanceName.positionFunction = function (self)
---     self._currentPosition = <expresion>
--- end
--- ```
--- Where `<expresion>` is a function of `self._relativeStep`
---
---@return nil
function interpolateQuaternions:positionFunction()
	self._currentPosition = self._relativeStep
end

--- Advances 1 step the interpolation
---
---@return ModQuaternion self.currentRotation Quaternion defining the current rotation
---@return boolean _finished boolean determining if the interpolation has finished or not
function interpolateQuaternions:update()
	if self._finished == false then
		self._currentStep = self._currentStep + 1
		self._relativeStep = self._currentStep/self.totalSteps

		self:positionFunction()

		self.currentRotation = tm.quaternion.Slerp(self.startRotation, self.finalRotation, self._currentPosition)

		if self._currentStep >= self.totalSteps then
			self._finished = true
		end
	end

	return self.currentRotation, self._finished
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Examples of how to use the previous functions

function update()
	if key == true then
		playerRotation = tm.players.GetPlayerTransform(0).GetRotation()
		playerPosition = tm.players.GetPlayerTransform(0).GetPosition()

		-- getVectorRotation example. Cube follows the rotation of the player
		offsetPositionCube = getVectorRotation(playerRotation, offset)
		positionCube = playerPosition + offsetPositionCube
		cube.GetTransform().SetPosition(positionCube)


		-- getChildRotation example. Whale follows the rotation of the player and makes the relative rotation between player and whale constant
		offsetPositionWhale = getVectorRotation(playerRotation, offset)
		positionWhale = playerPosition + offsetPositionWhale
		whale.GetTransform().SetPosition(positionWhale)

		offsetRotationWhale = getChildRotation(playerRotation, qRelative, false)
		whale.GetTransform().SetRotation(offsetRotationWhale)
	end

	-- interpolateQuaternions example. Whale rotates following the quaternion interpolation
	if active == true then
		rotation, finish = whale2Rotation:update()
		whale2.GetTransform().SetRotation(rotation)
	end
end


-- getVectorRotation and getChildRotation examples
key = false

function activateFollowObjects()
	key = true

	-- getVectorRotation example
	cube = tm.physics.SpawnObject(tm.players.GetPlayerTransform(0).GetPosition(), "PFB_MagneticCube")
	cube.GetTransform().SetScale(0.4)
	cube.SetIsStatic(true)
	cube.SetIsTrigger(true)
	offset = tm.vector3.Create(0, -1, 0)

	-- getChildRotation example
	whale = tm.physics.SpawnObject(tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0,2.5,0), "PFB_Whale")
	whale.GetTransform().SetScale(0.1)
	whale.SetIsStatic(true)
	whale.SetIsTrigger(true)
	qRelative = tm.quaternion.Create(tm.vector3.Create(-90,0,0))
end


-- interpolateQuaternions example
whale2 = tm.physics.SpawnObject(tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(0,2.5,0), "PFB_Whale")
whale2.GetTransform().SetScale(0.1)
whale2.SetIsStatic(true)
whale2.SetIsTrigger(true)

active = false

function rot1()
	active = true
	whale2Rotation = interpolateQuaternions:new{}
	whale2Rotation.startRotation = tm.quaternion.Create(tm.vector3.Create(0, 90, 90))
	whale2Rotation.finalRotation = tm.quaternion.Create(tm.vector3.Create(0, -90, 0))
	whale2Rotation.totalSteps = 180
	whale2Rotation.positionFunction = function (self)
		self._currentPosition = (self._relativeStep)^4
	end
end

function rot2()
	active = true
	whale2Rotation = interpolateQuaternions:new{}
	whale2Rotation.startRotation = tm.quaternion.Create(tm.vector3.Create(0, -90, 0))
	whale2Rotation.finalRotation = tm.quaternion.Create(tm.vector3.Create(180, 0, 90))
	whale2Rotation.totalSteps = 360
	whale2Rotation.positionFunction = function (self)
		self._currentPosition = 2*self._relativeStep
	end
end


-- Initialization
tm.playerUI.AddUIButton(0, "0", "Activate follow objects", activateFollowObjects)
tm.playerUI.AddUIButton(0, "1", "Rotation 1 whale", rot1)
tm.playerUI.AddUIButton(0, "2", "Rotation 2 whale", rot2)

tm.os.SetModTargetDeltaTime(1/60)

tm.os.Log("Mod loaded")