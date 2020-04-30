import 'package:flutter/material.dart';
import 'package:notepad/Screens/NoteDetail.dart';
import 'package:notepad/Screens/NoteList.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    primarySwatch: Colors.teal,

  ),
  title: "This is title",
  home: NoteList(),
));