local GNet = gTerminal.Improved.GNet or {}
local Filesystem = gTerminal.Improved.Filesystem

GNet.commands = {
    shared = {
        ["ls"] = {
            func = function(cl, ent, args)
                gTerminal:Broadcast(ent, "ACTIVE NETWORKS:");

                local index = 0
                for name, gnet in pairs(GNet.list) do
                    index = index + 1

                    gTerminal:Broadcast(ent, "    " .. index .. ". " .. gnet._name)
                end

                gTerminal:Broadcast(ent, "");
                gTerminal:Broadcast(ent, "    Found " .. index .. " active network(s).");
            end,
            help = "List all networks"
        },
        ["lu"] = {
            func = function(cl, ent, args)
                if !ent.gnet_client then return end

                gTerminal:Broadcast(ent, "ACTIVE USERS:")

                local index = 0
                for _, client in ipairs(ent.gnet_client.clients) do
                    index = index + 1

                    gTerminal:Broadcast(ent, "    " .. index .. ". " .. client:EntIndex())
                end

                gTerminal:Broadcast(ent, "")
                gTerminal:Broadcast(ent, "    Found " .. index .. " active user(s)")
            end,
            help = "List all users"
        },
        ["m"] = {
            func = function(cl, ent, args)
                local id, msg = args[2], table.concat(args, " ", 3)
                
                if !ent.gnet_client then gTerminal:Broadcast(ent, "You aren't connected to a network!", GT_COL_ERR) return end
                if !id then gTerminal:Broadcast(ent, "Invalid UserID!", GT_COL_ERR) return end 
                if !msg then gTerminal:Broadcast(ent, "Invalid message!", GT_COL_ERR) return end

                GNet.SendMessage(ent, ent.gnet_client, id, msg)
            end,
            help = "Send message"
        },
        ["mf"] = {
            func = function(cl, ent, args)
                local id, file = args[2], Filesystem.GetFile(ent, args[3])
                
                if !ent.gnet_client then gTerminal:Broadcast(ent, "You aren't connected to a network!", GT_COL_ERR) return end
                if !id then gTerminal:Broadcast(ent, "Invalid UserID!", GT_COL_ERR) return end 

                GNet.SendFile(ent, ent.gnet_client, id, file)
            end,
            help = "Send file"
        }
    },
    server = {
        ["c"] = {
            func = function(cl, ent, args)
                GNet.Create(ent, args[2], args[3])
            end,
            help = "Create network"
        },
        ["r"] = {
            func = function(cl, ent, args)
                GNet.Remove(ent)
            end,
            help = "Remove network"
        },
        ["ban"] = {
            func = function(cl, ent, args)
                local id = args[2]

                if !ent.gnet_host then gTerminal:Broadcast(ent, "You don't have active network!", GT_COL_ERR) return end
                if !id then gTerminal:Broadcast(ent, "Invalid UserID!", GT_COL_ERR) return end

                GNet.Ban(ent.gnet_host, id)
            end,
            help = "Ban user"
        },
        ["unban"] = {
            func = function(cl, ent, args)
                local id = args[2]

                if !ent.gnet_host then gTerminal:Broadcast(ent, "You don't have active network!", GT_COL_ERR) return end
                if !id then gTerminal:Broadcast(ent, "Invalid UserID!", GT_COL_ERR) return end

                GNet.UnBan(ent.gnet_host, id)
            end,
            help = "Unban user"
        },
        ["kick"] = {
            func = function(cl, ent, args)
                local id = args[2]

                if !ent.gnet_host then gTerminal:Broadcast(ent, "You don't have active network!", GT_COL_ERR) return end
                if !id then gTerminal:Broadcast(ent, "Invalid UserID!", GT_COL_ERR) return end

                GNet.Kick(ent.gnet_host, id)
            end,
            help = "Kick user"
        },
    },
    client = {
        ["j"] = {
            func = function(cl, ent, args)
                GNet.Join(ent, args[2], args[3])
            end,
            help = "Join network"
        },
        ["l"] = {
            func = function(cl, ent, args)
                GNet.Leave(ent, "Disconnected by user.")
            end,
            help = "Leave network"
        }
    },
}

GNet.list = GNet.list or {}


function GNet.Create(ent, name, pass)
    if GNet.list[name] then gTerminal:Broadcast(ent, "Network already exists!") return end
    if ent.gnet_host then gTerminal:Broadcast(ent, 'You are currently hosting "' .. ent.gnet_host._name .. '"', GT_COL_ERR) return end
    if !name then gTerminal:Broadcast(ent, "Invalid name!", GT_COL_ERR) return end


    local str = 'Network "' .. name .. '"'
    if pass then str = str .. 'with password "' .. pass .. '"' end
    str = str .. " created!"

    gTerminal:Broadcast(ent, str, GT_COL_SUCC)


    ent.gnet_host = {
        _name = name,
        _pass = pass,
        clients = {
            ent
        }
    }
    ent.gnet_client = ent.gnet_host

    GNet.list[name] = ent.gnet_host
end

function GNet.Remove(ent)
    if !ent.gnet_host then gTerminal:Broadcast(ent, "You don't have active network!", GT_COL_ERR) return end


    for _, ent in ipairs(ent.gnet_host.clients) do
        gTerminal:Broadcast(ent, "[GNET] Disconnected")
        ent.gnet_client = nil
    end

    gTerminal:Broadcast(ent, 'Network "' .. ent.gnet_host._name .. '" removed!', GT_COL_SUCC)

    GNet.list[ent.gnet_host._name] = nil
    ent.gnet_host = nil
