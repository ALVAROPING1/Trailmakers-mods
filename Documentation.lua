-- Original document by Ridicolas
-- Updated to include new functions and fully work with intellisense by ALVAROPING1

tm = {}

--------------------- OS ---------------------
--#region

--- Everything to do with files and general mod systems
tm.os = {}

--- Read all text of a file in the mods static data directory. Files in the static data directory can only be read and NOT written to
---@param path string
---@return string
function tm.os.ReadAllText_Static(path)	end


--- Read all text of a file in the mods dynamic data directory. Files in the dynamic data directory can be both read and written to. The dynamic data directory will NOT be uploaded to the steam workshop when you upload your mod. When a mod is run through the steam workshop, the dynamic data, unlike static data, is not located in the steam workshop directory but is located in the steam user data directory instead
---@param path string
---@return string
function tm.os.ReadAllText_Dynamic(path) end


--- Create or overwrite a file in the mods dynamic data directory. Files in the dynamic data directory can be both read and written to. The dynamic data directory will NOT be uploaded to the steam workshop when you upload your mod. When a mod is run through the steam workshop, the dynamic data, unlike static data, is not located in the steam workshop directory but is located in the steam user data directory instead
---@param path string
---@param stringToWrite string
---@return nil
function tm.os.WriteAllText_Dynamic(path, stringToWrite) end


--- Emit a log message
---@param message string
---@return nil
function tm.os.Log(message) end


--- Get time game has been playing in seconds
---@return number
function tm.os.GetTime() end


--- Get the time since last update
---@return number
function tm.os.GetModDeltaTime() end


--- Determines how often the mod gets updated. "1/60" means 60 times per second. Can't update faster than the game
---@param targetDeltaTime number
---@return nil
function tm.os.SetModTargetDeltaTime(targetDeltaTime) end


--- Returns the target delta time for the mod
---@return number
function tm.os.GetModTargetDeltaTime() end



--#endregion
--------------------- physics ---------------------
--#region

--- Everything that can effect physics, like gravity, spawing obejcts, and importing meshes
tm.physics = {}


--- Set the physics timescale
---@param speed number
---@return nil
function tm.physics.SetTimeScale(speed) end


--- Get the physics timescale
---@return number
function tm.physics.GetTimeScale() end


--- Set the physics gravity in the down direction
---@param strength number
---@return nil
function tm.physics.SetGravity(strength) end


--- Set the physics gravity as per the provided vector
---@param gravity ModVector3
---@return nil
function tm.physics.SetGravity(gravity) end


--- Get the physics gravity
---@return ModVector3
function tm.physics.GetGravity() end


--- Spawn a spawnable at the position, e.g. PFB_Barrel
---@param position ModVector3
---@param name string
---@return ModGameObject
function tm.physics.SpawnObject(position, name) end


--- Despawn all spawned objects from this mod
---@return nil
function tm.physics.ClearAllSpawns() end


--- Get a list of all possible spawnable names
---@return table
function tm.physics.SpawnableNames() end


--- Add a mesh to all clients, note this will have to be sent to the client when they join
---@param filename string
---@param resourceName string
---@return nil
function tm.physics.AddMesh(filename, resourceName) end


--- Add a texture to all clients, note this will have to be sent to the client when they join
---@param filename string
---@param resourceName string
---@return nil
function tm.physics.AddTexture(filename, resourceName) end


--- Spawn a custom physics object where mesh and texture have to be set by AddMesh and AddTexture
---@param position ModVector3
---@param meshName string
---@param textureName string
---@param isKinematic boolean
---@param mass number
---@return ModGameObject
function tm.physics.SpawnCustomObjectRigidbody(position, meshName, textureName, isKinematic, mass) end


--- Spawn a custom object where mesh and texture have to be set by AddMesh and AddTexture
---@param position ModVector3
---@param meshName string
---@param textureName string
---@return ModGameObject
function tm.physics.SpawnCustomObject(position, meshName, textureName) end


--- Spawn a box trigger that will detect overlap but will not interact with physics
---@param position ModVector3
---@param size ModVector3
---@return ModGameObject
function tm.physics.SpawnBoxTrigger(position, size) end


