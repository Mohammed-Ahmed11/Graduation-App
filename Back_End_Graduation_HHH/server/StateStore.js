const { bedroomStatus } = require("../routes/categories/BedRoom/BedRoomRoutes");

module.exports = {
  kitchenStatus: {
    fire: null,
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
    },
  garageStatus: {
    doorOpen: false,
    motion: false,
    alert: false,
  },

  bedroomStatus:{
    motion: false,
    temperature: null,
    fanOn: false,
    lightOn: false,
    emergencyOn: false,
  },
    gardenStatus: {
        motion: false,
        temperature: null,
        fanOn: false,
        lightOn: false,
        emergencyOn: false,
    },

    corridorStatus:{
        motion: false,
        temperature: null,
        fanOn: false,
        lightOn: false,
        emergencyOn: false,
    },

  // Add bedroomStatus, livingRoomStatus, etc.
};
