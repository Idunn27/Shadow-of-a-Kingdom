local minHUD = {}

-- require('minHUD')
-- You'll need the above code pasted in your luna.lua file.
-- Code made by Hatsune Blake! Please give credit!

local textplus = require("textplus")
local hudoverride = require("hudoverride")
local t = 0

-- Star Coin related stuff
local starcoin = require("npcs/ai/starcoin") 
starcoin.getLevelList()

function minHUD.onInitAPI()
    --registerEvent(twilightHUD, "onStart", "onStart")
    --registerEvent(twilightHUD, "onTick", "onTick")
end

-- Fonts
local minFont = textplus.loadFont("minFont.ini")

--------------
-- Settings --
--------------
-- You can tweek some of the HUD settings here, like extra graphics and so on.

-- Set this to 1 for solid black, 2 for transparent.
local hudBarSet = 2

-- Enter 2 to alter the uncollected Dragon Coin graphic to white. Only has an effect if you're using a solid black HUD bar. 
local dragonAltStyle = 0
-- Enter 2 for more space between Dragon Coin graphics. Useful if you only have 3 Dragon Coins per level as opposed to 5.
local dragonExtra = 0

-- If your episode has stars, enter 1. Otherwise enter 2.
local starCounterSet = 1

-- If you're using the built-in SMBX timer, enter 1. Otherwise enter 2.
local timeCounterSet = 2
-- Enter 2 for an alternative style for the timer graphic. Useful if you're using a solid black bar.
local timeAltStyle = 1

-- Set this to 2 to enable the death counter, a feature that tracks deaths insead of your lives.
local livesAltStyle = 2

---------------------
-- End of settings --
---------------------

-- Initialise the death counter to 0 if it hasn't been already
SaveData.deathCount = SaveData.deathCount or 0

-- Graphics
local hudBarB = Graphics.loadImage(Misc.resolveFile("hudBarB.png"))
local hudBarT = Graphics.loadImage(Misc.resolveFile("hudBarT.png"))
local coinCounter = Graphics.loadImage(Misc.resolveFile("coinCounter.png"))
local lifeCounter = Graphics.loadImage(Misc.resolveFile("lifeCounter.png"))
local starCounter = Graphics.loadImage(Misc.resolveFile("starCounter.png"))
local deathCounter = Graphics.loadImage(Misc.resolveFile("deathCounter.png"))
local timeCounter = Graphics.loadImage(Misc.resolveFile("timeCounter.png"))
local timeCounterB = Graphics.loadImage(Misc.resolveFile("timeCounterB.png"))
local dragonCoinEmpty = Graphics.loadImage(Misc.resolveFile("dragonCoinEmpty.png"))
local dragonCoinEmptyB = Graphics.loadImage(Misc.resolveFile("dragonCoinEmptyB.png"))
local dragonCoinEmptyW = Graphics.loadImage(Misc.resolveFile("dragonCoinEmptyW.png"))
local dragonCoinCollect = Graphics.loadImage(Misc.resolveFile("dragonCoinCollect.png"))
local reserveBox = Graphics.loadImage(Misc.resolveFile("reserveBox.png"))

-- Item icon graphics
local reserveItem = {}

reserveItem[0] = Graphics.loadImageResolved("item1.png")

reserveItem[9] = Graphics.loadImageResolved("item2.png")
reserveItem[184] = reserveItem[9]
reserveItem[185] = reserveItem[9]
reserveItem[249] = reserveItem[9]

reserveItem[14] = Graphics.loadImageResolved("item3.png")
reserveItem[182] = reserveItem[14]
reserveItem[183] = reserveItem[14]

reserveItem[264] = Graphics.loadImageResolved("item7.png")
reserveItem[277] = reserveItem[264]

reserveItem[34] = Graphics.loadImageResolved("item4.png")
reserveItem[169] = Graphics.loadImageResolved("item5.png")
reserveItem[170] = Graphics.loadImageResolved("item6.png")

-- No idea what this does lmao
function minHUD.onInitAPI()
    registerEvent(minHUD, "onDraw", "onDraw")
    registerEvent(minHUD, "onExitLevel", "onExitLevel")
end

