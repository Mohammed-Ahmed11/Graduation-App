const express = require("express");
const router = express.Router();

router.post("/status", async (req, res) => {
  const { temp, electricity } = req.body;
});

router.post("/change", async (req, res) => {
  const { temp, electricity } = req.body;
});

router.post("/set", async (req, res) => {
  const { smartOven, refigeratorMonitoring, DishwasherControl } = req.body;
  res.send({
    oven: smartOven,
    refigerator: refigeratorMonitoring,
    dishwasher: DishwasherControl,
  });
});

module.exports = router;
