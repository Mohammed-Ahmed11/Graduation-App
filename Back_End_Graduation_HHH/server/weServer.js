const WebSocket = require("ws");

// 🧠 Room-specific data handlers
const { handleKitchenData } = require("../routes/categories/kitchen/KitchenHandler");
const { handleRoofData } = require("../routes/categories/Roof/RoofHandler");
const { handleGarageData } = require("../routes/categories/Garage/GarageHandler");
const { handleGardenData } = require("../routes/categories/Garden/GardenHandler");
const { handleCorridorData } = require("../routes/categories/Corridor/CorridorHandler");
const { handleLivingRoomData } = require("../routes/categories/LivingRoom/LivingRoomHandler");
const { handleBedroomData } = require("../routes/categories/BedRoom/BedroomHandler");

// 🌐 Connected clients
const espClients = new Map();  // room -> WebSocket
const appClients = new Set();  // Set of Web/App sockets

const roomHandlers = {
  kitchen: handleKitchenData,
  roof: handleRoofData,
  garden: handleGardenData,
  living: handleLivingRoomData,
  corridor: handleCorridorData,
  bedroom: handleBedroomData,
  garage: handleGarageData,
};

const startWebSocketServer = () => {
  const wss = new WebSocket.Server({ port: 8080 });

  wss.on("connection", (ws) => {
    console.log("📡 WebSocket client connected");

    ws.on("message", (message) => {
      let data;
      try {
        data = JSON.parse(message.toString());
      } catch (err) {
        console.error("❌ Invalid JSON from client:", err.message);
        return;
      }

      // === 1. ESP Registration ===
      if (data.type === "esp" && data.Proj) {
        const room = data.Proj;
        espClients.set(room, ws);
        console.log(`🔌 ESP registered from room: ${room}`);
        return;
      }
 
      // === 2. Sensor Data from ESP ===
      for (const [room, handler] of Object.entries(roomHandlers)) {
        if (data[room]) {
          const roomData = data[room];
          console.log(`📥 Received data from ${room}:`, roomData);
          handler(roomData);

          // Forward to app clients
          const forwardPayload = JSON.stringify({ room, ...roomData });
          appClients.forEach((client) => {
            if (client.readyState === WebSocket.OPEN) {
              client.send(forwardPayload);
            }
          });
        }
      }

      // === 3. Command from App to ESP ===
      if (data.command && data.room) {
        const room = data.room.toLowerCase();
        const target = data.target || "esp";

        if (target === "esp") {
          const targetESP = espClients.get(room);
          if (targetESP && targetESP.readyState === WebSocket.OPEN) {
            console.log(`📲 Forwarding command to ESP (${room}):`, data);
            targetESP.send(JSON.stringify(data));
          } else {
            console.warn(`❌ ESP not connected for room ${room}`);
          }
        }
        return;
      }

      // === 4. Fallback: Register as App Client ===
      if (!appClients.has(ws)) {
        appClients.add(ws);
        console.log("📱 Registered new app/web client");
      }
    });

    ws.on("close", () => {
      console.log("🚪 Client disconnected");
      appClients.delete(ws);

      for (const [room, socket] of espClients.entries()) {
        if (socket === ws) {
          espClients.delete(room);
          console.log(`🔌 ESP from ${room} disconnected`);
          break;
        }
      }
    });

    ws.on("error", (err) => {
      console.error("⚠️ WebSocket error:", err.message);
    });
  });

  console.log("✅ WebSocket server listening on port 8080");
};

module.exports = {
  startWebSocketServer,
  espClients,
};
 