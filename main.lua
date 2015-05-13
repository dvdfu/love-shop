Textbox = require 'textbox'

function love.load()
	tb = Textbox:new()
	-- tb:setFont(love.graphics.newFont('data/Retro Computer_DEMO.ttf', 14))
	tb:setFont(love.graphics.newFont('data/pixelmix.ttf', 16))
	tb:setPosition(20, 20)
	tb:setTextSound(love.audio.newSource('aud/blip.wav'))
	tb:setEndSound(love.audio.newSource('aud/bleep.wav'))
	tb:setTexts({
			'As you probably know by now,` LOVE is a framework for making 2D games in the Lua programming language.',
			'LOVE is totally free,` and can be used in anything from friendly open-source hobby projects,` to evil,` closed-source commercial ones.',
			'This is the full source for \'hello world\' in LOVE.',
			'Running this code will cause an 800 by 600 window to appear,` and display white text on a black background.'
		})
end

function love.update(dt)
	tb:update(dt)
end

function love.draw()
	tb:draw()
end
