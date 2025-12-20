import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/groq_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with TickerProviderStateMixin {
  final GroqService _groqService = GroqService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  bool _isListening = false;
  bool _isProcessing = false;
  bool _speechEnabled = false;
  String _recognizedText = '';
  String _responseText = '';

  late AnimationController _pulseController;
  late AnimationController _waveController;

  final List<Map<String, String>> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onError: (error) {
        setState(() {
          _isListening = false;
          _recognizedText = '';
        });
        _showError('Speech recognition error: ${error.errorMsg}');
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    setState(() {});
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _textController.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  void _toggleListening() async {
    if (!_speechEnabled) {
      _showError('Speech recognition not available. Using text input instead.');
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _recognizedText = '';
        _responseText = '';
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });

          // When user stops speaking, process the message
          if (result.finalResult) {
            _processMessage(_recognizedText);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _processMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _isListening = false;
    });

    try {
      // Get AI response
      final response = await _groqService.sendMessage(message);

      setState(() {
        _responseText = response;
        _conversationHistory.insert(0, {'user': message, 'ai': response});
        _isProcessing = false;
      });

      // Speak the response
      await _flutterTts.speak(response);
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError(e.toString());
    }
  }

  Future<void> _handleQuickCommand(String command) async {
    setState(() {
      _recognizedText = command;
      _isProcessing = true;
    });

    try {
      final response = await _groqService.getQuickResponse(command);

      setState(() {
        _responseText = response;
        _conversationHistory.insert(0, {'user': command, 'ai': response});
        _isProcessing = false;
      });

      await _flutterTts.speak(response);
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voice Assistant',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Powered by Groq AI',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.flash_on, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'FAST',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Animated Microphone
                      GestureDetector(
                        onTap: _toggleListening,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: _isListening || _isProcessing
                                      ? [
                                          const Color(0xFFEC4899),
                                          const Color(0xFFF43F5E),
                                        ]
                                      : [
                                          const Color(0xFF6366F1),
                                          const Color(0xFF8B5CF6),
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_isListening || _isProcessing
                                                ? const Color(0xFFEC4899)
                                                : const Color(0xFF6366F1))
                                            .withOpacity(
                                              0.4 +
                                                  _pulseController.value * 0.2,
                                            ),
                                    blurRadius:
                                        40 + _pulseController.value * 20,
                                    spreadRadius:
                                        5 + _pulseController.value * 10,
                                  ),
                                ],
                              ),
                              child: _isProcessing
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Icon(
                                      _isListening
                                          ? Icons.mic_rounded
                                          : Icons.mic_none_rounded,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Status Text
                      Text(
                        _isProcessing
                            ? 'Processing...'
                            : _isListening
                            ? 'Listening...'
                            : 'Tap to speak',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: _isListening || _isProcessing
                              ? const Color(0xFFEC4899)
                              : const Color(0xFF94A3B8),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _isProcessing
                            ? 'Getting AI response...'
                            : _isListening
                            ? _recognizedText.isEmpty
                                  ? 'Speak now...'
                                  : _recognizedText
                            : 'Ask me anything about AI models',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (_isListening) ...[
                        const SizedBox(height: 32),
                        AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(300, 60),
                              painter: SoundWavePainter(_waveController.value),
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 40),

                      // Conversation History
                      if (_conversationHistory.isNotEmpty) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Conversation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._conversationHistory.map(
                          (conv) => Column(
                            children: [
                              _buildMessageBubble(conv['user']!, isUser: true),
                              const SizedBox(height: 12),
                              _buildMessageBubble(conv['ai']!, isUser: false),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Quick Commands
                      const Text(
                        'Quick Commands',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildQuickCommand('Tell me about ANN'),
                          _buildQuickCommand('How does CNN work?'),
                          _buildQuickCommand('Predict stocks'),
                          _buildQuickCommand('What is RAG?'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Text Input Area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(top: BorderSide(color: Color(0xFF334155))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(color: Color(0xFF64748B)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _processMessage(value.trim());
                              _textController.clear();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (_textController.text.trim().isNotEmpty) {
                          _processMessage(_textController.text.trim());
                          _textController.clear();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                )
              : null,
          color: isUser ? null : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: isUser ? null : Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFFEC4899).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
                color: isUser ? Colors.white : const Color(0xFFEC4899),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.white : const Color(0xFFE2E8F0),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCommand(String text) {
    return InkWell(
      onTap: () => _handleQuickCommand(text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF6366F1),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class SoundWavePainter extends CustomPainter {
  final double animationValue;

  SoundWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEC4899)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barCount = 30;
    final barWidth = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;
      final heightMultiplier = math.sin(
        (animationValue * 2 * math.pi) + (i * 0.3),
      );
      final barHeight = 10 + (heightMultiplier.abs() * 30);

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SoundWavePainter oldDelegate) => true;
}
