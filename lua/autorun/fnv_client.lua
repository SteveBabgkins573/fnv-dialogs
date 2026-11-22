-- FNV Dialogs: client UI, camera, input
if not CLIENT then return end

include("fnv_dialogs/lang.lua")

FNV = FNV or {}
FNV.Active = false
FNV.NPC = nil
FNV.Options = {}
FNV.Sel = 1
FNV.Enemy = false
FNV.Name = ""
FNV.Greeting = ""
FNV.Reply = nil
FNV.Answered = false
FNV.StartedAt = 0
FNV.Lang = FNV_LANG.Detect()

surface.CreateFont("FNV_Name", { font = "Roboto", size = 24, weight = 700 })
surface.CreateFont("FNV_Text", { font = "Roboto", size = 18, weight = 500 })
surface.CreateFont("FNV_Option", { font = "Roboto", size = 17, weight = 500 })
surface.CreateFont("FNV_Small", { font = "Roboto", size = 14, weight = 500 })

local C_FRIEND = Color(232, 193, 112)
local C_ENEMY = Color(225, 92, 84)
local C_TEXT = Color(235, 232, 220)
local C_DIM = Color(155, 152, 142)
local C_PANEL = Color(10, 10, 10, 228)

local function T(key)
    return FNV_LANG.Get(FNV.Lang, key)
end

-- Send detected language to the server
hook.Add("InitPostEntity", "FNV_SendLang", function()
    timer.Simple(0.5, function()
        net.Start("FNV_LANG")
            net.WriteString(FNV.Lang)
        net.SendToServer()
    end)
end)

local function RequestSpawn(enemy)
    net.Start("FNV_SPAWN")
        net.WriteBool(enemy)
    net.SendToServer()
end

local function RequestClear()
    net.Start("FNV_CLEAR")
    net.SendToServer()
end

local function OpenMenu()
    if IsValid(FNV.Menu) then FNV.Menu:Remove() end

    local f = vgui.Create("DFrame")
    f:SetSize(380, 250)
    f:Center()
    f:SetTitle("FNV Dialogs")
    f:MakePopup()

    local y = 45
    local function add(text, fn)
        local b = vgui.Create("DButton", f)
        b:SetPos(20, y)
        b:SetSize(340, 40)
        b:SetText(text)
        b.DoClick = fn
        y = y + 48
    end

    add(T("friendly_name"), function() RequestSpawn(false) end)
    add(T("enemy_name"), function() RequestSpawn(true) end)
    add("Clear all", RequestClear)

    local c = vgui.Create("DButton", f)
    c:SetPos(20, y)
    c:SetSize(340, 36)
    c:SetText(T("bye"))
    c.DoClick = function() f:Close() end

    FNV.Menu = f
    f.OnRemove = function() FNV.Menu = nil end
end

concommand.Add("fnv_menu", OpenMenu)
concommand.Add("fnv_spawn", function() RequestSpawn(false) end)
concommand.Add("fnv_spawn_enemy", function() RequestSpawn(true) end)
concommand.Add("fnv_clear", RequestClear)

-- Hotkeys: F6 friendly NPC, F7 enemy NPC, F8 remove all
hook.Add("PlayerButtonDown", "FNV_Hotkeys", function(ply, button)
    if button == KEY_F6 then
        RequestSpawn(false)
    elseif button == KEY_F7 then
        RequestSpawn(true)
    elseif button == KEY_F8 then
        RequestClear()
    end
end)

local function CloseDialog()
    if not FNV.Active then return end
    FNV.Active = false
    FNV.NPC = nil
    FNV.Reply = nil
    FNV.Answered = false
    net.Start("FNV_END")
    net.SendToServer()
end

local function Confirm()
    if not FNV.Active or FNV.Answered then return end
    if CurTime() - FNV.StartedAt < 0.35 then return end
    FNV.Answered = true
    net.Start("FNV_SELECT")
        net.WriteUInt(FNV.Sel, 4)
        net.WriteString(FNV.Lang)
    net.SendToServer()
end

net.Receive("FNV_OPEN_MENU", function() OpenMenu() end)

