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
-- $Id: saitohud_error.lua GIT 2016-02-01 hexahedronic $

local errors = {}

local function errorCallback(err)
	if errors[err] == true then return end

	ErrorNoHalt("[ERROR] SaitoHUD Encountered the following error at RunTime:\n")
		print("\t" .. err)

	ErrorNoHalt("\nPlease do the following:\n")
		print("\t- Remain calm, don't go spamming the devs with 'HELP ERROR IT NO WORK'.")
		print("\t- Visit the issue tracker. (https://github.com/hexahedronic/saitohud/issues)")
		print("\t- Check if this error, or your issue has ALLREADY BEEN REPORTED, if it has...")
		print("\t\t- Check your version of SaitoHUD is up-to-date.")
		print("\t\t- If it is, try your best to resolve the issue yourself then wait for a proper fix.")
		print("\t- If it has not been reported...")
		print("\t\t- Create a new issue with the information in the error dump below.")

	ErrorNoHalt("\nError Dump:\n")
	print("--COMMENCE ERROR INFORMATION DUMP--")

	print("\n--[[GM-VERSION: ".. VERSION .. "]]")
	print("--[[OS: " .. jit.os .. ", ARCH: " .. jit.arch .. "]]\n")

	print(err)

	if SaitoHUD and SaitoHUD.AntiUnfairTriggered then
		print("\n--[[AUT: " .. tostring(SaitoHUD.AntiUnfairTriggered()) .. "]]")
	end

	print("\n--END ERROR INFORMATION DUMP--")

	errors[err] = true
end

function saitohud_errorhandle(func, ...)
	-- Can't pass varargs through apparently
	local args = {...}
	local f = function() func(unpack(args)) end

	local details = {xpcall(f, errorCallback)}
	local passed 	= details[1]

	table.remove(details, 1)

	if passed then
		-- Maybe cache the datatypes/values to return fake
		-- values if an error occurs?
	end

	return unpack(details)
end
