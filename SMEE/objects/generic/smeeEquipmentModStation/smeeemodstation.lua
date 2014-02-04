function init(virtual)
	entity.setInteractive(true)
	entity.setAllOutboundNodes(false)
	
	if not virtual then
		responsiveObject.init()
		responsiveObject.start()
	end
end


function onInteraction(args)
	responsiveObject.interact()
	
	local params = entity.configParameter("interactData") 
	
	
	-- TODO test if it works
	return { "OpenCraftingInterface", { 
			config = params.config, 
			filter = params.filter
		}}
		
	-- TODO find a way put this in object file entity.configParameter
	--return { "OpenCraftingInterface", { 
	--		config = "/interface/windowconfig/smeeemodstation.config", 
	--		filter = { "craftingtable", "plain", "smee" }} 
	--	}
end


function main() 
	responsiveObject.update()
end


function die() 
	responsiveObject.die()
end
