function init(virtual)
	entity.setInteractive(true)
	entity.setAllOutboundNodes(false)
	
	if not virtual then
		responsiveObject.init()
		responsiveObject.start()
	end
end



function onInteraction(args)
	--turnPowerOn()
	
	-- TODO find a way put this in object file entity.configParameter
	return { "OpenCraftingInterface", { 
			config = "/interface/windowconfig/smeeemodstation.config", 
			filter = { "craftingtable", "plain", "smee" }} 
		}
end


function main() 
	responsiveObject.update()
end

function die() 
	responsiveObject.die()
end
