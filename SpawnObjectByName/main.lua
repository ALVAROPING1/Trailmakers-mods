
function update()

    playerList = tm.players.CurrentPlayers()

    for key,player in pairs(playerList) do

        pos = tm.players.GetPlayerTransform(player.playerId).GetPosition()

    end

end



function addUiForPlayer(playerId)

    tm.playerUI.AddUIText(playerId, "setSpawnName", "", onSetSpawnNameTxt)

    tm.playerUI.AddUIButton(playerId, "Spawn", "Spawn", spawn, nil)


    tm.playerUI.AddUIButton(playerId, "cleanup", "Cleanup spawns ", onCleanupSpawns, nil)

end



function onSetSpawnNameTxt(callbackData)    

    spawnName = callbackData.value

end


function spawn(callbackData)

    local pos = tm.players.GetPlayerTransform(callbackData.playerId).GetPosition()

    tm.physics.SpawnObject(tm.vector3.Create(pos.x+10, pos.y+5, pos.z ), spawnName)

end


function onCleanupSpawns(callbackData)    

    tm.physics.ClearAllSpawns()

end



function onPlayerJoined(player)

    tm.os.Log("player joined")

	addUiForPlayer(player.playerId)

end

tm.players.OnPlayerJoined.add(onPlayerJoined)