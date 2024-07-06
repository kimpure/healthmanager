--!strict

--// Service
local StarterPlayer = game:GetService("StarterPlayer")

--// ServerInit 
do
    Instance.new('Script' , StarterPlayer.StarterCharacterScripts).Name = 'Health'
end
--// Setting
local Setting = {
    Health = {
        MaxHealth = 100;
        BaseTraumaHealth = 0;
    };
    AutoRecovery = {
        AutoRecoveryTime = 3;
        AutoRecoveryValue = 1;
    };
}
--// Cases
local case = {
    AutoRecovery = true;
    Bleeding = false; 
}

--// Datas
type Datas = {
    [string]: {
        Event: {
            [number]: {
                Event: any;
                Pras: {any};
            }
        };
        Health: {
            MaxHealth: number;
            TraumaHealth: number;
            Health: number;
        };
    };
}
local Datas = {} :: Datas

--// Funtions
function changeHealthVible(player:Player , Value:number)
    Datas[player.Name].Health.Health = Value
end

function chnageTheHealth(player:Player)
    local Character = player.Character or player.CharacterAdded:Wait() :: Model
    local Humanoid = Character:FindFirstChildOfClass'Humanoid'
    local function this_main()
        if Humanoid then
            Humanoid.Health = Datas[player.Name].Health.Health
        else
            wait()
            Humanoid = Character:FindFirstChildOfClass'Humanoid'
            this_main()
        end
    end

    this_main()
end


function Run(player:Player)
    local _this = Datas[player.Name]

    for i=1 , math.huge do
        if _this.Event[i] then
            if typeof(_this.Event[i].Event) == "function" then
                _this.Event[i].Event( table.unpack( _this.Event[i].Pras ) )
                Datas[player.Name].Event[i] = nil
            end
        else
            return
        end
    end
end

--// module
local healthmanager = {}

--// Init
function healthmanager:Init(player:Player)
    Datas[player.Name] = {
        Event = {};
        Health = {
            MaxHealth = Setting.Health.MaxHealth;
            TraumaHealth = Setting.Health.BaseTraumaHealth;
            Health = Setting.Health.MaxHealth;
        };
        Running = false;
    }

    local Character = player.Character or player.CharacterAdded:Wait() :: Model
    local Humanoid = Character:FindFirstChildOfClass'Humanoid'
                
    local function this_main()
        if Humanoid then
            Humanoid.MaxHealth = Setting.Health.MaxHealth
            Humanoid:GetPropertyChangedSignal('Health'):Connect(function()
                if Humanoid.Health ~= Datas[player.Name].Health.Health then
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
    
    task.spawn(function()
        while task.wait(Setting.AutoRecovery.AutoRecoveryTime) do
            if case.AutoRecovery then
                local this_Health = Datas[player.Name].Health.Health
                if this_Health + Setting.AutoRecovery.AutoRecoveryValue <= Setting.Health.MaxHealth - Datas[player.Name].Health.TraumaHealth then
                    changeHealthVible(player, this_Health + Setting.AutoRecovery.AutoRecoveryValue)
                else
                    changeHealthVible(player, Setting.Health.MaxHealth - Datas[player.Name].Health.TraumaHealth)
                end
                chnageTheHealth(player)
            end
        end
    end)
end

function healthmanager:TakeDamege(player:Player , Damege:number)
    assert(type(Damege) == 'number' , 'Damege is not number')
    Datas[player.Name].Event[#Datas[player.Name].Event+1] = {
        Event = function(player:Player , Damege:number)
            changeHealthVible(player , Datas[player.Name].Health.Health - Damege)
            chnageTheHealth(player)
        end;
        Pras = {player , Damege};
    }

    Run(player)
end

function healthmanager:TakeTraumaDamege(player:Player , TraumaDamege:number)
    assert(type(TraumaDamege) == 'number' , 'Damege is not number')
    Datas[player.Name].Event[#Datas[player.Name].Event+1] = {
        Event = function(player:Player , TraumaDamege:number)
            Datas[player.Name].Health.TraumaHealth += TraumaDamege
            if Setting.Health.MaxHealth - Datas[player.Name].Health.TraumaHealth <= Datas[player.Name].Health.Health then
                changeHealthVible(player , Setting.Health.MaxHealth - Datas[player.Name].Health.TraumaHealth)
            end
        end;
        Pras = {player , TraumaDamege};
    }

    Run(player)
end

function healthmanager:GetHealth(player:Player , HealthType: 'TraumaHealth' | 'Health')
    return Datas[player.Name].Health[HealthType]
end

return healthmanager