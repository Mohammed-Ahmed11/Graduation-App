const express = require("express");
const router = express.Router();
const WebSocket = require("ws");
const { espClients } = require("../../../server/weServer");
const { kitchenStatus } = require("../../../server/StateStore"); // same instance

// ===== HTTP: Get status =====
router.post("/status", async (req, res) => {
  res.send({
    fire: kitchenStatus.fire,
    mq2: kitchenStatus.mq2,
    mq5: kitchenStatus.mq5,
    alert: kitchenStatus.alert,
  });
});

// ===== HTTP: Set device states =====
router.post("/set", async (req, res) => {
  const { smartOven, refigeratorMonitoring, DishwasherControl } = req.body;

  kitchenStatus.smartOven = smartOven ?? kitchenStatus.smartOven;
  kitchenStatus.refigeratorMonitoring = refigeratorMonitoring ?? kitchenStatus.refigeratorMonitoring;
  kitchenStatus.DishwasherControl = DishwasherControl ?? kitchenStatus.DishwasherControl;

  console.log("[Kitchen] Devices Set via HTTP:", {
    smartOven,
    refigeratorMonitoring,
    DishwasherControl,
  });

  // ✅ Include sensor data + smart device states in response
  res.send({
    fire: kitchenStatus.fire,
    mq2: kitchenStatus.mq2,
    mq5: kitchenStatus.mq5,
    alert: kitchenStatus.alert,
    oven: kitchenStatus.smartOven,
    refigerator: kitchenStatus.refigeratorMonitoring,
    dishwasher: kitchenStatus.DishwasherControl,
  });
});

// ===== HTTP: Trigger Buzzer =====
router.post("/buzzer", async (req, res) => {
  try {
    const targetESP = espClients.get("Smart-Home-1");

    if (targetESP && targetESP.readyState === WebSocket.OPEN) {
      const command = {
        room: "kitchen",
        command: "buzzer",
        action: "on",
        target: "esp",
      };

      targetESP.send(JSON.stringify(command));
      console.log("[Kitchen] 🔊 Sent to ESP:", command);
      res.json({ success: true, message: "Buzzer triggered" });
    } else {
      console.warn("[Kitchen] ❌ ESP not connected");
      res.status(503).json({ success: false, message: "ESP not connected" });
    }
  } catch (err) {
    console.error("[Kitchen] Buzzer error:", err.message);
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
});

module.exports = router;
