if Config.Framework ~= "esx" and (Config.Framework ~= "auto" or GetResourceState("es_extended") ~= "started") then
	return
end

PlayerData = {}

export, ESX = pcall(function()
	return exports.es_extended:getSharedObject()
end)

if not export then
	TriggerEvent("esx:getSharedObject", function(obj)
		ESX = obj
	end)
end

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(xPlayer, isNew, skin)
	PlayerData = xPlayer
	LoadPlayer()
end)

function MenuClose()
	ESX.UI.Menu.CloseAll()
end

function GetJobName()
	local job = ESX.GetPlayerData().job.name

	return job
end

function GetIdentifier()
	local identifier = ESX.GetPlayerData().identifier

	return identifier
end

function DisableHelpText()
	lib.hideTextUI()
end
