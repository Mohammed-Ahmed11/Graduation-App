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
        GlobalWidgetsLocalizations.delegate,
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
  static const String baseUrl = 'http://192.168.43.58:3000/api';

  static Future<Map<String, dynamic>> getAllDevices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/devices'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load devices');
    } catch (e) {
      print('Error getting devices: $e');
      return {'success': false, 'devices': {}};
    }
  }

  static Future<Map<String, dynamic>> updateDevice(String deviceId, String action) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/devices/$deviceId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': action}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to update device');
    } catch (e) {
      print('Error updating device: $e');
      return {'success': false};
    }
  }
}

class Device {
  final String id;
  final String nameAr;
  final String nameEn;
  final String type;
  bool isOn;
  final List<String> keywordsAr;
  final List<String> keywordsEn;

  Device({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.type,
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

  List<Room> rooms = [
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
          keywordsAr: ['إضاءة', 'نور', 'أنوار', 'لمبة', 'الضوء', 'ضوء الغرفة'],
          keywordsEn: ['light', 'lamp', 'illumination', 'lighting', 'room light'],
        ),
        Device(
          id: 'living_tv',
          nameAr: 'تلفزيون غرفة المعيشة',
          nameEn: 'Living Room TV',
          type: 'tv',
          keywordsAr: ['تلفزيون', 'تليفزيون', 'شاشة', 'تي في', 'tv', 'تلفاز'],
          keywordsEn: ['tv', 'television', 'screen', 'smart tv'],
        ),
        Device(
          id: 'living_ac',
          nameAr: 'مكيف غرفة المعيشة',
          nameEn: 'Living Room AC',
          type: 'ac',
          keywordsAr: ['مكيف', 'تكييف', 'تبريد', 'هواء بارد', 'الهواء', 'المروحة'],
          keywordsEn: ['ac', 'air conditioner', 'cooling', 'cold air', 'climate'],
        ),
        Device(
          id: 'living_curtains',
          nameAr: 'ستائر غرفة المعيشة',
          nameEn: 'Living Room Curtains',
          type: 'curtain',
          keywordsAr: ['ستائر', 'ستارة', 'الستارة', 'فتح الستارة', 'قفل الستارة'],
          keywordsEn: ['curtain', 'curtains', 'drapes', 'open curtain', 'close curtain'],
        ),
      ],
    ),
    Room(
      id: 'kitchen',
      nameAr: 'المطبخ',
      nameEn: 'Kitchen',
      keywordsAr: ['المطبخ', 'مطبخ', 'الطبخ', 'موقع الطبخ'],
      keywordsEn: ['kitchen', 'cooking', 'cook area'],
      devices: [
        Device(
          id: 'kitchen_oven',
          nameAr: 'فرن ذكي',
          nameEn: 'Smart Oven',
          type: 'oven',
          keywordsAr: ['فرن', 'الفرن', 'ذكي', 'خبز', 'تسخين الطعام', 'تحميص'],
          keywordsEn: ['oven', 'smart oven', 'bake', 'cooking', 'toaster'],
        ),
        Device(
          id: 'kitchen_fridge',
          nameAr: 'مراقبة الثلاجة',
          nameEn: 'Refrigerator Monitoring',
          type: 'fridge_monitor',
          keywordsAr: ['ثلاجة', 'مراقبة', 'تبريد', 'براد', 'درجة الحرارة', 'الثلاجة'],
          keywordsEn: ['fridge', 'refrigerator', 'monitoring', 'cooling', 'temperature'],
        ),
        Device(
          id: 'kitchen_dishwasher',
          nameAr: 'التحكم في غسالة الصحون',
          nameEn: 'Dishwasher Control',
          type: 'dishwasher',
          keywordsAr: ['غسالة', 'غسالة الصحون', 'الصحون', 'تنظيف الصحون', 'الجلاية'],
          keywordsEn: ['dishwasher', 'plate washer', 'wash dishes', 'clean dishes'],
        ),
      ],
    ),
    Room(
      id: 'garage',
      nameAr: 'الجراج',
      nameEn: 'Garage',
      keywordsAr: ['الجراج', 'الكراج', 'الموقف', 'موقف السيارات'],
      keywordsEn: ['garage', 'parking', 'car space'],
      devices: [
        Device(
          id: 'garage_door',
          nameAr: 'باب أوتوماتيكي',
          nameEn: 'Automatic Door',
          type: 'door',
          keywordsAr: ['باب', 'الباب', 'فتح الباب', 'قفل الباب', 'باب الجراج'],
          keywordsEn: ['door', 'automatic door', 'garage door', 'open door', 'close door'],
        ),
        Device(
          id: 'garage_light',
          nameAr: 'إضاءة الجراج',
          nameEn: 'Garage Light',
          type: 'light',
          keywordsAr: ['إضاءة', 'نور', 'لمبة', 'أنوار', 'الضوء', 'ضوء الجراج'],
          keywordsEn: ['light', 'lamp', 'illumination', 'garage light'],
        ),
        Device(
          id: 'garage_charger',
          nameAr: 'شحن السيارة',
          nameEn: 'Car Charging',
          type: 'charger',
          keywordsAr: ['شحن', 'شحن السيارة', 'السيارة', 'بطارية السيارة', 'شحن كهرباء'],
          keywordsEn: ['car charging', 'charge car', 'ev charger', 'electric car'],
        ),
      ],
    ),
    Room(
      id: 'roof',
      nameAr: 'السطح',
      nameEn: 'Roof',
      keywordsAr: ['السطح', 'الروف', 'أعلى البيت'],
      keywordsEn: ['roof', 'rooftop', 'top floor'],
      devices: [
        Device(
          id: 'roof_solar',
          nameAr: 'ألواح شمسية',
          nameEn: 'Solar Panels',
          type: 'solar',
          keywordsAr: ['طاقة شمسية', 'ألواح شمسية', 'الطاقة', 'الخلايا الشمسية'],
          keywordsEn: ['solar', 'solar panels', 'solar energy'],
        ),
        Device(
          id: 'roof_drain',
          nameAr: 'نظام تصريف المياه',
          nameEn: 'Water Drainage System',
          type: 'drainage',
          keywordsAr: ['تصريف', 'مياه', 'مطر', 'نظام التصريف'],
          keywordsEn: ['drainage', 'rainwater', 'water system'],
        ),
      ],
    ),
    Room(
      id: 'bedroom',
      nameAr: 'غرفة النوم',
      nameEn: 'Bedroom',
      keywordsAr: ['غرفة النوم', 'النوم', 'الاودة', 'السرير'],
      keywordsEn: ['bedroom', 'sleep', 'room', 'bed'],
      devices: [
        Device(
          id: 'bedroom_alarm',
          nameAr: 'منبه ذكي',
          nameEn: 'Smart Alarm',
          type: 'alarm',
          keywordsAr: ['منبه', 'تنبيه', 'الساعة', 'الاستيقاظ'],
          keywordsEn: ['alarm', 'smart alarm', 'clock', 'wake up'],
        ),
        Device(
          id: 'bedroom_purifier',
          nameAr: 'منقي هواء',
          nameEn: 'Air Purifier',
          type: 'purifier',
          keywordsAr: ['منقي', 'هواء', 'فلتر', 'نقاء', 'تنقية الهواء'],
          keywordsEn: ['purifier', 'air filter', 'clean air', 'air purifier'],
        ),
        Device(
          id: 'bedroom_lighting_control',
          nameAr: 'تحكم في الإضاءة',
          nameEn: 'Lighting Control',
          type: 'light_control',
          keywordsAr: ['إضاءة', 'نور', 'تحكم', 'لمبة', 'ضوء'],
          keywordsEn: ['light', 'lamp', 'lighting', 'light control'],
        ),
      ],
    ),
    Room(
      id: 'garden',
      nameAr: 'الحديقة',
      nameEn: 'Garden',
      keywordsAr: ['الحديقة', 'الجنينة', 'حديقة البيت', 'الخارج'],
      keywordsEn: ['garden', 'yard', 'outside garden', 'outdoor'],
      devices: [
        Device(
          id: 'garden_watering',
          nameAr: 'سقي تلقائي',
          nameEn: 'Automated Watering',
          type: 'watering',
          keywordsAr: ['سقي', 'الري', 'تلقائي', 'ماء النباتات'],
          keywordsEn: ['watering', 'auto watering', 'irrigation', 'water plants'],
        ),
        Device(
          id: 'garden_soil',
          nameAr: 'مراقبة التربة',
          nameEn: 'Soil Monitoring',
          type: 'soil_monitor',
          keywordsAr: ['تربة', 'مراقبة', 'حالة التربة', 'خصوبة'],
          keywordsEn: ['soil', 'monitoring', 'soil health', 'moisture'],
        ),
        Device(
          id: 'garden_lighting',
          nameAr: 'إضاءة خارجية',
          nameEn: 'Outdoor Lighting',
          type: 'outdoor_light',
          keywordsAr: ['إضاءة', 'خارجية', 'نور الجنينة', 'أنوار الحديقة'],
          keywordsEn: ['outdoor light', 'garden light', 'yard light'],
        ),
      ],
    ),
  ];

  List<VoiceCommand> commands = [
    VoiceCommand(
      action: 'turn_on',
      keywordsAr: ['شغل', 'افتح', 'اشغل', 'ولع'],
      keywordsEn: ['turn on', 'open', 'start'],
    ),
    VoiceCommand(
      action: 'turn_off',
      keywordsAr: ['اقفل', 'اطفي', 'اطفئ', 'سكر'],
      keywordsEn: ['turn off', 'close', 'stop'],
    ),
    VoiceCommand(
      action: 'stop',
      keywordsAr: ['وقف', 'استوب', 'توقف'],
      keywordsEn: ['stop', 'halt', 'cease'],
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
    _syncTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      ApiService.getAllDevices().then((result) {
        setState(() {
          _isConnected = result['success'];
        });
      });
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
    print('Processing command: $command');

    String normalizedCommand = command.toLowerCase().trim();
    String? action;

    for (VoiceCommand cmd in commands) {
      List<String> keywords = _selectedLocale == 'ar-SA' ? cmd.keywordsAr : cmd.keywordsEn;
      for (String keyword in keywords) {
        if (normalizedCommand.contains(keyword)) {
          action = cmd.action;
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

    Room? targetRoom;
    for (Room room in rooms) {
      List<String> roomKeywords = _selectedLocale == 'ar-SA' ? room.keywordsAr : room.keywordsEn;
      for (String keyword in roomKeywords) {
        if (normalizedCommand.contains(keyword)) {
          targetRoom = room;
          break;
        }
      }
      if (targetRoom != null) break;
    }

    Device? targetDevice;
    if (targetRoom != null) {
      for (Device device in targetRoom.devices) {
        List<String> deviceKeywords = _selectedLocale == 'ar-SA' ? device.keywordsAr : device.keywordsEn;
        for (String keyword in deviceKeywords) {
          if (normalizedCommand.contains(keyword)) {
            targetDevice = device;
            break;
          }
        }
        if (targetDevice != null) break;
      }
    } else {
      for (Room room in rooms) {
        for (Device device in room.devices) {
          List<String> deviceKeywords = _selectedLocale == 'ar-SA' ? device.keywordsAr : device.keywordsEn;
          for (String keyword in deviceKeywords) {

            if (normalizedCommand.contains(keyword)) {
              targetDevice = device;
              targetRoom = room;
              break;
            }
          }
          if (targetDevice != null) break;
        }
        if (targetDevice != null) break;
      }
    }

    if (targetDevice != null) {
      _sendCommandToServer(targetDevice, action);
    } else {
      _commandResult = _selectedLocale == 'ar-SA'
          ? 'لم يتم العثور على الجهاز المطلوب'
          : 'Device not found';
      _speak(_commandResult);
      setState(() {});
    }
  }

  void _sendCommandToServer(Device device, String action) async {
    print('Sending command $action to ${device.nameAr}');
    final result = await ApiService.updateDevice(device.id, action);
    if (result['success']) {
      setState(() {
        if (_selectedLocale == 'ar-SA') {
          _commandResult = action == 'turn_on'
              ? 'تم تشغيل ${device.nameAr}'
              : 'تم إيقاف ${device.nameAr}';
        } else {
          _commandResult = action == 'turn_on'
              ? '${device.nameEn} turned on'
              : '${device.nameEn} turned off';
        }
      });
      _speak(_commandResult);
      print('Server response: ${result['message']}');
    } else {
      setState(() {
        _commandResult = _selectedLocale == 'ar-SA'
            ? 'خطأ في الاتصال بالخادم'
            : 'Server connection error';
      });
      _speak(_commandResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFF0d1017),
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
            color:  const Color(0xFF2879fe),
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