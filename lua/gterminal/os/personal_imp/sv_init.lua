local OS = OS;


AddCSLuaFile("gterminal_improved/sh_init.lua")
include("gterminal_improved/sh_init.lua")


include("sv_commands.lua");


function OS:GetName()
	return "PersonalOS";
end;

function OS:GetUniqueID()
	return GetConVar("gt_os_override"):GetBool() and "personal" or "personal_imp";
end;

function OS:GetWarmUpText()
	return {
		"  ___ ___ ___  ___  ___  _  _   _   _    ",
		" | _ \\ __| _ \\/ __|/ _ \\| \\| | /_\\ | |   ",
		" |  _/ _||   /\\__ \\ (_) | .` |/ _ \\| |__ ",
		" |_| |___|_|_\\|___/\\___/|_|\\_/_/ \\_\\____|",
		" The operating system for your personal needs.",
		"   Improved build 100122",
	};
end;