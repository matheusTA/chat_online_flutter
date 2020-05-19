import 'dart:io';

import 'package:chat_online_flutter/app/widgets/message.dart';
import 'package:chat_online_flutter/app/widgets/textInput.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return authResult.user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessage({String text, File imgFile}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _globalKey.currentState.showSnackBar(SnackBar(
        content: Text("Não foi possível fazer o login, tente novamente!"),
        backgroundColor: Colors.red,
      ));
    }

    var now = new DateTime.now();
    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "senderTime": "${now.hour}:${now.minute}",
      "time": Timestamp.now(),
    };

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);

      setState(() {
        _isLoading = true;
      });

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data["imgUrl"] = url;

      setState(() {
        _isLoading = false;
      });
    }

    if (text != null) {
      data["text"] = text;
    }

    Firestore.instance.collection("messages").add(data);
  }

  Widget _showMessages(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
        return Center(
          child: CircularProgressIndicator(),
        );
        break;
      default:
        List<DocumentSnapshot> documents =
            snapshot.data.documents.reversed.toList();

        return ListView.builder(
            itemCount: documents.length,
            reverse: true,
            itemBuilder: (context, index) {
              return Message(
                  data: documents[index].data,
                  mine: documents[index].data["uid"] == _currentUser?.uid);
            });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _globalKey,
        appBar: AppBar(
          title: Text(_currentUser != null
              ? "Olá ${_currentUser.displayName}"
              : "Chat App"),
          elevation: 0,
          actions: <Widget>[
            _currentUser != null
                ? IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      googleSignIn.signOut();
                      _globalKey.currentState.showSnackBar(SnackBar(
                        content: Text("Você saiu com sucesso!"),
                      ));
                    })
                : Container()
          ],
        ),
        body: Column(
          children: <Widget>[
            _currentUser != null
                ? Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance
                            .collection("messages")
                            .orderBy("time")
                            .snapshots(),
                        builder: _showMessages))
                : Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.lock,
                            size: 100,
                            color: Color(0xFF757575),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(5, 15.0, 5, 25.0),
                            child: Text(
                              "Para ler as mensagens é preciso fazer login com o google, digite sua mensagem e clique em enviar que será pedido para você se autenticar",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF757575), fontSize: 25.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            _isLoading ? LinearProgressIndicator() : Container(),
            TextInput(
              sendMessage: _sendMessage,
            ),
          ],
        ));
  }
}
