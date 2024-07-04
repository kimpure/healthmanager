
how to use?
```lua
local a = require(script.Parent)
game.Players.PlayerAdded:Connect(function(plr)
	a.init(plr)
	a.add(plr , 'takeDamege' , {plr , 10})
	a.add(plr , 'takeDamege' , {plr , 10})	
	a.add(plr , 'takeDamege' , {plr , 10})	
	a.add(plr , 'takeDamege' , {plr , 10})	
	a.add(plr , 'takeDamege' , {plr , 10})
	print(a.getHealthEventList(plr))
	a.add(plr , 'takeDamege' , {plr , 10})	
	a.add(plr , 'takeDamege' , {plr , 10})	
	a.add(plr , 'takeDamege' , {plr , 10})	
	a.add(plr , 'takeDamege' , {plr , 10})
end)
```