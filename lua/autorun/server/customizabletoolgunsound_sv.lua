CreateConVar("custom_toolgun_sound_length", 3, FCVAR_REPLICATED, "Max length for toolgun sounds")

util.AddNetworkString("CUST_TG_SND")
util.AddNetworkString("CUST_TG_SND_BROADCAST")

local function requestString(ply)
    net.Start("CUST_TG_SND")
    net.Send(ply)
end

local function broadcastSnd(ply)
    net.Start("CUST_TG_SND_BROADCAST")
    net.WriteEntity(ply)
    net.WriteString(ply.Cust_Tlgn_Snd)
    net.Broadcast()
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

local function setToolgunSnd(ply, snd)
    ply.Cust_Tlgn_Snd = snd

    if game.SinglePlayer() then
        applyToolgunSnd(ply)
    else
        broadcastSnd(ply)
    end
end

net.Receive("CUST_TG_SND", function(len, ply)
    local snd = net.ReadString()

    setToolgunSnd(ply, snd)
end)

gameevent.Listen( "player_activate" )
hook.Add( "player_activate", "CustomToolgunSound_Init", function( data ) 
	local id = data.userid
    local ply = Player(id)

    requestString(ply)
end )

hook.Add("PlayerSpawn", "CustomToolgunSound_Apply", function(ply)
    applyToolgunSnd(ply)
end)