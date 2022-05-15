--CopperUI port for CC:Tweaked
--© MihlanDOta 2022

CopperTerm = {}

copperWindow = {}

copperLabel = {}

copperButton = {}

copperTextField = {}

copperListBox = {}

copperSwitch = {}

copperDropdown = {}

copperSubWindow = {}

copperProgressBar = {}

copperRadioGroup = {}

function has_index (tab, val)
    for index, value in pairs(tab) do
        if index == val then
            return true
        end
    end

    return false
end

function copperWindow:new(title, width, height)
    local obj = {}
    obj.x = 1
    obj.y = 1
    obj.backgroundColor = colors.lightGray
    obj.headerColor = colors.gray
    obj.windowTitle = title
    obj.windowWidth, obj.windowHeight = width, height
    obj.components = {}
    obj.isClosed = false
    obj.isDraggable = false
    obj._offsetX = nil
    obj._enableDrag = false
    obj._scrollOffset = 0
    obj.isScrollable = false

    
    function obj:getTitle()
        return self.windowTitle
    end

    function obj:getWidth()
        return self.windowWidth
    end

    function obj:getHeight()
        return self.windowHeight
    end

    function obj:getX()
        return self.x
    end

    function obj:getY()
        return self.y
    end

    function obj:setBackgroundColor(color)
        self.backgroundColor = color
    end

    function obj:addComponent(component)
        table.insert(self.components, component)

    end

    function obj:getComponentByPosition(x, y)
        comp = nil

        for i=1, #self.components do
            if (x >= (self.x - 1) + self.components[i].x and x <= (self.x - 1) + self.components[i].x + self.components[i].width - 1) and (y >= self._scrollOffset + (self.y - 1) + self.components[i].y and y <= self._scrollOffset + (self.y - 1) + self.components[i].y + (self.components[i].height - 2)) then
                comp = self.components[i]
            end
        end


        return comp
    end

    function obj:_render()
        term.clear()
        paintutils.drawFilledBox(self.x, self.y, self.x + self.windowWidth - 1, self.y + self.windowHeight - 1, self.backgroundColor)

        for i = 1, #self.components do
            self.components[i]:_render(self)
        end

        paintutils.drawBox(self.x, self.y, self.x + self.windowWidth - 1, self.y, self.headerColor)
        term.setCursorPos(self.x, self.y)
        term.write(self.windowTitle)
        paintutils.drawPixel(self.x + self.windowWidth - 2, self.y, colors.red)
        paintutils.drawPixel(self.x + self.windowWidth - 1, self.y, colors.red)
        term.setCursorPos(self.x + self.windowWidth - 1, self.y)
        term.write("X")
        term.setBackgroundColor(colors.black)

    end

    function obj:close()
        self.isClosed = true
    end

    function obj:setIsDraggable(isDraggable)
        self.isDraggable = isDraggable
        return self
    end

    function obj:setIsScrollable(isScrollable)
        self.isScrollable = isScrollable
        return self
    end

    function obj:getIsScrollable()
        return self.isScrollable
    end

    function obj:getIsDraggable()
        return self.isDraggable
    end
    
    function obj:render() 

        self:_render()

        while true do
            local event, button, x, y = os.pullEvent()
            local eventByScrollableComponent = false

            if event == "mouse_click" then
                if (x == self.x + self.windowWidth - 1 and y == self.y) or (x == self.x + self.windowWidth - 2 and y == self.y) then
                    self:close()
                end

                if self.isDraggable then
                    if (x >= self.x and x <= self.x + self.windowWidth - 1) and y == self.y then
                        self._enableDrag = true
                        self._offsetX = (self.x + self.windowWidth - 1) - (x + self.windowWidth) + 1
                    end
                end
            end

            if event == "mouse_up" then
                if self.isDraggable then
                    if (x >= self.x and x <= self.x + self.windowWidth - 1) and y == self.y then
                        self._enableDrag = false
                    end
                end
            end

            if event == "mouse_drag" then
                if self.isDraggable and self._enableDrag then
                    self.x = x + self._offsetX
                    self.y = y
                end
            end
            

            for i = 1, #self.components do
                if x ~= nil and y ~= nil then
                    --print(tostring(y).." <= "..tostring(self._scrollOffset + (self.y - 1) + self.components[i].y + (self.components[i].height - 1) - 1))
                    --os.sleep(3)
                    if (x >= (self.x - 1) + self.components[i].x and x <= (self.x - 1) + self.components[i].x + self.components[i].width - 1) and (y >= self._scrollOffset + (self.y - 1) + self.components[i].y and y <= self._scrollOffset + (self.y - 1) + self.components[i].y + (self.components[i].height - 2)) or not self.components[i].eventFrame then
                        self.components[i]:_pullEvent(self, event, button, x, y)

                        if self.components[i]._scrollableElement == true then
                        	eventByScrollableComponent = true and self.components[i].isVisible
                    	end
                    end
                else
                    self.components[i]:_pullEvent(self, event, button, nil, nil)
                end
            end

            if event == "mouse_scroll" then
                if self._scrollOffset - button <= 0 and self.isScrollable and not eventByScrollableComponent then
                    self._scrollOffset = self._scrollOffset - button
                end
            end

            self:_render()

            if self.isClosed then
                term.setCursorPos(1, 1)
                term.setBackgroundColor(colors.black)
                term.clear()
                break
            end

        end

    end
    
    setmetatable(obj, self)
    self.__index = self; return obj
