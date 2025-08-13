import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:project3d/apiservice/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ModelDetailScreen extends StatelessWidget {
  final ModelDetails model;

  const ModelDetailScreen({super.key, required this.model});

  // Helper function to launch URL
  Future<void> _launchUrl(BuildContext context) async {
    final url = Uri.parse(model.url);
    if (!await launchUrl(url)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)), 
        title: Text('3D View'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Hero(
                tag: model.url, // For a smooth transition animation
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(30)),
                  child: ModelViewer(
                    src: model.url,
                    alt: 'A 3D model of ',
                    ar: true,
                    autoRotate: true,
                    cameraControls: true,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Future Corner 3D Model",
                      style: textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'A stunning 3D asset from our collection.',
                    style: textTheme.titleMedium
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'About this model',
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                   Text(
                    'This is a detailed description of the 3D model. It can include information about its origin, purpose, materials, and any other relevant details.',
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoTile(
                    context,
                    icon: Icons.info_outline,
                    label: 'Public ID',
                    value: model.publicId,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoTile(
                    context,
                    icon: Icons.memory,
                    label: 'Size',
                    value: '${(model.bytes / 1024).toStringAsFixed(2)} KB',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoTile(
                    context,
                    icon: Icons.code,
                    label: 'Format',
                    value: model.format.toUpperCase(),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.purple.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart_checkout_outlined, color: Colors.white),
                      label: Text('BUY NOW', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                      onPressed: () => _launchUrl(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildInfoTile(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 20),
        const SizedBox(width: 16),
        Text('$label:',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
        // child: Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     SizedBox(
        //       height: 300,
        //       child: ModelViewer(
        //         src: model.url,
        //         alt: 'A 3D model of ${model.publicId}',
        //         ar: true,
        //         autoRotate: true,
        //         cameraControls: true,
        //         backgroundColor: Colors.grey.shade200,
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.all(16.0),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Text(
        //             model.publicId.split('/').last,
        //             style: const TextStyle(
        //               fontSize: 24,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //           const SizedBox(height: 8),
        //           Text(
        //             'Public ID: ${model.publicId}',
        //             style: TextStyle(
        //               fontSize: 16,
        //               color: Colors.grey[600],
        //             ),
        //           ),
        //           const SizedBox(height: 16),
        //           const Text(
        //             'Description:',
        //             style: TextStyle(
        //               fontSize: 18,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //           const SizedBox(height: 8),
        //           const Text(
        //             'This is a detailed description of the 3D model. It can include information about its origin, purpose, materials, and any other relevant details. For demonstration purposes, this is dummy text.',
        //             style: TextStyle(fontSize: 16),
        //           ),
        //           const SizedBox(height: 16),
        //           Text(
        //             'URL: ${model.url}',
        //             style: TextStyle(
        //               fontSize: 16,
        //               color: Colors.blue[600],
        //               decoration: TextDecoration.underline,
        //             ),
        //           ),
        //                       ],
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           );
        //         }
        //       }