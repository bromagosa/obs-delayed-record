--[[
    OBS-DELAYED-RECORD
    v1.0
    A script for Open Broadcaster Software that starts recording after a user
    specified delay.

    Copyright (C) 2020 Bernat Romagosa i Carrasquer and MunFilms
    bernat@romagosa.work
    info@munfilms.com

    https://github.com/bromagosa/obs-record-delay

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]--

local obs = obslua
local hotkey_id = obs.OBS_INVALID_HOTKEY_ID
local delay = 0
local remaining = 0
local active = false

--
-- OBS Script Overrides
--

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_int(
        props, 'delay', 'Delay: (ms)', 1000, 100000, 100)

    obs.obs_properties_add_button(props, 'button', 'Start timer', trigger)
    return props
end

function script_description()
    return 'Start recording after a delay.\n\n' ..
            'By Bernat Romagosa & Mun Films 2020'
end

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, 'source')
    delay = obs.obs_data_get_int(settings, 'delay')
end

function script_save(settings)
    local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
    obs.obs_data_set_array(settings, 'trigger_hotkey', hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
end

function script_load(settings)
    hotkey_id = obs.obs_hotkey_register_frontend(
        'trigger_record_delay', 'Delayed Recording', trigger)
    local hotkey_save_array = obs.obs_data_get_array(settings, 'trigger_hotkey')
    obs.obs_hotkey_load(hotkey_id, hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
end

function script_tick(seconds)
    if (active) then
        remaining = remaining - (seconds * 1000)
        if (remaining <= 0) then
            active = false
            remaining = delay
            obs.obs_frontend_recording_start()
        end
    end
end

--
-- Delayed Record Code
--

function trigger(pressed)
    if not pressed then return end
    remaining = delay
    active = true
end
