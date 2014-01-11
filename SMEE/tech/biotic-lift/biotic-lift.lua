function BioticLiftInit()
	data.liftTime = tech.parameter("liftTime")
	data.liftVelocity = tech.parameter("liftVelocity")
	data.liftAcceleration = tech.parameter("liftAcceleration")
	data.projIds = {}
end

function BioticLiftUninit()
	data.projIds = nil
end

-- takes args from the update function
-- returns energy usage
function BioticLiftUpdate(args)
	-- if there's enough energy, fire a projectile
	if args.actions["biotic-lift"] then
		if tech.parameter("energyUsage") <= args.availableEnergy then
			local dir = {}
			local pos = tech.position()
			dir[1] = args.aimPosition[1] - pos[1]
			dir[2] = args.aimPosition[2] - pos[2]
			local dist = math.sqrt(dir[1] * dir[1] + dir[2] * dir[2])
			local newpos = {}
			newpos[1] = dir[1] / dist + pos[1]
			newpos[2] = dir[2] / dist + pos[2]

			local pid = world.spawnProjectile("biotic-lift", newpos, tech.parentEntityId(), dir, false)
			local ppos = world.entityPosition(pid)
			-- format is entityId of projectile, last position of the projectile, time to live for the lifting effect, and the list of lifted entities
			table.insert(data.projIds, { id = pid, pos = ppos, ttl = data.liftTime, lifted = nil })
			data.updateEnergyUsage = data.updateEnergyUsage + tech.parameter("energyUsage")
		end
	end
	
	local cpos
	for i,proj in ipairs(data.projIds) do
		-- projectile is dead and lifting entities
		if not world.entityExists(proj.id) then
			if proj.lifted then
				proj.ttl = proj.ttl - args.dt
				-- end of effect
				if proj.ttl <= 0 then
					-- restore normal movement, animations, and rotation for lifted entities that are still alive
					for l,e in ipairs(proj.lifted) do
						if world.entityExists(e) then
							-- do restore stuff here
						end
					end
					table.remove(data.projIds, i)
				-- continue to affect lifted entities
				else
					local stillgood = false
					for l,e in ipairs(proj.lifted) do
						if world.entityExists(e) then
							stillgood = true
							world.callScriptedEntity(e, "entity.setVelocity", {0, data.liftVelocity})
							--world.spawnProjectile("singleDefaultBlue", world.entityPosition(e), tech.parentEntityId(), { 0, 0 }, false)
						else table.remove(proj.lifted, l)
						end
					end
					-- this projectile is no longer lifting anything, so remove it
					if not stillgood then
						table.remove(data.projIds, i)
					end
				end
			else
				-- use proj.pos to get enemies near the impact point
				proj.lifted = world.entityQuery(proj.pos, 4, { withoutEntityId = tech.parentEntityId(), notAnObject = true } )
				if not proj.lifted or #proj.lifted == 0 then
					table.remove(data.projIds, i)
				else
					-- disable normal movement, freeze animations, and capture rotation stuff to make them rotate slight
					--[[for l,v in ipairs(proj.lifted) do
						world.logInfo("Lifted %s going at %s", v, world.callScriptedEntity(v, "entity.velocity"))
					end]]--
				end
			end
		-- projectile is alive and moving, store the current position
		else
			proj.pos = world.entityPosition(proj.id)
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
