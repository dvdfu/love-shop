#Love Shop
Welcome to the Love Shop - helper Lua libraries for Love2D.

##input.lua

`input.lua` is a lightweight helper file designed to allow synchronous implementation of keyboard events such as keyboard presses and releases. For example:

```lua
Input = require 'input'

function love.update(dt)
    if Input:pressed('a') then
        print('The letter "a" was typed!')
    end
    Input:update()
end
```

This works under the following assumptions:

* `love.keyboard` callbacks are not defined elsewhere
* `input.lua` is `require`d once in some higher level file, such as `main.lua`
* `update()` is called once, *after* keyboard states are queried in one game loop

##textbox.lua

###Create a textbox

```lua
Textbox = require 'love-shop.textbox'

function love.load()
  tb = Textbox:new()
end
```

###Set textbox content

```lua
tb:setText({
  'This is an array of strings.',
  'Each string is one textbox page.',
  'You can use the \` symbol to add pauses,` or more for````longer pauses.',
  'You can also add questions?'},
  {'OK', 'No'},
  function(option)
    if option == 'No' then
      tb:setText({'And callbacks for option selections.'})
    end
  end)
```
