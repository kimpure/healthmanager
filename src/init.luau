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
        AutoRecoveryTime = .1;
        AutoRecoveryValue = 1;
    };
}
--// Casesr
local case = {
    AutoRecovery = true;
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
        Recovery: {
            loop: thread?;
        }
    };
}
local Datas = {} :: Datas

--// Funtions
function changeHealthVible(self , Value:number)
    self.Health.Health = Value
end

function Run(self)
    local _this = Datas[self.player.Name]

    for i=1 , math.huge do
        if _this.Event[i] then
            if typeof(_this.Event[i].Event) == "function" then
                _this.Event[i].Event( table.unpack( _this.Event[i].Pras ) )
                Datas[self.player.Name].Event[i] = nil
            end
        else
            return
        end
    end
end

local Recovery = {}
function Recovery.Init(self)
    local function Recovery()
        if case.AutoRecovery then
            local this_Health = self.Health.Health :: number
            if this_Health + Setting.AutoRecovery.AutoRecoveryValue <= Setting.Health.MaxHealth - self.Health.TraumaHealth then
                changeHealthVible(self , this_Health + Setting.AutoRecovery.AutoRecoveryValue)
            else
                changeHealthVible(self, Setting.Health.MaxHealth - self.Health.TraumaHealth)
            end
        end

        Datas[self.player.Name].Recovery.loop = task.delay(Setting.AutoRecovery.AutoRecoveryTime , Recovery)
    end

    Datas[self.player.Name].Recovery.loop = task.defer(Recovery)
end

--// module



--// Type

type HealthManagerImpl = {
	__index: HealthManagerImpl,
	new: (player:Player) -> (any);
    takeDamege: (self: HealthManager, Damege:number)->();
    takeTraumaDamege: (self:HealthManager, TraumaDamege:number)->();
}


export type HealthManager = typeof(setmetatable({} :: {
    player:Player;
    Health: {
        MaxHealth: number;
        TraumaHealth: number;
        Health: number;
    };
}, {} :: HealthManager))

--//

local healthmanager = {} :: HealthManagerImpl
healthmanager.__index = healthmanager

function healthmanager.new(player)
    Datas[player.Name] = {
        Event = {};
        Recovery = {
            loop = nil;
        }
    }
    
    --// MetaTable
    local self = {
        player=player;
        Health =  {
            MaxHealth =  Setting.Health.MaxHealth;
            TraumaHealth = Setting.Health.BaseTraumaHealth;
            Health = Setting.Health.MaxHealth;
        };
    }
    
    local _self = setmetatable(self , healthmanager)

    local function Recovery()
        if case.AutoRecovery then
            local this_Health = _self.Health.Health :: number
            if this_Health + Setting.AutoRecovery.AutoRecoveryValue <= Setting.Health.MaxHealth - self.Health.TraumaHealth then
                changeHealthVible(_self , this_Health + Setting.AutoRecovery.AutoRecoveryValue)
            else
                changeHealthVible(_self, Setting.Health.MaxHealth - self.Health.TraumaHealth)
            end
        end

        Datas[self.player.Name].Recovery.loop = task.delay(Setting.AutoRecovery.AutoRecoveryTime , Recovery)
    end

    Datas[self.player.Name].Recovery.loop = task.defer(Recovery)
    
    return _self
end


function healthmanager.takeDamege(self , Damege)
    assert(type(Damege) == 'number' , 'Damege is not number')
    Datas[self.player.Name].Event[#Datas[self.player.Name].Event+1] = {
        Event = function(player:Player , Damege:number)
            changeHealthVible(self , self.Health.Health::number - Damege)
        end;
        Pras = {self.player , Damege};
    }

    Run(self)
end

function healthmanager.takeTraumaDamege(self , TraumaDamege)
    assert(type(TraumaDamege) == 'number' , 'Damege is not number')
    Datas[self.player.Name].Event[#Datas[self.player.Name].Event+1] = {
        Event = function(player:Player , TraumaDamege:number)
            self.Health.TraumaHealth = self.Health.TraumaHealth::number + TraumaDamege
            if Setting.Health.MaxHealth - self.Health.TraumaHealth <= self.Health.Health then
                changeHealthVible(self , Setting.Health.MaxHealth - self.Health.TraumaHealth)
            end
        end;
        Pras = {self.player , TraumaDamege};
    }

    Run(self)
end

return healthmanager