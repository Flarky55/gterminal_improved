local Filesystem = {}


function Filesystem:Initialize(ent)
    ent.gti_files = {
        ["C:/"] = {
            _isdir = true,
            _name = "C:/"
        }
    }

    ent.gti_cur_dir = ent.gti_files["C:/"]
end

function Filesystem:MakeDirectory(ent, name)
    local cur_dir = ent.gti_cur_dir

    cur_dir[name] = {
        _name = name,
        _isdir = true,
        _parent = cur_dir,
    }

    return true
end

function Filesystem:GetWorkingDirectory(ent)
    local cur_dir = ent.gti_cur_dir
    local str = ""

    while cur_dir._parent do
        str = cur_dir._name .. "/" .. str 
        cur_dir = cur_dir._parent
    end
    str = "C:/" .. str

    return str
end

function Filesystem:GetFileNamesInLocalDirectory(ent)
    local cur_dir = ent.gti_cur_dir

    local tbl = {}
    for k, v in pairs(cur_dir) do
        if istable(v) and v._isdir and k != "_parent" then
            tbl[#tbl + 1] = v._name
        end
    end

    return tbl
end

function Filesystem:ChangeDirectory(ent, name)
    local cur_dir = ent.gti_cur_dir
    if cur_dir[name] then
        ent.gti_cur_dir = cur_dir[name] 
    end

    if name == ".." then
        ent.gti_cur_dir = cur_dir._parent or cur_dir
    end
end

gTerminal.Improved.Filesystem = Filesystem