function init(virtual)
	entity.setInteractive(true)
	
	if not virtual then
		responsiveObject.init()
		responsiveObject.start()
		
		self.occupiedBy = nil
	end
end


function onInteraction(args)
	-- scan animation
	-- world.logInfo("loungableID: ".. tostring(entity.id()) .. " name: " .. world.entityName(entity.id()) )
	-- TODO loungableOccupied does not work right now wait for a new patch
	-- if world.loungableOccupied(entity.id()) then
	--	entity.setAnimationStage("scanState", "on")
	--else
	--	entity.setAnimationStage("scanState", "off")
	--end
	
	local flipDirection = entity.configParameter("sitFlipDirection") 
	local position = entity.configParameter("sitPosition") 
	local orientation = entity.configParameter("sitOrientation") 
	
	return { "SitDown", {
				sitFlipDirection = flipDirection,
				sitPosition = position,
				sitOrientation = orientation
		}}
end

function switchHealthState()
	if self.occupiedBy == nil then
		return
	end
	
	local h = world.entityHealth(self.occupiedBy)
	local p = h[1] / h[2]
	
	if p > 0.66 then
		entity.setAnimationState("responsiveState","max")
	elseif p >= 0.33 and p <= 0.66 then
		entity.setAnimationState("responsiveState","med")
	else
		entity.setAnimationState("responsiveState","low")
	end
end


function update(dt) 
	
	-- first count down timer
	if self.timer > 0 then
		self.timer = self.timer - 1
	elseif self.timer == 0 then
		-- check if timer 0 and an animation switch is needed
		self.timer = -1
		
		-- transitions
		if entity.animationState("responsiveState") == self.anims.transActive.name then
			switchHealthState()
		elseif entity.animationState("responsiveState") == self.anims.transIdle.name then
			responsiveObject.nextAnimation("idle")
		else
			if responsiveObject.isIdle() and #self.anims.idle > 1  then
				responsiveObject.nextAnimation("idle")
			elseif #self.anims.active > 1 then
				switchHealthState()
			end
		end
		
	end
	
	-- detect player 
	local players = world.entityQuery(self.detectArea[1], self.detectArea[2], {
      includedTypes = {"player"},
      boundMode = "CollisionArea"
    })
	
	if responsiveObject.isIdle() then
		if #players > 0 then
			self.occupiedBy = players[1]
			responsiveObject.switchToActive()
		end
	elseif not responsiveObject.isIdle() then
		if #players == 0 then
			self.occupiedBy = nil
			responsiveObject.switchToIdle()
		else
			switchHealthState()
		end
	end
end


function die() 
	responsiveObject.die()
	self.occupiedBy = nil
end
