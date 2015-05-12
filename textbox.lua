local textbox = {}
textbox.__index = textbox

local function new()
	local t = {}
	t.font = love.graphics.newFont('data/Minecraftia-Regular.ttf', 16)
	-- t.font = love.graphics.newFont(12)
	t.textSpeed = 0.008
	t.beatSpeed = 0.2
	t.timer = 0
	t.index = 0
	t.lines = 1
	t.displayText = ''
	t.callback = nil
	t.maxWidth = 400
	t.maxLines = 3
	t.marginX = 20
	t.marginY = 20
	t.sound = love.audio.newSource('aud/blip.wav')
	return setmetatable(t, textbox)
end

function textbox:setCallback(callback)
	self.callback = callback
end

function textbox:setText(text)
	local formatted = ''
	local lineWidth = 0
	local word = ''
	local char = ''

	for i = 1, #text do
		char = text:sub(i,i)

		local charWidth = self.font:getWidth(char)
		local wordWidth = self.font:getWidth(word)

		if wordWidth + charWidth > self.maxWidth then
			formatted = formatted .. word .. '\n'
			lineWidth = 0
			word = ''
		end

		word = word .. char
		wordWidth = self.font:getWidth(word)
		
		if char == ' ' or i == #text then
			if lineWidth + wordWidth > self.maxWidth then
				formatted = formatted .. '\n'
				lineWidth = 0
			end
			formatted = formatted .. word
			lineWidth = lineWidth + wordWidth
			word = ''
		end
	end

	self.text = formatted;
	self.displayText = ''
	self.timer = 0
	self.index = 0
	self.lines = 1
end

function textbox:skip(dt)
	if self.timer > 0 then
		self.timer = self.timer - dt
	elseif self.index < self.text:len() then
		self.sound:play()
		while self.timer <= 0 do
			self.index = self.index+1

			local remainder = self.text:sub(self.index)
			local char = remainder:sub(0, 1)

			if char == '`' then
				self.timer = self.timer + self.beatSpeed
			else
				self.timer = self.timer + self.textSpeed
				self.displayText = self.displayText .. char
				if char == '\n' then
					self.lines = self.lines+1
					if self.lines > self.maxLines then
						self.displayText = self.displayText:sub(self.displayText:find('\n')+1)
					end
				end
			end
		end
	else
		if self.index == self.text:len() then
			self.callback()
		end
	end
end

function textbox:update(dt)
	self:skip(dt)
end

function textbox:draw()
	love.graphics.setColor(100, 100, 100)
	love.graphics.rectangle('fill', 100 - self.marginX, 100 - self.marginY, self.maxWidth + self.marginX*2, self.maxLines * self.font:getHeight() + self.marginY*2)
	love.graphics.setColor(255, 255, 255)

	local oldFont = love.graphics.getFont()
	love.graphics.setFont(self.font)
	love.graphics.print(self.displayText, 100, 100)
	love.graphics.setFont(oldFont)
end


return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})