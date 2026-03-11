RegisterNUICallback("getCreations", function(data, cb)
	local creations = lib.callback.await("electus_graffiti:getGraffities", false)
	cb(creations)
end)

RegisterNUICallback("createNewGraffiti", function(data, cb)
	local url = data.imageUrl
	local width = data.width
	local height = data.height

	local success = lib.callback.await("electus_graffiti:createNewGraffiti", false, url, width, height)
	if success then
		cb({ success = true })
	else
		cb({ success = false, error = "Failed to create graffiti" })
	end
end)

RegisterNUICallback("deleteCreation", function(data, cb)
	local id = data.id

	local success = lib.callback.await("electus_graffiti:deleteCreation", false, id)

	cb(success)
end)

RegisterNUICallback("getShareLink", function(data, cb)
	local id = data.id
	local link = lib.callback.await("electus_graffiti:getShareLink", false, id)

	cb(link)
end)

RegisterNUICallback("importImage", function(data, cb)
	local sharelink = data.shareLink
	local success = lib.callback.await("electus_graffiti:importImage", false, sharelink)

	cb(success)
end)

RegisterNUICallback("doesLinkExist", function(data, cb)
	local url = data.url
	local exists = lib.callback.await("electus_graffiti:doesLinkExist", false, url)

	cb(exists)
end)

RegisterNUICallback("canCreateNewGraffiti", function(data, cb)
	local numGraffities = lib.callback.await("electus_graffiti:getNumGraffities", false)
	cb(numGraffities < Config.MaxGraffities)
end)
