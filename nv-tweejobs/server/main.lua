ESX = nil
local webhook = '' -- Change it to your likings :)
local allowedAdminGroups = {
    ['superadmin'] = true,
    ['admin'] = true
    -- Here you can add more groups which will be allowed to you /setjob2 command, co not forget to add comma
}


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('nv-tweejobs:getSecondJob')
AddEventHandler('nv-tweejobs:getSecondJob', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.fetchAll('SELECT secondjob, secondjob_grade FROM users WHERE identifier = @identifier', { ['@identifier'] = xPlayer.getIdentifier() }, function(result)

        if result[1] ~= nil and result[1].secondjob ~= nil and result[1].secondjob_grade ~= nil then
                TriggerClientEvent('nv-tweejobs:returnSecondJob', _source, result[1].secondjob, result[1].secondjob_grade)
        else
            xPlayer.showNotification('Er is een fout opgetreden bij het laden van uw tweede taak uit de database')
        end
    end)
end)

RegisterServerEvent('nv-tweejobs:setSecondJob')
AddEventHandler('nv-tweejobs:setSecondJob', function(job1, job1_grade, job2, job2_grade)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    MySQL.Async.fetchAll('SELECT secondjob, secondjob_grade FROM users WHERE identifier = @identifier', { ['@identifier'] = xPlayer.getIdentifier() }, function(result)

        if result[1] ~= nil then
            if result[1].secondjob == job2 and result[1].secondjob_grade == job2_grade then
                xPlayer.setJob(job2, job2_grade)

                MySQL.Async.execute('UPDATE users SET secondjob = @secondjob, secondjob_grade = @secondjob_grade WHERE identifier = @identifier',
                    { 
                        ['@secondjob'] = job1,
                        ['@secondjob_grade'] = job1_grade,
                        ['@identifier'] = xPlayer.getIdentifier(),
                    },
                    function(affectedRows)
                        if affectedRows == 0 then
                            print('Speler met Steam-ID: '..xPlayer.getIdentifier()..'had een probleem bij het veranderen van zijn baan met het redden van zijn tweede baan')
                        end
                    end
                )  
            
                SendDiscordWebhook(_source, job1, job1_grade, job2, job2_grade, 255)
            else
                print('Speler met ID'..xPlayer.identifier..'is de meeste 99% cheater.')
                DropPlayer(_source, 'Cheater, misbruik van jobgebeurtenissen instellen')
            end
        else
            print('Speler met ID'..xPlayer.identifier..' had problemen met het veranderen van baan, hij is het meest van plan om vals te spelen'o)
        end
    end)

end)

function SendDiscordWebhook(source, job1, job1_grade, job2, job2_grade, color)
    local xPlayer = ESX.GetPlayerFromId(source)
		local connect = {
			  {
				  ["color"] = color,
				  ["title"] = GetPlayerName(source)..', SteamID: '..xPlayer.getIdentifier(), -- Maybye it us better to replace by xPlayer.getIdentifier() ,  I don't know :D Change by yourself, if you want
				  ["description"] = 'Deze speler is van baan veranderd' **FROM**: '..job1..' with grade: '..job1_grade..' **TO**: '..job2.. ' with grade '..job2_grade,
				  ["footer"] = {
					  ["text"] = 'nv-tweejobs, baan veranderen met commando /baan2 '..os.date("%Y/%m/%d %X"),
				  },
			  }
		  }
	PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({embeds = connect}), { ['Content-Type'] = 'application/json' })
end

RegisterCommand("geefbaan2", function(source, args, rawCommand)
    
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if allowedAdminGroups[xPlayer.getGroup()] then

        if not args[1] or not args[2] or not args[3] then
            xPlayer.showNotification('Je mist argumenten om de taak in te stellen')
        else
            local tPlayer = ESX.GetPlayerFromId(tonumber(args[1])) -- Tonumber in case somebody adds a paramter as a string, not a number
            if not tPlayer then
                xPlayer.showNotification('De ID is niet online op de server')
            else
                if ESX.DoesJobExist(args[2], tonumber(args[3])) then
                    MySQL.Async.execute('UPDATE users SET secondjob = @secondjob, secondjob_grade = @secondjob_grade WHERE identifier = @identifier',
                        { 
                            ['@secondjob'] = args[2],
                            ['@secondjob_grade'] = tonumber(args[3]),
                            ['@identifier'] = tPlayer.getIdentifier(),
                        },
                            function(affectedRows)
                                if affectedRows == 0 then
                                    xPlayer.showNotification('Er waren wat problemen met het wijzigen van de tweede taak, probeer het opnieuw')
                                    print('Speler met Steam-ID: '..xPlayer.getIdentifier()..'had een probleem bij het instellen van geefbaan2 op andere speler')
                                end
                            end
                    )
                else
                    xPlayer.showNotification('Ingevoerde taak bestaat niet')
                end

            end
        end


    else
        xPlayer.showNotification('U mag deze opdracht niet uitvoeren, u bent geen beheerder')
    end
    
end, false)