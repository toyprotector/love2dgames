--i can launch a rocket to mars and even make it fly back but i lack motivation to do it
--how can depression be an illness if there's no pathogen?

function R(n) 
	return math.floor(math.random()*n)
end
base62 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
function getbase62()
	local i = R(62)+1
	return string.sub(base62, i, i)
end
function genid(len)
	local s = ""
	for x=1,len do
		s = s .. getbase62()
	end
	return s
end

function gethealthcolor(p)
	if p > 0.8 then
		return {0,1,0,1}
	elseif p > 0.7 then
		return {0,0.8,0,1}
	elseif p > 0.5 then
		return {1,1,0,1}
	elseif p > 0.4 then
		return {1,0.5,0}
	else
		return {1,0,0,1}
	end
end

local objects = {}
function newobject(type, pos, velocity, oncontact, onidle)
	local ob = {id=genid(10), type=type, pos=pos, velocity=velocity, oncontact=oncontact, onidle=onidle}
	table.insert(objects, ob)
	if type == "creature" then
		ob.radius = 15
		ob.color = {1, 0, 0, 1}	--"red"
		ob.mana = 100
		ob.health = 50
	else
		ob.radius = 10
		ob.color = {0.5, 0.5, 0.5, 1} --"gray"
		ob.damage = 1
	end
	ob.draw = function () 
		love.graphics.setColor(ob.color)
		love.graphics.circle( "fill", ob.pos.x, ob.pos.y, ob.radius)
		if ob.type == "creature" then	--draw health bar
			local p = ob.health/50
			love.graphics.setColor(gethealthcolor(p))
			love.graphics.line(ob.pos.x - 15, ob.pos.y - 17, ob.pos.x - 15 + 30*p, ob.pos.y - 17)
		end
	end
	ob.update = function (dt)
		ob.pos.x = ob.pos.x + ob.velocity.x*dt
		ob.pos.y = ob.pos.y + ob.velocity.y*dt
		--local objs = checkcollision(ob)
		ob.onidle(ob)
	end
	return ob
end

function vec2(x,y) 
	return {x=x, y=y}
end

local player
function enemyidle(ob)
	ob.mana = ob.mana + 1
	local dx, dy = player.pos.x - ob.pos.x, player.pos.y - ob.pos.y
	local dm = math.sqrt(dx^2 + dy^2)
	if (ob.mana >= 100) then
		ob.mana = ob.mana - 100
		local dxr, dyr = dx/dm * (ob.radius + 10) * 1.2, dy/dm * (ob.radius + 10) * 1.2
		local proj = newobject("projectile", vec2(ob.pos.x +dxr, ob.pos.y +dyr), vec2(100*dx/dm,100*dy/dm), projoncontact, function () end)	
		proj.damage = 10
	end
	local dist = math.sqrt((player.pos.x - ob.pos.x)^2 + (player.pos.y - ob.pos.y)^2)
	if dist > 200 then	--too far
		ob.velocity.x = 100*dx/dm
		ob.velocity.y = 100*dy/dm
	else
		ob.velocity.x = 0
		ob.velocity.y = 0
	end
end


function love.load()
	love.window.setMode( 1280, 640, {} )
	player = newobject("creature", vec2(310, 310), vec2(0,0), function () end, function (ob) ob.mana = ob.mana + 1 end)	
	enemy = newobject("creature", vec2(R(310), R(310)), vec2(0,0), function () end, enemyidle)
end

function circlecoll(ob1, ob2)
	local d2 = (ob1.pos.x - ob2.pos.x)^2 + (ob1.pos.y - ob2.pos.y)^2
	return d2 <= (ob1.radius + ob2.radius)^2
end

function destroyobject(id)
	--get index of elem with id
	local index = -1
	for x=1,#objects do
		if objects[x].id == id then
			index = x
			break
		end
	end
	if index > 0 then
		table.remove(objects, index)
	end
end

function love.update(dt)
	for x=1,#objects do
		objects[x].update(dt)
	end
	local collisions = {}
	for x=1,#objects do
		for y=x+1, #objects do
			if circlecoll(objects[x], objects[y]) then
				local obx = objects[x]
				local oby = objects[y]
				table.insert(collisions, {obx, oby})
			end
		end
	end
	for c=1,#collisions do
		local obx = collisions[c][1]
		local oby = collisions[c][2]
		obx.oncontact(obx, oby)
		oby.oncontact(oby, obx)
	end
end

local attacktype = "bolt"
--bolt, wave, wave 2, star, explosion, construct, self

function love.keypressed(key, scancode, isrepeat)
	if key == "1" then
		attacktype = "bolt"
	elseif key == "2" then
		attacktype = "spread"
	elseif key == "3" then
		attacktype = "wave 2"
	elseif key == "4" then
		attacktype = "star"
	elseif key == "5" then
		attacktype = "explosion"
	elseif key == "6" then
		attacktype = "construct"
	elseif key == "7" then
		attacktype = "self"
	end
end

function love.keyreleased(key, scancode)

end

function projoncontact(ob, ob2)
	print(ob2.type, ob2.id)
	if ob2.type == "projectile" then 
		destroyobject(ob2.id) 
	elseif ob2.type == "creature" then
		ob2.health = ob2.health - ob.damage
		if ob2.health <= 0 then
			destroyobject(ob2.id) 
		end
		destroyobject(ob.id)
	end
end

function love.mousepressed(x, y, button)
	local dx, dy = x - player.pos.x, y - player.pos.y
	local dm = math.sqrt(dx^2 + dy^2)
	local dxr, dyr = dx/dm * (player.radius + 10), dy/dm * (player.radius + 10)
	if button == 1 then	--left
		if player.mana >= 100 then
			player.mana = player.mana - 100
			local proj = newobject("projectile", vec2(player.pos.x + dxr, player.pos.y + dyr), vec2(100*dx/dm,100*dy/dm), projoncontact, function () end)	
			proj.damage = 10
		end
	elseif button == 2 then
                if (dm > 10) then
	  		player.velocity.x = 100*dx/dm
			player.velocity.y = 100*dy/dm
		else
			player.velocity.x = 0
			player.velocity.y = 0
		end
	end
end

function love.mousereleased(x, y, button)

end

function love.draw()
	love.graphics.translate(10,10)
	for x=1,#objects do
		objects[x].draw()
	end
end