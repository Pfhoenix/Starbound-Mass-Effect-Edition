-- ===================================================================
-- RESPONSIVE OBJECT
-- ===================================================================
-- Version 1.0.0
--
-- little module/API for furniture and decorations to respond 
-- if a player enters it proximity radius and trigger animations
--
-- Config Parameters:
-- see sample file
--
-- Animation State:
-- entity.animationState("responsiveState")

----------------------------------------------------------------------
-- Definition
----------------------------------------------------------------------
responsiveObject = {}

----------------------------------------------------------------------
-- init
----------------------------------------------------------------------
-- 
-- call it in your entities init() hook.
function responsiveObject.init()
	
	self.anims = {}
	
	-- indexed array
	self.anims.idle = {}
	-- indexed array
	self.anims.active = {}
	
	-- transitions are optional and you can only have one to idle and one to active.
	self.anims.transIdle = {}
	self.anims.transIdle.name = ""
	self.anims.transIdle.time = -1
	self.anims.transIdle.sounds = nil
	
	self.anims.transActive = {}
	self.anims.transActive.name = ""
	self.anims.transActive.time = -1
	self.anims.transActive.sounds = nil
	
	responsiveObject.parse()
	self.timer = -1
end

----------------------------------------------------------------------
-- start
----------------------------------------------------------------------
-- 
-- call it in your entities init() hook after 
-- the responsive object initialization.
-- and optional registerAnimation calls.
function responsiveObject.start()

	entity.setAnimationState(
			"responsiveState",
			self.anims.idle[1].name
		)
	self.timer = self.anims.idle[1].time
	
end

----------------------------------------------------------------------
-- update
----------------------------------------------------------------------
-- 
-- call it in your entities main() hook.
function responsiveObject.update()

	-- first count down timer
	if self.timer > 0 then
		self.timer = self.timer - 1
	elseif self.timer == 0 then
		-- check if timer 0 and an animation switch is needed
		self.timer = -1
		
		-- transitions
		if entity.animationState("responsiveState") == self.anims.transActive.name then
			responsiveObject.nextAnimation("active")
		elseif entity.animationState("responsiveState") == self.anims.transIdle.name then
			responsiveObject.nextAnimation("idle")
		else
			if responsiveObject.isIdle() and #self.anims.idle > 1  then
				responsiveObject.nextAnimation("idle")
			elseif #self.anims.active > 1 then
				responsiveObject.nextAnimation("active")
			end
		end
		
	end
	
	-- detect player 
	local entityIds = world.playerQuery(
			entity.position(), 
			self.detectRadius, 
			{ inSightOf = entity.id() }
		)
	
	if responsiveObject.isIdle() then
		if #entityIds > 0 then
			responsiveObject.switchToActive()
		end
	elseif not responsiveObject.isIdle() then
		if #entityIds == 0 then
			responsiveObject.switchToIdle()
		end
	end
	
end


----------------------------------------------------------------------
-- die
----------------------------------------------------------------------
-- 
-- call it in your entities die() hook.
function responsiveObject.die()
	self.anims = nil
end

----------------------------------------------------------------------
-- interact
----------------------------------------------------------------------
-- 
-- optional, only if your entity is interactive (mouseover + E)
-- call it in your entities onInteraction() hook.
--
-- triggers the first active animation.
function responsiveObject.interact()
	
	if responsiveObject.isActive() then
		return
	end
	
	entity.setAnimationState(
			"responsiveState",
			self.anims.active[1].name
		)
	
	self.timer = self.anims.active[1].time
	
	if self.anims.active[1].sounds ~= nil then 
		entity.playSound(self.anims.active[1].sounds)
	end
end

----------------------------------------------------------------------
-- isIdle
----------------------------------------------------------------------
-- 
-- the object is idle or off 
--
-- returns true if one of the registered idle animation runs or
-- the idle transition runs.
function responsiveObject.isIdle()

	for i = 1, #self.anims.idle do
		if entity.animationState("responsiveState") == self.anims.idle[i].name then 
			return true
		end
	end
	if entity.animationState("responsiveState") == self.anims.transIdle.name then 
		return true
	end
	
	return false
end

----------------------------------------------------------------------
-- isActive
----------------------------------------------------------------------
-- 
-- the object is active
--
-- returns true if one of the registered active animation runs or
-- the active transition runs.
function responsiveObject.isActive()
	
	for i = 1, #self.anims.active do
		if entity.animationState("responsiveState") == self.anims.active[i].name then 
			return true
		end
	end
	if entity.animationState("responsiveState") == self.anims.transActive.name then 
		return true
	end
	
	return false
end


