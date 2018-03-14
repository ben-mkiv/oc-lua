dP=64209
wakeUpMessage = "WAKETHEFUCKUP"
m=component.proxy(component.list("modem")())
r=component.proxy(component.list("redstone")())
m.open(dP)
m.broadcast(dP,wakeUpMessage)
m.close()
computer.shutdown()
