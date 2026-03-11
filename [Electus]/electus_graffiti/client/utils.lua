function SendReactMessage(action, data)
	SendNUIMessage({
		action = action,
		data = data,
	})
end

function HelpText(msg)
	lib.showTextUI(msg, {
		style = {
			borderRadius = 10,
			backgroundColor = "#111111",
			color = "#ffffff",
			whiteSpace = "pre-line",
		},
	})
end

function DisableHelpText()
	lib.hideTextUI()
end

function Notify(text, type)
	lib.notify({
		title = L("graffiti"),
		description = text,
		type = type,
	})
end

local currentResourceName = GetCurrentResourceName()

local debugIsEnabled = GetConvarInt(("%s-debugMode"):format(currentResourceName), 0) == 1

function debugPrint(...)
	if not debugIsEnabled then
		return
	end
	local args <const> = { ... }

	local appendStr = ""
	for _, v in ipairs(args) do
		appendStr = appendStr .. " " .. tostring(v)
	end
	local msgTemplate = "^3[%s]^0%s"
	local finalMsg = msgTemplate:format(currentResourceName, appendStr)
	print(finalMsg)
end

local ray
local rayFlag = 1 | 16 | 32 | 64 | 128 | 256 | 2
local lastWorldCoords = vector3(0.0, 0.0, 0.0)
local lastSurfaceNormal = vector3(0.0, 0.0, 0.0)
local depth = 75

function GetWorldCoordsFromScreen()
	local camPos = GetGameplayCamCoord()
	local camRot = GetGameplayCamRot(2)
	local direction = RotToDir(camRot)
	local destination = camPos + direction * 25.0 -- Raycast distance

	if not ray then
		ray = StartShapeTestLosProbe(
			camPos.x,
			camPos.y,
			camPos.z,
			destination.x,
			destination.y,
			destination.z,
			1,
			PlayerPedId(),
			0
		)
	end

	local retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(ray)

	if retval ~= 1 then
		if endCoords ~= vector3(0.0, 0.0, 0.0) then
			lastWorldCoords = endCoords
			lastSurfaceNormal = surfaceNormal
		end

		ray = nil
	end

	return lastWorldCoords, lastSurfaceNormal
end

function GetWorldCoordsAndMaterialFromScreen()
	local camCoords = GetFinalRenderedCamCoord()
	local rot = GetFinalRenderedCamRot(2)
	local dir = RotToDir(rot)
	local endPoint = camCoords + dir * 75
	local raycast = StartExpensiveSynchronousShapeTestLosProbe(
		camCoords.x,
		camCoords.y,
		camCoords.z,
		endPoint.x,
		endPoint.y,
		endPoint.z,
		1,
		PlayerPedId(),
		4
	)
	local result, hit, coords, surfaceNormal, material = GetShapeTestResultIncludingMaterial(raycast)

	return coords, surfaceNormal, material
end

function RotToDir(rot)
	return vector3(
		-math.sin((math.pi / 180) * rot.z) * math.abs(math.cos((math.pi / 180) * rot.x)),
		math.cos((math.pi / 180) * rot.z) * math.abs(math.cos((math.pi / 180) * rot.x)),
		math.sin((math.pi / 180) * rot.x)
	)
end

function ReloadAndCloseUI()
	SendReactMessage("updateComponent", {
		component = "",
	})
	ToggleNuiFrame(false)
end

RegisterNUICallback("getConfig", function(data, cb)
	if not Config.WebBaseUrl then
		Config.WebBaseUrl = lib.callback.await("electus_graffiti:getWebBaseUrl", false)
	end

	if Config.ApiKey == nil and Config.UploadService == "lb-upload" then
		Config.ApiKey = lib.callback.await("electus_graffiti:getApiKey", false)
	end

	cb({ Config = Config, translation = GetAllLocales() })
end)

function SendMessageToUI(action, data)
	SendNUIMessage({
		action = action,
		data = data,
	})
end

local promiseId = 0
local promises = {}

function AwaitNUIMessage(action, data)
	promiseId += 1
	promises[promiseId] = promise.new()

	SendMessageToUI("await", {
		id = promiseId,
		action = action,
		data = data,
	})

	return Citizen.Await(promises[promiseId])
end

RegisterNUICallback("nuiMessageFinished", function(data, cb)
	if promises[data.id] then
		promises[data.id]:resolve(data.data)
	end

	cb("ok")
end)
