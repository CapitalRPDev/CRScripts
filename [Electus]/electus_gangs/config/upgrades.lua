Config.Upgrades = {
	{
		type = "garage",
		desc = "Increase the amount of vehicles you can store",
		upgrades = {
			{ requiresLevel = 0, price = 0, amount = 2 },
			{ requiresLevel = 5, price = 2000, amount = 5 },
			{ requiresLevel = 10, price = 3000, amount = 10 },
			{ requiresLevel = 20, price = 5000, amount = 20 },
		},
	},
	{
		type = "storageBoxes",
		desc = "Increase the amount of storage boxes in your warehouse",
		upgrades = {
			{ requiresLevel = 0, price = 0, amount = 1 },
			{ requiresLevel = 5, price = 2000, amount = 2 },
			{ requiresLevel = 10, price = 3000, amount = 3 },
			{ requiresLevel = 20, price = 5000, amount = 4 },
			{ requiresLevel = 25, price = 8000, amount = 5 },
			{ requiresLevel = 30, price = 10000, amount = 6 },
		},
	},
	{
		type = "weedGrowth",
		desc = "Increase the growth of your weed plants",
		upgrades = {
			{ requiresLevel = 0, price = 0, percentage = 0.0 },
			{ requiresLevel = 5, price = 2000, percentage = 0.25 },
			{ requiresLevel = 10, price = 3000, percentage = 0.5 },
			{ requiresLevel = 20, price = 5000, percentage = 0.75 },
		},
	},
	{
		type = "drugSell",
		desc = "Increase the max selling price of your drugs",
		upgrades = {
			{ requiresLevel = 1, price = 0, percentage = 0.0 },
			{ requiresLevel = 10, price = 2000, percentage = 0.25 },
			{ requiresLevel = 25, price = 3000, percentage = 0.5 },
			{ requiresLevel = 50, price = 5000, percentage = 0.75 },
		},
	},
	{
		type = "moneyLaundering",
		desc = "Increase the efficiency of your money laundring",
		upgrades = {
			{ requiresLevel = 15, price = 0, percentage = 0.0 },
			{ requiresLevel = 20, price = 2000, percentage = 0.25 },
			{ requiresLevel = 30, price = 3000, percentage = 0.5 },
			{ requiresLevel = 40, price = 5000, percentage = 0.75 },
		},
	},
}
