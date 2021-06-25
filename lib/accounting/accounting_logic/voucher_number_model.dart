import 'package:shop/accounting/accounting_logic/accounting_db.dart';
import 'package:shop/shared/DBException.dart';

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

  static Future<int> getVoucherNumberAndLock() async {
    final query = '''
    SELECT *
    FROM $tableName
    WHERE $column1Id = 1
    ''';
    // fetch voucher model
    var result = await AccountingDB.runRawQuery(query);
    var voucherNumberModel = fromDBResult(result);
    print('VNM01| @ DB: $voucherNumberModel');

    // check status
    if (voucherNumberModel!.status == VoucherNumberStatus.FREE) {
      // 1) change status to LOCK
      await _lockVoucherNumber();

      // 2) return number
      return voucherNumberModel.voucherNumber;
    }
    // number is lock
    return -1;
  }

  static Future<void> unlockVoucherNumber(int number) async {
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
      await _increaseAndFreeVoucherNumber(number);
    } else {
      print(
        'VNM30| ERROR: voucher_number_db is not as expected! check created voucher numbers',
      );
      DBException(
          'VNM30| ERROR: voucher_number_db is not as expected! check created voucher numbers');
    }
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

  static Future<void> _increaseAndFreeVoucherNumber(int oldNumber) async {
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
