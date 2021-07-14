-- By ALVAROPING1

-- Each section is enclosed by 2 '-' lines
-- To use a specific function in your mod, you need to copy all the code from the section it is in. It's not required to copy the code from other sections to use it.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Rotates a vector with a given rotation.
-- Input:
--		_bodyRot: euler angles defining the rotation.
--		_vector: vector to rotate.
-- Output:
--		_rotatedVector: rotated vector.
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
-- Rotates a child object given the rotation of the parent and the relative rotation between the rotations of both objects. Can also be interpreted as applying rotation transformation to a rotation.
-- Input:
--		_bodyRot: euler angles defining the rotation of the parent or the rotation transformation.
--		_qRelative: relative quaternion between the rotations or quaternion defining the starting rotation the transformation will be applied to.
--			Can be obtained with 'tm.quaternion.Create(_offsetRotationChild)' where '_offsetRotationChild' is either the rotation in euler angles of the child object when the parent's rotation is (0, 0, 0) or the starting rotation the transformation will be applied to,
--			or with 'getRelativeRotation()'.
-- Output:
--		_ChildRot: euler angles defining the rotation of the child.
function getChildRotation(_bodyRot, _qRelative)
	local _qParent = tm.quaternion.Create(_bodyRot)

	local _ChildRot = _qParent.Multiply(_qRelative).GetEuler()

	return _ChildRot
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Gets the relative rotation between 2 given rotations.
-- Input:
--		_sourceRotation: euler angles defining the initial rotation.
--		_targetRotation: euler angles defining the target rotation.
-- Output:
--		_relativeRotation: euler angles defining the relative rotation.
function getRelativeRotation(_sourceRotation, _targetRotation)
	local _qTarget = tm.quaternion.Create(_targetRotation)

	local _qTargetInverse = tm.quaternion.Create(-_qTarget.x, -_qTarget.y, -_qTarget.z, _qTarget.w)

	local _qSource = tm.quaternion.Create(_sourceRotation)

	local _relativeRotation = _qTargetInverse.Multiply(_qSource).GetEuler()

	return _relativeRotation
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Interpolates between 2 quaternions.
-- To create a new instance, do 'instanceName = interpolateQuaternions:new()'.
-- After creating an instance, you can do 'instanceName.Parameter = value' to change a parameter.
-- After creating an instance, you can do 'instanceName:function()' to call a function.
--
-- Public parameters:
--		startRotation: quaternion encoding the starting rotation, can be obtained from the euler angles with 'tm.quaternion.Create(tm.vector3.Create(eulerAngles)'.
--		finalRotation: quaternion encoding the final rotation, can be obtained from the euler angles with 'tm.quaternion.Create(tm.vector3.Create(eulerAngles)'.
--		totalSteps: amount of steps the rotation is going to take.
-- Private parameters (you shouldn't need to change these):
--		_currentRotation: quaternion encoding the current rotation.
--		_currentStep: current step in the interpolation.
--		_relativeStep: '_currentStep/totalSteps'.
--		_currentPosition: current position in the interpolation.
--		_finished: boolean determining if the interpolation has finished or not.
-- Functions
--		positionFunction(): makes _currentPosition be a function of _relativeStep, called once in each step (you shouldn't need to call it manually). Returns void.
--			To change it do:
--			instanceName.positionFunction = function (self)
--				self._currentPosition = <expresion>
--			end
--			Where <expresion> is a function of 'self._relativeStep'.
--		update(): advances 1 step the interpolation. Returns '_currentRotation, _finished'.
--
-- Prototype of the class (includes default values and definitions):
interpolateQuaternions = {

	startRotation = tm.quaternion.Create(tm.vector3.Create(90, 0, 0)),
	finalRotation = tm.quaternion.Create(tm.vector3.Create(-90, 0, 0)),
	_currentRotation = tm.quaternion.Create(tm.vector3.Create(90, 0, 0)),

	totalSteps = 360,
	_currentStep = 0,
	_relativeStep = 0,
	_currentPosition = 0,

	_finished = false,

	positionFunction = function (self)
		self._currentPosition = self._relativeStep
	end,

	update = function (self)
		if self._finished == false then
			self._currentStep = self._currentStep + 1
			self._relativeStep = self._currentStep/self.totalSteps

			self:positionFunction()

			self.currentRotation = tm.quaternion.Slerp(self.startRotation, self.finalRotation, self._currentPosition)

			if self._currentStep >= self.totalSteps then
				self._finished = true
			end
		end

		return self.currentRotation, self.finished
	end
}

-- Function defining how to create a new instance from the prototype
function interpolateQuaternions:new(o)
	o = o or {} -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
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

		offsetRotationWhale = getChildRotation(playerRotation, qRelative)
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
	whale = tm.physics.SpawnObject(tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.create(0,2.5,0), "PFB_Whale")
	whale.GetTransform().SetScale(0.1)
	whale.SetIsStatic(true)
	whale.SetIsTrigger(true)
	qRelative = tm.quaternion.Create(tm.vector3.Create(-90,0,0))
end


-- interpolateQuaternions example
whale2 = tm.physics.SpawnObject(tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.create(0,2.5,0), "PFB_Whale")
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