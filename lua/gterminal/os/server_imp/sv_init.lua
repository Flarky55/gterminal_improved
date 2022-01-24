include("sv_commands.lua");

function OS:GetName()
	return "ServerOS";
end;

function OS:GetUniqueID()
	return GetConVar("gt_os_override"):GetBool() and "server" or "server_imp";
end;

function OS:GetWarmUpText()
	return {
		" _____                    ",
		"|   __|___ ___ _ _ ___ ___",
		"|__   | -_|  _| | | -_|  _|",
		"|_____|___|_|  \\_/|___|_|  ",
		"-OPERATING SYSTEM V1-",
		"   Improved build 100122"
	};
end;

function OS:ShutDown(entity)
	if entity.gnet_host then
		gTerminal.Improved.GNet	.Remove(entity)
	end;
end;