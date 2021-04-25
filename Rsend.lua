local turtles = {id = -1}
local __meta = {__index = turtles} 

  function turtles.new() --default constructor
    local new_instance = {}
    setmetatable(new_instance, __meta)
    return new_instance
  end

  function turtles.both(self) 
    rednet.send(self.id,"right") sleep(.5)
    rednet.send(self.id,"dig") sleep(.5)
    rednet.send(self.id,"plant") sleep(.75)
    rednet.send(self.id,"right") sleep(.5)
    rednet.send(self.id,"right") sleep(.5)
    rednet.send(self.id,"dig") sleep(.5)
    rednet.send(self.id,"plant") sleep(.75)
    rednet.send(self.id,"right") sleep(.5)
    rednet.send(self.id,"forward") sleep(.5) 
  end
  
  function turtles.harvestRight(self)
    rednet.send(self.id,"right") sleep(.5)
    rednet.send(self.id,"dig") sleep(.5)
    rednet.send(self.id,"plant") sleep(.5)
    rednet.send(self.id,"left") sleep(.5)
    rednet.send(self.id,"forward") sleep(.5)
  end
  
  function turtles.harvestLeft(self)
    rednet.send(self.id,"left") sleep(.5)
    rednet.send(self.id,"dig") sleep(.5)
    rednet.send(self.id,"plant") sleep(.5)
    rednet.send(self.id,"right") sleep(.5)
    rednet.send(self.id,"forward") sleep(.5)
  end
  
  function turtles.stop(self)
    rednet.send(self.id,"compare down")
    local sender, message, protocol = rednet.receive()
    if message == "1" then
      return true
    else
      return false
    end
  end
  
  function turtles.look(self)
    local sides = 0
    --print("look called, id__ "..self.id)
    rednet.send(self.id,"left") sleep(.5)
    rednet.send(self.id,"look")
    local sender, message, protocol = rednet.receive()
    print("testing")
    if message == "7" then
      print("left grown")
      sides = sides + 1 --if the left full grown
    end
    
    rednet.send(self.id, "right") sleep(.5)
    rednet.send(self.id, "right") sleep(.5)
    rednet.send(self.id, "look")
    
    local sender, message, protocol = rednet.receive()
    if message == "7" then
      print("right grown")
      sides = sides + 2 --if the right side fully grown
     end
     
    rednet.send(self.id, "left") sleep(.5)
    return sides
  end  
  
local farmer = turtles.new()
  farmer.id = 2
local looker = turtles
  looker.id = 3
local farmlength = 6

rednet.open("back")

local toggle = 2 --switches between farmer and looker
local whereWheat = {}
--0 no wheat, 1 left side, 2 right side, 3 both
local wheatCount = 1
local position = 2--begins with the looker position
local direction = 2
-- -1^x will switch pos / neg every time x incriments

while true do --begin remote loop
  print("--------------")
  if toggle == 1 then --farmer control
    --whereWheat[1] = "-1"
    --print(whereWheat[1])
    print("farmer position = ".. position)
    
    if whereWheat[position] == 3 then
      farmer.both(farmer)
    elseif whereWheat[position] == 2 then
      farmer.harvestRight(farmer)
    elseif whereWheat[position] == 1 then
      farmer.harvestLeft(farmer)
    elseif whereWheat[position] == -3 then
      farmer.both(farmer)
    elseif whereWheat[position] == -2 then
      farmer.harvestLeft(farmer)
    elseif whereWheat[position] == -1 then
      farmer.harvestRight(farmer)
    else
      rednet.send(farmer.id,"forward")sleep(.5)
    end
    
    position = position + (-1)^direction--moves turtle forward 1
    --print("test")
    if farmer.stop(farmer) then
      print("farmer.stop")
      print("current pos = ".. position)
      rednet.send(farmer.id,"turn")sleep(1)
      direction = direction + 1
      while position > 1 do
        rednet.send(farmer.id,"forward") sleep(.5)
        position = position + (-1)^direction
      end
      toggle = 2
      position = 2 --resets position and direction
      direction = 2
      rednet.send(farmer.id,"turn")sleep(.5)
      rednet.send(looker.id,"down")sleep(.5)
    end
    
  else --looker control
    
    --print("begin looker control")
    print("looker position = "..position)
    whereWheat[position] = (looker.look(looker)) * (-1)^direction
    print("Wheat here = "..whereWheat[position])
    
    if whereWheat[position] == (3 or -3) then 
    --incriments wheat count
      wheatCount = wheatCount + 2
    elseif not(whereWheat[position] == 0) then
      wheatCount = wheatCount + 1
    end
    
    --tells how much wheat at looker's current pos
    rednet.send(looker.id,"forward")sleep(.5)
    position = position + (-1)^direction
    
    if looker.stop(looker) then      
      if (wheatCount > farmlength) then
        --begin stop control
        if (-1)^direction > 0 then
        --turns turtle if it's facing the wrong way
          rednet.send(looker.id,"turn")sleep(1)
          direction = direction + 1
        end
        
        while (position > 2) do
          --^^is 1 bc looker starts at position 1
          print("looker reset begin")
          print("position = " .. position)
        --takes looker back to its side
          rednet.send(looker.id,"forward")sleep(.5)
          position = position + (-1)^direction
        end
        rednet.send(looker.id,"turn")sleep(1)
        rednet.send(looker.id,"up")sleep(.5)
        position = 1
        direction = 2
        wheatCount = 1
        toggle = 1
      else--end looker stop control
        rednet.send(looker.id,"turn")sleep(1)
        direction = direction + 1
      end
    end--end looker stop loop
  end--end looker control
end--end remote loop

print("finished")
rednet.close("back")
