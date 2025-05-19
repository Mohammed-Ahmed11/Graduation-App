const express = require("express");
const router = express.Router();

// You can use a database or in-memory object to store latest state
let kitchenStatus = {
  temperature: null,
  electricity: null,
  smartOven: false,
  refigeratorMonitoring: false,
  DishwasherControl: false,
};

//  Http Routes

// Example to get latest kitchen status
router.post("/status", async (req, res) => {
  // const { temp, electricity } = req.body;
  // kitchenStatus.temperature = temp;
  // kitchenStatus.electricity = electricity;

  // console.log("[Kitchen] Status Updated via HTTP:", kitchenStatus);
  res.send({
    temp: kitchenStatus.temperature,
    electricity: kitchenStatus.electricity,
  });
});

router.post("/change", async (req, res) => {
  const { temp, electricity } = req.body;
  kitchenStatus.temperature = temp;
  kitchenStatus.electricity = electricity;

  console.log("[Kitchen] Status Changed via HTTP:", kitchenStatus);
  res.send({ success: true });
});

router.post("/set", async (req, res) => {
  const { smartOven, refigeratorMonitoring, DishwasherControl } = req.body;

  kitchenStatus.smartOven = smartOven;
  kitchenStatus.refigeratorMonitoring = refigeratorMonitoring;
  kitchenStatus.DishwasherControl = DishwasherControl;

  console.log("[Kitchen] Devices Set via HTTP:", kitchenStatus);
  res.send({
    oven: smartOven,
    refigerator: refigeratorMonitoring,
    dishwasher: DishwasherControl,
  });
});

// WebSocket Handling

function handleKitchenData(data) {
  try {
    const {
      temp,
      electricity,
      smartOven,
      refigeratorMonitoring,
      DishwasherControl,
    } = data;

    // You could also store or process this in DB or emit to frontend
    kitchenStatus = {
      temperature: temp ?? kitchenStatus.temperature,
      electricity: electricity ?? kitchenStatus.electricity,
      smartOven: smartOven ?? kitchenStatus.smartOven,
      refigeratorMonitoring:
        refigeratorMonitoring ?? kitchenStatus.refigeratorMonitoring,
      DishwasherControl: DishwasherControl ?? kitchenStatus.DishwasherControl,
    };

    console.log(
      "[Kitchen] Data received from ESP via WebSocket:",
      kitchenStatus
    );
  } catch (err) {
    console.error("[Kitchen] Error handling WebSocket data:", err.message);
  }
}

module.exports = router;
module.exports.handleKitchenData = handleKitchenData;
