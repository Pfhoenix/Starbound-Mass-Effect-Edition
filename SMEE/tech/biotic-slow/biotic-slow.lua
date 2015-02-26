function init()
	self.energyUsage = tech.parameter("energyUsage")
	self.targetYVel = tech.parameter("targetYVel")
	self.maxAccel = tech.parameter("maxAccel")
	self.anim = false
end

function uninit()
	tech.setAnimationState("active", "off")
	self.anim = false
end

function input(args)
	if not mcontroller.falling() then
		return nil
	end

	if args.moves["down"] then
		return "biotic-slow"
	end

	return nil
end

function update(args)
	if args.actions["biotic-slow"] then
		if not tech.consumeTechEnergy(self.energyUsage * args.dt) then
			tech.setAnimationState("active", "off")
			self.anim = false
			return
		end

		mcontroller.controlApproachYVelocity(self.targetYVel, self.maxAccel, false)

		if not self.anim then
			tech.setAnimationState("active", "on")
			self.anim = true
		end
	elseif self.anim then
		world.logInfo("Biotic slow turning off")
		tech.setAnimationState("active", "off")
		self.anim = false
	end
end