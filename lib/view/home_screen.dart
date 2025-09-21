import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui';
import 'chatbot_screen.dart';
import 'upload_section.dart';
import 'risk_clauses.dart';
import 'comparitive_justice.dart';

void main() {
  runApp(PrelexApp());
}

class PrelexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRELEX',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF0A1930),
      ),
      home: PrelexHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PrelexHomePage extends StatefulWidget {
  @override
  _PrelexHomePageState createState() => _PrelexHomePageState();
}

class _PrelexHomePageState extends State<PrelexHomePage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _uploadSectionKey = GlobalKey();
  final GlobalKey _resultsSectionKey = GlobalKey();

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _typewriterController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _typewriterAnimation;

  bool _isHovering = false;
  bool _isScrolled = false;
  bool _showResults = false;
  Map<String, dynamic>? _analysisResults;

  // Typewriter text
  final String _typewriterText = 'Never Sign Blind Again';
  String _displayText = '';

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _typewriterController = AnimationController(
      duration: Duration(milliseconds: 2500),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _typewriterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typewriterController,
      curve: Curves.easeInOut,
    ));

    // Animation listeners
    _typewriterAnimation.addListener(() {
      setState(() {
        int endIndex = (_typewriterAnimation.value * _typewriterText.length).round();
        _displayText = _typewriterText.substring(0, endIndex);
      });
    });

    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    });

    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 50;
      });
    });

    // Start animations with delays
    _startInitialAnimations();
  }

  void _startInitialAnimations() async {
    await Future.delayed(Duration(milliseconds: 300));
    _fadeController.forward();

    await Future.delayed(Duration(milliseconds: 200));
    _slideController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    _scaleController.forward();

    await Future.delayed(Duration(milliseconds: 500));
    _typewriterController.forward();

    _rotationController.repeat();
    _pulseController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _typewriterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Callback function for when analysis completes
  void _onAnalysisComplete(Map<String, dynamic> results) {
    setState(() {
      _analysisResults = results;
      _showResults = true;
    });

    // Smooth scroll to results section
    Future.delayed(Duration(milliseconds: 500), () {
      _scrollToResults();
    });
  }

  void _scrollToResults() {
    if (_resultsSectionKey.currentContext != null) {
      Scrollable.ensureVisible(
        _resultsSectionKey.currentContext!,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToUpload() {
    if (_uploadSectionKey.currentContext != null) {
      Scrollable.ensureVisible(
        _uploadSectionKey.currentContext!,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToFeatures() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent - 800,
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  void _openChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimpleChatbotApp(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Enhanced Background with particle network
          ParticleNetworkBackground(),

          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero Section
              SliverToBoxAdapter(child: _buildHeroSection()),

              // Upload Section
              SliverToBoxAdapter(
                child: Container(
                  key: _uploadSectionKey,
                  child: UploadSection(
                    onAnalysisComplete: _onAnalysisComplete,
                  ),
                ),
              ),

              // Results Section (only shown after analysis) - CLEAN VERSION
              if (_showResults && _analysisResults != null)
                SliverToBoxAdapter(
                  child: Container(
                    key: _resultsSectionKey,
                    child: _buildCleanResultsSection(),
                  ),
                ),

              // Features Section (always shown at bottom)
              SliverToBoxAdapter(child: _buildFeaturesSection()),

              // Footer Section
              SliverToBoxAdapter(child: _buildFooterSection()),
            ],
          ),

          // Simple Navigation Bar
          _buildNavigationBar(),

          // Scroll-to-top FAB (when scrolled)
          if (_isScrolled) _buildScrollToTopFAB(),

          // Chatbot FAB (always visible)
          _buildChatbotFAB(),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: 80,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: _isScrolled
              ? Color(0xFF0A1930).withOpacity(0.95)
              : Colors.transparent,
          border: _isScrolled
              ? Border(bottom: BorderSide(color: Color(0xFF2196F3).withOpacity(0.2), width: 1))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // PRELEX on the left with rotation animation
            GestureDetector(
              onTap: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 800),
                  curve: Curves.easeInOutCubic,
                );
              },
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Color(0xFF2196F3),
                          Color(0xFF21CBF3),
                          Colors.white,
                        ],
                        stops: [0.0, 0.5, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'PRELEX',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3.0,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 0),
                              blurRadius: 15,
                              color: Color(0xFF2196F3).withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation Items on the right with slide animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.easeOutBack,
                )),
                child: Row(
                  children: [
                    _simpleNavItem('HOME'),
                    SizedBox(width: 48),
                    _simpleNavItem('FEATURES'),
                    SizedBox(width: 48),
                    if (_showResults)
                      _simpleNavItem('RESULTS'),
                    if (_showResults) SizedBox(width: 48),
                    _simpleNavItem('SIGN OUT'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleNavItem(String text) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (text == 'RESULTS' && _showResults) {
            _scrollToResults();
          } else if (text == 'FEATURES') {
            _scrollToFeatures();
          }
        },
        child: AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 300),
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Text(text),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScrollToTopFAB() {
    return Positioned(
      bottom: 100,
      right: 30,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _scaleController,
            curve: Curves.elasticOut,
          ),
        ),
        child: AnimatedOpacity(
          opacity: _isScrolled ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2196F3),
                        Color(0xFF1976D2),
                        Color(0xFF0D47A1),
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF2196F3).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _scrollController.animateTo(
                          0,
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      borderRadius: BorderRadius.circular(28),
                      child: Center(
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChatbotFAB() {
    return Positioned(
      bottom: 30,
      right: 30,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 0.1, // Subtle rotation
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF00E5FF),
                      Color(0xFF00B2FF),
                      Color(0xFF0091EA),
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00E5FF).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 0,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openChatbot,
                    borderRadius: BorderRadius.circular(28),
                    child: Center(
                      child: Icon(
                        Icons.smart_toy_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1930),
            Color(0xFF051015),
            Colors.transparent,
          ],
          stops: [0.0, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background image with fade animation
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/home.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content with slide animation
          Padding(
            padding: EdgeInsets.fromLTRB(60, 90, 60, 60),
            child: Row(
              children: [
                // Left side content
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Typewriter effect for main heading
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      Color(0xFF2196F3),
                                      Color(0xFF21CBF3),
                                      Colors.white,
                                      Color(0xFF64B5F6),
                                    ],
                                    stops: [0.0, 0.3, 0.7, 1.0],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: AnimatedBuilder(
                                    animation: _typewriterAnimation,
                                    builder: (context, child) {
                                      return Text(
                                        _displayText,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 58,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                          height: 1.1,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0, 0),
                                              blurRadius: 20,
                                              color: Color(0xFF2196F3).withOpacity(0.4),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(height: 24),

                              // Subtitle with slide animation
                              SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(-0.3, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: _slideController,
                                  curve: Interval(0.3, 1.0, curve: Curves.easeOut),
                                )),
                                child: FadeTransition(
                                  opacity: Tween<double>(begin: 0, end: 1).animate(
                                    CurvedAnimation(
                                      parent: _fadeController,
                                      curve: Interval(0.4, 1.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Decode contracts instantly with AI precision.\nMake informed decisions, protect your interests.',
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 0.2,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 48),

                              // Button with scale and pulse animations
                              ScaleTransition(
                                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _scaleController,
                                    curve: Interval(0.5, 1.0, curve: Curves.elasticOut),
                                  ),
                                ),
                                child: MouseRegion(
                                  onEnter: (_) => setState(() => _isHovering = true),
                                  onExit: (_) => setState(() => _isHovering = false),
                                  child: AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _isHovering ? _pulseAnimation.value * 1.05 : 1.0,
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          decoration: BoxDecoration(
                                            color: _isHovering
                                                ? Color(0xFF21CBF3).withOpacity(0.1)
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: Color(0xFF21CBF3),
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: _isHovering ? [
                                              BoxShadow(
                                                color: Color(0xFF21CBF3).withOpacity(0.3),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                              ),
                                            ] : [],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(8),
                                              onTap: _scrollToUpload,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                                                child: Text(
                                                  'Analyze Document',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF21CBF3),
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right side for background image space
                Expanded(
                  flex: 4,
                  child: SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CLEAN RESULTS SECTION - Summary + Risk Factors + Comparative Justice
  Widget _buildCleanResultsSection() {
    if (_analysisResults == null) return SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_slideController),
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Column(
            children: [
              // Results Header
              _buildSectionHeader(
                'ANALYSIS RESULTS',
                'Comprehensive AI-powered insights for your document',
                Icons.analytics,
                Color(0xFF2196F3),
              ),

              SizedBox(height: 40),

              // Document Summary Section
              _buildDocumentSummary(),

              SizedBox(height: 40),

              // Risk Factors Section
              RiskFactorsSection(riskAnalysis: _analysisResults!['risk_analysis']),

              SizedBox(height: 30),

              // Comparative Justice Section
              ComparativeJusticeSection(riskAnalysis: _analysisResults!['risk_analysis']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentSummary() {
    final summary = _analysisResults!['summary'];
    final docInfo = _analysisResults!['document_info'];

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color(0xFF2196F3).withOpacity(0.3),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2196F3).withOpacity(0.05),
              Colors.black.withOpacity(0.8),
              Color(0xFF21CBF3).withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF2196F3).withOpacity(0.2),
                                Color(0xFF21CBF3).withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.description,
                            color: Color(0xFF21CBF3),
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DOCUMENT SUMMARY',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${docInfo['filename']} • ${docInfo['contract_type']?.toString().toUpperCase()}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Summary Content with fade animation
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _fadeController,
                  curve: Interval(0.3, 1.0),
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.3),
                  border: Border.all(
                    color: Color(0xFF2196F3).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: _buildFormattedSummary(summary['summary_text'] ?? 'No summary available'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedSummary(String summaryText) {
    final lines = summaryText.split('\n');
    List<Widget> widgets = [];
    int animationDelay = 0;

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        widgets.add(SizedBox(height: 12));
        continue;
      }

      animationDelay += 100;

      // Main section headers (marked with **)
      if (line.startsWith('**') && line.endsWith('**')) {
        String headerText = line.replaceAll('**', '');
        widgets.add(
          _DelayedAnimationWidget(
            delay: animationDelay,
            child: Padding(
              padding: EdgeInsets.only(top: 20, bottom: 12),
              child: Text(
                headerText.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2196F3),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      }
      // Bullet points or sub-items (starting with -)
      else if (line.startsWith('-') || line.startsWith('•')) {
        String bulletText = line.replaceFirst(RegExp(r'^[-•]\s*'), '');
        widgets.add(
          _DelayedAnimationWidget(
            delay: animationDelay,
            child: Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8, right: 12),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Color(0xFF21CBF3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      bulletText,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      // Regular paragraph text
      else {
        widgets.add(
          _DelayedAnimationWidget(
            delay: animationDelay,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                line,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: 60),
      child: Column(
        children: [
          // Section title with staggered animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 0.5),
                end: Offset.zero,
              ).animate(_slideController),
              child: Text(
                'POWERFUL AI ANALYSIS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _fadeController,
                curve: Interval(0.3, 1.0),
              ),
            ),
            child: Text(
              'Advanced legal intelligence at your fingertips',
              style: GoogleFonts.inter(
                fontSize: 20,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ),

          SizedBox(height: 80),

          // Feature cards in Row layout with staggered animations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAnimatedFeatureCard(
                Icons.search_outlined,
                'INSTANT ANALYSIS',
                'Get comprehensive contract analysis in seconds, not hours',
                0,
              ),
              _buildAnimatedFeatureCard(
                Icons.shield_outlined,
                'RISK DETECTION',
                'Identify potential legal risks and unfavorable clauses automatically',
                200,
              ),
              _buildAnimatedFeatureCard(
                Icons.lightbulb_outline,
                'SMART INSIGHTS',
                'Receive actionable recommendations to protect your interests',
                400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFeatureCard(IconData icon, String title, String description, int delay) {
    return _DelayedAnimationWidget(
      delay: delay,
      child: MouseRegion(
        onEnter: (_) {},
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 300,
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(0xFF2196F3).withOpacity(0.3),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2196F3).withOpacity(0.05),
                Colors.black.withOpacity(0.8),
                Color(0xFF21CBF3).withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF2196F3).withOpacity(0.2),
                            Color(0xFF21CBF3).withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 48,
                        color: Color(0xFF21CBF3),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 24),

              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),

              SizedBox(height: 16),

              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 0.1,
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.2),
                            color.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Icon(icon, size: 32, color: color),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 20,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF2196F3).withOpacity(0.3),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2196F3).withOpacity(0.05),
            Colors.black.withOpacity(0.8),
            Color(0xFF21CBF3).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2196F3).withOpacity(0.2),
                  Color(0xFF21CBF3).withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              icon,
              size: 48,
              color: Color(0xFF21CBF3),
            ),
          ),

          SizedBox(height: 24),

          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),

          SizedBox(height: 16),

          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 60, horizontal: 60),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Color(0xFF0A1930).withOpacity(0.8),
              Color(0xFF051015),
            ],
          ),
        ),
        child: Column(
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Text(
                'PRELEX',
                style: GoogleFonts.orbitron(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF21CBF3),
                  letterSpacing: 3.0,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Advanced Legal Document Analysis Platform',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 32),
            Text(
              '© 2024 PRELEX. All rights reserved.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Particle Network Background
class ParticleNetworkBackground extends StatefulWidget {
  @override
  _ParticleNetworkBackgroundState createState() =>
      _ParticleNetworkBackgroundState();
}

class _ParticleNetworkBackgroundState extends State<ParticleNetworkBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;
  final int particleCount = 80;
  final double connectionDistance = 120.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 16), // ~60 FPS
      vsync: this,
    )..repeat();

    particles = [];
    _controller.addListener(() {
      setState(() {
        _updateParticles();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeParticles(Size size) {
    if (particles.isEmpty) {
      final random = math.Random();
      for (int i = 0; i < particleCount; i++) {
        particles.add(Particle(
          x: random.nextDouble() * size.width,
          y: random.nextDouble() * size.height,
          vx: (random.nextDouble() - 0.5) * 0.3,
          vy: (random.nextDouble() - 0.5) * 0.3,
          size: random.nextDouble() * 2 + 0.5,
          opacity: random.nextDouble() * 0.6 + 0.2,
        ));
      }
    }
  }

  void _updateParticles() {
    final size = MediaQuery.of(context).size;

    for (var particle in particles) {
      particle.x += particle.vx;
      particle.y += particle.vy;

      // Bounce off edges
      if (particle.x <= 0 || particle.x >= size.width) {
        particle.vx *= -1;
      }
      if (particle.y <= 0 || particle.y >= size.height) {
        particle.vy *= -1;
      }

      // Keep particles within bounds
      particle.x = particle.x.clamp(0.0, size.width);
      particle.y = particle.y.clamp(0.0, size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    _initializeParticles(screenSize);

    return Container(
      width: screenSize.width,
      height: screenSize.height * 4, // Cover all sections
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1930),
            Color(0xFF051015),
            Color(0xFF0A1930),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: ParticleNetworkPainter(
          particles: particles,
          connectionDistance: connectionDistance,
        ),
        size: screenSize,
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
  });
}

class ParticleNetworkPainter extends CustomPainter {
  final List<Particle> particles;
  final double connectionDistance;

  ParticleNetworkPainter({
    required this.particles,
    required this.connectionDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawConnections(canvas);
    _drawParticles(canvas);
  }

  void _drawConnections(Canvas canvas) {
    final connectionPaint = Paint()
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final particle1 = particles[i];
        final particle2 = particles[j];

        final distance = math.sqrt(
          math.pow(particle1.x - particle2.x, 2) +
              math.pow(particle1.y - particle2.y, 2),
        );

        if (distance < connectionDistance) {
          final opacity = (1 - distance / connectionDistance) * 0.4;

          final shader = ui.Gradient.linear(
            Offset(particle1.x, particle1.y),
            Offset(particle2.x, particle2.y),
            [
              Color(0xFF2196F3).withOpacity(opacity),
              Color(0xFF21CBF3).withOpacity(opacity * 0.7),
              Color(0xFF64B5F6).withOpacity(opacity * 0.5),
            ],
            [0.0, 0.5, 1.0],
          );

          connectionPaint.shader = shader;

          canvas.drawLine(
            Offset(particle1.x, particle1.y),
            Offset(particle2.x, particle2.y),
            connectionPaint,
          );
        }
      }
    }
  }

  void _drawParticles(Canvas canvas) {
    for (var particle in particles) {
      // Glow effect
      final glowPaint = Paint()
        ..color = Color(0xFF2196F3).withOpacity(particle.opacity * 0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 3);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 4,
        glowPaint,
      );

      // Main particle
      final particlePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Color(0xFF2196F3).withOpacity(particle.opacity),
            Color(0xFF21CBF3).withOpacity(particle.opacity * 0.8),
            Color(0xFF64B5F6).withOpacity(particle.opacity * 0.6),
          ],
          stops: [0.0, 0.7, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(particle.x, particle.y),
            radius: particle.size,
          ),
        );

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        particlePaint,
      );

      // Core
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity * 0.8);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 0.2,
        corePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Helper widget for delayed animations
class _DelayedAnimationWidget extends StatefulWidget {
  final Widget child;
  final int delay;

  const _DelayedAnimationWidget({
    Key? key,
    required this.child,
    required this.delay,
  }) : super(key: key);

  @override
  _DelayedAnimationWidgetState createState() => _DelayedAnimationWidgetState();
}

class _DelayedAnimationWidgetState extends State<_DelayedAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start animation after delay
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}