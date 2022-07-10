Player.setCostume(CHARACTER_MARIO,"SMW-Mario",true)
Player.setCostume(CHARACTER_LUIGI,"SMW-Luigi",true)
Player.setCostume(CHARACTER_TOAD,"SMW-Toad",true)
local minHUD = require("minHUD")
function onTick()
    mem(0x00B2C5AC, FIELD_FLOAT, 99)
end