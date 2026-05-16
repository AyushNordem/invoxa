import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_sizes.dart';
import '../../../../../../core/theme/style_resource.dart';
import 'invoice_preview_controller.dart';

class InvoicePreviewView extends GetView<InvoicePreviewController> {
  const InvoicePreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text('Invoice Preview', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(children: [_buildInvoiceCard(), const SizedBox(height: 16), _buildProTip(), const SizedBox(height: 32)]),
      ),
      bottomNavigationBar: _buildBottomActionSheet(),
    );
  }

  Widget _buildInvoiceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.description, color: AppColors.secondary, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFF7F0), borderRadius: BorderRadius.circular(20)),
                child: Text('DRAFT', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Invoxa Solutions', style: StyleResource.instance.styleBold(fontSize: 20, color: AppColors.secondary)),
          Text('123 Tech Park, Mumbai', style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
          const Divider(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BILL TO', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary.withOpacity(0.6))),
                    const SizedBox(height: 4),
                    Text('Acme Corp', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
                    Text('billing@acme.com', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
                    Text('456 Enterprise Way,\nSan Francisco, CA', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
                  ],
                ),
              ),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [_buildInvoiceInfoItem('INVOICE #', 'INV-2024-001'), const SizedBox(height: 12), _buildInvoiceInfoItem('DATE', 'Oct 24, 2024'), const SizedBox(height: 12), _buildInvoiceInfoItem('DUE DATE', 'Nov 10, 2024')]),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildItemsHeader(),
          const Divider(),
          _buildItemsList(),
          const SizedBox(height: 24),
          _buildTotalsSection(),
          const Divider(height: 40),
          _buildAmountInWords(),
          const SizedBox(height: 24),
          _buildBankDetails(),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 60,
                  width: 100,
                  decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Text('Signature', style: StyleResource.instance.styleRegular(fontSize: 10, color: AppColors.greyText)),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Authorized Signatory', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary.withOpacity(0.6))),
        Text(value, style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
      ],
    );
  }

  Widget _buildItemsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('ITEM DESCRIPTION', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary.withOpacity(0.6))),
          ),
          Expanded(
            child: Center(
              child: Text('QTY', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary.withOpacity(0.6))),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('PRICE', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary.withOpacity(0.6))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    final items = controller.invoiceData['items'] as List;
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'], style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.secondary)),
                    Text(item['desc'], style: StyleResource.instance.styleRegular(fontSize: 10, color: AppColors.greyText)),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(item['qty'].toString(), style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.secondary)),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('\$${(item['price'] as double).toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.secondary)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTotalsSection() {
    return Column(
      children: [
        _buildTotalRow('Subtotal', '\$3,250.00'),
        const SizedBox(height: 8),
        _buildTotalRow('GST (18%)', '\$585.00'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary)),
            Text('\$3,835.00', style: StyleResource.instance.styleBold(fontSize: 20, color: AppColors.primary)),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
        Text(value, style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.secondary)),
      ],
    );
  }

  Widget _buildAmountInWords() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AMOUNT IN WORDS', style: StyleResource.instance.styleBold(fontSize: 8, color: AppColors.primary.withOpacity(0.6))),
          const SizedBox(height: 4),
          Text('Three Thousand Eight Hundred Thirty Five Dollars Only.', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _buildBankDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BANK DETAILS', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary.withOpacity(0.6))),
        const SizedBox(height: 8),
        _buildBankRow('Bank:', 'HDFC'),
        _buildBankRow('Account:', '50200012345678'),
        _buildBankRow('IFSC:', 'HDFC0001234'),
      ],
    );
  }

  Widget _buildBankRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
          Text(value, style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _buildProTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: AppRadius.card),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pro Tip', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
                Text('Invoices with the "Magic Light" style are paid 15% faster due to enhanced professional readability.', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit Invoice'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.borderGrey),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Download PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.ios_share, color: AppColors.secondary, size: 20),
          ),
        ],
      ),
    );
  }
}
