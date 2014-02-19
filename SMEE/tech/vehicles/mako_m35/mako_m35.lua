function init()
	data.active = false
	data.fireTimer = 0
	tech.setVisible(false)
	tech.rotateGroup("guns", 0, true)
	data.flip = false
	-- thrusters
	data.jumping = false
	data.jumpPressed = false
	data.thrustEnergyUsage = tech.parameter("thrustEnergyUsage")
	data.maxThrustAcceleration = tech.parameter("maxThrustAcceleration")
	-- tire parameters
	data.tireRadius = tech.parameter("tireRadius")
	data.tireFrames = tech.parameter("tireFrames")
	data.tireAngle = 0

end


function uninit()
	if data.active then
		local mechTransformPositionChange = tech.parameter("mechTransformPositionChange")
		tech.translate({-mechTransformPositionChange[1], -mechTransformPositionChange[2]})
		tech.setParentOffset({0, 0})
		data.active = false
		tech.setVisible(false)
		tech.setParentAppearance("normal")
		tech.setToolUsageSuppressed(false)
		tech.setParentFacingDirection(nil)
		data.tireAngle = 0
	end
end


function input(args)
  -- because we can't return multiple actions per frame, and thrusting needs per-frame response
  data.inputArgs = args

  if args.moves["special"] == 1 then
    if data.active then
      return "mechDeactivate"
    else
      return "mechActivate"
    end
  elseif args.moves["primaryFire"] then
    return "mechFire"
  end

  return nil
end

-- Animates the tires in the same way as the morphball tech

function animateTires(args)
	if data.active then
		
		if tech.onGround() then
			data.angularVelocity = tech.measuredVelocity()[1] / data.tireRadius
		else
			-- TODO slow down tires
		end
		
		
		if data.flip then
			data.angularVelocity = data.angularVelocity * (-1)
		end
		
		data.tireAngle = math.fmod(math.pi * 2 + data.tireAngle + data.angularVelocity * args.dt, math.pi * 2)

		-- Rotation frames for the ball are given as one *half* rotation so two
		-- full cycles of each of the ball frames completes a total rotation.
		local tireframe = math.floor(data.tireAngle / math.pi * data.tireFrames) % data.tireFrames
		tech.setGlobalTag("tireFrame", tireframe)
		
		-- TODO add reaction to the terrain
		-- check if directly below the tire is a foreground tile if not move them down.
		
	end
end

