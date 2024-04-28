CreateClientConVar("custom_toolgun_sound", "sound/weapons/airboat/airboat_gun_lastshot1.wav", true, false, "What toolgun sound you should use.")

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

    local maxlength = GetConVar("custom_toolgun_sound_length"):GetFloat()
    if SoundDuration(snd) > maxlength then
        notification.AddLegacy("Sound must not be longer than "..maxlength.."!", NOTIFY_ERROR, 3)
        return
    end

    net.Start("CUST_TG_SND")
    net.WriteString(snd)
    net.SendToServer()
end

net.Receive("CUST_TG_SND", function()
    sendSound()
end)

cvars.AddChangeCallback("custom_toolgun_sound", function(cvar, old, new)
    sendSound()
end)