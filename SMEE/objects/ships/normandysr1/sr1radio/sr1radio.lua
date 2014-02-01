function init(args)
	entity.setInteractive(true)
	entity.setAllOutboundNodes(false)
	entity.setAnimationState("radioState", "idle")
	
	-- to add new track increase the count here and add new animations to the animation file.
	self.trackcount = 2
	-- 0 = off
	self.currenttrack = 0
	self.dlg = "idle"
end


function nextTrack()
	self.currenttrack = self.currenttrack +1
	
	if self.currenttrack > self.trackcount then
		self.currenttrack = 0
	end
	
	if self.currenttrack > 0 then
		-- next track
		entity.setAnimationState("radioState", "track" .. self.currenttrack)
		self.dlg = "track" .. self.currenttrack
	else
		-- off
		entity.setAnimationState("radioState", "idle")
		self.dlg = "idle"
	end

end


function onInteraction(args)
	nextTrack()
	
	-- say does not work here need to find another way to give some feedback
	-- ShowPopup is no option since it plays the anoing quest sound.
	-- entity.say("radioDialog", self.dlg)
	
	return nil
end


function main() 
	
	
end
