// Shared Kitchen state object
const { kitchenStatus } = require("../../../server/StateStore"); // same instance
// WebSocket sensor update handler
function handleKitchenData(data) {
  try {
    const { fire, mq2, mq5, alert } = data;

    if (fire !== undefined) kitchenStatus.fire = fire;
    if (mq2 !== undefined) kitchenStatus.mq2 = mq2;
    if (mq5 !== undefined) kitchenStatus.mq5 = mq5;
    if (alert !== undefined) kitchenStatus.alert = alert;

    console.log("[Kitchen] 🔄 Updated from ESP:", kitchenStatus);
  } catch (err) {
    console.error("[Kitchen] Error in data handler:", err.message);
  }
}


module.exports = {
  handleKitchenData,
  kitchenStatus, // exported so routes can read/write this
};
