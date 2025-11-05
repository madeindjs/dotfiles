local mp = require("mp")
local input = require("mp.input")

---@param args table
local function command_native(args)
	return mp.command_native({
		name = "subprocess",
		capture_stdout = true,
		capture_stderr = true,
		args = args,
	})
end

---@param path string
local function get_tracks_comment(path)
	local cmd = command_native({
		"metaflac",
		path,
		"--show-tag",
		"COMMENT",
	})

	if cmd.status ~= 0 then
		error("Cannot get comment " .. cmd.stderr, 1)
	end

	local comment = string.gsub(cmd.stdout, "COMMENT=", "")
	return string.gsub(comment, "\n", "")
end

---@param path string
---@param tag string
local function set_tracks_comment(path, tag)
	local comment = get_tracks_comment(path)

	if string.match(comment, tag) then
		comment = string.gsub(comment, " " .. tag, "")
		comment = string.gsub(comment, tag .. " ", "")
	else
		comment = comment .. " " .. tag
	end

	local cmd = command_native({
		"metaflac",
		path,
		"--remove-tag",
		"COMMENT",
		"--set-tag",
		"COMMENT=" .. comment,
	})

	if cmd.status ~= 0 then
		error("Cannot set comment " .. cmd.stderr, 1)
	end

	return comment
end

local function add_tag_handler()
	local format = mp.get_property("file-format")

	if format == "flac" then
		local path = mp.get_property("path")

		mp.msg.info("Enter the tag to add")
		input.get({
			prompt = "Enter a tag:",
			---@param tag string
			closed = function(tag)
				local comment = set_tracks_comment(path, "#" .. tag)
				mp.msg.info("Comment updated to:" .. comment)
			end,
		})
	else
		mp.msg.warn("the file is not a flac file")
	end
end

local has_metaflac = command_native({
	"which",
	"metaflac",
})
if has_metaflac.status ~= 0 then
	mp.msg.warn("metaflac not found")
end

mp.add_key_binding("a", "playlist-m3u", add_tag_handler)
