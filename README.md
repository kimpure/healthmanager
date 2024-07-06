
how to use?
```lua
--!strict

local Players = game:GetService("Players")
local a = require(script.Parent)

Players.PlayerAdded:Connect(function(player)
    a:Init(player)
    a:TakeDamege(player , 33)
    a:TakeTraumaDamege(player , 70)
    a:GetHealth(player , 'TraumaHealth')
    print(a:GetHealth(player , 'Health'))
end)
```