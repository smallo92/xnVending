ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local animPlaying = false
local usingMachine = false
local VendingObject = nil
local itemItem = nil
local itemCost = nil
local itemName = nil
local itemProp = nil

Citizen.CreateThread(function()
    local waitTime = 500
	while true do
		Citizen.Wait(waitTime)
        if nearVendingMachine() and not usingMachine and not IsPedInAnyVehicle(PlayerPedId(), 1) then
            waitTime = 1
			DisplayHelpText("Press ~INPUT_PICKUP~ to buy a ~y~" .. itemName .. "~s~ for ~g~$" .. itemCost)
			if IsControlJustPressed(1, 38) then
				ESX.TriggerServerCallback('esx_vending:checkMoneyandInvent', function(response)
					if response == "cash" then
						ESX.ShowNotification("~r~You don't have enough cash")
					elseif response == "inventory" then
						ESX.ShowNotification("You cannot carry any more ~y~" .. itemName)
					else
						usingMachine = true
						local ped = PlayerPedId()
						local position = GetOffsetFromEntityInWorldCoords(VendingObject, 0.0, -0.97, 0.05)
						TaskTurnPedToFaceEntity(ped, VendingObject, -1)
						ReqAnimDict(Config.DispenseDict[1])
						RequestAmbientAudioBank("VENDING_MACHINE")
						HintAmbientAudioBank("VENDING_MACHINE", 0, -1)
						SetPedCurrentWeaponVisible(ped, false, true, 1, 0)
						ReqTheModel(itemProp)
						SetPedResetFlag(ped, 322, true)
						if not IsEntityAtCoord(ped, position, 0.1, 0.1, 0.1, false, true, 0) then
							TaskGoStraightToCoord(ped, position, 1.0, 20000, GetEntityHeading(VendingObject), 0.1)
							while not IsEntityAtCoord(ped, position, 0.1, 0.1, 0.1, false, true, 0) do
								Citizen.Wait(2000)
							end
						end
						TaskTurnPedToFaceEntity(ped, VendingObject, -1)
						Citizen.Wait(1000)
						TaskPlayAnim(ped, Config.DispenseDict[1], Config.DispenseDict[2], 8.0, 5.0, -1, true, 1, 0, 0, 0)
						Citizen.Wait(2500)
						local canModel = CreateObjectNoOffset(itemProp, position, true, false, false)
						SetEntityAsMissionEntity(canModel, true, true)
						SetEntityProofs(canModel, false, true, false, false, false, false, 0, false)
						AttachEntityToEntity(canModel, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
						Citizen.Wait(1700)
						ReqAnimDict(Config.PocketAnims[1])
						TaskPlayAnim(ped, Config.PocketAnims[1], Config.PocketAnims[2], 8.0, 5.0, -1, true, 1, 0, 0, 0)
						Citizen.Wait(1000)
						ClearPedTasks(ped)
						ReleaseAmbientAudioBank()
						RemoveAnimDict(Config.DispenseDict[1])
						RemoveAnimDict(Config.PocketAnims[1])
						if DoesEntityExist(canModel) then
							DetachEntity(canModel, true, true)
							DeleteEntity(canModel)
						end
						SetModelAsNoLongerNeeded(itemProp)
						usingMachine = false
					end
				end, itemItem)
            end
        else
            waitTime = 500
		end
	end
end)

function nearVendingMachine()
	local player = PlayerPedId()
	local playerLoc = GetEntityCoords(player, 0)

	for _, machine in ipairs(Config.Machines) do
		VendingObject = GetClosestObjectOfType(playerLoc, 0.6, machine.model, false)
		if DoesEntityExist(VendingObject) then
			itemItem = machine.item
			itemCost = machine.price
			itemName = machine.name
			itemProp = machine.prop
            return true
		end
	end
	return false
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function ReqTheModel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(0)
	end
end

function ReqAnimDict(animDict)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(0)
	end
end
