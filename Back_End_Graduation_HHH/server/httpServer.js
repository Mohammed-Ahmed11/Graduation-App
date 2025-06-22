const express = require("express");
const cors = require("cors");
const db = require("../models");

// ✅ Modular route imports
const usersRouter = require("../routes/Users");
const catKitchenRouter = require("../routes/categories/Kitchen/KitchenRoutes");
const catRoofRouter = require("../routes/categories/Roof/RoofRoutes");
const catGarageRouter = require("../routes/categories/Garage/GarageRoutes");
const catCorridorRouter = require("../routes/categories/Corridor/CorridorRoutes");
const catLivingRoomRouter = require("../routes/categories/LivingRoom/LivingRoomRoutes");
const catBedRoomRouter = require("../routes/categories/BedRoom/BedRoomRoutes");
const catGardenRouter = require("../routes/categories/Garden/GardenRoutes");

const app = express();

app.use(express.json());
app.use(cors());

// ✅ Base route health check (optional)
app.get("/", (req, res) => {
  res.send("Smart Home HTTP Server is running.");
});

// ✅ Register all API endpoints
app.use("/auth", usersRouter);
app.use("/cat/kitchen", catKitchenRouter);
app.use("/cat/roof", catRoofRouter);
app.use("/cat/garage", catGarageRouter);
app.use("/cat/living", catLivingRoomRouter);
app.use("/cat/corridor", catCorridorRouter);
app.use("/cat/bedroom", catBedRoomRouter);
app.use("/cat/garden", catBedRoomRouter);

// ✅ Launch and sync database
const startHttpServer = async () => {
  try {
    await db.sequelize.sync();
    app.listen(3001, () => {
      console.log("✅ HTTP Server running on port 3001");
    });
  } catch (err) {
    console.error("❌ Failed to start HTTP server:", err.message);
  }
};

module.exports = { startHttpServer };
