import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:shop/shared/custom_form_fields/switch_form_field.dartx';
// import 'package:shop/shared/custom_form_fields/text_form_field.dartx';
// import 'package:shop/shared/custom_form_fields/toggle_buttons_form_field.dartx';

import 'multi_selection_form_field.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Dating App - Signup Form',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       // home: FormFieldsPage(title: 'Signup Form'),
//       home: FormFieldsPage(),
//     );
//   }
// }

enum Gender {
  Male,
  Female,
  Other,
}

enum Interest { Sports, Tech, Games, Mentoring, Art, Travel, Music, Reading, Cooking, Blogging }

class SignupUser {
  String? name;
  Gender? gender;
  DateTime? birthdate;
  List<Interest>? interests;
  bool ethicsAgreement;

  SignupUser({
    this.name,
    this.gender,
    this.birthdate,
    this.interests,
    this.ethicsAgreement = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender.toString(),
        'birthdate': birthdate.toString(),
        'interests': interests.toString(),
        'ethicsAgreement': ethicsAgreement,
      };
}

class FormFieldsScreen extends StatefulWidget {
  static const String routeName = '/formFieldsPage';
  // FormFieldsPage({Key? key, required this.title}) : super(key: key);
  FormFieldsScreen({Key? key}) : super(key: key);
  final String title = 'Form Field Example';

  @override
  _FormFieldsScreenState createState() => _FormFieldsScreenState();
}

class _FormFieldsScreenState extends State<FormFieldsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _formResult = SignupUser();

