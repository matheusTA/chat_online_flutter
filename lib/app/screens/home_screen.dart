import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF15181b),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.lock,
            size: 100,
            color: Color(0xFF757575),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 15.0, 0, 25.0),
            child: Text(
              "Para entrar no bate-papo online é preciso fazer login com o google.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF757575), fontSize: 25.0),
            ),
          ),
          FlatButton(
            child: Text(
              "Autenticar com o google",
              style: TextStyle(fontSize: 20.0),
            ),
            color: Color(0xFF7159c1),
            textColor: Colors.white,
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
