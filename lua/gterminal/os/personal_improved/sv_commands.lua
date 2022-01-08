local gTerminal = gTerminal;
local Filesystem = gTerminal.Improved.Filesystem
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


local f_commands = {
	["mkdir"] = {
		func = function(client, entity, arguments)
			Filesystem.MakeDirectory(entity, arguments[2])
		end,
		help = "Create a directory in local file system"
	},
	["pwd"] = {
		func = function(client, entity, arguments)
			local cur_dir = entity.current_directory
			local str = ""
		
			while cur_dir._parent do
				str = cur_dir._name .. "/" .. str 
				cur_dir = cur_dir._parent
			end
			str = "C:/" .. str


			gTerminal:Broadcast(entity, str)
		end,
		help = "Print the local working directory"
	},
	["cd"] = {
		func = function(client, entity, arguments)
			Filesystem.ChangeDirectory(entity, arguments[2])
		end,
		help = "Change the local working directory"
	},
	["ls"] = {
		func = function(client, entity, arguments)
			local cur_dir = entity.current_directory

			for k, v in pairs(cur_dir) do
				if istable(v) and k != "_parent" then
					gTerminal:Broadcast(entity, v._name, v._isdir and GT_COL_INFO or GT_COL_SUCC)
				end
			end
		end,
		help = "List file names in a local directory"
	},
	["rm"] = {
		func = function(client, entity, arguments)
			Filesystem.RemoveDirectory(entity, arguments[2])
		end,
		help = "Remove a file or directory"
	},
	["touch"] = {
		func = function(client, entity, arguments)
			Filesystem.MakeFile(entity, arguments[2])
		end,
		help = "Touch a file"
	},
	["cat"] = {
		func = function(client, entity, arguments)
			local file = Filesystem.GetFile(entity, arguments[2])

			if file and file.content then
				gTerminal:Broadcast(entity, file.content, GT_COL_MSG)
			end
		end,
		help = "Print the content of a file"
	}
}
OS:NewCommand(":f", function(client, entity, arguments)
	if !entity.files then Filesystem.Initialize(entity) end

	local command = arguments[1]

	if !command or !f_commands[command] then
		gTerminal:Broadcast(entity, "=============================")
		gTerminal:Broadcast(entity, " File system Help:")
		gTerminal:Broadcast(entity, "")
		for name, tbl in pairs(f_commands) do
			gTerminal:Broadcast(entity, "   " .. name .. " - " .. tbl.help)
		end
		gTerminal:Broadcast(entity, "=============================")

		return
	end

	f_commands[command].func(client, entity, arguments)
end, "File system")