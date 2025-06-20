const express = require("express");
const router = express.Router();
const WebSocket = require("ws");
const { espClients } = require("../../../server/weServer");

let garageStatus = {
  doorOpen: false,
  carInside: false,
};

// === Get Current Garage Status ===
router.post("/status", async (req, res) => {
  res.send(garageStatus);
});

// === Manually Set Garage Devices ===
router.post("/set", async (req, res) => {
  const { doorOpen, carInside } = req.body;

  if (doorOpen !== undefined) garageStatus.doorOpen = doorOpen;
  if (carInside !== undefined) garageStatus.carInside = carInside;

  console.log("[Garage] ✅ Updated via HTTP:", garageStatus);
  res.send(garageStatus);
});

// === Optional: Toggle Garage Door via ESP ===
router.post("/trigger", async (req, res) => {
  try {
    const targetESP = espClients.get("Smart-Home-1");

    if (targetESP && targetESP.readyState === WebSocket.OPEN) {
      const command = {
        room: "garage",
        target: "esp",
        command: req.body.command || "door_toggle",
        action: req.body.action || "toggle"
      };

      targetESP.send(JSON.stringify(command));
      console.log("[Garage] 📲 Command sent:", command);
      res.json({ success: true, message: "Command sent" });
    } else {
      res.status(503).json({ success: false, message: "ESP not connected" });
    }
  } catch (err) {
    console.error("[Garage] Command Error:", err.message);
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
});

module.exports = router;
module.exports.garageStatus = garageStatus;
