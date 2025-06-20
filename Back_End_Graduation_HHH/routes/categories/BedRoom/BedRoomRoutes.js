const express = require("express");
const router = express.Router();
const WebSocket = require("ws");
const { espClients } = require("../../../server/weServer");

let bedroomStatus = {
  lightOn: false,
  acOn: false,
};

// === Get Bedroom Status ===
router.post("/status", async (req, res) => {
  res.send(bedroomStatus);
});

// === Manually Control Bedroom Devices ===
router.post("/set", async (req, res) => {
  const { lightOn, acOn } = req.body;

  if (lightOn !== undefined) bedroomStatus.lightOn = lightOn;
  if (acOn !== undefined) bedroomStatus.acOn = acOn;

  console.log("[Bedroom] ✅ Updated via HTTP:", bedroomStatus);
  res.send(bedroomStatus);
});
 
// === Optional: Trigger AC or Light via ESP ===
router.post("/trigger", async (req, res) => {
  try {
    const targetESP = espClients.get("Smart-Home-1");

    if (targetESP && targetESP.readyState === WebSocket.OPEN) {
      const command = {
        room: "bed",
        target: "esp",
        command: req.body.command,  // e.g. "light_toggle", "ac_toggle"
        action: req.body.action || "toggle"
      };

      targetESP.send(JSON.stringify(command));
      console.log("[Bedroom] 📲 Command sent:", command);
      res.json({ success: true, message: "Command sent" });
    } else {
      res.status(503).json({ success: false, message: "ESP not connected" });
    }
  } catch (err) {
    console.error("[Bedroom] Command Error:", err.message);
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
});

module.exports = router;
module.exports.bedroomStatus = bedroomStatus;
