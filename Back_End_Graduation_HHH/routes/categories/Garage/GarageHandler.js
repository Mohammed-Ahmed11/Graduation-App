const { garageStatus } = require("./GarageRoutes");

function handleGarageData(data) {
  try {
    garageStatus.doorOpen = data.doorOpen ?? garageStatus.doorOpen;
    garageStatus.carInside = data.carInside ?? garageStatus.carInside;

    console.log("[Garage] 🔄 Updated from ESP:", garageStatus);
  } catch (err) {
    console.error("[Garage] ❌ Handler Error:", err.message);
  }
}

module.exports = { handleGarageData };
