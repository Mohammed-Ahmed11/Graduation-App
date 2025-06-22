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
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../requestConfig.dart';

class CorridorPage extends StatefulWidget {
  const CorridorPage({super.key});

  @override
  State<CorridorPage> createState() => _CorridorPageState();
}

class _CorridorPageState extends State<CorridorPage> {
  Map<String, dynamic> corridorData = {};
  bool connected = false;
  Timer? refreshTimer;

  // Voice control variables
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _voiceText = 'قل الأمر (مثال: شغل النور)';
  String _commandResult = '';

  // Voice commands for corridor
  final List<Map<String, dynamic>> _voiceCommands = [
    {'action': 'light_on', 'keywords': ['شغل النور', 'افتح النور', 'ولع النور', 'إضاءة']},
    {'action': 'light_off', 'keywords': ['اقفل النور', 'اطفي النور', 'سكر النور']},
    {'action': 'lock', 'keywords': ['اقفل الباب', 'قفل الباب', 'أغلق الباب']},
    {'action': 'unlock', 'keywords': ['افتح الباب', 'فك الباب', 'انفتح الباب']},
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeSpeech();
    _initializeTts();
    loadCorridorStatus();

    refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        loadCorridorStatus();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _initializeSpeech() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _showSnack('⚠️ Microphone permission denied');
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (val) {
        setState(() {
          _isListening = val == 'listening';
          if (val == 'done' || val == 'notListening') {
            _voiceText = 'قل الأمر (مثال: شغل النور)';
          }
        });
      },
      onError: (val) {
        setState(() {
          _isListening = false;
          _voiceText = 'خطأ في التعرف على الصوت';
          _commandResult = '❌ خطأ: ${val.errorMsg}';
        });
      },
    );

