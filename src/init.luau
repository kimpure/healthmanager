--// Path
local Players = game:GetService("Players")
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
            {
                EventName: string;
                Pras: {any}
            }
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


--// ModuleFunctions
local Functions = {}

function Functions.takeDamege(player , Value)
    changeHealthVible(player , PlayerHealthDatas[player.Name].Health - Value)
    chnageTheHealth(player)
end



--// Type
export type healthmanager = {
    init: (player:Player)->();
    add:(player:Player , EventName:string , Pras:{any})->();
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
function run(player)
    if PlayerHealthDatas[player.Name].Event.Running then
        return
    else
        PlayerHealthDatas[player.Name].Event.Running = true
    end

    for i=1 , math.huge do
        local this = PlayerHealthDatas[player.Name].Event.EventList[i]
        if this then
            if typeof(Functions[this.EventName]) == "function" then
                Functions[this.EventName](table.unpack(this.Pras))
            else
                return
            end
        else
            return
        end
    end
end

--// Add 
function healthmanager.add(player , EventName , Pras)
    PlayerHealthDatas[player.Name].Event.EventList[#PlayerHealthDatas[player.Name].Event.EventList+1] = {
        EventName=EventName;
        Pras=Pras;
    }

    run(player)
end




return healthmanager