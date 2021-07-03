import 'package:flutter/material.dart';

Future<dynamic> confirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String noTitle,
  required String yesTitle,
  Function? yesHandler,
  Function? noHandler,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: TextStyle(fontSize: 24)),
      content: Text(content, style: TextStyle(fontSize: 24)),
      actions: [
        FlatButton(
          child: Text(noTitle, style: TextStyle(fontSize: 24)),
          onPressed: () {
            // close dilog and send back false
            Navigator.of(ctx).pop(false);
            if (noHandler != null) noHandler();
          },
        ),
        FlatButton(
          child: Text(yesTitle, style: TextStyle(fontSize: 24)),
          onPressed: () {
            // close dilog and send back true
            Navigator.of(ctx).pop(true);
            if (yesHandler != null) yesHandler();
          },
        ),
      ],
    ),
  );
}