    if (!available) {
      _showSnack('⚠️ Speech recognition not available');
    }
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('ar-SA');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.7);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _toggleListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        _voiceText = 'قل الأمر (مثال: شغل النور)';
      });
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    if (!connected) {
      _showSnack('⚠️ No connection. Cannot use voice control.');
      return;
    }

    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() => _voiceText = val.recognizedWords);
          if (val.finalResult && val.recognizedWords.isNotEmpty) {
            _processVoiceCommand(val.recognizedWords);
          }
        },
        localeId: 'ar-SA',
        partialResults: true,
      );
    } else {
      setState(() {
        _isListening = false;
        _voiceText = 'خطأ في تهيئة الميكروفون';
      });
      _showSnack('⚠️ Speech recognition not available');
    }
  }

  void _processVoiceCommand(String command) {
    String normalizedCommand = command.toLowerCase().trim();
    String? action;

    for (var cmd in _voiceCommands) {
      for (String keyword in cmd['keywords']) {
        if (normalizedCommand.contains(keyword)) {
          action = cmd['action'];
          break;
        }
      }
      if (action != null) break;
    }

    if (action == null) {
      setState(() => _commandResult = 'لم يتم التعرف على الأمر');
      _speak('لم يتم التعرف على الأمر');
      return;
    }

    if (action.startsWith('light_')) {
      _controlLight(action == 'light_on' ? 'on' : 'off');
    } else if (action == 'lock' || action == 'unlock') {
      _controlLock(action == 'lock');
    }
  }

  Future<void> _controlLight(String mode) async {
    try {
      final url = Uri.parse('$baseUrl/cat/corridor/light');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mode': mode}),
      );

      if (response.statusCode == 200) {
        setState(() => _commandResult = '✅ النور ${mode == 'on' ? 'مشغل' : 'مطفي'}');
        _speak('النور ${mode == 'on' ? 'مشغل' : 'مطفي'}');
        loadCorridorStatus();
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _commandResult = '❌ خطأ: $e');
      _speak('خطأ في التحكم بالنور');
    }
  }

  Future<void> _controlLock(bool lock) async {
    try {
      final url = Uri.parse('$baseUrl/cat/corridor/elock');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'lock': lock}),
      );

      if (response.statusCode == 200) {
        setState(() => _commandResult = '✅ الباب ${lock ? 'مقفل' : 'مفتوح'}');
        _speak('الباب ${lock ? 'مقفل' : 'مفتوح'}');
        loadCorridorStatus();
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _commandResult = '❌ خطأ: $e');
      _speak('خطأ في التحكم بالباب');
    }
  }

  Future<void> loadCorridorStatus() async {
    try {
      final url = Uri.parse('$baseUrl/cat/corridor/status');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          corridorData = data;
          connected = true;
        });
      } else {
        throw Exception('Failed to load corridor status');
      }
    } catch (e) {
      setState(() => connected = false);
    }
  }

  Future<void> toggleLight() async {
    if (!connected) {
      _showSnack('⚠️ No connection. Cannot control light.');
      return;
    }

    final isOn = corridorData['light'] == true;
    final mode = isOn ? 'off' : 'on';

    try {
      final url = Uri.parse('$baseUrl/cat/corridor/light');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mode': mode}),
      );

      if (response.statusCode == 200) {
        _showSnack('✅ Light turned ${isOn ? 'off' : 'on'}!');
        loadCorridorStatus();
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      _showSnack('❌ Error: $e');
    }
  }

  Future<void> toggleLock() async {
    if (!connected) {
      _showSnack('⚠️ No connection. Cannot control E-lock.');
      return;
    }

    final isLocked = corridorData['elock'] == true;
    final lockValue = !isLocked;

    try {
      final url = Uri.parse('$baseUrl/cat/corridor/elock');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'lock': lockValue}),
      );

      if (response.statusCode == 200) {
        _showSnack('🔒 E-lock ${lockValue ? 'locked' : 'unlocked'}');
        loadCorridorStatus();
      } else {
        throw Exception('Lock toggle failed: ${response.statusCode}');
      }
    } catch (e) {
      _showSnack('❌ Error: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _gridItem(IconData icon, String label, String value,
      {Color? color, Color? iconColor}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28, color: iconColor ?? Colors.white),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = connected
        ? (corridorData['motion'] == true ? 'Detected' : 'None')
        : 'N/A';
    final light = connected
        ? (corridorData['light'] == true ? 'On' : 'Off')
        : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corridor'),
        backgroundColor: const Color(0xFF2879fe),
        elevation: 4,
      ),
      backgroundColor: const Color(0xFF10141c),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!connected)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '⚠️ No connection. Some data may be unavailable.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Image banner
            Container(
              height: 140,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/corridor.jpg',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    bottom: 12,
                    child: Text(
                      'Corridor',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sensor Grid
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _gridItem(Icons.directions_run, 'Motion', motion,
                          iconColor: Colors.orange),
                      _gridItem(Icons.lightbulb, 'Light', light,
                          iconColor: Colors.amber),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Voice Control Button
            ControlButton(
              label: _isListening ? 'إيقاف الاستماع' : 'التحكم الصوتي',
              icon: _isListening ? Icons.mic_off : Icons.mic,
              color: _isListening ? Colors.red.shade600 : Colors.blue.shade600,
              onPressed: _toggleListening,
            ),

            if (_commandResult.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _commandResult.contains('✅')
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _commandResult,
                  style: TextStyle(
                    color: _commandResult.contains('✅')
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Manual Light Control
            ControlButton(
              label: corridorData['light'] == true ? 'Turn Off Light' : 'Turn On Light',
              icon: corridorData['light'] == true
                  ? Icons.lightbulb
                  : Icons.lightbulb_outline,
              color: Colors.amber.shade700,
              onPressed: toggleLight,
            ),

            const SizedBox(height: 12),

            // Manual Lock Control
            ControlButton(
              label: corridorData['elock'] == true ? 'Unlock E-Lock' : 'Lock E-Lock',
              icon: corridorData['elock'] == true
                  ? Icons.lock_open
                  : Icons.lock_outline,
              color: corridorData['elock'] == true
                  ? Colors.green.shade600
                  : Colors.red.shade600,
              onPressed: toggleLock,
            ),
          ],
        ),
      ),
    );
  }
}

class ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color? iconColor;

  const ControlButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 6,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: iconColor ?? const Color(0xFF10141c)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}