end


function copperSubWindow:new(title, width, height)
    local obj = {}
    obj.x = 1
    obj.y = 1
    obj.width = width + 1
    obj.height = height + 1
    obj.title = title



    setmetatable(obj, self)
    self.__index = self; return obj
end

function copperLabel:new(x, y, text, color)
    local obj = {}
    obj.x = x
    obj.y = y
    obj.text = text
    obj.color = color
    obj.selectionColor = colors.blue
    obj.width = string.len(text)
    obj.height = 2
    obj.eventFuncs = {}
    obj.eventFrame = true
    obj.isSelected = false

    function obj:_render(window)
        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y and self.text ~= nil then
            local _old_color = term.getTextColor()
            local _old_back_color = term.getBackgroundColor()
            if self.isSelected then
                paintutils.drawFilledBox((window.x - 1) + self.x, (window.y - 1) + self.y + window._scrollOffset, (window.x - 1) + self.x + self.width - 1, (window.y - 1) + self.y + self.height - 1 + window._scrollOffset - 1, self.selectionColor)
            end
            term.setBackgroundColor(window.backgroundColor)
            term.setCursorPos((window.x - 1) + math.floor(((self.width - string.len(self.text)) / 2) + self.x), (window.y - 1) + math.floor((self.height / 2) + self.y) + window._scrollOffset - 1)
            term.setTextColor(self.color)
            term.write(self.text)
            term.setTextColor(_old_color)
            term.setBackgroundColor(_old_back_color)
        end
    end

    function obj:_pullEvent(window, event, button, x, y)
        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            if has_index(self.eventFuncs, event) then
                self.eventFuncs[event](window, event, button, x, y)
            end
        end

        --for _event, _func in pairs(self.eventFuncs) do
        --    
        --end
    end

    function obj:getText()
        return self.text
    end

    function obj:setText(text)
        self.text = text
        return self
    end

    function obj:setX(x)
        self.x = x
        return self
    end

    function obj:setY(y)
        self.y = y
        return self
    end

    function obj:setWidth(width)
        self.width = width + 1
        return self
    end

    function obj:getWidth()
        return self.width
    end

    function obj:getHeight()
        return self.height - 1
    end

    function obj:getX()
        return self.x
    end

    function obj:getY()
        return self.y
    end

    function obj:setHeight(height)
        self.height = height
        return self
    end

    function obj:disableEventFrame(state)
        self.eventFrame = not state
        return self
    end

    function obj:getTextColor()
        return self.color
    end

    function obj:onEvent(event, func)
        self.eventFuncs[event] = func
        return self
    end

    setmetatable(obj, self)
    self.__index = self; return obj
