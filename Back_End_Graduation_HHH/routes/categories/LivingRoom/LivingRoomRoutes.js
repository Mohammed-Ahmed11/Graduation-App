const express = require("express");
const router = express.Router();
const WebSocket = require("ws");
const { espClients } = require("../../../server/weServer");
const { livingRoomStatus } = require("../../../server/StateStore");

// === Get current room state ===
router.post("/status", async (req, res) => {
  res.json(livingRoomStatus);
});

// === Set devices and send commands to ESP ===
router.post("/set", async (req, res) => {
  const {
    curtainOpen,
    fanOn,
    tvOn,
    emergencyOn
  } = req.body;

  const targetESP = espClients.get("Smart-Home-1");

  if (!targetESP || targetESP.readyState !== WebSocket.OPEN) {
    return res.status(503).json({ success: false, message: "ESP not connected" });
  }

  const commands = [];

  // === Curtain ===
  if (curtainOpen !== undefined) {
    livingRoomStatus.curtainOpen = curtainOpen;
    commands.push({
      room: "living",
      target: "uno1",
      command: curtainOpen ? "curtain_open" : "curtain_close"
    });
  }

  // === Fan ===
  if (fanOn !== undefined) {
    livingRoomStatus.fanOn = fanOn;
    commands.push({
      room: "living",
      target: "uno1",
      command: fanOn ? "fan_on" : "fan_off"
    });
  }

  // === TV ===
  if (tvOn !== undefined) {
    livingRoomStatus.tvOn = tvOn;
    commands.push({
      room: "living",
      target: "uno1",
      command: tvOn ? "tv_on" : "tv_off"
    });
  }

  // === Emergency ===
  if (emergencyOn !== undefined) {
    livingRoomStatus.emergencyOn = emergencyOn;
    commands.push({
      room: "living",
      target: "uno1",
      command: emergencyOn ? "emergency_on" : "emergency_off"
    });
  }

  // Send all commands
  commands.forEach(cmd => {
    targetESP.send(JSON.stringify(cmd));
    console.log(`[Living Room] 📤 Sent to ESP:`, cmd);
  });

  console.log("[Living Room] ✅ Updated via HTTP:", livingRoomStatus);
  res.json({ success: true, state: livingRoomStatus });
});

// === Trigger emergency manually (buzzer on ESP) ===
router.post("/emergency", async (req, res) => {
  const targetESP = espClients.get("Smart-Home-1");

  if (!targetESP || targetESP.readyState !== WebSocket.OPEN) {
    return res.status(503).json({ success: false, message: "ESP not connected" });
  }

  const command = {
    room: "living",
    target: "esp",  // buzzer on the ESP itself
    command: "buzzer",
    action: "on"
  };

  targetESP.send(JSON.stringify(command));
  console.log("[Living Room] 🚨 Emergency signal sent to ESP");
  res.json({ success: true, message: "Emergency command sent" });
});

module.exports = router;
