-- Police alerts
local policeAlerts = {}

function AlertPolice(id, coords, label, message, code)
	if not label then
		label = L("dispatch.label")
	end
	if not message then
		message = L("dispatch.drug_deal")
	end
	if not code then
		code = L("dispatch.brevity_code")
	end

	policeAlerts[#policeAlerts + 1] = { id = id, coords = coords }

	if GetResourceState("qs-dispatch") == "started" then
		TriggerEvent("qs-dispatch:server:CreateDispatchCall", {
			job = Config.PoliceJobs,
			callLocation = coords,
			callCode = {
				code = label,
				snippet = code,
			},
			message = message,
			flashes = true,
			image = nil,
			blip = {
				sprite = 108,
				scale = 1.5,
				colour = 1,
				flashes = true,
				text = label,
				time = 5 * 60 * 1000,
			},
		})
	elseif GetResourceState("ps-dispatch") == "started" then
		TriggerEvent("ps-dispatch:server:notify", {
			message = message,
			codeName = label,
			code = code,
			icon = "fas fa-person-rifle",
			priority = 1,
			coords = coords,
			jobs = Config.PoliceJobs,
			-- blip
			sprite = 108,
			color = 32,
			scale = 1.5,
			length = 3,
		})
	elseif GetResourceState("cd_dispatch") == "started" then
		TriggerClientEvent("cd_dispatch:AddNotification", -1, {
			job_table = Config.PoliceJobs,
			coords = coords,
			title = label,
			message = message,
			flash = 0,
			unique_id = tostring(math.random(0000000, 9999999)),
			sound = 1,
			blip = {
				sprite = 108,
				scale = 1.5,
				colour = 1,
				flashes = false,
				text = label,
				time = 5,
				radius = 0,
			},
		})
	elseif GetResourceState("origen_police") == "started" then
		exports["origen_police"]:SendAlert({
			coords = coords,
			title = label,
			type = "GENERAL",
			message = message,
			job = "police",
		})
	elseif GetResourceState("lb-tablet") == "started" then
		exports["lb-tablet"]:AddDispatch({
			title = label,
			location = { label = "Unkown", coords = coords },
			time = 300,
			priority = "medium",
			description = message,
			job = "police",
			code = code,
		})
	else
		TriggerClientEvent("electus_graffiti:alertPolice", -1, id, coords, label, message, code)
	end
end

RegisterNetEvent("electus_graffiti:removePoliceAlert", function(id)
	for i = 1, #policeAlerts do
		if policeAlerts[i].id == id then
			table.remove(policeAlerts, i)
			break
		end
	end

	TriggerClientEvent("electus_graffiti:removePoliceAlert", -1, id)
end)

RegisterNetEvent("electus_graffiti:getPoliceAlerts", function()
	local src = source
	for i = 1, #policeAlerts do
		TriggerClientEvent(
			"electus_graffiti:alertPolice",
			src,
			policeAlerts[i].coords,
			policeAlerts[i].label,
			policeAlerts[i].message,
			policeAlerts[i].code
		)
	end
end)

RegisterNetEvent("electus_graffiti:callCops", function(coords, label, message, code)
	local id = tostring(math.random(0000000, 9999999))
	AlertPolice(id, coords, label, message, code)
	CreateThread(function()
		Wait(5 * 60 * 1000)
		TriggerEvent("electus_graffiti:removePoliceAlert", id)
	end)
end)
