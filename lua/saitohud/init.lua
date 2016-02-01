-- SaitoHUD
-- Copyright (c) 2009-2010 sk89q <http://www.sk89q.com>
-- Copyright (c) 2010 BoJaN
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
-- $Id: init.lua GIT 2016-02-01 20:52:22Z hexahedronic $

local moduleLoadList = {
	"util",
	"listgest",
	"geom",
	"overlays",
	"player_tags",
	"sampling",
	"stranded",
	"sandbox",
	"survey",
	"measure",
	"resbrowser",
	"spectate",
	"e2_extensions",
	"entity_info",
	"umsg",
	--"calculator", -- Disabled for now due to major issues.
	"hook_manager",
	"panel",
}

------------------------------------------------------------
-- Functions / build module list
------------------------------------------------------------

local postModules = CreateClientConVar("saitohud_modules", "", true, false):GetString()
local preModules = CreateClientConVar("saitohud_modules_pre", "", true, false):GetString()
local profile = CreateClientConVar("saitohud_profile", "0", true, false):GetBool()

--- Load a module.
local function Load(module)
	path = "saitohud/modules/" .. module .. ".lua"
	if profile then
		MsgN("Loading: " .. path .. "...")
	end
	local start = SysTime()
	pcall(include, path)

	-- Profiling
	if profile then
		local t = SysTime() - start
		print(string.format(" >>> %.3fms", t * 1000))
	end
end

--- Remove existing SaitoHUD hooks.
local function RemoveExistingHooks()
	for name, list in pairs(hook.GetTable()) do
		for k, f in pairs(list) do
			if k:match("^SaitoHUD") then
				list[k] = nil
			end
		end
	end
end

-- Modules loaded at the beginning
for _, v in pairs(string.Explode(",", preModules)) do
	v = v:Trim()
	if v ~= "" then table.insert(moduleLoadList, 1, v) end
end

-- Modules loaded at the end
for _, v in pairs(string.Explode(",", postModules)) do
	v = v:Trim()
	if v ~= "" then table.insert(moduleLoadList, v) end
end

------------------------------------------------------------
-- Load
------------------------------------------------------------

-- Reloading check
local reloading = false
if SaitoHUD ~= nil then reloading = true end

if reloading then
	RemoveExistingHooks()
end

SaitoHUD = {}
SaitoHUD.Reloading = reloading

include("saitohud/saitohud.lua")
include("saitohud/functions.lua")
include("saitohud/concmd.lua")
include("saitohud/filters.lua")
include("saitohud/friends.lua")
include("saitohud/geom.lua")
include("saitohud/overlays.lua")
include("saitohud/vgui/DCustomListView.lua")
include("saitohud/vgui/DListView_CheckboxLine.lua")

Msg("====== Loading SaitoHUD ======\n")

local start = SysTime()

for _, v in pairs(moduleLoadList) do
	Load(v)
end

if profile then
	local t = SysTime() - start
	print(string.format("TOTAL: %.3fms", t * 1000))
end

Msg("==============================\n")
