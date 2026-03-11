lib.callback.register("electus_graffiti:getFivemanageUrl", function(source, cb)
	local apiKey = Config.ApiKey

	local p = promise:new()

	PerformHttpRequest("https://fmapi.net/api/v2/presigned-url?fileType=image", function(err, text, headers)
		p:resolve(text)
	end, "GET", "", { ["User-Agent"] = "electus_graffiti", ["Authorization"] = apiKey })

	local ret = Citizen.Await(p)

	return json.decode(ret)?.data?.presignedUrl
end)

lib.callback.register("electus_graffiti:getWebBaseUrl", function(src)
	local baseUrl = ("https://%s"):format(GetConvar("web_baseUrl", ""))

	return baseUrl
end)

lib.callback.register("electus_graffiti:hasItem", function(src, item)
	return GetInventoryCount(src, item) > 0
end)

lib.callback.register("electus_graffiti:getApiKey", function(src)
	if Config.UploadService == "lb-upload" then
		return Config.ApiKey
	else
		return false
	end
end)
