import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class ComparativeJusticeSection extends StatefulWidget {
  final Map<String, dynamic> riskAnalysis;

  const ComparativeJusticeSection({
    Key? key,
    required this.riskAnalysis,
  }) : super(key: key);

  @override
  _ComparativeJusticeSectionState createState() => _ComparativeJusticeSectionState();
}

class _ComparativeJusticeSectionState extends State<ComparativeJusticeSection>
    with TickerProviderStateMixin {
  Map<int, bool> flippedCards = {};
  Map<int, AnimationController> flipControllers = {};
  late AnimationController _masterController;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  // PRELEX Color Palette
  static const Color primaryCyan = Color(0xFF00D4FF);
  static const Color secondaryCyan = Color(0xFF0099CC);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color darkBackground = Color(0xFF0A1628);
  static const Color cardBackground = Color(0xFF1A2332);
  static const Color successGreen = Color(0xFF00E676);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3D9F2);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final comparativeJusticeList = widget.riskAnalysis['comparative_justice'] as List? ?? [];

    _masterController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    for (int i = 0; i < comparativeJusticeList.length; i++) {
      flipControllers[i] = AnimationController(
        duration: Duration(milliseconds: 800),
        vsync: this,
      );
      flippedCards[i] = false;
    }

    // Start animations
    Future.delayed(Duration(milliseconds: 300), () {
      _masterController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    flipControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comparativeJusticeList = widget.riskAnalysis['comparative_justice'] as List? ?? [];
    final negotiationTipsList = widget.riskAnalysis['negotiation_tips'] as List? ?? [];

    if (comparativeJusticeList.isEmpty) {
      return _buildNoDataAvailable();
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _slideController,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24),
              _buildInstructions(),
              SizedBox(height: 32),
              _buildCardsGrid(comparativeJusticeList, negotiationTipsList),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                darkBackground,
                cardBackground,
                darkBackground.withOpacity(0.8),
              ],
            ),
            border: Border.all(
              color: successGreen.withOpacity(0.6 + 0.4 * _pulseController.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: successGreen.withOpacity(0.3 + 0.2 * _pulseController.value),
                blurRadius: 20 + 10 * _pulseController.value,
                spreadRadius: 2 + _pulseController.value * 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildBalanceIcon(),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPARATIVE JUSTICE',
                      style: GoogleFonts.orbitron(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: successGreen.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Contract terms vs. industry standards',
                      style: GoogleFonts.rajdhani(
                        fontSize: 18,
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceIcon() {
    return AnimatedBuilder(
      animation: _masterController,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                successGreen.withOpacity(0.8),
                successGreen.withOpacity(0.2),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: successGreen.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _masterController.value * 0.5,
                child: Icon(
                  Icons.account_balance,
                  color: textPrimary,
                  size: 30,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            cardBackground,
            darkBackground.withOpacity(0.8),
          ],
        ),
        border: Border.all(
          color: primaryCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryCyan.withOpacity(0.2),
            ),
            child: Icon(
              Icons.touch_app,
              color: primaryCyan,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: 'FRONT: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: successGreen,
                    ),
                  ),
                  TextSpan(text: 'Industry comparison • '),
                  TextSpan(
                    text: 'BACK: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: accentBlue,
                    ),
                  ),
                  TextSpan(text: 'Negotiation strategies • '),
                  TextSpan(
                    text: 'TAP TO FLIP',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: primaryCyan,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsGrid(List comparativeJusticeList, List negotiationTipsList) {
    return StaggeredAnimationGrid(
      controller: _masterController,
      children: List.generate(
        comparativeJusticeList.length,
            (index) {
          String comparativeText = _cleanText(comparativeJusticeList[index].toString());
          String negotiationText = index < negotiationTipsList.length
              ? _cleanText(negotiationTipsList[index].toString())
              : 'Seek professional legal advice for this issue.';

          return _buildFlippableCard(index, comparativeText, negotiationText);
        },
      ),
    );
  }

  Widget _buildFlippableCard(int index, String frontText, String backText) {
    return GestureDetector(
      onTap: () => _flipCard(index),
      child: Container(
        margin: EdgeInsets.only(bottom: 20), // Fixed: Move margin to outer container
        child: AnimatedBuilder(
          animation: flipControllers[index]!,
          builder: (context, child) {
            final isShowingFront = flipControllers[index]!.value < 0.5;
            final flipValue = flipControllers[index]!.value;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isShowingFront ? successGreen : accentBlue).withOpacity(0.3),
                    blurRadius: 15 + 5 * flipValue,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(flipValue * math.pi),
                child: isShowingFront
                    ? _buildCardFront(index, frontText)
                    : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateX(math.pi),
                  child: _buildCardBack(index, backText),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFront(int index, String text) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 200),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardBackground,
            darkBackground.withOpacity(0.9),
            cardBackground.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: successGreen.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      successGreen.withOpacity(0.8),
                      successGreen.withOpacity(0.3),
                    ],
                  ),
                  border: Border.all(color: successGreen, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.orbitron(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INDUSTRY COMPARISON',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: successGreen,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'vs. Fair Standards',
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: successGreen.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.compare_arrows,
                  color: successGreen,
                  size: 18,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          Text(
            text,
            style: GoogleFonts.rajdhani(
              color: textPrimary,
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: successGreen.withOpacity(0.2),
                  border: Border.all(color: successGreen.withOpacity(0.3)),
                ),
                child: Text(
                  'COMPARISON',
                  style: GoogleFonts.rajdhani(
                    color: successGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryCyan.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.flip,
                  color: primaryCyan,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(int index, String text) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 200),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardBackground,
            darkBackground.withOpacity(0.9),
            cardBackground.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: accentBlue.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentBlue.withOpacity(0.8),
                      accentBlue.withOpacity(0.3),
                    ],
                  ),
                  border: Border.all(color: accentBlue, width: 1.5),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: textPrimary,
                  size: 18,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEGOTIATION STRATEGY',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: accentBlue,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'Actionable Tips',
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentBlue.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.handshake,
                  color: accentBlue,
                  size: 18,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          Text(
            text,
            style: GoogleFonts.rajdhani(
              color: textPrimary,
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: accentBlue.withOpacity(0.2),
                  border: Border.all(color: accentBlue.withOpacity(0.3)),
                ),
                child: Text(
                  'SOLUTION',
                  style: GoogleFonts.rajdhani(
                    color: accentBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryCyan.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.flip,
                  color: primaryCyan,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _flipCard(int index) {
    if (flippedCards[index]!) {
      flipControllers[index]!.reverse();
    } else {
      flipControllers[index]!.forward();
    }
    setState(() {
      flippedCards[index] = !flippedCards[index]!;
    });
  }

  Widget _buildNoDataAvailable() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _slideController,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(32),
              margin: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    darkBackground,
                    cardBackground,
                    darkBackground.withOpacity(0.8),
                  ],
                ),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.4 + 0.3 * _pulseController.value),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withOpacity(0.2),
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'NO COMPARATIVE DATA',
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Comparative analysis data is not available for this document.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      color: textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _cleanText(String text) {
    return text.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
  }
}

// Custom Widget for Staggered Animation
class StaggeredAnimationGrid extends StatelessWidget {
  final List<Widget> children;
  final AnimationController controller;

  const StaggeredAnimationGrid({
    Key? key,
    required this.children,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        final animationDelay = index * 150; // milliseconds delay between cards

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + animationDelay),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, _) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}