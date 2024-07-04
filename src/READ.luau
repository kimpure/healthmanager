--!strict

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

local Settings = {
    BaseHealth = 100;
    AutoRecovery = {
        AutoRecoveryTime = 3;
        AutoRecoveryValue = 1;
    };
}

local case = {
    AutoRecovery = true;
    Bleeding = false; 
}

local PlayerHealths = {}

function changeHealthVible(player:Player , Value:number)
    PlayerHealths[player.Name] = Value
end

function chnageTheHealth(player:Player)
    local Character = player.Character or player.CharacterAdded:Wait() :: Model
    local Humanoid = Character:FindFirstChildOfClass'Humanoid'
    local function this_main()
        if Humanoid then
            Humanoid.Health = PlayerHealths[player.Name]
        else
            wait()
            Humanoid = Character:FindFirstChildOfClass'Humanoid'
            this_main()
        end
    end

    this_main()
end

--// type

type healthmanager = {
    takeDamege: (player:Player , Value:number)->(),
    bleeding: (player:Player , BleedingCount:number , BleedingTickTime:number , BleedingTickDamege:number , Remainingtime:number)->(),
    run: (player:Player)->(),
    add: (player:Player , EventName:string , Pras: {any})->(),
}

export type main = {
    run: (player:Player)->(),
    add: (player:Player , EventName:{bleeding:string} , Pras: {any})->(),
    Init: (player:Player)->(),
}

local healthFunctions = {} :: healthmanager
--// 기능들


--// TakeDamege
function healthFunctions.takeDamege(player , Value)
    if PlayerHealths[player.Name] then
        changeHealthVible(player , PlayerHealths[player.Name] - Value)
        chnageTheHealth(player)
    else
        while task.wait() do
            if PlayerHealths[player.Name] then
                healthFunctions.takeDamege(player , Value)
                break
            end
        end
    end
end

--// $ running
function healthFunctions.bleeding(player , BleedingCount , BleedingTickTime , BleedingTickDamege , Remainingtime)
    case.AutoRecovery = false;
    case.Bleeding = true;
    
    for _=1 , BleedingCount do
        healthFunctions.takeDamege(player , BleedingTickDamege)
        task.wait(BleedingTickTime)
    end
    
    task.wait(Remainingtime)
    
    case.AutoRecovery = true;
    case.Bleeding = false; 
end


local healthmanager = {} :: healthmanager

--// Init

Instance.new('Script' , StarterPlayer.StarterCharacterScripts).Name = 'Health'

--//

--// queue Types

type EventList = {
    EventName: string;
    Pras: {any};
}

type Player_HelthQueue = {
    EventList:{EventList};
    Running:boolean;
}

--// queue
local healthQueue = {
    -- studiopure = {
    --     EventList = {
    --         {
    --             EventName = '';
    --             Pras = {};
    --         };
    --     };
    --     Running = false;
    -- }
}

--// $ running
function healthmanager.run(player)
    print('a')
    local healthQueue = healthQueue[player.Name] :: Player_HelthQueue
    if not healthQueue[player.Name].Running then
        return
    else
        healthQueue[player.Name].Running = true
    end

    for i=1 , math.huge do
        local v = healthQueue.EventList[i]

        if v then
            local this = {
                EventName = v.EventName;
                Pras = v.Pras;
            }


            this.Event = healthFunctions[this.EventName]

            if typeof(this.Event) == 'function' then
                --// Running Queue List for function 
                this.Event( table.unpack( this.Pras ) )
            end
        else
            healthQueue[player.Name].Running = false
            return
        end
    end
end

--// $ add
function healthmanager.add(player , EventName , Pras)
    if typeof(EventName) ~= 'string' or typeof(Pras) ~= 'table' then  
        error('type error')
    end

    if typeof(healthFunctions[EventName]) then
        if player.Character or typeof(healthQueue[ player.Name ]) == 'table' then
            healthQueue[ player.Name ].EventList[ #healthQueue[ player.Name ].EventList+1 ] = {
                EventName = EventName;
                Pras = Pras; 
            }
            healthmanager.run(player)
            print'a'
        else
            task.wait()
            healthmanager.add(player , EventName , Pras)
        end
    end
end

--// Init
-- Players.PlayerAdded:Connect(function(player:Player)
    
-- end)

function healthmanager.Init(player:Player)
    PlayerHealths[player.Name] = Settings.BaseHealth
    healthQueue[player.Name] = {
        EventList = {}
    }
    
        local Character = player.Character or player.CharacterAdded:Wait() :: Model
        local Humanoid = Character:FindFirstChildOfClass'Humanoid'
                    
        local function this_main()
            if Humanoid then
                Humanoid:GetPropertyChangedSignal('Health'):Connect(function()
                    if Humanoid.Health ~=  PlayerHealths[player.Name] then
                        chnageTheHealth(player)
                    end
                end)
            else
                task.wait()
                Humanoid = Character:FindFirstChildOfClass'Humanoid'
                this_main()
            end
        end
                    
        this_main()
                    
        while task.wait(Settings.AutoRecovery.AutoRecoveryTime) do
            if case.AutoRecovery then
                local this_Health = PlayerHealths[player.Name]
                if this_Health + Settings.AutoRecovery.AutoRecoveryValue <= Settings.BaseHealth then
                    changeHealthVible(player, this_Health + Settings.AutoRecovery.AutoRecoveryValue)
                else
                    changeHealthVible(player, Settings.BaseHealth)
                end
                chnageTheHealth(player)
            end
        end
end

return healthmanager