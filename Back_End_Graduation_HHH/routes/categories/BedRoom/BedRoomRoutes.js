const express = require("express");
const router = express.Router();
const WebSocket = require("ws");
const { espClients } = require("../../../server/weServer");
const { bedroomStatus } = require("../../../server/StateStore");

router.post("/status", (req, res) => {
  res.send(bedroomStatus);
});

router.post("/alarm", (req, res) => {
  const { enable } = req.body;

  if (typeof enable === "boolean") {
    const command = {
      room: "bedroom",
      command: "alarm",
      action: enable ? "on" : "off",
      target: "uno2",
    };

    const esp = espClients.get("Smart-Home-1");
    if (esp && esp.readyState === WebSocket.OPEN) {
      esp.send(JSON.stringify(command));
      res.json({ success: true, message: "Alarm toggled" });
    } else {
      res.status(503).json({ success: false, message: "ESP not connected" });
    }
  } else {
    res.status(400).json({ success: false, message: "Missing 'enable' boolean" });
  }
});

module.exports = router;
