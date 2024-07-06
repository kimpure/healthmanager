
how to use?
```lua
local Players = game:GetService("Players")
local a = require(script.Parent)

Players.PlayerAdded:Connect(function(player)
    a:Init(player)
    a:TakeDamege(player , player)
end)
```