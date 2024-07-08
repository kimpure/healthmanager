--!strict

--// service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// import
local jecs = require(ReplicatedStorage:WaitForChild('Package'):WaitForChild('jecs'))


local world = jecs.World.new()
local healths = world:component()
local maxHealths = world:component()
local traumaDamages = world:component()
local human = world:component()
local recovery = world:component()
local Events = world:component()
local Running = world:component()

--// $ type
-- type HealthManagerImpl = {
-- 	__index: HealthManagerImpl,
-- 	new: (player:Player) -> (any);
-- }

-- export type HealthManager = typeof(setmetatable({} :: {

-- }, {} :: HealthManager))


--// $ Setting
local Setting = {
    Health = {
        MaxHealth = 100;
        BaseTraumaDamage = 0;
        BaseHealth = 10;
    };
    AutoRecovery = {
        AutoRecoveryTime = .1;
        AutoRecoveryValue = 1;
    };
}

local case = {
    AutoRecovery = true;
}

--// $ main
local healthmanager = {}
healthmanager.__index = healthmanager

local function changeHealthVible(entity , value:number)
    world:set(entity , healths , value)

    if value <= 0 then
        world:set(entity , human , {dead=true})
    end
end

local function _recovery(entity)
    if case.AutoRecovery then
        if world:get(entity , healths)::number + Setting.AutoRecovery.AutoRecoveryValue <= Setting.Health.MaxHealth - world:get(entity , traumaDamages) then
            
            changeHealthVible(entity , world:get(entity , healths) + Setting.AutoRecovery.AutoRecoveryValue)
        else
            
            changeHealthVible(entity, Setting.Health.MaxHealth - world:get(entity , traumaDamages))
        end
    end

    world:set(entity , recovery , task.delay(Setting.AutoRecovery.AutoRecoveryTime , _recovery , entity))
end

-- local function Run(self)
--     local this = self.this

--     for i=1 , math.huge do
--         if world:get(this , Events).Events[i] then
--             if typeof(_this.Event[i].Event) == "function" then
--                 _this.Event[i].Event( table.unpack( _this.Event[i].Pras ) )
--                 Datas[self.player.Name].Event[i] = nil
--             end
--         else
--             return
--         end
--     end
-- end


function healthmanager.new()
    local playerHealth = world:entity()
    world:set(playerHealth , healths , Setting.Health.BaseHealth)
    world:set(playerHealth , maxHealths , Setting.Health.MaxHealth)
    world:set(playerHealth , traumaDamages , Setting.Health.BaseTraumaDamage)
    world:set(playerHealth , human , {dead=false})
    world:set(playerHealth , Events , {})
    world:set(playerHealth , Running , false)
    world:set(playerHealth , healths , Setting.Health.BaseHealth)

    print(world:get(playerHealth , healths))
    print(world:get(playerHealth , maxHealths))
    print(world:get(playerHealth , traumaDamages))
    print(world:get(playerHealth , human))
    print(world:get(playerHealth , Events))
    print(world:get(playerHealth , Running))

    world:set(playerHealth , recovery , task.delay(Setting.AutoRecovery.AutoRecoveryTime , _recovery , playerHealth))

    local this = setmetatable({
        Health = world:get(playerHealth , healths);
        MaxHealths = world:get(playerHealth , maxHealths);
        TraumaDamages = world:get(playerHealth , traumaDamages);
        human = world:get(playerHealth , human);
        this = playerHealth;
    } , healthmanager);

    RunService.Heartbeat:Connect(function(deltaTime)
        this.Health = world:get(playerHealth , healths);
        this.MaxHealths = world:get(playerHealth , maxHealths);
        this.TraumaDamages = world:get(playerHealth , traumaDamages);
        this.human = world:get(playerHealth , human);
    end)

    return this
end

function healthmanager.takeDamege(self , Damege)
    assert(type(Damege) == 'number' , 'Damege is not number')
    local this = self.this
    world:set(this , Events , table.insert(world:get(this , Events) , function(player:Player , Damege:number)
        changeHealthVible(this , world:get(this , healths)::number - Damege)
    end))
    -- Run(this)
end


return healthmanager