ESX = nil
local job1, job2
local job1_grade, job2_grade
local timer = 0
local sleepThread = 1000
local allowCommand = true

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterCommand("baan2", function (src, args, raw)
    if timer == 0 and allowCommand then
        TriggerServerEvent('nv-tweejobs:getSecondJob')
        timer = 30
        allowCommand = false
    else
        ESX.ShowNotification('Je moet 30 seconden wachten tussen het wisselen van job, nu moet je wachten: (tijd in seconden)'..timer) -- Here you can change whatewer you want
    end
end, false)

RegisterNetEvent('nv-tweejobs:returnSecondJob')
AddEventHandler('nv-tweejobs:returnSecondJob', function(secondjob, secondjob_grade)
    job2 = secondjob
    job2_grade = secondjob_grade
    job1 = ESX.PlayerData.job.name
    job1_grade = ESX.PlayerData.job.grade
    TriggerServerEvent('nv-tweejobs:setSecondJob', job1, job1_grade, job2, job2_grade)
    ESX.ShowNotification('Je heb je tweeden baan gepakt') -- Here you can change whatewer you want
    Wait(5000)
    ESX.ShowNotification('Deze baan heb je nu: '..ESX.PlayerData.job.label..'en je rank  is: '..ESX.PlayerData.job.grade_label) -- Here you can change whatewer you want
end)

Citizen.CreateThread(function()
    
    while true do
        if timer > 1 then
            timer = timer-1  
        elseif timer == 1 then
            allowCommand = true
            timer = 0
        end
        Citizen.Wait(sleepThread)
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

-- Add sugestion for /setjob2 command

TriggerEvent('chat:addSuggestion', '/geefbaan2', 'Geef een tweeden job', {
    { name="playerID", help="De server-ID van de speler waarvan je zijn tweede baan wilt wijzigen" },
    { name="jobname", help="De taaknaam van de taak die u voor een speler wilt instellen" },
    { name="jobgrade", help="De functiegroep van de functie die je voor een speler wilt instellen" }
})