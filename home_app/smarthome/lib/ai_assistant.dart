import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AiAssistant {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _isInitialized = false;

  Future<void> startListening(Function(String command) onCommandRecognized) async {
    // Initialize if not done already
    if (!_isInitialized) {
      _isInitialized = await _speechToText.initialize(
        onStatus: (status) {
          print("Speech status: $status");
        },
        onError: (error) {
          print("Speech error: $error");
        },
      );
    }

    // If failed to initialize
    if (!_isInitialized) {
      print("Failed to initialize speech recognition");
      return;
    }

    if (_speechToText.isListening) {
      print("Already listening...");
      return;
    }

    _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          onCommandRecognized(result.recognizedWords);
          stopListening(); // Stop after command recognized
        }
      },
    );
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  Future<void> handleCommand(String command) async {
    command = command.toLowerCase();
    String response;

    if (command.contains("open light")) {
      response = "Turning on the light.";
    } else if (command.contains("close light")) {
      response = "Turning off the light.";
    } else {
      response = "Sorry, I didn't understand that command.";
    }

    await _flutterTts.speak(response);
  }
}
