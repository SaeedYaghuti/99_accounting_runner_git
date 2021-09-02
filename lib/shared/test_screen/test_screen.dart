import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  static const String routeName = '/testScreen';
  TestScreen({Key? key}) : super(key: key);
  final String title = 'Test Screen';

  @override
  _TestScreenState createState() => _TestScreenState();
}

// class _TestScreenState extends State<TestScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Text('Welcome to Test Screen!'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {},
//         tooltip: 'Save',
//         child: Icon(
//           Icons.check,
//           size: 36.0,
//         ),
//       ),
//     );
//   }
// }

class _TestScreenState extends State<TestScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  int? _age;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: this._formKey,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Please fill in your name and age'),
                TextFormField(
                  autovalidate: false,
                  onSaved: (value) => this._name = value,
                  validator: (value) {
                    if (value == null || value.length < 3) {
                      return 'a minimum of 3 characters is required';
                    }
                  },
                ),
                // Counter(),
                CounterFormField(
                  autovalidate: false,
                  validator: (value) {
                    print('01 CounterFF validator run ...');
                    if (value == null || value < 0) {
                      print('02 CounterFF validator not valid');
                      return 'Negative values not supported';
                    }
                  },
                  onSaved: (value) => this._age = value,
                ),
                RaisedButton(
                  child: Text('Submit'),
                  onPressed: () {
                    if (this._formKey.currentState!.validate()) {
                      setState(() {
                        this._formKey.currentState!.save();
                      });
                    }
                  },
                ),
                SizedBox(height: 50.0),
                Text('${this._name} is ${this._age} years old')
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CounterFormField extends FormField<int> {
  CounterFormField({
    required FormFieldSetter<int> onSaved,
    required FormFieldValidator<int> validator,
    int initialValue = 0,
    bool autovalidate = false,
  }) : super(
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          autovalidate: autovalidate,
          builder: (FormFieldState<int> state) {
            return Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        if (state.value != null) state.didChange(state.value! - 1);
                      },
                    ),
                    Text(state.value.toString()),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (state.value != null) state.didChange(state.value! + 1);
                      },
                    ),
                  ],
                ),
                state.hasError
                    ? Text(
                        state.errorText!,
                        style: TextStyle(color: Colors.red),
                      )
                    : Container()
              ],
            );
          },
        );
}
