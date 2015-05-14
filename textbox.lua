local textbox = {}
textbox.__index = textbox

local function new()
	local t = {}
	t.textList = {}
	t.textPage = 1
	t.font = love.graphics.newFont()
	t.textSpeed = 0.01
	t.beatSpeed = 0.2
	t.timer = t.beatSpeed
	t.charIndex = 0
	t.textLines = 1
	t.textLinesMax = 3
	t.maxWidth = 240
	t.paddingX = 20
	t.paddingY = 20
	t.displayText = ''
	t.writing = false
	t.visible = false
	t.x = 0
	t.y = 0
	t.options = {}
	t.optionsIndex = 0
	t.optionsCallback = nil
	return setmetatable(t, textbox)
end

function textbox:getWidth()
	return self.maxWidth + 2*self.paddingX
end

function textbox:getHeight()
	return self.textLinesMax * self.font:getHeight() + self.paddingY*2
end

function textbox:setIcon(icon, right, bottom)
	self.icon = icon
	self.iconRight = right
	self.iconBottom = bottom
end

function textbox:setText(textList, options, callback)
	self.textList = textList
	self.textPage = 1
	self:read(textList[1])
	self.options = options or {}
	self.optionsIndex = 0
	self.optionsCallback = callback
end

function textbox:nextPage()
	if #self.textList > 0 then
		self.textPage = self.textPage + 1
		if self.textPage <= #self.textList then
			self:read(self.textList[self.textPage])
			self.writing = true
		else
			self.visible = false
		end
	else
		self.visible = false
	end
end

function textbox:read(text)
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
	self.timer = self.beatSpeed
	self.charIndex = 0
	self.textLines = 1
	self.visible = true
	self.writing = true
end

function textbox:skip(dt)
	if self.timer > 0 then
		self.timer = self.timer - dt
	elseif self.charIndex < self.text:len() then
		if self.textSound then
			self.textSound:play()
		end
		while self.timer <= 0 do
			self.charIndex = self.charIndex+1

			local remainder = self.text:sub(self.charIndex)
			local char = remainder:sub(0, 1)

			if char == '`' then
				self.timer = self.timer + self.beatSpeed
			else
				self.timer = self.timer + self.textSpeed
				self.displayText = self.displayText .. char
				if char == '\n' then
					self.textLines = self.textLines+1
					if self.textLines > self.textLinesMax then
						self.displayText = self.displayText:sub(self.displayText:find('\n')+1)
					end
				end
			end
		end
	elseif self.writing then
		self.writing = false
	end
end

function textbox:optionsActive()
	return not self.writing and #self.options > 0 and self.textPage == #self.textList
end

function textbox:update(dt)
	if not self.visible then return end
	if self.writing then
		self:skip(dt)
	end
	function love.keypressed(key)
		if not self.visible then return end
		if key == 'a' then
			if not self.writing then
				if self:optionsActive() then
					self.optionsCallback(self.options[self.optionsIndex+1])
				elseif #self.textList > 0 then
					self:nextPage()
				end
				if self.endSound then
					self.endSound:play()
				end
			else
				self:skip(self.beatSpeed*self.text:len())
			end
		elseif self:optionsActive() then
			if key == 'up' then
				self.optionsIndex = (self.optionsIndex-1) % #self.options
			elseif key == 'down' then
				self.optionsIndex = (self.optionsIndex+1) % #self.options
			end
		end
	end
end

function textbox:draw()
	if not self.visible then return end
	love.graphics.setColor(70, 70, 70)
	love.graphics.rectangle('fill', self.x, self.y, self:getWidth(), self:getHeight())
	love.graphics.setColor(255, 255, 255)

	local oldFont = love.graphics.getFont()
	love.graphics.setFont(self.font)
	love.graphics.print(self.displayText, self.x + self.paddingX, self.y + self.paddingY)
	love.graphics.setFont(oldFont)

	if self.icon and not self.writing and not self:optionsActive() then
		love.graphics.draw(self.icon, self.x + self:getWidth() - self.iconRight, self.y + self:getHeight() - self.iconBottom)
	end

	if self:optionsActive() then
		local option
		for i = 1, #self.options do
			option = self.options[i]
			love.graphics.print(option, self.x+self:getWidth()+64, self.y+i*16)
			if i == self.optionsIndex+1 then
				love.graphics.draw(self.icon, self.x+self:getWidth()+48, self.y+i*16+3)
			end
		end
	end
end


return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})