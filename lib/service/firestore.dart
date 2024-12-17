import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final CollectionReference notes =
  FirebaseFirestore.instance.collection('notes');

  final CollectionReference itlessons =
  FirebaseFirestore.instance.collection('it_lessons');

  final CollectionReference study =
  FirebaseFirestore.instance.collection('it_topics');

  final CollectionReference quiz =
  FirebaseFirestore.instance.collection('it_quiz');

  Future<void> addNoteme(String itcode,String itintro,String itprofs,String ittopics) {
    return itlessons.add({
      'it_code': itcode,
      'it_intro': itintro,
      'it_prof': itprofs,
      'it_topics': ittopics,
      'timestamp': Timestamp.now(),
    });
  }
  Future<void> updateNote(String docID, String itcode, String itintro, String itprofs, String ittopics) {
    return itlessons.doc(docID).update({
      'it_code': itcode,
      'it_intro': itintro,
      'it_prof': itprofs,
      'it_topics': ittopics,
      'timestamp': Timestamp.now(),
    });
  }
  Future<void> deleteNote(String docID){
    return itlessons.doc(docID).delete();
  }

  Future<void> addTopic(String itStudy, String itSubStudy, String itCode) {
    return study.add({
      'it_code': itCode,
      'it_study': itStudy,
      'it_substudy': itSubStudy,
      'timestamp': Timestamp.now(),
    });
  }
  Future<void> updateTopic(String docID, String itStudy, String itSubStudy, String itCode) {
    return study.doc(docID).update({
      'it_code': itCode,
      'it_study': itStudy,
      'it_substudy': itSubStudy,
      'timestamp': Timestamp.now(),
    });
  }
   Future<void> deleteTopic(String docID){
    return study.doc(docID).delete();
  }
  // ignore: non_constant_identifier_names
  Stream<QuerySnapshot> IT_LESSONS_FETCH() {
    final itLessonsStream = itlessons.orderBy('timestamp', descending: true).snapshots();
    return itLessonsStream;
  }
  // ignore: non_constant_identifier_names
  Stream<QuerySnapshot> IT_TOPIC_FETCH() {
  final itTopicFetch = study
      .orderBy('timestamp', descending: true).snapshots();
  return itTopicFetch;
}

//QUIZ
String generateUniqueId() {
  final DateTime now = DateTime.now();
  final int randomNumber = now.microsecond; 
  return "${now.millisecondsSinceEpoch}$randomNumber";
}
Future<void> addQuiz(String question, String a, String b, String c, String d, String correct, String itcode) {
    final String subid = generateUniqueId();
    return quiz.add({
      'it_a': a,
      'it_b': b,
      'it_c': c,
      'it_code': itcode,
      'it_correct_answer': correct,
      'it_d': d,
      'it_question': question,
      'sub_id': subid,
      'timestamp': Timestamp.now(),
    });
  }
Future<void> updateQuiz(
      String docID,
      String question,
      String answerA,
      String answerB,
      String answerC,
      String answerD,
      String correctAnswer) async {
    return quiz.doc(docID).update({
      'it_question': question,
      'it_a': answerA,
      'it_b': answerB,
      'it_c': answerC,
      'it_d': answerD,
      'it_correct_answer': correctAnswer,
    });
  }
   // ignore: non_constant_identifier_names
   Stream<QuerySnapshot> IT_QUIZ_FETCH() {
  final itQuizFetch = quiz
      .orderBy('timestamp', descending: true).snapshots();
  return itQuizFetch;
}

Future<void> deleteQuiz(String docID){
    return quiz.doc(docID).delete();
  }

  
}