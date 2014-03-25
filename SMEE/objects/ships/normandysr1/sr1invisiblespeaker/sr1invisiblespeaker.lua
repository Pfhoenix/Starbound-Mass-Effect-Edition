function init(virtual)
	if not virtual then
		wssInit()
	end
end

function die()
	wssDie()
end


function onInteraction(args)
	return nil
end


function main()
	wssUpdate()
end
