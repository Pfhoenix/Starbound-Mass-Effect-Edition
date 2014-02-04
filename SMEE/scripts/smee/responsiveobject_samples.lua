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
				"time" : -1,			// optional
				"sounds" : ""		// optional
			},
			"transIdle" : {
				"name" : "yourAnimName",
				"time" : -1,			// optional
				"sounds" : ""		// optional
			},
		}
	}

-- ===================================================================
-- sample for your .lua file (LUA Syntax):
-- ===================================================================
	