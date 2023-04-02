local ESX = nil



Citizen.CreateThread(function()

	while not ESX do

		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

		Citizen.Wait(100)

	end

end)



local isNearGasStation = false

local isFueling = false

local hasNozle = false

local canReturnNozle = true

local canRefillVehicle = true

local canPayBill = false

local zoneData = nil

local GallonPrice = 5 -- was 300

local JerryCanCost = 2000 -- was 30000

local RefillCost = 500 -- as 30000

attachedProp = 0

local blipShow = false

local blipGas = {}



local FuelClasses = {

	[0] = 0.3, -- Compacts

	[1] = 0.3, -- Sedans

	[2] = 0.3, -- SUVs

	[3] = 0.3, -- Coupes

	[4] = 0.3, -- Muscle

	[5] = 0.3, -- Sports Classics

	[6] = 0.3, -- Sports

	[7] = 0.3, -- Super

	[8] = 0.3, -- Motorcycles

	[9] = 0.3, -- Off-road

	[10] = 0.3, -- Industrial

	[11] = 0.3, -- Utility

	[12] = 0.3, -- Vans

	[13] = 0.0, -- Cycles

	[14] = 0.0, -- Boats

	[15] = 0.0, -- Helicopters

	[16] = 0.0, -- Planes

	[17] = 0.3, -- Service

	[18] = 0.3, -- Emergency

	[19] = 0.3, -- Military

	[20] = 0.3, -- Commercial

	[21] = 0.3, -- Trains

}



local FuelUsage = {

	[1.0] = 1.4,

	[0.9] = 1.2,

	[0.8] = 1.0,

	[0.7] = 0.9,

	[0.6] = 0.8,

	[0.5] = 0.7,

	[0.4] = 0.5,

	[0.3] = 0.4,

	[0.2] = 0.2,

	[0.1] = 0.1,

	[0.0] = 0.0,

}



local GasStations = {

	vector3(49.4187, 2778.793, 58.043),

	vector3(263.894, 2606.463, 44.983),

	vector3(1039.958, 2671.134, 39.550),

	vector3(1207.260, 2660.175, 37.899),

	vector3(2539.685, 2594.192, 37.944),

	vector3(2679.858, 3263.946, 55.240),

	vector3(2005.055, 3773.887, 32.403),

	vector3(1687.156, 4929.392, 42.078),

	vector3(1701.314, 6416.028, 32.763),

	vector3(179.857, 6602.839, 31.868),

	vector3(-94.4619, 6419.594, 31.489),

	vector3(-2554.996, 2334.40, 33.078),

	vector3(-1800.375, 803.661, 138.651),

	vector3(-1437.622, -276.747, 46.207),

	vector3(-2096.243, -320.286, 13.168),

	vector3(-724.619, -935.1631, 19.213),

	vector3(-526.019, -1211.003, 18.184),

	vector3(-70.2148, -1761.792, 29.534),

	vector3(265.648, -1261.309, 29.292),

	vector3(819.653, -1028.846, 26.403),

	vector3(1208.951, -1402.567,35.224),

	vector3(1181.381, -330.847, 69.316),

	vector3(620.843, 269.100, 103.089),

	vector3(2581.321, 362.039, 108.468),

	vector3(176.631, -1562.025, 29.263),

	vector3(176.631, -1562.025, 29.263),

	vector3(-319.292, -1471.715, 30.549),

	vector3(1784.324, 3330.55, 41.253)

}



local pzname = {

	'gas_station1',

	'gas_station2',

	'gas_station3',

	'gas_station4',

	'gas_station5',

	'gas_station6',

	'gas_station7',

	'gas_station8',

	'gas_station9',

	'gas_station10',

	'gas_station11',

	'gas_station12',

	'gas_station13',

	'gas_station14',

	'gas_station15',

	'gas_station16',

	'gas_station17',

	'gas_station18',

	'gas_station19',

	'gas_station20',

	'gas_station21',

	'gas_station22',

	'gas_station23',

	'gas_station25',

	'gas_station26',

	'gas_station27',

	'gas_station28',

	'gas_station29',

	'gas_station30',

	'gas_station31',

	'gas_station32',

	--'gas_station33',

	'gas_station34',

	'gas_station35',

	'gas_station36'

}



