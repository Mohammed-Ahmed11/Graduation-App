// const { bedroomStatus } = require("../routes/categories/BedRoom/BedRoomRoutes");

module.exports = {
  kitchenStatus: {
    fire: false,
    mq2: null,
    mq5: null,
    alert: false,
  },

  roofStatus: {
    rainDetected: false,
    alert: false,
  },
  livingRoomStatus: {
    motion: false,
    curtainOpen: false,
    temperature: null,
    fanOn: false,
    tvOn: false,
    emergencyOn: false,
    lightOn: false,
  },
  garageStatus: {
    doorOpen: false,
    motion: false,
    alert: false,
  },

  bedroomStatus: {
    buzzerEnabled: false,
    buzzerActive: false,
  },
  gardenStatus: {},

  corridorStatus: {
    light: false,
    elock: null,
  },

  // Add bedroomStatus, livingRoomStatus, etc.
};