  final nameFocusNode = FocusNode();
  final genderFocusNodes = [FocusNode(), FocusNode(), FocusNode()];
  final birthdateFocusNodes = [FocusNode(), FocusNode(), FocusNode()];
  final interestsFocusNode = FocusNode();
  final ethicsAgreementFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              // _buildText(),
              // SizedBox(height: 8.0),
              // _buildToggle(),
              // SizedBox(height: 8.0),
              // _buildDate(),
              // SizedBox(height: 8.0),
              _buildMultiSelection(context),
              // SizedBox(height: 8.0),
              // _buildSwitch(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitForm,
        tooltip: 'Save',
        child: Icon(
          Icons.check,
          size: 36.0,
        ),
      ),
    );
  }

  // Widget _buildText() {
  //   return MyTextFormField(
  //     decoration: const InputDecoration(
  //       hintText: 'Enter your name',
  //       labelText: 'Name',
  //     ),
  //     inputFormatters: [LengthLimitingTextInputFormatter(30)],
  //     initialValue: _formResult.name,
  //     validator: (userName) {
  //       if (userName?.isEmpty ?? true) {
  //         return 'Name is required';
  //       }
  //       if (userName == null || userName.length < 3) {
  //         return 'Name is too short';
  //       }
  //       return null;
  //     },
  //     onSaved: (userName) {
  //       _formResult.name = userName!;
  //     },
  //     autofocus: true,
  //     focusNode: nameFocusNode,
  //     textInputAction: TextInputAction.next,
  //     onTap: () {
  //       FocusScope.of(context).unfocus();
  //       FocusScope.of(context).requestFocus(nameFocusNode);
  //     },
  //   );
  // }

  // Widget _buildToggle() {
  //   return MyToggleButtonsFormField<Gender>(
  //     decoration: InputDecoration(
  //       labelText: 'Gender',
  //     ),
  //     initialValue: _formResult.gender,
  //     items: Gender.values,
  //     itemBuilder: (BuildContext context, Gender genderItem) => Text(describeEnum(genderItem)),
  //     selectedItemBuilder: (BuildContext context, Gender genderItem) => Text(describeEnum(genderItem)),
  //     validator: (gender) => gender == null ? 'Gender is required' : null,
  //     onSaved: (gender) {
  //       _formResult.gender = gender!;
  //     },
  //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
  //     focusNodes: genderFocusNodes,
  //     onChanged: (gender) {
  //       final genderIndex = Gender.values.indexOf(gender);
  //       if (genderIndex >= 0) {
  //         FocusScope.of(context).unfocus();
  //         FocusScope.of(context).requestFocus(genderFocusNodes[genderIndex]);
  //       }
  //     },
  //   );
  // }

  // Widget _buildDate() {
  //   return MyDateFormField(
  //     decoration: const InputDecoration(
  //       labelText: 'Birthdate',
  //     ),
  //     validator: (birthdate) {
  //       if (birthdate == null) {
  //         return 'A valid birthdate is required';
  //       }
  //       final now = DateTime.now();
  //       if (birthdate.isAfter(now)) {
  //         return 'You are not born yet !';
  //       }
  //       const MAX_AGE = 99;
  //       if (birthdate.isBefore(now.subtract(Duration(days: 365 * MAX_AGE)))) {
  //         return 'Select a more recent date';
  //       }
  //       const MIN_AGE = 18;
  //       if (birthdate.isAfter(now.subtract(Duration(days: 365 * MIN_AGE)))) {
  //         return 'Only adults are allowed';
  //       }
  //       return null;
  //     },
  //     onSaved: (birthdate) {
  //       _formResult.birthdate = birthdate!;
  //     },
  //     dayFocusNode: birthdateFocusNodes[0],
  //     dayOnTap: () {
  //       FocusScope.of(context).unfocus();
  //       FocusScope.of(context).requestFocus(birthdateFocusNodes[0]);
  //     },
  //     monthFocusNode: birthdateFocusNodes[1],
  //     monthOnTap: () {
  //       FocusScope.of(context).unfocus();
  //       FocusScope.of(context).requestFocus(birthdateFocusNodes[1]);
  //     },
  //     yearFocusNode: birthdateFocusNodes[2],
  //     yearOnTap: () {
  //       FocusScope.of(context).unfocus();
  //       FocusScope.of(context).requestFocus(birthdateFocusNodes[2]);
  //     },
  //   );
  // }

  Widget _buildMultiSelection(BuildContext context) {
    return MyMultiSelectionFormField<Interest>(
      decoration: InputDecoration(
        labelText: 'Interests',
      ),
      hint: Text('Select more interests'),
      isDense: true,
      focusNode: interestsFocusNode,
      options: Interest.values,
      titleBuilder: (interest) => Text(describeEnum(interest)),
      chipLabelBuilder: (interest) => Text(describeEnum(interest)),
      initialValues: _formResult.interests!,
      validator: (interests) => interests == null || interests.length < 3 ? 'Please select at least 3 interests' : null,
      onSaved: (interests) {
        _formResult.interests = interests!;
      },
      onChanged: (_) {
        FocusScope.of(context).unfocus();
        FocusScope.of(context).requestFocus(interestsFocusNode);
      },
    );
  }

  // Widget _buildSwitch() {
  //   return  MySwitchFormField(
  //               decoration: InputDecoration(
  //                 labelText: 'Ethics agreement',
  //                 hintText: null,
  //               ),
  //               focusNode: ethicsAgreementFocusNode,
  //               initialValue: _formResult.ethicsAgreement,
  //               validator: (userHasAgreedWithEthics) =>
  //                   userHasAgreedWithEthics == false ? 'Please agree with ethics' : null,
  //               onSaved: (userHasAgreedWithEthics) {
  //                 _formResult.ethicsAgreement = userHasAgreedWithEthics!;
  //               },
  //               onChanged: (_) {
  //                 FocusScope.of(context).unfocus();
  //                 FocusScope.of(context).requestFocus(ethicsAgreementFocusNode);
  //               },
  //             )
  //           ;
  // }

  void _submitForm() {
    final FormState form = _formKey.currentState!;

    if (form.validate()) {
      form.save();
      print('New user saved with signup data:\n');
      print(_formResult.toJson());
    }
  }
}
