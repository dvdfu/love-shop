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

function Textbox.new()
	local self = {}
	setmetatable(self, Textbox)
	
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

	return self
end

--set and format incoming text
local function read(tb, text)
	local formatted = ''
	local lineWidth = 0
	local word = ''
	local char = ''

	for i = 1, #text do
		char = text:sub(i,i)

		local charWidth = tb.font:getWidth(char)
		local wordWidth = tb.font:getWidth(word)

		if wordWidth + charWidth > tb.textWidth then
			formatted = formatted .. word .. '\n'
			lineWidth = 0
			word = ''
		end

		word = word .. char
		wordWidth = tb.font:getWidth(word)
		
		if char == ' ' or char == '-' or i == #text then
			if lineWidth + wordWidth > tb.textWidth then
				formatted = formatted .. '\n'
				lineWidth = 0
			end
			formatted = formatted .. word
			lineWidth = lineWidth + wordWidth
			word = ''
		end
	end

	tb.text = formatted;
	displayText = ''
	textTimer = tb.beatSpeed
	charIndex = 0
	textLine = 1
	visible = true
	writing = true
end

--advance text page after hitting spacebar
local function nextPage(tb)
	if #textList > 0 then
		textPage = textPage + 1
		if textPage <= #textList then
			read(tb, textList[textPage])
			writing = true
		else
			visible = false
		end
	else
		visible = false
	end
end

--scroll through text characters (use deltatime by default)
local function skip(tb, dt)
	if textTimer > 0 then
		textTimer = textTimer - dt
	elseif charIndex < tb.text:len() then
		while textTimer <= 0 do
			charIndex = charIndex+1

			local remainder = tb.text:sub(charIndex)
			local char = remainder:sub(0, 1)

			if char == '`' then
				textTimer = textTimer + tb.beatSpeed
			else

				if tb.textSound then
					tb.textSound:play()
				end
				textTimer = textTimer + tb.textSpeed
				displayText = displayText .. char
				if char == '\n' then
					textLine = textLine+1
					if textLine > tb.textHeight then
						displayText = displayText:sub(displayText:find('\n')+1)
					end
				end
			end
		end
	elseif writing then
		writing = false
	end
end

--render main bordered box
local function drawBox(tb, x, y, w, h)
	if not tb.patch then return end
	local sx = (w - 2*tb.patchW) / tb.patchW
	local sy = (h - 2*tb.patchH) / tb.patchH

	love.graphics.draw(tb.patch, tb.patchTL, x, y)
	love.graphics.draw(tb.patch, tb.patchML, x, y + tb.patchH, 0, 1, sy)
	love.graphics.draw(tb.patch, tb.patchBL, x, y + h - tb.patchH)

	love.graphics.draw(tb.patch, tb.patchTC, x + tb.patchW, y, 0, sx, 1)
	love.graphics.draw(tb.patch, tb.patchMC, x + tb.patchW, y + tb.patchH, 0, sx, sy)
	love.graphics.draw(tb.patch, tb.patchBC, x + tb.patchW, y + h - tb.patchH, 0, sx, 1)
	
	love.graphics.draw(tb.patch, tb.patchTR, x + w - tb.patchW, y)
	love.graphics.draw(tb.patch, tb.patchMR, x + w - tb.patchW, y + tb.patchH, 0, 1, sy)
	love.graphics.draw(tb.patch, tb.patchBR, x + w - tb.patchW, y + h - tb.patchH)
end

--render questions when options are displayed
local function drawOptions(tb, x, y)
	if not tb:optionsActive() then return end
	local fontHeight = tb.font:getHeight()
	drawBox(tb, x, y, 84, #options * fontHeight + tb.textPadding.t + tb.textPadding.b)

	local oldFont = love.graphics.getFont()
	love.graphics.setColor(tb.textColor.r, tb.textColor.g, tb.textColor.b)
	love.graphics.setFont(tb.font)
	local option
	for i = 1, #options do
		option = options[i]
		if i == optionIndex+1 then
			love.graphics.setColor(146, 182, 182)
		else
			love.graphics.setColor(tb.textColor.r, tb.textColor.g, tb.textColor.b)
		end
		love.graphics.print(option, x + tb.textPadding.r, y + tb.textPadding.t + (i-1)*fontHeight)
	end
	love.graphics.setFont(oldFont)
	love.graphics.setColor(255, 255, 255)
end

--render character profile
local function drawProfile(tb)
	if not tb.profile then return end

	love.graphics.draw(tb.profile.avatar, tb.x + tb.textPadding.r, tb.y + tb.textPadding.t)
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
	read(self, textList[1])
	options = opts or {}
	optionIndex = 0
	optionCallback = callback
end

function Textbox:optionsActive()
	return not writing and #options > 0 and textPage == #textList
end

function Textbox:update(dt)
	timer = (timer + dt*10) % (math.pi*2)
	if not visible then return end
	if writing then
		skip(self, dt)
	end
	function love.keypressed(key)
		if not visible then return end
		if key == ' ' then
			if not writing then
				if self:optionsActive() then
					optionCallback(options[optionIndex+1], optionIndex)
				elseif #textList > 0 then
					nextPage(self)
				end
				if self.endSound then
					self.endSound:play()
				end
			else
				skip(self, self.beatSpeed*self.text:len())
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

function Textbox:draw()
	if not visible then return end

	drawBox(self, self.x, self.y, self:getWidth(), self:getHeight())
	drawOptions(self, self.x + self:getWidth() + self.textPadding.l, self.y)
	drawProfile(self)
	
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

return Textbox
