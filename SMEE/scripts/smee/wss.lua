-- ===================================================================
-- Wireless Sound System
-- ===================================================================
-- Version 1.0.0 unfinished
--
-- How this works:
--


----------------------------------------------------------------------
-- wssInit
----------------------------------------------------------------------
-- call it from init()
function wssInit()
	world.logInfo("wss -- init")
		
	-- init our parameters
	-- is true if entity is master speaker
	self.isMasterSpeaker = false
	-- id of the master speaker
	self.masterSpeaker = 0
	-- list of ids for speakers only filled if the entity is master speaker
	self.registeredSpeakers = {}
	-- TODO item belongs to a speaker group
	self.speakerGroup = ""
	-- current sound playing
	self.currentSound = nil
	-- last sound playing
	self.lastActiveSound = nil
	-- time until sound is finished.
	self.soundTimer = 0
end

----------------------------------------------------------------------
-- wssDie
----------------------------------------------------------------------
-- call it from die()
function wssDie()
	world.logInfo("wss -- die")
	
	if self.isMasterSpeaker then
		-- give master to next wss object
		local objectIds = world.objectQuery(
				entity.position(), 
				entity.configParameter("wssSpeakerRange"), 
				{withoutEntityId = entity.id()}
			)
		
		if #objectIds > 0 then
			world.callScriptedEntity(
					objectIds[1], 
					"wssHandoverMaster",
					self.registeredSpeakers,
					self.currentSound,
					self.lastActiveSound,
					self.soundTimer
				)
		end
	end
	
	-- stop playing for this entity
	entity.playSound("wssStopSound")
	
	if self.masterSpeaker > 0 then
		-- now unregister me
		world.callScriptedEntity(
				self.masterSpeaker, 
				"wssUnregisterSpeaker",
				entity.id()
			)
	end
end


