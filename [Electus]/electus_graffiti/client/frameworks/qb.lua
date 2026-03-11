if (Config.Framework ~= "qb") and (Config.Framework ~= "auto" or GetResourceState("qb-core") ~= "started") then
	return
end

QBCore = nil
PlayerData = {}

QBCore = exports["qb-core"]:GetCoreObject()

function MenuClose()
	QBCore.UI.Menu.CloseAll()
end

PlayerData = QBCore.Functions.GetPlayerData()

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
	LoadPlayer()
end)

function GetJobName()
	local job = QBCore.Functions.GetPlayerData().job.name

	return job
end

function GetIdentifier()
	local identifier = QBCore.Functions.GetPlayerData().citizenid

	return identifier
end
