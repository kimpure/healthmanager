--!strict

--// service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// import
local jecs = require(ReplicatedStorage:WaitForChild('Package'):WaitForChild('jecs'))

local world = jecs.World.new()
local health = world:component()
local recovery = world:component()
local case = world:component()
local RunningLists = {} :: {
    [number]: {
        [number]: {
            Event: any;
            Pras: {any};
        };
        Running: boolean;
    };
};

local Setting = {
    Health = {
        MaxHealth = 100;
        BaseTraumaDamage = 0;
        BaseHealth = 10;
    };
    AutoRecovery = {
        AutoRecoveryTime = .1;
        AutoRecoveryValue = 0;
    };
}


local function run(self , main, Pras: {any})
    local player = self.player :: number & {
        __nominal_type_dont_use: any
    };

    local t = {
        Event = main;
        Pras = Pras;
    }

    RunningLists[player][#RunningLists[player]+1] = t

    if RunningLists[player].Running then
        return
    else
        RunningLists[player].Running = true
    end

    for i=1 , math.huge do
        if RunningLists[player][i] then
            RunningLists[player][i].Event(table.unpack(RunningLists[player][i].Pras));
            RunningLists[player][i] = nil
        else
            RunningLists[player].Running = false
            return
        end
    end
end


local function changeHealthVible(entity , value:number)
    local t = world:get(entity , health)
    t.health = value
    world:set(entity , health , t) ;
    if value <= 0 then
        print('죽었음')
    end
end

local function _recovery(entity)
    if world:get(entity , case).AutoRecovery then
        local t = world:get(entity , health) :: {
            health:number;
            maxHealth:number;
            traumaDamage:number;
        };
        if t.health + Setting.AutoRecovery.AutoRecoveryValue <= Setting.Health.MaxHealth - t.traumaDamage then
            
            changeHealthVible(entity , world:get(entity , health).health + Setting.AutoRecovery.AutoRecoveryValue)
        else
            
            changeHealthVible(entity, Setting.Health.MaxHealth - t.traumaDamage)
        end
    end
    world:set(entity , recovery , task.delay(Setting.AutoRecovery.AutoRecoveryTime , _recovery , entity))
end

local healthmanager = {}
healthmanager.__index = healthmanager
--// $ main

function healthmanager.new()
    local player = world:entity()
    world:set(player , health , {
        health=Setting.Health.BaseHealth;
        maxHealth=Setting.Health.MaxHealth;
        traumaDamage=Setting.Health.BaseTraumaDamage;
    });
    world:set(player , case , {AutoRecovery = true;});

    RunningLists[player] = {
        Running = false;
    };

    --// recovery
    task.defer(_recovery , player)

    --// metatable
    local self = setmetatable({
        health = world:get(player , health).health;
        maxHealth = world:get(player , health).maxHealth;
        traumaDamage = world:get(player , health).traumaDamage;
        player = player;
    } , healthmanager);

    RunService.Heartbeat:Connect(function(deltaTime)
        self.health = world:get(player , health).health;
        self.maxHealth = world:get(player , health).maxHealth;
        self.traumaDamage = world:get(player , health).traumaDamage;
    end)

    return self
end

function healthmanager.takeDamege(self , Damage)
    local player = self.player :: number & {
        __nominal_type_dont_use: any
    };

    local health = world:get(player , health) :: {
        health: number;
        maxHealth: number;
        traumaDamage: number;
    };


    local function main(self , Damage)
        local player = self.player :: number & {
            __nominal_type_dont_use: any
        };
        changeHealthVible(player , health.health - Damage)
    end

    run(self , main , {self , Damage})
end

return healthmanager