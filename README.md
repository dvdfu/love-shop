#Love Shop
Welcome to the Love Shop - helper Lua libraries for Love2D.

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
