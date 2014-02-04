function init(args)

	--Until scripting allows OpenCockpitInterface uncommented
	--entity.setInteractive(true)
	entity.setAllOutboundNodes(false)
	if not virtual then
		responsiveObject.init()
		responsiveObject.start()
	end
end


function onInteraction(args)
	responsiveObject.interact()
	
	-- Since Furious Koala the function is called but
	-- nothing happens if OpenCockpitInterface is called :(
	return { "OpenCockpitInterface",{} }
end


function main() 
	responsiveObject.update()
end
