# 사용해도 돼긴하는대 ecs 안썻고 opp 인지아닌지도 모를 이상한문법입니다
# 호스트 Jiwonz 님이 가져갔습니다 (이제 이 레포는 더이상 업데이트를 하지 않습니다.)


how to use?

**server.lua**
```lua
--!strict

local Players = game:GetService("Players")
local HealthManager = require(script.Parent)

Players.PlayerAdded:Connect(function(player)
    local NewManager = HealthManager.new(player)
    while wait(.1) do
        NewManager:takeDamege(math.random(1,2))
        print(NewManager) -- Table
        print(NewManager.player) -- Player
        print(NewManager.Health) -- Table
        print(NewManager.Health.Health) -- number
        print(NewManager.Health.MaxHealth) -- number
        print(NewManager.Health.TraumaHealth) -- number
    end
end)
```
