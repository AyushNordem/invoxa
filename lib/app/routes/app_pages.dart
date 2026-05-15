import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../presentation/pages/auth/login/login_binding.dart';
import '../presentation/pages/auth/login/login_view.dart';
import '../presentation/pages/auth/sign_up/sign_up_binding.dart';
import '../presentation/pages/auth/sign_up/sign_up_view.dart';
import '../presentation/pages/onboarding/business_setup/business_setup_binding.dart';
import '../presentation/pages/onboarding/business_setup/business_setup_view.dart';
import '../presentation/pages/splash/splash_binding.dart';
import '../presentation/pages/splash/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(name: _Paths.SPLASH, page: () => const SplashView(), binding: SplashBinding()),
    GetPage(
      name: _Paths.HOME,
      page: () => const Scaffold(body: Center(child: Text('Home Screen'))),
    ),
    GetPage(name: _Paths.LOGIN, page: () => const LoginView(), binding: LoginBinding(), transition: Transition.fadeIn),
    GetPage(name: _Paths.SIGN_UP, page: () => const SignUpView(), binding: SignUpBinding()),
    GetPage(name: _Paths.BUSINESS_SETUP, page: () => const BusinessSetupView(), binding: BusinessSetupBinding()),
  ];
}
