borders = require("borders")

hazeUI = {
    els = {},
    lastTouchUser = nil,
    currentScreen = nil,
    config = { screen = false, gpu = false },
    gpu = nil,
    super = self }

function copy (t) -- shallow-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do target[k] = v end
    setmetatable(target, meta)
    return target end

function clone (t) -- deep-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then target[k] = clone(v)
        else target[k] = v end end
    setmetatable(target, meta)
    return target end

function hazeUI:drawStatusbar(x, y, w, h, s, j, prefix)
    perc = math.floor((100/s) * j)
    bar = 1+math.floor( 0.5 + (((w-2) / s) * j))
    if prefix ~= nil then self.gpu.fill(x, y, w, h+1, " ");
    else self.gpu.fill(x, y, w, h, " "); end
    self.gpu.set(x, y, "[")
    self.gpu.set(x+w, y, "]")
    self.gpu.fill(x+1, y, bar, 1, "#");
    self.gpu.fill(x+1+bar, y, (w-bar-1), 1, "-");
    if prefix ~= nil then self.gpu.set(x, y+1, perc.."% ".. prefix.." "..j.." of "..s) end
end

function hazeUI:drawElement(el)
    if not el or el == nil then return end

    local text = el.text

    if type(text) == "string" then text = { text } end

    local xOffset = {}

    if not text then text = "" end

    for i=1,#text do
        if string.len(text[i]) > (el.w - (2*el.textPadding)) then
            text[i] = string.sub(text[i], 0, (el.w-(2*el.textPadding)))
        end

        if el.textalign == "center" then
            xOffset[i] = math.floor((el.w-(2*el.textPadding)-string.len(text[i])) / 2)
        elseif el.textalign == "right" then
            xOffset[i] = (el.w-(2*el.textPadding)) - string.len(text[i])
        else
            xOffset[i] = 0
        end
    end

    if el.fg then self.gpu.setForeground(el.fg) end
    if el.bg then self.gpu.setBackground(el.bg) end

    self.gpu.fill(el.x, el.y, el.w, el.h, " ")

    yT = el.y + math.ceil((el.h-#text)/2)

    for i=1,#text do
        xT = el.x + el.textPadding + xOffset[i]
        self.gpu.set(xT, yT+i-1, text[i])
    end

    if el.border ~= nil then
        borders.draw(el.x, el.y, el.w, el.h, el.borderColor, el.bg, el.border, self.gpu)
    end

    self.gpu.setBackground(0x000000)
    self.gpu.setForeground(0xFFFFFF)
end

function hazeUI:flushElements(force)
    if force == nil then force = false end
    for j=1,#self.els do
        local fl = false
        if self.els[j].window ~= self.currentScreen then
            if self.els[j].window ~= "all" then fl = true end
        end

        if force ~= false and self.els[j].window ~= "all" then fl = true end

        if fl then
            table.remove(self.els, j)
            self:flushElements(force)
            return
        end
    end
end

function hazeUI:drawScreen(name)
    self.currentScreen = name
    self.gpu.setBackground(0x0)
    self.gpu.fill(1,1,80,25, " ")
    if name ~= "all" then self:drawGroup("all") end
    self:drawGroup(name)
end

function hazeUI:drawGroup(name, subgroup)
    for j=1,#self.els do
        if self.els[j].window == name then
            if not subgroup or self.els[j].group == subgroup then
                self:drawElement(self.els[j])
            end end end end

-- add a button to the local cache
function hazeUI:addButton(x, y, w, h, text, group, foreground, background, textalign, cb, cb_parm)
    local el = {}
    el.x = x
    el.y = y
    el.w = w
    el.h = h
    el.border = nil
    el.borderColor = 0xABFEFE
    el.window = group
    el.bg = background
    el.fg = foreground
    el.text = text
    el.textalign = textalign
    el.textPadding = 1
    el.cb = cb
    el.cb_parm = cb_parm
    table.insert(self.els, el)
    return #self.els
end

function hazeUI:setElement(options)
    index = options.index
    if options.border then self.els[index].border = options.border end
    if options.borderColor then self.els[index].borderColor = options.borderColor end
    if options.textPadding then self.els[index].textPadding = options.textPadding end
    if options.cb then self.els[index].cb = options.cb end
    if options.cb_parm then self.els[index].cb_parm = options.cb_parm end
    if options.text then self.els[index].text = options.text end
    if options.textalign then self.els[index].textalign = options.textalign end
    if options.bg then self.els[index].bg = options.bg end
    if options.fg then self.els[index].fg = options.fg end
    if options.window then self.els[index].window = options.window end
    if options.group then self.els[index].group = options.group end
    if options.x then self.els[index].x = options.x end
    if options.y then self.els[index].y = options.y end
    if options.w then self.els[index].w = options.w end
    if options.h then self.els[index].h = options.h end
end

-- interpret touch event
function hazeUI:touchEvent(x, y, user)
    self.lastTouchUser = user
    for j=1,#self.els do
        local t = self.els[j]
        if t and t.cb then
            if t.window == self.currentScreen or t.window == "all" then
                if t.x <= x and (t.x+t.w-1) >= x and t.y <= y and (t.y+t.h-1) >= y then
                    if type(t.cb) == "function" then return t.cb(t.cb_parm)
                    elseif type(t.cb) == "string" then
                        return self.super[t.cb](self.super, t.cb_parm)
                    end
                end	end end end end

-- remove all buttons which belongs to name
function hazeUI:removeGroup(name)
    for j=1,#self.els do
        if self.els[j].window == name then
            table.remove(self.els, j)
            -- do that recursion to avoid skipping entrys
            return self:removeGroup(name)
        end end end

-- remove all buttons which belongs to name and group
function hazeUI:removeSubGroup(group, name)
    for j=1,#self.els do
        if self.els[j].window == group and self.els[j].group == name then
            table.remove(self.els, j)
            -- do that recursion to avoid skipping entrys
            return self:removeSubGroup(group, name)
        end end end

function hazeUI:list(title, text, list, callback, colorHeader, colorsList, preSelect)
    if colorHeader == nil or not colorHeader then
        colorHeader = {}
        colorHeader.title = { bg = 0x0097FF, fg = 0x282828 }
        colorHeader.text  = { bg = 0xFFDB00, fg = 0x282828 }
    end

    if colorsList == nil or not colorsList then
        colorsList = {}
        table.insert(colorsList, { bg = 0xFFDF00, fg = 0x282828 })
        table.insert(colorsList, { bg = 0xFFA200, fg = 0x282828 })
    end

    self:addButton(2, 3, 70, 1, title, "hazeUI_list", colorHeader.title.fg, colorHeader.title.bg, "left")
    self:addButton(2, 4, 70, 1, text, "hazeUI_list", colorHeader.text.fg, colorHeader.text.bg , "left")
    for i=1,#list do
        local b = self:addButton(2, 6+(2*(i-1)), 70, 2, list[i], "hazeUI_list", colorsList[((i%2)+1)].fg, colorsList[((i%2)+1)].bg, "left",
            function()
                self:flushElements(true)
                callback.f({ value = i, label = list[i], e = callback.p })
            end)

        if preSelect ~= "" and preSelect == list[i] then
            self:setElement({index = b, bg = 0xDADADA})
        end

        os.sleep(0)
    end

    self:drawScreen("hazeUI_list")
end

function hazeUI:textInput(label, callback)
    local term = require("term")

    self:addButton(2, 3, 30, 1, label, "hazeUI_textInput", 0x0, 0xFFA200, "left")
    self:drawScreen("hazeUI_textInput")

    term.setCursor(3, 4)

    callback.f({ value = io.read(), e = callback.p })
end

