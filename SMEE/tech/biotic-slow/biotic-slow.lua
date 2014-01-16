function init()
	data.energyUsage = tech.parameter("energyUsage")
	data.targetYVel = tech.parameter("targetYVel")
	data.maxAccel = tech.parameter("maxAccel")
	data.anim = false
end

function uninit()
	tech.setAnimationState("active", "off")
	data.anim = false
end

function input(args)
	if not tech.falling then
		return nil
	end
	
	if args.moves["down"] then
		return "biotic-slow"
	end
	
	return nil
end

function update(args)
	if args.actions["biotic-slow"] then
		if args.availableEnergy < data.energyUsage * args.dt then
			tech.setAnimationState("active", "off")
			data.anim = false
			return
		end
		local pvel = tech.velocity()
		if pvel[2] < data.targetYVel then
			pvel[2] = pvel[2] + data.maxAccel * args.dt
			if (pvel[2] > data.targetYVel) then
				pvel[2] = data.targetYVel
			end
			tech.setYVelocity(pvel[2])
			-- need to spawn some effect if enough time has passed since the last effect was spawned
			if not data.anim then
				tech.setAnimationState("active", "on")
				data.anim = true
			end
			return data.energyUsage * args.dt
		end
	elseif data.anim then
		tech.setAnimationState("active", "off")
		data.anim = false
	end
end