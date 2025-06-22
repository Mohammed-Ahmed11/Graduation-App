// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';

// // void main() {
// //   runApp(VoiceControlApp());
// // }

// class VoiceControlApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'التحكم الصوتي في المنزل',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: HomeControlScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class ApiService {
//   static const String baseUrl = 'http://192.168.1.6:3000/api';
  
//   static Future<Map<String, dynamic>> getAllDevices() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/devices'));
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       }
//       throw Exception('Failed to load devices');
//     } catch (e) {
//       print('Error getting devices: $e');
//       return {'success': false, 'devices': {}};
//     }
//   }
  
//   static Future<Map<String, dynamic>> updateDevice(String deviceId, String action) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/devices/$deviceId'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'action': action}),
//       );
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       }
//       throw Exception('Failed to update device');
//     } catch (e) {
//       print('Error updating device: $e');
//       return {'success': false};
//     }
//   }
// }

// class Device {
//   final String id;
//   final String name;
//   final String type;
//   bool isOn;
//   final List<String> keywords;

//   Device({
//     required this.id,
//     required this.name,
//     required this.type,
//     this.isOn = false,
//     required this.keywords,
//   });
// }

// class Room {
//   final String id;
//   final String name;
//   final List<String> keywords;
//   final List<Device> devices;

//   Room({
//     required this.id,
//     required this.name,
//     required this.keywords,
//     required this.devices,
//   });
// }

// class VoiceCommand {
//   final String action;
//   final List<String> keywords;

//   VoiceCommand({required this.action, required this.keywords});
// }

// class HomeControlScreen extends StatefulWidget {
//   @override
//   _HomeControlScreenState createState() => _HomeControlScreenState();
// }

// class _HomeControlScreenState extends State<HomeControlScreen> {
//   late stt.SpeechToText _speech;
//   late FlutterTts _flutterTts;
//   bool _isListening = false;
//   bool _continuousListening = false;
//   String _text = 'اضغط على الميكروفون وقل الأمر';
//   String _lastCommand = '';
//   String _commandResult = '';
//   bool _isConnected = false;
//   Timer? _syncTimer;

//   List<Room> rooms = [
//     Room(
//       id: 'bedroom',
//       name: 'غرفة النوم',
//       keywords: ['غرفة النوم', 'النوم', 'الغرفة', 'الاودة'],
//       devices: [
//         Device(id: 'bedroom_light', name: 'نور غرفة النوم', type: 'light', keywords: ['نور', 'ضوء', 'لمبة', 'اضاءة']),
//         Device(id: 'bedroom_fan', name: 'مروحة غرفة النوم', type: 'fan', keywords: ['مروحه','مروحة', 'مراوح', 'هواء']),
//         Device(id: 'bedroom_ac', name: 'تكييف غرفة النوم', type: 'ac', keywords: ['تكييف', 'مكيف', 'تبريد']),
//       ],
//     ),
//     Room(
//       id: 'kitchen',
//       name: 'المطبخ',
//       keywords: ['المطبخ', 'مطبخ', 'الطبخ'],
//       devices: [
//         Device(id: 'kitchen_light', name: 'نور المطبخ', type: 'light', keywords: ['نور', 'ضوء', 'لمبة', 'اضاءة']),
//         Device(id: 'kitchen_fan', name: 'مروحة المطبخ', type: 'fan', keywords: ['مروحه','مروحة', 'شفاط', 'هواء']),
//         Device(id: 'kitchen_microwave', name: 'الميكروويف', type: 'microwave', keywords: ['ميكروويف', 'فرن', 'تسخين']),
//       ],
//     ),
//     Room(
//       id: 'living_room',
//       name: 'الصالة',
//       keywords: ['الصاله', 'صاله', 'الريسيبشن', 'غرفة المعيشة'],
//       devices: [
//         Device(id: 'living_light', name: 'نور الصالة', type: 'light', keywords: ['نور', 'ضوء', 'لمبة', 'اضاءة']),
//         Device(id: 'living_tv', name: 'التليفزيون', type: 'tv', keywords: ['تليفزيون', 'تلفزيون', 'تي في', 'شاشة']),
//         Device(id: 'living_ac', name: 'تكييف الصالة', type: 'ac', keywords: ['تكييف', 'مكيف', 'تبريد']),
//       ],
//     ),
//     Room(
//       id: 'bathroom',
//       name: 'الحمام',
//       keywords: ['الحمام', 'حمام', 'دورة المياه'],
//       devices: [
//         Device(id: 'bathroom_light', name: 'نور الحمام', type: 'light', keywords: ['نور', 'ضوء', 'لمبة', 'اضاءة']),
//         Device(id: 'bathroom_fan', name: 'شفاط الحمام', type: 'fan', keywords: ['مروحة','شفاط', 'هواء']),
//       ],
//     ),
//   ];

