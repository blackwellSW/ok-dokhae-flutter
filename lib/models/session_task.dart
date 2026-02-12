class Task {
  final String id;
  final String typeTag;
  final String question; 
  final List<String> options;
  final int correctOptionIndex;
  
  final int highlightSentenceIndex; 
  final List<int> validEvidenceIndices;
  
  final String feedbackMessage;
  final List<String> whyOptions; 

  Task({
    this.id = '',
    required this.typeTag,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.highlightSentenceIndex,
    required this.validEvidenceIndices,
    required this.feedbackMessage,
    required this.whyOptions,
  });
}

class UserLog {
  final String taskType;
  final String question;
  final String selectedAnswer;
  final String evidenceText;
  final String whyReason;

  UserLog({
    required this.taskType,
    required this.question,
    required this.selectedAnswer,
    required this.evidenceText,
    required this.whyReason,
  });
}