----------------------------------------------------------------------
-- wssBroadcastToSpeakers
----------------------------------------------------------------------
-- @param sound name of the sound
-- @param dt if dt == -1 force sound switch
function wssBroadcastToSpeakers(sound, dt)

	if #self.registeredSpeakers == nil then
		return nil
	end
	
	if self.soundTimer > 0 then
		self.soundTimer = self.soundTimer - dt
	end
	
	-- to prevent broadcast spamming
	local dobroadcast = false
	
	if dt == -1 then
		dobroadcast = true
	elseif self.soundTimer <= 0 and sound ~= nil then
		world.logInfo("wssBroadcastToSpeakers loop " .. sound )
		dobroadcast = true
	end
	
	-- stop here if no broadcast is needed
	if not dobroadcast then
		return
	end
	
	-- assign timer
	if sound == nil then
		world.logInfo("wssBroadcastToSpeakers stop sound ")
		sound = "wssStopSound"
		self.soundTimer = 0
	else
		world.logInfo("wssBroadcastToSpeakers play sound [" .. sound .."]" )
		self.soundTimer = entity.configParameter(sound .. "Duration")
		world.logInfo("wssBroadcastToSpeakers play sound [" .. sound .."] duration: " .. tostring(self.soundTimer))
		
	end
	
		world.logInfo("wssBroadcastToSpeakers registeredSpeakers: " .. tostring(#self.registeredSpeakers))
	
	for k, v in pairs(self.registeredSpeakers) do
		world.callScriptedEntity(v, "wssPlaySound", sound  )
	end
end

function wssPlaySound(sound)
	world.logInfo("wssPlaySound entity:" ..tostring(entity.id() ) )
	entity.playImmediateSound(entity.configParameter(sound)[1] )
end

----------------------------------------------------------------------
-- wssTriggerSound
----------------------------------------------------------------------
-- call this function if you want to trigger a new sound.
--
-- @param sound if nil no sound is played
function wssTriggerSound(sound)
	if sound ~= nil then
		world.logInfo("wss -- triggerSound: " .. sound )
	else
		world.logInfo("wss -- triggerSound: nil")
	end
	
	if self.isMasterSpeaker then
		world.logInfo("wss -- triggerSound master speaker")
	
		self.lastActiveSound = self.currentSound
		self.currentSound = sound
		wssBroadcastToSpeakers(self.currentSound,-1)
		
	elseif self.masterSpeaker ~= nil then
		world.logInfo("wss -- triggerSound redirect to master speaker")
		world.callScriptedEntity(
				self.masterSpeaker, 
				"wssTriggerSound",
				sound
			)
	end
end

----------------------------------------------------------------------
-- wssTriggerLastSound
----------------------------------------------------------------------
-- call this function if you want to return to the last sound
--
function wssTriggerLastSound()
	world.logInfo("wss -- triggerLastSound ")
	
	if self.isMasterSpeaker then
		world.logInfo("wss -- triggerLastSound master speaker")
	
		self.currentSound = self.lastActiveSound
		self.lastActiveSound = nil
		wssBroadcastToSpeakers(self.currentSound,-1)
		
	elseif self.masterSpeaker ~= nil then
		world.logInfo("wss -- triggerLastSound redirect to master speaker")
		world.callScriptedEntity(
				self.masterSpeaker,
				"wssTriggerLastSound"
			)
	end
end

----------------------------------------------------------------------
-- wssUpdate
----------------------------------------------------------------------
-- called from main()
function wssUpdate()
	
	if not self.isMasterSpeaker and self.masterSpeaker == 0 then
		-- entity id is not available during init() so we need to 
		-- register the master the first time main() is called.
		if entity.id() > 0 then
			wssRegisterMasterSpeaker()
		end
	else
		-- if master then broadcast to speakers
		if not self.isMasterSpeaker then
			return
		end
		wssBroadcastToSpeakers(self.currentSound,entity.dt())
	end
end

----------------------------------------------------------------------
-- wssIsSoundPlaying
----------------------------------------------------------------------
-- 
function wssIsSoundPlaying()
	world.logInfo("wss -- isSoundPlaying")
		
	if self.isMasterSpeaker then
		world.logInfo("wss -- isSoundPlaying master speaker")
		
		if self.currentSound ~= nil then
			world.logInfo("wss -- isSoundPlaying true")
			return true
		end
		world.logInfo("wss -- isSoundPlaying false")
		return false
		
	elseif self.masterSpeaker > 0 then
		world.logInfo("wss -- isSoundPlaying redirect to master speaker")
		return world.callScriptedEntity(
				self.masterSpeaker, 
				"wssIsSoundPlaying"
			)
	end

	return false
end

----------------------------------------------------------------------
-- wssGetCurrentSoundPlaying
----------------------------------------------------------------------
-- 
function wssGetCurrentSoundPlaying()
	world.logInfo("wss -- wssGetCurrentSoundPlaying")
		
	if self.isMasterSpeaker then
		return self.currentSound
		
	elseif self.masterSpeaker > 0 then
		world.logInfo("wss -- wssGetCurrentSoundPlaying redirect to master speaker")
		return world.callScriptedEntity(
				self.masterSpeaker, 
				"wssGetCurrentSoundPlaying"
			)
	end
	
	return nil
end


----------------------------------------------------------------------
-- wssHandoverMaster
----------------------------------------------------------------------
-- if the master is removed a new master need to be found.
--
-- @param speakers
-- @param csound
-- @param lasound
-- @param timer
function wssHandoverMaster(speakers, csound, lasound, timer)
	world.logInfo("wss -- handoverMaster called")
	
	world.logInfo("wss -- handoverMaster new master speaker found" )
		
	self.registeredSpeakers = speakers
	self.isMasterSpeaker = true
	self.masterSpeaker = nil
	self.currentSound = csound
	self.lastActiveSound = lasound
	self.soundTimer = timer
end

----------------------------------------------------------------------
-- wssRegisterMasterSpeaker
----------------------------------------------------------------------
-- 
function wssRegisterMasterSpeaker()
	world.logInfo("wss -- looking for master speaker ...")
	
	local objectIds = world.objectQuery(
			entity.position(), 
			entity.configParameter("wssSpeakerRange"), 
			{withoutEntityId = entity.id()}
		)
	
	world.logInfo("wss -- " .. tostring(#objectIds) .." objects in area found." )
	local master = nil
	
	for k, v in pairs(objectIds) do
		master = world.callScriptedEntity(
				k, 
				"wssRegisterSpeaker",
				entity.id()
			)
		
		if master ~=nil and master > 0 then
			world.logInfo("wss -- master found")
			self.masterSpeaker = master
			break;
		end
	end
	if self.masterSpeaker == 0 then
		-- no master  found.
		world.logInfo("wss -- no master found. I am master now")
		self.isMasterSpeaker = true
		
		-- master itself is also a speaker
		wssRegisterSpeaker(entity.id())
	end
end

----------------------------------------------------------------------
-- wssRegisterSpeaker
----------------------------------------------------------------------
-- @param speakerid
-- @return master entity id or nil if is not the master
function wssRegisterSpeaker(speakerid)
	world.logInfo("wss -- registerSpeaker called")
	if not self.isMasterSpeaker then
		return nil
	else
		world.logInfo("wss -- registerSpeaker master speaker" )
	
		self.registeredSpeakers[#self.registeredSpeakers+1] = speakerid
		world.logInfo("wss -- speaker count: " .. tostring(#self.registeredSpeakers) )
		
		-- return master id
		return entity.id()
	end
	
	return nil
end

----------------------------------------------------------------------
-- wssUnregisterSpeaker
----------------------------------------------------------------------
-- @param speakerid
function wssUnregisterSpeaker(speakerid)
	
	world.logInfo("wss -- unregisterSpeaker called" )
	if not self.isMasterSpeaker then
		return
	else
		world.logInfo("wss -- unregisterSpeaker master speaker" )
		for k, v in pairs(self.registeredSpeakers) do
			if v == speakerid then
				table.remove(self.registeredSpeakers, v)
				break
			end
		end
		world.logInfo("wss -- speaker count: " .. tostring(#self.registeredSpeakers) )
		
	end
end