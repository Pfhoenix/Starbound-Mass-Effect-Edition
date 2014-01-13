function init(args)
	entity.setInteractive(true)
	entity.setAllOutboundNodes(false)
	entity.setAnimationState("stationState", "off")
	self.powerondelay = -1
	self.poweroffdelay = -1
end


function isPowerOn()	
	return entity.animationState("stationState") == "on" 
			or entity.animationState("stationState") == "turnOn"
end


function turnPowerOn()
	if not isPowerOn() then
		entity.setAnimationState("stationState", "turnOn")
		self.powerondelay = 5
	end
end


function turnPowerOff()
	if isPowerOn() then
		entity.setAnimationState("stationState", "turnOff")
		self.poweroffdelay = 5
	end
end


function onInteraction(args)
	turnPowerOn()
	-- TODO find a we put this in object file entity.configParameter
	return { "OpenCraftingInterface", { 
			config = "/interface/windowconfig/smeeemodstation.config", 
			filter = { "craftingtable", "plain", "smee" }} 
		}
end


function main() 
	
	if self.powerondelay > 0 then
		self.powerondelay = self.powerondelay -1
	else  
		-- switch to on loop
		if self.powerondelay == 0 then
			entity.setAnimationState("stationState", "on")
			self.powerondelay = -1
		end
	end
  
	if self.poweroffdelay > 0 then
		self.poweroffdelay = self.poweroffdelay -1
	else  
		-- switch to on loop
		if self.poweroffdelay == 0 then
			entity.setAnimationState("stationState", "off")
			self.poweroffdelay = -1
		end
	end
  
	-- detect everything that runs around
	local radius = entity.configParameter("detectRadius")
	local entityIds = world.entityQuery(
			entity.position(), 
			radius, 
			{ notAnObject = true }
		)	
	if not isPowerOn() then
		if #entityIds > 0 then
			turnPowerOn()
		end
	elseif isPowerOn() then
		if #entityIds == 0 then
			turnPowerOff()
		end
	end
end
