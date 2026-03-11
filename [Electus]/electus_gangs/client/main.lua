-- Loading framework
while not FrameworkLoaded do
	Wait(100)
end

while not OnPlayerLoad do
	Wait(100)
end

TriggerEvent("electus_gangs:updateNextCaptureZones")

TriggerEvent("electus_gangs:playerLoaded")

OnPlayerLoad()
LoadZones()

RegisterNetEvent("electus_gangs:jobUpdated", function()
	TriggerEvent("electus_gangs:zonesUpdated")
end)
