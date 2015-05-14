Textbox = require 'textbox'

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.graphics.setBackgroundColor(180, 200, 220)
	tb = Textbox:new()
	tb.font = love.graphics.newFont('data/babyblue.ttf', 16)
	tb.x, tb.y = 100, 100
	tb.paddingX, tb.paddingY = 16, 16
	tb.textWidth, tb.textHeight = 320, 3
	tb.textSound = love.audio.newSource('aud/blip.wav')
	tb.endSound = love.audio.newSource('aud/bleep.wav')
	tb.scrollSound = love.audio.newSource('aud/blap.wav')
	tb:setIcon(love.graphics.newImage('img/dot.png'), 16, 16)
	tb:setPatch(love.graphics.newImage('img/patch.png'))
	tb:setText({
		'Shall I compare thee to a summer\'s day?',
		'Thou art more lovely and more temperate:` Rough winds do shake the darling buds of May,` And summer\'s lease hath all too short a date.'
		}, {'Rock', 'Paper', 'Scissors', 'Snake', 'Spock'},
		function(option, index)
			tb:setText({'You chose ' .. option .. '. It doesn\'t actually matter what you do.'})
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
