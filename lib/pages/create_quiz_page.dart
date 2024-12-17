import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_drawer.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/pages/make_quiz.dart';
import 'package:flutter_application_1/pages/quiz_page.dart';
import 'package:flutter_application_1/service/firestore.dart';

class QuizCreatePage extends StatefulWidget {
  const QuizCreatePage({super.key});

  @override
  State<QuizCreatePage> createState() => _QuizCreatePageState();
}

class _QuizCreatePageState extends State<QuizCreatePage> {
  final FireStoreService fireStoreService = FireStoreService();
  late String userEmail;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    checkIfAdmin();
  }

  // Check if user email matches "admin@gmail.com"
  void checkIfAdmin() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      if (user != null && user.email == "admin@gmail.com") {
        isAdmin = true;
      } else {
        isAdmin = false;
      }
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Topics"),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreService.IT_LESSONS_FETCH(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String noteText = data['it_topics'];
                String topicCode = data['it_code'];
                Color cardColor = Colors.lightBlue[50]!;

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: cardColor,
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Topic Text
                        Text(
                          noteText,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: cardColor.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isAdmin) 
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MakeQuiz(
                                    topic: noteText,
                                    topicode: topicCode,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                            ),
                            child: const Text('Create Quiz'),
                          )
                        else 
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuizPage(
                                    topic: noteText,
                                    topicode: topicCode,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
                            ),
                            child: const Text('Take Quiz'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No Data'),
            );
          }
        },
      ),
    );
  }
}
