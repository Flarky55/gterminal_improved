local gTerminal = gTerminal
gTerminal.Improved = gTerminal.Improved or {}

MsgC(Color(0, 255, 0), "Initialized gTerminal Improved!\n")


if SERVER then
    include("gterminal_improved/sv_filesystem.lua")
    include("gterminal_improved/sv_gnet.lua")
    
    AddCSLuaFile("gterminal_improved/cl_editor.lua")
    
    
    CreateConVar("gt_os_override", "0", {FCVAR_ARCHIVE}, "Should gTerminal-Improved override default personal and server os")


    function gTerminal:Broadcast(entity, text, colorType, position)
        if ( !IsValid(entity) ) then
            return;
        end;
    
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
    
                    if (position) then
                        net.WriteInt(position + (k - 1), 16);
                    else
                        net.WriteInt(-1, 16);
                    end;
                net.Broadcast();
            end;
        else
            net.Start("gT_AddLine");
                net.WriteUInt(index, 16);
                net.WriteString(text);
                net.WriteUInt(colorType or GT_COL_MSG, 8);
                net.WriteInt(position or -1, 16);
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
    
        if ( !gTerminal[index] ) then
            gTerminal[index] = {};
        end;
    
        if (!position or position == -1) then
            table.insert( gTerminal[index], {text = text, color = colorType} );
        else
            gTerminal[index][position] = {text = text, color = colorType};
        end;
    
        if (#gTerminal[index] > Entity(index).maxLines ) then
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