net.Receive("FNV_START", function()
    FNV.NPC = net.ReadEntity()
    FNV.Enemy = net.ReadBool()
    FNV.Name = net.ReadString()
    FNV.Lang = FNV_LANG.Detect()
    FNV.Sel = 1
    FNV.Reply = nil
    FNV.Answered = false
    FNV.StartedAt = CurTime()
    FNV.Greeting = T(FNV.Enemy and "threat" or "hello")
    if FNV.Enemy then
        FNV.Options = { T("leave"), T("surrender"), T("regret") }
    else
        FNV.Options = { T("pass"), T("fine"), T("nojob"), T("bye") }
    end
    FNV.Active = true
end)

net.Receive("FNV_REPLY", function()
    FNV.Reply = net.ReadString()
end)

net.Receive("FNV_END", function()
    FNV.Active = false
    FNV.NPC = nil
    FNV.Reply = nil
    FNV.Answered = false
end)

-- Camera: over-the-shoulder view aimed at the NPC
hook.Add("CalcView", "FNV_Cam", function(ply, pos, ang, fov)
    if not FNV.Active or not IsValid(FNV.NPC) then return end

    local npc = FNV.NPC
    local target = npc:GetPos() + Vector(0, 0, 68)
    local base = ply:GetPos() + Vector(0, 0, 64)
    local flat = target - base
    flat.z = 0
    if flat:LengthSqr() < 1 then return end
    flat:Normalize()

    local right = Vector(-flat.y, flat.x, 0)
    local camPos = base + right * 52 + flat * 8 + Vector(0, 0, 6)

    local tr = util.TraceLine({
        start = target,
        endpos = camPos,
        filter = { ply, npc },
        mask = MASK_SOLID_BRUSHONLY,
    })
    if tr.Hit then camPos = tr.HitPos + tr.HitNormal * 6 end

    local look = target - camPos
    return {
        origin = camPos,
        angles = look:Angle(),
        fov = 55,
        drawviewer = true,
    }
end)

-- W/S or mouse wheel to select, E or LMB to answer
local lastNav = 0
local useHeld, attackHeld = false, false

