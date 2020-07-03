--        ___    ___ _______   ________   ________  ________       _______      ___    ___ _______        ___    ___         _______  ________  ________  ________     
--        |\  \  /  /|\  ___ \ |\   ___  \|\   __  \|\   ____\     |\  ___ \    |\  \  /  /|\  ___ \      |\  \  |\  \       /  ___  \|\   __  \|\   ____\|\  ___  \    
--        \ \  \/  / | \   __/|\ \  \\ \  \ \  \|\  \ \  \___|_    \ \   __/|   \ \  \/  / | \   __/|   __\_\  \_\_\  \_____/__/|_/  /\ \  \|\  \ \  \___|\ \____   \   
--         \ \    / / \ \  \_|/_\ \  \\ \  \ \  \\\  \ \_____  \    \ \  \_|/__  \ \    / / \ \  \_|/__|\____    ___    ____\__|//  / /\ \   __  \ \_____  \|____|\  \  
--          /     \/   \ \  \_|\ \ \  \\ \  \ \  \\\  \|____|\  \  __\ \  \_|\ \  /     \/   \ \  \_|\ \|___| \  \__|\  \___|   /  /_/__\ \  \|\  \|____|\  \  __\_\  \ 
--         /  /\   \    \ \_______\ \__\\ \__\ \_______\____\_\  \|\__\ \_______\/  /\   \    \ \_______\  __\_\  \_\_\  \_____|\________\ \_______\____\_\  \|\_______\
--        /__/ /\ __\    \|_______|\|__| \|__|\|_______|\_________\|__|\|_______/__/ /\ __\    \|_______| |\____    ____   ____\\|_______|\|_______|\_________\|_______|
--        |__|/ \|__|                                  \|_________|             |__|/ \|__|               \|___| \  \__|\  \___|                   \|_________|         
--                                                                                                              \ \__\ \ \__\                                           
--                                                                                                               \|__|  \|__|                                           

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
      local iter, id = initFunc()
      if not id or id == 0 then
        disposeFunc(iter)
        return
      end
      
      local enum = {handle = iter, destructor = disposeFunc}
      setmetatable(enum, entityEnumerator)
      
      local next = true
      repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
      until not next
      
      enum.destructor, enum.handle = nil, nil
      disposeFunc(iter)
    end)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end;

Citizen.CreateThread(function()
    Citizen.Wait(0)
    while true do			
        for veh in EnumerateVehicles() do
            local class = GetVehicleClass(veh)
                if class == 15 or class == 16 or veh == 'polmav' then
                    if IsVehicleSeatFree(veh, -1) and IsEntityInAir(veh) then
                        SetEntityAsMissionEntity(veh, 1, 1)
                        DeleteEntity(veh)
                    end
                end
        end
        Citizen.Wait(2000) -- This timeout is how often the server checks for random explosion of elicopters! (1000 = 1s) (Lower of 2000 = lag)
    end
end)