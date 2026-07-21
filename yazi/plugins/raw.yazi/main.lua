-- Preview camera RAW files (CR2, etc.) by extracting their embedded JPEG
-- with exiftool, then handing it to yazi's built-in image pipeline.
-- yazi's `image` crate can't decode RAW, but it can decode the extracted JPEG.

local M = {}

-- Tags to try, in order of preference: full-size preview, then smaller fallbacks.
local TAGS = { "-PreviewImage", "-JpgFromRaw", "-ThumbnailImage" }

function M:peek(job)
	local start, cache = os.clock(), ya.file_cache(job)
	if not cache then
		return
	end

	-- Make sure the embedded JPEG has been extracted and cached.
	if not fs.cha(cache) then
		if not self:preload(job) then
			return ya.preview_widget(job, "No embedded preview found in this RAW file")
		end
	end

	ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

	local _, err = ya.image_show(cache, job.area)
	ya.preview_widget(job, err)
end

function M:seek() end

function M:preload(job)
	local cache = ya.file_cache(job)
	if not cache or fs.cha(cache) then
		return true
	end

	-- exiftool writes the embedded JPEG to stdout; stash it in a temp file
	-- alongside the cache entry so image_precache can downscale it.
	local src = Url(tostring(cache) .. ".rawjpg")

	local extracted = false
	for _, tag in ipairs(TAGS) do
		local output = Command("exiftool")
			:arg({ "-b", tag, tostring(job.file.url) })
			:stdout(Command.PIPED)
			:stderr(Command.NULL)
			:output()

		if output and output.status.success and #output.stdout > 0 then
			if fs.write(src, output.stdout) then
				extracted = true
				break
			end
		end
	end

	if not extracted then
		return false
	end

	local ok = ya.image_precache(src, cache)
	fs.remove("file", src)
	return ok
end

return M
