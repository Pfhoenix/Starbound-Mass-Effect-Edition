function init(args)
	if not virtual then
		wssInit()
		entity.setInteractive(true)
	end
	
	-- to add new track increase the count here and add new animations to the animation file.
	self.trackcount = 2
	-- 0 = off
	self.currenttrack = 0
	self.dlg = "off"
end

function die()
	wssDie()
end

function nextTrack()
	self.currenttrack = self.currenttrack +1
	
	if self.currenttrack > self.trackcount then
		self.currenttrack = 0
	end
	
	local sound = "off"
	
	if self.currenttrack > 0 then
		sound = "track" .. self.currenttrack
	end
	
	self.dlg = sound
	
	wssTriggerSound(sound)

end


function onInteraction(args)
	nextTrack()
	
	-- say does not work here need to find another way to give some feedback
	-- ShowPopup is no option since it plays the anoing quest sound.
	-- entity.say("radioDialog", self.dlg)
	
	-- FIXME
	-- world.logInfo(args)
	-- entity.say(self.dlg)
	-- Test say with nearest player entity or if args contains player entity.
	
	return nil
end


function main() 
	wssUpdate()
	
end
