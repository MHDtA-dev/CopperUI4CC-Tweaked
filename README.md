![Logo](https://raw.githubusercontent.com/MihlanDOta/CopperUI4CC-Tweaked/main/images/cuilogo.JPG)

##Attention, please. The unofficial CopperUI library is laid out in the PyPI package manager. We are already working on this together with our dev ##studio, the official Python port will be posted later.

# CopperUI4CC-Tweaked

## What is CopperUI?
- CopperUI is a pseudo-ui framework for terminals. It allows you to draw windows, buttons, colored text, input fields and other widgets in the console using various characters and colored spaces. This version of the library is designed for minecraft mod CC: Tweaked. To install, you need to enter on your computer:

```
wget https://raw.githubusercontent.com/MihlanDOta/CopperUI4CC-Tweaked/main/CopperUI.lua CopperUI.lua
```


**Warning! The library is under development! When using it, it is possible that you may encounter bugs. Please report bugs in the "issues" tab**

### Some GIFs

- Test application demonstrates widgets in current version of library

![demoapp](https://raw.githubusercontent.com/MihlanDOta/CopperUI4CC-Tweaked/main/images/demoapp.gif)

- Here you can see a calculator written using this library:

![calculator](https://raw.githubusercontent.com/MihlanDOta/CopperUI4CC-Tweaked/main/images/copperuicctweaked.gif)


## How to use

- Create new lua file, and import the library

```
local copperui = dofile("CopperUI.lua")
```

### Create the window

```
local window = copperui.createWindow([Title], [Size X], [Size Y])
```
If you want full screen, use

```
local window = copperui.createWindow([Title], copperui.FULL_SCREEN())
```

- You can make window draggable:

```
window:setIsDraggable(true)
```

- Also you can make it scrollable:

```
window:setIsScrollable(true)
```

- You can make it in one line:

```
local window = copperui.createWindow([Title], [Size Z], [Size Y]):setIsDraggable(true):setIsScrollable(true)
```
### Labels

```
local label = copperui.createLabel([x position], [y position], [text], [text color])
```

For example:

```
local label = copperui.createLabel(3, 6, "Hello!", colors.red)
```

- You can make centered label:

```
local label = copperui.createCenteredLabel([window], [y position], [text], [text color])
```

- Add your label to the window:

```
window:addComponent(label)
```

- You can make it in one line:

```
window:addComponent(copperui.createLabel(3, 6, "Hello!", colors.red))
```

or

```
window:addComponent(copperui.createCenteredLabel(window, 6, "Hello!", colors.red))
```

You can change the label text in any piece of code

```
label:setText([Text])
```

### Adding events to the widgets

- You can use default computercraft events. You need to specify the name of the event and the pointer to the function to be executed. Arguments such as window, event name, button, and event coordinates will be passed to the function.

```
function label_clicked(window, event, button, x, y)
    window:addComponent(copperui.createCenteredLabel(window, 6, "Label was clicked!", colors.red))
end

label:onEvent("mouse_click", label_clicked)

```

In this example, when the mouse clicks on the label we created earlier, the ```label_clicked``` function will be called.

### Rendering the window
- The last line of code in your program should be the line
```
window:render()
```

This line starts rendering the window and listening for events.

### Final result

As a result, it turns out something like this:

```
local copperUI = dofile("CopperUI.lua")

local window = copperUI.createWindow("Title of the app", copperUI.FULL_SCREEN()):setIsDraggable(true)

local label = copperUI.createLabel(1, 3, "Usual label", colors.white)
local centered_label = copperUI.createCenteredLabel(window, 4, "Centered label", colors.white)

local clickable_label = copperUI.createLabel(1, 5, "Click me!", colors.white):onEvent("mouse_click", function() window:addComponent(copperUI.createLabel(1, 6, "Hello!", colors.red)) end)

window:addComponent(label)
window:addComponent(centered_label)
window:addComponent(clickable_label)

window:render()
```


***Documentation for other widgets coming soon...***
