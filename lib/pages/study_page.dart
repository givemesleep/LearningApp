import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_drawer.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/service/firestore.dart';

class StudyPage extends StatefulWidget {
  final String topic;
  final String topicode;

  const StudyPage({super.key, required this.topic, required this.topicode});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
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

  final FireStoreService fireStoreService = FireStoreService();
  final TextEditingController itStudy = TextEditingController();
  final TextEditingController itSubStudy = TextEditingController();
  final TextEditingController itCode = TextEditingController();

  void openNoteBox({String? docID, String? customHeader}) {
    final isAdding = docID == null;
    itCode.text = widget.topicode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isAdding ? 'Add Course Lesson Topics' : 'Update Course Lesson Topics',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (customHeader != null && customHeader.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      customHeader,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              TextField(
                controller: itStudy,
                decoration: InputDecoration(
                  labelText: isAdding
                      ? 'Title of the Topic'
                      : 'Update Title of the Topic',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'e.g., Introduction to Programming',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: itSubStudy,
                decoration: InputDecoration(
                  labelText: 'Details of the Topic',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'Add topic description here...',
                ),
                maxLines: 5,
                minLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 15),
              Visibility(
                visible: false,
                child: TextField(
                  controller: itCode,
                  decoration: const InputDecoration(
                    hintText: 'Hidden Topic Code',
                  ),
                ),
              ),
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
              if (isAdding) {
                fireStoreService.addTopic(
                    itStudy.text, itSubStudy.text, itCode.text);
              } else {
                fireStoreService.updateTopic(
                    docID, itStudy.text, itSubStudy.text, itCode.text);
              }
              itStudy.clear();
              itSubStudy.clear();
              itCode.clear();
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
        title: Text(widget.topic),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.reset_tv_rounded),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              },
            );
          },
        ),
      ),
      drawer: buildAppDrawer(context, logout),
      floatingActionButton:
          FirebaseAuth.instance.currentUser?.email == "admin@gmail.com"
              ? FloatingActionButton(
                  onPressed: () => openNoteBox(),
                  child: const Icon(Icons.add),
                )
              : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: fireStoreService.IT_TOPIC_FETCH(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;
              List filteredNotesList = notesList.where((doc) {
                var data = doc.data() as Map<String, dynamic>;
                String subCode = data['it_code'].toString().trim();
                String topicCode = widget.topicode.trim();
                return subCode == topicCode;
              }).toList();

              if (filteredNotesList.isEmpty) {
                return const Center(
                    child: Text('No posts available for this topic.'));
              }

              return ListView.builder(
                itemCount: filteredNotesList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = filteredNotesList[index];
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText = data['it_study'];
                  String subText = data['it_substudy'];
                  String docID = document.id;

                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(noteText,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(subText, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          if (FirebaseAuth.instance.currentUser?.email ==
                              "admin@gmail.com")
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    openNoteBox(
                                        docID: docID,
                                        customHeader: 'Edit the Course Topic');
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
                                                  BorderRadius.circular(16)),
                                          title: const Text('Confirm Deletion'),
                                          content: const Text(
                                              'Are you sure you want to delete this post? This action cannot be undone.'),
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
                                                    .deleteTopic(docID);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('No posts available.'));
            }
          },
        ),
      ),
    );
  }
}
