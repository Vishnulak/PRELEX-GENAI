// document_modification_widget.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentModificationWidget extends StatefulWidget {
  final Map<String, dynamic>? analysisResult;
  final File? originalDocument;
  final String apiBaseUrl;

  const DocumentModificationWidget({
    Key? key,
    this.analysisResult,
    this.originalDocument,
    required this.apiBaseUrl,
  }) : super(key: key);

  @override
  _DocumentModificationWidgetState createState() =>
      _DocumentModificationWidgetState();
}

class _DocumentModificationWidgetState extends State<DocumentModificationWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isLoading = false;
  List<ModificationSuggestion> _suggestions = [];
  List<CustomModification> _customModifications = [];
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.analysisResult != null) {
      _loadModificationSuggestions();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadModificationSuggestions() async {
    if (widget.analysisResult == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${widget.apiBaseUrl}/get-modification-suggestions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'risky_clauses': widget.analysisResult!['risk_analysis']
          ['detailed_clauses'],
          'original_text': widget.analysisResult!['extraction']['text'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _suggestions = (data['modification_suggestions'] as List)
              .map((item) => ModificationSuggestion.fromJson(item))
              .toList();
        });
      } else {
        _showErrorSnackBar('Failed to load modification suggestions');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _addCustomModification() {
    setState(() {
      _customModifications.add(CustomModification(
        originalText: '',
        replacementText: '',
        reason: '',
      ));
    });
  }

  void _removeCustomModification(int index) {
    setState(() {
      _customModifications.removeAt(index);
    });
  }

  Future<void> _applyModifications() async {
    if (widget.originalDocument == null) {
      _showErrorSnackBar('Original document is required');
      return;
    }

    final selectedModifications = _suggestions
        .where((s) => s.selectedModifications.any((m) => m.selected))
        .expand((s) => s.selectedModifications.where((m) => m.selected))
        .toList();

    if (selectedModifications.isEmpty && _customModifications.isEmpty) {
      _showErrorSnackBar('Please select at least one modification');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${widget.apiBaseUrl}/apply-modifications'),
      );

      // Add original document
      request.files.add(await http.MultipartFile.fromPath(
        'original_document',
        widget.originalDocument!.path,
      ));

      // Add modifications
      request.fields['modifications'] = jsonEncode(
        selectedModifications.map((m) => m.toJson()).toList(),
      );

      // Add custom modifications
      request.fields['custom_modifications'] = jsonEncode(
        _customModifications.map((m) => m.toJson()).toList(),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        await _downloadModifiedDocument(data['download_url']);
        _showSuccessSnackBar('Document modified successfully!');
      } else {
        final errorData = jsonDecode(responseData);
        _showErrorSnackBar(errorData['message'] ?? 'Failed to apply modifications');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadModifiedDocument(String downloadUrl) async {
    try {
      // Request storage permission
      if (await Permission.storage.request().isGranted) {
        final response = await http.get(Uri.parse('${widget.apiBaseUrl}$downloadUrl'));

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final directory = await getExternalStorageDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final file = File('${directory!.path}/modified_contract_$timestamp.zip');

          await file.writeAsBytes(bytes);

          _showSuccessDialog(
            'Download Complete',
            'Modified document saved to: ${file.path}',
            file.path,
          );
        } else {
          _showErrorSnackBar('Failed to download file');
        }
      } else {
        _showErrorSnackBar('Storage permission required for download');
      }
    } catch (e) {
      _showErrorSnackBar('Download error: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog(String title, String message, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              'The download includes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Modified document'),
            const Text('• Change log'),
            const Text('• Legal disclaimer'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Open file location (platform-specific)
            },
            child: const Text('Open Folder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.analysisResult == null ||
        (widget.analysisResult!['risk_analysis']['detailed_clauses'] as List).isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          InkWell(
            onTap: _toggleExpanded,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_document,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document Modifications Available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        Text(
                          '${_suggestions.length} suggested improvements ready',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _expandAnimation,
                child: child,
              );
            },
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                children: [
                  const Divider(height: 1),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    )
                  else
                    Expanded(
                      child: _buildModificationContent(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModificationContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legal Warning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              border: Border.all(color: Colors.amber[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.amber[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Legal Disclaimer: These are suggestions only. Consult an attorney before making changes.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Suggested Modifications
          if (_suggestions.isNotEmpty) ...[
            Text(
              'Suggested Modifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ..._suggestions.map((suggestion) => _buildSuggestionCard(suggestion)),
            const SizedBox(height: 20),
          ],

          // Custom Modifications
          Text(
            'Custom Modifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          if (_customModifications.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'No custom modifications added yet.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else
            ..._customModifications.asMap().entries.map((entry) =>
                _buildCustomModificationCard(entry.key, entry.value)),

          const SizedBox(height: 16),

          // Add Custom Modification Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addCustomModification,
              icon: const Icon(Icons.add),
              label: const Text('Add Custom Modification'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Apply Modifications Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _applyModifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Apply Modifications & Download',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(ModificationSuggestion suggestion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getSeverityIcon(suggestion.severity),
                  color: _getSeverityColor(suggestion.severity),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion.riskDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Original: ${suggestion.originalClause}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 12),

            ...suggestion.suggestedModifications.map((mod) => CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                mod.description,
                style: const TextStyle(fontSize: 13),
              ),
              subtitle: Text(
                'Impact: ${mod.impact}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              value: mod.selected,
              onChanged: (value) {
                setState(() {
                  mod.selected = value ?? false;
                });
              },
              activeColor: Colors.blue[700],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomModificationCard(int index, CustomModification modification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Custom Modification ${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeCustomModification(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              decoration: const InputDecoration(
                labelText: 'Original Text to Replace',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 12),
              onChanged: (value) {
                modification.originalText = value;
              },
            ),
            const SizedBox(height: 8),

            TextField(
              decoration: const InputDecoration(
                labelText: 'Replacement Text',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 12),
              onChanged: (value) {
                modification.replacementText = value;
              },
            ),
            const SizedBox(height: 8),

            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason for Change',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: const TextStyle(fontSize: 12),
              onChanged: (value) {
                modification.reason = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.dangerous;
      case 'high':
        return Icons.warning;
      case 'medium-high':
        return Icons.priority_high;
      case 'medium':
        return Icons.info;
      default:
        return Icons.info_outline;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium-high':
        return Colors.amber;
      case 'medium':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// Data Models
class ModificationSuggestion {
  final int clauseId;
  final String originalClause;
  final String riskDescription;
  final String severity;
  final List<SuggestedModification> suggestedModifications;
  final bool customModificationAllowed;

  ModificationSuggestion({
    required this.clauseId,
    required this.originalClause,
    required this.riskDescription,
    required this.severity,
    required this.suggestedModifications,
    required this.customModificationAllowed,
  });

  List<SuggestedModification> get selectedModifications =>
      suggestedModifications.where((m) => m.selected).toList();

  factory ModificationSuggestion.fromJson(Map<String, dynamic> json) {
    return ModificationSuggestion(
      clauseId: json['clause_id'],
      originalClause: json['original_clause'],
      riskDescription: json['risk_description'],
      severity: json['severity'],
      customModificationAllowed: json['custom_modification_allowed'] ?? true,
      suggestedModifications: (json['suggested_modifications'] as List)
          .map((item) => SuggestedModification.fromJson(item))
          .toList(),
    );
  }
}

class SuggestedModification {
  final String id;
  final String description;
  final String replacementText;
  final String impact;
  bool selected;

  SuggestedModification({
    required this.id,
    required this.description,
    required this.replacementText,
    required this.impact,
    this.selected = false,
  });

  factory SuggestedModification.fromJson(Map<String, dynamic> json) {
    return SuggestedModification(
      id: json['id'],
      description: json['description'],
      replacementText: json['replacement_text'],
      impact: json['impact'],
      selected: json['selected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'replacement_text': replacementText,
      'impact': impact,
      'selected': selected,
    };
  }
}

class CustomModification {
  String originalText;
  String replacementText;
  String reason;

  CustomModification({
    required this.originalText,
    required this.replacementText,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'original_text': originalText,
      'replacement_text': replacementText,
      'reason': reason,
    };
  }
}