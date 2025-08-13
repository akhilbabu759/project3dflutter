import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:project3d/apiservice/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PlatformFile? _selectedFile;
  String? _statusText;
  bool _isUploading = false;
  ModelDetails? _lastUploaded;
  final ApiService _apiService = ApiService();

  // Helpers
  String _formatSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '—';
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(size < 10 ? 2 : 1)} ${units[unitIndex]}';
  }

  Future<void> _pickFile() async {
    if (_isUploading) return;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['glb', 'gltf'],
        withData: true, // so size is always available
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _statusText = null;
          _lastUploaded = null;
        });
      }
    } catch (e) {
      setState(() {
        _statusText = 'Failed to select file: $e';
      });
    }
  }

  Future<void> _uploadModel() async {
    if (_selectedFile == null || _isUploading) {
      setState(() {
        _statusText ??= 'Please select a .glb or .gltf file.';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _statusText = 'Uploading...';
      _lastUploaded = null;
    });

    try {
      final ModelDetails modelDetails = await _apiService.uploadModel(_selectedFile!);
      setState(() {
        _isUploading = false;
        _lastUploaded = modelDetails;
        _statusText = 'Upload successful! Public ID: ${modelDetails.publicId}';
      });
    } catch (e) {
      log('Upload failed: $e');
      setState(() {
        _isUploading = false;
        _statusText = 'Upload failed: ${e.toString()}';
      });
    }
  }

  void _clearSelection() {
    if (_isUploading) return;
    setState(() {
      _selectedFile = null;
      _statusText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
        title: const Text('3D Model Dashboard'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 900;
          final cardWidth = math.min(720.0, c.maxWidth - 32);
          final body = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 900 : cardWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _Header(color: color),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _PickerCard(
                              color: color,
                              isUploading: _isUploading,
                              selectedFile: _selectedFile,
                              sizeText: _formatSize(_selectedFile?.size),
                              onPick: _pickFile,
                              onClear: _clearSelection,
                            ),
                            const SizedBox(height: 12),
                            _UploadActions(
                              color: color,
                              isUploading: _isUploading,
                              canUpload: _selectedFile != null,
                              onUpload: _uploadModel,
                            ),
                            if (_isUploading) ...[
                              const SizedBox(height: 16),
                              _ProgressStrip(color: color),
                            ],
                            const SizedBox(height: 16),
                            if (_statusText != null)
                              _StatusBanner(
                                text: _statusText!,
                                color: color,
                                isError: _statusText!.toLowerCase().contains('failed'),
                              ),
                            if (_lastUploaded != null) ...[
                              const SizedBox(height: 12),
                              _SuccessDetails(
                                color: color,
                                publicId: _lastUploaded!.publicId,
                                url: _lastUploaded!.url,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          return body;
        },
      ),
    );
  }
}

/* Top header card */
class _Header extends StatelessWidget {
  final ColorScheme color;
  const _Header({required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: color.primaryContainer.withOpacity(0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.upload_file_rounded, color: color.primary, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upload 3D Models', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    'Supported formats: .glb, .gltf',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* File picker card */
class _PickerCard extends StatelessWidget {
  final ColorScheme color;
  final bool isUploading;
  final PlatformFile? selectedFile;
  final String sizeText;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _PickerCard({
    required this.color,
    required this.isUploading,
    required this.selectedFile,
    required this.sizeText,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = selectedFile != null;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isUploading ? null : onPick,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.surfaceVariant.withOpacity(0.35),
                color.surface.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: hasFile ? color.primary.withOpacity(0.35) : color.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasFile ? color.primary.withOpacity(0.12) : Colors.grey.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasFile ? Icons.description_rounded : Icons.add_to_photos_rounded,
                  color: hasFile ? color.primary : Colors.grey.shade600,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: hasFile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedFile!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sizeText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select 3D Model',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to choose a .glb or .gltf file',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 12),
              if (hasFile)
                Tooltip(
                  message: 'Remove file',
                  child: IconButton(
                    onPressed: isUploading ? null : onClear,
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey.shade600,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: isUploading ? null : onPick,
                  icon: const Icon(Icons.file_open_rounded),
                  label: const Text('Browse'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/* Upload CTA row */
class _UploadActions extends StatelessWidget {
  final ColorScheme color;
  final bool isUploading;
  final bool canUpload;
  final VoidCallback onUpload;

  const _UploadActions({
    required this.color,
    required this.isUploading,
    required this.canUpload,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: (!canUpload || isUploading) ? null : onUpload,
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text('Upload Model'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // OutlinedButton.icon(
        //   onPressed: isUploading ? null : onUpload,
        //   icon: const Icon(Icons.playlist_add_check_rounded),
        //   label: const Text('Quick Upload'),
        //   style: OutlinedButton.styleFrom(
        //     padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        //   ),
        // ),
      ],
    );
  }
}

/* Progress indicator during upload */
class _ProgressStrip extends StatelessWidget {
  final ColorScheme color;
  const _ProgressStrip({required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        minHeight: 8,
        color: color.primary,
        backgroundColor: color.primaryContainer.withOpacity(0.35),
      ),
    );
  }
}

/* Status banner for success or error */
class _StatusBanner extends StatelessWidget {
  final String text;
  final ColorScheme color;
  final bool isError;

  const _StatusBanner({
    required this.text,
    required this.color,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isError ? Colors.red.withOpacity(0.08) : Colors.green.withOpacity(0.08);
    final fg = isError ? Colors.red.shade700 : Colors.green.shade700;
    final icon = isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;

    return Card(
      color: bg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: fg.withOpacity(0.25))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* Details card for last successful upload */
class _SuccessDetails extends StatelessWidget {
  final ColorScheme color;
  final String publicId;
  final String url;

  const _SuccessDetails({
    required this.color,
    required this.publicId,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> copyToClipboard(String v) async {
      await Clipboard.setData(ClipboardData(text: v));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last Upload', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _InfoRow(
              label: 'Public ID',
              value: publicId,
              onCopy: () => copyToClipboard(publicId),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'URL',
              value: url,
              onCopy: () => copyToClipboard(url),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          tooltip: 'Copy',
          icon: const Icon(Icons.copy_rounded, size: 18),
          onPressed: onCopy,
        ),
      ],
    );
  }
}
