AddCSLuaFile();

ENT.Type = "anim";
ENT.Base = "sent_computer";

ENT.maxChars = 140
ENT.maxLines = 50;


if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model or "models/props_phx/rt_screen.mdl");
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
	function ENT:Initialize()
		self.scrW = 2600;
		self.scrH = 1500;
		self.lineHeight = 28.7;
		self.consoleText = "";
	end;

	function ENT:Draw()
		self:DrawModel();

		if ( self:GetWarmingUp() or self:GetActive() ) then
			local angle = self:GetAngles();
			angle:RotateAroundAxis(angle:Forward(), 90);
			angle:RotateAroundAxis(angle:Right(), -90);
			if self.GetScreenAngles then angle = self:GetScreenAngles() end

			local pos = self:GetPos()
			if self.GetScreenPos then pos = self:GetScreenPos() end

			cam.Start3D2D(pos, angle, 0.0215);
				render.PushFilterMin(TEXFILTER.ANISOTROPIC);
				render.PushFilterMag(TEXFILTER.ANISOTROPIC);
					surface.SetDrawColor(self.BackroundColor or color_black);
					surface.DrawRect(0, 0, self.scrW, self.scrH);

					local lines = gTerminal[ self:EntIndex() ] or {};

					for i = 1, self.maxLines do
						if ( lines[i] ) then
							local color = gTerminal:ColorFromIndex(lines[i].color);

							draw.SimpleText(lines[i].text or "", "gT_ConsoleFont", 1, (28.7 * i) - 28.7, color, 0, 0);
						end;
					end;

					local y = (self.maxLines + 1) * self.lineHeight;

					surface.SetDrawColor(255, 255, 255, 15);
					surface.DrawRect(1, y, self.scrW - 1, self.lineHeight);

					if ( IsValid( self:GetUser() ) ) then
						if ( self:GetUser() != LocalPlayer() ) then
							self.consoleText = self:GetUser():Name().." is typing...";
						end;
					else
						self.consoleText = "";
					end;

					draw.SimpleText("> ".. (self.consoleText or ""), "gT_ConsoleFont", 1, y, color_white, 0, 0);

					if ( self:GetWarmingUp() ) then
						if (!self.flashTime) then
							self.flashTime = CurTime() + 0.25;
						end;

						local fraction = math.Clamp( ( self.flashTime - CurTime() ) / 0.25, 0, 1 );

						surface.SetDrawColor(255, 0, 0, 255);
						surface.DrawRect(0, 0, self.scrW / 3, self.scrH * fraction);

						surface.SetDrawColor(0, 255, 0, 255);
						surface.DrawRect(self.scrW / 3, 0, self.scrW / 3, self.scrH * fraction);

						surface.SetDrawColor(0, 0, 255, 255);
						surface.DrawRect( (self.scrW * 2) / 3, 0, self.scrW / 3, self.scrH * fraction );

						if (fraction < 1 and fraction > 0.75) then
							surface.SetDrawColor(math.random(100, 255), math.random(100, 255), math.random(100, 255), 255);
							surface.DrawRect(0, 0, self.scrW, self.scrH);
						elseif (fraction < 0.5) then
							draw.SimpleText("RES: "..self.scrW.."x"..self.scrH, "gT_ConsoleFont", self.scrW - 2, 2, Color(255, 255, 255, 255), 2, 0);
						end;
					elseif (self.flashTime) then
						self.flashTime = nil;
					end;
				render.PopFilterMin();
				render.PopFilterMag();
			cam.End3D2D();
		end;
	end;
end