function update(args)
  local frameEnergyCost = 0
  
  local energyCostPerSecond = tech.parameter("energyCostPerSecond")
  local mechCustomMovementParameters = tech.parameter("mechCustomMovementParameters")
  local mechTransformPositionChange = tech.parameter("mechTransformPositionChange")
  local parentOffset = tech.parameter("parentOffset")
  local mechCollisionTest = tech.parameter("mechCollisionTest")
  local mechAimLimit = tech.parameter("mechAimLimit") * math.pi / 180
  local mechFrontRotationPoint = tech.parameter("mechFrontRotationPoint")
  local mechFrontFirePosition = tech.parameter("mechFrontFirePosition")
  local mechBackRotationPoint = tech.parameter("mechBackRotationPoint")
  local mechBackFirePosition = tech.parameter("mechBackFirePosition")
  local mechFireCycle = tech.parameter("mechFireCycle")
  local mechProjectile = tech.parameter("mechProjectile")
  local mechProjectileConfig = tech.parameter("mechProjectileConfig")

  if not data.active and args.actions["mechActivate"] then
    mechCollisionTest[1] = mechCollisionTest[1] + tech.position()[1]
    mechCollisionTest[2] = mechCollisionTest[2] + tech.position()[2]
    mechCollisionTest[3] = mechCollisionTest[3] + tech.position()[1]
    mechCollisionTest[4] = mechCollisionTest[4] + tech.position()[2]
    if not world.rectCollision(mechCollisionTest) then
      tech.burstParticleEmitter("mechActivateParticles")
      tech.translate(mechTransformPositionChange)
      tech.setVisible(true)
      tech.setParentAppearance("sit")
      tech.setToolUsageSuppressed(true)
      data.active = true
      data.jumpPressed = false -- don't want start thrusting immediately unintentionally
    else
      -- Make some kind of error noise
    end
  elseif data.active and (args.actions["mechDeactivate"] or energyCostPerSecond * args.dt > args.availableEnergy) then
    tech.burstParticleEmitter("mechDeactivateParticles")
    tech.translate({-mechTransformPositionChange[1], -mechTransformPositionChange[2]})
    tech.setVisible(false)
    tech.setParentAppearance("normal")
    tech.setToolUsageSuppressed(false)
    tech.setParentOffset({0, 0})
    data.active = false
    data.jumping = false
  end

  tech.setParentFacingDirection(nil)
  if data.active then
    -- handle jumping first so that code later can account for being off-ground or falling as necessary
    if data.inputArgs.moves["jump"] then
      if not data.jumping then
        -- turn on thrusting animations/particles/whatnot
        data.jumping = true
      end
      
      -- this will get later changed to take into account the rotation of the mako itself
      local vector = { 0, data.maxThrustAcceleration }
      if data.thrustEnergyUsage * args.dt <= args.availableEnergy then
		local pv = tech.velocity()
		tech.setVelocity({ pv[1] + vector[1] * args.dt, pv[2] + vector[2] * args.dt })
		frameEnergyCost = frameEnergyCost + data.thrustEnergyUsage * args.dt
      else
        -- turn off thrusting animations/particles/whatnot
        data.jumping = false
      end
    else
      if data.jumping then
        -- turn off thrusting animations/particles/whatnot
        data.jumping = false
      end
    end
  
    local diff = world.distance(args.aimPosition, tech.position())
    local aimAngle = math.atan2(diff[2], diff[1])
	data.flip = aimAngle > math.pi / 2 or aimAngle < -math.pi / 2
  	
    tech.applyMovementParameters(mechCustomMovementParameters)
    if data.flip then
    
      tech.setFlipped(true)
      local nudge = tech.stateNudge()
      tech.setParentOffset({-parentOffset[1] - nudge[1], parentOffset[2] + nudge[2]})
      tech.setParentFacingDirection(-1)

      if aimAngle > 0 then
        aimAngle = math.max(aimAngle, math.pi - mechAimLimit)
      else
        aimAngle = math.min(aimAngle, -math.pi + mechAimLimit)
      end

      tech.rotateGroup("guns", math.pi - aimAngle)
    else
      tech.setFlipped(false)
      local nudge = tech.stateNudge()
      tech.setParentOffset({parentOffset[1] + nudge[1], parentOffset[2] + nudge[2]})
      tech.setParentFacingDirection(1)

      if aimAngle > 0 then
        aimAngle = math.min(aimAngle, mechAimLimit)
      else
        aimAngle = math.max(aimAngle, -mechAimLimit)
      end

      tech.rotateGroup("guns", aimAngle)
    end

    if not tech.onGround() then
      if tech.velocity()[2] > 0 then
        tech.setAnimationState("movement", "jump")
      else
        tech.setAnimationState("movement", "fall")
      end
    elseif tech.walking() or tech.running() then
      if data.flip and tech.direction() == 1 or not data.flip and tech.direction() == -1 then
          tech.setAnimationState("movement", "drive")
      else
        tech.setAnimationState("movement", "drive")
      end
    else
      tech.setAnimationState("movement", "idle")
    end

    if args.actions["mechFire"] then
      if data.fireTimer <= 0 then
        world.spawnProjectile(mechProjectile, tech.anchorPoint("frontGunFirePoint"), tech.parentEntityId(), {math.cos(aimAngle), math.sin(aimAngle)}, false, mechProjectileConfig)
        data.fireTimer = data.fireTimer + mechFireCycle
        tech.setAnimationState("frontFiring", "fire")
      else
        local oldFireTimer = data.fireTimer
        data.fireTimer = data.fireTimer - args.dt
        if oldFireTimer > mechFireCycle / 2 and data.fireTimer <= mechFireCycle / 2 then
          world.spawnProjectile(mechProjectile, tech.anchorPoint("backGunFirePoint"), tech.parentEntityId(), {math.cos(aimAngle), math.sin(aimAngle)}, false, mechProjectileConfig)
          tech.setAnimationState("backFiring", "fire")
        end
      end
    end
	
	animateTires(args)
	
    frameEnergyCost = frameEnergyCost + energyCostPerSecond * args.dt
    return frameEnergyCost
  end

  return 0
end
