Config = {}

Config.NewESX = false -- If you're using the latest version of ESX enable this

Config.DispenseDict = {"mini@sprunk", "plyr_buy_drink_pt1"}
Config.PocketAnims = {"mp_common_miss", "put_away_coke"}

Config.Machines = {
	{
		model = `prop_vend_soda_01`, -- Model name
		item = "ecola", -- Database item name
		name = "E-Cola", -- Friendly display name
		prop = "prop_ecola_can", -- Prop to spawn falling in machine
		price = 1 -- Purchase price
	},
	{
		model = `prop_vend_soda_02`, 
		item = "sprunk",
		name = "Sprunk",
		prop = "prop_ld_can_01",
		price = 1
	},
	{
		model = `prop_vend_snak_01`,
		item = "p&qs",
		name = "Ps & Qs",
		prop = "prop_candy_pqs",
		price = 3
	},
	{
		model = `weed_vending`,
		item = "marijuana",
		name = "Weed",
		prop = "prop_weed_bottle",
		price = 100
	}
}