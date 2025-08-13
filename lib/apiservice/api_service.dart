import 'dart:convert';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// A data model for the 3D model details returned by the API.
class ModelDetails {
  final String publicId;
  final String url;
  final int bytes;
  final String format;

  ModelDetails({
    required this.publicId,
    required this.url,
    required this.bytes,
    required this.format,
  });

  factory ModelDetails.fromJson(Map<String, dynamic> json) {
    log('Parsing ModelDetails from JSON: $json');
    return ModelDetails(
      publicId: json['public_id'],
      // The GET endpoint returns 'secure_url', while POST/PUT return 'url'.
      url: json['url'] ?? json['secure_url'],
      bytes: json['bytes'],
      format: json['format']?? 'glb', // Default to 'glb' if not provided
    );
  }

  @override
  String toString() {
    return 'ModelDetails(publicId: $publicId, url: $url, bytes: $bytes, format: $format)';
  }
}

/// A service class to interact with the 3D model backend API.
class ApiService {
  // IMPORTANT: Use 10.0.2.2 for Android emulator to connect to localhost.
  // For a physical device, use your computer's local IP address.
  static const String _baseUrl =
  //  "http://192.168.1.4:3000";
   'https://project3d-5khv.onrender.com';
  // It's best practice to load sensitive data like API keys from environment
  // variables rather than hardcoding them in your source code.
  final String _apiKey = dotenv.env['API_KEY'] ?? '';

  Map<String, String> get _headers {
    if (_apiKey.isEmpty) {
      // Depending on your app's logic, you might want to throw an exception here
      // if the API key is crucial for all requests.
      log('API_KEY is not set in the .env file.');
    }
    return {'X-API-Key': _apiKey}; // Or 'Authorization': 'Bearer $_apiKey'
  }

  /// Fetches a list of all 3D models from the server.
  ///
  /// Returns a [List<ModelDetails>] on success.
  /// Throws an [Exception] on failure.
  Future<List<ModelDetails>> getAllModels() async {
    try {
      log('Fetching all models...');
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: _headers,
      );
      log('Fetching all models...2');

      if (response.statusCode == 200) {
        log('Fetching all models...3');
        Iterable l = json.decode(response.body);
        log('Fetching all models...4');
        return List<ModelDetails>.from(l.map((model) => ModelDetails.fromJson(model)));
      } else {
        throw Exception('Failed to fetch models: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log('Error fetching all models: $e');
      rethrow;
    }
  }
  /// Uploads a 3D model file.
  ///
  /// Takes a [File] object representing the .glb model.
  /// Returns a [ModelDetails] object on success.
  /// Throws an [Exception] on failure.
  Future<ModelDetails> uploadModel(PlatformFile modelFile) async {
    // File upload is not supported on web
    try {
      log('Uploading model: ${modelFile.name}');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/models'),
      );

      request.headers.addAll(_headers);

      if (kIsWeb || modelFile.path == null) {
        // On web, or if path is null, use bytes
        if (modelFile.bytes == null) {
          throw Exception('File bytes are null. Cannot upload model.');
        }
        request.files.add(http.MultipartFile.fromBytes(
          'model',
          modelFile.bytes!,
          filename: modelFile.name,
          contentType: _getMediaType(modelFile.name),
        ));
      } else {
        // On mobile/desktop, use file path
        request.files.add(
          await http.MultipartFile.fromPath(
            'model', // This is the field name the backend expects.
            modelFile.path!,
            contentType: _getMediaType(modelFile.path!),
          ),
        );
      }
      log('Request prepared: ${request.files.length} file(s)');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return ModelDetails.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to upload model: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log('Error uploading model: $e');
      rethrow; // Re-throw the exception to be handled by the caller
    }
  }

  /// Gets details for a specific model by its public_id.
  ///
  /// The [publicId] is the identifier from Cloudinary (e.g., 'models/filename').
  /// Returns a [ModelDetails] object on success.
  /// Throws an [Exception] on failure.
  Future<ModelDetails> getModelDetails(String publicId) async {
    final encodedPublicId = Uri.encodeComponent(publicId);
    final response = await http.get(Uri.parse('$_baseUrl/models/$encodedPublicId'),
        headers: _headers);

    if (response.statusCode == 200) {
      return ModelDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to get model details: ${response.statusCode} ${response.body}');
    }
  }

  /// Replaces an existing model with a new file.
  ///
  /// The [publicId] is the identifier of the model to replace.
  /// The [modelFile] is the new .glb file.
  /// Returns a [ModelDetails] object on success.
  /// Throws an [Exception] on failure.
  Future<ModelDetails> updateModel(String publicId, PlatformFile modelFile) async {
    final encodedPublicId = Uri.encodeComponent(publicId);
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$_baseUrl/models/$encodedPublicId'),
    );

    request.headers.addAll(_headers);

    if (kIsWeb || modelFile.path == null) {
      if (modelFile.bytes == null) {
        throw Exception('File bytes are null. Cannot update model.');
      }
      request.files.add(http.MultipartFile.fromBytes(
        'model',
        modelFile.bytes!,
        filename: modelFile.name,
        contentType: _getMediaType(modelFile.name),
      ));
    } else {
      request.files.add(await http.MultipartFile.fromPath(
        'model', modelFile.path!,
        contentType: _getMediaType(modelFile.path!),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return ModelDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to update model: ${response.statusCode} ${response.body}');
    }
  }

  /// Deletes a model from the server.
  ///
  /// The [publicId] is the identifier of the model to delete.
  /// Returns `true` on success.
  /// Throws an [Exception] on failure.
  Future<bool> deleteModel(String publicId) async {
    final encodedPublicId = Uri.encodeComponent(publicId);
    final response = await http.delete(Uri.parse('$_baseUrl/models/$encodedPublicId'),
        headers: _headers);

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['result'] == 'ok';
    } else {
      throw Exception(
          'Failed to delete model: ${response.statusCode} ${response.body}');
    }
  }

  MediaType _getMediaType(String path) {
    if (path.endsWith('.glb')) {
      return MediaType('model', 'gltf-binary');
    } else if (path.endsWith('.gltf')) {
      return MediaType('model', 'gltf+json');
    } else {
      // Fallback
      return MediaType('application', 'octet-stream');
    }
  }
}
