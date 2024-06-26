local Filesystem = {}


util.AddNetworkString("gTerminal_Improved.Editor.Open")
util.AddNetworkString("gTerminal_Improved.Editor.Save")


Filesystem.commands = {
	["cd"] = {
		func = function(cl, ent, args)
			Filesystem.ChangeDir(ent, args[2])
		end,
		help = "Change Directory",
	},
	["mkdir"] = {
		func = function(cl, ent, args)
			Filesystem.CreateDir(ent, args[2])
		end,
		help = "Create Directory",
	},
	["ls"] = {
		func = function(cl, ent, args)
			local cur_dir = ent.cur_dir

			for k, v in pairs(cur_dir) do
				if istable(v) and k != "_parent" then
					gTerminal:Broadcast(ent, k, v._isdir and GT_COL_INFO or GT_COL_SUCC)
				end
			end
		end,
		help = "List all files",
	},
	["pwd"] = {
		func = function(cl, ent, args)
			local cur_dir = ent.cur_dir
			local str = ""

			while cur_dir._parent do
				str = cur_dir._name .. "/" .. str
				cur_dir = cur_dir._parent
			end

			gTerminal:Broadcast(ent, "C:/" .. str)
		end,
		help = "Print full path",
	},
	["touch"] = {
		func = function(cl, ent, args)
			local name = args[2] or "new_file.txt"
			
			local _file
			if name then _file = Filesystem.GetFile(ent, name) end

			net.Start("gTerminal_Improved.Editor.Open")
				net.WriteEntity(ent)
				net.WriteString(name)
				net.WriteString(_file and _file.content or "")
			net.Send(cl)
		end,
		help = "Create file",
	},
	["cat"] = {
		func = function(cl, ent, args)
			local file = Filesystem.GetFile(ent, args[2])

			if file and file.content then gTerminal:Broadcast(ent, file.content) end
		end,
		help = "Read file",
	},
	["rm"] = {
		func = function(cl, ent, args)
			Filesystem.RemoveObject(ent, args[2])
		end,
		help = "Remove object",
	},
}


local bad_names = {
    ["_isdir"] = true,
    ["_isfile"] = true,
    ["_name"] = true,
    ["_parent"] = true,
}


function Filesystem.Initialize(ent)
    ent.files = {
        ["C:/"] = {
            _isdir = true,
            _name = "C:/",
        }
    }

    ent.cur_dir = ent.files["C:/"]
end


function Filesystem.CreateDir(ent, name)
    local cur_dir = ent.cur_dir

    if !name or bad_names[name] then gTerminal:Broadcast(ent, "Invalid directory name!", GT_COL_ERR) return end
	if cur_dir[name] then gTerminal:Broadcast(ent, "Directory already exists!", GT_COL_ERR) return end

    cur_dir[name] = {
        _isdir = true,
        _name = name,
        _parent = cur_dir,
    }
end

function Filesystem.ChangeDir(ent, name)
    local cur_dir = ent.cur_dir

    if name == "../" then 
        ent.cur_dir = cur_dir._parent or cur_dir  
        return
	elseif !name then
		ent.cur_dir = ent.files["C:/"]
		return
    end

    if bad_names[name] then gTerminal:Broadcast(ent, "Invalid directory name!", GT_COL_ERR) return end
	if !cur_dir[name] then gTerminal:Broadcast(ent, "Directory is not exists!", GT_COL_ERR) return end

    ent.cur_dir = cur_dir[name]
end


function Filesystem.CreateFile(ent, name, content)
    local cur_dir = ent.cur_dir

    if !name or bad_names[name] then gTerminal:Broadcast(ent, "Invalid file name!", GT_COL_ERR) return end
	if cur_dir[name] then gTerminal:Broadcast(ent, "File already exists!", GT_COL_ERR) return end

    local extension = string.match(name, "^.+(%..+)$")

    cur_dir[name] = {
        _isfile = true,
        _name = name,
        _extension = extension,
        content = content or "",
    }
end

function Filesystem.EditFileContent(ent, name, new_content)
	local cur_dir = ent.cur_dir

	if !name or bad_names[name] then gTerminal:Broadcast(ent, "Invalid file name!", GT_COL_ERR) return end
	if !cur_dir[name] then gTerminal:Broadcast(ent, "File is not exists!", GT_COL_ERR) return end

	cur_dir[name].content = new_content
end

function Filesystem.GetFile(ent, name)
    local cur_dir = ent.cur_dir

    if !name or bad_names[name] then gTerminal:Broadcast(ent, "Invalid file name!", GT_COL_ERR) return end
	if !cur_dir[name] then gTerminal:Broadcast(ent, "File is not exists!", GT_COL_ERR) return end

    return cur_dir[name]
end

net.Receive("gTerminal_Improved.Editor.Save", function(len, ply)
	local ent = net.ReadEntity()
	local file_name, content = net.ReadString(), net.ReadString()

	if !IsValid(ent) or ( IsValid(ent) and !ent.SetOS or (ent.SetOS and ent:GetUser() != ply) ) then 
		ply:ChatPrint("ЭЭЭ, КУДА ПРЁШЬ?")
		return 
	end

	if Filesystem.GetFile(ent, file_name) then
		Filesystem.EditFileContent(ent, file_name, content)
	else
		Filesystem.CreateFile(ent, file_name, content)
	end
end)


function Filesystem.RemoveObject(ent, name)
    local cur_dir = ent.cur_dir

    if !name or bad_names[name] then gTerminal:Broadcast(ent, "Invalid name!", GT_COL_ERR) return end
	if !cur_dir[name] then gTerminal:Broadcast(ent, "File is not exists!", GT_COL_ERR) return end

    cur_dir[name] = nil 
end


gTerminal.Improved.Filesystem = Filesystem