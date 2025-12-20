import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart';
import 'voice_assistant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final authService = AuthService();
  bool _isModelsExpanded = false;
  bool _isSidebarVisible = false;
  late AnimationController _animationController;

  final List<AIModel> _models = [
    AIModel(
      name: 'ANN Model',
      description: 'Artificial Neural Network',
      icon: Icons.hub_rounded,
      gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
    AIModel(
      name: 'CNN Model',
      description: 'Convolutional Neural Network',
      icon: Icons.image_outlined,
      gradient: const [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    ),
    AIModel(
      name: 'Stock Prediction',
      description: 'Market Forecasting AI',
      icon: Icons.show_chart_rounded,
      gradient: const [Color(0xFFEC4899), Color(0xFFF43F5E)],
    ),
    AIModel(
      name: 'RAG Model',
      description: 'Retrieval-Augmented Generation',
      icon: Icons.auto_awesome_rounded,
      gradient: const [Color(0xFF10B981), Color(0xFF3B82F6)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          Container(
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
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        // Menu Button
                        IconButton(
                          onPressed: _toggleSidebar,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.menu_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Synthesia AI',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content Area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 20 : 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Welcome Header
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                            ).createShader(bounds),
                            child: Text(
                              'Welcome to Synthesia AI',
                              style: TextStyle(
                                fontSize: isMobile ? 32 : 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Description
                          Text(
                            'Your Advanced AI Models Platform',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 24,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w300,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Feature Cards
                          Container(
                            padding: EdgeInsets.all(isMobile ? 20 : 32),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF334155),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF6366F1),
                                            Color(0xFF8B5CF6),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.rocket_launch_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'What You Can Do',
                                        style: TextStyle(
                                          fontSize: isMobile ? 22 : 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                _buildFeatureItem(
                                  icon: Icons.hub_rounded,
                                  title: 'Neural Network Processing',
                                  description:
                                      'Leverage powerful ANN models for advanced pattern recognition and data analysis',
                                  gradient: const [
                                    Color(0xFF6366F1),
                                    Color(0xFF8B5CF6),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                _buildFeatureItem(
                                  icon: Icons.image_outlined,
                                  title: 'Image Analysis with CNN',
                                  description:
                                      'Process and analyze images using state-of-the-art convolutional neural networks',
                                  gradient: const [
                                    Color(0xFF8B5CF6),
                                    Color(0xFFEC4899),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                _buildFeatureItem(
                                  icon: Icons.show_chart_rounded,
                                  title: 'Market Predictions',
                                  description:
                                      'Get accurate stock market forecasts powered by advanced AI algorithms',
                                  gradient: const [
                                    Color(0xFFEC4899),
                                    Color(0xFFF43F5E),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                _buildFeatureItem(
                                  icon: Icons.auto_awesome_rounded,
                                  title: 'Context-Aware AI',
                                  description:
                                      'Experience intelligent responses with our Retrieval-Augmented Generation model',
                                  gradient: const [
                                    Color(0xFF10B981),
                                    Color(0xFF3B82F6),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                _buildFeatureItem(
                                  icon: Icons.mic_rounded,
                                  title: 'Voice Interaction',
                                  description:
                                      'Communicate naturally with AI using our advanced voice assistant technology',
                                  gradient: const [
                                    Color(0xFFEC4899),
                                    Color(0xFFF43F5E),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Quick Stats
                          isMobile
                              ? Column(
                                  children: [
                                    _buildStatCard(
                                      '4',
                                      'AI Models',
                                      Icons.psychology_rounded,
                                      const [
                                        Color(0xFF6366F1),
                                        Color(0xFF8B5CF6),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildStatCard(
                                      '24/7',
                                      'Availability',
                                      Icons.access_time_rounded,
                                      const [
                                        Color(0xFF8B5CF6),
                                        Color(0xFFEC4899),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildStatCard(
                                      '∞',
                                      'Possibilities',
                                      Icons.all_inclusive_rounded,
                                      const [
                                        Color(0xFF10B981),
                                        Color(0xFF3B82F6),
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        '4',
                                        'AI Models',
                                        Icons.psychology_rounded,
                                        const [
                                          Color(0xFF6366F1),
                                          Color(0xFF8B5CF6),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: _buildStatCard(
                                        '24/7',
                                        'Availability',
                                        Icons.access_time_rounded,
                                        const [
                                          Color(0xFF8B5CF6),
                                          Color(0xFFEC4899),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: _buildStatCard(
                                        '∞',
                                        'Possibilities',
                                        Icons.all_inclusive_rounded,
                                        const [
                                          Color(0xFF10B981),
                                          Color(0xFF3B82F6),
                                        ],
                                      ),
                                    ),
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

          // Sidebar Overlay
          if (_isSidebarVisible)
            GestureDetector(
              onTap: _toggleSidebar,
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),

          // Sidebar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarVisible ? 0 : (isMobile ? -280 : -300),
            top: 0,
            bottom: 0,
            child: Container(
              width: isMobile ? 280 : 300,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF000000),
                    blurRadius: 20,
                    offset: Offset(4, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Profile Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Profile Picture
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Welcome text
                          const Text(
                            'Welcome',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Username
                          Text(
                            user?.email?.split('@')[0] ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Email
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF334155).withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // AI Models Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // AI Models Button
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isModelsExpanded = !_isModelsExpanded;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF475569),
                                ),
                              ),
                              child: Row(
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
                                      Icons.psychology_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'AI Models',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: _isModelsExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 300),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Expandable Models List
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: _isModelsExpanded
                                ? Column(
                                    children: [
                                      const SizedBox(height: 8),
                                      ..._models.map(
                                        (model) => _buildModelItem(model),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Voice Assistant Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        onTap: () {
                          _toggleSidebar();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const VoiceAssistantScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEC4899).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Voice Assistant',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: InkWell(
                        onTap: () async {
                          await authService.signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WelcomeScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFEF4444),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelItem(AIModel model) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${model.name} selected'),
              backgroundColor: model.gradient[0],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(model.icon, color: model.gradient[0], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      model.description,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    List<Color> gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class AIModel {
  final String name;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  AIModel({
    required this.name,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
