
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void showSelectSimpleDialog(BuildContext context, String title, List<String> titles,
    Function onSelected) {
  
  final TextEditingController _textController = TextEditingController();

  List<SimpleDialogOption> getListOptions(
      List<String> titles, Function onSelected) {
    var lst = <SimpleDialogOption>[];
    for (var item in titles) {
      lst.add(SimpleDialogOption(
          child: Text(item),
          onPressed: () {
            onSelected(item, _textController.text);
            Navigator.of(context).pop();
          }));
    }
    return lst;
  }

  Widget getTextEdit(){
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _textController,
        decoration: 
        InputDecoration(
          hintText: "목적을 입력하세요",
          labelStyle: TextStyle(color: Colors.black),
          hintStyle: TextStyle(fontSize: 18.0, color: Color.fromARGB(255, 94, 230, 155)),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(width: 1, color: Color.fromARGB(255, 11, 11, 11)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(width: 1, color: Color.fromARGB(255, 11, 11, 11)),
        ),

      	labelText: '제목',
      )),
    );
  }
  SimpleDialog dialog = SimpleDialog(
    backgroundColor: Color.fromARGB(150, 255, 255, 255),
    title: Text(title),
    shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.all(Radius.circular(12.0))),
    children: [getTextEdit(), for (var n in getListOptions(titles, onSelected)) n ]
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return dialog;
    },
  );
}