import 'package:flutter/material.dart';

Future<void> showErrorDialog(
    BuildContext context, String title, String content, Object e) async {
  await showDialog<Null>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text('$content \nerror: ${e.toString()}'),
      actions: [
        ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            })
      ],
    ),
  );
}
