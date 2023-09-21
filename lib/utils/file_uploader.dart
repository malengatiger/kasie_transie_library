import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:universal_io/io.dart';
import 'package:http/http.dart' as http;

final FileUploader fileUploader = FileUploader();
class FileUploader {
  static const mm = '🔵🔵🔵🔵🔵 FileUploader 🔵🔵';

  Future uploadUserFile(String associationId, File file) async {
    final res = await _sendFile(associationId: associationId, file: file, query: 'uploadUserFile');
    pp('$mm ... result: $res');
    return res;
  }
  Future uploadVehicleFile(String associationId, File file) async {
    final res = await _sendFile(associationId: associationId, file: file, query: 'uploadVehicleFile');
    pp('$mm ... result: $res');
    return res;
  }

  Future _sendFile({required String associationId, required File file, required String query}) async {
    final url = KasieEnvironment.getUrl();
    final uri = Uri.parse('$url$query');
    var request = http.MultipartRequest('POST', uri);
    final bytes = await file.readAsBytes();
    final httpImage = http.MultipartFile.fromBytes(file.path, bytes);
    request.files.add(httpImage);
    request.fields['associationId'] = associationId;

    final response = await request.send();
    return response;
  }
}
