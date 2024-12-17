import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_button.dart';
import 'package:flutter_application_1/components/my_textfield.dart';
import 'package:flutter_application_1/helper/helper_functions.dart';

// ignore: must_be_immutable
class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  
    const RegisterPage({super.key, required this.onTap});

    @override
  State<StatefulWidget> createState() => _RegisterPageState();

}
  class _RegisterPageState extends State<RegisterPage>{

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  Future<void> register() async {
    showDialog(
      context: context, 
      builder: (context) => const Center(
      child: CircularProgressIndicator(),
    )
    );

    if(passwordController.text != confirmPwController.text){
      Navigator.pop(context);

      displayMessageToUser("Password Don't Matched!", context);
    }else{
      try {
      UserCredential? userCredential = 
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text, 
      password: passwordController.text,
      );
      Navigator.pop(context);

      
      displayMessageToUser('Account Created Succesfully', context);
    await FirebaseFirestore.instance.collection('it_users').doc(userCredential.user?.uid).set({
      'student_id': usernameController.text, 
      'email': emailController.text,        
      'timestamp': Timestamp.now(),          
    });
    
    }     

    on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
    }
    
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary),
              const SizedBox(height: 25),
              const Text(
                'R E G I S T E R',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),
              MyTextfield(
                  hintText: "Student Number",
                  obscureText: false,
                  controller: usernameController),
              const SizedBox(height: 10),
              MyTextfield(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController),
              const SizedBox(height: 10),
              MyTextfield(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController),
              const SizedBox(height: 10),
              MyTextfield(
                  hintText: "Confirm Password",
                  obscureText: true,
                  controller: confirmPwController),
              const SizedBox(height: 30),
              MyButton(text: "Sign Up", onTap: register),
              GestureDetector(
                onTap: widget.onTap, //error here
                child: const Text(
                  'Already Have Existing Account? Log in now',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  }
