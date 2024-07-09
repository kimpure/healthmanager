--!strict

local Players = game:GetService("Players")
local HealthManager = require(script.Parent)

Players.PlayerAdded:Connect(function(player)
    local NewManager = HealthManager.new()
    NewManager:takeTraumaDamege(30)
    while wait(.1) do
        print(NewManager.health)
    end
end)