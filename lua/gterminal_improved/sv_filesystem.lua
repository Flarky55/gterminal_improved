local Filesystem = {}


local names_blacklist = {
    ["_parent"] = true,
    ["_isdir"] = true,
    ["_isfile"] = true,
    ["_name"] = true,
}


function Filesystem.Initialize(ent)
    ent.files = {
        ["C:/"] = {
            _isdir = true,
            _name = "C:/"
        }
    }
    
    ent.current_directory = ent.files["C:/"]
end


function Filesystem.MakeDirectory(ent, name)
    local cur_dir = ent.current_directory

    if !name then return end

    if names_blacklist[name] then
        gTerminal:Broadcast(ent, "Invalid name!", GT_COL_ERR)
        return
    end

    if cur_dir[name] then
        gTerminal:Broadcast(ent, "Directory already exists!", GT_COL_ERR)
        return
    end

    cur_dir[name] = {
        _isdir = true,
        _name = name,
        _parent = cur_dir,
    }
end

function Filesystem.RemoveDirectory(ent, name)
    local cur_dir = ent.current_directory

    if !name then return end

    if names_blacklist[name] then
        gTerminal:Broadcast(ent, "Invalid name!", GT_COL_ERR)
        return
    end

    if !cur_dir[name] then
        gTerminal:Broadcast(ent, "Directory is not exists!", GT_COL_ERR)
        return
    end

    cur_dir[name] = nil
end

function Filesystem.ChangeDirectory(ent, name)
    local cur_dir = ent.current_directory

    if !name then return end

    if names_blacklist[name] then
        gTerminal:Broadcast(ent, "Invalid name!", GT_COL_ERR)
        return
    end

    if name == "../" then ent.current_directory = cur_dir._parent or cur_dir return end
    if cur_dir[name] then ent.current_directory = cur_dir[name] end
end


function Filesystem.MakeFile(ent, name)
    local cur_dir = ent.current_directory

    if !name then return end

    if names_blacklist[name] then
        gTerminal:Broadcast(ent, "Invalid name!", GT_COL_ERR)
        return
    end

    name = name .. ".txt"
    cur_dir[name] = {
        _isfile = true,
        _name = name,
    }
end

function Filesystem.GetFile(ent, name)
    local cur_dir = ent.current_directory

    if !name then return end

    if names_blacklist[name] then
        gTerminal:Broadcast(ent, "Invalid name!", GT_COL_ERR)
        return
    end

    return cur_dir[name .. ".txt"]
end

gTerminal.Improved.Filesystem = Filesystem