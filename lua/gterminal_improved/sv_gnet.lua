local GNet = gTerminal.Improved.GNet or {}

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
        }
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
                GNet.Leave(ent)
            end,
            help = "Leave network"
        }
    },
}

GNet.list = GNet.list or {}


function GNet.Create(ent, name, pass)
    --if ent.gnet_host or !name then return end


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
    if !ent.gnet_host then return end


    for _, ent in ipairs(ent.gnet_host.clients) do
        gTerminal:Broadcast(ent, "[GNET] Disconnected")
        ent.gnet_client = nil
    end

    GNet.list[ent.gnet_host._name] = nil
    ent.gnet_host = nil
end

function GNet.Get(name)
    return GNet.list[name]
end


function GNet.Join(ent, name, pass)
    if !name or ent.gnet_client then return end

    local gnet = GNet.Get(name)

    if !gnet then return end

    if gnet._pass and pass and gnet._pass != pass then return end


    GNet.Broadcast(gnet, "Client connected!")


    table.insert(gnet.clients, ent)
    ent.gnet_client = gnet
end

function GNet.Leave(ent)
    if !ent.gnet_client then return end

    local gnet = ent.gnet_client

    for i, client in ipairs(gnet.clients) do
        if client == ent then table.remove(gnet.clients, i) break end
    end


    GNet.Broadcast(gnet, "Client disconnected!")


    ent.gnet_client = nil
end


function GNet.Broadcast(gnet, msg)
    for _, client in ipairs(gnet.clients) do
        gTerminal:Broadcast(client, msg)
    end
end


gTerminal.Improved.GNet = GNet