--- Sets the build complexity value. Default value is 700 and values above it can make the game unstable
---@param value integer
---@return nil
function tm.physics.SetBuildComplexity(value) end


--- Registers a function to the collision enter callback of a game object
---@param targetObject ModGameObject
---@param functionName string
---@return nil
function tm.physics.RegisterFunctionToCollisionEnterCallback(targetObject, functionName) end


--- Registers a function to the collision exit callback of a game object
---@param targetObject ModGameObject
---@param functionName string
---@return nil
function tm.physics.RegisterFunctionToCollisionExitCallback(targetObject, functionName) end


--- Returns a bool if raycast hit something. Hit argument get overwritten with raycast data
---@param origin ModVector3
---@param direction ModVector3
---@param hitPositionOut ModVector3
---@param maxDistance number
---@return boolean
function tm.physics.Raycast(origin, direction, hitPositionOut, maxDistance) end


--- Returns the internal name for the current map
---@return string
function tm.physics.GetMapName() end


--- Returns the wind velocity at a position
---@param position ModVector3
---@return ModVector3
function tm.physics.GetWindVelocityAtPosition(position) end



--#endregion
--------------------- player ---------------------
--#region

--- Everything to do with players actions and info
tm.players = {}


--- Event triggered when a player joins the server. Functions are called with a `userdata` object as argument whose only field is `playerId` (ID of the player who triggered the event)
tm.players.OnPlayerJoined = {}


--- Add function to event
---@param Function function
---@return nil
function tm.players.OnPlayerJoined.add(Function) end


--- Remove function from event
---@param Function function
---@return nil
function tm.players.OnPlayerJoined.remove(Function) end


--- Event triggered when a player leaves the server. Functions are called with a `userdata` object as argument whose only field is `playerId` (ID of the player who triggered the event)
tm.players.OnPlayerLeft = {}


--- Add function to event
---@param Function function
---@return nil
function tm.players.OnPlayerLeft.add(Function) end


--- Remove function from event
---@param Function function
---@return nil
function tm.players.OnPlayerLeft.remove(Function) end


--- Get all players currently connected to the server
---@return table
function tm.players.CurrentPlayers() end


--- Forcefully disconnect a given player
---@param playerId integer
---@return nil
function tm.players.Kick(playerId) end


--- Get the transform of a player
---@param playerId integer
---@return ModTransform
function tm.players.GetPlayerTransform(playerId) end


--- Get the GameObject of a player
---@param playerId integer
---@return ModGameObject
function tm.players.GetPlayerGameObject(playerId) end


--- Get all structure(s) owned by that player
---@param playerId integer
---@return table
function tm.players.GetPlayerStructures(playerId) end


--- Get the structure(s) currently in build mode for a player
---@param playerId integer
---@return table
function tm.players.GetPlayerStructuresInBuild(playerId) end


--- Get the last select block in the builder for that player
---@param playerId integer
---@return ModBlock
function tm.players.GetPlayerSelectBlockInBuild(playerId) end


--- Get the player's name
---@param playerId integer
---@return string
function tm.players.GetPlayerName(playerId) end


--- Returns true if the player is in build mode
---@param playerId integer
---@return boolean
function tm.players.GetPlayerIsInBuildMode(playerId) end



--#endregion
--------------------- playerUI ---------------------
--#region

--- For adding UI to your mod
tm.playerUI = {}


--- Add a button to the clients mod UI
---@param playerId integer
---@param id string | integer | number | boolean
---@param defaultValue string
---@param callback function Function to execute (executed with a `CallbackData` object as parameter)
---@param data any
---@return nil
function tm.playerUI.AddUIButton(playerId, id, defaultValue, callback, data) end


--- Add a text field to the clients mod UI
---@param playerId integer
---@param id string | integer | number | boolean
---@param defaultValue string
---@param callback function Function to execute (executed with a `CallbackData` object as parameter)
---@param data any
---@return nil
function tm.playerUI.AddUIText(playerId, id, defaultValue, callback, data) end


--- Add a label to the clients mod UI
---@param playerId integer
---@param id string | integer | number | boolean
---@param defaultValue string
---@return nil
function tm.playerUI.AddUILabel(playerId, id, defaultValue) end


