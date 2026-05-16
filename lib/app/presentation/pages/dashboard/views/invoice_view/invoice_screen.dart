import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/style_resource.dart';
import '../../../../../routes/app_pages.dart';
import 'invoice_controller.dart';

class InvoiceScreen extends GetView<InvoiceController> {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            _buildAppBar(),
            const SizedBox(height: AppSpacing.lg),
            _buildSearchBar(),
            const SizedBox(height: AppSpacing.lg),
            _buildSummaryCard(),
            const SizedBox(height: AppSpacing.xl),
            _buildInvoicesHeader(),
            const SizedBox(height: AppSpacing.md),
            _buildInvoicesList(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.ADD_INVOICE),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: AppColors.white, size: 28),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex')),
        Text('Invoxa', style: StyleResource.instance.styleBold(fontSize: 20, color: AppColors.primary)),
        const Icon(Icons.search, color: AppColors.secondary, size: 24),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.greyText, size: 20),
                const SizedBox(width: 12),
                Text('Search invoices...', style: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildIconButton(Icons.tune),
        const SizedBox(width: 12),
        _buildIconButton(Icons.sort),
      ],
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: AppColors.secondary, size: 20),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL RECEIVABLE', style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.white.withOpacity(0.8))),
              Icon(Icons.account_balance_wallet_outlined, color: AppColors.white.withOpacity(0.8), size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text('\$42,850.00', style: StyleResource.instance.styleBold(fontSize: 28, color: AppColors.white)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildSubSummary('PAID', '\$38.2k')),
              const SizedBox(width: 16),
              Expanded(child: _buildSubSummary('PENDING', '\$4.6k')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubSummary(String label, String amount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.white.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(amount, style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
        ],
      ),
    );
  }

  Widget _buildInvoicesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Invoices', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
        Text('24 Total', style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.greyText)),
      ],
    );
  }

  Widget _buildInvoicesList() {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.invoices.length,
        itemBuilder: (context, index) {
          final invoice = controller.invoices[index];
          return _buildInvoiceCard(invoice);
        },
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    final status = invoice['status'];
    Color statusColor;
    Color bgColor;
    if (status == 'PAID') {
      statusColor = const Color(0xFF10B981);
      bgColor = const Color(0xFFD1FAE5);
    } else if (status == 'PENDING') {
      statusColor = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFFEF3C7);
    } else {
      statusColor = const Color(0xFFEF4444);
      bgColor = const Color(0xFFFEE2E2);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
                child: Icon(status == 'OVERDUE' ? Icons.warning_amber_rounded : Icons.description_outlined, color: status == 'OVERDUE' ? const Color(0xFFEF4444) : AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invoice['id'], style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.greyText)),
                    Text(invoice['client'], style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary)),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: AppColors.greyText),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.greyText),
                      const SizedBox(width: 4),
                      Text(invoice['date'], style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('\$${invoice['amount'].toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 20, color: AppColors.secondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: StyleResource.instance.styleBold(fontSize: 10, color: statusColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
