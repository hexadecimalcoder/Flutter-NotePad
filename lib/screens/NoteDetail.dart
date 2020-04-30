import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:notepad/models/note.dart';
import 'package:notepad/utils/database_helper.dart';
import 'dart:async';
import 'package:intl/intl.dart';


class NoteDetail extends StatefulWidget {
  final String appbarTitle;
  final Note note;
  NoteDetail(this.note, this.appbarTitle);
  @override
  _NoteDetailState createState() => _NoteDetailState(this.note, this.appbarTitle);
}

class _NoteDetailState extends State<NoteDetail> {

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;
  var _formKey = GlobalKey<FormState>();
  static var _properties = ['High', 'Low'];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  _NoteDetailState(this.note, this.appBarTitle);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleController.text = note.title;
    descriptionController.text = note.description;
    return WillPopScope(
      onWillPop: (){
        //Works when back button pressed in navbar
        movetoLastScreen();

      },


      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: Theme.of(context).primaryColorLight,
              size: 34.0,
            ),
            onPressed: (){
              //Works when the top back icon pressed
              movetoLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
          child: ListView(
            children: <Widget>[
              Text(
                  'Priority',
                  style: TextStyle(
                    fontSize: 24.0,
                  )
              ),
              ListTile(
                title: DropdownButton(
                  items: _properties.map((String dropDownStringItem){
                    return DropdownMenuItem<String> (
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelectedByUser){
                    setState(() {
                      print('Dropdown changed to $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: titleController,
                    style: textStyle,
                    validator: (string){
                      if(string.isEmpty){
                        return 'This field is compulsory';
                      }
                      return null;
                    },
                    onChanged: (value){
                      updateTitle();
                      print('Something changed in title text field');
                    },
                    decoration: InputDecoration(
                        labelText: 'Enter Title',
                        hintText: 'Give the main objective of note',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextFormField(
                  controller: descriptionController,
                  style: textStyle,
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: null,
                  onChanged: (value){
                    updateDescription();
                    print('Something changed in description text field');
                  },
                  decoration: InputDecoration(
                      labelText: 'Enter Description',
                      hintText: 'Write something about your note',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)
                        ),
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: (){
                          setState(() {
                            if(_formKey.currentState.validate()) {
                              _save();
                              print('Save button clicked');
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 5.0,),
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)
                        ),
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: (){
                          setState(() {
                            _delete();
                            print('Cancel button clicked');
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  void movetoLastScreen(){
    Navigator.pop(context, true);       //pass some parameter to main screen
  }
  //Convert the string priority before saving to database
  void updatePriorityAsInt(String value) {
    switch(value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }
  //Convert the int priority before displaying
  String getPriorityAsString(int value) {
    String priority;
    switch(value){
      case 1:
        return _properties[0]; //'HIGH'
        break;
      case 2:
        return _properties[1]; //'LOW'
        break;
    }
  }
  //UpdateTitle of note object
  void updateTitle(){
    note.title = titleController.text;
  }
  //Update the description of note object
  void updateDescription(){
    note.description = descriptionController.text;
  }
  //Save Data to database
  void _save() async{
    movetoLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if(note.id!= null){       //Update operation
      var result = await helper.updateNote(note);
    }
    else{                     //Insert operation
      var result = await helper.insertNote(note);
    }
    if(result!=0){        //success
      _showAlertDialog('Status', 'Note Saved Successfully !');
    }
    else{                 //failure
      _showAlertDialog('Status', 'Something Went Wrong !');
    }
  }
  //Delete present note
  void _delete() async {
    movetoLastScreen();
    //WHen delete the newnote
    if(note.id != null){
      _showAlertDialog('Status', 'Note Deleted');
      return;
    }
    int result = await helper.deleteNote(note.id);
    if(result!=0){
      _showAlertDialog('Status', 'Note Deleted');
    }
    else{
      _showAlertDialog('Status', 'Something Went Wrong !');
    }
  }
  void _showAlertDialog(String title, String text){
    AlertDialog alertdialog = AlertDialog(
      title: Text(title),
      content: ListTile(
        title: Text(
          text,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
        subtitle: Text(
          'Tap outside the box to dismiss',
          style: TextStyle(
            fontSize: 14.0,
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
    showDialog(
      context: context,
      builder: (_) => alertdialog,
    );
  }


}
