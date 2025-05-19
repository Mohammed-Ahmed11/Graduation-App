const express = require("express");
const cors = require("cors");
const db = require("../models");

// Routers
const usersRouter = require("../routes/Users");
const catKitcenRouter = require("../routes/categories/Kitchen");
const catRoofRouter = require("../routes/categories/Roof");
const catGarageRouter = require("../routes/categories/Garage");
const catGardenRouter = require("../routes/categories/Garden");
const catLivingRoomRouter = require("../routes/categories/LivingRoom");
const catBedRoomRouter = require("../routes/categories/BedRoom");

const app = express();

app.use(express.json());
app.use(cors());

// Register routes
app.use("/auth", usersRouter);
app.use("/cat/kitchen", catKitcenRouter);
app.use("/cat/roof", catRoofRouter);
app.use("/cat/garage", catGarageRouter);
app.use("/cat/garden", catGardenRouter);
app.use("/cat/living", catLivingRoomRouter);
app.use("/cat/bed", catBedRoomRouter);

// Sync DB and export server startup function
const startHttpServer = async () => {
  await db.sequelize.sync();
  app.listen(3001, () => {
    console.log("HTTP Server running on port 3001");
  });
};

module.exports = { startHttpServer };
