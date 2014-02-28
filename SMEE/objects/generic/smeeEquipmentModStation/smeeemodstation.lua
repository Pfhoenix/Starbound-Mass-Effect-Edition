function init(virtual)
	entity.setInteractive(true)
	
	if not virtual then
		responsiveObject.init()
		responsiveObject.start()
	end
end


function onInteraction(args)
	responsiveObject.interact()
	
	local params = entity.configParameter("interactData") 
	
	return { "OpenCraftingInterface", { 
			config = params.config, 
			filter = params.filter
		}}
end


function main() 
	responsiveObject.update()
end


function die() 
	responsiveObject.die()
end