//   List<VoiceCommand> commands = [
//     VoiceCommand(action: 'turn_on', keywords: ['شغل', 'افتح', 'اشغل', 'ولع']),
//     VoiceCommand(action: 'turn_off', keywords: ['اقفل', 'اطفي', 'اطفئ', 'سكر']),
//     VoiceCommand(action: 'stop', keywords: ['وقف', 'استوب', 'توقف']),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _flutterTts = FlutterTts();
//     _initializeSpeech();
//     _initializeTts();
//     _startPeriodicSync();
//   }

//   void _initializeSpeech() async {
//     var status = await Permission.microphone.request();
//     print('Microphone permission status: $status');
    
//     bool available = await _speech.initialize(
//       onStatus: (val) {
//         print('Speech status: $val');
//         setState(() {
//           if (val == 'done' || val == 'notListening') {
//             _isListening = false;
//           } else if (val == 'listening') {
//             _isListening = true;
//           }
//         });
        
//         if (val == 'done' && _continuousListening) {
//           Future.delayed(Duration(milliseconds: 500), () {
//             if (_continuousListening && !_isListening) {
//               _startListening();
//             }
//           });
//         }
//       },
//       onError: (val) {
//         print('Speech error: $val');
//         setState(() => _isListening = false);
//         if (_continuousListening) {
//           Future.delayed(Duration(milliseconds: 1000), () {
//             if (_continuousListening && !_isListening) {
//               _startListening();
//             }
//           });
//         }
//       },
//       debugLogging: true,
//     );

//     if (!available) {
//       setState(() {
//         _text = 'خطأ في تهيئة الميكروفون - تأكد من الصلاحيات';
//       });
//       print('Speech recognition not available');
//     } else {
//       print('Speech recognition initialized successfully');
//     }
//   }

//   void _initializeTts() async {
//     await _flutterTts.setLanguage('ar-SA');
//     await _flutterTts.setPitch(1.0);
//     await _flutterTts.setSpeechRate(0.7);
//   }

//   void _speak(String text) async {
//     await _flutterTts.speak(text);
//   }

//   void _startPeriodicSync() {
//     _syncTimer = Timer.periodic(Duration(seconds: 10), (timer) {
//       // Just check connection status
//       ApiService.getAllDevices().then((result) {
//         setState(() {
//           _isConnected = result['success'];
//         });
//       });
//     });
//   }

//   void _toggleListening() async {
//     if (!_continuousListening) {
//       setState(() {
//         _continuousListening = true;
//         _text = 'الاستماع المستمر مفعل - قل الأمر';
//         _commandResult = '';
//       });
//       _startListening();
//     } else {
//       setState(() {
//         _continuousListening = false;
//         _isListening = false;
//         _text = 'تم إيقاف الاستماع';
//         _commandResult = '';
//       });
//       await _speech.stop();
//     }
//   }

//   void _startListening() async {
//     if (_continuousListening && !_isListening) {
//       print('Starting to listen...');
//       bool available = await _speech.initialize();
//       if (available) {
//         await _speech.listen(
//           onResult: (val) {
//             setState(() => _text = val.recognizedWords);
//             print('Recognized: ${val.recognizedWords}');
//             if (val.finalResult && val.recognizedWords.isNotEmpty) {
//               if (_lastCommand != val.recognizedWords) {
//                 _processVoiceCommand(val.recognizedWords);
//               }
//             }
//           },
//           localeId: 'ar-SA',
//           pauseFor: Duration(seconds: 3),
//           listenFor: Duration(seconds: 8),
//           partialResults: true,
//         );
//       } else {
//         print('Speech recognition not available for listening');
//       }
//     }
//   }

//   void _processVoiceCommand(String command) {
//     setState(() => _lastCommand = command);
//     print('Processing command: $command');

//     String normalizedCommand = command.toLowerCase().trim();
//     String? action;

//     // Find action
//     for (VoiceCommand cmd in commands) {
//       for (String keyword in cmd.keywords) {
//         if (normalizedCommand.contains(keyword)) {
//           action = cmd.action;
//           break;
//         }
//       }
//       if (action != null) break;
//     }