hook.Add("CreateMove", "FNV_Input", function(cmd)
    if not FNV.Active then return end

    -- Read buttons BEFORE clearing them, otherwise KeyDown always returns false
    local fwd = cmd:KeyDown(IN_FORWARD)
    local back = cmd:KeyDown(IN_BACK)
    local use = cmd:KeyDown(IN_USE)
    local attack = cmd:KeyDown(IN_ATTACK)

    cmd:ClearMovement()
    cmd:SetButtons(0)

    if FNV.Answered then
        useHeld, attackHeld = use, attack
        return
    end

    local now = CurTime()
    if fwd and now - lastNav > 0.16 then
        FNV.Sel = math.max(1, FNV.Sel - 1)
        lastNav = now
    elseif back and now - lastNav > 0.16 then
        FNV.Sel = math.min(#FNV.Options, FNV.Sel + 1)
        lastNav = now
    end

    if (use and not useHeld) or (attack and not attackHeld) then
        Confirm()
    end
    useHeld, attackHeld = use, attack
end)

hook.Add("PlayerBindPress", "FNV_Binds", function(ply, bind, pressed)
    if not FNV.Active then return end

    if bind == "cancelselect" then
        if pressed then CloseDialog() end
        return true
    end

    if bind == "invprev" then
        if pressed and not FNV.Answered then
            FNV.Sel = math.max(1, FNV.Sel - 1)
        end
        return true
    end

    if bind == "invnext" then
        if pressed and not FNV.Answered then
            FNV.Sel = math.min(#FNV.Options, FNV.Sel + 1)
        end
        return true
    end

    if bind == "+use" or bind == "+attack" then
        if pressed and not FNV.Answered then Confirm() end
        return true
    end

    if bind == "+attack" or bind == "+attack2" or bind == "+reload" or bind == "+zoom"
        or bind == "lastinv" or bind == "slot1" or bind == "slot2" or bind == "slot3"
        or bind == "slot4" or bind == "slot5" or bind == "slot6" or bind == "slot7"
        or bind == "slot8" or bind == "slot9" or bind == "slot10" then
        return true
    end
end)

hook.Add("OnGameUIHidden", "FNV_GameUI", function()
    if FNV.Active then CloseDialog() end
end)

-- Hide only gameplay HUD elements, never the whole HUD (HUDPaint must keep running)
local HIDE_DURING_DIALOG = {
    CHudHealth = true,
    CHudBattery = true,
    CHudAmmo = true,
    CHudSecondaryAmmo = true,
    CHudCrosshair = true,
    CHudWeaponSelection = true,
    CHudZoom = true,
    CHudDamageIndicator = true,
    CHudPoisonDamageIndicator = true,
    CHudSuitPower = true,
    CHudHistoryResource = true,
}

hook.Add("HUDShouldDraw", "FNV_HUD", function(name)
    if FNV.Active and HIDE_DURING_DIALOG[name] then return false end
end)

hook.Add("Think", "FNV_Validate", function()
    if FNV.Active and not IsValid(FNV.NPC) then
        FNV.Active = false
        FNV.NPC = nil
        FNV.Reply = nil
        net.Start("FNV_END")
        net.SendToServer()
    end
end)

local function DrawWrapped(text, font, x, y, maxw, col)
    surface.SetFont(font)
    local words = {}
    for w in string.gmatch(text or "", "%S+") do words[#words + 1] = w end

    local lines, line = {}, ""
    for _, w in ipairs(words) do
        local test = (line == "") and w or (line .. " " .. w)
        if surface.GetTextSize(test) > maxw and line ~= "" then
            lines[#lines + 1] = line
            line = w
        else
            line = test
        end
    end
    if line ~= "" then lines[#lines + 1] = line end

    for i, l in ipairs(lines) do
        draw.SimpleText(l, font, x, y + (i - 1) * 26, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
end

hook.Add("HUDPaint", "FNV_UI", function()
    local w, h = ScrW(), ScrH()

    if not FNV.Active then
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        local tr = ply:GetEyeTrace()
        local e = tr.Entity
        if IsValid(e) and e:GetNWBool("FNV_Talker", false)
            and tr.HitPos:Distance(ply:EyePos()) < 300 then
            local txt = T("hint")
            surface.SetFont("FNV_Option")
            local tw, th = surface.GetTextSize(txt)
            local x, y = w / 2, h / 2 + 55
            surface.SetDrawColor(0, 0, 0, 170)
            surface.DrawRect(x - tw / 2 - 12, y - 6, tw + 24, th + 12)
            draw.SimpleText(txt, "FNV_Option", x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
        return
    end

    local col = FNV.Enemy and C_ENEMY or C_FRIEND
    local pw = math.min(w * 0.86, 860)
    local px = (w - pw) / 2
    local py = h * 0.38
    local ph = h * 0.58

    surface.SetDrawColor(0, 0, 0, 110)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(C_PANEL)
    surface.DrawRect(px, py, pw, ph)
    surface.SetDrawColor(col.r, col.g, col.b, 200)
    surface.DrawOutlinedRect(px, py, pw, ph, 2)
    surface.DrawRect(px, py, pw, 3)

    local name = FNV.Name ~= "" and FNV.Name or T(FNV.Enemy and "enemy_name" or "friendly_name")
    draw.SimpleText(name, "FNV_Name", w / 2, py + 10, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    draw.SimpleText(T("dialog"), "FNV_Small", w / 2, py + 44, C_DIM, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

    DrawWrapped(FNV.Reply or FNV.Greeting, "FNV_Text", w / 2, py + 66, pw - 80, C_TEXT)

    if FNV.Reply then
        draw.SimpleText("...", "FNV_Text", w / 2, py + ph - 62, C_DIM, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    else
        local oy = py + ph * 0.44
        for i, opt in ipairs(FNV.Options) do
            local sel = (i == FNV.Sel)
            if sel then
                surface.SetDrawColor(col.r, col.g, col.b, 45)
                surface.DrawRect(px + 28, oy - 4, pw - 56, 32)
                surface.SetDrawColor(col.r, col.g, col.b, 210)
                surface.DrawRect(px + 28, oy - 4, 3, 32)
            end
            draw.SimpleText((sel and "> " or "  ") .. opt, "FNV_Option", w / 2, oy,
                sel and col or C_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            oy = oy + 34
        end
    end

    draw.SimpleText(T("controls"), "FNV_Small", w / 2, py + ph - 26, C_DIM, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end)
