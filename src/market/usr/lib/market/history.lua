function marketGUI:history(fileOffset)
  local marketHistory = require("marketHistory")
  local ser = require("serialization")
  
  self.ui:flushElements(true)
  if not fileOffset or fileOffset == nil then
    marketHistory.load()
  end

  local pages = math.ceil(#marketHistory.files/8)

  if not fileOffset or fileOffset == nil or fileOffset < 0 or fileOffset > #marketHistory.files then
    fileOffset = (pages*8)-8
  end

  local page = 1+math.ceil(fileOffset/8)

  for i=1,#marketHistory.files do
    local fileIndex = fileOffset + i

    if i > 8 or fileIndex > #marketHistory.files then
      break
    end

    fd = io.open("/var/log/"..marketHistory.files[fileIndex], "r")
    local serTradeLog = fd:read("*a")
    fd:close()

    local tradeLog = ser.unserialize(serTradeLog)

    local color = 0x202020

    if tradeLog.cntLeft == 0 then
      color = 0x00EE00
    end

    local bgCol = 0xEEEEEE

    if i%2 == 0 then
      bgCol = 0xCCCCCC
    end

    self.ui:addButton(11, 3+(2*i), 40, 1, tradeLog.offer.label .. " <> " .. tradeLog.price.label, "history", 0x0, bgCol, "left", self.historyShow, "/var/log/"..self.files[fileIndex])
    self.ui:addButton(11, 4+(2*i), 40, 1, tradeLog.user .. " | " .. (tradeLog.cnt-tradeLog.cntLeft) .."/"..tradeLog.cnt, "history", 0x0, bgCol, "left", self.historyShow, "/var/log/"..marketHistory.files[fileIndex])

    self.ui:addButton(3, 3+(2*i), 8, 2, "#"..fileIndex, "history", 0x0, color, "right", self.historyShow, "/var/log/"..marketHistory.files[fileIndex])
  end

  if page > 1 then
    self.ui:addButton(1, 21, 15, 1, "< page "..(page-1), "history", 0x0, 0xFFFFFF, "left", self.history, (fileOffset-8))
  end

  if page < pages then
    self.ui:addButton(16, 21, 15, 1, "page "..(page+1).." >", "history", 0x0, 0xFFFFFF, "left", self.history, (fileOffset+8))
  end

  self.ui:addButton(1, 1, 30, 1, "file count: "..#files, "history", 0x0, 0xFFFFFF, "left")
  self:drawScreen("history")
end

function marketGUI:historyShow(filename)
  local ser = require("serialization")
  fd = io.open(filename, "r")
  local serTradeLog = fd:read("*a")
  fd:close()

  local tradeLog = ser.unserialize(serTradeLog)

  local color = 0x202020

  if tradeLog.cntLeft == 0 then
    color = 0x00EE00
  end

  self.ui:addButton(50, 3, 30, 1, "file: "..filename, "historyShow", 0x0, 0xFFFFFF, "left", self.history)
    self.ui:addButton(50, 4, 30, 1, "o>"..tradeLog.offer.label, "historyShow", 0x0, 0xFFFFFF, "center", self.history)
    self.ui:addButton(50, 5, 30, 1, "p<"..tradeLog.price.label, "historyShow", 0x0, 0xFFFFFF, "center", self.history)
    self.ui:addButton(50, 6, 30, 1, "date: "..tradeLog.date, "historyShow", 0x0, 0xFFFFFF, "left", self.history)
    self.ui:addButton(50, 7, 30, 1, "time: "..tradeLog.time, "historyShow", 0x0, 0xFFFFFF, "left", self.history)
  if tradeLog.userItem then
    self.ui:addButton(50, 8, 30, 1, "userItem: "..tradeLog.userItem.label, "historyShow", 0x0, 0xFFFFFF, "left", self.history)
  else
    self.ui:addButton(50, 8, 30, 1, "userItem: none", "historyShow", 0x0, 0xFFFFFF, "left", self.history)
  end
  self.ui:addButton(50, 9, 30, 1, "username: "..tradeLog.user, "historyShow", 0x0, 0xFFFFFF, "left", self.history)
  self.ui:addButton(50, 10, 30, 1, 'cnt (left): '..tradeLog.cnt..'('..tradeLog.cntLeft..')', "historyShow", 0x0, color, "left", self.history)

  self.ui:addButton(65, 12, 15, 1, "back", "historyShow", 0x0, 0xFFFFFF, "center", self.history)

  self:drawScreen("historyShow")
end