//     if (action == null) {
//       _commandResult = 'لم يتم التعرف على الأمر';
//       _speak(_commandResult);
//       setState(() {});
//       return;
//     }

//     // Find room
//     Room? targetRoom;
//     for (Room room in rooms) {
//       for (String keyword in room.keywords) {
//         if (normalizedCommand.contains(keyword)) {
//           targetRoom = room;
//           break;
//         }
//       }
//       if (targetRoom != null) break;
//     }

//     // Find device
//     Device? targetDevice;
//     if (targetRoom != null) {
//       for (Device device in targetRoom.devices) {
//         for (String keyword in device.keywords) {
//           if (normalizedCommand.contains(keyword)) {
//             targetDevice = device;
//             break;
//           }
//         }
//         if (targetDevice != null) break;
//       }
//     } else {
//       // Search all rooms for device
//       for (Room room in rooms) {
//         for (Device device in room.devices) {
//           for (String keyword in device.keywords) {
//             if (normalizedCommand.contains(keyword)) {
//               targetDevice = device;
//               targetRoom = room;
//               break;
//             }
//           }
//           if (targetDevice != null) break;
//         }
//         if (targetDevice != null) break;
//       }
//     }

//     if (targetDevice != null) {
//       _sendCommandToServer(targetDevice, action);
//     } else {
//       _commandResult = 'لم يتم العثور على الجهاز المطلوب';
//       _speak(_commandResult);
//       setState(() {});
//     }
//   }

//   void _sendCommandToServer(Device device, String action) async {
//     print('Sending command $action to ${device.name}');
//     final result = await ApiService.updateDevice(device.id, action);
//     if (result['success']) {
//       setState(() {
//         _commandResult = action == 'turn_on' ? 'تم تشغيل ${device.name}' : 'تم إيقاف ${device.name}';
//       });
//       _speak(_commandResult);
//       print('Server response: ${result['message']}');
//     } else {
//       setState(() {
//         _commandResult = 'خطأ في الاتصال بالخادم';
//       });
//       _speak(_commandResult);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0d1017),
//       appBar: AppBar(
//         title: Text('HUB HOME HYPER'),
//         backgroundColor: const Color(0xFF2879fe),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           Container(
//             margin: EdgeInsets.only(right: 16),
//             child: Row(
//               children: [
//                 Icon(
//                   _isConnected ? Icons.cloud_done : Icons.cloud_off,
//                   color: _isConnected ? Colors.green : Colors.red,
//                 ),
//                 SizedBox(width: 4),
//                 Text(
//                   _isConnected ? 'متصل' : 'غير متصل',
//                   style: TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: Center(
//         child: Container(
//           margin: EdgeInsets.all(20),
//           padding: EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: const Color(0xFF2879fe),
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 10,
//                 offset: Offset(0, 5),)
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Microphone button
//               GestureDetector(
//                 onTap: _toggleListening,
//                 child: Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: _continuousListening ? Colors.red : Colors.green,
//                     boxShadow: [
//                       BoxShadow(
//                         color: (_continuousListening ? Colors.red : Colors.blue).withOpacity(0.3),
//                         blurRadius: 20,
//                         offset: Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     _continuousListening ? Icons.mic_off : Icons.mic,
//                     size: 50,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
              
//               // Status text
//               Text(
//                 _continuousListening ? 'إيقاف الاستماع' : 'بدء الاستماع',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: _continuousListening ? Colors.red : Colors.white,
//                 ),
//               ),
//               SizedBox(height: 16),
              
//               // Listening indicator
//               if (_isListening)
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.green[100],
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         'جاري الاستماع...',
//                         style: TextStyle(
//                           color: Colors.green[800],
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
              
//               SizedBox(height: 20),
              
//               // Command display
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[50],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'الأمر المسموع:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       _text,
//                       style: TextStyle(fontSize: 16),
//                       textAlign: TextAlign.center,
//                     ),
//                     if (_lastCommand.isNotEmpty) ...[
//                       SizedBox(height: 12),
//                       Text(
//                         'آخر أمر: $_lastCommand',
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
              
//               // Command result
//               if (_commandResult.isNotEmpty) ...[
//                 SizedBox(height: 16),
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: _commandResult.contains('تم') ? Colors.green[50] : Colors.red[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: _commandResult.contains('تم') ? Colors.green[200]! : Colors.red[200]!,
//                     ),
//                   ),
//                   child: Text(
//                     _commandResult,
//                     style: TextStyle(
//                       color: _commandResult.contains('تم') ? Colors.green[800] : Colors.red[800],
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _syncTimer?.cancel();
//     _speech.stop();
//     _flutterTts.stop();
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(VoiceControlApp());
}

class VoiceControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Home Control',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeControlScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
       // GlobalWidgetLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      locale: Locale('ar', 'SA'), // Default language
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://192.168.81.154:3001/cat'; // Updated to match your existing servers

  // Add timeout for all requests
  static const Duration timeoutDuration = Duration(seconds: 5);

  // Corridor API calls
  static Future<Map<String, dynamic>> getCorridorStatus() async {
    try {
      print('🔄 Checking corridor status...');
      final response = await http.post(
        Uri.parse('$baseUrl/corridor/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);
      
      print('📡 Corridor status response: ${response.statusCode}');
      print('📡 Corridor status body: ${response.body}');
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      throw Exception('Failed to load corridor status - Status: ${response.statusCode}');
    } catch (e) {
      print('❌ Error getting corridor status: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> controlCorridorLight(String mode) async {
    try {
      print('💡 Controlling corridor light: $mode');
      final response = await http.post(
        Uri.parse('$baseUrl/corridor/light'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mode': mode}),
      ).timeout(timeoutDuration);
      
      print('📡 Light control response: ${response.statusCode}');
      print('📡 Light control body: ${response.body}');
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Light $mode successfully'};
      }
      throw Exception('Failed to control light - Status: ${response.statusCode}');
    } catch (e) {
      print('❌ Error controlling corridor light: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> controlCorridorLock(bool lock) async {
    try {
      print('🔒 Controlling corridor lock: ${lock ? 'lock' : 'unlock'}');
      final response = await http.post(
        Uri.parse('$baseUrl/corridor/elock'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'lock': lock}),
      ).timeout(timeoutDuration);
      
      print('📡 Lock control response: ${response.statusCode}');
      print('📡 Lock control body: ${response.body}');
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'E-lock ${lock ? 'locked' : 'unlocked'} successfully'};
      }
      throw Exception('Failed to control lock - Status: ${response.statusCode}');
    } catch (e) {
      print('❌ Error controlling corridor lock: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Garage API calls
  static Future<Map<String, dynamic>> getGarageStatus() async {
    try {
      print('🔄 Checking garage status...');
      final response = await http.post(
        Uri.parse('$baseUrl/garage/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);
      
      print('📡 Garage status response: ${response.statusCode}');
      print('📡 Garage status body: ${response.body}');
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      throw Exception('Failed to load garage status - Status: ${response.statusCode}');
    } catch (e) {
      print('❌ Error getting garage status: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> triggerGarageBuzzer() async {
    try {
      print('🔔 Triggering garage buzzer...');
      final response = await http.post(
        Uri.parse('$baseUrl/garage/buzzer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': 'on'}),
      ).timeout(timeoutDuration);
      
      print('📡 Buzzer response: ${response.statusCode}');
      print('📡 Buzzer body: ${response.body}');
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Buzzer triggered successfully'};
      }
      throw Exception('Failed to trigger buzzer - Status: ${response.statusCode}');
    } catch (e) {
      print('❌ Error triggering garage buzzer: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> openGarageDoor() async {
    try {
      print('🚪 Opening garage door...');
      final response = await http.post(
        Uri.parse('$baseUrl/garage/open'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeoutDuration);
      
      print('📡 Door response: ${response.statusCode}');
      print('📡 Door body: ${response.body}');
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Garage door opened successfully'};
      }
      throw Exception('Failed to open garage door - Status: ${response.statusCode}');
    } catch (e) {
      print('❌ Error opening garage door: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Test connection method
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing server connection...');
      final corridorResult = await getCorridorStatus();
      if (corridorResult['success']) {
        print('✅ Corridor server is reachable');
        return true;
      }
      
      final garageResult = await getGarageStatus();
      if (garageResult['success']) {
        print('✅ Garage server is reachable');
        return true;
      }
      
      print('❌ Both servers are unreachable');
      return false;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }
}

class Device {
  final String id;
  final String nameAr;
  final String nameEn;
  final String type;
  final String action; // New field for specific actions
  bool isOn;
  final List<String> keywordsAr;
  final List<String> keywordsEn;

  Device({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.type,
    required this.action,
    this.isOn = false,
    required this.keywordsAr,
    required this.keywordsEn,
  });
}

class Room {
  final String id;
  final String nameAr;
  final String nameEn;
  final List<String> keywordsAr;
  final List<String> keywordsEn;
  final List<Device> devices;

  Room({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.keywordsAr,
    required this.keywordsEn,
    required this.devices,
  });
}

class VoiceCommand {
  final String action;
  final List<String> keywordsAr;
  final List<String> keywordsEn;

  VoiceCommand({
    required this.action,
    required this.keywordsAr,
    required this.keywordsEn,
  });
}

class HomeControlScreen extends StatefulWidget {
  @override
  _HomeControlScreenState createState() => _HomeControlScreenState();
}

class _HomeControlScreenState extends State<HomeControlScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _continuousListening = false;
  String _text = 'اضغط على الميكروفون وقل الأمر';
  String _lastCommand = '';
  String _commandResult = '';
  bool _isConnected = false;
  Timer? _syncTimer;
  String _selectedLocale = 'ar-SA'; // Default language
  String _connectionError = '';

  List<Room> rooms = [
    // Corridor Room
    Room(
      id: 'corridor',
      nameAr: 'الممر',
      nameEn: 'Corridor',
      keywordsAr: ['الممر', 'ممر', 'الطرقة', 'الدهليز'],
      keywordsEn: ['corridor', 'hallway', 'passage'],
      devices: [
        Device(
          id: 'corridor_light',
          nameAr: 'إضاءة الممر',
          nameEn: 'Corridor Light',
          type: 'light',
          action: 'light',
          keywordsAr: ['إضاءة', 'نور', 'أنوار', 'لمبة', 'الضوء', 'ضوء الممر'],
          keywordsEn: ['light', 'lamp', 'illumination', 'lighting', 'corridor light'],
        ),
        Device(
          id: 'corridor_elock',
          nameAr: 'القفل الإلكتروني',
          nameEn: 'Electronic Lock',
          type: 'lock',
          action: 'elock',
          keywordsAr: ['قفل', 'القفل', 'قفل إلكتروني', 'إلكتروني', 'الباب', 'قفل الباب'],
          keywordsEn: ['lock', 'electronic lock', 'elock', 'door lock', 'smart lock'],
        ),
      ],
    ),
    // Garage Room
    Room(
      id: 'garage',
      nameAr: 'الجراج',
      nameEn: 'Garage',
      keywordsAr: ['الجراج', 'الكراج', 'الموقف', 'موقف السيارات', 'جراج'],
      keywordsEn: ['garage', 'parking', 'car space'],
      devices: [
        Device(
          id: 'garage_door',
          nameAr: 'باب الجراج',
          nameEn: 'Garage Door',
          type: 'door',
          action: 'door',
          keywordsAr: ['باب', 'الباب', 'باب الجراج', 'فتح الباب'],
          keywordsEn: ['door', 'garage door', 'open door'],
        ),
        Device(
          id: 'garage_buzzer',
          nameAr: 'جرس الجراج',
          nameEn: 'Garage Buzzer',
          type: 'buzzer',
          action: 'buzzer',
          keywordsAr: ['جرس', 'الجرس', 'بزر', 'تنبيه', 'صوت', 'منبه'],
          keywordsEn: ['buzzer', 'alarm', 'bell', 'sound', 'alert'],
        ),
      ],
    ),
    // Keep existing rooms
    Room(
      id: 'living_room',
      nameAr: 'غرفة المعيشة',
      nameEn: 'Living Room',
      keywordsAr: ['غرفة المعيشة', 'الصالة', 'صاله', 'الريسيبشن', 'الانتريه'],
      keywordsEn: ['living room', 'sitting room', 'lounge', 'reception'],
      devices: [
        Device(
          id: 'living_light',
          nameAr: 'إضاءة غرفة المعيشة',
          nameEn: 'Living Room Light',
          type: 'light',
          action: 'general',
          keywordsAr: ['إضاءة', 'نور', 'أنوار', 'لمبة', 'الضوء', 'ضوء الغرفة'],
          keywordsEn: ['light', 'lamp', 'illumination', 'lighting', 'room light'],
        ),
      ],
    ),
  ];

  List<VoiceCommand> commands = [
    VoiceCommand(
      action: 'turn_on',
      keywordsAr: ['شغل', 'افتح', 'اشغل', 'ولع', 'فعل'],
      keywordsEn: ['turn on', 'open', 'start', 'activate'],
    ),
    VoiceCommand(
      action: 'turn_off',
      keywordsAr: ['اقفل', 'اطفي', 'اطفئ', 'سكر', 'أوقف'],
      keywordsEn: ['turn off', 'close', 'stop', 'deactivate'],
    ),
    VoiceCommand(
      action: 'lock',
      keywordsAr: ['اقفل', 'قفل', 'أمن', 'احمِ'],
      keywordsEn: ['lock', 'secure', 'close'],
    ),
    VoiceCommand(
      action: 'unlock',
      keywordsAr: ['افتح', 'اقفل القفل', 'فك القفل', 'الغ القفل'],
      keywordsEn: ['unlock', 'open', 'unsecure'],
    ),
    VoiceCommand(
      action: 'trigger',
      keywordsAr: ['شغل', 'فعل', 'نبه', 'صوت'],
      keywordsEn: ['trigger', 'activate', 'sound', 'start'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeSpeech();
    _initializeTts();
    _startPeriodicSync();
    _testInitialConnection();
  }

  void _testInitialConnection() async {
    print('🚀 Testing initial connection...');
    bool isConnected = await ApiService.testConnection();
    setState(() {
      _isConnected = isConnected;
      if (!isConnected) {
        _connectionError = 'Server is not reachable';
      }
    });
  }

  void _initializeSpeech() async {
    var status = await Permission.microphone.request();
    print('Microphone permission status: $status');

    bool available = await _speech.initialize(
      onStatus: (val) {
        print('Speech status: $val');
        setState(() {
          if (val == 'done' || val == 'notListening') {
            _isListening = false;
          } else if (val == 'listening') {
            _isListening = true;
          }
        });

        if (val == 'done' && _continuousListening) {
          Future.delayed(Duration(milliseconds: 500), () {
            if (_continuousListening && !_isListening) {
              _startListening();
            }
          });
        }
      },
      onError: (val) {
        print('Speech error: $val');
        setState(() => _isListening = false);
        if (_continuousListening) {
          Future.delayed(Duration(milliseconds: 1000), () {
            if (_continuousListening && !_isListening) {
              _startListening();
            }
          });
        }
      },
      debugLogging: true,
    );

    if (!available) {
      setState(() {
        _text = _selectedLocale == 'ar-SA'
            ? 'خطأ في تهيئة الميكروفون - تأكد من الصلاحيات'
            : 'Microphone initialization error - check permissions';
      });
      print('Speech recognition not available');
    } else {
      print('Speech recognition initialized successfully');
    }
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage(_selectedLocale);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.7);
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      print('⏰ Periodic sync check...');
      bool isConnected = await ApiService.testConnection();
      
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          if (!isConnected) {
            _connectionError = 'Connection lost';
          } else {
            _connectionError = '';
          }
        });
      }
    });
  }

  void _toggleListening() async {
    if (!_continuousListening) {
      setState(() {
        _continuousListening = true;
        _text = _selectedLocale == 'ar-SA'
            ? 'الاستماع المستمر مفعل - قل الأمر'
            : 'Continuous listening enabled - say a command';
        _commandResult = '';
      });
      _startListening();
    } else {
      setState(() {
        _continuousListening = false;
        _isListening = false;
        _text = _selectedLocale == 'ar-SA' ? 'تم إيقاف الاستماع' : 'Listening stopped';
        _commandResult = '';
      });
      await _speech.stop();
    }
  }

  void _startListening() async {
    if (_continuousListening && !_isListening) {
      print('Starting to listen...');
      bool available = await _speech.initialize();
      if (available) {
        await _speech.listen(
          onResult: (val) {
            setState(() => _text = val.recognizedWords);
            print('Recognized: ${val.recognizedWords}');
            if (val.finalResult && val.recognizedWords.isNotEmpty) {
              if (_lastCommand != val.recognizedWords) {
                _processVoiceCommand(val.recognizedWords);
              }
            }
          },
          localeId: _selectedLocale,
          pauseFor: Duration(seconds: 3),
          listenFor: Duration(seconds: 8),
          partialResults: true,
        );
      } else {
        print('Speech recognition not available for listening');
      }
    }
  }

  void _processVoiceCommand(String command) {
    setState(() => _lastCommand = command);
    print('🎤 Processing command: $command');

    String normalizedCommand = command.toLowerCase().trim();
    String? action;

    // Find action in command
    for (VoiceCommand cmd in commands) {
      List<String> keywords = _selectedLocale == 'ar-SA' ? cmd.keywordsAr : cmd.keywordsEn;
      for (String keyword in keywords) {
        if (normalizedCommand.contains(keyword.toLowerCase())) {
          action = cmd.action;
          print('🎯 Found action: $action for keyword: $keyword');
          break;
        }
      }
      if (action != null) break;
    }

    if (action == null) {
      _commandResult = _selectedLocale == 'ar-SA'
          ? 'لم يتم التعرف على الأمر'
          : 'Command not recognized';
      _speak(_commandResult);
      setState(() {});
      return;
    }

    // Find room and device
    Room? targetRoom;
    Device? targetDevice;

    // First try to find room
    for (Room room in rooms) {
      List<String> roomKeywords = _selectedLocale == 'ar-SA' ? room.keywordsAr : room.keywordsEn;
      for (String keyword in roomKeywords) {
        if (normalizedCommand.contains(keyword.toLowerCase())) {
          targetRoom = room;
          print('🏠 Found room: ${room.nameAr} for keyword: $keyword');
          break;
        }
      }
      if (targetRoom != null) break;
    }

    // Then find device (either in specific room or globally)
    if (targetRoom != null) {
      for (Device device in targetRoom.devices) {
        List<String> deviceKeywords = _selectedLocale == 'ar-SA' ? device.keywordsAr : device.keywordsEn;
        for (String keyword in deviceKeywords) {
          if (normalizedCommand.contains(keyword.toLowerCase())) {
            targetDevice = device;
            print('🔧 Found device: ${device.nameAr} for keyword: $keyword');
            break;
          }
        }
        if (targetDevice != null) break;
      }
    } else {
      // Search all rooms for device
      for (Room room in rooms) {
        for (Device device in room.devices) {
          List<String> deviceKeywords = _selectedLocale == 'ar-SA' ? device.keywordsAr : device.keywordsEn;
          for (String keyword in deviceKeywords) {
            if (normalizedCommand.contains(keyword.toLowerCase())) {
              targetDevice = device;
              targetRoom = room;
              print('🔧 Found device globally: ${device.nameAr} in ${room.nameAr}');
              break;
            }
          }
          if (targetDevice != null) break;
        }
        if (targetDevice != null) break;
      }
    }

    if (targetDevice != null && targetRoom != null) {
      print('✅ Executing command: $action on ${targetDevice.nameAr} in ${targetRoom.nameAr}');
      _sendCommandToDevice(targetRoom, targetDevice, action);
    } else {
      _commandResult = _selectedLocale == 'ar-SA'
          ? 'لم يتم العثور على الجهاز المطلوب'
          : 'Device not found';
      _speak(_commandResult);
      setState(() {});
    }
  }

  void _sendCommandToDevice(Room room, Device device, String action) async {
    print('📤 Sending command $action to ${device.nameAr} in ${room.nameAr}');
    
    if (!_isConnected) {
      setState(() {
        _commandResult = _selectedLocale == 'ar-SA'
            ? 'خطأ: لا يوجد اتصال بالخادم'
            : 'Error: No server connection';
      });
      _speak(_commandResult);
      return;
    }
    
    Map<String, dynamic> result = {'success': false, 'message': 'Unknown device'};

    // Handle Corridor devices
    if (room.id == 'corridor') {
      if (device.action == 'light') {
        if (action == 'turn_on') {
          result = await ApiService.controlCorridorLight('on');
        } else if (action == 'turn_off') {
          result = await ApiService.controlCorridorLight('off');
        }
      } else if (device.action == 'elock') {
        if (action == 'lock' || action == 'turn_on') {
          result = await ApiService.controlCorridorLock(true);
        } else if (action == 'unlock' || action == 'turn_off') {
          result = await ApiService.controlCorridorLock(false);
        }
      }
    }
    // Handle Garage devices
    else if (room.id == 'garage') {
      if (device.action == 'door') {
        if (action == 'turn_on' || action == 'turn_off') {
          result = await ApiService.openGarageDoor();
        }
      } else if (device.action == 'buzzer') {
        if (action == 'turn_on' || action == 'trigger') {
          result = await ApiService.triggerGarageBuzzer();
        }
      }
    }

    // Update UI with result
    if (result['success']) {
      setState(() {
        if (_selectedLocale == 'ar-SA') {
          _commandResult = _getSuccessMessageAr(room, device, action);
        } else {
          _commandResult = _getSuccessMessageEn(room, device, action);
        }
      });
      _speak(_commandResult);
      print('✅ Server response: ${result['message']}');
    } else {
      setState(() {
        _commandResult = _selectedLocale == 'ar-SA'
            ? 'خطأ في الاتصال بالخادم: ${result['message'] ?? 'Unknown error'}'
            : 'Server connection error: ${result['message'] ?? 'Unknown error'}';
        _isConnected = false; // Update connection status
      });
      _speak(_commandResult);
      print('❌ Server error: ${result['message']}');
    }
  }

  String _getSuccessMessageAr(Room room, Device device, String action) {
    switch (action) {
      case 'turn_on':
        return 'تم تشغيل ${device.nameAr}';
      case 'turn_off':
        return 'تم إيقاف ${device.nameAr}';
      case 'lock':
        return 'تم قفل ${device.nameAr}';
      case 'unlock':
        return 'تم فتح ${device.nameAr}';
      case 'trigger':
        return 'تم تشغيل ${device.nameAr}';
      default:
        return 'تم تنفيذ الأمر على ${device.nameAr}';
    }
  }

  String _getSuccessMessageEn(Room room, Device device, String action) {
    switch (action) {
      case 'turn_on':
        return '${device.nameEn} turned on';
      case 'turn_off':
        return '${device.nameEn} turned off';
      case 'lock':
        return '${device.nameEn} locked';
      case 'unlock':
        return '${device.nameEn} unlocked';
      case 'trigger':
        return '${device.nameEn} triggered';
      default:
        return 'Command executed on ${device.nameEn}';
    }
  }

  // Add test connection button handler
  void _testConnection() async {
    setState(() {
      _commandResult = _selectedLocale == 'ar-SA'
          ? 'جاري اختبار الاتصال...'
          : 'Testing connection...';
    });
    
    bool isConnected = await ApiService.testConnection();
    
    setState(() {
      _isConnected = isConnected;
      _commandResult = isConnected
          ? (_selectedLocale == 'ar-SA' ? 'الاتصال ناجح!' : 'Connection successful!')
          : (_selectedLocale == 'ar-SA' ? 'فشل الاتصال بالخادم' : 'Connection failed');
    });
    
    _speak(_commandResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1017),
      appBar: AppBar(
        title: Text(_selectedLocale == 'ar-SA' ? 'التحكم الصوتي' : 'Voice Control'),
        backgroundColor: const Color(0xFF2879fe),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              setState(() {
                _selectedLocale = _selectedLocale == 'ar-SA' ? 'en-US' : 'ar-SA';
                _initializeTts();
                _text = _selectedLocale == 'ar-SA' 
                    ? 'اضغط على الميكروفون وقل الأمر'
                    : 'Press microphone and say command';
              });
            },
          ),
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                SizedBox(width: 4),
                Text(
                  _isConnected
                      ? (_selectedLocale == 'ar-SA' ? 'متصل' : 'Connected')
                      : (_selectedLocale == 'ar-SA' ? 'غير متصل' : 'Disconnected'),
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2879fe),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _toggleListening,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _continuousListening ? Colors.red : Colors.blue,
                    boxShadow: [
                      BoxShadow(
                        color: (_continuousListening ? Colors.red : Colors.blue).withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    _continuousListening ? Icons.mic_off : Icons.mic,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                _continuousListening
                    ? (_selectedLocale == 'ar-SA' ? 'إيقاف الاستماع' : 'Stop Listening')
                    : (_selectedLocale == 'ar-SA' ? 'بدء الاستماع' : 'Start Listening'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _continuousListening ? Colors.red : const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              SizedBox(height: 16),
              if (_isListening)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _selectedLocale == 'ar-SA' ? 'جاري الاستماع...' : 'Listening...',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedLocale == 'ar-SA' ? 'الأمر المسموع:' : 'Recognized Command:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _text,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (_lastCommand.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Text(
                        _selectedLocale == 'ar-SA'
                            ? 'آخر أمر: $_lastCommand'
                            : 'Last Command: $_lastCommand',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_commandResult.isNotEmpty) ...[
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _commandResult.contains('تم') || _commandResult.contains('turned')
                        ? Colors.green[50]
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _commandResult.contains('تم') || _commandResult.contains('turned')
                          ? Colors.green[200]!
                          : Colors.red[200]!,
                    ),
                  ),
                  child: Text(
                    _commandResult,
                    style: TextStyle(
                      color: _commandResult.contains('تم') || _commandResult.contains('turned')
                          ? Colors.green[800]
                          : Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }
}