function init(virtual)
	entity.setInteractive(true)
	if not virtual then
		wss.getInstance()
		wss.registerSpeaker(entity)
	end
end

function die()
	--wss.getInstance()
	wss.unregisterSpeaker(entity)
	
end


function onInteraction(args)
	--wss.getInstance()
	
	if not wss.isSoundPlaying() then
		wss.triggerSound("wssTrack1")
	else
		wss.triggerSound("")
	end 
	
	return nil
end


function main()
	--wss.getInstance()
	wss.update(entity)
end
