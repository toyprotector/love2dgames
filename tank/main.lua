function love.load()
	--local tank = {}
	r = 10
	th = 0
	x = 40
	y = 50
	w = math.pi/4
	al = 0
	vr = 10
	vth = 0
	--vx = 10
	--vy = 0
	ar = 0
	ath = 0
	bulletpool = {}
	obstaclepool = {}
	--map is 16x16, 
	--local map = {0,0,0
end

function love.update(dt)
	local bx = x
	local by = y
	w = w+al*dt
	th = th+w*dt

	vr = vr+ar*dt
	vth = vth+ath*dt
	vx = vr*math.cos(vth)
	vy = vr*math.sin(vth)
	x = x+vx*dt
	y = y+vy*dt

	

	for x=1,#bulletpool do
		local bullet = bulletpool[x]
		bullet.x = bullet.x + bullet.vx*dt
		bullet.y = bullet.y + bullet.vy*dt
	end
end

function love.draw()
	love.graphics.line(x, y, x+r*math.cos(vth+th), y+r*math.sin(vth+th))
	love.graphics.circle('line', x, y, r)
	local dx = 20*math.cos(vth-math.pi/2)
	local dy = 20*math.sin(vth-math.pi/2)
	love.graphics.line(x-20*math.cos(vth)-dx, y-20*math.sin(vth)-dy, x+20*math.cos(vth)-dx, y+20*math.sin(vth)-dy)
	love.graphics.line(x-20*math.cos(vth)+dx, y-20*math.sin(vth)+dy, x+20*math.cos(vth)+dx, y+20*math.sin(vth)+dy)
	for x=1,#bulletpool do
		local bullet = bulletpool[x]
		love.graphics.circle('line', bullet.x, bullet.y, 2)
	end
	for x=1,#obstaclepool do
		local obstacle = obstaclepool[x]
		love.graphics.circle('line', obstacle.x, obstacle.y, 5)
	end
end

function love.keypressed(key)
	if key == "q" then
		w = - math.pi/4
		--al = - math.pi/4
	elseif key == "e" then
		w = math.pi/4
		--al = math.pi/4
	elseif key == "w" then
		vr = 15
		--ar = 15
	elseif key == "s" then
		vr = -15
		--ar = -15
	elseif key == "a" then
		--vth = - math.pi/4
		ath = -math.pi/4
	elseif key == "d" then
		--vth = math.pi/4
		ath = math.pi/4
	elseif key == "space" then
		table.insert(bulletpool, {x=x+r*math.cos(vth+th), y=y+r*math.sin(vth+th), vx=20*math.cos(vth+th), vy=20*math.sin(vth+th)})
	end
end

function love.keyreleased(key)
	if key == "q" then
		w = 0
		--al = 0
	elseif key == "e" then
		w = 0
		--al = 0
	elseif key == "w" then
		vr = 0
		--ar = 0
	elseif key == "s" then
		vr = 0
		--ar = 0
	elseif key == "a" then
		--vth = 0
		ath = 0
	elseif key == "d" then
		--vth = 0
		ath = 0
	end
end
