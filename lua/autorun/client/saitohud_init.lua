-- SaitoHUD
-- Copyright (c) 2009 sk89q <http://www.sk89q.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- $Id: saitohud_init.lua GIT 2016-02-01 22:07:11Z hexahedronic $

-- Incase of manual loading
include("autorun/saitohud_error.lua")

-- Debugging function
concommand.Add("saitohud_reload", function()
	LocalPlayer():PrintMessage(HUD_PRINTTALK, "Reloading SaitoHUD...")
	include("saitohud/init.lua")
end)

include("saitohud/init.lua")
