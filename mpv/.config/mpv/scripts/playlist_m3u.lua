local mp = require("mp")
local input = require("mp.input")

local function add_tag(msg)
	local path = mp.get_property("path")

	local res = mp.command_native({
		name = "subprocess",
		capture_stdout = true,
		capture_stderr = true,
		args = { "music-playlist-add", path, msg },
	})

	if res.status == 0 then
		mp.msg.info("added tag " .. msg)
	else
		mp.msg.warn(res.stderr)
	end
end

local function add_tag_handler()
	local format = mp.get_property("file-format")
	print(format)
	if format == "flac" then
		mp.msg.info("Enter the tag to add")
		input.get({
			prompt = "Enter a tag:",
			closed = add_tag,
		})
	else
		mp.msg.warn("the file is not a flac file")
	end
end

mp.add_key_binding("a", "playlist-m3u", add_tag_handler)
