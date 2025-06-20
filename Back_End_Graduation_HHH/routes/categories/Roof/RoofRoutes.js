const express = require("express");
const router = express.Router();
const WebSocket = require("ws");
const { espClients } = require("../../../server/weServer");

let roofStatus = require("../../../server/StateStore").roofStatus;
// === 1. Get current roof data ===
router.post("/status", async (req, res) => {
  res.send(roofStatus);
});

// === 2. Update roof state manually (optional control)
router.post("/set", async (req, res) => {
  const { rainDetected, solarPanelStatus } = req.body;

  if (rainDetected !== undefined) roofStatus.rainDetected = rainDetected;
  if (solarPanelStatus !== undefined) roofStatus.solarPanelStatus = solarPanelStatus;

  console.log("[Roof] ✅ Set via HTTP:", roofStatus);
  res.send(roofStatus);
});

// === 3. Reset solar panel via ESP command ===
router.post("/solar-reset", async (req, res) => {
  try {
    const targetESP = espClients.get("Smart-Home-1");

    if (targetESP && targetESP.readyState === WebSocket.OPEN) {
      const command = {
        room: "roof",
        target: "esp",
        command: "solar_reset",
        action: "now",
      };

      targetESP.send(JSON.stringify(command));
      console.log("[Roof] ☀️ Solar panel reset command sent");
      res.json({ success: true, message: "Solar reset command sent" });
    } else {
      res.status(503).json({ success: false, message: "ESP not connected" });
    }
  } catch (err) {
    console.error("[Roof] Solar reset error:", err.message);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

// === 4. Trigger buzzer from app ===
router.post("/buzzer", async (req, res) => {
  try {
    const targetESP = espClients.get("Smart-Home-1");

    if (targetESP && targetESP.readyState === WebSocket.OPEN) {
      const command = {
        room: "roof",
        command: "buzzer",
        action: "on",
        target: "esp",
      };

      targetESP.send(JSON.stringify(command));
      console.log("[Roof] 🔊 Sent buzzer command:", command);
      res.json({ success: true, message: "Buzzer triggered" });
    } else {
      console.warn("[Roof] ❌ ESP not connected");
      res.status(503).json({ success: false, message: "ESP not connected" });
    }
  } catch (err) {
    console.error("[Roof] Buzzer error:", err.message);
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
});

module.exports = router;
module.exports.roofStatus = roofStatus;
