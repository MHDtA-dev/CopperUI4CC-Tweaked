local copperUI = dofile("CopperUI.lua")

local window = copperUI.createWindow("Title of the app", copperUI.FULL_SCREEN()):setIsDraggable(true)

local label = copperUI.createLabel(1, 3, "Usual label", colors.white)
local centered_label = copperUI.createCenteredLabel(window, 4, "Centered label", colors.white)

local clickable_label = copperUI.createLabel(1, 5, "Click me!", colors.white):onEvent("mouse_click", function() window:addComponent(copperUI.createLabel(1, 6, "Hello!", colors.red)) end)

window:addComponent(label)
window:addComponent(centered_label)
window:addComponent(clickable_label)

window:render()
