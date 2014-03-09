function init(virtual)
	entity.setInteractive(true)
	if not virtual then
		responsiveObject.init()
		responsiveObject.start()
		wssInit()
	end
end

function die()
	wssDie()
	responsiveObject.die()
end


function onInteraction(args)
	responsiveObject.interact()
	
	local flipDirection = entity.configParameter("sitFlipDirection") 
	local position = entity.configParameter("sitPosition") 
	local orientation = entity.configParameter("sitOrientation") 
	
	return { "OpenCockpitInterface",
			{
				sitFlipDirection = flipDirection,
				sitPosition = position,
				sitOrientation = orientation
			} 
		}
end


function main() 
	wssUpdate()
	responsiveObject.update()
	
	local isactive = responsiveObject.isActive()
	local sound = entity.animationState("wssState")
	
	if isactive and sound ~= "galaxy" then
		wssTriggerSound("galaxy")
	elseif not isactive and sound == "galaxy" then
		wssTriggerLastSound()
	end
	
end
