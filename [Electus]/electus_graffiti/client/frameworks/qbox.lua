if (Config.Framework ~= "qbx") and (Config.Framework ~= "auto" or GetResourceState("qbx_core") ~= "started") then
	return
end

PlayerData = {}

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
	LoadPlayer()
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate", function()
	TriggerEvent("electus_gangs:zonesUpdated")
end)

function GetJobName()
	local job = QBX.PlayerData.job.name or ""

	return job
end

function GetIdentifier()
	local identifier = QBX.PlayerData.citizenid

	return identifier
end
