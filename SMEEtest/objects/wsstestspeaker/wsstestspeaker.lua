function init(virtual)
	if not virtual then
		wssInit()
		entity.setInteractive(true)
	end
end

function die()
	wssDie()
end


function onInteraction(args)
	local mysound = nil
	
	if not wssIsSoundPlaying() then
		mysound = "wssTrack1"
	end 
	wssTriggerSound(mysound)
	
	return nil
end


function main()
	wssUpdate()
end
