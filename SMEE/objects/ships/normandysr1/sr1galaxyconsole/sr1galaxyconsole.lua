function init(virtual)
	entity.setInteractive(true)
	if not virtual then
		responsiveObject.init()
		responsiveObject.start()
	end
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
	responsiveObject.update()
end
