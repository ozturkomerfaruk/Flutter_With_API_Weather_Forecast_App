import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final myController = TextEditingController(); // ana sayfaya yazı göndermek

  @override
  void dispose() {
    myController.dispose(); //açık kalmasın kapatalım.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/search.jpg"),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors
            .transparent, //Scaffold Containerin önüne geçmesini engelledik
        body: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70),
                child: TextField(
                  controller: myController, //bunu kullanmamız lazım
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.search,
                      size: 30,
                    ),
                    hintText: "Select City",
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30),
                ),
              ),
              TextButton(
                  onPressed: () async {
                    var response = await http.get(
                        "https://www.metaweather.com/api/location/search/?query=${myController.text}");
                    jsonDecode(response.body).isEmpty
                        ? _showDialog()
                        : Navigator.pop(context, myController.text);
                  },
                  child: Text(
                    "Bring the city ",
                    style: TextStyle(
                      fontSize: 30,
                      backgroundColor: Colors.blueGrey,
                      color: Colors.black,
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: new Text("The city you were looking for was not found"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