function getVehicleClosestToMe()

    playerped = PlayerPedId()

    coordA = GetEntityCoords(playerped, 1)

    coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)

    targetVehicle = getVehicleInDirection(coordA, coordB)

    return targetVehicle

end



function getVehicleInDirection(coordFrom, coordTo)

	local offset = 0

	local rayHandle

	local vehicle



	for i = 0, 100 do

		rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)	

		a, b, c, d, vehicle = GetRaycastResult(rayHandle)

		

		offset = offset - 1



		if vehicle ~= 0 then break end

	end

	

	local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))

	

	if distance > 3000 then vehicle = nil end



    return vehicle ~= nil and vehicle or 0

end



local function Round(num, numDecimalPlaces)

	local mult = 10^(numDecimalPlaces or 0)

	return math.floor(num * mult + 0.5) / mult

end



local function SetFuel(sentVeh, sentFuel)

	if not DoesEntityExist(sentVeh) then return end;

	if type(sentFuel) == 'number' and sentFuel >= 0 and sentFuel <= 100 then

		local fuel = sentFuel + 0.0

		Entity(sentVeh).state:set('fuel', fuel, true)

		Sync.SetVehicleFuelLevel(sentVeh, fuel)

	end

end



local ExtraFuelUsageValue = 0.0

exports('extraFuelUsage', function(value)

	ExtraFuelUsageValue = value

end)



local function GetFuel(sentVeh)

	if not DoesEntityExist(sentVeh) then return end;

	return Entity(sentVeh).state.fuel or -1.0

end



local function doFuel(sentVeh)

	if DoesEntityExist(sentVeh) then

		local currFuel = GetFuel(sentVeh)

		if currFuel == -1.0 then

			TriggerServerEvent('one-fuel:initFuel', VehToNet(sentVeh))

		elseif IsVehicleEngineOn(sentVeh) then

			SetFuel(sentVeh, currFuel - FuelUsage[Round(GetVehicleCurrentRpm(sentVeh), 1)] * ((FuelClasses[GetVehicleClass(sentVeh)]+ExtraFuelUsageValue) or 1.0) / 10) -- From LegacyFuel

		end

	end

end



function loadAnimDict( dict )

    while ( not HasAnimDictLoaded( dict ) ) do

        RequestAnimDict( dict )

        Citizen.Wait( 5 )

    end

end



CreateThread(function()

	while true do

		Wait(1000)

		local plyPed = PlayerPedId()

		local plyVeh = GetVehiclePedIsIn(plyPed, false)

		if plyVeh ~= 0 then

			local plySeat = GetPedInVehicleSeat(plyVeh, -1) == plyPed

			if plySeat then

				doFuel(plyVeh)

			end

		end

	end

end)



function CreateBlip(coords)

	local blip = AddBlipForCoord(coords)



	SetBlipSprite(blip, 361)

	SetBlipScale(blip, 0.5)

	SetBlipColour(blip, 1)

	SetBlipDisplay(blip, 4)

	SetBlipAsShortRange(blip, true)



	BeginTextCommandSetBlipName("STRING")

	AddTextComponentString("Gas Station")

	EndTextCommandSetBlipName(blip)

	table.insert(blipGas, blip)

	return blip

end



local state = {

	['true'] = 'enabled',

	['false'] = 'disabled'

}

function ShowBlipGas()

	blipShow = not blipShow

	exports['one-notifications']:DoShortHudText('inform', 'Blip Gas station ' .. state[tostring(blipShow)], 4500)

	if blipShow then

		Citizen.CreateThread(function()

			for k,v in pairs(GasStations) do

				CreateBlip(v)

			end

		end)

	else

		for k , v in pairs(blipGas) do

			RemoveBlip(v)

		end

		blipGas = {}

	end

end



function JerrycanAnim()

	RequestAnimDict("weapon@w_sp_jerrycan")

	while ( not HasAnimDictLoaded( "weapon@w_sp_jerrycan" ) ) do

		Wait(0)

	end

	TaskPlayAnim(PlayerPedId(),"weapon@w_sp_jerrycan","fire",2.0, -8, -1,49, 0, 0, 0, 0)

end



RegisterNetEvent('one-polyzone:enter')