--- Set the value of a clients ui element
---@param playerId integer
---@param id string | integer | number | boolean
---@param value string
---@return nil
function tm.playerUI.SetUIValue(playerId, id, value) end


--- Remove all UI elements for that player
---@param playerId integer
---@return nil
function tm.playerUI.ClearUI(playerId) end



--#endregion
--------------------- audio ---------------------
--#region

--- Lets you play audio and effect audio
tm.audio = {}


--- Play audio at a position. This is more cost friendly but you can not stop or move the sound
---@param audioName string
---@param position ModVector3
---@param keepObjectDuration number
---@return nil
function tm.audio.PlayAudioAtPosition(audioName, position, keepObjectDuration) end


--- Play audio on a Gameobject
---@param audioName string
---@param modGameObject ModGameObject
---@return nil
function tm.audio.PlayAudioAtGameobject(audioName, modGameObject) end


--- Stop all audio on a Gameobject
---@param modGameObject ModGameObject
---@return nil
function tm.audio.StopAllAudioAtGameobject(modGameObject) end


--- Returns a table of all playable audio names
---@return table
function tm.audio.GetAudioNames() end



--#endregion
--------------------- input ---------------------
--#region

---Keys: "`" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "0" | "-" | "=" | "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z" | "[" | "]" | ";" | "'" | "\\" | "," | "." | "/" | "backspace" | "tab" | "enter" | "left shift" | "right shift" | "left control" | "left alt" | "space" | "right alt" | "right control" | "insert" | "home" | "page up" | "delete" | "end" | "page down" | "up" | "down" | "left" | "right" | "numlock" | "[/]" | "[*]" | "[-]" | "[+]" | "[enter]" | "[,]" | "[1]" | "[2]" | "[3]" | "[4]" | "[5]" | "[6]" | "[7]" | "[8]" | "[9]" | "[0]"
tm.input = {}


--- Registers a function to the callback of when the given player presses the given key
---@param playerId integer
---@param functionName string
---@param keyName string
---@return nil
function tm.input.RegisterFunctionToKeyDownCallback(playerId, functionName, keyName) end


--- Registers a function to the callback of when the given player releases  the given key
---@param playerId integer
---@param functionName string
---@param keyName string
---@return nil
function tm.input.RegisterFunctionToKeyUpCallback(playerId, functionName, keyName) end



--#endregion
--------------------- vector3 ---------------------
--#region

--- For all things vectors, vector3 can store three numbers
tm.vector3 = {}


---@class ModVector3 For all things vectors, vector3 can store three numbers
---@field x number Returns the x value of the vector
---@field y number Returns the y value of the vector
---@field z number Returns the z value of the vector
---@field Equals fun(otherVector: ModVector3): boolean Returns true if both vectors are the same, false if not (can be done with the normal `==` operator)
---@field GetHashCode fun(): integer Returns the hash code of the vector
---@field Dot fun(otherVector: ModVector3): number Returns the dot product of two vector3
---@field Cross fun(otherVector: ModVector3): ModVector3 Returns the cross product of two vector3
---@field Magnitude fun(): number Returns the magnitude/length
---@field ToString fun(): string Returns a formatted string of a vector


--- Creates a vector3 with specified values
---@param x number
---@param y number
---@param z number
---@return ModVector3
function tm.vector3.Create(x, y, z) end


--- Creates a vector3 with values defaulted to zero
---@return ModVector3
function tm.vector3.Create() end


--- Creates a vector3 pointing right. 1,0,0
---@return ModVector3
function tm.vector3.Right() end


--- Creates a vector3 pointing left. -1,0,0
---@return ModVector3
function tm.vector3.Left() end


--- Creates a vector3 pointing up. 0,1,0
---@return ModVector3
function tm.vector3.Up() end


--- Creates a vector3 pointing down. 0,-1,0
---@return ModVector3
function tm.vector3.Down() end


--- Creates a vector3 pointing forward. 0,0,1
---@return ModVector3
function tm.vector3.Forward() end


