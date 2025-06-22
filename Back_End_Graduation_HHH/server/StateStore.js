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
    motion: true,
    alert: false,
  },

  bedroomStatus: {
    buzzerEnabled: false,
    buzzerActive: false,
  },
  gardenStatus: {
    soilMoisture: null,
    irrigationOn: false,
  },

  corridorStatus: {
    light: false,
    elock: false,
  },
};
