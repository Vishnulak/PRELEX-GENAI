import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// Data Models (keeping the same)
class ChatSession {
  final String sessionId;
  final String documentTitle;
  final DateTime createdAt;
  final DateTime lastActivity;
  final int messageCount;

  ChatSession({
    required this.sessionId,
    required this.documentTitle,
    required this.createdAt,
    required this.lastActivity,
    required this.messageCount,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['session_id'],
      documentTitle: json['document_title'],
      createdAt: DateTime.parse(json['created_at']),
      lastActivity: DateTime.parse(json['last_activity']),
      messageCount: json['message_count'],
    );
  }
}

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      role: json['role'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

// API Service (keeping the same)
class ApiService {
  static const String baseUrl = 'http://localhost:5001';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static String _extractErrorMessage(String responseBody, int statusCode) {
    try {
      final Map<String, dynamic> errorData = json.decode(responseBody);
      return errorData['message'] ?? errorData['error'] ?? 'Server error ($statusCode)';
    } catch (e) {
      return 'Request failed with status $statusCode';
    }
  }

  static Future<Map<String, dynamic>?> uploadDocumentBytes(Uint8List fileBytes, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload-document'));
      request.headers.addAll({'Accept': 'application/json'});
      request.files.add(http.MultipartFile.fromBytes('document', fileBytes, filename: fileName));

      var streamedResponse = await request.send().timeout(Duration(seconds: 120));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Upload failed');
        }
      } else {
        throw Exception(_extractErrorMessage(response.body, response.statusCode));
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  static Future<Map<String, dynamic>> sendMessage(String sessionId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: _headers,
        body: json.encode({'session_id': sessionId, 'message': message}),
      ).timeout(Duration(seconds: 90));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Chat failed');
        }
      } else {
        throw Exception(_extractErrorMessage(response.body, response.statusCode));
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  static Future<List<ChatMessage>> getChatHistory(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat-history/$sessionId'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final messages = data['messages'] as List;
          return messages.map((msg) => ChatMessage.fromJson(msg)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load chat history');
        }
      } else {
        throw Exception(_extractErrorMessage(response.body, response.statusCode));
      }
    } catch (e) {
      throw Exception('Failed to load chat history: $e');
    }
  }

  static Future<List<ChatSession>> getSessions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sessions'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final sessions = data['sessions'] as List;
          return sessions.map((session) => ChatSession.fromJson(session)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load sessions');
        }
      } else {
        throw Exception(_extractErrorMessage(response.body, response.statusCode));
      }
    } catch (e) {
      throw Exception('Failed to load sessions: $e');
    }
  }

  static Future<void> deleteSession(String sessionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/session/$sessionId'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_extractErrorMessage(response.body, response.statusCode));
      }
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Exception('Backend health check failed');
      }
    } catch (e) {
      throw Exception('Cannot connect to backend: $e');
    }
  }
}

void main() {
  runApp(SimpleChatbotApp());
}

class SimpleChatbotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Document Chatbot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF0B0E1A),
        // Mixed typography approach - Orbitron for headers, system font for readability
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          headlineLarge: GoogleFonts.orbitron(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
          ),
          headlineMedium: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
          ),
          titleLarge: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          labelLarge: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          labelSmall: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<ChatSession> sessions = [];
  bool isLoading = false;
  String? backendStatus;
  String? aiStatus;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
    checkBackendHealth();
    loadSessions();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> checkBackendHealth() async {
    try {
      final health = await ApiService.checkHealth();
      setState(() {
        backendStatus = health['status'] ?? 'unknown';
        aiStatus = health['vertex_ai_status'] ?? 'unknown';
      });
      if (health['vertex_ai_status'] != 'connected') {
        _showSnackBar('AI service not available', isError: true);
      }
    } catch (e) {
      setState(() {
        backendStatus = 'disconnected';
        aiStatus = 'disconnected';
      });
      _showSnackBar('Cannot connect to backend', isError: true);
    }
  }

  Future<void> loadSessions() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getSessions();
      setState(() {
        sessions = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Failed to load sessions', isError: true);
    }
  }

  Future<void> uploadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => isLoading = true);
        final fileBytes = result.files.single.bytes;
        final fileName = result.files.single.name;

        if (fileBytes == null) throw Exception('Failed to read file');

        _showSnackBar('Processing document...');
        final response = await ApiService.uploadDocumentBytes(fileBytes, fileName);
        setState(() => isLoading = false);

        if (response != null && response['status'] == 'success') {
          _showSnackBar('Document uploaded successfully!');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                sessionId: response['session_id'],
                documentTitle: response['document_info']['filename'],
                welcomeMessage: response['welcome_message'],
              ),
            ),
          ).then((_) => loadSessions());
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Upload failed: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.blue[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0E1A), Color(0xFF1A1B3E), Color(0xFF0B0E1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: isLoading
                    ? _buildLoadingState()
                    : sessions.isEmpty
                    ? _buildEmptyState()
                    : _buildSessionsList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI CHATBOT',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: aiStatus == 'connected' ? Colors.green[800] : Colors.red[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      aiStatus == 'connected' ? 'AI READY' : 'AI OFFLINE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: IconButton(
        icon: Icon(Icons.info_outline, color: Colors.white70),
        onPressed: _showStatusDialog,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'PROCESSING...',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue[900]!.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue[400]!, width: 2),
                ),
                child: Icon(Icons.psychology, size: 50, color: Colors.blue[400]),
              ),
              SizedBox(height: 32),
              Text(
                'SMART DOCUMENT\nANALYSIS',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  height: 1.2,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Upload any document and chat with AI to get precise, contextual answers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40),
              if (aiStatus != 'connected')
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red[900]!.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.red[400]!),
                  ),
                  child: Text(
                    'AI SERVICE UNAVAILABLE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.red[400],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[900]!.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue[400]!),
                ),
                child: Icon(Icons.document_scanner, color: Colors.blue[400], size: 24),
              ),
              title: Text(
                session.documentTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    '${session.messageCount} MESSAGES',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.blue[400],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatDateTime(session.lastActivity),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.white60),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red[400]),
                        SizedBox(width: 8),
                        Text(
                          'DELETE',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.red[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'delete') await _deleteSession(session.sessionId);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      sessionId: session.sessionId,
                      documentTitle: session.documentTitle,
                    ),
                  ),
                ).then((_) => loadSessions());
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: aiStatus == 'connected'
                ? [Colors.blue[600]!, Colors.blue[800]!]
                : [Colors.grey[600]!, Colors.grey[800]!],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: (aiStatus == 'connected' ? Colors.blue : Colors.grey).withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: (aiStatus == 'connected') ? uploadDocument : null,
          icon: Icon(Icons.upload_file, color: Colors.white),
          label: Text(
            'UPLOAD',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  Future<void> _deleteSession(String sessionId) async {
    try {
      await ApiService.deleteSession(sessionId);
      loadSessions();
      _showSnackBar('Session deleted');
    } catch (e) {
      _showSnackBar('Delete failed', isError: true);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'now';
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1B3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'SYSTEM STATUS',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusRow('BACKEND', backendStatus ?? 'CHECKING'),
            _buildStatusRow('AI SERVICE', aiStatus ?? 'CHECKING'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CLOSE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.blue[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status) {
    Color statusColor = status.toLowerCase() == 'connected' || status.toLowerCase() == 'healthy'
        ? Colors.green[400]!
        : Colors.red[400]!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String sessionId;
  final String documentTitle;
  final String? welcomeMessage;

  ChatScreen({
    required this.sessionId,
    required this.documentTitle,
    this.welcomeMessage,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  List<ChatMessage> messages = [];
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool isLoading = false;
  bool isSending = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
    loadChatHistory();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> loadChatHistory() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getChatHistory(widget.sessionId);
      setState(() {
        messages = response;
        isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Failed to load chat', isError: true);
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isSending) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      isSending = true;
      messages.add(userMessage);
    });

    messageController.clear();
    _scrollToBottom();

    try {
      final response = await ApiService.sendMessage(widget.sessionId, text);
      if (response['status'] == 'success' && response['ai_response'] != null) {
        final aiMessage = ChatMessage(
          id: response['ai_response']['id'],
          role: 'assistant',
          content: response['ai_response']['content'],
          timestamp: DateTime.parse(response['ai_response']['timestamp']),
        );
        setState(() {
          messages.add(aiMessage);
          isSending = false;
        });
      }
      _scrollToBottom();
    } catch (e) {
      setState(() => isSending = false);
      setState(() {
        messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_error',
          role: 'assistant',
          content: 'Sorry, I encountered an error. Please try again.',
          timestamp: DateTime.now(),
        ));
      });
      _showSnackBar('Send failed', isError: true);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.blue[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0E1A), Color(0xFF1A1B3E), Color(0xFF0B0E1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildChatHeader(),
              Expanded(
                child: isLoading ? _buildLoadingState() : _buildMessagesList(),
              ),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.documentTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'AI ANALYSIS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.blue[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'LOADING...',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.all(20),
        itemCount: messages.length + (isSending ? 1 : 0),
        itemBuilder: (context, index) {
          if (isSending && index == messages.length) {
            return _buildTypingIndicator();
          }
          return _buildMessageBubble(messages[index]);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue[900]!.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue[400]!),
              ),
              child: Icon(Icons.psychology, color: Colors.blue[400], size: 18),
            ),
            SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.blue[800]!.withOpacity(0.6)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUser
                      ? Colors.blue[400]!.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.green[900]!.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green[400]!),
              ),
              child: Icon(Icons.person, color: Colors.green[400], size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue[900]!.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue[400]!),
            ),
            child: Icon(Icons.psychology, color: Colors.blue[400], size: 18),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI THINKING...',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white60,
                  ),
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask about your document...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.white38,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  maxLines: null,
                  onSubmitted: (_) => sendMessage(),
                ),
              ),
            ),
            SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSending
                      ? [Colors.grey[600]!, Colors.grey[800]!]
                      : [Colors.blue[600]!, Colors.blue[800]!],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isSending ? Colors.grey : Colors.blue).withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: isSending ? null : sendMessage,
                icon: Icon(
                  isSending ? Icons.hourglass_empty : Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}