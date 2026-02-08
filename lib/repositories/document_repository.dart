import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../services/dio_client.dart';
import '../models/document_model.dart';

class DocumentRepository {
  final DioClient _client = DioClient();

  // [1] 문서 업로드 (명세서: POST /documents)
  Future<Document?> uploadDocument(String filePath, String fileName) async {
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: MediaType('application', 'pdf'), // PDF 기준
        ),
        "title": fileName, // [추가] 명세서 예시에 title이 있음
      });

      final response = await _client.dio.post(
        '/documents',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 응답에 document_id만 오는지, 전체 객체가 오는지 확인 필요.
        // 명세서엔 DocumentUploadResponse(document_id, ...) 라고 되어 있음.
        // Document 모델로 변환 가능한지 체크
        return Document.fromJson(response.data); 
      }
    } catch (e) {
      print("업로드 실패: $e");
    }
    return null;
  }

  // [2] 문서 목록 조회 (명세서: GET /documents)
  Future<List<Document>> getDocuments() async {
    try {
      final response = await _client.dio.get('/documents');
      if (response.statusCode == 200) {
        final list = response.data['documents'] as List; // [주의] { documents: [...] } 형태일 수 있음
        return list.map((e) => Document.fromJson(e)).toList();
      }
    } catch (e) {
      print("목록 조회 실패: $e");
    }
    return [];
  }
}