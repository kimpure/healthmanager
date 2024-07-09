how to use?

**server.lua**
```lua
--!strict

local Players = game:GetService("Players")
local HealthManager = require(script.Parent)

Players.PlayerAdded:Connect(function(player)
    local NewManager = HealthManager.new()
    while wait(.1) do
        NewManager:takeDamege(10)
        print(NewManager.health)
    end
end)
```
