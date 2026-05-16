import 'package:flutter/material.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/style_resource.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Help & Support',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How can we help you?', style: StyleResource.instance.styleBold(fontSize: 24, color: AppColors.secondary)),
            const SizedBox(height: 8),
            Text('Search our help center or contact our team directly.', style: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText)),
            const SizedBox(height: 32),
            _buildSupportItem(Icons.email_outlined, 'Email Support', 'support@invoxa.com'),
            _buildSupportItem(Icons.language_outlined, 'Help Center', 'www.invoxa.com/help'),
            _buildSupportItem(Icons.chat_bubble_outline, 'Live Chat', 'Available Mon-Fri, 9am-6pm'),
            const SizedBox(height: 32),
            Text('Frequently Asked Questions', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
            const SizedBox(height: 16),
            _buildFaqItem('How do I create my first invoice?', 'Simply go to the Invoices tab and tap the + button. Fill in the client and product details and hit Save.'),
            _buildFaqItem('Can I export invoices as PDF?', 'Yes, after creating an invoice, go to the Preview screen and tap the Download PDF button.'),
            _buildFaqItem('How do I add a custom tax?', 'Go to Profile > Settings > Tax Settings to configure CGST, SGST, and IGST components.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
                Text(value, style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: StyleResource.instance.styleSemiBold(fontSize: 15, color: AppColors.secondary)),
          const SizedBox(height: 8),
          Text(answer, style: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText)),
        ],
      ),
    );
  }
}
