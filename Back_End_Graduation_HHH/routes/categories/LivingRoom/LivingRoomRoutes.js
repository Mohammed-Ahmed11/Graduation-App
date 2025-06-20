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
    lights,
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

  // === Motion sensor ===
  if (req.body.motion !== undefined) {
    livingRoomStatus.motion = req.body.motion;
    commands.push({
      room: "living",
      target: "uno1",
      command: req.body.motion ? "motion_on" : "motion_off"
    });
  }
  // === Light sensor ===
  if (req.body.lights !== undefined) {
    livingRoomStatus.lightOn = req.body.lights;
    // Use the same command for light on/off
    commands.push({
      room: "living",
      target: "uno1",
      command: req.body.lights ? "light_on" : "light_off"
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
 // === Toggle Emergency ===
router.post("/buzzer", async (req, res) => {
  try {
    const targetESP = espClients.get("Smart-Home-1");

    if (!targetESP || targetESP.readyState !== WebSocket.OPEN) {
      console.warn("[Living] ❌ ESP not connected");
      return res.status(503).json({ success: false, message: "ESP not connected" });
    }

    const newState = !livingRoomStatus.emergencyOn;

    // Update state first
    livingRoomStatus.emergencyOn = newState;

    const command = {
      room: "living",
      target: "uno1",
      command: newState ? "emergency_on" : "emergency_off"
    };

    targetESP.send(JSON.stringify(command));
    console.log(`[Living] 🚨 Emergency ${newState ? "ON" : "OFF"} → Sent to ESP:`, command);

    res.json({
      success: true,
      message: `Emergency ${newState ? "enabled" : "disabled"}`
    });
  } catch (err) {
    console.error("[Living] Emergency error:", err.message);
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
});


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
