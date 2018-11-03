MediaPlayer = {}


function MediaPlayer.new(x, y, w, h)
	local self = inherit(Component.new('video', x, y, w, h), MediaPlayer)
	self.mediaType = 'youtube'
	self.browser = nil

	return self
end

local function parseYoutubeId(url)
	local matching = {'v=(.+)', 'tu.be/(.+)', '/v/(.+)'}
	for i=1, #matching do
		local id = url:match(matching[i])
		if id then
			return id:sub(0, 11)
		end
	end
	return false
end

function MediaPlayer:play(path, mediaType)
	check('s', {path})

	mediaType = mediaType and mediaType:lower() or self.mediaType

	local f

	if mediaType == 'youtube' then
		local id = parseYoutubeId(path)
		assert(id, 'invalid YouTube URL!')
		f = function()
			self.browser:loadURL('https://www.youtube.com/tv#/watch?v=' .. id)
		end
	end

	if f then
		self:stop()
		
		self.browser = Browser(0, 0, self.w, self.h)
			:setParent(self)
			:once('created', f)
			:once('documentReady', function()
				print('Now playing ' .. self:getTitle())
			end)
	end

	return self
end

function MediaPlayer:getTitle()
	return self.browser.browser.title
end

function MediaPlayer:stop()
	if isComponent(self.browser) then
		self.browser:destroy()
		self.browser = nil
	end
end

function MediaPlayer:draw()
	if not self.browser then
		dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(0,0,0))
	end
end

setmetatable(MediaPlayer, {__call = function(_, ...) return MediaPlayer.new(...) end})