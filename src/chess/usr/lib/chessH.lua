screens = {}
gpus = {}
projector = {}
fields = {}
statsScreen = false
selectProjector = false
figures = {}
defaultGame = { activePlayer = false, players = { { name = "default", color = 0xFF0000, selectedField = false }, { name = false, color = 0x00FF00, selectedField = false } } }
game = clone(defaultGame)
backgroundColorBoard = 0x222222
function getFigure(type)
    for i=1,#figures do if figures[i].type == type then return figures[i].data; end end
    return false
end
function renderField(p, field)
    if not field.figure then return; end
    renderFillData(p, getFigure(field.figure.type), 17+(field.projectorOffsetX * 16), 17+(field.projectorOffsetY * 16) - 32, field.figure.player)
end
function renderProjector(id)
    projector[id].c.clear()
    for i=1,#projector[id].fields do
        renderField(projector[id].c, fields[projector[id].fields[i]]) end
end
function loadFile(filename)
    if not require("filesystem").exists(filename) then return false; end
    local cf = io.open(filename, "r")
    local serData = cf:read("*a")
    cf:close()
    return require("serialization").unserialize(serData)
end
function getScreenOffsetX(screen)
    if screen == 1 or screen == 3 then
        return 0
    elseif screen == 2 or screen == 4 then
        return -5
    end
    return 0
end
function getScreenOffsetY(screen)
    if screen == 1 or screen == 2 then
        return 0
    elseif screen == 3 or screen == 4 then
        return -5
    end
    return 0
end
function renderFillData(p, data, offsetX, offsetZ, color)
    for s=1,#data do for i=1,#data[s] do p.fill(data[s][i].x + offsetX, data[s][i].z + offsetZ, data[s][i].min, data[s][i].max, color) end end
end
function getScreenIndex(device)
    for s=1,#screens do if screens[s].address == device then
        return s
    end end
    return false
end
function getProjectorIndex(device)
    for p=1,#projector do if projector[p].address == device then
        return p
    end end
    return false
end
function getFieldBackground(x, y, selected)
    if selected then
        return 0xDD0000
    elseif x%2 == 0 and y%2 == 0 or x%2 == 1 and y%2 == 1 then
        return 0x0
    else
        return 0x555555
end end
function drawScreen(i)
    if screens[i].fieldID ~= "stats" then
        screens[i].gpu.setBackground(backgroundColorBoard)
        screens[i].gpu.fill(1, 1, 50, 25, " ")
        screens[i].currentScreen = "fields"
        screens[i]:drawGroup("fields")
    end
end
function drawPattern()
    for i=1,#screens do drawScreen(i) end
end
function setPlayer(data)
    game.players[data.player].name = screens[statsScreen].lastTouchUser
    drawStats()
end
function drawStats()
    screens[statsScreen]:removeGroup("stats")
    if not game.players[1].name or game.players[1].name == "default" then screens[statsScreen]:addButton(1, 1, 24, 2, "set Player", "stats", 0xFFFFFF, 0xAA5555, "center", setPlayer, { player = 1 })
    else screens[statsScreen]:addButton(1, 1, 24, 2, game.players[1].name, "stats", 0xFFFFFF, 0x666666, "center") end
    if not game.players[2].name or game.players[2].name == "default" then screens[statsScreen]:addButton(27, 1, 24, 2, "set Player", "stats", 0xFFFFFF, 0xAA5555, "center", setPlayer, { player = 2 })
    else screens[statsScreen]:addButton(27, 1, 24, 2, game.players[2].name, "stats", 0xFFFFFF, 0x666666, "center") end
    if game.players[1].selectedField then screens[statsScreen]:addButton(1, 3, 24, 3, "selected: " .. game.players[1].selectedField, "stats", 0xFFFFFF, 0x999999, "center") end
    if game.players[2].selectedField then screens[statsScreen]:addButton(27, 3, 24, 3, "selected: " .. game.players[2].selectedField, "stats", 0xFFFFFF, 0x999999, "center") end
    if selectProjector then screens[statsScreen]:addButton(1, 5, 30, 3, "setup Projector #"..getProjectorIndex(selectProjector)..": " .. selectProjector, "stats", 0xFFFFFF, 0xAA5555, "center") end
    screens[statsScreen]:addButton(23, 12, 30, 3, "reset game", "stats", 0xFFFFFF, 0xDADADA, "center", initBoard)
    screens[statsScreen]:drawScreen("stats")
end
function getFieldIndex(x, y)
    for i=1,#fields do
        if fields[i].x == x and fields[i].y == y then
            return i; end end
    return false
