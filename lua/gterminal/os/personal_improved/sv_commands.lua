local gTerminal = gTerminal;
local timer = timer;
local OS = OS;


OS:NewCommand(":help", function(client, entity, arguments)
	gTerminal:Broadcast(entity, "=============================");
	gTerminal:Broadcast(entity, "  PersonalOS Help Menu");
	gTerminal:Broadcast(entity, "");
	gTerminal:Broadcast(entity, "    COMMANDS:");

	for k, v in SortedPairs( OS:GetCommands() ) do
		gTerminal:Broadcast(entity, "     "..k.." - "..v.help);
	end;

	gTerminal:Broadcast(entity, "=============================");
end, "Provides a list of help.");


OS:NewCommand(":cls", function(client, entity)
	for i = 0, 25 do
		timer.Simple(i * 0.05, function()
			if ( IsValid(entity) ) then
				gTerminal:Broadcast(entity, "", MSG_COL_NIL, i);
			end;
		end);
	end;
end, "Clears the screen.");


OS:NewCommand(":gid", function(client, entity)
	gTerminal:Broadcast( entity, "TERMINAL ID => "..entity:EntIndex() );
end, "Gets the terminal ID.");


OS:NewCommand(":setpass", function(client, entity, arguments)
	local password = table.concat(arguments, " ");

	if (password and password != "") then
		entity.password = password;
		gTerminal:Broadcast(entity, "Password set.");
	else
		entity.password = nil;
		gTerminal:Broadcast(entity, "Password removed.");
	end;
end, "Sets the password for the terminal.");


OS:NewCommand(":x", function(client, entity)
	gTerminal:Broadcast( entity, "SHUTTING DOWN..." );

	for k, v in pairs( player.GetAll() ) do
		v[ "pass_authed_"..entity:EntIndex() ] = nil;
	end;

	gTerminal.os:Call(entity, "ShutDown");
	
	timer.Simple(math.Rand(2, 5), function()
		if ( IsValid(entity) ) then
			for i = 0, 25 do
				if ( IsValid(entity) ) then
					gTerminal:Broadcast(entity, "");
				end;
			end;

			entity:SetActive(false);
		end;
	end);
end, "Turns off the terminal.");


local commands = {
	["cat"] = {
		func = function(client, ent, args)
			
		end,
		help = "Print the content of a file"
	},
	["cd"] = {
		func = function(client, ent, args)
			gTerminal.Improved.Filesystem:ChangeDirectory(ent, args[2])
		end,
		help = "Change the local working directory"
	},
	["ls"] = {
		func = function(client, ent, args)
			local tbl = gTerminal.Improved.Filesystem:GetFileNamesInLocalDirectory(ent)
			for _, name in ipairs(tbl) do
				gTerminal:Broadcast(ent, name)
			end
		end,
		help = "List file names in a local directory"
	},
	["mkdir"] = {
		func = function(client, ent, args)
			gTerminal.Improved.Filesystem:MakeDirectory(ent, args[2])
		end,
		help = "Create a directory in local file system"
	},
	["pwd"] = {
		func = function(client, ent, args)
			local dir = gTerminal.Improved.Filesystem:GetWorkingDirectory(ent)

			gTerminal:Broadcast(ent, dir)
		end,
		help = "Print the local working directory"
	},
}
OS:NewCommand(":f", function(client, ent, args)
	if !ent.gti_files then gTerminal.Improved.Filesystem:Initialize(ent) end

	local command = args[1]

	if !command or !commands[command] then
		for cmd, tbl in pairs(commands) do
			gTerminal:Broadcast(ent, cmd .. " - " .. tbl.help)
		end
		return
	end

	commands[command].func(client, ent, args)
end, "Filesystem")