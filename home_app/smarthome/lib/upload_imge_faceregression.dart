import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

// void main() {
//   runApp(const FaceRecognitionApp());
// }

class FaceRecognitionApp extends StatelessWidget {
  const FaceRecognitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Recognition Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      home: const FaceUploadScreen(),
    );
  }
}

class FaceUploadScreen extends StatefulWidget {
  const FaceUploadScreen({super.key});

  @override
  State<FaceUploadScreen> createState() => _FaceUploadScreenState();
}

class _FaceUploadScreenState extends State<FaceUploadScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _selectedFile;
  bool _isUploading = false;
  String _statusMessage = '';

  // Replace with your server's IP address
  final String _serverUrl = 'http://192.168.1.6:5000/upload_face'; // Update IP as needed

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      // For Android 13+, request specific media permissions
      var status = await Permission.photos.request();
      if (status.isDenied) {
        setState(() {
          _statusMessage = 'Photo access permission denied';
        });
        return false;
      }
      // Fallback for older Android versions
      status = await Permission.storage.request();
      if (status.isDenied) {
        setState(() {
          _statusMessage = 'Storage permission denied';
        });
        return false;
      }
    }
    return true;
  }

  Future<void> _pickFile() async {
    if (!await _requestPermissions()) {
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'bmp', 'tiff'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        // Basic file size validation (e.g., < 10MB)
        if (await file.length() > 10 * 1024 * 1024) {
          setState(() {
            _statusMessage = 'File size exceeds 10MB limit';
          });
          return;
        }
        setState(() {
          _selectedFile = file;
          _statusMessage = '';
        });
      } else {
        setState(() {
          _statusMessage = 'No file selected';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error picking file: $e';
      });
      debugPrint('File picking error: $e');
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      setState(() {
        _statusMessage = 'Please select a file first';
      });
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = 'Please enter a name';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _statusMessage = 'Uploading...';
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_serverUrl));
      request.files.add(await http.MultipartFile.fromPath('image', _selectedFile!.path));
      request.fields['name'] = _nameController.text.trim();

      var response = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      setState(() {
        _isUploading = false;
        if (response.statusCode == 200) {
          _statusMessage = jsonResponse['message'] ?? 'Upload successful!';
          _selectedFile = null;
          _nameController.clear();
        } else {
          _statusMessage = jsonResponse['error'] ?? 'Upload failed (Code: ${response.statusCode})';
        }
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = 'Upload error: $e';
      });
      debugPrint('Upload error: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Face File'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 20),
                      _selectedFile == null
                          ? const Text(
                              'No file selected',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            )
                          : Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Selected: ${_selectedFile!.path.split('/').last}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('Select File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadFile,
                icon: const Icon(Icons.upload),
                label: const Text('Upload File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: TextStyle(
                  color: _statusMessage.contains('Error') ||
                          _statusMessage.contains('failed')
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}