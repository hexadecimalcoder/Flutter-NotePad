import 'package:flutter/material.dart';
import 'package:notepad/screens/NoteDetail.dart';
import 'package:notepad/models/note.dart';
import 'package:notepad/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
class NoteList extends StatefulWidget {

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count= 0;
  @override

  Widget build(BuildContext context) {
    if(noteList == null){
      noteList = List<Note>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        centerTitle: true,
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 40.0,
        ),
        tooltip: 'Add a new note',
        onPressed: (){
          navigateToDetail(Note('','', 2, ''), 'Add New Note');
          print('add new');
        },
      ),
    );
  }
  Widget getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
        itemCount: count+1,
        itemBuilder: (BuildContext context, int position) {
          if (position == 0) {
            return Container(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 42.0,
                  ),
                  title: Text(
                    'Developed By Souhardhya Paul',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                  subtitle: Text(
                    'Show some love by visiting his website',
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                  onTap: _launchURL,
                ),
                elevation: 10.0,
                color: Colors.blue,
              ),
            );
          }
          else{
            return Card(
              color: Colors.grey[100],
              elevation: 2.0,
              child: ListTile(
                leading: CircleAvatar(
                  child: getPriorityIcon(this.noteList[position-1].priority),
                  backgroundColor: getPriorityColor(this.noteList[position-1].priority),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      this.noteList[position-1].title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    Text(
                      this.noteList[position-1].description,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  'Added on : ${this.noteList[position-1].date}',
                ),
                trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.pink, size: 30.0,),
                    color: Colors.grey,
                    onPressed: (){
                      _delete(context, noteList[position-1]);
                    }
                ),
                onTap: (){
                  navigateToDetail(this.noteList[position-1], 'Add New Note');
                  print('new screen');
                },
              ),
            );
          }
        }
    );
  }

  //Returns the priority color
  Color getPriorityColor(int priority){
    switch(priority){
      case 1:
        return Colors.yellow;
        break;
      case 2:
        return Colors.green;
        break;
      default:
        return Colors.green;
    }
  }
  //Returns the priority icon
  Icon getPriorityIcon(int priority){
    switch(priority){
      case 1:
        return Icon(
          Icons.assignment_late,
          color: Colors.redAccent,
        );
        break;
      case 2:
        return Icon(
          Icons.add_alert,
          color: Colors.yellowAccent,
        );
        break;
      default:
        return Icon(
          Icons.add_alert,
          color: Colors.yellowAccent,
        );
    }
  }
  //Delete function
  void _delete(BuildContext context, Note note) async{
    int result =await databaseHelper.deleteNote(note.id);
    if(result!=0){
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }
  void _showSnackBar (BuildContext context, String message){
    final snackbar = SnackBar(content: Text(message),);
    Scaffold.of(context).showSnackBar(snackbar);
  }
  void navigateToDetail(Note note, String title) async{
    bool result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context){
          return NoteDetail(note, title);
        }
        )
    );
    if (result==true) {
      updateListView();
    }
  }
  void updateListView(){
    final Future<Database> dbFuture = databaseHelper.initialiseDatabase();
    dbFuture.then((database){
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
  _launchURL() async {
    const url = 'https://souhardhyapaul.tk';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
