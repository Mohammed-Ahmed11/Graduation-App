const { startHttpServer } = require("./server/httpServer");
const { startWebSocketServer } = require("./server/weServer");

startHttpServer();
startWebSocketServer();
