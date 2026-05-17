import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:invoxa/app/presentation/widgets/log_print_condition.dart';

import '../utils/app_constants.dart';

class CloudinaryService {
  static Future<String?> uploadImage(String filePath) async {
    if (filePath.isEmpty) return null;

    final url = Uri.parse('https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload');

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = AppConstants.cloudinaryUploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonResponse = jsonDecode(responseString);
        return jsonResponse['secure_url'];
      } else {
        logPrint('Cloudinary upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logPrint('Cloudinary upload error: $e');
      return null;
    }
  }

  static Future<String?> uploadPdf(Uint8List pdfBytes, String filename) async {
    if (pdfBytes.isEmpty) return null;

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/'
      '${AppConstants.cloudinaryCloudName}/raw/upload',
    );

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = AppConstants.cloudinaryUploadPdfPreset
        ..fields['resource_type'] = 'raw'
        ..files.add(http.MultipartFile.fromBytes('file', pdfBytes, filename: filename));

      final response = await request.send();

      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      logPrint("Cloudinary Response: $responseString");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseString);
        return jsonResponse['secure_url'];
      } else {
        logPrint('Cloudinary PDF upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logPrint('Cloudinary PDF upload error: $e');
      return null;
    }
  }
}
