import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllQuizPage extends StatefulWidget {
  const AllQuizPage({super.key});

  @override
  State<AllQuizPage> createState() => _AllQuizPageState();
}

class _AllQuizPageState extends State<AllQuizPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> _outcomeDocs = []; // Holds the quiz results

  @override
  void initState() {
    super.initState();
    fetchQuizResults();
  }

  // Fetch the quiz results from Firestore
  Future<void> fetchQuizResults() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final outcomeSnapshot = await _firestore
          .collection('it_outcome')
          .where('it_userid', isEqualTo: user.uid)
          .get();

      setState(() {
        _outcomeDocs = outcomeSnapshot.docs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Results"),
      ),
      body: _outcomeDocs.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show loading if no results
          : ListView.builder(
              itemCount: _outcomeDocs.length,
              itemBuilder: (context, index) {
                final result = _outcomeDocs[index].data() as Map<String, dynamic>;
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
                          "Quiz Code: ${result['it_code']}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your Score: ${result['it_quiz_total']}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Date: ${DateTime.fromMillisecondsSinceEpoch((result['timestamp'] as Timestamp).millisecondsSinceEpoch).toLocal()}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
