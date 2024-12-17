// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_drawer.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/pages/all_quiz_page.dart'; // Import your new page here

class QuizPage extends StatefulWidget {
  final String topic;
  final String topicode; // Topic code filter
  const QuizPage({super.key, required this.topic, required this.topicode});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentIndex = 0; // Current question index
  int _correctAnswers = 0; // Score tracker
  String _selectedDropdownAnswer = ''; // Selected letter answer
  List<QueryDocumentSnapshot> _quizDocs = []; // Holds the quiz questions

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  // Fetch quizzes based on the topic code
  Future<void> fetchQuizzes() async {
    final quizSnapshot = await _firestore
        .collection('it_quiz')
        .where('it_code', isEqualTo: widget.topicode)
        .get();

    setState(() {
      _quizDocs = quizSnapshot.docs;
    });

    if (_quizDocs.isEmpty) {
      showEndOfQuizDialog("No quizzes available for this topic.");
    }
  }

  // Submit the user's selected answer
  Future<void> submitAnswer(String selectedLetter, String correctAnswer, String questionText) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await _firestore.collection('it_quiz_answers').add({
        'it_answer': selectedLetter,
        'it_correct_answer': correctAnswer,
        'it_question': questionText,
        'it_code': widget.topicode,
        'it_user': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (selectedLetter == correctAnswer) {
        setState(() => _correctAnswers++);
      }
    }
  }

  // Save the results to Firestore
  Future<void> saveResults() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('it_outcome').add({
        'it_code': widget.topicode,
        'it_quiz_total': '$_correctAnswers / ${_quizDocs.length}',
        'it_userid': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // Show a modal dialog when the quiz ends
  void showEndOfQuizDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Quiz Completed"),
        content: Text(message),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await saveResults();  // Save the results to Firestore
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AllQuizPage()), // Go to next page after quiz completion
                );
              },
              child: const Text("View Results"),
            ),
          ),
        ],
      ),
    );
  }

  // Logout functionality
  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.topic} Quiz"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: buildAppDrawer(context, logout),
      body: _quizDocs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _currentIndex >= _quizDocs.length
              ? showQuizCompleted()
              : buildQuizCard(),
    );
  }

  Widget showQuizCompleted() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showEndOfQuizDialog("Your Score: $_correctAnswers / ${_quizDocs.length}");
    });
    return const Center(child: Text("Fetching Results..."));
  }

  Widget buildQuizCard() {
    final quiz = _quizDocs[_currentIndex];
    final data = quiz.data() as Map<String, dynamic>;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${_currentIndex + 1}. ${data['it_question']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text("A. ${data['it_a']}", style: const TextStyle(fontSize: 16)),
            Text("B. ${data['it_b']}", style: const TextStyle(fontSize: 16)),
            Text("C. ${data['it_c']}", style: const TextStyle(fontSize: 16)),
            Text("D. ${data['it_d']}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedDropdownAnswer.isNotEmpty ? _selectedDropdownAnswer : null,
              hint: const Text("Select your answer"),
              isExpanded: true,
              items: ['A', 'B', 'C', 'D'].map((String letter) {
                return DropdownMenuItem<String>(
                  value: letter,
                  child: Text(letter),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDropdownAnswer = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_selectedDropdownAnswer.isNotEmpty) {
                  await submitAnswer(
                    _selectedDropdownAnswer,
                    data['it_correct_answer'],
                    data['it_question'],
                  );
                  setState(() {
                    _currentIndex++;
                    _selectedDropdownAnswer = '';
                  });
                }
              },
              child: const Text("Submit Answer"),
            ),
          ],
        ),
      ),
    );
  }
}
