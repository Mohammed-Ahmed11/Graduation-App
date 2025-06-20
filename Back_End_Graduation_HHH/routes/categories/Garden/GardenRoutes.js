const express = require("express");
const router = express.Router();
const WebSocket = require("ws");
const { espClients } = require("../../../server/weServer");

let gardenStatus = {
  soilMoisture: null,
  irrigationOn: false,
};

// === Get Current Garden Status ===
router.post("/status", async (req, res) => {
  res.send(gardenStatus);
});

// === Manually Set Irrigation On/Off ===
router.post("/set", async (req, res) => {
  const { irrigationOn } = req.body;
  if (irrigationOn !== undefined) {
    gardenStatus.irrigationOn = irrigationOn;
  }

  console.log("[Garden] ✅ Updated via HTTP:", gardenStatus);
  res.send(gardenStatus);
});

// === Optional: Trigger ESP Irrigation Command ===
router.post("/trigger", async (req, res) => {
  try {
    const targetESP = espClients.get("Smart-Home-1");

    if (targetESP && targetESP.readyState === WebSocket.OPEN) {
      const command = {
        room: "garden",
        target: "esp",
        command: req.body.command || "irrigation_toggle",
        action: req.body.action || "toggle",
      };

      targetESP.send(JSON.stringify(command));
      console.log("[Garden] 📲 Command sent:", command);
      res.json({ success: true, message: "Command sent" });
    } else {
      res.status(503).json({ success: false, message: "ESP not connected" });
    }
  } catch (err) {
    console.error("[Garden] ❌ Trigger error:", err.message);
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
});

module.exports = router;
module.exports.gardenStatus = gardenStatus;
