local Textbox = {}
Textbox.__index = Textbox

local textList = {}
local textPage = 1
local textTimer = 0
local timer = 0
local charIndex = 0
local textLine = 1
local displayText = ''
local writing = false
local visible = false
local options = {}
local optionIndex = 0
local optionCallback = nil

local function new()
	local self = {}
	
	self.font = love.graphics.newFont()
	self.textSpeed = 0.01
	self.beatSpeed = 0.2
	self.textWidth, self.textHeight = 320, 2
	self.textPadding = {
		l = 12,
		r = 12,
		t = 12,
		b = 12
	}
	self.x, self.y = 0, 0
	self.patch = nil
	self.profile = nil
	self.textColor = {
		r = 0,
		g = 0,
		b = 0
	}
	return setmetatable(self, Textbox)
end

function Textbox:setPatch(patch)
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

function Textbox:setColor(r, g, b)
	self.textColor.r = r
	self.textColor.g = g
	self.textColor.b = b
end

function Textbox:getWidth()
	return self.textWidth + self.textPadding.l + self.textPadding.r
end

function Textbox:getHeight()
	return self.textHeight * self.font:getHeight() + self.textPadding.t + self.textPadding.b
end

function Textbox:setIcon(icon, right, bottom)
	self.icon = icon
	self.iconRight = right
	self.iconBottom = bottom
end

function Textbox:setText(list, opts, callback)
	textList = list
	textPage = 1
	self:read(textList[1])
	options = opts or {}
	optionIndex = 0
	optionCallback = callback
end

function Textbox:nextPage()
	if #textList > 0 then
		textPage = textPage + 1
		if textPage <= #textList then
			self:read(textList[textPage])
			writing = true
		else
			visible = false
		end
	else
		visible = false
	end
end

function Textbox:read(text)
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
	displayText = ''
	textTimer = self.beatSpeed
	charIndex = 0
	textLine = 1
	visible = true
	writing = true
end

function Textbox:skip(dt)
	if textTimer > 0 then
		textTimer = textTimer - dt
	elseif charIndex < self.text:len() then
		while textTimer <= 0 do
			charIndex = charIndex+1

			local remainder = self.text:sub(charIndex)
			local char = remainder:sub(0, 1)

			if char == '`' then
				textTimer = textTimer + self.beatSpeed
			else

				if self.textSound then
					self.textSound:play()
				end
				textTimer = textTimer + self.textSpeed
				displayText = displayText .. char
				if char == '\n' then
					textLine = textLine+1
					if textLine > self.textHeight then
						displayText = displayText:sub(displayText:find('\n')+1)
					end
				end
			end
		end
	elseif writing then
		writing = false
	end
end

function Textbox:optionsActive()
	return not writing and #options > 0 and textPage == #textList
end

function Textbox:update(dt)
	timer = (timer + dt*10) % (math.pi*2)
	if not visible then return end
	if writing then
		self:skip(dt)
	end
	function love.keypressed(key)
		if not visible then return end
		if key == ' ' then
			if not writing then
				if self:optionsActive() then
					optionCallback(options[optionIndex+1], optionIndex)
				elseif #textList > 0 then
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
				optionIndex = (optionIndex-1) % #options
				if self.scrollSound then
					self.scrollSound:play()
				end
			elseif key == 'down' then
				optionIndex = (optionIndex+1) % #options
				if self.scrollSound then
					self.scrollSound:play()
				end
			end
		end
	end
end

function Textbox:drawBox(x, y, w, h)
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

function Textbox:drawOptions(x, y)
	if not self:optionsActive() then return end
	local fontHeight = self.font:getHeight()
	self:drawBox(x, y, 84, #options * fontHeight + self.textPadding.t + self.textPadding.b)

	local oldFont = love.graphics.getFont()
	love.graphics.setColor(self.textColor.r, self.textColor.g, self.textColor.b)
	love.graphics.setFont(self.font)
	local option
	for i = 1, #options do
		option = options[i]
		if i == optionIndex+1 then
			love.graphics.setColor(146, 182, 182)
		else
			love.graphics.setColor(self.textColor.r, self.textColor.g, self.textColor.b)
		end
		love.graphics.print(option, x + self.textPadding.r, y + self.textPadding.t + (i-1)*fontHeight)
	end
	love.graphics.setFont(oldFont)
	love.graphics.setColor(255, 255, 255)

	if self.icon then
		-- love.graphics.draw(self.icon, x+6 + 2*math.sin(self.timer), y + self.paddingY + optionIndex*16+4)
	end
end

function Textbox:drawProfile()
	if not self.profile then return end

	love.graphics.draw(self.profile.avatar, self.x + self.textPadding.r, self.y + self.textPadding.t)
end

function Textbox:draw()
	if not visible then return end

	self:drawBox(self.x, self.y, self:getWidth(), self:getHeight())
	self:drawOptions(self.x + self:getWidth() + self.textPadding.l, self.y)
	self:drawProfile()
	
	local oldFont = love.graphics.getFont()
	love.graphics.setColor(self.textColor.r, self.textColor.g, self.textColor.b)
	love.graphics.setFont(self.font)
	love.graphics.print(displayText, self.x + self.textPadding.l, self.y + self.textPadding.t)
	love.graphics.setFont(oldFont)
	love.graphics.setColor(255, 255, 255)

	if self.icon and not writing and not self:optionsActive() then
		love.graphics.draw(self.icon, self.x + self:getWidth() - self.iconRight, self.y + self:getHeight() - self.iconBottom + 2*math.sin(timer))
	end
end

return setmetatable({}, { __call = function(_, ...) return new(...) end })
