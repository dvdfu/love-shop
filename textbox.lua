local textbox = {}
textbox.__index = textbox

local function new()
	local tb = {}
	tb.textList = {}
	tb.textPage = 1
	tb.timer = 0
	tb.charIndex = 0
	tb.textLine = 1
	tb.displayText = ''
	tb.writing = false
	tb.visible = false
	tb.options = {}
	tb.optionIndex = 0
	tb.optionCallback = nil
	
	tb.font = love.graphics.newFont()
	tb.textSpeed = 0.01
	tb.beatSpeed = 0.2
	tb.textWidth, tb.textHeight = 320, 2
	tb.paddingX, tb.paddingY = 0, 0
	tb.x, tb.y = 0, 0
	tb.patch = nil
	tb.profile = nil
	return setmetatable(tb, textbox)
end

function textbox:setPatch(patch)
	self.patch = patch
	local pw, ph = patch:getWidth(), patch:getHeight()
	self.patchTL = love.graphics.newQuad(0, 0, pw/3, ph/3, patch:getDimensions())
	self.patchML = love.graphics.newQuad(0, pw/3, pw/3, ph/3, patch:getDimensions())
	self.patchBL = love.graphics.newQuad(0, pw*2/3, pw/3, ph/3, patch:getDimensions())

	self.patchTC = love.graphics.newQuad(pw/3, 0, pw/3, ph/3, patch:getDimensions())
	self.patchMC = love.graphics.newQuad(pw/3, pw/3, pw/3, ph/3, patch:getDimensions())
	self.patchBC = love.graphics.newQuad(pw/3, pw*2/3, pw/3, ph/3, patch:getDimensions())

	self.patchTR = love.graphics.newQuad(pw*2/3, 0, pw/3, ph/3, patch:getDimensions())
	self.patchMR = love.graphics.newQuad(pw*2/3, pw/3, pw/3, ph/3, patch:getDimensions())
	self.patchBR = love.graphics.newQuad(pw*2/3, pw*2/3, pw/3, ph/3, patch:getDimensions())
	self.patchW, self.patchH = pw/3, ph/3
end

function textbox:getWidth()
	return self.textWidth + 2*self.paddingX
end

function textbox:getHeight()
	return self.textHeight * self.font:getHeight() + self.paddingY*2
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
	self.optionIndex = 0
	self.optionCallback = callback
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

		if wordWidth + charWidth > self.textWidth then
			formatted = formatted .. word .. '\n'
			lineWidth = 0
			word = ''
		end

		word = word .. char
		wordWidth = self.font:getWidth(word)
		
		if char == ' ' or char == '-' or i == #text then
			if lineWidth + wordWidth > self.textWidth then
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
	self.textLine = 1
	self.visible = true
	self.writing = true
end

function textbox:skip(dt)
	if self.timer > 0 then
		self.timer = self.timer - dt
	elseif self.charIndex < self.text:len() then
		while self.timer <= 0 do
			self.charIndex = self.charIndex+1

			local remainder = self.text:sub(self.charIndex)
			local char = remainder:sub(0, 1)

			if char == '`' then
				self.timer = self.timer + self.beatSpeed
			else

				if self.textSound then
					self.textSound:play()
				end
				self.timer = self.timer + self.textSpeed
				self.displayText = self.displayText .. char
				if char == '\n' then
					self.textLine = self.textLine+1
					if self.textLine > self.textHeight then
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
		if key == ' ' then
			if not self.writing then
				if self:optionsActive() then
					self.optionCallback(self.options[self.optionIndex+1], self.optionIndex)
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
				self.optionIndex = (self.optionIndex-1) % #self.options
				if self.scrollSound then
					self.scrollSound:play()
				end
			elseif key == 'down' then
				self.optionIndex = (self.optionIndex+1) % #self.options
				if self.scrollSound then
					self.scrollSound:play()
				end
			end
		end
	end
end

function textbox:drawBox(x, y, w, h)
	if not self.patch then return end
	local sx = (w - 2*self.patchW) / self.patchW
	local sy = (h - 2*self.patchH) / self.patchH

	love.graphics.draw(self.patch, self.patchTL, x, y)
	love.graphics.draw(self.patch, self.patchML, x, y + self.patchH, 0, 1, sy)
	love.graphics.draw(self.patch, self.patchBL, x, y + h - self.patchH)

	love.graphics.draw(self.patch, self.patchTC, x + self.patchW, y, 0, sx, 1)
	love.graphics.draw(self.patch, self.patchMC, x + self.patchW, y + self.patchH, 0, sx, sy)
	love.graphics.draw(self.patch, self.patchBC, x + self.patchW, y + h - self.patchH, 0, sx, 1)
	
	love.graphics.draw(self.patch, self.patchTR, x + w - self.patchW, y)
	love.graphics.draw(self.patch, self.patchMR, x + w - self.patchW, y + self.patchH, 0, 1, sy)
	love.graphics.draw(self.patch, self.patchBR, x + w - self.patchW, y + h - self.patchH)
end

function textbox:drawOptions(x, y)
	if not self:optionsActive() then return end
	self:drawBox(x, y, 84, #self.options*16 + 2*self.paddingY)

	local oldFont = love.graphics.getFont()
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(self.font)
	local option
	for i = 1, #self.options do
		option = self.options[i]
		if i == self.optionIndex+1 then
			love.graphics.setColor(146, 182, 182)
			love.graphics.print(option, x + self.paddingX, y + self.paddingY + (i-1)*16)
			love.graphics.setColor(0, 0, 0)
		else
			love.graphics.print(option, x + self.paddingX, y + self.paddingY + (i-1)*16)
		end
	end
	love.graphics.setFont(oldFont)
	love.graphics.setColor(255, 255, 255)

	if self.icon then
		-- love.graphics.draw(self.icon, x+6, y + self.paddingY + self.optionIndex*16+4)
	end
end

function textbox:draw()
	if not self.visible then return end

	self:drawBox(self.x, self.y, self:getWidth(), self:getHeight())
	self:drawOptions(self.x + self:getWidth() + self.paddingX, self.y)
	
	local oldFont = love.graphics.getFont()
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(self.font)
	love.graphics.print(self.displayText, self.x + self.paddingX, self.y + self.paddingY)
	love.graphics.setFont(oldFont)
	love.graphics.setColor(255, 255, 255)

	if self.icon and not self.writing and not self:optionsActive() then
		love.graphics.draw(self.icon, self.x + self:getWidth() - self.iconRight, self.y + self:getHeight() - self.iconBottom)
	end
end


return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})