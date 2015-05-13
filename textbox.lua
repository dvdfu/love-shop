local textbox = {}
textbox.__index = textbox

local function new()
	local t = {}
	t.texts = {}
	t.textPage = 1
	t.font = love.graphics.newFont()
	t.textSpeed = 0.01
	t.beatSpeed = 0.2
	t.timer = 0
	t.index = 0
	t.lines = 1
	t.displayText = ''
	t.maxWidth = 400
	t.maxLines = 3
	t.paddingX = 20
	t.paddingY = 20
	t.stopped = false
	t.visible = true
	t.x = 0
	t.y = 0
	return setmetatable(t, textbox)
end

function textbox:setPosition(x, y)
	self.x, self.y = x, y
end

function textbox:setTextSound(sound)
	self.textSound = sound
end

function textbox:setEndSound(sound)
	self.endSound = sound
end

function textbox:setFont(font)
	self.font = font
end

function textbox:setTexts(texts)
	self.texts = texts
	self.textPage = 1
	self:setText(texts[1])
end

function textbox:nextPage()
	if #self.texts > 0 then
		self.textPage = self.textPage + 1
		if self.textPage <= #self.texts then
			self:setText(self.texts[self.textPage])
			self.stopped = false
			self.timer = self.beatSpeed
		else
			self.visible = false
		end
	else
		self.visible = false
	end
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
		
		if char == ' ' or char == '-' or i == #text then
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
	self.stopped = false
end

function textbox:skip(dt)
	if self.timer > 0 then
		self.timer = self.timer - dt
	elseif self.index < self.text:len() then
		if self.textSound then
			self.textSound:play()
		end
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
	elseif not self.stopped then
		self.stopped = true
	end
end

function textbox:update(dt)
	if not self.visible then return end
	self:skip(dt)
	function love.keypressed(key, isrepeat)
		if not self.visible then return end
		if key == 'a' then
			self:skip(self.beatSpeed*self.text:len())
			if self.stopped then
				if self.endSound then
					self.endSound:play()
				end
				self:nextPage()
			end
		end
	end
end

function textbox:draw()
	if not self.visible then return end
	love.graphics.setColor(70, 70, 70)
	love.graphics.rectangle('fill', self.x, self.y, self.maxWidth + self.paddingX*2, self.maxLines * self.font:getHeight() + self.paddingY*2)
	love.graphics.setColor(255, 255, 255)

	local oldFont = love.graphics.getFont()
	love.graphics.setFont(self.font)
	love.graphics.print(self.displayText, self.x+self.paddingX, self.y+self.paddingY)
	love.graphics.setFont(oldFont)
end


return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})