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
	local soundargs = {}
	
	if not wssIsSoundPlaying() then
		soundargs.sound = "wssTrack1"
	else
		soundargs.sound = ""
	end 
	wssTriggerSound(soundargs)
	
	return nil
end


function main()
	wssUpdate()
end
