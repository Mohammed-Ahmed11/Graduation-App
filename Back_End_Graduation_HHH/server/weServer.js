const { WebSocketServer } = require("ws");

// Import handlers
const { handleKitchenData } = require("../routes/categories/Kitchen");
const { handleRoofData } = require("../routes/categories/Roof");
const { handleGarageData } = require("../routes/categories/Garage");
const { handleGardenData } = require("../routes/categories/Garden");
const { handleLivingRoomData } = require("../routes/categories/LivingRoom");
const { handleBedRoomData } = require("../routes/categories/BedRoom");

const startWebSocketServer = () => {
  const wss = new WebSocketServer({ port: 8080 });

  wss.on("connection", (ws) => {
    console.log("ESP device connected");

    ws.on("message", (message) => {
      console.log("Received:", message.toString());

      try {
        const data = JSON.parse(message);
        const room = data.room;

        switch (room) {
          case "kitchen":
            handleKitchenData(data);
            break;
          case "roof":
            handleRoofData(data);
            break;
          case "garage":
            handleGarageData(data);
            break;
          case "garden":
            handleGardenData(data);
            break;
          case "living":
            handleLivingRoomData(data);
            break;
          case "bed":
            handleBedRoomData(data);
            break;
          default:
            console.warn("Unknown room:", room);
        }
      } catch (err) {
        console.error("Invalid JSON from ESP:", err.message);
      }
    });

    ws.on("close", () => {
      console.log("ESP device disconnected");
    });

    ws.on("error", (err) => {
      console.error("WebSocket error:", err.message);
    });
  });

  console.log("WebSocket server listening on port 8080");
};

module.exports = { startWebSocketServer };
