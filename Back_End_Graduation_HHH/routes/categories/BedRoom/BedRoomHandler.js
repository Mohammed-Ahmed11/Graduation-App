const { bedroomStatus } = require("./BedRoomRoutes");

function handleBedRoomData(data) {
  try {
    bedroomStatus.lightOn = data.lightOn ?? bedroomStatus.lightOn;
    bedroomStatus.acOn = data.acOn ?? bedroomStatus.acOn;

    console.log("[Bedroom] 🔄 Updated from ESP:", bedroomStatus);
  } catch (err) {
    console.error("[Bedroom] ❌ Handler Error:", err.message);
  }
}

module.exports = { handleBedRoomData };