--- Creates a vector3 pointing back. 0,0,-1
---@return ModVector3
function tm.vector3.Back() end


--- Flips all the signs (can be done with the normal `-` operator)
---@param vector3 ModVector3
---@return ModVector3
function tm.vector3.op_UnaryNegation(vector3) end


--- Adds first and second together (can be done with the normal `+` operator)
---@param first ModVector3
---@param second ModVector3
---@return ModVector3
function tm.vector3.op_Addition(first, second) end


--- Subtracts first and second together (can be done with the normal `-` operator)
---@param first ModVector3
---@param second ModVector3
---@return ModVector3
function tm.vector3.op_Subtraction(first, second) end


--- Multiplies the vector by the scaler
---@param vector3 ModVector3
---@param scaler number
---@return ModVector3
function tm.vector3.op_Multiply(vector3, scaler) end


--- Divides the vector by the divisor
---@param vector3 ModVector3
---@param divisor number
---@return ModVector3
function tm.vector3.op_Division(vector3, divisor) end


--- Returns true if both vectors are the same, false if not (can be done with the normal `==` operator)
---@param first ModVector3
---@param second ModVector3
---@return boolean
function tm.vector3.op_Equality(first, second) end


--- Returns true if both vectors are not the same, false if not (can be done with the normal `~=` operator)
---@param first ModVector3
---@param second ModVector3
---@return boolean
function tm.vector3.op_Inequality(first, second) end



--#endregion
--------------------- quaternion ---------------------
--#region

--- Quaternions are for rotations, they get rid of gimbal lock that a vector3 rotation runs into. Quaternion can store four numbers
tm.quaternion = {}


---@class ModQuaternion Quaternions are for rotations, they get rid of gimbal lock that a vector3 rotation runs into. Quaternion can store four numbers
---@field x number Returns the x value of the quaternion
---@field y number Returns the y value of the quaternion
---@field z number Returns the z value of the quaternion
---@field w number Returns the w value of the quaternion
---@field GetEuler fun(): ModVector3 Returns a vector3 representing the euler angles of the quaternion
---@field Multiply fun(otherQuaternion: ModQuaternion): ModQuaternion Multiplies two quaternions and returns the result


--- Creates a quaternion by manually defining its components
---@param x number
---@param y number
---@param z number
---@param w number
---@return ModQuaternion
function tm.quaternion.Create(x, y, z, w) end


--- Creates a quaternion using euler angle components
---@param x number
---@param y number
---@param z number
---@return ModQuaternion
function tm.quaternion.Create(x, y, z) end


--- Creates a quaternion using a euler angle vector3
---@param eulerAngle ModVector3
---@return ModQuaternion
function tm.quaternion.Create(eulerAngle) end


--- Creates a quaternion using an angle and an axis to rotate around
---@param angle number
---@param axis ModVector3
---@return ModQuaternion
function tm.quaternion.Create(angle, axis) end


--- Returns the resulting quaternion from a slerp between two quaternions
---@param firstQuaternion ModQuaternion
---@param secondQuaternion ModQuaternion
---@param t number Position in the interpolation (0=firstQuaternion, 1=secondQuaternion)
---@return ModQuaternion
function tm.quaternion.Slerp(firstQuaternion, secondQuaternion, t) end



--#endregion
--------------------- Callback Data ---------------------
--#region

---@class CallbackData These are all the things you can get from the argument that ui elements pass in the function you specify
---@field playerId integer Gives you the player that interacted with the element
---@field id integer Gives you the id of the interacted element
---@field type string Gives you the type of the interacted element
---@field value string Gives you the value of the interacted element. Value is the text that is shown on the UI element
---@field data any Gives you the data of the interacted element. You pass in the data when registering the UI element's callback

--- These are all the things you can call on a CallbackData type or variable. Not to be used stand alone
---@type CallbackData
tm.UICallbackData = nil



--#endregion
--------------------- Documentation ---------------------
--#region

-- Gives the unformated documentation
---@return string
function tm.GetDocs() end



--#endregion
--------------------- ModGameObject ---------------------
--#region

