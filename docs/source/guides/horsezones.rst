Adding horse spawnpoints
========================

Horses spawn wherever there is a horse zone and horse zones can be added using the ::lua:obj:`HorseMod.HorseZones` module. To do so, a ::lua:obj:`HorseMod.HorseZone` object is defined by providing coordinates of a rectangular area via the coordinates of two corners of the rectangle, and a Z level. You can also chose between three different spawn chances with the parameter ::lua:obj:`HorseMod.HorseZones.name`, with the default being `horsesmall`.

.. note:: You need to add zones from a Lua file inside `media/lua/server`. since horse zones need to be loaded on both the client and the server and loaded when loading a save.

Example
-------
.. code::

    local HorseZones = require("HorseZones")

    table.insert(
        HorseZones.zones,
        {
            x1 = 5546,
            y1 = 6505,
            x2 = 5617,
            y2 = 6514,
            z = 0,
        }
    )

    table.insert(
        HorseZones.zones,
        {
            x1 = 5546,
            y1 = 6505,
            x2 = 5617,
            y2 = 6514,
            z = 0,
            name = "horselarge",
        }
    )