function responsiveObject.switchToActive()
	if responsiveObject.isIdle() then
		entity.setAnimationState(
				"responsiveState", 
				self.anims.transActive.name
			)
		if not self.anims.transActive.sounds ~= nil then 
			entity.playSound(self.anims.transActive.sounds)
		end
		self.timer = self.anims.transActive.time
	end
end


function responsiveObject.switchToIdle()
	if not responsiveObject.isIdle() then
		entity.setAnimationState(
				"responsiveState", 
				self.anims.transIdle.name
			)
		if not self.anims.transIdle.sounds ~= nil then 
			entity.playSound(self.anims.transIdle.sounds)
		end
		self.timer = self.anims.transIdle.time
	end
end

----------------------------------------------------------------------
-- nextAnimation
----------------------------------------------------------------------
--
-- switches to the next animation of that type
function responsiveObject.nextAnimation(type)
	
	local anims = self.anims[type]
	local index = 1
	
	if self.randomize == true then
		index = math.random(1, #anims)
	end
	
	entity.setAnimationState(
			"responsiveState", 
			anims[index].name
		)
	self.timer = anims[index].time
	
	if anims[index].sounds ~= nil then 
		entity.playSound(anims[index].sounds)
	end
	
end

----------------------------------------------------------------------
-- registerAnimation
----------------------------------------------------------------------
-- 
-- registers an animation for the responsive object
-- the animation file of the object must have responsiveState state types defined.
--
-- @param name string name of the animation state
-- @param type string can be:
-- 		"idle" - for off or idle animations (this means no player around)
-- 		"active" - for off or idle animations (with at least one player in proximity)
-- 		"transIdle" - optional transition from active to idle anim
-- 		"transActive" - optional transition from idle to active anim
-- @param time number time how many update loops are waited until the next stage is entered
--		this means the duration is multiplied with your scriptDelta value
-- @param sounds array of strings 
function responsiveObject.registerAnimation(
		name,
		type,
		time,
		sounds
	)
	
	if type == "transIdle" then
		self.anims.transIdle.name = name;
		self.anims.transIdle.time = time;
		self.anims.transIdle.sounds = sounds;
		
	elseif type == "transActive" then
		self.anims.transActive.name = name;
		self.anims.transActive.time = time;
		self.anims.transActive.sounds = sounds;
		
	else
		local ani =  {}
		ani.name = name
		ani.time = time
		ani.sounds = sounds
		
		self.anims[type][#self.anims[type]+1] = ani
	end
end

----------------------------------------------------------------------
-- parse
----------------------------------------------------------------------
--
-- starts parsing the configParameters from our object file
--
function responsiveObject.parse()

	-- can be nil since you can also call registerAnimation to setup the states
	local responsiveConfig = entity.configParameter("responsiveObject") 
	if responsiveConfig == nil then
		return
	end
	
	-- not nil parse params 
	-- "mostly fail saved"
	self.detectRadius = responsiveConfig.detectRadius
	if self.detectRadius == nil then
		self.detectRadius = 1
	end
	
	self.detectLineOfSight = responsiveConfig.detectLineOfSight
	if self.detectLineOfSight == nil then
		self.detectLineOfSight = true
	end
	
	self.randomize = responsiveConfig.responsiveAnimations.randomize
	if self.randomize == nil then
		self.randomize = false
	end
	
	responsiveObject.parseAnimationArray("idle")
	responsiveObject.parseAnimationArray("active")
	responsiveObject.parseTransition("transActive")
	responsiveObject.parseTransition("transIdle")
	
end



----------------------------------------------------------------------
-- parseAnimationArray
----------------------------------------------------------------------
--
-- for parsing idle and active
--
function responsiveObject.parseAnimationArray(state)
	
	local responsiveConfig = entity.configParameter("responsiveObject") 
	local arrayanim = responsiveConfig.responsiveAnimations[state]
	
	for i = 1, #arrayanim do
 			
		local time = arrayanim[i].time
		local sounds =  arrayanim[i].sounds
		if time == nil then
			time = -1
		end
		
		responsiveObject.registerAnimation(
				arrayanim[i].name, 
				state, 
				time,
				sounds
			)
	end

end

----------------------------------------------------------------------
-- parseTransition
----------------------------------------------------------------------
--
-- for parsing the optional transitions
--
function responsiveObject.parseTransition(state)
	
	local responsiveConfig = entity.configParameter("responsiveObject") 
	local trans = responsiveConfig.responsiveAnimations[state]
	
	-- since it is optional 
	if trans == nil then
		return
	end
	
	local time = trans.time
	local sounds = trans.sounds
	if time == nil then
		time = -1
	end

	responsiveObject.registerAnimation(
			trans.name, 
			state, 
			time,
			sounds
		)

end
