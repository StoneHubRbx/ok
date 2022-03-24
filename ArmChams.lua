getgenv().Color = Color3.fromRGB(141, 115, 245)
getgenv().Material = Enum.Material.ForceField

game.RunService.Heartbeat:Connect(function()
    if (workspace.CurrentCamera["Left Arm"] ~= nil) then
        for i, v in pairs(workspace.CurrentCamera:GetChildren()) do
            if (v:IsA("Model") and v.Name:find("Arm")) then
                for i2, v2 in pairs(v:GetChildren()) do
                    if (v2:IsA("MeshPart") or v2:IsA("BasePart")) then
                        v2.Color = getgenv().Color
                        v2.Material = getgenv().Material
                    end
                end
            end
        end
        
        for i, v in pairs(workspace.CurrentCamera:GetChildren()) do
            if (v.Name ~= "Left Arm" or v.Name ~= "Right Arm") then
                if (v:IsA("Model")) then
                    for i2, v2 in pairs(v:GetChildren()) do
                        if (v2:IsA("MeshPart") or v2:IsA("BasePart")) then
                            v2.Color = getgenv().Color
                            v2.Material = getgenv().Material
                        end
                    end
                end
            end
        end
    end
end)