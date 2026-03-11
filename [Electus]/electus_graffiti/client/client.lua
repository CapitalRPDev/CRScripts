function ToggleNuiFrame(shouldShow)
	SetNuiFocus(shouldShow, shouldShow)
	SendReactMessage("setVisible", shouldShow)
end

function ToggleVisibility(shouldShow)
	SendReactMessage("setVisible", shouldShow)
end

RegisterCommand("show-nui", function()
	ToggleNuiFrame(true)
end)

RegisterNUICallback("hideFrame", function(_, cb)
	ToggleNuiFrame(false)
	cb({})
end)

RegisterCommand("close", function()
	ToggleNuiFrame(false)
end)

CreateThread(function()
	Wait(1000)
	if Config.IntegrateElectusGangs then
		if GetResourceState("electus_gangs") ~= "started" then
			print("Please start electus_gangs before using electus_graffiti")
		else
			exports["electus_gangs"]:LoadExtension("graffiti")
		end
	end
end)

function IsDead()
	return IsPedDeadOrDying(PlayerPedId()) or IsEntityDead(PlayerPedId())
end
