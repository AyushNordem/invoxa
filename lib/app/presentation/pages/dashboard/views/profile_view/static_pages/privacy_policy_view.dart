import 'package:flutter/material.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/style_resource.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Privacy Policy',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('1. Introduction', 'Welcome to Invoxa. We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about our policy, or our practices with regards to your personal information, please contact us.'),
            _buildSection('2. Information We Collect', 'We collect personal information that you provide to us such as name, address, contact information, passwords and security data, and payment information.'),
            _buildSection(
              '3. How We Use Your Information',
              'We use personal information collected via our app for a variety of business purposes described below. We process your personal information for these purposes in reliance on our legitimate business interests, in order to enter into or perform a contract with you, with your consent, and/or for compliance with our legal obligations.',
            ),
            _buildSection('4. Sharing Your Information', 'We only share information with your consent, to comply with laws, to provide you with services, to protect your rights, or to fulfill business obligations.'),
            _buildSection(
              '5. Data Security',
              'We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you transmit to us, please be aware that despite our efforts, no security measures are perfect or impenetrable.',
            ),
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
