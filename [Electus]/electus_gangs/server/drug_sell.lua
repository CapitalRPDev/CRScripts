local validatePrices = {}

RegisterServerCallback("electus_gangs:confirmPrice", function(src, selectedDrug, requestedPrice)
	local gangId = GetPlayerGangId(src)
	local upgrade = GetUpgradeItemFromConfig(gangId, "drugSell")
	local addedMaxRoof = 0

	addedMaxRoof = upgrade.percentage

	local drug = nil

	for i = 1, #Config.Drugs.acceptedDrugs do
		if Config.Drugs.acceptedDrugs[i].item == selectedDrug.item then
			drug = Config.Drugs.acceptedDrugs[i]
			break
		end
	end

	if not drug then
		return false
	end

	local targetPrice = drug.targetPrice + (addedMaxRoof * drug.targetPrice)
	local percentage = Config.Drugs.drugSellAcceptPercentage(requestedPrice, targetPrice)
	local random = math.random(1, 100)

	if random <= math.floor(percentage) then
		validatePrices[src] = requestedPrice
		return true
	end

	return false
end)

RegisterServerCallback("electus_gangs:sellDrug", function(src, zoneId, selectedDrug, price, amount)
	local player = GetPlayer(src)
	local drug = nil

	for i = 1, #Config.Drugs.acceptedDrugs do
		if Config.Drugs.acceptedDrugs[i].item == selectedDrug.item then
			drug = Config.Drugs.acceptedDrugs[i]
			break
		end
	end

	if not drug then
		return Notify(src, L("drug_not_accepted"), "error")
	end

	local itemCount = GetItemCountTemp(src, drug.item)

	if itemCount < amount then
		return Notify(src, L("not_enough_drugs"), "error")
	end

	if not validatePrices[src] or validatePrices[src] ~= price then
		return Notify(src, L("price_not_accepted"), "error")
	end

	validatePrices[src] = nil

	local money = price * amount
	local gangId = GetPlayerGangId(src)

	RemoveItemTemp(src, drug.item, amount)

	if Config.Drugs.dirtyCashOnSelling then
		AddDirtyMoney(player, money)
	else
		AddCashMoney(player, money)
	end

	ChangeGangRep(gangId, Config.GangReputation.sellDrugs)
	AddProgressToCapture("drugCapture", zoneId, gangId, amount * Config.Drugs.progressPerDrug)

	local zoneOwner = GetGangFromZoneId(zoneId)

	if Config.Capturing.war.points.drugSelling and gangId and zoneOwner and zoneOwner.gangId then
		AddWarProgress(gangId, zoneOwner.gangId, Config.Capturing.war.points.drugSelling)
	end

	GainXP(gangId, Config.Drugs.xpGainOnDrugSell)

	CheckWeeklyTask(gangId, "sell_drugs", amount)

	AdminLog(
		src,
		"info",
		L("sold_drug", {
			["amount"] = amount,
			["price"] = money,
			["currency"] = L("currency"),
		}),
		{
			["amount"] = amount,
			["price"] = money,
			["currency"] = L("currency"),
		}
	)

	Notify(
		src,
		L("sold_drug", {
			["amount"] = amount,
			["price"] = money,
			["currency"] = L("currency"),
		}),
		"success"
	)

	CreateLogEvent(
		gangId,
		L("drug_sell"),
		L("sold_drug", {
			["amount"] = amount,
			["price"] = money,
			["currency"] = L("currency"),
		})
	)
	TriggerEvent("electus_gangs:soldDrug", zoneId, gangId, amount, selectedDrug)

	return true
end)

RegisterServerCallback("electus_gangs:getPlayerDrugs", function(src)
	local retDrugs = {}
	local player = GetPlayer(src)

	for i = 1, #Config.Drugs.acceptedDrugs do
		local drug = Config.Drugs.acceptedDrugs[i]
		local itemCount = GetItemCountTemp(src, drug.item)

		if itemCount > 0 then
			retDrugs[#retDrugs + 1] = {
				item = drug.item,
				label = drug.label,
				count = itemCount,
				maxAmount = drug.maxAmount,
			}
		end
	end

	return retDrugs
end)

RegisterServerCallback("electus_gangs:getOnlinePoliceCount", function()
	return GetPoliceJobCount()
end)