end

function copperTextField:new(x, y, width, height)
    local obj = {}
    obj.x = x
    obj.y = y
    obj.width = width
    obj.height = height + 1
    obj.eventFuncs = {}
    obj.fieldColor = colors.black
    obj.textColor = colors.white
    obj.eventFrame = true
    obj.text = ""
    obj.isEnabled = true

    function obj:_render(window)
        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            local _old_color = term.getTextColor()
            local _old_back_color = term.getBackgroundColor()
            paintutils.drawFilledBox((window.x - 1) + self.x, (window.y - 1) + self.y + window._scrollOffset, (window.x - 1) + self.x + self.width - 1, (window.y - 1) + self.y + self.height - 1 + window._scrollOffset - 1, self.fieldColor)
            term.setCursorPos((window.x - 1) + self.x, (window.y - 1) + math.floor((self.height / 2) + self.y) + window._scrollOffset - 1)
            term.setTextColor(self.textColor)
            term.setBackgroundColor(self.fieldColor)
            if string.len(self.text) > self.width then
                term.write(string.sub(self.text, 1, self.width - 3).."...")
            else
                term.write(self.text)
            end
            term.setBackgroundColor(_old_back_color)
            term.setTextColor(_old_color)
        end
    end

    function obj:_pullEvent(window, event, button, x, y)
        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            if event == "mouse_click" then
                if self.isEnabled then
                    local _old_color = term.getTextColor()
                    local _old_back_color = term.getBackgroundColor()
                    paintutils.drawFilledBox((window.x - 1) + self.x, window._scrollOffset + (window.y - 1) + self.y, (window.x - 1) + self.x + self.width - 1, window._scrollOffset + (window.y - 1) + self.y + self.height - 2, self.fieldColor)
                    term.setCursorPos((window.x - 1) + self.x, window._scrollOffset + (window.y - 1) + math.floor((self.height / 2) + self.y - 1))
                    term.setTextColor(self.textColor)
                    term.setBackgroundColor(self.fieldColor)
                    obj.text = io.read()
                    term.setTextColor(_old_color)
                    term.setBackgroundColor(_old_back_color)
                end
            end

            if self.isEnabled then
                if has_index(self.eventFuncs, event) then
                    self.eventFuncs[event](window, event, button, x, y)
                end
            end
        end

    end

    function obj:disableEventFrame(state)
        self.eventFrame = not state
        return self
    end

    function obj:setX(x)
        self.x = x
        return self
    end

    function obj:setIsEnabled(isEnabled)
        self.isEnabled = isEnabled
        return self
    end

    function obj:getIsEnabled()
        return self.isEnabled
    end

    function obj:setY(y)
        self.y = y
        return self
    end

    function obj:getText()
        return self.text
    end

    function obj:setText(text)
        self.text = text
        return self
    end

    function obj:setWidth(width)
        self.width = width
        return self
    end

    function obj:setHeight(height)
        self.height = height
        return self
    end

    function obj:getWidth()
        return self.width
    end

    function obj:getHeight()
        return self.height
    end

    function obj:getX()
        return self.x
    end

    function obj:getY()
        return self.y
    end

    function obj:onEvent(event, func)
        self.eventFuncs[event] = func
        return self
    end

    setmetatable(obj, self)
    self.__index = self; return obj

end



