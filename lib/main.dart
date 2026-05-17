import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/theme/app_theme.dart';
import 'app/core/utils/app_constants.dart';
import 'app/presentation/bindings/initial_binding.dart';
import 'app/presentation/widgets/error_show/error_show.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(const InvoxaApp());
}

class InvoxaApp extends StatelessWidget {
  const InvoxaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, widget) {
        /// Override global Flutter error UI in Release Mode
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return ErrorMessage(errorDetails: errorDetails);
        };

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(0.95)),
          child: widget ?? SizedBox.shrink(),
        );
      },
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
