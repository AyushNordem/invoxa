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
import '../presentation/pages/dashboard/views/profile_view/update_password/update_password_binding.dart';
import '../presentation/pages/dashboard/views/profile_view/update_password/update_password_view.dart';
import '../presentation/pages/dashboard/views/profile_view/settings/settings_binding.dart';
import '../presentation/pages/dashboard/views/profile_view/settings/settings_view.dart';
import '../presentation/pages/dashboard/views/profile_view/edit_profile/edit_profile_binding.dart';
import '../presentation/pages/dashboard/views/profile_view/edit_profile/edit_profile_view.dart';
import '../presentation/pages/dashboard/views/profile_view/static_pages/privacy_policy_view.dart';
import '../presentation/pages/dashboard/views/profile_view/static_pages/terms_conditions_view.dart';
import '../presentation/pages/dashboard/views/profile_view/static_pages/help_support_view.dart';
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
    GetPage(name: _Paths.UPDATE_PASSWORD, page: () => const UpdatePasswordView(), binding: UpdatePasswordBinding()),
    GetPage(name: _Paths.SETTINGS, page: () => const SettingsView(), binding: SettingsBinding()),
    GetPage(name: _Paths.EDIT_PROFILE, page: () => const EditProfileView(), binding: EditProfileBinding()),
    GetPage(name: _Paths.PRIVACY_POLICY, page: () => const PrivacyPolicyView()),
    GetPage(name: _Paths.TERMS_CONDITIONS, page: () => const TermsConditionsView()),
    GetPage(name: _Paths.HELP_SUPPORT, page: () => const HelpSupportView()),
  ];
}
