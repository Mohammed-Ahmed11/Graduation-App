const express = require("express");
const router = express.Router();

let garageStatus = {
  doorOpen: false,
  carInside: false,
};

router.post("/status", async (req, res) => {
  res.send(garageStatus);
});

router.post("/set", async (req, res) => {
  const { doorOpen, carInside } = req.body;

  garageStatus.doorOpen = doorOpen;
  garageStatus.carInside = carInside;

  console.log("[Garage] Devices Set via HTTP:", garageStatus);
  res.send(garageStatus);
});

function handleGarageData(data) {
  try {
    const { doorOpen, carInside } = data;

    garageStatus = {
      doorOpen: doorOpen ?? garageStatus.doorOpen,
      carInside: carInside ?? garageStatus.carInside,
    };

    console.log("[Garage] WebSocket update:", garageStatus);
  } catch (err) {
    console.error("[Garage] WebSocket error:", err.message);
  }
}

module.exports = router;
module.exports.handleGarageData = handleGarageData;
