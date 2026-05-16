import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../presentation/pages/auth/login/login_binding.dart';
import '../presentation/pages/auth/login/login_view.dart';
import '../presentation/pages/auth/sign_up/sign_up_binding.dart';
import '../presentation/pages/auth/sign_up/sign_up_view.dart';
import '../presentation/pages/onboarding/business_setup/business_setup_binding.dart';
import '../presentation/pages/onboarding/business_setup/business_setup_view.dart';
import '../presentation/pages/dashboard/dashboard_binding.dart';
import '../presentation/pages/dashboard/dashboard_view.dart';
import '../presentation/pages/dashboard/views/invoice_view/add_invoice/add_invoice_binding.dart';
import '../presentation/pages/dashboard/views/invoice_view/add_invoice/add_invoice_view.dart';
import '../presentation/pages/dashboard/views/invoice_view/add_invoice/add_product/add_product_binding.dart';
import '../presentation/pages/dashboard/views/invoice_view/add_invoice/add_product/add_product_view.dart';
import '../presentation/pages/dashboard/views/customer_view/add_customer/add_customer_binding.dart';
import '../presentation/pages/dashboard/views/customer_view/add_customer/add_customer_view.dart';
import '../presentation/pages/dashboard/views/invoice_view/invoice_preview/invoice_preview_binding.dart';
import '../presentation/pages/dashboard/views/invoice_view/invoice_preview/invoice_preview_view.dart';
import '../presentation/pages/splash/splash_binding.dart';
import '../presentation/pages/splash/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(name: _Paths.SPLASH, page: () => const SplashView(), binding: SplashBinding()),
    GetPage(name: _Paths.HOME, page: () => const DashboardView(), binding: DashboardBinding()),
    GetPage(name: _Paths.LOGIN, page: () => const LoginView(), binding: LoginBinding(), transition: Transition.fadeIn),
    GetPage(name: _Paths.SIGN_UP, page: () => const SignUpView(), binding: SignUpBinding()),
    GetPage(name: _Paths.BUSINESS_SETUP, page: () => const BusinessSetupView(), binding: BusinessSetupBinding()),
    GetPage(name: _Paths.ADD_INVOICE, page: () => const AddInvoiceView(), binding: AddInvoiceBinding()),
    GetPage(name: _Paths.ADD_PRODUCT, page: () => const AddProductView(), binding: AddProductBinding()),
    GetPage(name: _Paths.ADD_CUSTOMER, page: () => const AddCustomerView(), binding: AddCustomerBinding()),
    GetPage(name: _Paths.INVOICE_PREVIEW, page: () => const InvoicePreviewView(), binding: InvoicePreviewBinding()),
  ];
}
