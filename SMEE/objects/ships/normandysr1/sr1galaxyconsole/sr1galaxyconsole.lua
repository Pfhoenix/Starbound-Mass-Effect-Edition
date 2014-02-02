function init(args)
	--Until scripting allows OpenCockpitInterface uncommented
	--entity.setInteractive(true)
	entity.setAllOutboundNodes(false)
	entity.setAnimationState("stationState", "idleseq1")
	self.transdelay = -1
	self.idledelay = 10
end


function isIdle()	
	return entity.animationState("stationState") == "idleseq1" 
			or entity.animationState("stationState") == "idleseq2"
			or entity.animationState("stationState") == "transnormandy"
end


function transGalaxy()
	if isIdle() then
		entity.setAnimationState("stationState", "transgalaxy")
		entity.playSound("zoomInSounds")
		self.transdelay = 5
	end
end


function transNormandy()
	if not isIdle() then
		entity.setAnimationState("stationState", "transnormandy")
		entity.playSound("zoomOutSounds")
		self.transdelay = 5
	end
end

-- if we have more idle states change value here
function randomNormandy()
	self.idledelay = 10;
	entity.setAnimationState(
			"stationState", 
			"idleseq" .. math.random(1, 2)
		)
end


function onInteraction(args)
	transGalaxy()
	
	-- Since Furious Koala the function is called but
	-- nothing happens if OpenCockpitInterface is called :(
	return { "OpenCockpitInterface",{} }
end


function main() 
	
	-- transition done
	if self.transdelay > 0 then
		self.transdelay = self.transdelay -1
	else  
		-- switch to on loop
		if self.transdelay == 0 then
			if entity.animationState("stationState") == "transnormandy" then
				randomNormandy()
			else
				entity.setAnimationState("stationState", "galaxy")
			end
			self.transdelay = -1
		end
	end

	-- detect everything that runs around
	local radius = entity.configParameter("detectRadius")
	local entityIds = world.playerQuery(
			entity.position(), 
			radius, 
			{ inSightOf = entity.id() }
		)
	
	if isIdle() then
		if #entityIds > 0 then
			transGalaxy()
		end
	elseif not isIdle() then
		if #entityIds == 0 then
			transNormandy()
		end
	end
	
	-- switch idle anims
	if isIdle() and self.transdelay < 0 then
		if self.idledelay > 0 then
			self.idledelay = self.idledelay -1
		else  
			randomNormandy()
		end
	end
	
end