function copperButton:new(x, y, width, height, text, textColor)
    local obj = {}
    obj.x = x
    obj.y = y
    obj.width = width
    obj.height = height + 1
    obj.text = text
    obj.textColor = textColor
    obj.buttonColor = colors.gray
    obj.eventFuncs = {}
    obj.eventFrame = true
    obj.isEnabled = true

    function obj:_render(window)
        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            local _old_color = term.getTextColor()
            local _old_back_color = term.getBackgroundColor()
            paintutils.drawFilledBox((window.x - 1) + self.x, (window.y - 1) + self.y + window._scrollOffset, (window.x - 1) + self.x + self.width - 1, (window.y - 1) + self.y + self.height - 1 + window._scrollOffset - 1, self.buttonColor)
            term.setTextColor(self.textColor)
            term.setCursorPos((window.x - 1) + math.floor(((self.width - string.len(self.text)) / 2) + self.x), (window.y - 1) + math.floor(((self.height - 1) / 2) + self.y) + window._scrollOffset)
            term.write(self.text)
            term.setTextColor(_old_color)
            term.setBackgroundColor(_old_back_color)
        end
    end

    function obj:_pullEvent(window, event, button, x, y)
        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            if self.isEnabled then
                if event == "mouse_click" then
                    self.buttonColor = colors.black
                end

                if event == "mouse_up" then
                    self.buttonColor = colors.gray
                end


                if has_index(self.eventFuncs, event) then
                    self.eventFuncs[event](window, event, button, x, y)
                end
            end
        end

    end

    function obj:setText(text)
        self.text = text
        return self
    end

    function obj:disableEventFrame(state)
        self.eventFrame = not state
        return self
    end

    function obj:setX(x)
        self.x = x
        return self
    end

    function obj:setIsEnabled(isEnabled)
        self.isEnabled = isEnabled
        return self
    end

    function obj:getIsEnabled()
        return self.isEnabled
    end

    function obj:setY(y)
        self.y = y
        return self
    end

    function obj:setWidth(width)
        self.width = width
        return self
    end

    function obj:setHeight(height)
        self.height = height
        return self
    end

    function obj:getWidth()
        return self.width
    end

    function obj:getHeight()
        return self.height
    end

    function obj:getX()
        return self.x
    end

    function obj:getY()
        return self.y
    end

    function obj:onEvent(event, func)
        self.eventFuncs[event] = func
        return self
    end

    setmetatable(obj, self)
    self.__index = self; return obj
end

function copperSwitch:new(x, y)
    local obj = {}
    obj.x = x
    obj.y = y
    obj.width = 4
    obj.height = 2
    obj.enabledColor = colors.lime
    obj.disabledColor = colors.gray
    obj.enabled = false
    obj.eventFuncs = {}
    obj.eventFrame = true
    obj.isEnabled = true

    function obj:_render(window)
        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            local _old_color = term.getTextColor()
            local _old_back_color = term.getBackgroundColor()

            if self.enabled then
                paintutils.drawBox((window.x - 1) + self.x, (window.y - 1) + self.y + window._scrollOffset, (window.x - 1) + self.x + self.width - 1, (window.y - 1) + self.y + self.height - 1 + window._scrollOffset - 1, self.enabledColor)
                paintutils.drawPixel((window.x - 1) + self.x + self.width - 1, (window.y - 1) + self.y + self.height - 1 + window._scrollOffset - 1, colors.white)
            else
                paintutils.drawBox((window.x - 1) + self.x, (window.y - 1) + self.y + window._scrollOffset, (window.x - 1) + self.x + self.width - 1, (window.y - 1) + self.y + self.height - 1 + window._scrollOffset - 1, self.disabledColor)
                paintutils.drawPixel((window.x - 1) + self.x, (window.y - 1) + self.y + window._scrollOffset, colors.white)
            end


            term.setTextColor(_old_color)
            term.setBackgroundColor(_old_back_color)
        end
    end

    function obj:_pullEvent(window, event, button, x, y)
        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            if self.isEnabled then
                if event == "mouse_click" then
                    self.enabled = not self.enabled
                end

                if has_index(self.eventFuncs, event) then
                    self.eventFuncs[event](window, event, button, x, y)
                end
            end
        end

    end

    function obj:onEvent(event, func)
        self.eventFuncs[event] = func
        return self
    end

    function obj:disableEventFrame(state)
        self.eventFrame = not state
        return self
    end

    function obj:getState()
        return self.enabled
    end

    function obj:getX()
        return self.x
    end

    function obj:getY()
        return self.y
    end

    setmetatable(obj, self)
    self.__index = self; return obj
