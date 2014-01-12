function BioticLiftInit()
	data.liftTime = tech.parameter("liftTime")
	data.liftVelocity = tech.parameter("liftVelocity")
	data.liftAcceleration = tech.parameter("liftAcceleration")
	data.liftIds = {}
end

function BioticLiftUninit()
	data.liftIds = nil
end

-- takes args from the update function
-- returns energy usage
function BioticLiftUpdate(args)
	-- if there's enough energy, fire a projectile
	if args.actions["biotic-lift"] then
		if tech.parameter("energyUsage") <= args.availableEnergy then
			local lifted = world.entityQuery(args.aimPosition, 4, { withoutEntityId = tech.parentEntityId(), inSightOf = tech.parentEntityId(), notAnObject = true })
			if lifted and #lifted > 0 then
				table.insert(data.liftIds, { lifted = lifted, ttl = data.liftTime, liftvel = data.liftVelocity })
				tech.setAnimationState("active", "on")
				tech.playImmediateSound(tech.parameter("liftsound"))
				data.updateEnergyUsage = data.updateEnergyUsage + tech.parameter("energyUsage")
			end
		end
	end
	
	local cpos
	for i,lift in ipairs(data.liftIds) do
		lift.ttl = lift.ttl - args.dt
		-- end of effect
		if lift.ttl <= 0 then
			-- restore normal movement, animations, and rotation for lifted entities that are still alive
			for l,e in ipairs(lift.lifted) do
				if world.entityExists(e) then
					-- do restore stuff here
				end
			end
			table.remove(data.liftIds, i)
		-- continue to affect lifted entities
		else
			local stillgood = false
			for l,e in ipairs(lift.lifted) do
				if world.entityExists(e) then
					stillgood = true
					world.callScriptedEntity(e, "entity.setVelocity", {0, lift.liftvel})
				else table.remove(lift.lifted, l)
				end
			end
			if not stillgood then
				table.remove(data.liftIds, i)
			end
		end
	end
end

function init()
	BioticLiftInit()
end

function uninit()
	BioticLiftUninit()
end

function input(args)
	if args.moves["special"] == 1 then
		return "biotic-lift"
	end
	
	return nil
end

function update(args)
	data.updateEnergyUsage = 0
	
	BioticLiftUpdate(args)
		
	return data.updateEnergyUsage
end
