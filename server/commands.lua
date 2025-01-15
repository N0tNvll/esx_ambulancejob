ESX.RegisterCommand('revive', 'admin', function(xPlayer, args, showError)
	args.playerId.triggerEvent('esx_ambulancejob:revive')
end, true, { help = TranslateCap('revive_help'), validate = true, arguments = {
	{ name = 'playerId', help = 'The player id', type = 'player' }
} })

ESX.RegisterCommand('reviveall', "admin", function(xPlayer, args, showError)
	TriggerClientEvent('esx_ambulancejob:revive', -1)
end, false)