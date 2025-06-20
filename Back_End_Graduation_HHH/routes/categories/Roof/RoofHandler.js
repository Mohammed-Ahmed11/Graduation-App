let roofStatus = require("../../../server/StateStore").roofStatus;

function handleRoofData(data) {
  try {
    roofStatus.temperature = data.temperature ?? roofStatus.temperature;
    roofStatus.rainDetected = data.rainDetected ?? roofStatus.rainDetected;
    roofStatus.solarPanelStatus = data.solarPanelStatus ?? roofStatus.solarPanelStatus;

    console.log("[Roof] 🔄 Updated from ESP:", roofStatus);
  } catch (err) {
    console.error("[Roof] ❌ Handler Error:", err.message);
  }
}

module.exports = { handleRoofData };
