import 'dart:io';

import 'package:chat_online_flutter/app/components/message_component.dart';
import 'package:chat_online_flutter/app/components/text_component.dart';
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
  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      _currentUser = user;
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
      "senderTime": "${now.hour}:${now.minute}"
    };

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data["imgUrl"] = url;
    }

    if (text != null) {
      data["text"] = text;
    }

    Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _globalKey,
        appBar: AppBar(
          title: Text("Olá"),
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream:
                        Firestore.instance.collection("messages").snapshots(),
                    builder: (context, snapshot) {
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
                                    data: documents[index].data, mine: true);
                              });
                      }
                    })),
            TextComponent(
              sendMessage: _sendMessage,
            ),
          ],
        ));
  }
}
