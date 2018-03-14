require("marketFunctions")
ser = require("serialization")
filesystem = require("filesystem")
component = require("component")
sides = require("sides")
term = require("term")
colors = require("colors")
require 'hazeUI'

marketGUI = {ui = {}, touchTimer = nil, config = { admin = "Ben85", terminalIndex = nil }, yOffset = 3 }

require 'market/adminStock'
require 'market/adminFunctions'
require 'market/history'
require 'market/importTrades'
require 'market/trade'
require 'market/openTrade'
require 'market/printTrades'
require 'market/adminMenue'


function marketGUI:init(address, gpuAddress, index)
  self.config.terminalIndex = index
  self.ui = clone(hazeUI) 
  self.ui.super = self
  self.ui.config.screen = address
  self.ui.config.gpu = gpuAddress
  self.ui.gpu = require("component").proxy(gpuAddress)
  self.ui.gpu.bind(address)
  self.ui:addButton(4, 1, 74, 1, "╼ Trade-Station ╾", "all", 0x0, 0xFFFFFF, "center", "printTrades")
  self.ui:addButton(4, 2, 74, 1, "", "all", 0x0, 0xEDEDED, "center", "printTrades")
  self.ui:addButton(78, 1, 3, 2, "#", "all", 0xFF9900, 0xFF9900, "left", "adminMenue")
  self.ui:addButton(1, 1, 3, 2, "?", "all", 0x2F2F2F, 0xFF9900, "left", "help")
end

function marketGUI:help()
  self:info({
	  "1.) put your items in the left QSU",
	  "2.) select a trade from the list",
	  "3.) select the amount you want to buy and click checkout"},"How this works")
end

function marketGUI:warning(msgs, title)
  if not title or title == nil then title = "(!) warning" end
  self.ui:addButton(2, 8, 78, 1, title, "warning", 0xEEEEEE, 0x761100, "left", "printTrades")
  self.ui:addButton(2, 9, 78, 1, " ", "warning", 0xEEEEEE, 0xBD2C00, "left", "printTrades")
  for i=1,#msgs do
	self.ui:addButton(2, 10+(-1+i), 78, 1, msgs[i], "warning", 0xEEEEEE, 0x761100, "left", "printTrades")
  end
  
 self.ui:addButton(2, 23, 30, 2, "back", "warning", 0xEEEEEE, 0x5A5A5A, "center", "printTrades")
  
 self.ui:drawScreen('warning')
end


function marketGUI:info(msgs, title)
  if not title or title == nil then title = "(i) info" end
  self.ui:addButton(2, 8, 78, 1, title, "info", 0xEEEEEE, 0x007615, "left", "printTrades")
  self.ui:addButton(2, 9, 78, 1, " ", "info", 0xEEEEEE, 0x00BD70, "left", "printTrades")
  for i=1,#msgs do
	self.ui:addButton(2, 10+(-1+i), 78, 1, msgs[i], "info", 0xEEEEEE, 0x007615, "left", "printTrades")
  end
  self.ui:addButton(2, 23, 30, 2, "back", "info", 0xEEEEEE, 0x5A5A5A, "center", "printTrades")
  
  self.ui:drawScreen('info')
end

