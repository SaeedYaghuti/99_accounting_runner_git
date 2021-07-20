import 'package:shop/shared/storage_type.dart';

import 'accounting/accounting_logic/account_ids.dart';

const String dbUrl = 'https://flutter-shop-03-default-rtdb.firebaseio.com/';
const String webApiKey = 'AIzaSyAV9xklqkQKO8Z6F5_tKcva5k9FpBcmBU8';

// link: https://firebase.google.com/docs/reference/rest/auth
const String firebaseSignupNewUser =
    'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$webApiKey';
const String firebaseSignin =
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$webApiKey';

// Login page
const AUTOLOGINSAEID =
    true; // if true you never see login screen; it use default email/pass to login
const SAEIDEMAIL = 'test2@test.com';
const SAEIDPASSWORD = '123456';

// Switch between Shop and Accounting
const RUN_SHOP_APP = false;
const RUN_ACCOUNTING_APP = true;

// hashing password
const HASH_PASS = 'ze455MAFIkVygjMGUpLm7fEeeAaxN3Vyv-3r_iXJGgU';

// select storage TYPE
const STORAGE_TYPE = StorageType.SQL;

// account_model
const PAID_EXPENDITURE_BY = ACCOUNTS_ID.CASH_DRAWER_ACCOUNT_ID;
