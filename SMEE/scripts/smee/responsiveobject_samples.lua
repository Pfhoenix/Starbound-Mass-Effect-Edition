-- DO NOT INCLUDE THIS SCRIPT TO ANY OBJECT
-- THIS THIS JUST A SAMPLE FILE FOR RESPONSIVEOBJECT

-- REMOVE the lua comments inside these code spippets!

-- ===================================================================
-- include this with your values into your .object file (JSON Syntax):
-- ===================================================================
	
-- ===================================================================
-- starbound properties:
-- ===================================================================
	"objectType" : "wire",
	"scripts" : [ 
			"/scripts/smee/responsiveobject.lua", 
			"yourobjectscript.lua" 
		],
	"scriptDelta" : 5,
	"animation" : "youranimationfile.animation",
	"animationParts" : {
			"yourpartid" : "youranimationimage.png"
		},


-- ===================================================================
-- sound configuration:
-- ===================================================================
-- this is need since playSound needs a key instead of an array with
-- sound files

	"mySounds" : [ "/sfx/somesoundfile.ogg" ],
	
-- ===================================================================
-- responsive object properties sample:
-- ===================================================================
	"responsiveObject" : {
		"detectRadius" : 5,				// 5 is a good radius
		"detectLineOfSight" : true,		//optional default true
		"responsiveAnimations" : {
			"randomize" : true,
			"idle" : [
				{
					"name" : "yourAnimName",
					"time" : -1,		// optional
					"sounds" : ""		// optional
				}
				-- and more
			],
			"active" : [
				{
					"name" : "yourAnimName",
					"time" : -1,		// optional
					"sounds" : ""		// optional
				}
				-- and more
			],
			-- transitions are optional remove them if not needed
			"transActive" : {
				"name" : "yourAnimName",
				"time" : -1,				// optional
				"sounds" : "mySounds"		// optional
			},
			"transIdle" : {
				"name" : "yourAnimName",
				"time" : -1,				// optional
				"sounds" : "mySounds"		// optional
			},
		}
	}

-- ===================================================================
-- sample for your .lua file (LUA Syntax):
-- ===================================================================

function init(virtual)
	entity.setInteractive(true)
	entity.setAllOutboundNodes(false)
	
	if not virtual then
		responsiveObject.init()
		-- you can also add animation states here with:
		-- responsiveObject.registerAnimation
		responsiveObject.start()
	end
	
	-- TODO your custom code here
end


-- only need if entity.setInteractive(true)
function onInteraction(args)
	-- optional if you don't need it remove this line
	responsiveObject.interact()
	
	return { "", {} }
end


function main() 
	responsiveObject.update()
	
	-- TODO your custom code here
end

function die() 
	responsiveObject.die()
	
	-- TODO your custom code here
end
	