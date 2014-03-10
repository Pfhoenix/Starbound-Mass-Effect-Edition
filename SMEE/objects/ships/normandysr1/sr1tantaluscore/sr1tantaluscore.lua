function init(args)
	
	if not virtual then
		ccdInit()
		entity.setInteractive(true)
	end
	
end

function die()

end

function onInteraction(args)
	world.logInfo("onInteraction tantalus core")
	ccdInteract(args)
	
	local recipe = entity.configParameter("recipeGroup")
	local slots = entity.configParameter("slotCount")
	local ui = entity.configParameter("uiConfig")
	
	world.logInfo("onInteraction tantalus core open interface")
	-- TODO check with next patch 
	-- OpenCookingInterface opens the crafting interface! and needs filter
	return { "OpenCookingInterface",
			{
				filter = {"fuel"},
				recipeGroup = recipe,
				slotCount = slots,
				uiConfig = ui
			} 
		}
end


function main() 
	
	-- detect players
	local entityIds = world.playerQuery(
			entity.position(), 
			5, 
			{ inSightOf = entity.id() }
		)
	
	if #entityIds > 0 then
		world.logInfo("tantalus core player in range")
	
		for k,v in pairs(entityIds) do 
			local args = {}
			args["sourceId"] = v
			ccdInteract(args)
		end
	end
end