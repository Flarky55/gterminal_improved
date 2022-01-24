AddCSLuaFile();

ENT.Type = "anim";
ENT.Base = "sent_computer";

ENT.Model = "models/props_phx/rt_screen.mdl"


if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model);
		self:SetMoveType(MOVETYPE_VPHYSICS);
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetSolid(SOLID_VPHYSICS);
		self:SetUseType(SIMPLE_USE);
		self:DrawShadow(false);
		self:SetActive(false);
		self:SetOS("default");
		
		local physicsObject = self:GetPhysicsObject();

		if ( IsValid(physicsObject) ) then
			physicsObject:Wake();
			physicsObject:EnableMotion(true);
		end;
	end;
end


if CLIENT then
	local cam = cam
	local surface = surface
	local draw = draw


	function ENT:Initialize() 
		self.scrW = self.scrW or 905;
		self.scrH = self.scrH or 768;
		self.maxChars = self.maxChars or 50;
		self.maxLines = self.maxLines or 24;
		self.lineHeight = self.lineHeight or 28.7;
		self.consoleText = "";
	end


	function ENT:Draw()
		self:DrawModel();

		if ( self:GetWarmingUp() or self:GetActive() ) then
			local angle
			if self.GetScreenAngles then 
				angle = self:GetScreenAngles()
			else
				angle = self:GetAngles();
				angle:RotateAroundAxis(angle:Forward(), 90);
				angle:RotateAroundAxis(angle:Right(), -90);
			end

			local pos = self.GetScreenPos and self:GetScreenPos() or self:GetPos()
			

			cam.Start3D2D(pos, angle, 0.0215);
				render.PushFilterMin(TEXFILTER.ANISOTROPIC);
				render.PushFilterMag(TEXFILTER.ANISOTROPIC);


					surface.SetDrawColor(self.BackroundColor or color_black);
					surface.DrawRect(0, 0, self.scrW, self.scrH);

					local lines = gTerminal[ self:EntIndex() ] or {};
					for i = 1, self.maxLines do
						if ( lines[i] ) then
							local color = gTerminal:ColorFromIndex(lines[i].color);

							draw.SimpleText(lines[i].text or "", "gT_ConsoleFont", 1, (self.lineHeight * i) - self.lineHeight, color, 0, 0);
						end;
					end;

					local y = (self.maxLines + 1) * self.lineHeight;
					surface.SetDrawColor(255, 255, 255, 15);
					surface.DrawRect(1, y, self.scrW - 1, self.lineHeight);


					if IsValid(self:GetUser()) then
						if self:GetUser() != LocalPlayer() then
							self.consoleText = self:GetUser():Name().." is typing...";
						end;
					else
						self.consoleText = "";
					end;

					draw.SimpleText("> ".. (self.consoleText or ""), "gT_ConsoleFont", 1, y, color_white, 0, 0);


					if ( self:GetWarmingUp() ) then
						draw.SimpleText("RES: " .. self.scrW .. "x" .. self.scrH, "gT_ConsoleFont", self.scrW - 2, 2, color_white, 2, 0);
					end


				render.PopFilterMin();
				render.PopFilterMag();
			cam.End3D2D();
		end;
	end;
end