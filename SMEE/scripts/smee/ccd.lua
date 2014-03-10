-- ===================================================================
-- Citadel Codex Dispenser
-- ===================================================================
-- Version 1.0.0
--
-- API module for dropping codex books on interaction with an object

function ccdInit()
	self.dispenseCodex = entity.configParameter("ccdCodex", "nocodexdefined")
	world.logInfo("ccdInit dispenseCodex: ".. self.dispenseCodex)
	if not storage.ccd then
		storage.ccd = {}
		-- stores the player ids for players that recived a codex
		-- so each player gets only one codex!
		storage.ccd.playerlist = {}
	end
end


function ccdInteract(args)
	world.logInfo("ccd Interact" )
	local playerId = args["sourceId"]
	local uniqueId = world.entityUuid( playerId )
	local found = false
	
	world.logInfo("ccd player uid: " .. tostring(uniqueId) )
	-- Maybe in the future it is possible to detect if a player has a codex entry.
	-- but as long this is not possible we store the UPID into our list
	
	for k,v in pairs(storage.ccd.playerlist) do 
		if v == uniqueId then
			world.logInfo("ccd player uid found")
			found = true
			break
		end
	end
	
	if not found then
		world.logInfo("ccd player uid not found dispense")
	
		world.spawnItem(self.dispenseCodex, entity.position(), 1)
		storage.ccd.playerlist[#storage.ccd.playerlist+1] = uniqueId
		
		world.logInfo("ccd dispense done")
	
	end
end