if Config.Framework == "ESX" or Config.Framework == "NewESX" then
	ESX = nil
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

	function AddItem(thisCost, thisItem, xPlayer)
		xPlayer.removeMoney(thisCost)
		xPlayer.addInventoryItem(thisItem, 1)
	end

	-- confirm parameter is used for after the animation plays, do the same checks but also give item and take money
	ESX.RegisterServerCallback('esx_vending:checkMoneyandInvent', function(source, cb, machine, entry, confirm)
		local thisItem = Config.Machines[machine]
		local thisCost = thisItem.price[entry]
		local xPlayer = ESX.GetPlayerFromId(source)
		local targetItem = xPlayer.getInventoryItem(thisItem.item[entry])

		if Config.Framework == "NewESX" then
			local cashMoney = xPlayer.getAccount('money').money
			if thisCost > cashMoney then
				cb("cash")
			else
				if not xPlayer.canCarryItem(thisItem.item[entry], 1) then
					cb("inventory")
				else
					if confirm then AddItem(thisCost, thisItem.item[entry], xPlayer) end
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
					if confirm then AddItem(thisCost, thisItem.item[entry], xPlayer) end
					cb(true)
				end
			end
		end
	end)
elseif Config.Framework == "vRP" then
	-- vRP Compatibility
	local Proxy = module("vrp", "lib/Proxy")
	vRP = Proxy.getInterface("vRP")
	TryGiveInventoryItem = function(source, cb, machine, entry, confirm)
		local user_id = vRP.getUserId({source})
		local item = Config.Machines[machine]
		local itemid = item.item[entry]
		local price = item.price[entry]
		-- Make sure we can afford the item
		if vRP.getMoney({user_id}) >= price then
			local weight = vRP.getItemWeight({itemid})
			local remaining = vRP.getInventoryMaxWeight({user_id}) - vRP.getInventoryWeight({user_id})
			-- Make sure we can carry the item
			if weight <= remaining then
				-- Give and pay
				if confirm then
					vRP.giveInventoryItem({user_id, itemid, 1, true})
					vRP.tryPayment({user_id, price})
				end
				cb(true)
			else
				cb("inventory")
			end
		else
			cb("cash")
		end
	end

	RegisterServerEvent('xnVending:triggerServerCallback')
	AddEventHandler('xnVending:triggerServerCallback', function(name, requestId, ...)
		local playerId = source
		if name == "esx_vending:checkMoneyandInvent" then
			TryGiveInventoryItem(playerId, function(...)
				TriggerClientEvent('xnVending:serverCallback', playerId, requestId, ...)
			end, ...)
		end
	end)
else
	-- Standalone, no economy so we just instantly accept it
	TryGiveInventoryItem = function(source, cb, machine, entry)
		cb(true)
	end

	RegisterServerEvent('xnVending:triggerServerCallback')
	AddEventHandler('xnVending:triggerServerCallback', function(name, requestId, ...)
		local playerId = source
		if name == "esx_vending:checkMoneyandInvent" then
			TryGiveInventoryItem(playerId, function(...)
				TriggerClientEvent('xnVending:serverCallback', playerId, requestId, ...)
			end, ...)
		end
	end)
end
