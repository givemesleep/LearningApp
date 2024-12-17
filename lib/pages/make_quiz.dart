// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_drawer.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/service/firestore.dart';

class MakeQuiz extends StatefulWidget {
  final String topic;
  final String topicode;
  const MakeQuiz({super.key, required this.topic, required this.topicode});

  @override
  State<MakeQuiz> createState() => _MakeQuizPageState();
}

class _MakeQuizPageState extends State<MakeQuiz> {
  final FireStoreService fireStoreService = FireStoreService();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerAController = TextEditingController();
  final TextEditingController _answerBController = TextEditingController();
  final TextEditingController _answerCController = TextEditingController();
  final TextEditingController _answerDController = TextEditingController();
  final TextEditingController _correctAnswerController =
      TextEditingController();
  final TextEditingController itCode = TextEditingController();

  // To track the current docID for editing
  String? currentDocID;

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})),
      );
    }
  }

  void voidSubmit({String? docID}) {
    itCode.text = widget.topicode;
    if (_questionController.text.isEmpty ||
        _answerAController.text.isEmpty ||
        _answerBController.text.isEmpty ||
        _answerCController.text.isEmpty ||
        _answerDController.text.isEmpty ||
        _correctAnswerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    if (docID == null) {
      fireStoreService.addQuiz(
        _questionController.text,
        _answerAController.text,
        _answerBController.text,
        _answerCController.text,
        _answerDController.text,
        _correctAnswerController.text,
        itCode.text,
      );
    } else {
      fireStoreService.updateQuiz(
        docID,
        _questionController.text,
        _answerAController.text,
        _answerBController.text,
        _answerCController.text,
        _answerDController.text,
        _correctAnswerController.text,
      );
    }
    _questionController.clear();
    _answerAController.clear();
    _answerBController.clear();
    _answerCController.clear();
    _answerDController.clear();
    _correctAnswerController.clear();

    setState(() {
      currentDocID = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.topic} Quiz"),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: buildAppDrawer(context, logout),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create a Quiz',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Enter the Question',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., What is Flutter?',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _answerAController,
                decoration: const InputDecoration(
                  labelText: 'Answer A',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., A programming language',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _answerBController,
                decoration: const InputDecoration(
                  labelText: 'Answer B',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., A type of food',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _answerCController,
                decoration: const InputDecoration(
                  labelText: 'Answer C',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., A mobile app',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _answerDController,
                decoration: const InputDecoration(
                  labelText: 'Answer D',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., An operating system',
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
  value: _correctAnswerController.text.isNotEmpty ? _correctAnswerController.text : null,
  decoration: const InputDecoration(
    labelText: 'Correct Answer',
    border: OutlineInputBorder(),
    hintText: 'Choose Correct Answer',
  ),
  items: ['A', 'B', 'C', 'D'].map((String letter) {
    return DropdownMenuItem<String>(
      value: letter,
      child: Text(letter),
    );
  }).toList(),
  onChanged: (String? newValue) {
    setState(() {
      _correctAnswerController.text = newValue ?? '';
    });
  },
),

              const SizedBox(height: 30),
              // Submit Button
              ElevatedButton(
                onPressed: () {
                  voidSubmit(docID: currentDocID);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'Submit Quiz',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your Quizzes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: fireStoreService.IT_QUIZ_FETCH(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No quizzes created yet'));
                  }

                  List notesList = snapshot.data!.docs;
                  List filteredNotesList = notesList.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String subCode = data['it_code'].toString().trim();
                    String topicCode = widget.topicode.trim();
                    return subCode == topicCode;
                  }).toList();

                  if (filteredNotesList.isEmpty) {
                    return const Center(
                        child: Text('No quizzes available for this topic'));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: DataTable(
                        columnSpacing: 16.0,
                        headingRowColor: WidgetStateProperty.all(
                            Colors.blueAccent.withOpacity(0.1)),
                        columns: const [
                          DataColumn(label: Text('Question')),
                          DataColumn(label: Text('Answer A')),
                          DataColumn(label: Text('Answer B')),
                          DataColumn(label: Text('Answer C')),
                          DataColumn(label: Text('Answer D')),
                          DataColumn(label: Text('Correct Answer')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: List.generate(filteredNotesList.length, (index) {
                          var quiz = filteredNotesList[index];
                          var quizData = quiz.data() as Map<String, dynamic>;
                          var question = quizData['it_question'] ?? '';
                          var answerA = quizData['it_a'] ?? '';
                          var answerB = quizData['it_b'] ?? '';
                          var answerC = quizData['it_c'] ?? '';
                          var answerD = quizData['it_d'] ?? '';
                          var correctAnswer =
                              quizData['it_correct_answer'] ?? '';
                          String docID = quiz.id;

                          return DataRow(cells: [
                            DataCell(Text(question)),
                            DataCell(Text(answerA)),
                            DataCell(Text(answerB)),
                            DataCell(Text(answerC)),
                            DataCell(Text(answerD)),
                            DataCell(Text(correctAnswer)),
                            DataCell(
                              Row(
                                children: [
                                  // Edit Button
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () async {
                                      DocumentSnapshot doc =
                                          await FirebaseFirestore.instance
                                              .collection('it_quiz')
                                              .doc(docID)
                                              .get();

                                      if (doc.exists) {
                                        var data =
                                            doc.data() as Map<String, dynamic>;
                                        _questionController.text =
                                            data['it_question'] ?? '';
                                        _answerAController.text =
                                            data['it_a'] ?? '';
                                        _answerBController.text =
                                            data['it_b'] ?? '';
                                        _answerCController.text =
                                            data['it_c'] ?? '';
                                        _answerDController.text =
                                            data['it_d'] ?? '';
                                        _correctAnswerController.text =
                                            data['it_correct_answer'] ?? '';

                                        setState(() {
                                          currentDocID = docID;
                                        });
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            title:
                                                const Text('Confirm Deletion'),
                                            content: const Text(
                                              'Are you sure you want to delete this quiz? This action cannot be undone.',
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  fireStoreService
                                                      .deleteQuiz(docID);
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
