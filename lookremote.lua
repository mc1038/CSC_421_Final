rednet.open("right")

function look()
  local bool, mdata = turtle.inspect()
  if bool then
    return tostring(mdata.metadata)
  else
    return "1"
  end
end

local sendid = 6

while true do
  local sender, message, protocol = rednet.receive()

  if message == "forward" then
    turtle.forward()
    print("forward")
  end
  
  if message == "right" then
    turtle.turnRight()
    print("turnRight")
  end
  
  if message == "left" then
    turtle.turnLeft()
    print("turnLeft")
  end
  
  if message == "back" then
    turtle.back()
    print("back")
  end
  
  if message == "up" then
    turtle.up()
    print("up")
  end
  
  if message == "down" then
    turtle.down()
    print("down")
  end
  
  if message == "turn"then
    turtle.turnLeft()
    turtle.turnLeft()
  end
  
  if message == "look" then
    age = look()
    print("looked for age " .. age)
    rednet.send(sendid, age)
  end
  
  if message == "compare down" then
    print("compare down")
    if turtle.compareDown() then
      rednet.send(sendid,"1")
    else
      rednet.send(sendid,"2")
    end
  end
    

end
