local Filesystem = {}

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
			Filesystem.CreateFile(ent, args[2], args[3])
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

    if !name or bad_names[name] or cur_dir[name] then return end

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
    end

    if !name or bad_names[name] or !cur_dir[name] then return end

    ent.cur_dir = cur_dir[name]
end


function Filesystem.CreateFile(ent, name, content)
    local cur_dir = ent.cur_dir

    if !name or bad_names[name] or cur_dir[name] then return end

    local extension = string.match(name, "^.+(%..+)$")

    cur_dir[name] = {
        _isfile = true,
        _name = name,
        _extension = extension,
        content = content or "",
    }
end

function Filesystem.GetFile(ent, name)
    local cur_dir = ent.cur_dir

    if !name or bad_names[name] or !cur_dir[name] then return end

    return cur_dir[name]
end


function Filesystem.RemoveObject(ent, name)
    local cur_dir = ent.cur_dir

    if !name or bad_names[name] or !cur_dir[name] then return end

    return cur_dir[name]
end


gTerminal.Improved.Filesystem = Filesystem