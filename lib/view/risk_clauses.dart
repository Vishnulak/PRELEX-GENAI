import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiskFactorsSection extends StatefulWidget {
  final Map<String, dynamic> riskAnalysis;

  const RiskFactorsSection({
    Key? key,
    required this.riskAnalysis,
  }) : super(key: key);

  @override
  _RiskFactorsSectionState createState() => _RiskFactorsSectionState();
}

class _RiskFactorsSectionState extends State<RiskFactorsSection>
    with TickerProviderStateMixin {
  Set<int> expandedRisks = {};
  late AnimationController _slideController;
  late AnimationController _glowController;
  late AnimationController _networkController;

  // PRELEX Color Palette
  static const Color primaryCyan = Color(0xFF00D4FF);
  static const Color secondaryCyan = Color(0xFF0099CC);
  static const Color darkBackground = Color(0xFF0A1628);
  static const Color cardBackground = Color(0xFF1A2332);
  static const Color borderGlow = Color(0xFF00B8E6);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3D9F2);
  static const Color warningAccent = Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _networkController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Trigger slide-in animation
    Future.delayed(Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _glowController.dispose();
    _networkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final riskyClausesList = widget.riskAnalysis['risky_clauses'] as List? ?? [];
    final consequencesList = widget.riskAnalysis['real_world_consequences'] as List? ?? [];
    final summary = widget.riskAnalysis['summary'] as Map<String, dynamic>? ?? {};

    if (riskyClausesList.isEmpty) {
      return _buildNoRisksFound();
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
              _buildHeader(summary),
              SizedBox(height: 24),
              _buildRiskLevelIndicator(summary),
              SizedBox(height: 32),
              ...riskyClausesList.asMap().entries.map((entry) {
                int index = entry.key;
                String riskText = entry.value.toString();
                String consequence = index < consequencesList.length
                    ? consequencesList[index].toString()
                    : 'Potential impact on your contractual position';

                return _buildAnimatedRiskItem(index, riskText, consequence);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> summary) {
    final totalRisks = summary['total_risks'] ?? 0;
    final riskLevel = summary['risk_level'] ?? 'unknown';

    return AnimatedBuilder(
      animation: _glowController,
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
              color: primaryCyan.withOpacity(0.6 + 0.4 * _glowController.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryCyan.withOpacity(0.3 + 0.2 * _glowController.value),
                blurRadius: 20 + 10 * _glowController.value,
                spreadRadius: 2 + _glowController.value * 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildNetworkIcon(),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RISK ANALYSIS',
                          style: GoogleFonts.orbitron(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(
                                color: primaryCyan.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '$totalRisks POTENTIAL ISSUES • LEVEL: ${riskLevel.toUpperCase()}',
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
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: primaryCyan.withOpacity(0.1),
                  border: Border.all(color: primaryCyan.withOpacity(0.3)),
                ),
                child: Text(
                  'Tap each risk item below to reveal detailed consequences',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNetworkIcon() {
    return AnimatedBuilder(
      animation: _networkController,
      builder: (context, child) {
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                primaryCyan.withOpacity(0.8),
                primaryCyan.withOpacity(0.2),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryCyan.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              Transform.rotate(
                angle: _networkController.value * 2 * 3.14159,
                child: Icon(
                  Icons.blur_circular,
                  color: primaryCyan,
                  size: 30,
                ),
              ),
              // Inner icon
              Icon(
                Icons.analytics_outlined,
                color: textPrimary,
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiskLevelIndicator(Map<String, dynamic> summary) {
    final riskLevel = summary['risk_level'] ?? 'unknown';
    final criticalRisks = summary['critical_risks'] ?? 0;
    final highRisks = summary['high_risks'] ?? 0;
    final mediumHighRisks = summary['medium_high_risks'] ?? 0;
    final recommendation = summary['recommendation'] ?? 'Review document carefully';

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardBackground,
                cardBackground.withOpacity(0.8),
                darkBackground,
              ],
            ),
            border: Border.all(
              color: secondaryCyan.withOpacity(0.5 + 0.3 * _glowController.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: secondaryCyan.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: warningAccent.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.speed,
                      color: warningAccent,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'ASSESSMENT OVERVIEW',
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                recommendation,
                style: GoogleFonts.rajdhani(
                  fontSize: 18,
                  color: textSecondary,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  if (criticalRisks > 0)
                    _buildRiskCountChip('CRITICAL', criticalRisks, Color(0xFFFF6B6B)),
                  if (highRisks > 0)
                    _buildRiskCountChip('HIGH', highRisks, Color(0xFFFFB347)),
                  if (mediumHighRisks > 0)
                    _buildRiskCountChip('MEDIUM-HIGH', mediumHighRisks, warningAccent),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiskCountChip(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        '$label: $count',
        style: GoogleFonts.rajdhani(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildAnimatedRiskItem(int index, String riskText, String consequence) {
    final isExpanded = expandedRisks.contains(index);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
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
                  color: isExpanded
                      ? primaryCyan.withOpacity(0.8)
                      : borderGlow.withOpacity(0.3),
                  width: isExpanded ? 2 : 1,
                ),
                boxShadow: [
                  if (isExpanded)
                    BoxShadow(
                      color: primaryCyan.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  splashColor: primaryCyan.withOpacity(0.2),
                  highlightColor: primaryCyan.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        expandedRisks.remove(index);
                      } else {
                        expandedRisks.add(index);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildRiskNumberBadge(index),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _cleanRiskText(riskText),
                                style: GoogleFonts.rajdhani(
                                  color: textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            _buildExpandIcon(isExpanded),
                          ],
                        ),
                        _buildConsequencesSection(consequence, isExpanded),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRiskNumberBadge(int index) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            primaryCyan.withOpacity(0.8),
            primaryCyan.withOpacity(0.3),
          ],
        ),
        border: Border.all(
          color: primaryCyan,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryCyan.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: GoogleFonts.orbitron(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandIcon(bool isExpanded) {
    return AnimatedRotation(
      turns: isExpanded ? 0.5 : 0,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryCyan.withOpacity(0.2),
          border: Border.all(
            color: primaryCyan.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.keyboard_arrow_down,
          color: primaryCyan,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildConsequencesSection(String consequence, bool isExpanded) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      height: isExpanded ? null : 0,
      margin: isExpanded ? EdgeInsets.only(top: 20) : EdgeInsets.zero,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: isExpanded ? 1.0 : 0.0,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                darkBackground,
                cardBackground.withOpacity(0.5),
              ],
            ),
            border: Border.all(
              color: warningAccent.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: warningAccent,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'POTENTIAL CONSEQUENCES',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: warningAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                _cleanConsequenceText(consequence),
                style: GoogleFonts.rajdhani(
                  color: textSecondary,
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoRisksFound() {
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
          animation: _glowController,
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
                  color: Color(0xFF00E676).withOpacity(0.6 + 0.4 * _glowController.value),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00E676).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFF00E676).withOpacity(0.8),
                          Color(0xFF00E676).withOpacity(0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF00E676).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.verified_outlined,
                      color: textPrimary,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'ANALYSIS COMPLETE',
                    style: GoogleFonts.orbitron(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No significant risks detected in this document.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      fontSize: 18,
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

  String _cleanRiskText(String text) {
    return text.replaceAll(RegExp(r'^[🚨⚠️⚡📋ℹ️]*\s*\d+\.\s*'), '').trim();
  }

  String _cleanConsequenceText(String text) {
    return text.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
  }
}