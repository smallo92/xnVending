**xnVending**

This adds workable vending machines around the map for ESX, walk up to any vending machine that is configured in the `config.lua` and press `E` to purchase. Included in this release is a bonus vending machine model I made which is a weed vending machine, currently it is not placed anywhere on the map, you must do that yourself. I won't be telling you how, it's easy enough to google how to add custom things to the map.

**Installation**

Copy xnVending to your resources folder and add `start xnVending` to your server.cfg\

**Config**

In the config are the animations for the vending machine (audio is part of the animation, so I wouldn't recommend changing it) `Config.DispenseDict`

There is also the animations for putting the item in the users pocket, there is probably a better one somewhere `Config.PocketAnims`

Last thing is the config for the vending machines and the items here is an example;

```lua
{
	model = `prop_vend_soda_01`, -- Model name
	item = "ecola", -- Database item name
	name = "E-Cola", -- Friendly display name
	prop = "prop_ecola_can", -- Prop to spawn falling in machine
	price = 1 -- Purchase price
},
```

It's pretty self explanatory. No coordinates need to be added for vending machines as it uses a searching native to find the closest model of type. So this will work for any new types you have on your server without any configuration.

**Dependencies**

Obviously this needs `ESX`

**Videos**

[Normal Vending Machine Showoff](https://www.youtube.com/watch?v=dvQYazR44Vo)

[Weed Vending Machine Showoff](https://img.xpl.wtf/s/hpBOrnr.mp4)

Note: Weed effects aren't included in this mod