local Pool = MenuPool.New()
local MainMenu = UIMenu.New('Add-On Peds', '~b~Spawn custom added Peds')
local Items = {}
Pool:Add(MainMenu)

-- Actual Menu [

local IsAdmin

RegisterNetEvent('AOPSM:AdminStatusChecked')
AddEventHandler('AOPSM:AdminStatusChecked', function(State) --Just Don't Edit!
	IsAdmin = State
end)


Citizen.CreateThread(function() --Controls
	AOPSM.CheckStuff()

	while true do
		Citizen.Wait(0)

        Pool:ProcessMenus()

		if ((GetIsControlJustPressed(AOPSM.KBKey) and GetLastInputMethod(2)) or ((GetIsControlPressed(AOPSM.GPKey1) and GetIsControlJustPressed(AOPSM.GPKey2)) and not GetLastInputMethod(2))) then
			MainMenu:Visible(not MainMenu:Visible())
		end
	end
end)

RegisterNetEvent('AOPSM:GotPeds')
AddEventHandler('AOPSM:GotPeds', function(AddOnPeds)
	for Key, Value in pairs(AddOnPeds) do
		local Ped = UIMenuItem.New(Value.DisplayName, 'Model: ' .. Value.SpawnName)
		MainMenu:AddItem(Ped)
		table.insert(Items, {Ped, Value.SpawnName})
	end

	MainMenu.OnItemSelect = function(Sender, Item, Index)
		for Key, Value in pairs(Items) do
			if Item == Value[1] then
				AOPSM.SpawnPed(Value[2])
			end
		end
	end

	Pool:RefreshIndex()
end)

-- ] Actual Menu

-- Functions [

function AOPSM.SpawnPed(Model)
	Model = GetHashKey(Model)
	if IsModelValid(Model) then
		if not HasModelLoaded(Model) then
			RequestModel(Model)
			while not HasModelLoaded(Model) do
				Citizen.Wait(0)
			end
		end
		
		SetPlayerModel(PlayerId(), Model)
		SetPedDefaultComponentVariation(PlayerPedId())
		
		SetModelAsNoLongerNeeded(Model)
	else
		SetNotificationTextEntry('STRING')
		AddTextComponentString('~r~Invalid Model!')
		DrawNotification(false, false)
	end
end

function AOPSM.CheckStuff()
	IsAdmin = nil
	if AOPSM.OnlyForAdmins then
		TriggerServerEvent('AOPSM:CheckAdminStatus')
		while (IsAdmin == nil) do
			Citizen.Wait(0)
		end
		if IsAdmin then
			TriggerServerEvent('AOPSM:GetPeds')
		end
	else
		TriggerServerEvent('AOPSM:GetPeds')
	end
end

function GetIsControlPressed(Control)
	if IsControlPressed(1, Control) or IsDisabledControlPressed(1, Control) then
		return true
	end
	return false
end

function GetIsControlJustPressed(Control)
	if IsControlJustPressed(1, Control) or IsDisabledControlJustPressed(1, Control) then
		return true
	end
	return false
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght, NoSpaces)
	AddTextEntry(GetCurrentResourceName() .. '_KeyboardHead', TextEntry)
	DisplayOnscreenKeyboard(1, GetCurrentResourceName() .. '_KeyboardHead', '', ExampleText, '', '', '', MaxStringLenght)

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		if NoSpaces == true then
			drawNotification('~y~NO SPACES!')
		end
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		return result
	else
		Citizen.Wait(500)
		return nil
	end
end
	
-- ] Functions

