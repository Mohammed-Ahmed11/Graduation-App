const express = require("express");
const router = express.Router();
const WebSocket = require("ws");
const { espClients } = require("../../../server/weServer");
const { corridorStatus } = require("../../../server/StateStore");

router.post("/status", (req, res) => {
  res.send(corridorStatus);
});

router.post("/light", (req, res) => {
  const { mode } = req.body;
  const command = {
    room: "corridor",
    command: mode === "auto" ? "light_auto" : mode === "on" ? "light_on" : "light_off",
    target: "uno2",
  };

  const esp = espClients.get("Smart-Home-1");
  if (esp && esp.readyState === WebSocket.OPEN) {
    esp.send(JSON.stringify(command));
    res.json({ success: true, message: `Corridor light set to ${mode}` });
  } else {
    res.status(503).json({ success: false, message: "ESP not connected" });
  }
});

router.post("/elock", (req, res) => {
  const { lock } = req.body;

  if (typeof lock === "boolean") {
    const command = {
      room: "corridor",
      command: lock ? "lock" : "unlock",
      target: "uno2",
    };

    const esp = espClients.get("Smart-Home-1");
    if (esp && esp.readyState === WebSocket.OPEN) {
      esp.send(JSON.stringify(command));
      res.json({ success: true, message: `Door ${lock ? "locked" : "unlocked"}` });
    } else {
      res.status(503).json({ success: false, message: "ESP not connected" });
    }
  } else {
    res.status(400).json({ success: false, message: "Missing 'lock' boolean" });
  }
});

module.exports = router;