AddEventHandler('one-polyzone:enter', function(name, data)

	for k ,v in pairs(pzname) do

		if name == v then

			isNearGasStation = true

			zoneData = data

		end

	end

end)



RegisterNetEvent('one-polyzone:exit')

AddEventHandler('one-polyzone:exit', function(name)

	for k ,v in pairs(pzname) do

		if name == v then

			isNearGasStation = false

			zoneData = nil

			local playerPed = PlayerPedId()

			local playerVeh = GetVehiclePedIsIn(playerPed, false)

			if playerVeh ~= 0 and hasNozle then

				Sync.NetworkExplodeVehicle(playerVeh, true, false, 0)

				if DoesEntityExist(attachedProp) then

					DeleteEntity(attachedProp)

					attachedProp = 0

				end

				hasNozle = false

			end

		end

	end

end)



RegisterNetEvent('one-fuel:SelectFuel', function()

	TriggerEvent('nh-context:sendMenu', {

		{

			id = 1,

			header = "Gas Pump",

			txt = "Select the kind of fuel you want to use",

		},

		{

			id = 2,

			header = "Regular",

			txt = "Octane : 87 | Price : $".. GallonPrice,

			params = {

				event = "one-fuel:FuelSelected",

			},

			disabled = hasNozle

		},

		{

			id = 3,

			header = "Buy or Refil Jerrycan",

			txt = "",

			params = {

				event = "one-fuel:BuyJerrycan",

			},

		},

		{

			id = 4,

			header = "Return Nozle",

			txt = "",

			params = {

				event = "one-fuel:ReturnNozel",

			},

			disabled = canReturnNozle

		},

		{

			id = 5,

			header = "◀",

			txt = "",

			params = {

				event = "",

				args = {

					number = 1,

					id = 3

				}

			}

		},

	})

end)



RegisterNetEvent('one-fuel:FuelSelected', function()

	local currentPed = PlayerPedId()

	if not hasNozle then

		hasNozle = true

		canReturnNozle = false

		attachedProp = CreateObject(GetHashKey("prop_cs_fuel_nozle"), 0, 0, 0, true, true, true)

		DecorSetInt(attachedProp,"GamemodeCar",955)

		AttachEntityToEntity(attachedProp, currentPed, GetPedBoneIndex(currentPed, 0xDEAD), 0.13, 0.04, -0.03, 80.0, 100.0, 190.0, true, true, false, true, 1, true)

	end

end)



RegisterNetEvent('one-fuel:ReturnNozel', function()

	if hasNozle then

		if DoesEntityExist(attachedProp) then

            DeleteEntity(attachedProp)

            attachedProp = 0

        end

		hasNozle = false

		canReturnNozle = true

	end

end)



RegisterNetEvent('one-fuel:vehrefuel', function()

	TriggerEvent('nh-context:sendMenu', {

		{

			id = 1,

			header = "Refuel from nozle",

			txt = "if you have nozle",

			params = {

				event = "one-fuel:RefillVehicle",

			},

		},

		{

			id = 2,

			header = "Refuel from jerrycan",

			txt = "if you have jerrycan",

			params = {

				event = "one-fuel:refuelfromjerrycan",

			},

		},

		{

			id = 3,

			header = "◀",

			txt = "",

			params = {

				event = "",

				args = {

					number = 1,

					id = 3

				}

			}

		},

	})

end)



RegisterNetEvent('one-fuel:RefillVehicle', function()

	if isNearGasStation == true and hasNozle == true then

		local veh = getVehicleClosestToMe()

		local vehicleCurrentFuel = math.ceil(exports['one-fuel']:GetFuel(veh))

		local endFuel = (100 - vehicleCurrentFuel)

		local FuelCost = endFuel * GallonPrice

		TriggerEvent('nh-context:sendMenu', {

			{

				id = 1,

				header = "Refuel Vehicle",

				txt = "Current Fuel : ".. math.ceil(exports['one-fuel']:GetFuel(veh)) .. " | Total Cost : $".. FuelCost .. ".0",

			},

			{

				id = 2,

				header = "Start Refueling",

				txt = "",

				params = {

					event = "one-fuel:RefuelVehicle",

					args = FuelCost,

				},

				disabled = canRefillVehicle

			},

			{

				id = 3,

				header = "◀",

				txt = "",

				params = {

					event = "",

					args = {

						number = 1,

						id = 3

					}

				}

			},

		})

	end

end)



