import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/accounting/accounting_logic/voucher_model.dart';
import 'package:shop/accounting/accounting_logic/DBException.dart';
import 'package:shop/accounting/accounting_logic/voucher_number_exception.dart';

class VoucherNumberModel {
  final int id = 1;
  final int voucherNumber;
  final VoucherNumberStatus status;

  VoucherNumberModel(
    this.voucherNumber,
    this.status,
  );

  static const String tableName = 'voucher_number';
  static const String column1Id = 'id';
  static const String column2Number = 'number';
  static const String column3Status = 'status';
  static const String LOCK = 'LOCK';
  static const String FREE = 'FREE';

  static const String QUERY_CREATE_VOUCHER_NUMBER_TABLE =
      '''CREATE TABLE $tableName (
    $column1Id INTEGER NOT NULL, 
    $column2Number INTEGER NOT NULL, 
    $column3Status TEXT NOT NULL
  )''';

  // throw error if currently is locked
  static Future<int> borrowNumber() async {
    print('VN-M 00| borrowing Number...');
    final query = '''
    SELECT *
    FROM $tableName
    WHERE $column1Id = 1
    ''';
    // fetch voucher model
    var result = await AccountingDB.runRawQuery(query);
    var voucherNumberModel = fromDBResult(result);
    // print('VN-M 01| before _lockVoucherNumber() > $voucherNumberModel');

    // check status
    if (voucherNumberModel!.status == VoucherNumberStatus.FREE) {
      // 1) change status to LOCK
      await _lockVoucherNumber();

      // 2) return number
      return voucherNumberModel.voucherNumber;
    } else {
      throw VoucherNumberException(
          'VN-M 02| voucher-number status expected to be FREE but it is LOCK');
    }
  }

  static Future<void> numberConsumed(int number) async {
    print('VNM 28| numberConsumed ...');
    final query = '''
    SELECT *
    FROM $tableName
    WHERE $column1Id = 1
    ''';
    // fetch voucher model
    var result = await AccountingDB.runRawQuery(query);
    // print(
    //   'VNM 29| voucher_number before _freeVoucherNumberAndIncrease() > $result',
    // );
    var voucherNumberModel = fromDBResult(result);

    // check status
    if (voucherNumberModel!.voucherNumber == number &&
        voucherNumberModel.status == VoucherNumberStatus.LOCK) {
      // increase number and make it free
      await _freeVoucherNumberAndIncrease(number);
    } else {
      print(
        'VNM30| ERROR: voucher_number_db is not as expected! check created voucher numbers',
      );
      VoucherNumberException(
        'VNM30| ERROR: voucher_number_db is not as expected! check created voucher numbers',
      );
    }
  }

  static Future<void> numberNotConsumed(int number) async {
    print('VNM 34| numberNotConsumed ...');
    final query = '''
    SELECT *
    FROM $tableName
    WHERE $column1Id = 1
    ''';
    // fetch voucher model
    var result = await AccountingDB.runRawQuery(query);
    var voucherNumberModel = fromDBResult(result);

    // check status
    if (voucherNumberModel!.voucherNumber == number &&
        voucherNumberModel.status == VoucherNumberStatus.LOCK) {
      // increase number and make it free
      await _freeVoucherNumberWithoutIncrease();
    } else {
      print(
        'VNM 35| ERROR: voucher_number_db is not as expected! check created voucher numbers',
      );
      VoucherNumberException(
        'VNM 35| ERROR: voucher_number_db is not as expected! check created voucher numbers',
      );
    }
  }

  static Future<void> reset() async {
    print('VNM 40| reset ...');
    var max = await VoucherModel.maxVoucherNumber();
    await VoucherNumberModel._freeVoucherNumberAndIncrease(max);
  }

  static Future<void> _lockVoucherNumber() async {
    var query = '''
    UPDATE $tableName
    SET $column3Status = '$LOCK'
    WHERE
    $column1Id = 1
    ''';
    await AccountingDB.runRawQuery(query);
  }

  static Future<void> _freeVoucherNumberAndIncrease(int oldNumber) async {
    var query = '''
    UPDATE $tableName
    SET 
      $column2Number = ${oldNumber + 1},
      $column3Status = '$FREE'
    WHERE
    $column1Id = 1 
    ''';
    await AccountingDB.runRawQuery(query);
  }

  static const InitialVoucherNumber = {
    column1Id: 1,
    column2Number: 1,
    column3Status: FREE,
  };

  // when some one lock the number and lost the current number
  static Future<void> _freeVoucherNumberWithoutIncrease() async {
    var query = '''
    UPDATE $tableName
    SET 
      $column3Status = '$FREE'
    WHERE
    $column1Id = 1 
    ''';
    await AccountingDB.runRawQuery(query);
  }

  static Map<String, Object> mapForDb(int number, VoucherNumberStatus status) {
    return {
      column1Id: 1,
      column2Number: number,
      column3Status: (status == VoucherNumberStatus.FREE) ? FREE : LOCK,
    };
  }

  static VoucherNumberModel? fromDBResult(List<Map<String, Object?>> dbResult) {
    for (var map in dbResult) {
      if (map[column1Id] == 1) {
        return VoucherNumberModel(
          map[column2Number] as int,
          (map[column3Status] as String) == LOCK
              ? VoucherNumberStatus.LOCK
              : VoucherNumberStatus.FREE,
        );
      }
    }
  }

  @override
  String toString() {
    return '{ $column1Id: $id, $column2Number: $voucherNumber, $column3Status: $status }';
  }
}

enum VoucherNumberStatus {
  FREE,
  LOCK,
}
