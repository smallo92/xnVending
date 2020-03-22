if Config.Framework == "ESX" or Config.Framework == "NewESX" then
	-- ESX Compatibility code
	ESX = nil
	Citizen.CreateThread(function()
		while ESX == nil do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Citizen.Wait(0)
		end
	end)
	ShowNotification = function(str)
		ESX.ShowNotification(str)
	end
	TriggerServerCallback = function(...)
		ESX.TriggerServerCallback(...)
	end
elseif Config.Framework == "vRP" then
	-- vRP Compatibility code
	vRP = Proxy.getInterface("vRP")
	ShowNotification = function(str)
		vRP.notify({str})
	end

	-- ESX.TriggerServerCallback (https://github.com/ESX-Org/es_extended/blob/ff9930068f83af6adf78275b2581a0e5ea54a3bf/client/functions.lua#L76)
	ServerCallbacks = {}
	CurrentRequestId = 0
	TriggerServerCallback = function(name, cb, ...)
		ServerCallbacks[CurrentRequestId] = cb
		TriggerServerEvent("xnVending:triggerServerCallback", name, CurrentRequestId, ...)
		CurrentRequestId = (CurrentRequestId + 1) % 65535
	end
	RegisterNetEvent('xnVending:serverCallback')
	AddEventHandler('xnVending:serverCallback', function(requestId, ...)
		if ServerCallbacks[requestId] then
			ServerCallbacks[requestId](...)
			ServerCallbacks[requestId] = nil
		end
	end)
else
	-- Standalone
	ShowNotification = function(str)
		SetNotificationTextEntry("STRING")
	    AddTextComponentString(str)
	    DrawNotification(true, false)
	end

	-- ESX.TriggerServerCallback (https://github.com/ESX-Org/es_extended/blob/ff9930068f83af6adf78275b2581a0e5ea54a3bf/client/functions.lua#L76)
	ServerCallbacks = {}
	CurrentRequestId = 0
	TriggerServerCallback = function(name, cb, ...)
		ServerCallbacks[CurrentRequestId] = cb
		TriggerServerEvent("xnVending:triggerServerCallback", name, CurrentRequestId, ...)
		CurrentRequestId = (CurrentRequestId + 1) % 65535
	end
	RegisterNetEvent('xnVending:serverCallback')
	AddEventHandler('xnVending:serverCallback', function(requestId, ...)
		if ServerCallbacks[requestId] then
			ServerCallbacks[requestId](...)
			ServerCallbacks[requestId] = nil
		end
	end)
end

local animPlaying = false
local usingMachine = false
local VendingObject = nil
local machineModel = nil

Citizen.CreateThread(function()
    local waitTime = 500
	while true do
		Citizen.Wait(waitTime)
        if nearVendingMachine() and not usingMachine and not IsPedInAnyVehicle(PlayerPedId(), 1) then
			waitTime = 1
			local buttonsMessage = {}
			local machine = machineModel
			local machineInfo = Config.Machines[machineModel]
			local machineNames = machineInfo.name
			for i = 1, #machineNames do
				buttonsMessage[machineNames[i] .. " ($" .. machineInfo.price[i] .. ")"] = Config.PurchaseButtons[i]
				if IsControlJustPressed(1, Config.PurchaseButtons[i]) then
					TriggerServerCallback('esx_vending:checkMoneyandInvent', function(response)
						if response == "cash" then
							ShowNotification("~r~You don't have enough cash")
						elseif response == "inventory" then
							ShowNotification("You cannot carry any more ~y~" .. machineNames[i])
						else
							usingMachine = true
							local ped = PlayerPedId()
							local position = GetOffsetFromEntityInWorldCoords(VendingObject, 0.0, -0.97, 0.05)
							TaskTurnPedToFaceEntity(ped, VendingObject, -1)
							ReqAnimDict(Config.DispenseDict[1])
							RequestAmbientAudioBank("VENDING_MACHINE")
							HintAmbientAudioBank("VENDING_MACHINE", 0, -1)
							SetPedCurrentWeaponVisible(ped, false, true, 1, 0)
							ReqTheModel(machineInfo.prop[i])
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
							local canModel = CreateObjectNoOffset(machineInfo.prop[i], position, true, false, false)
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
							SetModelAsNoLongerNeeded(machineInfo.prop[i])
							TriggerServerCallback('esx_vending:checkMoneyandInvent', function(response) end, machine, i, true)
							usingMachine = false
						end
					end, machine, i, false)
				end
			end
			local scaleForm = setupScaleform("instructional_buttons", buttonsMessage)
			DrawScaleformMovieFullscreen(scaleForm, 255, 255, 255, 255, 0)
			BlockWeaponWheelThisFrame()
        else
            waitTime = 500
		end
	end
end)

function nearVendingMachine()
	local player = PlayerPedId()
	local playerLoc = GetEntityCoords(player, 0)

	for machine, _  in pairs(Config.Machines) do
		VendingObject = GetClosestObjectOfType(playerLoc, 0.6, machine, false)
		if DoesEntityExist(VendingObject) then
			machineModel = machine
            return true
		end
	end
	return false
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

function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(ControlButton)
    PushScaleformMovieMethodParameterButtonName(ControlButton)
end

function setupScaleform(scaleform, buttonsMessages)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

	local buttonCount = 0
	for machine, buttons in pairs(buttonsMessages) do
		PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
		PushScaleformMovieFunctionParameterInt(buttonCount)
		Button(GetControlInstructionalButton(2, buttons, true))
		ButtonMessage(machine)
		PopScaleformMovieFunctionVoid()
		buttonCount = buttonCount + 1
	end

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(70)
    PopScaleformMovieFunctionVoid()

    return scaleform
end