local MathRound = function(value, numDecimalPlaces)

	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))

end



local function trim(value)

	if not value then return nil end

	return (string.gsub(value, '^%s*(.-)%s*$', '%1'))

end



RegisterNetEvent('one-fuel:RefuelVehicle', function()

	local veh = getVehicleClosestToMe()

	local vehicleCurrentFuel = math.ceil(exports['one-fuel']:GetFuel(veh))

	local timer = (100 - vehicleCurrentFuel) * 400

	local endFuel = (100 - vehicleCurrentFuel)

	local FuelCost = endFuel * GallonPrice

	local currentCash = ESX.GetPlayerData().money



	--taxes

	local percentTax = exports["one-taxes"]:cekPajak("ACTION", "pertamina")

	local tax = MathRound(percentTax * FuelCost)



	if Config.Tax == true then

		if currentCash >= FuelCost+tax then

			loadAnimDict("anim@heists@keycard@")

			TaskPlayAnim(PlayerPedId(), "anim@heists@keycard@","idle_a",1.0, 1.0, -1, 9, 1.0, 0, 0, 0)



			exports['one-taskbar']:Progress({

				duration = timer,

				label = "Refueling",

			}, function(cancelled)

				if not cancelled then

					TriggerServerEvent('one-fuel:PurchaseSuccessful', FuelCost+tax)

					exports['one-notifications']:DoShortHudText('infrom', 'you pay $' ..FuelCost .. ' + tax $' .. tax)

					exports["one-taxes"]:BayarPajak(tax)

					exports['one-fuel']:SetFuel(veh, 100)

					canRefillVehicle = true

					canPayBill = false

					ClearPedTasksImmediately(GetPlayerPed(-1))

				else

					canRefillVehicle = true

					canPayBill = false

					ClearPedTasks(PlayerPedId())

				end

			end)

		else

			exports['one-notifications']:DoShortHudText('error', 'not enough cash for $' .. FuelCost+tax)

		end

	elseif Config.Tax == false then

		if currentCash >= FuelCost then

			loadAnimDict("anim@heists@keycard@")
	
			TaskPlayAnim(PlayerPedId(), "anim@heists@keycard@","idle_a",1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
	
	
	
			exports['one-taskbar']:Progress({
	
				duration = timer,
	
				label = "Refueling",
	
			}, function(cancelled)
	
				if not cancelled then
	
					TriggerServerEvent('one-fuel:PurchaseSuccessful', FuelCost)
	
					exports['one-notifications']:DoShortHudText('infrom', 'you pay $' ..FuelCost)
	
					exports['one-fuel']:SetFuel(veh, 100)
	
					canRefillVehicle = true
	
					canPayBill = false
	
					ClearPedTasksImmediately(GetPlayerPed(-1))
	
				else
	
					canRefillVehicle = true
	
					canPayBill = false
	
					ClearPedTasks(PlayerPedId())
	
				end
	
			end)
	
		else
	
			exports['one-notifications']:DoShortHudText('error', 'not enough cash for $' .. FuelCost)
	
		end

	end

end)



RegisterNetEvent('one-fuel:BuyJerrycan', function()

	local ped = PlayerPedId()

	local currentCash = ESX.GetPlayerData().money



	--taxes

	local percentTax = exports["one-taxes"]:cekPajak("ACTION", "gasoline")

	local tax = MathRound(percentTax * JerryCanCost)



	if Config.Tax == true then

		if currentCash >= JerryCanCost+tax then

			if not HasPedGotWeapon(ped, 883325847) then

				TriggerServerEvent('one-fuel:PurchaseSuccessful', JerryCanCost+tax)

				exports["one-taxes"]:BayarPajak(tax)

				TriggerEvent('player:receiveItem', "WEAPON_PETROLCAN", 1)

				exports['one-inventory']:updateJerryCan(4500)

				SetPedAmmo(ped, 883325847, 4500)

				exports['one-notifications']:DoShortHudText('infrom', 'you pay $'..JerryCanCost .. ' + tax $' ..tax)

			else

				local refillCost = Round(RefillCost * (1 - GetAmmoInPedWeapon(ped, 883325847) / 4500))



				--taxes

				local percentTax = exports["one-taxes"]:cekPajak("ACTION", "gasoline")

				local tax = MathRound(percentTax * refillCost)



				if refillCost > 0 then

					if currentCash >= refillCost then

						exports['one-inventory']:updateJerryCan(4500)

						TriggerServerEvent('one-fuel:PurchaseSuccessful', JerryCanCost+tax)

						exports["one-taxes"]:BayarPajak(tax)

						SetPedAmmo(ped, 883325847, 4500)

						exports['one-notifications']:DoShortHudText('infrom', 'you pay $'..refillCost .. ' + tax $' .. tax)

					else

						exports['one-notifications']:DoShortHudText('error', 'not enough cash for $'..JerryCanCost+tax)

					end

				else

					exports['one-notifications']:DoShortHudText('error', 'jerrycan is full!')

				end

			end

		else

			exports['one-notifications']:DoShortHudText('error', 'not enough cash for $' .. JerryCanCost+tax)

		end

	elseif Config.Tax == false then

		if currentCash >= JerryCanCost then

			if not HasPedGotWeapon(ped, 883325847) then

				TriggerServerEvent('one-fuel:PurchaseSuccessful', JerryCanCost)

				TriggerEvent('player:receiveItem', "WEAPON_PETROLCAN", 1)

				exports['one-inventory']:updateJerryCan(4500)

				SetPedAmmo(ped, 883325847, 4500)

				exports['one-notifications']:DoShortHudText('infrom', 'you pay $'..JerryCanCost)

			else

				local refillCost = Round(RefillCost * (1 - GetAmmoInPedWeapon(ped, 883325847) / 4500))



				if refillCost > 0 then

					if currentCash >= refillCost then

						exports['one-inventory']:updateJerryCan(4500)

						TriggerServerEvent('one-fuel:PurchaseSuccessful', JerryCanCost)

						SetPedAmmo(ped, 883325847, 4500)

						exports['one-notifications']:DoShortHudText('infrom', 'you pay $'..refillCost)

					else

						exports['one-notifications']:DoShortHudText('error', 'not enough cash for $'..JerryCanCost)

					end

				else

					exports['one-notifications']:DoShortHudText('error', 'jerrycan is full!')

				end

			end

		else

			exports['one-notifications']:DoShortHudText('error', 'not enough cash for $' .. JerryCanCost)

		end

	end

end)



RegisterNetEvent('one-fuel:refuelfromjerrycan', function()

	local plyped = PlayerPedId()

	local coords = GetEntityCoords(plyped)

	local vehicle = nil



	if IsPedInAnyVehicle(plyped, false) then

		vehicle = GetVehiclePedIsIn(plyped, false)

	else

		vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)

	end



	if DoesEntityExist(vehicle) then

		if GetSelectedPedWeapon(plyped) == 883325847 then

			if GetAmmoInPedWeapon(plyped, 883325847) > 100 then

				local currvehfuel = GetFuel(vehicle)

				local setvehfuel = currvehfuel + 30

				JerrycanAnim()

				exports['one-nui']:isOtherNUIActive(true)

				exports['one-progressbars']:startUI(30000, "Refueling")

				Citizen.Wait(30000)

				ClearPedTasksImmediately(plyped)

				SetFuel(vehicle, setvehfuel)

				exports['one-inventory']:updateJerryCan(50)

				SetPedAmmo(plyped, 883325847, 50)

				exports['one-nui']:isOtherNUIActive(false)

			else

				exports['one-notifications']:DoShortHudText('error', 'jerrycan empty!')

			end

		else

			exports['one-notifications']:DoShortHudText('error', 'where is your jerrycan?')

		end

	else

		exports['one-notifications']:DoShortHudText('error', 'there is no vehicle nearby')

	end

end)



exports('ShowBlipGas', function()

	ShowBlipGas()

end)



exports('SetFuel', SetFuel) -- exports['one-fuel']:SetFuel(veh, fuel)

exports('GetFuel', GetFuel) -- exports['one-fuel']:GetFuel(veh)



exports("hasNozle", function()

	return hasNozle

end)



exports("NearGasFn", function()

	return isNearGasStation

end)



exports("gasZoneData", function()

	return zoneData

end)