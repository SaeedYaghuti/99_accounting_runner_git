import 'package:flutter/material.dart';

Future<dynamic> confirmDialog(
  BuildContext context,
  String title,
  String content,
  String noTitle,
  String yesTitle,
  Function yesHandler,
  Function noHandler,
) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        FlatButton(
          child: Text(noTitle),
          onPressed: () {
            // close dilog and send back no
            Navigator.of(ctx).pop(false);
            noHandler();
          },
        ),
        FlatButton(
          child: Text(yesTitle),
          onPressed: () {
            // close dilog and send back no
            Navigator.of(ctx).pop(true);
            yesHandler();
          },
        ),
      ],
    ),
  );
}
