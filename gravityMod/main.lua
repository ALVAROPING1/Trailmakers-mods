
function update()
	if loaded == true then
		onUpdateGravity()
	end
end

function onUpdateGravity()
	playerPosition = tm.players.GetPlayerTransform(0).GetPosition()

	direction = tm.vector3.op_Subtraction(planetPosition, playerPosition)
	distance = direction.Magnitude()
	unitDirection = tm.vector3.op_Division(direction, distance)

	strength = 500000

	gravityIntensity = tm.vector3.op_Multiply(unitDirection, strength/distance^2)
	tm.physics.SetGravity(gravityIntensity)
end

function onLoadPlanet()
	---@type ModVector3
	---@diagnostic disable-next-line: assign-type-mismatch #The game implements an override to the `+` operator for ModVector3 addition
	planetPosition = tm.players.GetPlayerTransform(0).GetPosition() + tm.vector3.Create(100, 0, 100)
	tm.physics.SpawnObject(planetPosition, "PFB_MagneticCube").SetIsStatic(true)
	tm.os.Log("Mod loaded")
	loaded = true
end


function onPlayerJoined()
	tm.input.RegisterFunctionToKeyDownCallback(0, "onLoadPlanet", "P")
end

tm.players.OnPlayerJoined.add(onPlayerJoined)