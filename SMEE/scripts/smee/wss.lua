-- ===================================================================
-- Wireless Sound System
-- ===================================================================
-- Version xxx unfinished
--
-- How this works:
--



-- if dt == -1 force sound switch
function wssBroadcastToSpeakers(sound, dt)

	if #self.registeredSpeakers == nil then
		return nil
	end
	
	self.soundTimer = self.soundTimer - dt
	if self.soundTimer <= 0 or dt == -1 then
	
		if sound ~= "" then
			self.soundTimer = 2.0 -- FIXME entity.configParameter(tostring(sound) .. "Duration")
		else
			self.soundTimer = 0
		end
		
		for i = 1, #self.registeredSpeakers do
			world.callScriptedEntity(self.registeredSpeakers[i], "entity.playSound", sound )
		--	self.registeredSpeakers[i].playSound(sound)
		end
	end
end



----------------------------------------------------------------------
-- init
----------------------------------------------------------------------
-- @param entity

function wssInit()
	world.logInfo("wss -- init")
		
	-- init our parameters
	
	-- the first registers speaker which it also used to trigger
	-- update from his main() function
	self.registeredSpeakers = {}
	self.isMasterSpeaker = false
	self.masterSpeaker = 0
	
	-- current sound playing
	self.currentSound = ""
	-- last sound playing
	self.lastActiveSound = ""
	-- time until sound is finished.
	self.soundTimer = 0
	
	world.logInfo("wss -- init done.")
end

----------------------------------------------------------------------
-- die
----------------------------------------------------------------------

function wssDie()
	world.logInfo("wss -- die")
	
	if self.isMasterSpeaker then
		-- give master to next wss object
		local objectIds = world.objectQuery(
				entity.position(), 
				1000, 
				{withoutEntityId = entity.id()}
			)
		
		if #objectIds > 0 then
			world.callScriptedEntity(
					objectIds[1], 
					"wssHandoverMaster",
					{
						speakers = self.registeredSpeakers,
						csound = self.currentSound,
						lasound = self.lastActiveSound,
						timer = self.soundTimer
					}
				)
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
end


function wssTriggerSound(sound)
	world.logInfo("wss -- triggerSound ")
	
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

function wssTriggerLastSound()
	world.logInfo("wss -- triggerLastSound ")
	
	if self.isMasterSpeaker then
		world.logInfo("wss -- triggerLastSound master speaker")
	
		self.currentSound = self.lastActiveSound
		self.lastActiveSound = ""
		wssBroadcastToSpeakers(self.currentSound,-1)
		
	elseif self.masterSpeaker ~= nil then
		world.logInfo("wss -- triggerLastSound redirect to master speaker")
		world.callScriptedEntity(
				self.masterSpeaker,
				"wssTriggerLastSound"
			)
	end
	
end

-- calls this from every speaker in your main
-- entity = speaker that calls
-- args from main
function wssUpdate()
	
	if not self.isMasterSpeaker and self.masterSpeaker == 0 then
		
		if entity.id() > 0 then
			-- now look for master speaker
			world.logInfo("wss -- looking for master speaker ...")
			
			local objectIds = world.objectQuery(
					entity.position(), 
					1000, 
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
	end 
	
	if not self.isMasterSpeaker then
		return
	end
	
	wssBroadcastToSpeakers(self.currentSound,entity.dt())
end

function wssIsSoundPlaying()
	world.logInfo("wss -- isSoundPlaying")
		
	if self.isMasterSpeaker then
		world.logInfo("wss -- isSoundPlaying master speaker")
		
		if self.currentSound ~= "" then
			return true
		end
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


-- @param args.speakers
-- @param args.csound
-- @param args.lasound
-- @param args.timer
--
function wssHandoverMaster(args)
	world.logInfo("wss -- handoverMaster called")
	
	world.logInfo("wss -- handoverMaster new master speaker found" )
		
	self.registeredSpeakers = args.speakers
	self.isMasterSpeaker = true
	self.masterSpeaker = nil
	self.currentSound = args.csound
	self.lastActiveSound = args.lasound
	self.soundTimer = args.timer
end

-- @param speakerid
-- @return the entity if it is already a master or nil if not
--
function wssRegisterSpeaker(speakerid)
	world.logInfo("wss -- registerSpeaker called")
	if not self.isMasterSpeaker then
		return nil
	else
		world.logInfo("wss -- registerSpeaker master speaker" )
	
		self.registeredSpeakers[#self.registeredSpeakers+1] = speakerid
		return entity.id()
	end
end

-- @param speakerid
function wssUnregisterSpeaker(speakerid)
	
	world.logInfo("wss -- unregisterSpeaker called" )
	if not self.isMasterSpeaker then
		return
	else
		world.logInfo("wss -- unregisterSpeaker master speaker" )
		for i=#self.registeredSpeakers,1,-1 do
			if self.registeredSpeakers[i] == speakerid then
				local removed = table.remove(self.registeredSpeakers, i)
		
				world.callScriptedEntity(removed, "entity.playSound", "" )
				break
			end
		end
	end
end