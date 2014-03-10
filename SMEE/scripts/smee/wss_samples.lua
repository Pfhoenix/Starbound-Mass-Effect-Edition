-- DO NOT INCLUDE THIS SCRIPT TO ANY OBJECT
-- THIS THIS JUST A SAMPLE FILE FOR WSS


-- ===================================================================
-- include this with your values into your .object file (JSON Syntax):
-- ===================================================================
	
-- ===================================================================
-- starbound properties:
-- ===================================================================
	-- either wire or loungeable is needed that callScriptedEntity works
	"objectType" : "wire",
	"scripts" : [ 
			"/scripts/smee/wss.lua", 
			"yourotherobjectscripts.lua", ... 
		],
	-- Important: all your wss objects need the same scriptDelta!
	"scriptDelta" : 5,
	"animation" : "youranimationfile.animation",
	"animationParts" : {
			-- is needed since each of the animation parts contain a sound
			"wssSounds" : "youranimationimage.png"
		},


-- ===================================================================
-- wss properties:
-- ===================================================================
	"wssSpeakerGroup" : "sr1ship", --TODO not implemented yet
	"wssSpeakerRange" : 1000, -- defines the range that is scanned for a possible master and other speakers
	

-- ===================================================================
-- sample snippet for your .animation file (JSON Syntax):
-- ===================================================================
-- Important: all linked objects need the same wssStates!
-- Also off is always needed to turn the sound off.

"animatedParts" : {
	"stateTypes" : {
		"wssState" : {
			"default" : "off",
			"states" : {
				-- turns the music off
				"off" : {
				},
				
				"track1" : {
					"properties" : {
						"persistentSound" : "asoundtoplay.ogg"
					}
				},
				-- Add more 
			}
		}
	},

	"parts" : {
		"wssSounds" : {
			"properties" : {
				"centered" : false
			},

			"partStates" : {
				"wssState" : {
					"off" : {
						"properties" : {
							"image" : "<partImage>"
						}
					},
					"track1" : {
						"properties" : {
							"image" : "<partImage>"
						}
					},
					-- Add more 
				}
			}
		}
	}
}

		
-- ===================================================================
-- sample for your .lua file (LUA Syntax):
-- ===================================================================

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
	local mysound = "off"
	
	if not wssIsSoundPlaying() then
		mysound = "track1"
	end 
	wssTriggerSound(mysound)
	
	return nil
end


function main()
	wssUpdate()
end
