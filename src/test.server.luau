--!strict

local Players = game:GetService("Players")
local HealthManager = require(script.Parent)

-- Players.PlayerAdded:Connect(function(player)
--     local NewManager = HealthManager.new(player)
--     while wait(.1) do
--         NewManager:takeDamege(math.random(1,2))
--         print(NewManager) -- Table
--         print(NewManager.player) -- Player
--         print(NewManager.Health) -- Table
--         print(NewManager.Health.Health) -- number
--         print(NewManager.Health.MaxHealth) -- number
--         print(NewManager.Health.TraumaHealth) -- number
--     end
-- end)

Players.PlayerAdded:Connect(function(player)
    local NewManager = HealthManager.new()
    while wait(.1) do
        NewManager:takeDamege(10)
        print(NewManager.health)
    end
end)