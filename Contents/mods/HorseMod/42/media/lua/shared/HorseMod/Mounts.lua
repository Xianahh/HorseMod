local mountcommands = require("HorseMod/networking/mountcommands")
local commands = require("HorseMod/networking/commands")

local IS_CLIENT = isClient()
local IS_SERVER = isServer()


local Mounts = {}


---@type table<IsoPlayer, IsoAnimal>
Mounts.playerMountMap = {}

---@type table<IsoAnimal, IsoPlayer>
Mounts.mountPlayerMap = {}


---@param player IsoPlayer
---@param animal IsoAnimal
function Mounts.addMount(player, animal)
    Mounts.playerMountMap[player] = animal
    Mounts.mountPlayerMap[animal] = player

    if IS_SERVER then
        mountcommands.Mount:send(
            nil,
            {
                animal = commands.getAnimalId(animal),
                character = commands.getPlayerId(player),
            }
        )
    end
end


---@param player IsoPlayer
function Mounts.removeMount(player)
    local mount = Mounts.playerMountMap[player]
    Mounts.playerMountMap[player] = nil
    Mounts.mountPlayerMap[mount] = nil
    
    if IS_SERVER then
        mountcommands.Dismount:send(
            nil,
            {
                character = commands.getPlayerId(player)
            }
        )
    end
end


if IS_CLIENT then
    -- need to delay this require :(
    Events.OnInitGlobalModData.Add(function()
        local client = require("HorseMod/networking/client")

        client.registerCommandHandler(mountcommands.Mount, function(args)
            local player = commands.getPlayer(args.character)
            if player then
                local animal = commands.getAnimal(args.animal)
                assert(animal ~= nil, "could not find mounted animal sent by server")
                Mounts.addMount(player, animal)
            else
                print("[HorseMod] received Mount command for unknown player")
            end
        end)

        client.registerCommandHandler(mountcommands.Dismount, function(args)
            local player = commands.getPlayer(args.character)
            if player then
                Mounts.removeMount(player)
            else
                print("[HorseMod] received Dismount command for unknown player")
            end
        end)
    end)
end


return Mounts