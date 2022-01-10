local GNet = {}

GNet.commands = {
    shared = {
        ["ls"] = {
            func = function(cl, ent, args)
                gTerminal:Broadcast(ent, "ACTIVE NETWORKS:");

                local index = 0
                for _, entity in ipairs( ents.FindByClass(ent.ClassName) ) do
                    local serv = entity.gnet_host
                    if serv then
                        index = index + 1

                        gTerminal:Broadcast(ent, "    " .. index .. ". " .. serv._name .. (serv._pass and " (PRIVATE)" or " (PUBLIC)") )
                    end
                end

                gTerminal:Broadcast(ent, "");
                gTerminal:Broadcast(ent, "    Found " .. index .. " active network(s).");
            end,
            help = "List all networks"
        }
    },
    server = {
        ["c"] = {
            func = function(cl, ent, args)
                GNet.Create(ent, args[2], args[3])
            end,
            help = "Create network"
        }
    },
    client = {
        ["j"] = {
            func = function(cl, ent, args)

            end,
            help = "Join network"
        }
    },
}


function GNet.Create(ent, name, pass)
    if ent.gnet_host or !name then return end


    ent.gnet_host = {
        _name = name,
        _pass = pass,
        clients = {
            ent
        }
    }
end

function GNet.Remove(ent)
    if !ent.gnet_host then return end


    for _, ent in ipairs(ent.gnet_host.clients) do

    end

    ent.gnet_host = nil
end


function GNet.Join(ent, name)

end

function GNet.Leave(ent, name)

end


gTerminal.Improved.GNet = GNet