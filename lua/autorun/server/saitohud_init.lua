-- SaitoHUD
-- Copyright (c) 2016 Hexahedronic <http://www.hexahedronic.org>
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
-- $Id: saitohud_init.lua GIT 2016-05-01 hexahedronic $

print("Loading serverside SaitoHUD adder...")

local function addDir(dir)
	local files, folders = file.Find("saitohud/" .. dir .. "*.lua", "LUA")
	for _, file in pairs(files) do
		local path = "saitohud/" .. dir .. file

		print("Adding " .. path .. ".")
		AddCSLuaFile(path)
	end
end

addDir("")
addDir("vgui/")
addDir("modules/")
