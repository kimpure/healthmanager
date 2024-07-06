--!strict

--// Service
local StarterPlayer = game:GetService("StarterPlayer")

--// ServerInit 
Instance.new('Script' , StarterPlayer.StarterCharacterScripts).Name = 'Health'

--// Setting
local Setting = {
    BaseHealth = 100;
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
        Health: number;
        Running: boolean
    }
}
local Datas = {} :: Datas

--// Funtions
function changeHealthVible(player:Player , Value:number)
    Datas[player.Name].Health = Value
end

function chnageTheHealth(player:Player)
    local Character = player.Character or player.CharacterAdded:Wait() :: Model
    local Humanoid = Character:FindFirstChildOfClass'Humanoid'
    local function this_main()
        if Humanoid then
            Humanoid.Health = Datas[player.Name].Health
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
    
    if _this.Running then
        return
    else
        Datas[player.Name].Running = true
    end

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
        Health = Setting.BaseHealth;
        Running = false;
    }

    local Character = player.Character or player.CharacterAdded:Wait() :: Model
    local Humanoid = Character:FindFirstChildOfClass'Humanoid'
                
    local function this_main()
        if Humanoid then
            Humanoid:GetPropertyChangedSignal('Health'):Connect(function()
                if Humanoid.Health ~= Datas[player.Name].Health then
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
                local this_Health = Datas[player.Name].Health
                if this_Health + Setting.AutoRecovery.AutoRecoveryValue <= Setting.BaseHealth then
                    changeHealthVible(player, this_Health + Setting.AutoRecovery.AutoRecoveryValue)
                else
                    changeHealthVible(player, Setting.BaseHealth)
                end
                chnageTheHealth(player)
            end
        end
    end)
end

function healthmanager:TakeDamege(player:Player , Damege:number)
    Datas[player.Name].Event[#Datas[player.Name].Event+1] = {
        Event = function(player:Player , Damege:number)
            changeHealthVible(player , Datas[player.Name].Health - Damege)
            chnageTheHealth(player)
        end;
        Pras = {player , Damege};
    }

    Run(player)
end


return healthmanager