end
function initBoard()
    for i=1,#fields do fields[i].figure = false; end
    for x=1,8 do fields[getFieldIndex(x, 2)].figure = { type = "pawn", player = 1 } end
    for x=1,8 do fields[getFieldIndex(x, 7)].figure = { type = "pawn", player = 2 } end
    fields[getFieldIndex(1, 1)].figure = { type = "rock", player = 1 }
    fields[getFieldIndex(8, 1)].figure = { type = "rock", player = 1 }
    fields[getFieldIndex(1, 8)].figure = { type = "rock", player = 2 }
    fields[getFieldIndex(8, 8)].figure = { type = "rock", player = 2 }
    fields[getFieldIndex(2, 1)].figure = { type = "knight", player = 1 }
    fields[getFieldIndex(7, 1)].figure = { type = "knight", player = 1 }
    fields[getFieldIndex(2, 8)].figure = { type = "knight", player = 2 }
    fields[getFieldIndex(7, 8)].figure = { type = "knight", player = 2 }
    fields[getFieldIndex(3, 1)].figure = { type = "bishop", player = 1 }
    fields[getFieldIndex(6, 1)].figure = { type = "bishop", player = 1 }
    fields[getFieldIndex(3, 8)].figure = { type = "bishop", player = 2 }
    fields[getFieldIndex(6, 8)].figure = { type = "bishop", player = 2 }
    fields[getFieldIndex(4, 1)].figure = { type = "queen", player = 1 }
    fields[getFieldIndex(5, 1)].figure = { type = "king", player = 1 }
    fields[getFieldIndex(4, 8)].figure = { type = "king", player = 2 }
    fields[getFieldIndex(5, 8)].figure = { type = "queen", player = 2 }
    for i=1,#projector do renderProjector(i) end
    game = clone(defaultGame)
    drawStats()
