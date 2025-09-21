import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math' as math;

class UploadSection extends StatefulWidget {
  final Function(Map<String, dynamic>)? onAnalysisComplete;

  const UploadSection({Key? key, this.onAnalysisComplete}) : super(key: key);

  @override
  _UploadSectionState createState() => _UploadSectionState();
}

class _UploadSectionState extends State<UploadSection>
    with TickerProviderStateMixin {
  bool _isUploadHovering = false;
  bool _isProcessing = false;
  String _processStatus = '';

  // Animation controllers
  late AnimationController _headerAnimationController;
  late AnimationController _uploadBoxAnimationController;
  late AnimationController _processingAnimationController;
  late AnimationController _errorAnimationController;
  late AnimationController _successAnimationController;
  late AnimationController _pulseAnimationController;

  // Animations
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _uploadBoxScaleAnimation;
  late Animation<Offset> _uploadBoxSlideAnimation;
  late Animation<double> _processingFadeAnimation;
  late Animation<double> _processingScaleAnimation;
  late Animation<double> _errorShakeAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _pulseAnimation;

  // Flask service URLs - Updated with correct configurations
  static const List<String> _serviceUrls = [
    'http://127.0.0.1:5000',
    'http://localhost:5000',
  ];

  // Processing results
  Map<String, dynamic>? _processedData;
  String? _lastError;
  String? _workingServiceUrl;
  String? _uploadedFileName;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimations();
  }

  void _initializeAnimations() {
    // Header animations
    _headerAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutQuart,
      ),
    );
    _headerSlideAnimation = Tween<Offset>(
      begin: Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Upload box animations
    _uploadBoxAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _uploadBoxScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _uploadBoxAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _uploadBoxSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _uploadBoxAnimationController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Processing animations
    _processingAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _processingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _processingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _processingScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _processingAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Error shake animation
    _errorAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _errorShakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _errorAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Success animation
    _successAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _successScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Pulse animation for upload box
    _pulseAnimationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startEntryAnimations() async {
    await Future.delayed(Duration(milliseconds: 300));
    _headerAnimationController.forward();

    await Future.delayed(Duration(milliseconds: 200));
    _uploadBoxAnimationController.forward();

    // Start subtle pulse animation
    _pulseAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _uploadBoxAnimationController.dispose();
    _processingAnimationController.dispose();
    _errorAnimationController.dispose();
    _successAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          // Upload section
          Container(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Header
                    _buildAnimatedHeader(),

                    SizedBox(height: 60),

                    // Upload Box - show only if no document is processed
                    if (_processedData == null) _buildAnimatedUploadBox(),

                    // Animated Processing Status
                    if (_isProcessing) _buildAnimatedProcessingIndicator(),

                    // Animated Error Display
                    if (_lastError != null) _buildAnimatedErrorDisplay(),

                    // Animated uploaded document info when analysis is complete
                    if (_processedData != null && _uploadedFileName != null)
                      _buildAnimatedUploadedDocumentInfo(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: FadeTransition(
        opacity: _headerFadeAnimation,
        child: Column(
          children: [
            // Main title with scale animation
            ScaleTransition(
              scale: _headerFadeAnimation,
              child: Text(
                'UPLOAD YOUR DOCUMENT',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            SizedBox(height: 16),

            // Subtitle with delayed fade
            AnimatedBuilder(
              animation: _headerAnimationController,
              builder: (context, child) {
                final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0)
                    .animate(CurvedAnimation(
                  parent: _headerAnimationController,
                  curve: Interval(0.3, 1.0, curve: Curves.easeOut),
                ));

                return FadeTransition(
                  opacity: delayedAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(delayedAnimation),
                    child: Text(
                      'GET INSTANT AI-POWERED LEGAL ANALYSIS AND PROTECTION INSIGHTS',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedUploadBox() {
    return SlideTransition(
      position: _uploadBoxSlideAnimation,
      child: ScaleTransition(
        scale: _uploadBoxScaleAnimation,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isUploadHovering ? _pulseAnimation.value : 1.0,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isUploadHovering = true),
                onExit: (_) => setState(() => _isUploadHovering = false),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 600,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isUploadHovering
                          ? Color(0xFF2196F3)
                          : Color(0xFF2196F3).withOpacity(0.5),
                      width: 2,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2196F3).withOpacity(_isUploadHovering ? 0.1 : 0.05),
                        Colors.black.withOpacity(_isUploadHovering ? 0.8 : 0.9),
                        Color(0xFF21CBF3).withOpacity(_isUploadHovering ? 0.1 : 0.05),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF2196F3).withOpacity(_isUploadHovering ? 0.3 : 0.1),
                        blurRadius: _isUploadHovering ? 30 : 15,
                        spreadRadius: _isUploadHovering ? 5 : 0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _isProcessing ? null : _pickAndProcessFile,
                      child: _buildUploadBoxContent(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUploadBoxContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated upload icon
        TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: _isUploadHovering ? math.sin(value * math.pi * 2) * 0.1 : 0,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2196F3).withOpacity(0.2),
                      Color(0xFF21CBF3).withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Color(0xFF2196F3).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  size: 60,
                  color: Color(0xFF21CBF3),
                ),
              ),
            );
          },
        ),

        SizedBox(height: 24),

        // Animated text
        AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 300),
          style: GoogleFonts.spaceGrotesk(
            fontSize: _isUploadHovering ? 24 : 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
          child: Text('DRAG & DROP OR CLICK TO UPLOAD'),
        ),

        SizedBox(height: 12),

        Text(
          'SUPPORTS PDF, DOC, DOCX FILES UP TO 20MB',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),

        SizedBox(height: 20),

        // Animated file type chips
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedFileTypeChip('PDF', 0),
            SizedBox(width: 8),
            _buildAnimatedFileTypeChip('DOC', 100),
            SizedBox(width: 8),
            _buildAnimatedFileTypeChip('DOCX', 200),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedFileTypeChip(String type, int delay) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return FadeTransition(
          opacity: AlwaysStoppedAnimation(value),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: AlwaysStoppedAnimation(value),
              curve: Curves.easeOut,
            )),
            child: _fileTypeChip(type),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedProcessingIndicator() {
    // Start processing animation when first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_processingAnimationController.isAnimating) {
        _processingAnimationController.forward();
      }
    });

    return FadeTransition(
      opacity: _processingFadeAnimation,
      child: ScaleTransition(
        scale: _processingScaleAnimation,
        child: Container(
          margin: EdgeInsets.only(top: 30),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(0.7),
            border: Border.all(
              color: Color(0xFF2196F3).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Animated circular progress indicator
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 1500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * math.sin(value * math.pi * 4)),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                      strokeWidth: 3,
                    ),
                  );
                },
              ),

              SizedBox(height: 16),

              // Animated status text
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: Text(
                  _processStatus,
                  key: ValueKey(_processStatus),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 8),

              // Pulsing subtitle
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 2000),
                tween: Tween(begin: 0.5, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: 0.4 + (0.4 * math.sin(value * math.pi * 2)),
                    child: Text(
                      'Enhanced AI analysis in progress...',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedErrorDisplay() {
    // Start error shake animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _errorAnimationController.forward();
    });

    return AnimatedBuilder(
      animation: _errorShakeAnimation,
      builder: (context, child) {
        final shake = math.sin(_errorShakeAnimation.value * math.pi * 3) * 5;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: FadeTransition(
            opacity: _errorShakeAnimation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: _errorAnimationController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RotationTransition(
                          turns: Tween<double>(begin: 0, end: 0.1).animate(
                            CurvedAnimation(
                              parent: _errorAnimationController,
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: Icon(Icons.error_outline, color: Colors.red, size: 20),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Processing Error',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      _lastError!,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _lastError = null);
                        _errorAnimationController.reset();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Dismiss'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedUploadedDocumentInfo() {
    // Start success animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_successAnimationController.isAnimating) {
        _successAnimationController.forward();
      }
    });

    return FadeTransition(
      opacity: _successScaleAnimation,
      child: ScaleTransition(
        scale: _successScaleAnimation,
        child: Container(
          margin: EdgeInsets.only(top: 20),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2196F3).withOpacity(0.1),
                Colors.black.withOpacity(0.8),
                Color(0xFF21CBF3).withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: Color(0xFF2196F3).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF2196F3).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // Animated document icon
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF2196F3).withOpacity(0.3),
                            Color(0xFF21CBF3).withOpacity(0.2),
                          ],
                        ),
                        border: Border.all(
                          color: Color(0xFF2196F3).withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.description,
                        size: 24,
                        color: Color(0xFF21CBF3),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(width: 16),

              // Animated document info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 500),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF21CBF3),
                        letterSpacing: 1.0,
                      ),
                      child: Text('UPLOADED DOCUMENT'),
                    ),
                    SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 500),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      child: Text(
                        _uploadedFileName!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Animated new document button
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _processedData = null;
                          _lastError = null;
                          _uploadedFileName = null;
                        });
                        _successAnimationController.reset();
                        _startEntryAnimations();
                      },
                      icon: Icon(Icons.add_circle_outline, size: 18),
                      label: Text('NEW DOCUMENT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Keep all the existing methods for file processing unchanged
  Future<void> _pickAndProcessFile() async {
    try {
      print('Starting file picker...');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        final file = result.files.first;
        print('File selected: ${file.name}, Size: ${file.size} bytes');

        if (file.size > 20 * 1024 * 1024) {
          setState(() {
            _lastError = 'File size exceeds 20MB limit. Please select a smaller file. Current size: ${(file.size / (1024 * 1024)).toStringAsFixed(2)} MB';
          });
          return;
        }

        // Store the filename
        setState(() {
          _uploadedFileName = file.name;
          _isProcessing = true;
          _processStatus = 'Uploading and processing document...';
          _lastError = null;
        });

        await _processDocument(file.bytes!, file.name, file.extension ?? '');
      } else {
        print('No file selected or file has no bytes');
      }
    } catch (e) {
      print('Error picking file: $e');
      setState(() {
        _isProcessing = false;
        _lastError = 'Error picking file: ${e.toString()}';
      });
    }
  }

  Future<void> _processDocument(Uint8List fileBytes, String filename, String extension) async {
    try {
      print('Starting document processing...');

      if (_workingServiceUrl == null) {
        setState(() {
          _processStatus = 'Finding available service...';
        });

        _workingServiceUrl = await _findWorkingUrl(_serviceUrls);

        if (_workingServiceUrl == null) {
          throw Exception('No legal document processing service is currently available.\n\nPlease ensure:\n1. Flask server is running on port 5000\n2. No firewall is blocking the connection\n3. Check the server console for errors');
        }
      }

      setState(() {
        _processStatus = 'Processing document with enhanced AI analysis...';
      });

      print('Using service URL: $_workingServiceUrl');
      print('Processing file: $filename (${fileBytes.length} bytes)');

      final uri = Uri.parse('$_workingServiceUrl/analyze-document');
      print('Request URI: $uri');

      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Access-Control-Request-Method': 'POST',
        'Access-Control-Request-Headers': 'content-type',
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'document',
          fileBytes,
          filename: filename,
        ),
      );

      print('Sending multipart request...');

      final streamedResponse = await request.send().timeout(
        Duration(seconds: 300),
        onTimeout: () {
          throw TimeoutException('Request timeout after 5 minutes. The document might be too large or the server is overloaded.', Duration(seconds: 300));
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('Response received:');
      print('Status: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body preview: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          print('Successfully parsed JSON response');
          print('Response keys: ${responseData.keys.toList()}');

          setState(() {
            _processedData = responseData;
            _isProcessing = false;
            _processStatus = '';
            _lastError = null;
          });

          if (widget.onAnalysisComplete != null) {
            widget.onAnalysisComplete!(responseData);
          }

          print('Processing completed successfully!');
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
          print('Response body: ${response.body}');
          throw Exception('Invalid JSON response from server. Raw response: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}');
        }
      } else {
        print('HTTP Error ${response.statusCode}: ${response.body}');

        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? 'Processing failed';

          if (errorData.containsKey('details')) {
            errorMessage += '\n\nDetails: ${errorData['details']}';
          }
        } catch (e) {
          errorMessage = 'Server error (${response.statusCode}): ${response.reasonPhrase}';
          if (response.body.isNotEmpty) {
            errorMessage += '\n\nServer response: ${response.body.length > 300 ? response.body.substring(0, 300) + '...' : response.body}';
          }
        }

        throw Exception(errorMessage);
      }
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      setState(() {
        _isProcessing = false;
        _processStatus = '';
        _lastError = 'Request timeout: The server took too long to respond (${e.duration?.inSeconds} seconds). This may happen with large documents. Please try again or use a smaller file.';
      });
    } catch (e) {
      print('Error processing document: $e');
      setState(() {
        _isProcessing = false;
        _processStatus = '';
        _lastError = 'Processing failed: ${e.toString()}';
      });
    }
  }

  Future<String?> _findWorkingUrl(List<String> urls) async {
    print('Starting service discovery...');

    for (int i = 0; i < urls.length; i++) {
      String url = urls[i];
      try {
        print('Testing URL [$i]: $url/health');

        final response = await http.get(
          Uri.parse('$url/health'),
          headers: {
            'Accept': 'application/json',
            'Access-Control-Request-Method': 'GET',
          },
        ).timeout(
          Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Health check timeout', Duration(seconds: 10)),
        );

        print('Response status [$i]: ${response.statusCode}');

        if (response.statusCode == 200) {
          print('Response body [$i]: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}');

          try {
            final data = json.decode(response.body);
            if (data['status'] == 'healthy') {
              print('✅ Found working URL: $url');
              return url;
            } else {
              print('❌ Service not healthy: ${data['status']}');
            }
          } catch (e) {
            print('⚠️  JSON parse failed but 200 OK, assuming healthy: $e');
            return url;
          }
        } else {
          print('❌ HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      } on TimeoutException catch (e) {
        print('❌ Timeout [$i]: ${e.message}');
      } catch (e) {
        print('❌ Connection failed [$i]: ${e.runtimeType} - $e');

        if (e.toString().contains('CORS') || e.toString().contains('cross-origin')) {
          print('🔍 CORS error detected - this might still be a working endpoint');
          print('⚠️  Attempting to use $url despite CORS preflight failure');
          return url;
        }
      }
    }

    print('❌ No working URLs found');
    return null;
  }

  Widget _fileTypeChip(String type) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2196F3).withOpacity(0.2),
            Color(0xFF21CBF3).withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Color(0xFF2196F3).withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        type,
        style: GoogleFonts.inter(
          color: Color(0xFF21CBF3),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}