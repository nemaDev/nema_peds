--Update Check

local LatestVersion = ''; CurrentVersion = '2.0.1'
local GithubResourceName = 'AddOnPedSpawnMenu'

PerformHttpRequest('https://raw.githubusercontent.com/Flatracer/FiveM_Resources/master/' .. GithubResourceName .. '/VERSION', function(Error, NewestVersion, Header)
	PerformHttpRequest('https://raw.githubusercontent.com/Flatracer/FiveM_Resources/master/' .. GithubResourceName .. '/CHANGES', function(Error, Changes, Header)
		LatestVersion = NewestVersion
		print('\n')
		print('##############')
		print('## ' .. GetCurrentResourceName())
		print('##')
		print('## Current Version: ' .. CurrentVersion)
		print('## Newest Version: ' .. NewestVersion)
		print('##')
		if CurrentVersion ~= NewestVersion then
			print('## Outdated')
			print('## Check the Topic (type DownloadAOPSM and press enter)')
			print('## For the newest Version!')
			print('##############')
			print('CHANGES:\n' .. Changes)
		else
			print('## Up to date!')
			print('##############')
		end
		print('\n')
	end)
end)

AddEventHandler('rconCommand', function(Name, Arguments)
	if Name == 'DownloadAOPSM' and CurrentVersion ~= LatestVersion then
		if os.getenv('HOME') then
			os.execute('open https://forum.fivem.net/t/release-add-on-ped-skinchange-menu/94522')
		else
			os.execute('start https://forum.fivem.net/t/release-add-on-ped-skinchange-menu/94522')
		end
	end
end)

--Add-On Peds
AddOnPedsTable = {}

Citizen.CreateThread(function()
	local AddOnPedsTXT = LoadResourceFile(GetCurrentResourceName(), 'Add-On Peds.txt'):gsub('\r', '\n')
	if AddOnPedsTXT ~= nil and AddOnPedsTXT ~= '' then
		if not (AddOnPedsTXT:find('SpawnName') or AddOnPedsTXT:find('DisplayName')) then
			AddOnPedsTable = GetAddOns(AddOnPedsTXT)
		elseif AddOnPedsTXT:find('SpawnName') or AddOnPedsTXT:find('DisplayName') then
			print('Add-On Peds.txt format isn\'t correct, correcting it now.')
			AddOnPedsTXT = AddOnPedsTXT:gsub('\nDisplayName: \n', ''):gsub('\nSpawnName: ', ''):gsub('SpawnName: ', ''):gsub('\nDisplayName: ', ':')
			SaveResourceFile(GetCurrentResourceName(), 'Add-On Peds.txt', AddOnPedsTXT, -1)
			
			AddOnPedsTable = GetAddOns(AddOnPedsTXT)
		else
			print('Add-On Peds.txt format is unknown!')
		end
	else
		print('Add-On Peds.txt not found or empty!')
	end
end)

RegisterServerEvent('AOPSM:GetPeds') --Just Don't Edit!
AddEventHandler('AOPSM:GetPeds', function() --Gets the Add-On Peds
	TriggerClientEvent('AOPSM:GotPeds', source, AddOnPedsTable)
end)

--Admin Check

RegisterServerEvent('AOPSM:CheckAdminStatus') --Just Don't Edit!
AddEventHandler('AOPSM:CheckAdminStatus', function()
	local IDs = GetPlayerIdentifiers(source)
	local Admins = LoadResourceFile(GetCurrentResourceName(), 'Admins.txt')
	local AdminsSplitted = stringsplit(Admins, '\n')
	for k, AdminID in pairs(AdminsSplitted) do
		local AdminID = AdminID:gsub(' ', '')
		local SingleAdminsSplitted = stringsplit(AdminID, ',')
		for _, ID in pairs(IDs) do
			if ID:lower() == SingleAdminsSplitted[1]:lower() or ID:lower() == SingleAdminsSplitted[2]:lower() or ID:lower() == SingleAdminsSplitted[3]:lower() then
				TriggerClientEvent('AOPSM:AdminStatusChecked', source, true); return
			end
		end
	end
end)

AddEventHandler('es:playerLoaded', function(Source, user) --Checks if Player is a ESMode Admin
	if user.getGroup() == 'admin' or user.getGroup() == 'superadmin' then
		TriggerClientEvent('AOPSM:AdminStatusChecked', Source, true)
	end
end)

function stringsplit(input, seperator)
	if seperator == nil then
		seperator = '%s'
	end
	
	local t={} ; i=1
	
	for str in string.gmatch(input, '([^'..seperator..']+)') do
		t[i] = str
		i = i + 1
	end
	
	return t
end

function GetAddOns(AddOnPedsTXT)
	local AddOnPedsTXTSplitted = stringsplit(AddOnPedsTXT, '\n')
	local ReturnTable = {}
	
	for Key, Value in ipairs(AddOnPedsTXTSplitted) do
		if Value:find(':') then
			local PedInformations = stringsplit(Value, ':')
			if #PedInformations == 2 then
				local SpawnName = PedInformations[1]
				local DisplayName = PedInformations[2]
				if SpawnName and SpawnName ~= '' and DisplayName and DisplayName ~= '' then
					table.insert(ReturnTable, {['SpawnName'] = SpawnName, ['DisplayName'] = DisplayName})
				end
			end
		end
	end
	return ReturnTable
end

