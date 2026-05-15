import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/style_resource.dart';

/// A common base view that wraps the screen with the standard Invoxa light gradient background.
/// This reduces boilerplate across screens.
class BaseView extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar; // Custom AppBar if you need complete override
  final String? title; // Pass title to use the default common AppBar
  final bool showBackButton; // Whether to show the back button in the common AppBar
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool useSafeArea;
  final EdgeInsetsGeometry? padding;

  const BaseView({super.key, required this.child, this.appBar, this.title, this.showBackButton = true, this.floatingActionButton, this.bottomNavigationBar, this.useSafeArea = true, this.padding});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          appBar ??
          (title != null
              ? AppBar(
                  title: Text(title ?? "", style: StyleResource.instance.styleMedium(fontSize: 18, color: AppColors.black)),
                  centerTitle: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: showBackButton
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 20),
                          onPressed: () => Get.back(),
                        )
                      : null,
                )
              : null),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      // Setting this to true ensures the gradient is visible behind a transparent AppBar
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [AppColors.primarySoft, AppColors.white, AppColors.white], stops: [0.0, 0.4, 1.0]),
        ),
        child: useSafeArea
            ? SafeArea(
                child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
              )
            : Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );
  }
}
