-- FNV Dialogs: server logic (spawn, use, dialogue state)
if not SERVER then return end

AddCSLuaFile("fnv_dialogs/lang.lua")
AddCSLuaFile("autorun/fnv_client.lua")
include("fnv_dialogs/lang.lua")

util.AddNetworkString("FNV_START")
util.AddNetworkString("FNV_REPLY")
util.AddNetworkString("FNV_END")
util.AddNetworkString("FNV_SELECT")
util.AddNetworkString("FNV_LANG")
util.AddNetworkString("FNV_OPEN_MENU")
util.AddNetworkString("FNV_SPAWN")
util.AddNetworkString("FNV_CLEAR")

FNV = FNV or {}

local function Tr(ply, key)
    local lang = "english"
    if IsValid(ply) and ply.FNV_Lang and FNV_LANG.L[ply.FNV_Lang] then
        lang = ply.FNV_Lang
    end
    return FNV_LANG.Get(lang, key)
end

local function EndDialog(ply)
    if not IsValid(ply) or not ply.FNV_Busy then return end
    ply.FNV_Busy = false
    ply.FNV_Answered = false
    ply.FNV_Cooldown = CurTime() + 0.5
    local npc = ply.FNV_NPC
    if IsValid(npc) then npc.FNV_Talking = nil end
    ply.FNV_NPC = nil
    net.Start("FNV_END")
    net.Send(ply)
end

local function StartDialog(ply, npc)
    if not IsValid(ply) or not IsValid(npc) then return end
    if ply.FNV_Busy then return end
    if (ply.FNV_Cooldown or 0) > CurTime() then return end
    if ply:GetPos():Distance(npc:GetPos()) > 350 then return end

    ply.FNV_Busy = true
    ply.FNV_Answered = false
    ply.FNV_NPC = npc
    npc.FNV_Talking = ply

    local a = (ply:GetPos() - npc:GetPos()):Angle()
    npc:SetAngles(Angle(0, a.y, 0))
    if npc.SetIdealYaw then npc:SetIdealYaw(a.y) end

    net.Start("FNV_START")
        net.WriteEntity(npc)
        net.WriteBool(npc:GetNWBool("FNV_Enemy", false))
        net.WriteString(npc:GetNWString("FNV_Name", ""))
    net.Send(ply)
end

local function MakeHostile(npc, ply)
    if not IsValid(npc) or not IsValid(ply) then return end
    if npc.SetNPCState then npc:SetNPCState(NPC_STATE_NONE) end
    npc:AddEntityRelationship(ply, D_HT, 99)
    if npc.SetEnemy then npc:SetEnemy(ply) end
    if npc.SetSchedule then npc:SetSchedule(SCHED_CHASE_ENEMY) end
end

