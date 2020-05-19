import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextInput extends StatefulWidget {
  final Function({String text, File imgFile}) sendMessage;
  final bool isAuth;
  TextInput({@required this.sendMessage, @required this.isAuth});

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  void _resetText() {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.photo_camera),
              onPressed: widget.isAuth
                  ? () async {
                      final File imgFile = await ImagePicker.pickImage(
                          source: ImageSource.camera);

                      if (imgFile == null) return;

                      widget.sendMessage(imgFile: imgFile);
                    }
                  : null),
          Expanded(
              child: TextField(
            controller: _textController,
            decoration:
                InputDecoration.collapsed(hintText: "Enviar uma mesagem"),
            onChanged: (text) {
              setState(() {
                _isComposing = text.isNotEmpty;
              });
            },
            onSubmitted: (text) {
              widget.sendMessage(text: text);
              _resetText();
            },
          )),
          IconButton(
              icon: Icon(Icons.send),
              onPressed: _isComposing
                  ? () {
                      widget.sendMessage(text: _textController.text);
                      _resetText();
                    }
                  : null)
        ],
      ),
    );
  }
}
