
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jecs = require(ReplicatedStorage:WaitForChild('Package'):WaitForChild('jecs'))


local world = jecs.World.new()
local pair = jecs.pair

local ChildOf = world:component()
local Name = world:component()

local function parent(entity) 
    return world:target(entity, ChildOf)
end
local function getName(entity) 
    return world:get(entity, Name)
end

local alice = world:entity()
world:set(alice, Name, "alice")

local bob = world:entity()
world:add(bob, pair(ChildOf, alice))
world:set(bob, Name, "bob")

local sara = world:entity()
world:add(sara, ChildOf)
world:set(sara, Name, "testing")

print(getName((sara)))

for e in world:query(pair(ChildOf, alice)) do 
    print(getName(e), "is the child of alice")
end


local world = jecs.World.new()
local pair = jecs.pair

local ChildOf = world:component()
local Name = world:component()

local function parent(entity) 
    return world:target(entity, ChildOf)
end
local function getName(entity) 
    return world:get(entity, Name)
end

local alice = world:entity()
world:set(alice, Name, "alice")

local bob = world:entity()
world:add(bob, pair(ChildOf, alice))
world:set(bob, Name, "bob")

local sara = world:entity()
world:add(sara, pair(ChildOf, alice))
world:set(sara, Name, "sara")

print(getName(parent(sara)))

for e in world:query(pair(ChildOf, alice)) do 
    print(getName(e), "is the child of alice")
end

-- Output
-- "alice"
-- bob is the child of alice
-- sara is the child of alice