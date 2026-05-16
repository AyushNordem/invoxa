part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const SIGN_UP = _Paths.SIGN_UP;
  static const BUSINESS_SETUP = _Paths.BUSINESS_SETUP;
  static const ADD_INVOICE = _Paths.ADD_INVOICE;
  static const ADD_PRODUCT = _Paths.ADD_PRODUCT;
  static const ADD_CUSTOMER = _Paths.ADD_CUSTOMER;
  static const INVOICE_PREVIEW = _Paths.INVOICE_PREVIEW;
  static const UPDATE_PASSWORD = _Paths.UPDATE_PASSWORD;
  static const SETTINGS = _Paths.SETTINGS;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const SIGN_UP = '/sign-up';
  static const BUSINESS_SETUP = '/business-setup';
  static const ADD_INVOICE = '/add-invoice';
  static const ADD_PRODUCT = '/add-product';
  static const ADD_CUSTOMER = '/add-customer';
  static const INVOICE_PREVIEW = '/invoice-preview';
  static const UPDATE_PASSWORD = '/update-password';
  static const SETTINGS = '/settings';
}
