Textbox = require 'textbox'

function love.load()
	love.graphics.setBackgroundColor(0, 0, 0)
	tb = Textbox:new()
	tb.font = love.graphics.newFont('data/babyblue.ttf', 16)
	tb.x, tb.y = 100, 100
	tb.paddingX, tb.paddingY = 20, 20
	tb.textWidth, tb.textHeight = 320, 3
	tb.textSound = love.audio.newSource('aud/blip.wav')
	tb.endSound = love.audio.newSource('aud/bleep.wav')
	tb.scrollSound = love.audio.newSource('aud/blap.wav')
	tb:setIcon(love.graphics.newImage('img/dot.png'), 16, 16)
	tb:setPatch(love.graphics.newImage('img/patch.png'))
	tb:setText({
		'Shall I compare thee to a summer\'s day?',
		'Thou art more lovely and more temperate:` Rough winds do shake the darling buds of May,` And summer\'s lease hath all too short a date.'
		}, {'FIGHT', 'ITEM', 'PKMN', 'RUN'},
		function(option)
			tb:setText({'It doesn\'t actually matter what you do.'})
		end)
end

function love.update(dt)
	tb:update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
end

function love.draw()
	tb:draw()
end
