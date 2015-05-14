Textbox = require 'textbox'

function love.load()
	tb = Textbox:new()
	-- tb:setFont(love.graphics.newFont('data/Retro Computer_DEMO.ttf', 14))
	tb.font = love.graphics.newFont('data/babyblue.ttf', 16)
	tb.x, tb.y = 100, 100
	tb.textSound = love.audio.newSource('aud/blip.wav')
	tb.endSound = love.audio.newSource('aud/bleep.wav')
	tb:setIcon(love.graphics.newImage('img/dot.png'), 16, 16)
	-- tb:setText({
	-- 		'As you probably know by now,` LOVE is a framework for making 2D games in the Lua programming language.',
	-- 		'LOVE is totally free,` and can be used in anything from friendly open-source hobby projects,` to evil,` closed-source commercial ones.',
	-- 		'This is the full source for \'hello world\' in LOVE.',
	-- 		'Running this code will cause an 640 by 400 window to appear,` and display white text on a black background.'
	-- 	})
	local function cb(option)
		if option == 'yes' then
			tb:setText({'good'})
		else
			tb:setText(
				{'As you probably know by now,` LOVE is a framework for making 2D games in the Lua programming language.',
				'do you understand'},
				{'no','maybe','yes'}, cb)
		end
	end
	tb:setText(
		{'As you probably know by now,` LOVE is a framework for making 2D games in the Lua programming language.',
		'do you understand'},
		{'no','maybe','yes'}, cb)
	
end

function love.update(dt)
	tb:update(dt)
end

function love.draw()
	tb:draw()
end
