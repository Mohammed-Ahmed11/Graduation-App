const WebSocket = require("ws");

// ✅ Correctly import each room’s data handler
const { handleKitchenData } = require("../routes/categories/Kitchen");
const { handleRoofData } = require("../routes/categories/Roof");
const { handleGarageData } = require("../routes/categories/Garage");
const { handleGardenData } = require("../routes/categories/Garden");
const { handleLivingRoomData } = require("../routes/categories/LivingRoom");
const { handleBedRoomData } = require("../routes/categories/Bedroom");

const startWebSocketServer = () => {
  const wss = new WebSocket.Server({ port: 8080 });

  const clients = new Set();        // All WebSocket connections
  const espClients = new Map();     // room -> ESP WebSocket
  const appClients = new Set();     // Set of all app/web clients

  wss.on("connection", (ws) => {
    console.log("Client connected");
    clients.add(ws);

    ws.on("message", (message) => {
      let data;
      try {
        data = JSON.parse(message.toString());
      } catch (err) {
        console.error("Invalid JSON:", err.message);
        return;
      }

      // --- 1. ESP Client Registration ---
      if (data.type === "esp" && data.room) {
        const { room } = data;
        console.log(`ESP registered from room: ${room}`);
        espClients.set(room, ws);
        return;
      }

      // --- 2. Sensor Data from ESP ---
      const roomKeys = ["kitchen", "roof", "garage", "garden", "living", "bed"];
      roomKeys.forEach((room) => {
        if (data[room]) {
          const roomData = data[room];
          console.log(`Received sensor data from ${room}:`, roomData);

          // ✅ Call the correct room handler
          switch (room) {
            case "kitchen":
              handleKitchenData(roomData);
              break;
            case "roof":
              handleRoofData(roomData);
              break;
            case "garage":
              handleGarageData(roomData);
              break;
            case "garden":
              handleGardenData(roomData);
              break;
            case "living":
              handleLivingRoomData(roomData);
              break;
            case "bed":
              handleBedRoomData(roomData);
              break;
          }

          // ✅ Forward data to all app clients, including room name
          const msg = JSON.stringify({ room, ...roomData });
          appClients.forEach((client) => {
            if (client.readyState === WebSocket.OPEN) {
              client.send(msg);
            }
          });
        }
      });

      // --- 3. Command from App to ESP ---
      if (data.command && data.room) {
        const targetEsp = espClients.get(data.room);
        if (targetEsp && targetEsp.readyState === WebSocket.OPEN) {
          console.log(`Forwarding command to ESP in room ${data.room}:`, data);
          targetEsp.send(JSON.stringify(data));
        } else {
          console.warn(`No ESP connected for room ${data.room}`);
        }
        return;
      }

      // --- 4. Default: Register as app client ---
      if (!appClients.has(ws)) {
        appClients.add(ws);
        console.log("Registered new app client");
      }
    });

    ws.on("close", () => {
      console.log("Client disconnected");
      clients.delete(ws);
      appClients.delete(ws);

      for (const [room, socket] of espClients.entries()) {
        if (socket === ws) {
          espClients.delete(room);
          console.log(`ESP from room ${room} disconnected`);
          break;
        }
      }
    });

    ws.on("error", (err) => {
      console.error("WebSocket error:", err.message);
    });
  });

  const sendCommandToESP = (room, payload) => {
  const target = espClients.get(room);
  if (target && target.readyState === WebSocket.OPEN) {
    target.send(JSON.stringify({ room, ...payload }));
  } else {
    console.warn(`[WebSocket] ❌ No ESP connected for room: ${room}`);
  }
};

  console.log("✅ WebSocket server listening on port 8080");
};

module.exports = { startWebSocketServer };
