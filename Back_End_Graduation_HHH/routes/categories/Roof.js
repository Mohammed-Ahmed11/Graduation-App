const express = require("express");
const router = express.Router();

let roofStatus = {
  temperature: null,
  rainDetected: false,
  solarPanelStatus: null,
};

router.post("/status", async (req, res) => {
  res.send(roofStatus);
});

router.post("/set", async (req, res) => {
  const { rainDetected, solarPanelStatus } = req.body;

  roofStatus.rainDetected = rainDetected;
  roofStatus.solarPanelStatus = solarPanelStatus;

  console.log("[Roof] Devices Set via HTTP:", roofStatus);
  res.send(roofStatus);
});

function handleRoofData(data) {
  try {
    const { temp, rainDetected, solarPanelStatus } = data;

    roofStatus = {
      temperature: temp ?? roofStatus.temperature,
      rainDetected: rainDetected ?? roofStatus.rainDetected,
      solarPanelStatus: solarPanelStatus ?? roofStatus.solarPanelStatus,
    };

    console.log("[Roof] WebSocket update:", roofStatus);
  } catch (err) {
    console.error("[Roof] WebSocket error:", err.message);
  }
}

module.exports = router;
module.exports.handleRoofData = handleRoofData;
