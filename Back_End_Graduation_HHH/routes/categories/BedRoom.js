const express = require("express");
const router = express.Router();

let bedroomStatus = {
  lightOn: false,
  acOn: false,
};

router.post("/status", async (req, res) => {
  res.send(bedroomStatus);
});

router.post("/set", async (req, res) => {
  const { lightOn, acOn } = req.body;

  bedroomStatus.lightOn = lightOn;
  bedroomStatus.acOn = acOn;

  console.log("[Bedroom] Devices Set via HTTP:", bedroomStatus);
  res.send(bedroomStatus);
});

function handleBedRoomData(data) {
  try {
    const { lightOn, acOn } = data;

    bedroomStatus = {
      lightOn: lightOn ?? bedroomStatus.lightOn,
      acOn: acOn ?? bedroomStatus.acOn,
    };

    console.log("[Bedroom] WebSocket update:", bedroomStatus);
  } catch (err) {
    console.error("[Bedroom] WebSocket error:", err.message);
  }
}

module.exports = router;
module.exports.handleBedRoomData = handleBedRoomData;
