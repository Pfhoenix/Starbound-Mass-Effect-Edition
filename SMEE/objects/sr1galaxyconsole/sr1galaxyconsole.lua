function init(args)
	entity.setInteractive(true)
	entity.setAllOutboundNodes(false)
	entity.setAnimationState("stationState", "idleseq1")
	self.transdelay = -1
end


function isIdle()	
	return entity.animationState("stationState") == "idleseq1" 
			or entity.animationState("stationState") == "idleseq2"
			or entity.animationState("stationState") == "transnormandy"
end


function transGalaxy()
	if isIdle() then
		entity.setAnimationState("stationState", "transgalaxy")
		self.transdelay = 5
	end
end


function transNormandy()
	if not isIdle() then
		entity.setAnimationState("stationState", "transnormandy")
		self.transdelay = 5
	end
end

function randomNormandy()
	-- TODO show random normandy sequence
	entity.setAnimationState("stationState", "idleseq2")
	--entity.setAnimationState("stationState", "idleseq1")
		
end


function onInteraction(args)
	transGalaxy()
	-- unfortunatly OpenCockpitInterface calls also sit 
	-- and cannot sit on an entity of objectType wire 
	return { "OpenCockpitInterface",{} }
end


function main() 
	
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
  
  -- TODO switch idle animations
  
	-- detect everything that runs around
	local radius = entity.configParameter("detectRadius")
	local entityIds = world.entityQuery(
			entity.position(), 
			radius, 
			{ notAnObject = true }
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
end
