import 'package:flutter/material.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/style_resource.dart';

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Terms & Conditions',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('1. Agreement to Terms', 'By using Invoxa, you agree to be bound by these Terms and Conditions. If you do not agree with all of these terms, then you are expressly prohibited from using the app and you must discontinue use immediately.'),
            _buildSection('2. Intellectual Property Rights', 'Unless otherwise indicated, Invoxa is our proprietary property and all source code, databases, functionality, software, website designs, audio, video, text, photographs, and graphics are owned or controlled by us.'),
            _buildSection('3. User Representations', 'By using the app, you represent and warrant that: all registration information you submit will be true, accurate, current, and complete; you will maintain the accuracy of such information.'),
            _buildSection('4. Prohibited Activities', 'You may not access or use the app for any purpose other than that for which we make the app available. The app may not be used in connection with any commercial endeavors except those that are specifically endorsed or approved by us.'),
            _buildSection('5. Limitation of Liability', 'In no event will we or our directors, employees, or agents be liable to you or any third party for any direct, indirect, consequential, exemplary, incidental, special, or punitive damages.'),
            const SizedBox(height: 20),
            Text('Last updated: October 2024', style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
          const SizedBox(height: 12),
          Text(content, style: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText, height: 1.5)),
        ],
      ),
    );
  }
}
