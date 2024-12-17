import 'package:flutter/material.dart';

void displayMessageToUser(String message, BuildContext context){
  showDialog(
    context: context, 
  builder: (context) => AlertDialog(
    title: Text(message),
  ));
}

void displayMessageToUser1(String message, BuildContext context, Null Function() param2){
  showDialog(
    context: context, 
  builder: (context) => AlertDialog(
    title: Text(message),
  ));
}