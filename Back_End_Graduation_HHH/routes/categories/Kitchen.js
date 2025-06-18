const express = require("express");
const router = express.Router();

let kitchenStatus = {
  fire: null,
  mq2: null,
  mq5: null,
  alert: false,
  smartOven: false,
  refigeratorMonitoring: false,
  DishwasherControl: false,
};

// ===== HTTP API =====
router.post("/status", async (req, res) => {
  res.send({
    fire: kitchenStatus.fire,
    mq2: kitchenStatus.mq2,
    mq5: kitchenStatus.mq5,
    alert: kitchenStatus.alert,
  });
});

router.post("/set", async (req, res) => {
  const { smartOven, refigeratorMonitoring, DishwasherControl } = req.body;

  kitchenStatus.smartOven = smartOven ?? kitchenStatus.smartOven;
  kitchenStatus.refigeratorMonitoring =
    refigeratorMonitoring ?? kitchenStatus.refigeratorMonitoring;
  kitchenStatus.DishwasherControl =
    DishwasherControl ?? kitchenStatus.DishwasherControl;

  console.log("[Kitchen] Devices Set via HTTP:", {
    smartOven,
    refigeratorMonitoring,
    DishwasherControl,
  });

  res.send({
    oven: kitchenStatus.smartOven,
    refigerator: kitchenStatus.refigeratorMonitoring,
    dishwasher: kitchenStatus.DishwasherControl,
  });
});

// ===== WebSocket Data Handler =====
function handleKitchenData(data) {
  try {
    // ✅ No need to check for `data.kitchen`, data *is* the kitchen object now
    const { fire, mq2, mq5, alert } = data;

    kitchenStatus.fire = fire ?? kitchenStatus.fire;
    kitchenStatus.mq2 = mq2 ?? kitchenStatus.mq2;
    kitchenStatus.mq5 = mq5 ?? kitchenStatus.mq5;
    kitchenStatus.alert = alert ?? kitchenStatus.alert;

    console.log("[Kitchen] Updated from ESP:", kitchenStatus);
  } catch (err) {
    console.error("[Kitchen] Error in WebSocket data handler:", err.message);
  }
}

module.exports = router;
module.exports.handleKitchenData = handleKitchenData;