end

function copperListBox:new(x, y, width, height)
    local obj = {}
    obj.x = x
    obj.y = y
    obj.width = width
    obj.height = height + 1
    obj.elements = {}
    obj.selectedElemntIndex = nil
    obj.backgroundColor = colors.gray
    obj.selectedElementColor = colors.black
    obj.textColor = colors.white
    obj.eventFuncs = {}
    obj.isVisible = true
    obj.eventFrame = true
    obj._scrollableElement = true
    obj._scrollOffset = 0
    obj.pereves = 0
    obj.autoScroll = false

    function obj:_render(window)
    	if not self.isVisible then
    		return
    	end

    	self.pereves = #self.elements - (self.height - 1)
    	if self.pereves < 0 then
    		self.pereves = 0
    	end

    	if self.autoScroll then
    		self._scrollOffset = self.pereves
    	end

        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            local _old_color = term.getTextColor()
            local _old_back_color = term.getBackgroundColor()
            paintutils.drawFilledBox((window.x - 1) + self.x, (window.y - 1) + self.y + window._scrollOffset, (window.x - 1) + self.x + self.width - 1, (window.y - 1) + self.y + self.height - 1 + window._scrollOffset - 1, self.backgroundColor)
            term.setTextColor(self.textColor)

            if #self.elements > 0 then
                for i=1, #self.elements do
                	i = i + self._scrollOffset
                	if (window.y - 1) + self.y + i - 1 + window._scrollOffset - self._scrollOffset <= (window.y - 1) + self.y + self.height - 1 + window._scrollOffset - 1 then
	                    if i == self.selectedElemntIndex then
	                        paintutils.drawBox((window.x - 1) + self.x, (window.y - 1) + self.y + i - 1 + window._scrollOffset - self._scrollOffset, (window.x - 1) + self.x + self.width - 1, (window.y - 1) + self.y + i - 1 + window._scrollOffset - self._scrollOffset, self.selectedElementColor)
	                    else
	                        paintutils.drawBox((window.x - 1) + self.x, (window.y - 1) + self.y + i - 1 + window._scrollOffset - self._scrollOffset, (window.x - 1) + self.x + self.width - 1, (window.y - 1) + self.y + i - 1 + window._scrollOffset - self._scrollOffset, self.backgroundColor)
	                    end
	                    term.setCursorPos((window.x - 1) + self.x, (window.y - 1) + self.y + i - 1 + window._scrollOffset - self._scrollOffset)

                    
	                    if string.len(self.elements[i]) > self.width - 1 then
	                        term.write(string.sub(self.elements[i], 1, self.width - 3).."...")
	                    else
	                        term.write(self.elements[i])
	                    end
                	end
                end
            end
            term.setTextColor(_old_color)
            term.setBackgroundColor(_old_back_color)
        end
    end

    function obj:_pullEvent(window, event, button, x, y)
    	if not self.isVisible then
    		return
    	end

        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            if event == "mouse_click" then
                --print(self.height)
                --os.sleep(5)
                if y - (window.y - 1) - self.y + 1 - window._scrollOffset + self._scrollOffset <= #self.elements then
                    self.selectedElemntIndex = y - (window.y - 1) - self.y + 1 - window._scrollOffset + self._scrollOffset
                end
            end

            if event == "mouse_scroll" then
            	if self._scrollOffset + button >= 0 and self._scrollOffset + button <= self.pereves then
            		self._scrollOffset = self._scrollOffset + button
            	end
            end

            if has_index(self.eventFuncs, event) then
                self.eventFuncs[event](window, event, button, x, y)
            end
        end

    end

    function obj:onEvent(event, func)
        self.eventFuncs[event] = func
        return self
    end

    function obj:setAutoScroll(autoScroll)
    	self.autoScroll = autoScroll
    	return self
    end

    function obj:getAutoScroll()
    	return self.autoScroll
    end

    function obj:setIsVisible(isVisible)
    	self.isVisible = isVisible
    	return self
    end

    function obj:setSelectedIndex(index)
        if index <= 0 or index > #self.elements then
            self.selectedElemntIndex = nil
        else
            self.selectedElemntIndex = index
        end
    end

    function obj:getIsVisible()
    	return self.isVisible
    end

    function obj:addElement(element)
        table.insert(self.elements, element)
        return self
    end

    function obj:getElementsArray()
        return self.elements
    end

    function obj:removeLatestElement(element)
        table.remove(self.elements)
        return self
    end

    function obj:getSelectedIndex()
        return self.selectedElemntIndex
    end

    function obj:getSelectedElement()
        if self.selectedElemntIndex == nil then
            return nil
        else
            return self.elements[self.selectedElemntIndex]
        end
    end

    function obj:getElementsCount()
    	return #self.elements
    end

    function obj:setX(x)
        self.x = x
        return self
    end

    function obj:setY(y)
        self.y = y
        return self
    end

    function obj:setWidth(width)
        self.width = width
        return self
    end

    function obj:setHeight(height)
        self.height = height + 1
        return self
    end

    function obj:getWidth()
        return self.width
    end

    function obj:getHeight()
        return self.height - 1
    end

    function obj:getX()
        return self.x
    end

    function obj:getY()
        return self.y
    end

    setmetatable(obj, self)
    self.__index = self; return obj

