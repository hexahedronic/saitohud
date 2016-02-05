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
-- $Id: umsg.lua GIT 2016-05-01 hexahedronic $

local doDebug = CreateClientConVar("umsg_debug", "0", true, false)
local peekWire = CreateClientConVar("umsg_debug_peek_wire", "0", true, false)
local peekTitan = CreateClientConVar("umsg_debug_peek_titan", "1", true, false)

local messages = {}
local snapshot = {}
local snapshotKeys = {}
local lastSnapshot = 0
local initial = false
local timeDiff = 0

if not _OldUserMessageIncoming then
	_OldUserMessageIncoming = usermessage.IncomingMessage
end

local function GetLocalVar(func, key)
	local k = 1
	while true do
		local name, value = debug.getupvalue(func, k)
		if not name then break end
		if name == key then return value end
		k = k + 1
	end
	return nil
end

local function StartListening()
	-- Name upvalue the same so that we don't break other people's attempts
	local Hooks = GetLocalVar(_OldUserMessageIncoming, "Hooks")

	if Hooks then
		local function DoLog(name, msg)
			local logName = name
			local fakeMsg

			if peekWire:GetBool() and name == "wire_umsg" then
				local entIndex = msg:ReadShort()
				local ent = ents.GetByIndex(entIndex)
				logName = name .. ":" .. (ValidEntity(ent) and tostring(ent) or "?")

				-- Does not appear to work!
				msg:Reset()
			elseif peekTitan:GetBool() and name == "x" then -- Titan
				local payload = msg:ReadString()
				local success, decodedData = pcall(glon.decode, payload)

				fakeMsg = {}
				fakeMsg.ReadString = function() return payload end

				if success then
					local entIndex = decodedData[1]
					local ent = Entity(entIndex)
					local value = decodedData[3]
					local key = decodedData[2]

					logName = name .. ":" .. (ValidEntity(ent) and tostring(ent) or "?") .. ":" .. key
				end
			end

			messages[logName] = messages[logName] and messages[logName] + 1 or 1

			if fakeMsg then return fakeMsg end
		end

		usermessage.IncomingMessage = function(messageName, msg)
			local success, fakeMsg = pcall(DoLog, messageName, msg)
			if success and fakeMsg then msg = fakeMsg end
			_OldUserMessageIncoming(messageName, msg)
		end

		return true
	end

	return false
end

local function StopListening()
	usermessage.IncomingMessage = _OldUserMessageIncoming
end

local function HUDPaint()
	if RealTime() - lastSnapshot > 2 then
		timeDiff = math.Round(RealTime() - lastSnapshot)
		snapshot = messages
		snapshotKeys = {}
		for key, _ in pairs(snapshot) do table.insert(snapshotKeys, key) end
		table.sort(snapshotKeys, function(a, b) return a < b end)
		messages = {}
		lastSnapshot = RealTime()
		initial = false
	end

	if (#snapshotKeys > 0 or not initial) and not initial then
		local i = 0
		for _, name in pairs(snapshotKeys) do
			local num = snapshot[name]
			local x, y = 20, 160 + 16 * i

			surface.SetDrawColor(255, 0, 0, 200)
			surface.DrawRect(x + 100, y, num, 14)
			surface.SetTextColor(255, 255, 255, 255)
			surface.SetFont("Default")

			surface.SetTextPos(x, y)
			surface.DrawText(tostring(num))
			surface.SetTextPos(x + 30, y)
			surface.DrawText(string.format("%.2f/sec", num / timeDiff))
			surface.SetTextPos(x + 100, y)
			surface.DrawText(name)

			i = i + 1
		end
	else
		local x, y = 20, 160
		local txt = string.format("Collecting initial data [%.2f]...", 2 - (RealTime() - lastSnapshot))

		surface.SetFont("Default")

		surface.SetTextPos(x, y)
		surface.DrawText(txt)
	end
end

local function Rehook()
	if doDebug:GetBool() then
		if StartListening() then
			initial = true
			lastSnapshot = RealTime()
			hook.Add("HUDPaint", "SaitoHUD.Debug.UserMessage", HUDPaint)
		else
			Error("Failed to find Hooks upvalue")
		end
	else
		StopListening()
		hook.Remove("HUDPaint", "SaitoHUD.Debug.UserMessage")
	end
end

cvars.AddChangeCallback("umsg_debug", Rehook)

Rehook()