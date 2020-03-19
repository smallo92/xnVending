ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_vending:checkMoneyandInvent', function(source, cb, item)
	local plySource = source
	local thisItem = item
	local thisCost = nil
	local thisName = nil
	local xPlayer = ESX.GetPlayerFromId(plySource)
	local cashMoney = xPlayer.getMoney()
	local targetItem = xPlayer.getInventoryItem(thisItem)
	
	for _, machine in ipairs(Config.Machines) do
		if machine.item == thisItem then
			thisCost = machine.price
			thisName = machine.name
		end
	end
	
	if thisCost > cashMoney then
		cb("cash")
	else
		if targetItem.limit ~= -1 and (targetItem.count + 1) > targetItem.limit then
			cb("inventory")
		else
			xPlayer.removeMoney(thisCost)
			xPlayer.addInventoryItem(thisItem, 1)
			cb(true)
		end
	end
end)