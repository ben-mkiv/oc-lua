component = require("component")

fluxgate = false
fluxGateRate = false

function initializeFluxgate()
    fluxgate = component.flux_gate
    fluxGateRate = fluxgate.getSignalLowFlow()
end

initializeFluxgate()