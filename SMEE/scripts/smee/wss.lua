-- ===================================================================
-- Wireless Sound System
-- ===================================================================
-- Version 1.0.0
--
-- How this works:
--
-- WSS triggers animations via master-slave-communication.
-- Because playSound and playImmediateSound cannot stop the sound 
-- before it is finished.
--
-- See also wss_samples.lua for how to use this API.
-- 

----------------------------------------------------------------------
-- wssInit
----------------------------------------------------------------------
-- call it from init()
function wssInit()
	--world.logInfo("wss -- init")
		
	-- init our parameters
	-- is true if entity is master speaker
	self.isMasterSpeaker = false
	-- id of the master speaker
	self.masterSpeaker = 0
	-- list of ids for speakers only filled if the entity is master speaker
	self.registeredSpeakers = {}
	
	self.speakerGroup = entity.configParameter("wssSpeakerGroup", "")
	self.speakerRange = entity.configParameter("wssSpeakerRange", 1000)
	
	-- setup the stored data
	-- the last animation stage is saved automatic since EKu6 but
	-- we need also save the current and last sound variables.
	if not storage.wss then
		storage.wss = {}
		storage.wss.currentSound = "off"
		storage.wss.lastActiveSound = "off"
	end
end

----------------------------------------------------------------------
-- wssDie
----------------------------------------------------------------------
-- call it from die()
function wssDie()
	--world.logInfo("wss -- die")
	
	if self.isMasterSpeaker then
		-- world.logInfo("wss -- looking for new master")
		-- give master to next wss object
		local objectIds = world.objectQuery(
				entity.position(), 
				self.speakerRange, 
				{withoutEntityId = entity.id()}
			)
		
		if #objectIds > 0 then
			world.callScriptedEntity(
					objectIds[1], 
					"wssHandoverMaster",
					self.registeredSpeakers,
					storage.wss.currentSound,
					storage.wss.lastActiveSound
				)
			self.masterSpeaker = objectIds[1]
		end
	end
	
	if self.masterSpeaker > 0 then
		-- now unregister me
		world.callScriptedEntity(
				self.masterSpeaker, 
				"wssUnregisterSpeaker",
				entity.id()
			)
	end
	
	self.isMasterSpeaker = false
	self.masterSpeaker = 0
	self.registeredSpeakers = {}
end


----------------------------------------------------------------------
-- wssBroadcastToSpeakers
----------------------------------------------------------------------
-- @param sound name of the sound
function wssBroadcastToSpeakers(sound, dt)

	if #self.registeredSpeakers == nil then
		return nil
	end
	
	for k, v in pairs(self.registeredSpeakers) do
		world.callScriptedEntity(v, "wssPlaySound", sound  )
	end
end

function wssPlaySound(sound)
	world.logInfo("wssPlaySound ".. sound .." on entity:" ..tostring(entity.id() ) )
	entity.setAnimationState("wssState", sound)
end

----------------------------------------------------------------------
-- wssTriggerSound
----------------------------------------------------------------------
-- call this function if you want to trigger a new sound.
--
-- @param sound if nil no sound is played
function wssTriggerSound(sound)
	--world.logInfo("wss -- triggerSound: " .. sound )
	
	if self.isMasterSpeaker then
		--world.logInfo("wss -- triggerSound master speaker")
		
		storage.wss.lastActiveSound = storage.wss.currentSound
		storage.wss.currentSound = sound
		wssBroadcastToSpeakers(storage.wss.currentSound)
		
	elseif self.masterSpeaker ~= nil then
		--world.logInfo("wss -- triggerSound redirect to master speaker")
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
	--world.logInfo("wss -- triggerLastSound " .. storage.wss.lastActiveSound )
	
	if self.isMasterSpeaker then
		--world.logInfo("wss -- triggerLastSound master speaker")
	
		storage.wss.currentSound = storage.wss.lastActiveSound
		storage.wss.lastActiveSound = "off"
		wssBroadcastToSpeakers(storage.wss.currentSound)
		
	elseif self.masterSpeaker ~= nil then
		--world.logInfo("wss -- triggerLastSound redirect to master speaker")
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
	end
end

----------------------------------------------------------------------
-- wssIsSoundPlaying
----------------------------------------------------------------------
-- 
function wssIsSoundPlaying()
	if self.isMasterSpeaker then
		if entity.animationState("wssState") == "off" then
			return false
		end
		return true
		
	elseif self.masterSpeaker > 0 then
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
	if self.isMasterSpeaker then
		return storage.wss.currentSound
		
	elseif self.masterSpeaker > 0 then
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
function wssHandoverMaster(speakers, csound, lasound)
	self.registeredSpeakers = speakers
	self.isMasterSpeaker = true
	self.masterSpeaker = nil
	storage.wss.currentSound = csound
	storage.wss.lastActiveSound = lasound
end

----------------------------------------------------------------------
-- wssRegisterMasterSpeaker
----------------------------------------------------------------------
-- 
function wssRegisterMasterSpeaker()
	--world.logInfo("wss -- looking for master speaker ...")
	
	local objectIds = world.objectQuery(
			entity.position(), 
			self.speakerRange, 
			{withoutEntityId = entity.id()}
		)
	
	--world.logInfo("wss -- " .. tostring(#objectIds) .." objects in area found." )
	local master = nil
	
	for k, v in pairs(objectIds) do
		master = world.callScriptedEntity(
				k, 
				"wssRegisterSpeaker",
				entity.id()
			)
		
		if master ~=nil and master > 0 then
			--world.logInfo("wss -- master found")
			self.masterSpeaker = master
			break;
		end
	end
	if self.masterSpeaker == 0 then
		-- no master  found.
		--world.logInfo("wss -- no master found. I am master now")
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
	--world.logInfo("wss -- registerSpeaker called")
	if not self.isMasterSpeaker then
		return nil
	else
		--world.logInfo("wss -- registerSpeaker master speaker" )
		self.registeredSpeakers[#self.registeredSpeakers+1] = speakerid
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
	--world.logInfo("wss -- unregisterSpeaker called" )
	if not self.isMasterSpeaker then
		return
	else
		--world.logInfo("wss -- unregisterSpeaker master speaker" )
		for k, v in pairs(self.registeredSpeakers) do
			if v == speakerid then
				table.remove(self.registeredSpeakers, v)
				break
			end
		end
	end
end