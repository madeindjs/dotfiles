-- vinyl-spin.lua
-- Displays cover art as a spinning vinyl circle for audio files

local msg = require('mp.msg')

-- 33.33 RPM → 2π × (33.33/60) ≈ 3.4907 rad/s
local RPM        = 5
local RAD_PER_SEC = 2 * math.pi * (RPM / 60)

local SHADER_PATH = "~~/shaders/vinyl-circle.glsl"

local vinyl_active = false
local spin_timer   = nil

local function is_albumart()
    local count = mp.get_property_number("track-list/count") or 0
    for i = 0, count - 1 do
        local t   = mp.get_property(string.format("track-list/%d/type", i))
        local art = mp.get_property(string.format("track-list/%d/albumart", i))
        if t == "video" and art == "yes" then return true end
    end
    return false
end

-- Push the current rotation angle to the shader every frame.
-- We derive it from time-pos (audio clock) so it naturally
-- pauses/resumes with playback and stays in sync after seeks.
local function tick()
    local t = mp.get_property_number("time-pos") or 0
    local a = (t * RAD_PER_SEC) % (2 * math.pi)
    mp.set_property("glsl-shader-opts", string.format("angle=%.6f", a))
end

local function enable_vinyl()
    msg.info("Cover art detected – enabling vinyl spin effect")
    mp.set_property_native("glsl-shaders", { SHADER_PATH })
    -- 60 Hz is plenty; the VO re-renders at display refresh rate anyway
    spin_timer = mp.add_periodic_timer(1 / 60, tick)
    vinyl_active = true
end

local function disable_vinyl()
    if not vinyl_active then return end
    msg.info("Removing vinyl spin effect")
    if spin_timer then spin_timer:kill(); spin_timer = nil end
    mp.set_property("glsl-shader-opts", "")
    mp.set_property_native("glsl-shaders", {})
    vinyl_active = false
end

mp.register_event("file-loaded", function()
    if is_albumart() then enable_vinyl() end
end)

mp.register_event("end-file", disable_vinyl)
