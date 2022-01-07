local init = function()
    MsgC(Color(0,255,0), "Initialized gTerminal-Improved!\n")

    if !gTerminal then
        return MsgC(Color(255, 0, 0), "!!!gTerminal not found!!!\n") 
    end


    gTerminal.Improved = gTerminal.Improved or {}


    include("gterminal_improved/sv_filesystem.lua")


    MsgC(Color(0, 255, 0), "Successfully Loaded gTerminal-Improved!\n")
end


hook.Add("Initialize", "gTerminal_Improved", init)
init()