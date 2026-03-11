local extensions = {
	bodyguards = false,
	graffiti = false,
}

local zoneTypes = {}

function LoadExtension(extension)
	extensions[extension] = true
end

function InitZoneType(name, label, description)
	zoneTypes[#zoneTypes + 1] = {
		name = name,
		label = label,
		description = description,
	}
end

RegisterNuiCallback("get_extensions", function(data, cb)
	cb(extensions)
end)

RegisterNuiCallback("get_extended_zone_types", function(data, cb)
	cb(zoneTypes)
end)

exports("LoadExtension", LoadExtension)
exports("InitZoneType", InitZoneType)
