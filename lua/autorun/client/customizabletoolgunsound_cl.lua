CreateClientConVar("custom_toolgun_sound", "weapons/airboat/airboat_gun_lastshot1.wav", true, false, "What toolgun sound you should use.")
CreateConVar("custom_toolgun_sound_length", 3, FCVAR_REPLICATED, "Max length for toolgun sounds")

local supportedFileTypes = {
    [".mp3"] = true,
    [".wav"] = true,
    [".ogg"] = true
}

local function sendSound()
    local snd = GetConVar("custom_toolgun_sound"):GetString()
    if not snd then return end
    if snd == "" then return end

    if #snd > 100 then
        notification.AddLegacy("Sound path must not be longer than 100!", NOTIFY_ERROR, 3)
        return
    end

    local isSupportedFileType = false

    for ftype, _ in pairs(supportedFileTypes) do
        if string.EndsWith(snd, ftype) then
            isSupportedFileType = true
            break
        end
    end

    if not isSupportedFileType then
        notification.AddLegacy("Sound filetype must be mp3, ogg or wav!", NOTIFY_ERROR, 3)
        return
    end

    local maxlength = GetConVar("custom_toolgun_sound_length")
    maxlength = (maxlength:GetFloat() or 5)

    if SoundDuration(snd) > maxlength then
        notification.AddLegacy("Sound must not be longer than "..maxlength.."!", NOTIFY_ERROR, 3)
        return
    end

    net.Start("CUST_TG_SND")
    net.WriteString(snd)
    net.SendToServer()
end

local function applyToolgunSnd(ply)
    local cs = ply.Cust_Tlgn_Snd
    
    if not cs then return end

    timer.Simple(0.1, function()
        local wep = ply:GetWeapon("gmod_tool")

        if not wep then return end
        wep.ShootSound = cs
    end)
end

net.Receive("CUST_TG_SND", function()
    sendSound()
end)

net.Receive("CUST_TG_SND_BROADCAST", function()
    local ply = net.ReadEntity()
    local snd = net.ReadString()

    ply.Cust_Tlgn_Snd = snd
    applyToolgunSnd(ply)
end)

gameevent.Listen( "player_spawn" )
hook.Add( "player_spawn", "CustomToolgunSound_ApplyCL", function( data ) 
	local id = data.userid
    local ply = Player(id)

    applyToolgunSnd(ply)
end )

cvars.AddChangeCallback("custom_toolgun_sound", function(cvar, old, new)
    sendSound()
end)