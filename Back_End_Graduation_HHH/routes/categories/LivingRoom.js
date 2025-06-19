const express = require("express");
const router = express.Router();

let livingRoomStatus = {
  motion: false,
  curtainOpen: false,
  temperature: null,
  fanOn: false,
  tvOn: false,
  emergencyOn: false,
};

// === Get full current status ===
router.post("/status", async (req, res) => {
  res.json(livingRoomStatus);
});

// === Set device states (optional manual override) ===
router.post("/set", async (req, res) => {
  const {
    motion,
    curtainOpen,
    temperature,
    fanOn,
    tvOn,
    emergencyOn
  } = req.body;

  // Update values if provided
  if (motion !== undefined) livingRoomStatus.motion = motion;
  if (curtainOpen !== undefined) livingRoomStatus.curtainOpen = curtainOpen;
  if (temperature !== undefined) livingRoomStatus.temperature = temperature;
  if (fanOn !== undefined) livingRoomStatus.fanOn = fanOn;
  if (tvOn !== undefined) livingRoomStatus.tvOn = tvOn;
  if (emergencyOn !== undefined) livingRoomStatus.emergencyOn = emergencyOn;

  console.log("[Living Room] Devices Set via HTTP:", livingRoomStatus);
  res.json(livingRoomStatus);
});

// === Incoming handler for ESP / WebSocket JSON payload ===
function handleLivingRoomData(data) {
  try {
    const roomData = data?.living;

    if (!roomData) throw new Error("Missing 'living' key in data");

    livingRoomStatus = {
      motion: roomData.motion ?? livingRoomStatus.motion,
      curtainOpen: roomData.curtainOpen ?? livingRoomStatus.curtainOpen,
      temperature: roomData.temperature ?? livingRoomStatus.temperature,
      fanOn: roomData.fanOn ?? livingRoomStatus.fanOn,
      tvOn: roomData.tvOn ?? livingRoomStatus.tvOn,
      emergencyOn: roomData.emergencyOn ?? livingRoomStatus.emergencyOn,
    };

    console.log("[Living Room] WebSocket update:", livingRoomStatus);
  } catch (err) {
    console.error("[Living Room] WebSocket error:", err.message);
  }
}

module.exports = router;
module.exports.handleLivingRoomData = handleLivingRoomData;
