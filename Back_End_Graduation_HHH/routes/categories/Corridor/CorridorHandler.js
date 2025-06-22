// === handlers/corridorHandler.js ===
const { corridorStatus } = require("../../../server/StateStore");

function handleCorridorData(data) {
  try {
    if (data.light !== undefined) corridorStatus.light = data.light;

    if (data.elock !== undefined) {
      corridorStatus.elock = data.elock === "locked"; // convert to boolean
    }

    console.log("[Corridor] 🔄 Updated from ESP:", corridorStatus);
  } catch (err) {
    console.error("[Corridor] Error in data handler:", err.message);
  }
}


module.exports = {
  handleCorridorData,
  corridorStatus,
};
