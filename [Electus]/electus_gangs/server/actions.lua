RegisterNetEvent("electus_gangs:cuffPlayer", function(playerId)
	Entity(GetPlayerPed(playerId)).state:set("tied", true, true)
	local src = source

	TriggerClientEvent("electus_gangs:getCuffed", playerId, src)
end)

RegisterNetEvent("electus_gangs:uncuffPlayer", function(playerId)
	Entity(GetPlayerPed(playerId)).state:set("tied", false, true)
	local src = source

	-- TriggerClientEvent("electus_gangs:getUncuffed", playerId)
end)

RegisterNetEvent("electus_gangs:escortPlayer", function(playerId)
	local src = source

	TriggerClientEvent("electus_gangs:getEscorted", playerId, src)
end)

RegisterNetEvent("electus_gangs:taskLeaveVehicle", function(vehNet, seatIndex)
	local src = source
	local veh = NetworkGetEntityFromNetworkId(vehNet)
	local ped = GetPedInVehicleSeat(veh, seatIndex)

	if Entity(ped).state.escortedIntoVehicle then
		TaskLeaveVehicle(ped, veh, 0)
		Entity(ped).state:set("escortedIntoVehicle", false, true)
	end
end)

RegisterNetEvent("electus_gangs:warpPlayerIntoVehicle", function(vehNet, playerId, seat)
	local src = source
	local ped = GetPlayerPed(src)
	local pedCoords = GetEntityCoords(ped)
	local targetPed = GetPlayerPed(playerId)
	local targetCoords = GetEntityCoords(targetPed)
	local veh = NetworkGetEntityFromNetworkId(vehNet)

	if #(pedCoords - targetCoords) < 5.0 then
		Entity(targetPed).state:set("escortedIntoVehicle", true, true)
		Entity(targetPed).state:set("escorted", false, true)
		TaskWarpPedIntoVehicle(targetPed, veh, seat)
	end
end)

RegisterServerCallback("electus_gangs:searchPlayer", function(src, playerId)
	local srcPed = GetPlayerPed(src)
	local targetPed = GetPlayerPed(playerId)
	local targetCoords = GetEntityCoords(targetPed)
	local srcCoords = GetEntityCoords(srcPed)

	if #(srcCoords - targetCoords) < 5.0 then
		return SearchPlayer(src, playerId)
	else
		return false
	end
end)

RegisterServerCallback("electus_gangs:stopEscortPlayer", function(src, playerNet)
	Entity(GetPlayerPed(src)).state:set("escorting", false, true)
	Entity(NetworkGetEntityFromNetworkId(playerNet)).state:set("escorted", false, true)
end)

RegisterServerCallback("electus_gangs:escortPlayer", function(src, playerId)
	Entity(GetPlayerPed(src)).state:set("escorting", true, true)
	Entity(GetPlayerPed(playerId)).state:set("escorted", true, true)
end)

RegisterServerCallback("electus_gangs:placeHeadbag", function(src, playerId)
	local srcPed = GetPlayerPed(src)
	local targetPed = GetPlayerPed(playerId)
	local targetCoords = GetEntityCoords(targetPed)
	local srcCoords = GetEntityCoords(srcPed)

	if #(srcCoords - targetCoords) < 5.0 and Entity(targetPed).state.tied then
		Entity(targetPed).state:set("headbag", true, true)
	else
		return false
	end
end)

RegisterServerCallback("electus_gangs:createHeadBag", function(src)
	local ped = GetPlayerPed(src)
	local coords = GetEntityCoords(ped)
	local headBag = CreateObject(GetHashKey("prop_money_bag_01"), coords.x, coords.y, coords.z, true, true, true)

	while not DoesEntityExist(headBag) do
		Wait(0)
	end

	return NetworkGetNetworkIdFromEntity(headBag)
end)

RegisterNetEvent("electus_gangs:removeHeadBag", function(playerId)
	Entity(GetPlayerPed(playerId)).state:set("headbag", false, true)
end)

RegisterNetEvent("electus_gangs:removeHeadbagObject", function(objNet)
	local obj = NetworkGetEntityFromNetworkId(objNet)

	if DoesEntityExist(obj) then
		DeleteEntity(obj)
	end
end)
