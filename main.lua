function CheckCollision(x1,y1,w1,h1,x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

function love.load()
    gamestate = "not game over"
    ship = {}
    meteors = {}
    meteor = {}
    meteor.sprite = love.graphics.newImage("graphics/meteor.png")
    ship.sprite = love.graphics.newImage("graphics/rocket.png")
    ship.x = 300
    ship.y = 450
    ship.rotation = 0
    ship.speed = 250
    bulletSpeed = 400
    print("Load")
    math.randomseed(os.time())
    for i=0, 5, 1 do
        table.insert(meteors,{x=i*70+50,y=math.random(0,love.graphics.getHeight()),scale=math.random(10,20)/100.0,speed=math.random(1,200),direction=math.random(0,2*math.pi)})
    end
    bullets ={}
    pewpew = love.audio.newSource("audio/pewpew.wav")
    explosion = love.audio.newSource("audio/explosion.wav")
end

function love.update(dt)
    ship.rotation = math.atan2(love.mouse.getY()-ship.y,love.mouse.getX()-ship.x)+math.pi/2.0
    if(love.keyboard.isDown("w")) then
        ship.x = ship.x + ship.speed*dt*math.sin(ship.rotation)
        ship.y = ship.y - ship.speed*dt*math.cos(ship.rotation)
    end
    
    for j, m in ipairs(meteors) do
        if(m.x < 0 or m.y>love.graphics.getHeight()) then
            print(m.direction*360/(2*math.pi))
            m.direction = (m.direction+3/2*math.pi)
        end
        if(m.x > love.graphics.getWidth() or m.y < 0 ) then 
            m.direction = (m.direction-3/2*math.pi)
        end
        m.x = m.x+m.speed*dt*math.cos(m.direction)
        m.y = m.y+m.speed*dt*math.sin(m.direction)
        if(CheckCollision(ship.x-0.3*0.1*ship.sprite:getWidth(), ship.y-0.2*0.1*ship.sprite:getWidth(), 0.06*ship.sprite:getWidth(), 0.06*ship.sprite:getWidth(), m.x-0.5*m.scale*meteor.sprite:getWidth(), m.y-0.5*m.scale*meteor.sprite:getHeight(), m.scale*meteor.sprite:getWidth()*0.8, m.scale*meteor.sprite:getHeight()*0.8)) then
            if(gamestate == "not game over") then
                gamestate = "game over"
                explosion:play()
            end 
         end
    end
    
    for i,v in ipairs(bullets) do
        v.x = v.x + (v.dx *dt)
        v.y = v.y + (v.dy *dt)
        if(v.x > love.graphics.getWidth() or v.x < 0 or v.y > love.graphics.getHeight() or v.y < 0) then 
            table.remove(bullets,i)
        end
        for j,m in ipairs(meteors) do
            if(CheckCollision(v.x,v.y,0.1,0.1,m.x-0.5*m.scale*meteor.sprite:getWidth(),m.y-0.5*m.scale*meteor.sprite:getHeight(),m.scale*meteor.sprite:getWidth(),m.scale*meteor.sprite:getHeight())) then
                print("Collision")
                explosion:play()
                table.remove(meteors,j)
                table.remove(bullets,i)
            end
        end
    end
end

function love.mousepressed(x,y,button)
    if button == "l" then
        pewpew:play()
        local angle = math.atan2(y-ship.y,x-ship.x)
        table.insert(bullets, {x= ship.x, y=ship.y, dx=bulletSpeed*math.cos(angle),dy=bulletSpeed*math.sin(angle)})
    end
end

function love.draw()
    if(gamestate == "not game over") then
        love.graphics.draw(ship.sprite, ship.x, ship.y, ship.rotation, 0.1, 0.1,ship.sprite:getWidth()/2.0,ship.sprite:getHeight()/2.0)
        love.graphics.setColor(255,255,255)
        for i,v in ipairs(bullets) do
            love.graphics.circle("fill",v.x,v.y,3)
        end
        for i,v in ipairs(meteors) do 
            love.graphics.draw(meteor.sprite,v.x,v.y,0,v.scale,v.scale,meteor.sprite:getWidth()/2.0,meteor.sprite:getHeight()/2.0)
        end
    elseif(gamestate == "game over") then
        love.graphics.print("Game Over!!!",300,300)
    end
end
