const express = require("express");
const router = express.Router();

let gardenStatus = {
  soilMoisture: null,
  irrigationOn: false,
};

router.post("/status", async (req, res) => {
  res.send(gardenStatus);
});

router.post("/set", async (req, res) => {
  const { irrigationOn } = req.body;
  gardenStatus.irrigationOn = irrigationOn;

  console.log("[Garden] Devices Set via HTTP:", gardenStatus);
  res.send(gardenStatus);
});

function handleGardenData(data) {
  try {
    const { soilMoisture, irrigationOn } = data;

    gardenStatus = {
      soilMoisture: soilMoisture ?? gardenStatus.soilMoisture,
      irrigationOn: irrigationOn ?? gardenStatus.irrigationOn,
    };

    console.log("[Garden] WebSocket update:", gardenStatus);
  } catch (err) {
    console.error("[Garden] WebSocket error:", err.message);
  }
}

module.exports = router;
module.exports.handleGardenData = handleGardenData;
