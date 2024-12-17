import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/all_quiz_page.dart';
import 'package:flutter_application_1/pages/create_quiz_page.dart';
import 'package:flutter_application_1/pages/home_page.dart';
// import 'package:flutter_application_1/pages/quiz_page.dart';

Widget buildAppDrawer(BuildContext context, VoidCallback logout) {
  final User? user = FirebaseAuth.instance.currentUser;
  return Drawer(
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 188, 198, 206), Color.fromARGB(255, 88, 89, 97)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Color.fromARGB(255, 161, 49, 196),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'You are logged in as:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user != null ? user.email ?? "No email available" : "Not logged in",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Drawer Items
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                leading: const Icon(Icons.home, color: Color.fromARGB(255, 151, 153, 156)),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
              ),
              if (user?.email == "admin@gmail.com") ...[
                // Admin only: Create Quizzes
                ListTile(
                  leading: const Icon(Icons.bubble_chart, color: Colors.purpleAccent),
                  title: const Text('Create Quizzes'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QuizCreatePage()),
                    );
                  },
                ),
              ] else ...[
                // User: Take A Short Quizzes
                ListTile(
                  leading: const Icon(Icons.book, color: Colors.greenAccent),
                  title: const Text('Take A Short Quiz'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QuizCreatePage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.quiz, color: Colors.greenAccent),
                  title: const Text('View Quizzes Results'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AllQuizPage()),
                    );
                  },
                ),
              ],
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout'),
                onTap: logout, 
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Thank you for using our app!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    ),
  );
}