end

function copperDropdown:new(x, y, width, window)
    local obj = {}
    obj.x = x
    obj.y = y
    obj.width = width
    obj.height = 2
    obj.textColor = colors.white
    obj.fieldColor = colors.gray
    obj.isEnabled = true
    obj.eventFrame = true
    obj.eventFuncs = {}
    obj.listbox = copperListBox:new(x, y + 1, width, 4):setIsVisible(false):onEvent("mouse_click", function() obj.listbox:setIsVisible(false) end)
    window:addComponent(obj.listbox)


    function obj:_render(window)
        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            local _old_color = term.getTextColor()
            local _old_back_color = term.getBackgroundColor()
            paintutils.drawFilledBox((window.x - 1) + self.x, (window.y - 1) + self.y + window._scrollOffset, (window.x - 1) + self.x + self.width - 1, (window.y - 1) + self.y + self.height - 1 + window._scrollOffset - 1, self.fieldColor)
            term.setCursorPos((window.x - 1) + self.x, (window.y - 1) + math.floor((self.height / 2) + self.y) + window._scrollOffset - 1)
            term.setTextColor(self.textColor)
            term.setBackgroundColor(self.fieldColor)

            if self.listbox:getSelectedElement() == nil then
                term.write("")
            else
                if string.len(self.listbox:getSelectedElement()) > self.width then
                    term.write(string.sub(self.listbox:getSelectedElement(), 1, self.width - 3).."...")
                else
                    term.write(self.listbox:getSelectedElement())
                end
            end
            term.setBackgroundColor(_old_back_color)
            term.setTextColor(_old_color)
        end
    end

    function obj:initialSelectionIndex(index)
        self.listbox:setSelectedIndex(index)
    end

    function obj:_pullEvent(window, event, button, x, y)
        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            if event == "mouse_click" then
                if self.isEnabled then

                    if #self.listbox:getElementsArray()  <= 4 then
                        self.listbox:setHeight(#self.listbox:getElementsArray())
                    else
                        self.listbox:setHeight(4)
                    end

                    self.listbox:setIsVisible(not self.listbox:getIsVisible())
                end
            end

            if self.isEnabled then
                if has_index(self.eventFuncs, event) then
                    self.eventFuncs[event](window, event, button, x, y)
                end
            end
        end

    end

    function obj:addElement(element)
        self.listbox:addElement(element)
        return self
    end

    setmetatable(obj, self)
    self.__index = self; return obj
end

function copperProgressBar:new(x, y, width)
    local obj = {}
    obj.x = x
    obj.y = y
    obj.width = width
    obj.height = 2
    obj.progress = 0
    obj.progressColor = colors.lime
    obj.color = colors.gray
    obj.eventFrame = true
    obj.eventFuncs = {}

    function obj:_render(window)
        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            local _old_color = term.getTextColor()
            local _old_back_color = term.getBackgroundColor()
            paintutils.drawFilledBox((window.x - 1) + self.x, (window.y - 1) + self.y + window._scrollOffset, (window.x - 1) + self.x + self.width - 1, (window.y - 1) + self.y + self.height - 1 + window._scrollOffset - 1, self.color)

            if math.floor(self.width * self.progress / 100) ~= 0 then
                paintutils.drawFilledBox((window.x - 1) + self.x, (window.y - 1) + self.y + window._scrollOffset, (window.x - 1) + self.x + (self.width * self.progress / 100) - 1, (window.y - 1) + self.y + self.height - 1 + window._scrollOffset - 1, self.progressColor)
            end
            term.setBackgroundColor(_old_back_color)
            term.setTextColor(_old_color)
        end
    end

    function obj:_pullEvent(window, event, button, x, y)
        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            if self.isEnabled then
                if has_index(self.eventFuncs, event) then
                    self.eventFuncs[event](window, event, button, x, y)
                end
            end

            if has_index(self.eventFuncs, event) then
                self.eventFuncs[event](window, event, button, x, y)
            end

        end

    end

    function obj:setX(x)
        self.x = x
        return self
    end

    function obj:setY(y)
        self.y = y
        return self
    end

    function obj:setWidth(width)
        self.width = width
        return self
    end

    function obj:setHeight(height)
        self.height = height + 1
        return self
    end

    function obj:getWidth()
        return self.width
    end

    function obj:getHeight()
        return self.height - 1
    end

    function obj:getX()
        return self.x
    end

    function obj:getY()
        return self.y
    end

    function obj:getProgress()
        return self.progress
    end

    function obj:setProgress(percentage)
        if percentage > 100 then
            self.progress = 100
        elseif percentage < 0 then
            self.progress = 0
        else
            self.progress = percentage
        end
        return self
    end

    setmetatable(obj, self)
    self.__index = self; return obj
end

function copperRadioGroup:new(x, y)
    local obj = {}
    obj.x = x
    obj.y = y
    obj.width = 5
    obj.height = 1
    obj.elements = {}
    obj.selectedElemntIndex = nil
    obj.eventFrame = true
    obj.eventFuncs = {}
    obj.radioColor = colors.gray
    obj.isVisible = true
    obj.textColor = colors.white

    function obj:_render(window)
        if not self.isVisible then
            return
        end

        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            local _old_color = term.getTextColor()
            local _old_back_color = term.getBackgroundColor()
            --paintutils.drawFilledBox((window.x - 1) + self.x, (window.y - 1) + self.y + window._scrollOffset, (window.x - 1) + self.x + self.width - 1, (window.y - 1) + self.y + self.height - 1 + window._scrollOffset - 1, self.backgroundColor)
            term.setTextColor(self.textColor)

            if #self.elements > 0 then
                for i=1, #self.elements do
                    if (window.y - 1) + self.y + i - 1 + window._scrollOffset <= (window.y - 1) + self.y + self.height - 1 + window._scrollOffset - 1 then
                        paintutils.drawPixel((window.x - 1) + self.x, (window.y - 1) + self.y + i - 1 + window._scrollOffset, self.radioColor)
                        term.setBackgroundColor(_old_back_color)
                        if i == self.selectedElemntIndex then
                            term.setBackgroundColor(self.radioColor)
                            term.setCursorPos((window.x - 1) + self.x, (window.y - 1) + self.y + i - 1 + window._scrollOffset)
                            term.write("*")
                            term.setBackgroundColor(_old_back_color)
                        end
                        term.setCursorPos((window.x - 1) + self.x + 2, (window.y - 1) + self.y + i - 1 + window._scrollOffset)
                        term.write(self.elements[i])
                    end
                end
            end
            term.setTextColor(_old_color)
            term.setBackgroundColor(_old_back_color)
        end
    end

    function obj:_pullEvent(window, event, button, x, y)
        if not self.isVisible then
            return
        end

        if (window.y - 1) + window._scrollOffset + self.y + self.height > window.y then
            if event == "mouse_click" then
                --print(self.height)
                --os.sleep(5)
                if y - (window.y - 1) - self.y + 1 - window._scrollOffset <= #self.elements then
                    self.selectedElemntIndex = y - (window.y - 1) - self.y + 1 - window._scrollOffset
                end
            end


            if has_index(self.eventFuncs, event) then
                self.eventFuncs[event](window, event, button, x, y)
            end
        end

    end

    function obj:addElement(element)
        table.insert(self.elements, element)
        self.height = self.height + 1
        return self
    end

    function obj:getElementsArray()
        return self.elements
    end

    function obj:removeLatestElement(element)
        table.remove(self.elements)
        return self
    end

    function obj:getSelectedIndex()
        return self.selectedElemntIndex
    end

    function obj:getSelectedElement()
        if self.selectedElemntIndex == nil then
            return nil
        else
            return self.elements[self.selectedElemntIndex]
        end
    end

    setmetatable(obj, self)
    self.__index = self; return obj

end

function CopperTerm.createWindow(title, width, height)
    window = copperWindow:new(title, width, height)
    return window
end

function CopperTerm.createLabel(x, y, text, color)
    label = copperLabel:new(x, y, text, color)
    return label
end

function CopperTerm.createCenteredLabel(window, y, text, color)
    label = copperLabel:new(math.floor((window.windowWidth - string.len(text)) / 2), y, text, color)
    return label
end

function CopperTerm.createButton(x, y, width, height, text, textColor)
    button = copperButton:new(x, y, width, height, text, textColor)
    return button
end

function CopperTerm.createCenteredButton(window, y, width, height, text, textColor)
    button = copperButton:new(math.floor((window.windowWidth - width) / 2), y, width, height, text, textColor)
    return button
end

function CopperTerm.createTextField(x, y, width, height)
    textfield = copperTextField:new(x, y, width, height)
    return textfield
end

function CopperTerm.createCenteredTextField(window, y, width, height)
    textfield = copperTextField:new(math.floor((window.windowWidth - width) / 2), y, width, height)
    return textfield
end

function CopperTerm.createListBox(x, y, width, height)
    listbox = copperListBox:new(x, y, width, height)
    return listbox
end

function CopperTerm.createCenteredListBox(window, y, width, height)
    listbox = copperListBox:new(math.floor((window.windowWidth - width) / 2), y, width, height)
    return listbox
end

function CopperTerm.createSwitch(x, y)
    switch = copperSwitch:new(x, y)
    return switch
end

function CopperTerm.createCenteredSwitch(window, y)
    switch = copperSwitch:new(math.floor((window.windowWidth - 4) / 2), y)
    return switch
end

function CopperTerm.createDropdown(x, y, width, window)
    dropdown = copperDropdown:new(x, y, width, window)
    return dropdown
end

function CopperTerm.createCenteredDropdown(window, y, width)
    dropdown = copperDropdown:new(math.floor((window.windowWidth - width) / 2), y, width, window)
    return dropdown
end

function CopperTerm.createProgressBar(x, y, width)
    progressBar = copperProgressBar:new(x, y, width)
    return progressBar
end

function CopperTerm.createCenteredProgressBar(window, y, width)
    progressBar = copperProgressBar:new(math.floor((window.windowWidth - width) / 2), y, width)
    return progressBar
end

function CopperTerm.createRadioGroup(x, y)
    radioGroup = copperRadioGroup:new(x, y)
    return radioGroup
end

function CopperTerm.createCenteredRadioGroup(window, y)
    radioGroup = copperRadioGroup:new(math.floor((window.windowWidth - 5) / 2), y)
    return radioGroup
end

function CopperTerm.FULL_SCREEN()
    return term.getSize()
end

return CopperTerm


