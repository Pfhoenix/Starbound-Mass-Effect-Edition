-- ===================================================================
-- Wireless Sound System
-- ===================================================================
-- Version xxx unfinished
--

----------------------------------------------------------------------
-- Definition
----------------------------------------------------------------------
wss = {}

-- TODO find a way to prevent double initialization
wss.initialized = false

-- singleton instance
local _instance 

----------------------------------------------------------------------
-- init
----------------------------------------------------------------------
local function init()
	world.logInfo("wss init")
	-- To test if _instance also works if not use _instance
	_instance.registeredSpeakers = {}
	
	-- the first registers speaker which it also used to trigger
	-- update from his main() function
	_instance.masterSpeaker = nil
	
	_instance.currentSound = ""
	_instance.lastActiveSound = ""
	
	_instance.soundTimer = 0
	
	world.logInfo("wss init done.")
end

-- if dt == -1 force sound switch
local function broadcastToSpeakers(sound, dt)
	if #_instance.registeredSpeaker == nil then
		return nil
	end
	
	_instance.soundTimer = _instance.soundTimer - dt
	if _instance.soundTimer <= 0 or dt == -1 then
	
		if sound ~= "" then
			_instance.soundTimer = _instance.masterSpeaker.configParameter(sound .. "Duration")
		else
			_instance.soundTimer = 0
		end
		
		
		for i = 1, #_instance.registeredSpeakers do
			_instance.registeredSpeakers[i].playSound(sound)
		end
	end
end


----------------------------------------------------------------------
-- getInstance
----------------------------------------------------------------------
-- 
-- call it in your speakers init() hook.
function wss.getInstance()
	if wss.initialized == false then
		wss.initialized = true
		_instance = {} -- setmetatable({}, wss)
		init()
	end
	return _instance
end


function wss.triggerSound(sound)
	world.logInfo("wss triggerSound " .. sound )
	
	_instance.lastActiveSound = _instance.currentSound
	_instance.currentSound = sound
	broadcastToSpeakers(_instance.currentSound,-1)
end

function wss.triggerLastSound()
	_instance.currentSound = _instance.lastActiveSound
	_instance.lastActiveSound = ""
	broadcastToSpeakers(_instance.currentSound,-1)
end

-- calls this from every speaker in your main
-- entity = speaker that calls
-- args from main
function wss.update(entity)

	if entity ~= _instance.masterSpeaker then
		return
	end
	broadcastToSpeakers(_instance.currentSound,entity.dt())
end

function wss.isSoundPlaying()
	if _instance.currentSound ~= nil then
		return true
	end
	
	return false
end


function wss.registerSpeaker(entity)
	world.logInfo("wss registerSpeaker ")
	
	_instance.registeredSpeakers[#_instance.registeredSpeakers+1] = entity
	
	if #_instance.registeredSpeakers == 1 then
		_instance.masterSpeaker = entity
	end
end


function wss.unregisterSpeaker(entity)
	world.logInfo("wss unregisterSpeaker " )--.. world.entityName(entity.id()) .. " " .. entity.id() )
	
	for i=#_instance.registeredSpeakers,1,-1 do
		if _instance.registeredSpeakers[i] == entity then
			local removed = table.remove(_instance.registeredSpeakers, i)
			removed.playSound(nil)
			break
		end
	end
	
	if entity == _instance.masterSpeaker and #_instance.registeredSpeakers > 0 then
		_instance.masterSpeaker = _instance.registeredSpeakers[1]
	else 
		_instance.masterSpeaker = nil
	end
end