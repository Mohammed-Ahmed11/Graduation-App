const { gardenStatus } = require("./GardenRoutes");

function handleGardenData(data) {
  try {
    gardenStatus.soilMoisture = data.soilMoisture ?? gardenStatus.soilMoisture;
    gardenStatus.irrigationOn = data.irrigationOn ?? gardenStatus.irrigationOn;

    console.log("[Garden] 🔄 Updated from ESP:", gardenStatus);
  } catch (err) {
    console.error("[Garden] ❌ Handler error:", err.message);
  }
}

module.exports = { handleGardenData };
