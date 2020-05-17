import 'package:flutter/material.dart';

class TextComponent extends StatefulWidget {
  Function(String) sendMessage;

  TextComponent({@required this.sendMessage});

  @override
  _TextComponentState createState() => _TextComponentState();
}

class _TextComponentState extends State<TextComponent> {
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
          IconButton(icon: Icon(Icons.photo_camera), onPressed: () {}),
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
              widget.sendMessage(text);
              _resetText();
            },
          )),
          IconButton(
              icon: Icon(Icons.send),
              onPressed: _isComposing
                  ? () {
                      widget.sendMessage(_textController.text);
                      _resetText();
                    }
                  : null)
        ],
      ),
    );
  }
}
