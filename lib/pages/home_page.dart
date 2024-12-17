import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_drawer.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/pages/study_page.dart';
import 'package:flutter_application_1/service/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FireStoreService fireStoreService = FireStoreService();
  // ignore: non_constant_identifier_names
  final TextEditingController it_code = TextEditingController();
  // ignore: non_constant_identifier_names
  final TextEditingController it_intro = TextEditingController();
  // ignore: non_constant_identifier_names
  final TextEditingController it_topics = TextEditingController();
  // ignore: non_constant_identifier_names
  final TextEditingController it_profs = TextEditingController();

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage(
                  onTap: () {},
                )),
      );
    }
  }

  void openNoteBoxs({String? docID}) {
    final isAdding = docID == null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isAdding ? 'Add Course' : 'Update Enrolled Course',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: it_code,
                decoration: InputDecoration(
                  labelText:
                      isAdding ? 'Enter Course Code' : 'Update Course Code',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'e.g., CS101',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: it_topics,
                decoration: InputDecoration(
                  labelText: 'Course Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'e.g., Introduction to Programming',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: it_profs,
                decoration: InputDecoration(
                  labelText: 'Instructor Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'e.g., John Doe',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: it_intro,
                decoration: InputDecoration(
                  labelText: 'Course Description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'Detailed course overview...',
                ),
                maxLines: 5,
                minLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (it_code.text.trim().isEmpty ||
                  it_topics.text.trim().isEmpty ||
                  it_profs.text.trim().isEmpty ||
                  it_intro.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'All fields are required! Please fill out everything.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              if (isAdding) {
                fireStoreService.addNoteme(
                  it_code.text.trim(),
                  it_intro.text.trim(),
                  it_profs.text.trim(),
                  it_topics.text.trim(),
                );
              } else {
                fireStoreService.updateNote(
                  docID,
                  it_code.text.trim(),
                  it_intro.text.trim(),
                  it_profs.text.trim(),
                  it_topics.text.trim(),
                );
              }

              it_code.clear();
              it_topics.clear();
              it_intro.clear();
              it_profs.clear();
              Navigator.pop(context);
            },
            child: Text(
              isAdding ? 'Create' : 'Update',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Platform Application'),
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
      floatingActionButton:
          FirebaseAuth.instance.currentUser?.email == "admin@gmail.com"
              ? FloatingActionButton(
                  onPressed: () => openNoteBoxs(),
                  child: const Icon(Icons.add),
                )
              : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreService.IT_LESSONS_FETCH(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;
            return LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth < 600
                        ? 1
                        : constraints.maxWidth < 1000
                            ? 2
                            : 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = notesList[index];
                    String docID = document.id;
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String noteText = data['it_topics'];
                    String noteIntro = data['it_intro'];
                    String noteProf = data['it_prof'];
                    Color cardColor = Colors.lightBlue[50]!;

                    //Body Starts
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: cardColor,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.blueAccent,
                                        child: Text(
                                          noteProf.isNotEmpty
                                              ? noteProf[0]
                                              : '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            noteProf,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Instructor',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    noteText,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    noteIntro,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          String topic = data['it_topics'];
                                          String topicode = data['it_code'];
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => StudyPage(
                                                    topic: topic,
                                                    topicode: topicode)),
                                          );
                                        },
                                        icon: const Icon(Icons.remove_red_eye),
                                        label: const Text('View'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.blueAccent,
                                          elevation: 5,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                      if (FirebaseAuth
                                              .instance.currentUser?.email ==
                                          "admin@gmail.com")
                                        Row(
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                openNoteBoxs(docID: docID);
                                              },
                                              icon: const Icon(Icons.edit),
                                              label: const Text('Edit'),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    Colors.orangeAccent,
                                                elevation: 5,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                // Show a confirmation dialog
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          "Confirm Deletion"),
                                                      content: const Text(
                                                          "Are you sure you want to delete this item? This action cannot be undone."),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const Text(
                                                              "Cancel"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            // Perform the deletion
                                                            fireStoreService
                                                                .deleteNote(
                                                                    docID);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const Text(
                                                              "Delete",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red)),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              icon: const Icon(Icons.delete),
                                              label: const Text('Delete'),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    Colors.redAccent,
                                                elevation: 5,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
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
