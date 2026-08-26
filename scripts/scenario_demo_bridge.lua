-- Name: Demo Bridge
-- Description: BLACKBRIDGE / Shatterdome demo — one player ship, no enemies. Consoles autoconnect by station name.
-- Type: Basic

require("utils.lua")

function init()
    playerShip = PlayerSpaceship()
        :setTemplate("Atlantis")
        :setFaction("Human Navy")
        :setPosition(0, 0)
        :setHeading(0)
        :setCallSign(_("Bridge"))
end

function update(delta)
end
