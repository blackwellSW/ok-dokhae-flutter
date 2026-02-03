import '../models/work.dart';
import '../models/session_task.dart'; // Task 모델 import

abstract class ApiService {
  // 전체 작품 목록 가져오기
  Future<List<Work>> getWorks();

  // 특정 작품의 지문(문장 리스트) 가져오기
  Future<List<String>> getWorkContent(String workId);

  // 특정 작품의 문제(Task) 리스트 가져오기
  Future<List<Task>> getTasks(String workId);

  // 학습 결과 제출하기 (POST)
  Future<void> submitResult(String workId, List<UserLog> logs);
}