function minHUD.drawHUD(camIdx,priority,isSplit)
    -- All HUD rendering goes here

    -- Base HUD Bar
    if hudBarSet == 1 then
        Graphics.drawImageWP(hudBarB, 0, 0, priority)
    else
        Graphics.drawImageWP(hudBarT, 0, 0, priority)
    end

    -- Reserve Box
    Graphics.drawImageWP(reserveBox, 400 - reserveBox.width*0.5, 4, priority)

    local itemImage = reserveItem[player.reservePowerup] or reserveItem[0]

    if player.reservePowerup > 0 and itemImage ~= nil then
        Graphics.drawImageWP(itemImage, 392, 4, priority)
    end

    -- Coins
    Graphics.drawImageWP(coinCounter, 20, 4, priority)
    textplus.print{text = tostring(mem(0x00B2C5A8, FIELD_WORD)), font = minFont, priority = 5, x = 54, y = 4, xscale = 2, yscale = 2, color = Color.fromHexRGBA(0xFFFFFFFF)}

    -- Lives or Death Counter
    if livesAltStyle == 2 then
        Graphics.drawImageWP(deathCounter, 130, 4, priority)
        textplus.print{text = tostring(SaveData.deathCount), font = minFont, priority = 5, x = 164, y = 4, xscale = 2, yscale = 2} 
    else
        Graphics.drawImageWP(lifeCounter, 114, 4, priority)
        textplus.print{text = tostring(mem(0x00B2C5AC, FIELD_FLOAT)), font = minFont, priority = 5, x = 164, y = 4, xscale = 2, yscale = 2, color = Color.fromHexRGBA(0xFFFFFFFF)}
    end

    -- Stars
    if starCounterSet == 1 then
        Graphics.drawImageWP(starCounter, 450, 4, priority)
        textplus.print{text = tostring(mem(0x00B251E0, FIELD_WORD)), font = minFont, priority = 5, x = 484, y = 4, xscale = 2, yscale = 2, color = Color.fromHexRGBA(0xFFFFFFFF)}
    end

    -- Score
    textplus.print{text = tostring(SaveData._basegame.hud.score), font = minFont, priority = 5, x = 544, y = 4, xscale = 2, yscale = 2, color = Color.fromHexRGBA(0xFFFFFFFF)}

    -- Time [SMBX Built In]
    if timeCounterSet == 1 then
        if timeAltStyle == 2 then
            Graphics.drawImageWP(timeCounterB, 670, 4, priority)
        else
            Graphics.drawImageWP(timeCounter, 670, 4, priority)
        end
        textplus.print{text = tostring(Timer.getValue()), font = minFont, priority = 5, x = 702, y = 4, xscale = 2, yscale = 2, color = Color.fromHexRGBA(0xFFFFFFFF)}
    end    

    -- Reserve power-up rendering
    -- if player.reservePowerup > 0 then
    --     local image = Graphics.sprites.npc[player.reservePowerup].img
    --     local config = NPC.config[player.reservePowerup]
    
    --     local gfxwidth = config.gfxwidth
    --     local gfxheight = config.gfxheight
    
    --     if gfxwidth == 0 then
    --         gfxwidth = config.width
    --     end
    --     if gfxheight == 0 then
    --         gfxheight = config.height
    --     end
    
    --     Graphics.drawImageWP(image, 400 - gfxwidth*0.5, 16 + deeperReserveBox.height*0.5 - gfxheight*0.5, 0,0, gfxwidth,gfxheight, priority)
    -- end

    -- Dragon Coins tracking
    for index,value in ipairs(starcoin.getLevelList()) do
        if value == 0 then
            if hudBarSet == 1 then
                if dragonAltStyle == 2 then
                    if dragonExtra == 2 then
                        Graphics.drawImageWP(dragonCoinEmptyW, 204 + (index * 36), 4, priority)
                    else
                        Graphics.drawImageWP(dragonCoinEmptyW, 204 + (index * 18), 4, priority)
                    end
                else
                    if dragonExtra == 2 then
                    Graphics.drawImageWP(dragonCoinEmptyB, 204 + (index * 36), 4, priority)
                    else
                    Graphics.drawImageWP(dragonCoinEmptyB, 204 + (index * 18), 4, priority)
                    end
                end
            else
                if dragonExtra == 2 then
                    Graphics.drawImageWP(dragonCoinEmpty, 204 + (index * 36), 4, priority)
                else
                    Graphics.drawImageWP(dragonCoinEmpty, 204 + (index * 18), 4, priority)
                end
            end
        else
            if dragonExtra == 2 then
                Graphics.drawImageWP(dragonCoinCollect, 204 + (index * 36), 4, priority)
            else
                Graphics.drawImageWP(dragonCoinCollect, 204 + (index * 18), 4, priority)
            end
        end
    end
end

Graphics.overrideHUD(minHUD.drawHUD)

-- Track if the player is dying during a level exit
function minHUD.onExitLevel() 
    if not isOverworld and player:mem(0x13C,FIELD_BOOL) then
        SaveData.deathCount = SaveData.deathCount + 1
    end
end

return minHUD