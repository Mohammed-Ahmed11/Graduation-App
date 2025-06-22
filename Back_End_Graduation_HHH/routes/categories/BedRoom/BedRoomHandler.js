// === handlers/bedroomHandler.js ===
const { bedroomStatus } = require("../../../server/StateStore");

function handleBedroomData(data) {
  try {
    if (data.buzzer_enabled !== undefined) {
      bedroomStatus.buzzerEnabled = data.buzzer_enabled;
    }

    if (data.buzzer_active !== undefined) {
      bedroomStatus.buzzerActive = data.buzzer_active;
    }

    console.log("[Bedroom] 🔄 Updated from ESP:", bedroomStatus);
  } catch (err) {
    console.error("[Bedroom] Error in data handler:", err.message);
  }
}

module.exports = {
  handleBedroomData,
  bedroomStatus,
};
