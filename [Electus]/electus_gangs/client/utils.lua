function SendReactMessage(action, data)
	if InTablet then
		exports["lb-tablet"]:SendCustomAppMessage("electus_gangs", action, data)
	else
		SendNUIMessage({
			action = action,
			data = data,
		})
	end
end

function Notify(text, type)
	lib.notify({
		title = L("gangs"),
		description = text,
		type = type,
	})
end

local ray
local rayFlag = 1 | 16 | 32 | 64 | 128 | 256
local lastWorldCoords = vector3(0.0, 0.0, 0.0)
local lastSurfaceNormal = vector3(0.0, 0.0, 0.0)
local depth = 75

function GetWorldCoordsFromScreen()
	if not ray then
		local world, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
		local targetCoords = world + normal * depth

		ray = StartShapeTestLosProbe(
			world.x,
			world.y,
			world.z,
			targetCoords.x,
			targetCoords.y,
			targetCoords.z,
			rayFlag,
			PlayerPedId(),
			7
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

local loadedBlips = {}

function MarkerBlip(zoneId, id, coords, sprite, color, scale, label, enable)
	if not enable then
		return
	end

	if loadedBlips[id] then
		RemoveBlip(loadedBlips[id].blip)
	end

	local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

	SetBlipSprite(blip, sprite)
	SetBlipColour(blip, color)
	SetBlipScale(blip, scale)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(label)
	EndTextCommandSetBlipName(blip)

	loadedBlips[id] = { blip = blip, zoneId = zoneId }
end

function RemoveMarkerBlips(zoneId)
	for id, blip in pairs(loadedBlips) do
		if blip.zoneId == zoneId then
			RemoveBlip(blip.blip)
			loadedBlips[id] = nil
		end
	end
end

function EnableHelpText(msg, icon)
	lib.showTextUI(msg, {
		icon = icon,
		style = {
			borderRadius = 10,
			backgroundColor = "#111111",
			color = "#ffffff",
			whiteSpace = "pre-line",
		},
	})
end

function IsHelpTextOpen()
	return lib.isTextUIOpen()
end

function DisableHelpText()
	lib.hideTextUI()
end

function IsTextUIOpen()
	return lib.isTextUIOpen()
end

function GetHelpText()
	local isOpen, currentText = IsTextUIOpen()

	if isOpen then
		return currentText
	end
end

function LoadDict(dict)
	RequestAnimDict(dict)
	local timeout = GetGameTimer() + 5000

	while GetGameTimer() < timeout do
		if HasAnimDictLoaded(dict) then
			break
		end

		Wait(0)
	end

	return dict
end

function LoadModel(model)
	RequestModel(model)
	local timeout = GetGameTimer() + 5000

	while GetGameTimer() < timeout do
		if HasModelLoaded(model) then
			break
		end

		Wait(0)
	end

	return model
end
---@param sceneId number
---@return boolean started
function WaitForSceneToStart(sceneId)
	local timeout = GetGameTimer() + 5000

	while GetGameTimer() < timeout do
		local localScene = NetworkGetLocalSceneFromNetworkId(sceneId)

		if IsSynchronizedSceneRunning(localScene) then
			return true
		end

		Wait(0)
	end

	return false
end

---Wait for a scene to finish or reach a specific phase
---@param sceneId number
---@param phase? number
---@return boolean success
function WaitForScene(sceneId, phase)
	phase = math.max(math.min(phase or 1.0, 1.0), 0.0)

	WaitForSceneToStart(sceneId)

	local localScene = NetworkGetLocalSceneFromNetworkId(sceneId)

	while IsSynchronizedSceneRunning(localScene) do
		Wait(0)

		if GetSynchronizedScenePhase(localScene) >= phase then
			return true
		end
	end

	return false
end

function WaitForNetIdToExist(netId)
	local timeout = GetGameTimer() + 5000

	while not NetworkDoesNetworkIdExist(netId) do
		Wait(250)

		if GetGameTimer() > timeout then
			debugprint("Timed out waiting for ped to be valid")
			return
		end
	end

	return NetworkGetEntityFromNetworkId(netId)
end

---@param bagName string
---@return number? entity
function GetEntityDataFromStateBag(bagName)
	local netId = tonumber(bagName:match("entity:(%d+)"))

	if not netId then
		return
	end

	return WaitForNetIdToExist(netId)
end