end

function GNet.Get(name)
    return GNet.list[name]
end


function GNet.Join(ent, name, pass)
    if !name then gTerminal:Broadcast(ent, "Invalid name!", GT_COL_ERR) return end
    if ent.gnet_client then gTerminal:Broadcast(ent, "You are already connected to a network!", GT_COL_ERR) return end

    local gnet = GNet.Get(name)

    if !gnet then gTerminal:Broadcast(ent, "Invalid network!", GT_COL_ERR) return end

    if gnet._pass then
        if !pass then gTerminal:Broadcast(ent, "Password required!", GT_COL_ERR) return end
        if pass != gnet._pass then gTerminal:Broadcast(ent, "Incorrect password!", GT_COL_ERR) return end
    end

    if gnet.bans and gnet.bans[ent] then gTerminal:Broadcast(ent, "You are banned from this network!", GT_COL_ERR) return end


    GNet.Broadcast(gnet, "Client " .. ent:EntIndex() .. " connected!", GT_COL_INFO)


    table.insert(gnet.clients, ent)
    ent.gnet_client = gnet
end

function GNet.Leave(ent, reason)
    if !ent.gnet_client then gTerminal:Broadcast(ent, "You aren't connected to a network!", GT_COL_ERR) return end

    local gnet = ent.gnet_client

    for i, client in ipairs(gnet.clients) do
        if client == ent then table.remove(gnet.clients, i) break end
    end

    
    local str = 'Client "' .. ent:EntIndex() ..  '" disconnected!'
    if reason then str = str .. " (" .. reason .. ")" end
    GNet.Broadcast(gnet, str, GT_COL_INFO)

    local str = '[GNET] Dropped from "' .. gnet._name .. '"'
    if reason then str = str .. " (" .. reason .. ")" end 
    gTerminal:Broadcast(ent, str, GT_COL_INFO)


    ent.gnet_client = nil
end


function GNet.Broadcast(gnet, msg, colorType)
    for _, client in ipairs(gnet.clients) do
        gTerminal:Broadcast(client, "[GNET] " .. msg, colorType)
    end
end

function GNet.GetUserByID(gnet, id)
    for _, ent in ipairs(gnet.clients) do
        if ent:EntIndex() == tonumber(id) then return ent end
    end
end

function GNet.Ban(gnet, id)
    local user = Entity(id)
    if user then
        gnet.bans = gnet.bans or {}
        gnet.bans[user] = true

        GNet.Leave(user, "Banned!")
    end
end

function GNet.UnBan(gnet, id)
    local user = Entity(id)
    if gnet.bans and user then
        gnet.bans[user] = nil
    end
end

function GNet.Kick(gnet, id)
    local user = GNet.GetUserByID(gnet, id)
    if user then
        GNet.Leave(user, "Kicked!")
    end
end

function GNet.SendMessage(sender, gnet, id, msg)
    local sender_id = sender:EntIndex()
    if sender.gnet_host then sender_id = sender_id .. "(HOST)" end

    local user = id != "@" and Entity(tonumber(id))
    if user then
        gTerminal:Broadcast(user, "[GNET] " .. sender_id .. " > You: " .. msg, GT_COL_INFO)
        gTerminal:Broadcast(sender, "[GNET] You > " .. id .. ": " .. msg, GT_COL_INFO)
    elseif id == "@" then
        GNet.Broadcast(gnet, sender_id .. " > Everyone: " .. msg, GT_COL_INFO)
    end
end

function GNet.SendFile(sender, gnet, id, file)
    local sender_id = sender:EntIndex()
    if sender.gnet_host then sender_id = sender_id .. "(HOST)" end

    local user = Entity(tonumber(id))
    if !user then gTerminal:Broadcast(sender, "Invalid UserID", GT_COL_ERR) return end


    user.gnet_file_request = true
    gTerminal:Broadcast(user, '[GNET] Would you like to accept file "' .. file._name .. '" from ' .. sender_id .. "? (Y/N)", GT_COL_INFO)
    timer.Create("GNet.File.Request." .. id, 60, 1, function()
        if IsValid(user) and user.gnet_file_request then
            gTerminal:Broadcast(user, "[GNET] File request from " .. sender_id .. " timed out...", GT_COL_INFO)
            gTerminal:Broadcast(sender, "[GNET] File request to " .. id .. " timed out...", GT_COL_INFO)

            user.gnet_file_request = nil
        end
    end)

    gTerminal:GetInput(user, function(cl, args)
        if(args[1] and args[1]:lower() == "y") then
            gTerminal:Broadcast(user, "[GNET] Request from " .. sender_id .. " accepted!", GT_COL_INFO)
            gTerminal:Broadcast(sender, "[GNET] Request to " .. id .. " accepted!", GT_COL_INFO)


            Filesystem.ChangeDir(user)

            if !Filesystem.GetFile(user, "Downloads") then
                Filesystem.CreateDir(user, "Downloads")
            end

            Filesystem.ChangeDir(user, "Downloads")
            Filesystem.CreateFile(user, file._name, file.content)
            Filesystem.ChangeDir(user)
        else
            gTerminal:Broadcast(user, "[GNET] Request from " .. sender_id .. " denied!", GT_COL_INFO)
            gTerminal:Broadcast(sender, "[GNET] Request to " .. id .. " denied!", GT_COL_INFO)
        end

        user.gnet_file_request = nil
    end)
end


gTerminal.Improved.GNet = GNet