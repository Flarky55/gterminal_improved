local gTerminal = gTerminal;
local Filesystem = gTerminal.Improved.Filesystem
local GNet = gTerminal.Improved.GNet
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
		gTerminal:Broadcast(entity, "Password set to '"..entity.password.."'.");
	else
		entity.password = nil;
		gTerminal:Broadcast(entity, "Removed password.");
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


local f_commands = Filesystem.commands
OS:NewCommand(":f", function(client, entity, arguments)
	if !entity.cur_dir then Filesystem.Initialize(entity) end

	local command = arguments[1]

	if !command or !f_commands[command] then
		gTerminal:Broadcast(entity, "File System");
		gTerminal:Broadcast(entity, "  INFO:");
		gTerminal:Broadcast(entity, "    This is the terminal's file system.");
		gTerminal:Broadcast(entity, "  HELP:");
		for name, tbl in pairs(f_commands) do
			gTerminal:Broadcast(entity, "    " .. name .. " - " .. tbl.help)
		end

		return
	end

	f_commands[command].func(client, entity, arguments)
end, "Terminal file protocol.")


local gnet_commands = table.Copy(GNet.commands.shared)
table.Merge(gnet_commands, GNet.commands.client)
OS:NewCommand(":gnet", function(client, entity, arguments)
	local command = arguments[1]

	if !command or !gnet_commands[command] then
		gTerminal:Broadcast(entity, "Global Network Mark II");
		gTerminal:Broadcast(entity, "  INFO:");
		gTerminal:Broadcast(entity, "    Allows you to create networks.");
		gTerminal:Broadcast(entity, "  HELP:");
		for name, tbl in pairs(gnet_commands) do
			gTerminal:Broadcast(entity, "    " .. name .. " - " .. tbl.help)
		end

		return
	end

	gnet_commands[command].func(client, entity, arguments)
end, "Global networking platform.")