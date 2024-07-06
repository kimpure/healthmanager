--!strict

--// Path
local StarterPlayer = game:GetService("StarterPlayer")


--// Auto Init
Instance.new('Script' , StarterPlayer.StarterCharacterScripts).Name = 'Health'

--// Setting
local Setting = {
    baseHealth = 100;
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


--// Types
type PlayerHealthDatas = {
    Evnet : {
        EventList: {
            Event: <T>(...T)->();
            Pras: {any};
        };
        Running: boolean;
    };
    Health: number
}

--// PlayerData
local PlayerHealthDatas = {} :: PlayerHealthDatas

--// Data Functcions
function changeHealthVible(player:Player , Value:number)
    PlayerHealthDatas[player.Name].Health = Value
end

function chnageTheHealth(player:Player)
    local Character = player.Character or player.CharacterAdded:Wait() :: Model
    local Humanoid = Character:FindFirstChildOfClass'Humanoid'
    local function this_main()
        if Humanoid then
            Humanoid.Health = PlayerHealthDatas[player.Name].Health
        else
            wait()
            Humanoid = Character:FindFirstChildOfClass'Humanoid'
            this_main()
        end
    end

    this_main()
end


--// Functions Type

type Funtions = {
    takeDamege: (player:Player , Value:number)->()
}


--// ModuleFunctions
local Functions = {}

function Functions.takeDamege(player , Value)
    changeHealthVible(player , PlayerHealthDatas[player.Name].Health - Value)
    chnageTheHealth(player)
end

--// Type
type addEventName = "takeDamege"

export type healthmanager = {
    init: (player:Player)->();
    add: (player:Player , EventName:addEventName , Pras:{any})->();
    getHealthEventList:(player:Player)->()
}
type run = (player:Player)->();

local healthmanager = {} :: healthmanager

--// Init
function healthmanager.init(player)
    PlayerHealthDatas[player.Name] = {
        Event = {
            EventList = {};
            Running = false;
        };
        Health = Setting.baseHealth;
    }


    local Character = player.Character or player.CharacterAdded:Wait() :: Model
    local Humanoid = Character:FindFirstChildOfClass'Humanoid'
                
    local function this_main()
        if Humanoid then
            Humanoid:GetPropertyChangedSignal('Health'):Connect(function()
                if Humanoid.Health ~= PlayerHealthDatas[player.Name].Health then
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
                local this_Health = PlayerHealthDatas[player.Name].Health
                if this_Health + Setting.AutoRecovery.AutoRecoveryValue <= Setting.baseHealth then
                    changeHealthVible(player, this_Health + Setting.AutoRecovery.AutoRecoveryValue)
                else
                    changeHealthVible(player, Setting.baseHealth)
                end
                chnageTheHealth(player)
            end
        end
    end)
end

--// Running 
local run : run = function(player) 
    if PlayerHealthDatas[player.Name].Event.Running then
        return
    else
        PlayerHealthDatas[player.Name].Event.Running = true
    end

    for i=1 , math.huge do
        local this = PlayerHealthDatas[player.Name].Event.EventList[i].Event
        if this then
            if typeof(this) == 'function' then
                this()
            end
        else
            PlayerHealthDatas[player.Name].Event.Running = false
            return
        end
    end
end

--// Add 
function healthmanager.add(player , EventName , Pras)
    -- PlayerHealthDatas[player.Name].Event.EventList[#PlayerHealthDatas[player.Name].Event.EventList+1] = {
    --     EventName=EventName;
    --     Pras=Pras;
    -- }

    -- run(player)
end

--// Functions
function healthmanager.getHealthEventList(player)
    return PlayerHealthDatas[player.Name].Event.EventList
end


return healthmanager