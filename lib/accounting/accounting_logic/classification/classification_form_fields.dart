import 'package:flutter/material.dart';
import 'package:shop/accounting/accounting_logic/classification/transaction_classification.dart';
import 'package:shop/accounting/expenditure/expenditure_class_tree.dart';
import 'package:shop/auth/auth_provider_sql.dart';
import 'package:shop/shared/result_status.dart';

import 'classification_tree.dart';

class ClassificationFormFields {
  final formKey = GlobalKey<FormState>();

  String? id;
  int? authId;
  Function? resetState;

  ClassificationFormFields({
    int? authId,
    AuthProviderSQL? authProvider,
    TransactionClassification? parentClass,
    String? id,
    String? titleEnglish,
    String? titlePersian,
    String? titleArabic,
    String? note,
    // TransactionClassification? tranClass,
    Function? resetState,
  }) {
    this.authId = authId;
    this.parentClass = parentClass;
    // this.tranClass = tranClass;
    this.id = id;
    this.titleEnglish = titleEnglish;
    this.titlePersian = titlePersian;
    this.titleArabic = titleArabic;
    this.note = note;
  }

  // # tranClass
  // TransactionClassification? tranClassification;
  // bool hasErrorTranClass = false;
  // final tranClassFocusNode = FocusNode();
  // TextEditingController tranClassController = TextEditingController();
  // TransactionClassification? get tranClass {
  //   return tranClassification;
  // }
  // set tranClass(TransactionClassification? tranClassification) {
  //   this.tranClassification = tranClassification;
  //   this.tranClassController.text = (tranClassification == null) ? '' : tranClassification.titleEnglish;
  //   id = tranClassification?.id;
  //   titleEnglish = tranClassification?.titleEnglish;
  //   titlePersian = tranClassification?.titlePersian;
  //   titleArabic = tranClassification?.titleArabic;
  //   note = tranClassification?.note;
  // }
  // String? validateTranClass(String? tranClassText) {
  //   // print('EXP_FRM_FLD | validateTranClass() 01 | input: $tranClassText');
  //   if (tranClassText == null || tranClassText.isEmpty) {
  //     return 'tranClass should not be empty';
  //   }
  //   if (tranClassification == null) {
  //     return 'tranClassification should not be null inside expenditureFields';
  //   }
  //   if (tranClassification!.titleEnglish != tranClassText &&
  //       tranClassification!.titlePersian != tranClassText &&
  //       tranClassification!.titleArabic != tranClassText) {
  //     return 'tranClassification.titleE|P|A is mismatch with input text';
  //   }
  //   return null;
  // }

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
    // if (tranClass == null) {
    //   hasErrorTranClass = true;
    //   errorMessages += '\nTranClass is empty';
    // }
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
    var tranClass = EXP_CLASS_TREE.firstWhere((tranClass) => tranClass.id == ExpClassIds.GENERAL_EXP_CLASS_ID);
    return ClassificationFormFields(
      parentClass: TRANS_CLASS_TREE.firstWhere((parent) => parent.id == ExpClassIds.MAIN_EXP_CLASS_ID),
      id: tranClass.id,
      titleEnglish: tranClass.titleEnglish,
      titlePersian: tranClass.titlePersian,
      titleArabic: tranClass.titleArabic,
      note: tranClass.note,
    );
  }

  @override
  String toString() {
    return '''
      id: $id,
      parentClass: {$parentClass},
      titleEnglish: $titleEnglish,
      titlePersian: $titlePersian,
      titleArabic: $titleArabic,
      note: $note, 
    ''';
  }
}
