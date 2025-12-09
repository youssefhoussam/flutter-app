import 'package:flutter/material.dart';
import 'dart:math' as math;

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with TickerProviderStateMixin {
  bool _isListening = false;
  String _recognizedText = '';
  String _responseText = '';
  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _recognizedText = 'Listening...';
        _responseText = '';
        // Simulate recognition after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (_isListening) {
            setState(() {
              _recognizedText = 'How can AI help me with stock predictions?';
              _responseText =
                  'I can help you analyze market trends, predict stock movements using advanced algorithms, and provide insights based on historical data. Would you like to explore our Stock Prediction model?';
              _isListening = false;
            });
          }
        });
      }
    });
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
                    const Text(
                      'Voice Assistant',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                      const SizedBox(height: 40),

                      // Animated Microphone
                      GestureDetector(
                        onTap: _toggleListening,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: _isListening
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
                                        (_isListening
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
                              child: Icon(
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

                      const SizedBox(height: 40),

                      // Status Text
                      Text(
                        _isListening ? 'Listening...' : 'Tap to speak',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: _isListening
                              ? const Color(0xFFEC4899)
                              : const Color(0xFF94A3B8),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        _isListening
                            ? 'Speak now, I\'m listening...'
                            : 'Ask me anything about AI models',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (_isListening) ...[
                        const SizedBox(height: 40),
                        // Sound Wave Animation
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

                      const SizedBox(height: 60),

                      // Recognized Text
                      if (_recognizedText.isNotEmpty &&
                          _recognizedText != 'Listening...') ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'You',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _recognizedText,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Response Text
                      if (_responseText.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEC4899).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.smart_toy_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI Assistant',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _responseText,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      // Quick Actions
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCommand(String text) {
    return InkWell(
      onTap: () {
        setState(() {
          _recognizedText = text;
          _responseText = 'Processing your question about "${text}"...';
        });
      },
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
