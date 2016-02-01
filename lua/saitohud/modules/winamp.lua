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
-- $Id$

require("WinAmp_Interface")

local foundWinamp = winamp.SetupWinAmp()

local updateNowPlaying = CreateClientConVar("winamp_now_playing", "0", true, false)
local nowPlayingField = CreateClientConVar("winamp_now_playing_field", "cl_xfire", true, false)
local updateData = CreateClientConVar("winamp_update_data", "0", true, false)
CreateClientConVar("winamp_data_title", "", false, true)
CreateClientConVar("winamp_data_pos_time_t", 0, false, true)
CreateClientConVar("winamp_data_total_time", "", false, true)
CreateClientConVar("winamp_data_total_time_t", 0, false, true)
CreateClientConVar("winamp_data_bitrate", "", false, true)
CreateClientConVar("winamp_data_sample_rate", "", false, true)

local lastUpdate = 0
local lastPos = -1
local lastPosUpdateTime = 0

local function UpdateField(field, text)
    if GetConVar(field):GetString() ~= text then
        RunConsoleCommand(field, text)
        return true
    end
    
    return false
end

local function Think()
    if CurTime() - lastUpdate < (foundWinamp and 1 or 10) then
        return
    end
    
    if not foundWinamp then
        foundWinamp = winamp.SetupWinAmp()
        if not foundWinamp then return end
    end
    
    local field = nowPlayingField:GetString()
    
    if winamp.CurrentPlayMode() == 1 then
        UpdateField(field, "Now Playing: " .. winamp.GetCurrentTrack())
        if updateData:GetBool() then
            UpdateField("winamp_data_title", winamp.GetCurrentTrack())
            if math.abs(winamp.GetSongPos() / 1000 - lastPos - (SysTime() - lastPosUpdateTime)) > 2 then
                UpdateField("winamp_data_pos_time_t", tostring(winamp.GetSongPos() / 1000))
                lastPos = winamp.GetSongPos() / 1000
                lastPosUpdateTime = SysTime()
            end
            UpdateField("winamp_data_total_time", tostring(winamp.GetSongLenS()))
            UpdateField("winamp_data_total_time_t", tostring(winamp.GetSongLen()))
            UpdateField("winamp_data_bitrate", tostring(winamp.GetBitrate()))
            UpdateField("winamp_data_sample_rate", tostring(winamp.GetSamplerate()))
        end
    else
        UpdateField(field, "")
        if updateData:GetBool() then
            UpdateField("winamp_data_title", "")
            UpdateField("winamp_data_total_time", "")
            UpdateField("winamp_data_bitrate", "")
            UpdateField("winamp_data_sample_rate", "")
        end
    end
    
    
    lastUpdate = CurTime()
end

local function Rehook()
    if updateNowPlaying:GetBool() then
        hook.Add("Think", "SaitoHUD.Winamp", Think)
    else
        SaitoHUD.RemoveHook("Think", "SaitoHUD.Winamp")
    end
end

cvars.AddChangeCallback("winamp_now_playing", Rehook)

if updateNowPlaying:GetBool() then
    hook.Add("Think", "SaitoHUD.Winamp", Think)
end