const express = require("express");
const router = express.Router();
const WebSocket = require("ws");
const { espClients } = require("../../../server/weServer");
const { garageStatus } = require("../../../server/StateStore");

// === Get current garage door status ===
router.post("/status", (req, res) => {
  res.send(garageStatus);
});

// === Open garage door ===
router.post("/open", (req, res) => {
  const esp = espClients.get("Smart-Home-1");

  if (esp && esp.readyState === WebSocket.OPEN) {
    const command = {
      room: "garage",
      command: "open_garage",
      target: "uno2",
    };
    esp.send(JSON.stringify(command));
    console.log("[Garage] 🚪 Open command sent");
    res.json({ success: true, message: "Garage door opened" });
  } else {
    res.status(503).json({ success: false, message: "ESP not connected" });
  }
});

module.exports = router;
