ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_vending:checkMoneyandInvent', function(source, cb, item, count)
	local plySource = source
	local thisItem = item
	local thisCount = count
	local thisCost = thisItem.price[thisCount]
	local xPlayer = ESX.GetPlayerFromId(plySource)
	local targetItem = xPlayer.getInventoryItem(thisItem.item[thisCount])
	
	if Config.NewEsx then
		local cashMoney = xPlayer.getAccount('money').money
		if thisCost > cashMoney then
			cb("cash")
		else
			if not xPlayer.canCarryItem(thisItem.item[thisCount], 1) then
				cb("inventory")
			else
				AddItem(thisCost, thisItem.item[thisCount], xPlayer)
				cb(true)
			end
		end
	else
		local cashMoney = xPlayer.getMoney()
		if thisCost > cashMoney then
			cb("cash")
		else
			if targetItem.limit ~= -1 and (targetItem.count + 1) > targetItem.limit then
				cb("inventory")
			else
				AddItem(thisCost, thisItem.item[thisCount], xPlayer)
				cb(true)
			end
		end
	end
end)

function AddItem(thisCost, thisItem, xPlayer)
	xPlayer.removeMoney(thisCost)
	xPlayer.addInventoryItem(thisItem, 1)
end