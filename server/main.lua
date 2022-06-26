RegisterServerEvent('vrs_bikerental:server:pay')
AddEventHandler('vrs_bikerental:server:pay', function(price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeAccountMoney('money', price)
end)

RegisterServerEvent('vrs_bikerental:server:returnmoney')
AddEventHandler('vrs_bikerental:server:returnmoney', function(price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.addAccountMoney('money', price)
end)

ESX.RegisterServerCallback('vrs_bikerental:server:checkMoney', function(source, cb, price)
	local xPlayer = ESX.GetPlayerFromId(source)

	cb(xPlayer.getAccount('money').money >= price)
end)