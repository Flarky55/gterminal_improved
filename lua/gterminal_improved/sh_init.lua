local gTerminal = gTerminal
gTerminal.Improved = gTerminal.Improved or {}

MsgC(Color(0, 255, 0), "Initialized gTerminal Improved!\n")


GT_COL_NIL = 0;
GT_COL_MSG = 1;
GT_COL_WRN = 2;
GT_COL_ERR = 3;
GT_COL_INFO = 4;
GT_COL_INTL = 5;
GT_COL_CMD = 6;
GT_COL_SUCC = 7;

local colors = {
    [GT_COL_NIL] = Color(50, 50, 50),
    [GT_COL_MSG] = Color(200, 200, 200),
    [GT_COL_WRN] = Color(255, 250, 50),
    [GT_COL_ERR] = Color(255, 50, 50),
    [GT_COL_INFO] = Color(60, 100, 250),
    [GT_COL_INTL] = Color(60, 250, 250),
    [GT_COL_CMD] = Color(125, 125, 125),
    [GT_COL_SUCC] = Color(75, 255, 80)
}

function gTerminal:ColorFromIndex(code)
    return colors[code] or colors[GT_COL_NIL]
end


if SERVER then
    include("gterminal_improved/sv_filesystem.lua")
    include("gterminal_improved/sv_gnet.lua")
    
    AddCSLuaFile("gterminal_improved/cl_editor.lua")
    
    
    CreateConVar("gt_os_override", "0", {FCVAR_ARCHIVE}, "Should gTerminal-Improved override default personal and server OS")


    function gTerminal:Broadcast(entity, text, colorType, position, xposition, onlyColor)
        if ( !IsValid(entity) ) then
            return;
        end;

        if !onlyColor then onlyColor = false end 
        text = tostring(text)
    
        local index = entity:EntIndex();
        local output;
        local maxChars = entity.maxChars or 50

        if (utf8.len(text) > maxChars) then
            output = {};
    
            local expected = math.floor(utf8.len(text) / maxChars);
    
            for i = 0, expected do
                output[i + 1] = utf8.sub(text, i * maxChars, (i * maxChars) + maxChars - 1);
            end;
        end;
    
        if (output) then
            for k, v in ipairs(output) do
                net.Start("gT_AddLine");
                    net.WriteUInt(index, 16);
                    net.WriteString(v);
                    net.WriteUInt(colorType or GT_COL_MSG, 8);
                    net.WriteInt(position and position + (k - 1) or -1, 16)
                    net.WriteInt(xposition and xposition or 0, 7)
                    net.WriteBool(onlyColor)
                net.Broadcast();
            end;
        else
            net.Start("gT_AddLine");
                net.WriteUInt(index, 16);
                net.WriteString(text);
                net.WriteUInt(colorType or GT_COL_MSG, 8);
                net.WriteInt(position or -1, 16);
                net.WriteInt(xposition and xposition or 0, 7)
                net.WriteBool(onlyColor)
            net.Broadcast();
        end;
    end;
end

if CLIENT then
    include("gterminal_improved/cl_editor.lua")


    net.Receive("gT_AddLine", function(length)
        local index = net.ReadUInt(16);
        local text = net.ReadString();
        local colorType = net.ReadUInt(8);
        local position = net.ReadInt(16);
        local xposition = net.ReadInt(7)
        local only_color = net.ReadBool()

        local ent = Entity(index)
        local maxChars = ent.maxChars


        if ( !gTerminal[index] ) then
            gTerminal[index] = {};
        end;

        if only_color then
            if gTerminal[index][position] then
                gTerminal[index][position].color = colorType
            end
            return
        end
    
        if (!position or position == -1) then
            table.insert( gTerminal[index], {text = text, color = colorType} );
        else
            if xposition == 0 then
                gTerminal[index][position] = {text = text, color = colorType};
            else
                local str = gTerminal[index][position].text
                local nlen = maxChars + 1 - utf8.len(str)

                if nlen > 0 then
                    for i = 0, nlen do
                        str = str .. " "
                    end
                end

                local t = {}

                if utf8.len(text) < 1 then
                    for i = 1, utf8.len(str) do
                        table.insert(t, string.sub(str, i, i)) 
                    end
                    table.remove(t, xposition)
                    table.insert(t, xposition, text)
                    
                    local new_str = ""

                    for k, v in pairs(t) do
                        new_str = new_str .. t[k]
                    end
                    gTerminal[index][position] = {text = new_str, color = colorType}
                else
                    local tl = utf8.len(text)
                    if tl + xposition > maxChars + 1 then
                        text = string.sub(text, 0, maxChars + 1 - xposition)
                    end
                    for i = 1, utf8.len(str) do
                        table.insert(t, string.sub(str, i, i))
                    end
                    for i = 1, tl do
                        table.remove(t, xposition)
                    end
                    for i = tl, 1, -1 do
                        table.insert(t, xposition, string.sub(text, i, i))
                    end

                    local new_str = ""
                    for k, v in pairs(t) do
                        new_str = new_str .. t[k]
                    end
                    gTerminal[index][position] = {text = new_str, color = colorType}
                end
            end
        end;
    
        if (#gTerminal[index] > (ent.maxLines or 24) ) then
            table.remove(gTerminal[index], 1);
        end;
    end);
    
    net.Receive("gT_ActiveConsole", function()
        local index = net.ReadUInt(16);
        local entity = Entity(index);
        local client = LocalPlayer();

        if ( IsValid(entity) ) then
            client.gT_Entity = entity;
            client.gT_TextEntry = vgui.Create("DTextEntry");
            client.gT_TextEntry:SetSize(0, 0);
            client.gT_TextEntry:SetPos(0, 0);
            client.gT_TextEntry:MakePopup();
    
            client.gT_TextEntry.OnTextChanged = function(textEntry)
                local offset = 0;
                local text = textEntry:GetValue();
                local maxChars = entity.maxChars or 50


                if (utf8.len(text) > maxChars) then
                    offset = textEntry:GetCaretPos() - maxChars - 3;
                end;
    
                entity.consoleText = utf8.sub(text, offset);
            end;
    
            client.gT_TextEntry.OnEnter = function(textEntry)
                net.Start("gT_EndConsole");
                    net.WriteUInt(index, 16);
                    net.WriteString( tostring( textEntry:GetValue() ) );
                net.SendToServer();
    
                textEntry:SetText("");
                textEntry:SetCaretPos(0);
    
                entity.consoleText = "";
            end;
        end;
    end);
end