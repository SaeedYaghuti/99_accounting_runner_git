import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/account_model.dart';
import 'package:shop/accounting/accounting_logic/accounts_tree.dart';
import 'package:shop/accounting/accounting_logic/classification/transaction_classification.dart';
import 'package:shop/accounting/accounting_logic/floating_account.dart';
import 'package:shop/accounting/accounting_logic/floating_account_tree.dart';
import 'package:shop/accounting/expenditure/expenditure_class_tree.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/constants.dart';
import 'package:shop/shared/result_status.dart';

class ClassificationFormFields {
  final formKey = GlobalKey<FormState>();

  int? id;
  int? authId;
  Function? resetState;

  ClassificationFormFields({
    int? id,
    int? authId,
    AuthProviderSQL? authProvider,
    TransactionClassification? parentClass,
    String? titleEnglish,
    String? titlePersian,
    String? titleArabic,
    double? amount,
    AccountModel? paidBy,
    String? note,
    TransactionClassification? expClass,
    FloatingAccount? floatAccount,
    DateTime? date,
    Function? resetState,
  }) {
    this.id = id;
    this.authId = authId;
    this.parentClass = parentClass;
    this.titleEnglish = titleEnglish;
    this.titlePersian = titlePersian;
    this.titleArabic = titleArabic;
  }

  // # parentClass
  TransactionClassification? parentClassification;
  bool hasErrorParentClass = false;
  final parentClassFocusNode = FocusNode();
  TextEditingController parentClassController = TextEditingController();
  TransactionClassification? get parentClass {
    return parentClassification;
  }

  set parentClass(TransactionClassification? parentClassification) {
    this.parentClassification = parentClassification;
    this.parentClassController.text = (parentClassification == null) ? '' : parentClassification.titleEnglish;
  }

  String? validateParentClass(String? parentClassText) {
    // print('EXP_FRM_FLD | validateParentClass() 01 | input: $parentClassText');
    if (parentClassText == null || parentClassText.isEmpty) {
      return 'parentClass should not be empty';
    }
    if (parentClassification == null) {
      return 'parentClassification should not be null inside expenditureFields';
    }
    if (parentClassification!.titleEnglish != parentClassText &&
        parentClassification!.titlePersian != parentClassText &&
        parentClassification!.titleArabic != parentClassText) {
      return 'parentClassification.titleE|P|A is mismatch with input text';
    }
    return null;
  }

  // # titleEnglish
  final titleEnglishFocusNode = FocusNode();
  var hasErrorTitleEnglish = false;
  TextEditingController titleEnglishController = TextEditingController();
  set titleEnglish(String? text) {
    this.titleEnglishController.text = text ?? '';
  }

  String? get titleEnglish {
    return titleEnglishController.text;
  }

  String? validateTitleEnglish(String? titleEnglish) {
    if (titleEnglish == null || titleEnglish.isEmpty) {
      return 'English title should not be empty';
    }
    return null;
  }

  // # titlePersian
  final titlePersianFocusNode = FocusNode();
  var hasErrorTitlePersian = false;
  TextEditingController titlePersianController = TextEditingController();
  set titlePersian(String? text) {
    this.titlePersianController.text = text ?? '';
  }

  String? get titlePersian {
    return titlePersianController.text;
  }

  String? validateTitlePersian(String? titlePersian) {
    if (titlePersian == null || titlePersian.isEmpty) {
      return 'Persian title should not be empty';
    }
    return null;
  }

  // # titleArabic
  final titleArabicFocusNode = FocusNode();
  var hasErrorTitleArabic = false;
  TextEditingController titleArabicController = TextEditingController();
  set titleArabic(String? text) {
    this.titleArabicController.text = text ?? '';
  }

  String? get titleArabic {
    return titleArabicController.text;
  }

  String? validateTitleArabic(String? titleArabic) {
    if (titleArabic == null || titleArabic.isEmpty) {
      return 'Arabic title should not be empty';
    }
    return null;
  }

  // # note
  final noteFocusNode = FocusNode();
  var hasErrorNote = false;
  TextEditingController noteController = TextEditingController();
  String? get note {
    return noteController.text;
  }

  set note(String? text) {
    this.noteController.text = text ?? '';
  }

  String? validateNote(String? note) {
    if (note == null || note.isEmpty) {
      return 'Note should not be empty';
    }
    return null;
  }

  // # expClass
  TransactionClassification? expClassification;
  bool hasErrorExpClass = false;
  final expClassFocusNode = FocusNode();
  TextEditingController expClassController = TextEditingController();
  TransactionClassification? get expClass {
    return expClassification;
  }

  set expClass(TransactionClassification? expClassification) {
    this.expClassification = expClassification;
    this.expClassController.text = (expClassification == null) ? '' : expClassification.titleEnglish;
  }

  String? validateExpClass(String? expClassText) {
    // print('EXP_FRM_FLD | validateExpClass() 01 | input: $expClassText');
    if (expClassText == null || expClassText.isEmpty) {
      return 'expClass should not be empty';
    }

    if (expClassification == null) {
      return 'expClassification should not be null inside expenditureFields';
    }
    if (expClassification!.titleEnglish != expClassText &&
        expClassification!.titlePersian != expClassText &&
        expClassification!.titleArabic != expClassText) {
      return 'expClassification.titleE|P|A is mismatch with input text';
    }
    return null;
  }

  // # validate
  Result<bool> validate() {
    if (formKey.currentState == null) {
      print('EF20| Warn: _formKey.currentState == null');
      return Result(false, '_formKey.currentState is null');
    }
    // step#1 validate custom fields that have no predifined validate() method
    var errorMessages = '';
    if (parentClass == null) {
      hasErrorParentClass = true;
      errorMessages += '\nParentClass is empty';
    }
    if (titleEnglish == null) {
      hasErrorTitleEnglish = true;
      errorMessages += '\nTitleEnglish is empty';
    }
    if (titlePersian == null) {
      hasErrorTitlePersian = true;
      errorMessages += '\nTitlePersian is empty';
    }
    if (titleArabic == null) {
      hasErrorTitleArabic = true;
      errorMessages += '\nTitleArabic is empty';
    }
    if (expClass == null) {
      hasErrorExpClass = true;
      errorMessages += '\nExpClass is empty';
    }

    // step#2 validate FormField that have predifined validate() method
    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      errorMessages += '\nSome of regular form FormFeilds are not valid';
    }
    // print('EXP_FRM_FIELD | validate() | errorMessages: $errorMessages');

    if (resetState != null) resetState!();

    if (errorMessages == '') {
      return Result(true);
    } else {
      return Result(false, errorMessages);
    }
  }

  // # Example
  static ClassificationFormFields get expenditureExample {
    AccountModel cashDrawer = ACCOUNTS_TREE.firstWhere((acc) => acc.id == PAID_EXPENDITURE_BY);
    return ClassificationFormFields(
      id: null,
      amount: 3.750,
      paidBy: cashDrawer,
      note: 'nescafee and cup',
      date: DateTime.now(),
      expClass: EXP_CLASS_TREE.firstWhere((expClass) => expClass.id == ExpClassIds.GENERAL_EXP_CLASS_ID),
      floatAccount: FLOAT_ACCOUNT_TREE.firstWhere((float) => float.id == FloatAccountIds.GENERAL_FLOAT_ACCOUNT_ID),
    );
  }

  @override
  String toString() {
    return '''
      id: $id,
      parentClass: $parentClass,
      titleEnglish: $titleEnglish,
      titlePersian: $titlePersian,
      titleArabic: $titleArabic,
      note: $note, 
      expClass: {$expClass}, 
    ''';
  }
}
