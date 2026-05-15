import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/style_resource.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const GradientButton({super.key, required this.text, required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: AppRadius.button,
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(.4)], begin: Alignment.centerLeft, end: Alignment.centerRight),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: MaterialButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 3)) : Text(text, style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
      ),
    );
  }
}