end
function setupProjectorCoveredFields(p)
    p.fields = {}
    for x=-1,1 do for y=-1,1 do
        if getFieldIndex(x + fields[p.fieldID].x, y + fields[p.fieldID].y) then
            local id = getFieldIndex(x + fields[p.fieldID].x, y + fields[p.fieldID].y)
            p.fields[#p.fields+1] = id
            fields[id].projector = getProjectorIndex(p.address)
            fields[id].projectorOffsetX = x
            fields[id].projectorOffsetY = y
    end end end
end
function setupProjectorFieldID(id)
    projector[getProjectorIndex(selectProjector)].fieldID = id
    projector[getProjectorIndex(selectProjector)].c.clear()
    setupProjectorCoveredFields(projector[getProjectorIndex(selectProjector)])
    selectProjector = false
    setup()
end
function getPlayerIndex(nick)
    for i=1,#game.players do if game.players[i].name == nick then return i; end end
    return 1
end
function clickField(data)
    if selectProjector then setupProjectorFieldID(data.id); return; end
    local player = getPlayerIndex(screens[fields[data.id].screen].lastTouchUser)
    local moveUnit = false
    local unitMoved = false
    if game.players[player].selectedField then
        moveUnit = game.players[player].selectedField
        screens[fields[game.players[player].selectedField].screen]:setElement({ index = fields[game.players[player].selectedField].el, text = "" })
        drawScreen(fields[game.players[player].selectedField].screen)
    end
    if game.players[player].selectedField == data.id then
        moveUnit = false
        game.players[player].selectedField = false
    else
        game.players[player].selectedField = data.id

        if moveUnit and fields[moveUnit].figure then if not fields[data.id].figure or fields[data.id].figure.player ~= player then
            fields[data.id].figure = fields[moveUnit].figure
            unitMoved = true
            fields[moveUnit].figure = false
            renderProjector(fields[data.id].projector)
            if fields[data.id].projector ~= fields[moveUnit].projector then
                renderProjector(fields[moveUnit].projector)
            end
            moveUnit = false
        end end

        if fields[data.id].figure and fields[data.id].figure.player ~= player then
            game.players[player].selectedField = false
        end

        if unitMoved then
            game.players[player].selectedField = false
        else
            screens[fields[game.players[player].selectedField].screen]:setElement({ index = fields[game.players[player].selectedField].el, text = "o", fg = game.players[player].color })
        end

        drawScreen(fields[game.players[player].selectedField].screen)
    end
    drawStats()
end
function setStatsScreen(data)
    statsScreen = getScreenIndex(data.screen)
    screens[statsScreen].fieldID = "stats"
    setup()
end
function screenSelector(target)
    target:removeGroup("screenSelector")
    target:removeGroup("screenSelectorFinal")
    if screens[getScreenIndex(target.address)].fieldID == nil then
        local draw = { true, true, true, true, true }
        for i=1,#screens do if screens[i].fieldID ~= nil then
            local id = screens[i].fieldID
            if id == "stats" then id = 5 end
            draw[id] = false;
        end end
        if draw[1] then target:addButton(1, 1, 24, 10, "1", "screenSelector", 0x282828, 0xFFB000, "center", setScreenFieldID, { screen = target.address, id = 1 }); end
        if draw[2] then target:addButton(26, 1, 25, 10, "2", "screenSelector", 0x282828, 0xFFBBBB, "center", setScreenFieldID, { screen = target.address, id = 2 }); end
        if draw[3] then target:addButton(1, 12, 24, 10, "3", "screenSelector", 0x282828, 0xAABBBB, "center", setScreenFieldID, { screen = target.address, id = 3 }); end
        if draw[4] then target:addButton(26, 12, 25, 10, "4", "screenSelector", 0x282828, 0xFFBBBB, "center", setScreenFieldID, { screen = target.address, id = 4 }); end
        if draw[5] then target:addButton(1, 23, 50, 3, "stats", "screenSelector", 0x282828, 0xFFBBBB, "center", setStatsScreen, { screen = target.address }); end
        target:drawScreen("screenSelector")
    else
        target:addButton(12, 6, 25, 12, "" .. screens[getScreenIndex(target.address)].fieldID, "screenSelectorFinal", 0xDADADA, 0x282828, "center", setScreenFieldID, { screen = target.address, id = nil })
        target:drawScreen("screenSelectorFinal")
end end
function getScreenByField(x, y)
    if y <= 4 then
        if x <= 4 then return 1
        else return 2
        end
    elseif  x <= 4 then
        return 3
    else
        return 4
end end
function getScreenIndexByField(x, y)
    local id = getScreenByField(x, y)
    for i=1,#screens do if screens[i].fieldID == id then return i
end end end
function initFields()
    fields = {}
    for y=1,8 do for x=1,8 do
        fields[#fields+1] = {}
        fields[#fields].screen = getScreenIndexByField(x, y)
        fields[#fields].bg = getFieldBackground(x, y, false)
        fields[#fields].fg = fields[#fields].bg
        fields[#fields].width = 10
        fields[#fields].height = 5
        fields[#fields].x = x
        fields[#fields].y = y
        fields[#fields].posX = 1 + (getScreenOffsetX(getScreenByField(x, y)) + x) * fields[#fields].width
        fields[#fields].posY = 1 + (getScreenOffsetY(getScreenByField(x, y)) + y) * fields[#fields].height
        fields[#fields].el = screens[fields[#fields].screen]:addButton(fields[#fields].posX, fields[#fields].posY, fields[#fields].width, fields[#fields].height, "", "fields", fields[#fields].bg, fields[#fields].fg, "center", clickField, { id = #fields })
        screens[fields[#fields].screen]:setElement({ index = fields[#fields].el, textPadding = 0 })
    end end
    fields.init = true
    drawPattern()
end
function projectorSelector(target)
    renderFillData(target.c, figures[1].data, 17, -15, 1)
    selectProjector = target.address
    drawStats()
end
function checkSetupScreens()
    for i=1,#screens do
        if screens[i].fieldID == nil then
            return false; end end
    return true
end
function checkSetupProjectors(index)
    if index ~= nil then
        return projector[index].fieldID; end
    for i=1,#projector do
        if not checkSetupProjectors(i) then
            return false; end end
    return true
end
function setup()
    if not checkSetupScreens() then
        for i=1,#screens do screenSelector(screens[i]) end
    elseif not checkSetupProjectors() then
        if not fields.init then initFields() end
        for i=1,#projector do if not checkSetupProjectors(i) then
            projectorSelector(projector[i]); return
        end end
    else
       for i=1,#fields do
           if fields[i].projector == nil then
            print("field not covered by projector "..x..","..y)
            os.sleep(2)
        end end
        drawStats()
end end
function setScreenFieldID(data)
    screens[getScreenIndex(data.screen)].fieldID = data.id
    setup()
end
function initProjectors()
    for address,name in pairs(components.list("hologram")) do
        projector[#projector+1] = {}
        projector[#projector].address = address
        projector[#projector].c = components.proxy(address)
        projector[#projector].c.setPaletteColor(1, 0xFF0000)
        projector[#projector].c.setPaletteColor(2, 0x00FF00)
        projector[#projector].c.setPaletteColor(3, 0x0000FF)
        projector[#projector].c.setTranslation(0, 0.7, 0)
        projector[#projector].c.setScale(0.95)
        projector[#projector].c.clear()
end end
function initScreens()
    for address,name in pairs(components.list("gpu")) do gpus[#gpus+1] = {}; gpus[#gpus].address = address; end
    for address,name in pairs(components.list("screen")) do
        screens[#screens+1] = clone(hazeUI)
        screens[#screens].address = address
        screens[#screens].gpu = components.proxy(gpus[#screens].address)
        screens[#screens].gpu.bind(screens[#screens].address)
        screens[#screens].gpu.setResolution(50, 25)
        screens[#screens].gpu.fill(1, 1, 50, 25, " ")
        screens[#screens].super = screens[#screens]
        screens[#screens].self = screens[#screens]
end end
function initFigures()
    table.insert(figures, { type = "king", data = loadFile("/home/king.3draw") })
    table.insert(figures, { type = "pawn", data = loadFile("/home/pawn.3draw") })
    table.insert(figures, { type = "knight", data = loadFile("/home/knight.3draw") })
    table.insert(figures, { type = "rock", data = loadFile("/home/rock.3draw") })
    table.insert(figures, { type = "bishop", data = loadFile("/home/bishop.3draw") })
    table.insert(figures, { type = "queen", data = loadFile("/home/queen.3draw") })
end
function touchEventHandler(id, device, x, y, button, user)
    screens[getScreenIndex(device)]:touchEvent(x, y, user)
end