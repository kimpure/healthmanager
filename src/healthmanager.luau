local Players = game:GetService("Players")

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

    Humanoid.Health = PlayerHealths[player.Name]
end

local healthmanager = {}

--// Init
Players.PlayerAdded:Connect(function(player)
    PlayerHealths[player.Name] = Settings.BaseHealth

    player.CharacterAdded:Connect(function()
        local Character = player.Character or player.CharacterAdded:Wait() :: Model
        local Humanoid = Character:FindFirstChildOfClass'Humanoid'

        Humanoid:GetPropertyChangedSignal('Health'):Connect(function()
            if Humanoid.Health ~=  PlayerHealths[player.Name] then
                chnageTheHealth(player)
            end
        end)

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
    end)
end)

--// TakeDamege
function healthmanager.takeDamege(player:Player , Value:number)
    changeHealthVible(player , PlayerHealths[player.Name] - Value)
    chnageTheHealth(player)
end

--// bleeding
function healthmanager.bleeding(player:Player , BleedingCount:number , BleedingTickTime:number , BleedingTickDamege:number , Remainingtime:number)
    case.AutoRecovery = false;
    case.Bleeding = true;

    for i=1 , BleedingCount do
        healthmanager.takeDamege(player , BleedingTickDamege)
        task.wait(BleedingTickTime)
    end

    task.wait(Remainingtime)

    case.AutoRecovery = true;
    case.Bleeding = false;
end


return healthmanager