-- E on a talker NPC
hook.Add("PlayerUse", "FNV_PlayerUse", function(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    if not ent:GetNWBool("FNV_Talker", false) then return end
    if ply.FNV_Busy then return false end
    StartDialog(ply, ent)
    return false
end)

-- Fallback: some NPCs do not trigger PlayerUse on Linux/listen servers
hook.Add("PlayerTick", "FNV_UseFallback", function(ply)
    if not IsValid(ply) then return end
    local down = ply:KeyDown(IN_USE)
    if down and not ply.FNV_UseHeld and not ply.FNV_Busy then
        local tr = ply:GetEyeTrace()
        local ent = tr.Entity
        if IsValid(ent) and ent:GetNWBool("FNV_Talker", false)
            and tr.HitPos:Distance(ply:EyePos()) < 300 then
            StartDialog(ply, ent)
        end
    end
    ply.FNV_UseHeld = down
end)

hook.Add("PlayerDeath", "FNV_Death", function(ply)
    EndDialog(ply)
end)

-- Client sends its detected game language once after joining
net.Receive("FNV_LANG", function(_, ply)
    local lang = net.ReadString()
    if FNV_LANG.L[lang] then ply.FNV_Lang = lang end
end)

net.Receive("FNV_END", function(_, ply)
    EndDialog(ply)
end)

net.Receive("FNV_SELECT", function(_, ply)
    if not IsValid(ply) or not ply.FNV_Busy or ply.FNV_Answered then return end
    local i = net.ReadUInt(4)
    local lang = net.ReadString()
    if not FNV_LANG.L[lang] then lang = "english" end
    ply.FNV_Lang = lang
    ply.FNV_Answered = true

    local npc = ply.FNV_NPC
    if not IsValid(npc) then EndDialog(ply) return end

    local enemy = npc:GetNWBool("FNV_Enemy", false)
    local reply, hostile

    if enemy then
        if i == 1 then
            reply = FNV_LANG.Get(lang, "out")
        elseif i == 2 then
            reply = FNV_LANG.Get(lang, "never")
            hostile = true
        elseif i == 3 then
            reply = FNV_LANG.Get(lang, "asked")
            hostile = true
        else
            reply = FNV_LANG.Get(lang, "out")
        end
    else
        if i == 1 then
            reply = FNV_LANG.Get(lang, "safe")
        elseif i == 2 then
            reply = FNV_LANG.Get(lang, "good")
        elseif i == 3 then
            reply = FNV_LANG.Get(lang, "later")
        else
            reply = FNV_LANG.Get(lang, "bye")
        end
    end

    if hostile then
        -- Combat starts at once, so the player is not frozen in the dialogue camera
        ply:ChatPrint(reply)
        EndDialog(ply)
        timer.Simple(0.15, function()
            if IsValid(ply) and IsValid(npc) then MakeHostile(npc, ply) end
        end)
    else
        net.Start("FNV_REPLY")
            net.WriteString(reply)
        net.Send(ply)
        timer.Simple(2.2, function()
            if IsValid(ply) then EndDialog(ply) end
        end)
    end
end)

local function SpawnTalker(ply, enemy)
    if not IsValid(ply) then return end

    local aim = ply:GetAimVector()
    local eye = ply:EyePos()
    local tr = util.TraceLine({
        start = eye,
        endpos = eye + aim * 240,
        filter = ply,
        mask = MASK_SOLID_BRUSHONLY,
    })
    local pos = tr.HitPos - aim * 55

    local npc = ents.Create(enemy and "npc_combine_s" or "npc_citizen")
    if not IsValid(npc) then return end

    npc:SetPos(pos)
    if enemy then
        npc:SetKeyValue("additionalequipment", "weapon_smg1")
    else
        local models = {
            "models/humans/group01/male_01.mdl",
            "models/humans/group01/male_02.mdl",
            "models/humans/group01/female_01.mdl",
            "models/humans/group01/female_02.mdl",
        }
        npc:SetModel(models[math.random(#models)])
    end

    npc:Spawn()
    npc:Activate()

    if npc.SetNPCState then npc:SetNPCState(NPC_STATE_SCRIPT) end
    if npc.SetSchedule then npc:SetSchedule(SCHED_IDLE_STAND) end
    npc:SetUseType(SIMPLE_USE)
    npc:AddEntityRelationship(ply, enemy and D_NU or D_LI, 99)
    npc:SetNWBool("FNV_Talker", true)
    npc:SetNWBool("FNV_Enemy", enemy)
    npc:SetNWString("FNV_Name", Tr(ply, enemy and "enemy_name" or "friendly_name"))
    npc:DropToFloor()

    local a = (ply:GetPos() - npc:GetPos()):Angle()
    npc:SetAngles(Angle(0, a.y, 0))
end

local function ClearTalkers(ply)
    local n = 0
    for _, p in ipairs(player.GetAll()) do
        if IsValid(p) and p.FNV_Busy then EndDialog(p) end
    end
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:GetNWBool("FNV_Talker", false) then
            ent:Remove()
            n = n + 1
        end
    end
    if IsValid(ply) then ply:ChatPrint("FNV: removed " .. n) end
end

net.Receive("FNV_SPAWN", function(_, ply)
    if not IsValid(ply) then return end
    SpawnTalker(ply, net.ReadBool())
end)

net.Receive("FNV_CLEAR", function(_, ply)
    ClearTalkers(ply)
end)

concommand.Add("fnv_spawn", function(ply)
    if IsValid(ply) then SpawnTalker(ply, false) end
end)

concommand.Add("fnv_spawn_enemy", function(ply)
    if IsValid(ply) then SpawnTalker(ply, true) end
end)

concommand.Add("fnv_clear", function(ply)
    ClearTalkers(ply)
end)

hook.Add("PlayerSay", "FNV_Chat", function(ply, text)
    if not IsValid(ply) then return end
    local t = string.lower(text or "")
    if t == "!dialog" or t == "/dialog" then
        net.Start("FNV_OPEN_MENU")
        net.Send(ply)
        return ""
    elseif t == "!npc" then
        SpawnTalker(ply, false)
        return ""
    elseif t == "!enemy" then
        SpawnTalker(ply, true)
        return ""
    end
    if ply.FNV_Busy then return "" end
end)
