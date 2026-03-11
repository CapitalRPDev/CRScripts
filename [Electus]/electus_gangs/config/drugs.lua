Config.Drugs = {
	enableDrugDealing = true,
	onlyGangMembersCanSellDrugs = false, -- only gang members can sell drugs
	minPolice = 0, -- minimum amount of police required to sell drugs (0 = disabled)
	dirtyCashOnSelling = true,
	progressPerDrug = 1, -- amount of progress added to drug capture per sold drug
	givenWeedBagAmount = { min = 1, max = 5 }, -- min and max amount of weed bags that are given when processing weed
	acceptedDrugs = {
		{ item = "weed_bag", label = "Weed", targetPrice = 50 },
	},
	drugSellAcceptPercentage = function(reqPrice, targetPrice) -- do not touch this function if you don't know what you are doing
		local k = 0.025 -- lower k = higher acceptance of higher prices
		local e = 2.71828
		return 100 * e ^ (-k * (reqPrice - targetPrice))
	end,
	xpGainOnDrugSell = 5, -- xp gained on selling drugs
	maxDrugSellAmount = 5, -- max amount of weed bags that can be sold at once
	onlySellInsideOwnedZone = false, -- only allow selling drugs inside owned zones
	drugSellDialog = {
		-- make sure the sum of all percentages is 1.0 or do not touch it
		sell = {
			{ percent = 0.25, value = "interested" },
			{ percent = 0.25, value = "no", exit = true },
			{ percent = 0.25, value = "callingCops", exit = true },
			{ percent = 0.25, value = "gangControl", exit = true },
		},
		amount = {
			{ percent = 1.0, value = "yes" },
			{ percent = 0.0, value = "highPrice", exit = true },
		},
		priceCheck = {
			{ percent = 1.0, value = "interested" },
			{ percent = 0.0, value = "notInterested", exit = true },
		},
	},
}
