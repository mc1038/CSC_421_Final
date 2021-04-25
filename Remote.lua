rednet.open("right")
local sendid = 6
while true do
  local sender, message, protocol = rednet.receive()
  if message == "forward" then
    turtle.forward()
    print("forward")
  end
  
  if message == "back" then
    turtle.back()
    print("back")
  end
  
  if message == "right" then
    turtle.turnRight()
    print("right")
  end
  
  if message == "left" then
    turtle.turnLeft() 
    print("Left")  
  end
  
  if message == "up" then
    turtle.up()
  end
  
  if message == "turn" then
    turtle.turnLeft()
    turtle.turnLeft()
  end
  
  if message == "dig" then
    turtle.dig()
    print("dig")
    
  end
  if message == "compare down" then
    print("compare down")
    if turtle.compareDown() then
      rednet.send(sendid,"1")
    else
      rednet.send(sendid,"0")
    end
  end
  
  if message == "plant" then
    print("Plant")
    turtle.select(2)
    turtle.place()
    turtle.select(1)
    end
end
