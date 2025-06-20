const {livingRoomStatus} =  require("../../../server/StateStore");

function handleLivingRoomData(data) {
  
  try {
    // `data` here is the `living` object already
    livingRoomStatus.motion = data.motion ?? livingRoomStatus.motion;
    livingRoomStatus.curtainOpen = data.curtainOpen ?? livingRoomStatus.curtainOpen;
    livingRoomStatus.temperature = data.temperature ?? livingRoomStatus.temperature;
    livingRoomStatus.fanOn = data.fanOn ?? livingRoomStatus.fanOn;
    livingRoomStatus.tvOn = data.tvOn ?? livingRoomStatus.tvOn;
    livingRoomStatus.emergencyOn = data.emergencyOn ?? livingRoomStatus.emergencyOn;

    console.log("[Living Room] 🔄 Updated from ESP:", livingRoomStatus);
  } catch (err) {
    console.error("[Living Room] ❌ Handler Error:", err.message);
  }
}
 
module.exports = { handleLivingRoomData };
 