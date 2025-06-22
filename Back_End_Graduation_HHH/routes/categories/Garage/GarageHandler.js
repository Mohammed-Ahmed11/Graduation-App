// === handlers/garageHandler.js ===
const { garageStatus } = require("../../../server/StateStore");

function handleGarageData(data) {
  try {
    const { garage_door } = data;

    if (garage_door !== undefined) garageStatus.door = garage_door;

    console.log("[Garage] 🔄 Updated from ESP:", garageStatus);
  } catch (err) {
    console.error("[Garage] Error in data handler:", err.message);
  }
}

module.exports = {
  handleGarageData,
  garageStatus,
};
