const { startHttpServer } = require("./server/httpServer");
const { startWebSocketServer } = require("./server/weServer");

// Start both servers
startHttpServer();
startWebSocketServer();