---@class ModGameObject These are all the things you can call on a ModGameObject type or variable
---@field Despawn fun(): nil Despawns the object. This can not be done on players
---@field GetTransform fun(): ModTransform Returns the gameObject's transform
---@field SetIsVisible fun(isVisible: boolean): nil Sets visibility of the gameObject
---@field GetIsVisible fun(): boolean Gets the visibility of the gameObject
---@field GetIsRigidbody fun(): boolean Returns true if the gameObject or any of its children are rigidbodies
---@field SetIsStatic fun(isStatic: boolean): nil Sets the gameObject's and its children's rigidbodies to be static or not
---@field GetIsStatic fun(): boolean Returns true if the gameObject and all of its children are static
---@field SetIsTrigger fun(isTrigger: boolean): nil Determines whether the gameObject lets other gameobjects pass through its colliders or not
---@field Exists fun(): boolean Returns true if the gameObject exists



--#endregion
--------------------- ModTransform ---------------------
--#region

---@class ModTransform These are all the things you can call on a ModTransform type or variable
---@field SetPosition (fun(position: ModVector3): nil) | (fun(x: number, y: number, z: number): nil) Sets the position of the transform
---@field GetPosition fun(): ModVector3 Gets the position of the transform
---@field SetRotation (fun(rotation: ModVector3): nil) | (fun(x: number, y: number, z: number): nil) | (fun(rotation: ModQuaternion): nil) Sets the rotation of the transform
---@field GetRotation fun(): ModVector3 Gets the rotation of the transform
---@field GetRotationQuaternion fun(): ModQuaternion Gets the rotation quaternion of the transform
---@field SetScale (fun(scaleVector: ModVector3): nil) | (fun(x: number, y: number, z: number): nil) | (fun(scale: number): nil) Sets the scale of the transform. Setting a non-uniform scale may, among other things, break the objects physics
---@field GetScale fun(): ModVector3 Gets the scale of the transform
---@field TransformPoint fun(point: ModVector3): ModVector3 Returns the points position in world space (Adds the current pos with input vector)
---@field TransformDirection fun(direction: ModVector3): ModVector3 Returns the directions world space direction



--#endregion
--------------------- ModBlock ---------------------
--#region

---@class ModBlock These are all the things you can call on a ModBlock type or variable
---@field SetColor fun(r: number, g: number, b: number): nil [In buildmode only] Set the block's primary color
---@field SetSecondaryColor fun(r: number, g: number, b: number): nil [In buildmode only] Set the block's secondary color
---@field SetMass fun(mass: number): nil [In buildmode only] Set the block's mass
---@field GetMass fun(): number Get the block's mass
---@field SetBuoyancy fun(mass: number): nil [In buildmode only] Set the block's buoyancy
---@field GetBuoyancy fun(): number Get the block's buoyancy
---@field SetHealth fun(hp: number): nil Set the block's health
---@field GetStartHealth fun(): number Get the block's start health
---@field GetCurrentHealth fun(): number Get the block's health
---@field GetName fun(): string Get the name of the block's type
---@field SetDragAll fun(f: number, b: number, u: number, d: number, l: number, r: number): nil Set the drag value in all directions, front, back, up, down, left, right
---@field AddForce fun(x: number, y: number, z: number): nil Add a force to the given block as an impulse
---@field AddTorque fun(x: number, y: number, z: number): nil Add a torque to the given block as an impulse
---@field SetEnginePower fun(power: number): nil Sets Engine power (only works on engine blocks)
---@field GetEnginePower fun(): number Gets Engine power (only works on engine blocks)
---@field SetJetPower fun(power: number): nil Sets Jet power (only works on jet blocks)
---@field GetJetPower fun(): number Gets jet power (only works on jet blocks)
---@field Exists fun(): boolean Returns true if the block exists. Keep in mind that when you repair your structure, your destroyed blocks will be replaced with different ones, making the old ones useless



--#endregion
--------------------- ModStructure ---------------------
--#region

---@class ModStructure These are all the things you can call on a ModStructure type or variable
---@field Destroy fun(): nil Destroy the structure
---@field GetBlocks fun(): table Gets all blocks in structure
---@field AddForce fun(x: number, y: number, z: number): nil Add a force to the given structure as an impulse



--#endregion