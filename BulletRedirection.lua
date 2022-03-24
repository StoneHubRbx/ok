local workspace = game:GetService("Workspace")
local currentcamera = workspace.CurrentCamera
local players = game:GetService("Players")
local localplayer = players.LocalPlayer
local mouse = localplayer:GetMouse()
local replicatedfirst = game:GetService("ReplicatedFirst")

local network = require(replicatedfirst.ClientModules.Old.framework.network)
local particle = require(replicatedfirst.ClientModules.Old.framework.particle)
local camera = require(replicatedfirst.ClientModules.Old.framework.camera)
local physics = require(replicatedfirst.SharedModules.Old.Utilities.Math.physics:Clone())

local replication = debug.getupvalue(camera.setspectate, 1)
local hud = debug.getupvalue(camera.step, 21)
local gamelogic = debug.getupvalue(hud.updateammo, 4)
local bodyparts = debug.getupvalue(replication.getbodyparts, 1)

local function gettarget()
    local target, closest = nil, math.huge

    for i,v in next, players:GetPlayers() do
        if v.Name ~= localplayer.Name and v.Team ~= localplayer.Team then
            if bodyparts[v] then
                local pos, onscreen = currentcamera:WorldToScreenPoint(bodyparts[v].head.Position)
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude

                if onscreen and dist < closest then
                    closest = dist
                    target = v
                end
            end
        end
    end

    return target, closest
end

local position = Vector3.new()
local velocity = Vector3.new()

local serverposition = Vector3.new()

local oldsend = network.send
network.send = function(self, name, ...)
    local args = {...}

    if not checkcaller() then
        if name == "repupdate" then
            serverposition = args[1]
        end

        if name == "newbullets" then
            local target = gettarget()

            if target then
                args[1].firepos = gamelogic.currentgun.barrel.Position
                args[1].camerapos = serverposition

                position = bodyparts[target].head.Position
                velocity = physics.trajectory(args[1].firepos, Vector3.new(0, -196.2, 0), position, gamelogic.currentgun.data.bulletspeed)

                for i,v in next, args[1].bullets do
                    v[1] = velocity
                end
            else
                position = Vector3.new()
                velocity = Vector3.new()
            end
        end
    end

    return oldsend(self, name, unpack(args))
end

local oldnew = particle.new
particle.new = function(data)
    if gamelogic.currentgun and gamelogic.currentgun.data then
        if data.visualorigin and data.visualorigin == gamelogic.currentgun.barrel.Position then
            if position and position ~= Vector3.new() then
                data.position = position
                data.velocity = velocity

                position = Vector3.new()
                velocity = Vector3.new()
            end
        end
    end

    return oldnew(data)
end