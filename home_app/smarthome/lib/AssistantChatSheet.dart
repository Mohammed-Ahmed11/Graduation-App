import 'package:flutter/material.dart';
import 'package:smarthome/ai_assistant.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final AiAssistant _assistant = AiAssistant();
  bool _isListening = false;

  @override
  void dispose() {
    _textController.dispose();
    _assistant.stopListening();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    
    // Add user message
    _addMessage(text, true);
    
    // Process and get response
    _assistant.handleCommand(text).then((response) {
      _addMessage(response, false);
    });
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.insert(0, ChatMessage(
        text: text,
        isUser: isUser,
      ));
    });
  }

  void _startVoiceInput() async {
    setState(() => _isListening = true);
    
    await _assistant.startListening((command) async {
      setState(() => _isListening = false);
      if (command.isNotEmpty) {
        _handleSubmitted(command);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1017),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2879fe),
        title: const Text('AI Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Image.asset(
                      'assets/images/aibg.png', // Ensure this image exists in your assets
                      width: 250, // Adjust size as needed
                      height: 250,
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _messages[index],
                  ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message or use voice',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
            IconButton(
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
              color: _isListening ? Colors.red : null,
              onPressed: _startVoiceInput,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({Key? key, required this.text, required this.isUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            child: Icon(isUser ? Icons.person : Icons.smart_toy),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isUser ? 'You' : 'Assistant'),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}