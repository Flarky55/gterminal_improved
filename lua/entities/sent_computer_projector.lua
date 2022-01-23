AddCSLuaFile()

ENT.Type = "anim";
ENT.Base = "sent_computer_base";

ENT.Model = "models/maxofs2d/motion_sensor.mdl"
ENT.PrintName = "Projector";
ENT.Category = "gTerminal";
ENT.Spawnable = true

ENT.BackroundColor = Color(0, 0, 0, 225)


function ENT:GetScreenPos()
    local angle = self:GetAngles()

    local offset = angle:Up() * 38.2 + angle:Forward() * 10 + angle:Right() * 27.9

    return self:GetPos() + offset
end

function ENT:GetScreenAngles()
    local angle = self:GetAngles()
    angle:RotateAroundAxis(angle:Up(), 90)
    angle:RotateAroundAxis(angle:Forward(), 80)

    return angle
end