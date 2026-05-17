import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_sizes.dart';
import '../../../../../../core/theme/style_resource.dart';
import '../../../../../../data/models/invoice_model.dart';
import '../add_invoice/invoice_pdf_view.dart';
import 'invoice_preview_controller.dart';

class InvoicePreviewView extends GetView<InvoicePreviewController> {
  const InvoicePreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final inv = controller.invoice.value;
      final invNo = inv?.invoiceNumber ?? 'Detail';
      return BaseView(
        title: 'Invoice $invNo',
        bottomNavigationBar: Obx(() {
          final invoice = controller.invoice.value;
          if (invoice == null) return const SizedBox.shrink();
          return _buildBottomActionSheet(invoice);
        }),
        child: Obx(() {
          final invoice = controller.invoice.value;
          if (invoice == null) {
            return const Center(child: Text('No invoice details found'));
          }

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
                child: Column(children: [_buildInvoiceCard(invoice), const SizedBox(height: 16), _buildProTip(invoice), const SizedBox(height: 32)]),
              ),
              if (controller.isLoading.value)
                Container(
                  color: AppColors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
            ],
          );
        }),
      );
    });
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    final seller = invoice.sellerDetails;
    final buyer = invoice.buyerDetails;
    final status = invoice.status ?? 'Pending';
    final statusUpper = status.toUpperCase();

    Color statusColor;
    Color bgColor;
    if (statusUpper == 'PAID') {
      statusColor = const Color(0xFF10B981);
      bgColor = const Color(0xFFE6F4EA);
    } else if (statusUpper == 'PENDING') {
      statusColor = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFFFF7ED);
    } else {
      statusColor = const Color(0xFFEF4444);
      bgColor = const Color(0xFFFEF2F2);
    }

    final dateStr = invoice.date != null ? DateFormat('dd MMM yyyy').format(invoice.date!) : '-';
    final dueDateStr = invoice.dueDate != null ? DateFormat('dd MMM yyyy').format(invoice.dueDate!) : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Icon & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt_long_outlined, color: AppColors.secondary, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                child: Text(statusUpper, style: StyleResource.instance.styleBold(fontSize: 10, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Business details
          Text(seller?.businessName ?? 'Invoxa Solutions', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
          if ((seller?.address?.street ?? '').isNotEmpty) Text(seller!.address!.street!, style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
          if (seller?.address?.city != null)
            Text('${seller?.address?.city ?? ""}${seller?.address?.state != null ? ", ${seller?.address?.state}" : ""}${seller?.address?.pincode != null ? " - ${seller?.address?.pincode}" : ""}', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
          if ((seller?.gstNumber ?? '').isNotEmpty) Text('GSTIN: ${seller!.gstNumber}', style: StyleResource.instance.styleMedium(fontSize: 11, color: AppColors.greyText)),
          if ((seller?.mobile ?? '').isNotEmpty) Text('Contact: ${seller!.mobile}', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),

          const Divider(height: 32, thickness: 1, color: Color(0xFFF1F5F9)),

          // Parties & Meta Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BILL TO', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary.withOpacity(0.6))),
                    const SizedBox(height: 6),
                    Text(buyer?.name ?? 'Unknown Customer', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
                    if ((buyer?.mobile ?? '').isNotEmpty) Text('Contact: ${buyer!.mobile}', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
                    if ((buyer?.email ?? '').isNotEmpty) Text(buyer!.email!, style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
                    if (buyer?.address != null) ...[
                      const SizedBox(height: 2),
                      if ((buyer?.address?.street ?? '').isNotEmpty) Text(buyer!.address!.street!, style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
                      Text('${buyer?.address?.city ?? ""}${buyer?.address?.state != null ? ", ${buyer?.address?.state}" : ""}${buyer?.address?.zipCode != null ? " - ${buyer?.address?.zipCode}" : ""}', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [_buildInvoiceInfoItem('INVOICE NUMBER', invoice.invoiceNumber ?? '-'), const SizedBox(height: 12), _buildInvoiceInfoItem('INVOICE DATE', dateStr), const SizedBox(height: 12), _buildInvoiceInfoItem('DUE DATE', dueDateStr)],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildItemsHeader(),
          const Divider(height: 16, thickness: 1, color: Color(0xFFF1F5F9)),
          _buildItemsList(invoice),
          const SizedBox(height: 20),
          _buildTotalsSection(invoice),

          if ((invoice.notes ?? '').isNotEmpty) ...[const Divider(height: 32, thickness: 1, color: Color(0xFFF1F5F9)), _buildNotesSection(invoice.notes!)],

          const Divider(height: 32, thickness: 1, color: Color(0xFFF1F5F9)),
          _buildAmountInWords(invoice.grandTotal),

          const SizedBox(height: 20),
          _buildBankDetails(invoice),

          // Signature Section
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (seller?.signatureUrl != null && seller!.signatureUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      seller.signatureUrl!,
                      height: 50,
                      width: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 50,
                        width: 120,
                        decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text('Signature', style: StyleResource.instance.styleRegular(fontSize: 10, color: AppColors.greyText)),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 50,
                    width: 120,
                    decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text('Signature', style: StyleResource.instance.styleRegular(fontSize: 10, color: AppColors.greyText)),
                    ),
                  ),
                const SizedBox(height: 6),
                Text('Authorized Signatory', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary)),
                if ((seller?.businessName ?? '').isNotEmpty) Text('for ${seller!.businessName}', style: StyleResource.instance.styleRegular(fontSize: 8, color: AppColors.greyText)),
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
        Text(label, style: StyleResource.instance.styleBold(fontSize: 9, color: AppColors.primary.withOpacity(0.6))),
        const SizedBox(height: 2),
        Text(value, style: StyleResource.instance.styleBold(fontSize: 13, color: AppColors.secondary)),
      ],
    );
  }

  Widget _buildItemsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text('ITEM DESCRIPTION', style: StyleResource.instance.styleBold(fontSize: 9, color: AppColors.primary.withOpacity(0.6))),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text('QTY', style: StyleResource.instance.styleBold(fontSize: 9, color: AppColors.primary.withOpacity(0.6))),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('RATE', style: StyleResource.instance.styleBold(fontSize: 9, color: AppColors.primary.withOpacity(0.6))),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('DISC%', style: StyleResource.instance.styleBold(fontSize: 9, color: AppColors.primary.withOpacity(0.6))),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('AMOUNT', style: StyleResource.instance.styleBold(fontSize: 9, color: AppColors.primary.withOpacity(0.6))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(InvoiceModel invoice) {
    final items = invoice.items ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: items.map((item) {
        final double itemSubtotal = item.rate * item.quantity;
        final double itemDiscount = itemSubtotal * (item.discount / 100);
        final double itemAmount = itemSubtotal - itemDiscount;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF8FAFC), width: 1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name ?? 'Unnamed Product', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.secondary)),
                    if ((item.description ?? '').isNotEmpty) ...[const SizedBox(height: 2), Text(item.description!, style: StyleResource.instance.styleRegular(fontSize: 10, color: AppColors.greyText))],
                    if ((item.hsnCode ?? '').isNotEmpty) ...[const SizedBox(height: 2), Text('HSN: ${item.hsnCode!}', style: StyleResource.instance.styleMedium(fontSize: 9, color: AppColors.greyText))],
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text('${item.quantity.toStringAsFixed(0)} ${item.unit ?? "PCS"}', style: StyleResource.instance.styleMedium(fontSize: 11, color: AppColors.secondary)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('₹${item.rate.toStringAsFixed(2)}', style: StyleResource.instance.styleMedium(fontSize: 11, color: AppColors.secondary)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(item.discount > 0 ? '${item.discount.toStringAsFixed(0)}%' : '0%', style: StyleResource.instance.styleMedium(fontSize: 11, color: AppColors.secondary)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('₹${itemAmount.toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 11, color: AppColors.secondary)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTotalsSection(InvoiceModel invoice) {
    // CGST, SGST, IGST totals
    final showCGST = invoice.hasCGST;
    final showSGST = invoice.hasSGST;
    final showIGST = invoice.hasIGST;
    final taxPerItem = invoice.taxPercentage / (showCGST && showSGST ? 2 : 1);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 220,
        child: Column(
          children: [
            _buildTotalRow('Subtotal', '₹${invoice.subTotal.toStringAsFixed(2)}'),
            if (invoice.discountTotal > 0) ...[const SizedBox(height: 6), _buildTotalRow('Discount', '-₹${invoice.discountTotal.toStringAsFixed(2)}', isDiscount: true)],
            if (showCGST) ...[const SizedBox(height: 6), _buildTotalRow('CGST (${taxPerItem.toStringAsFixed(1)}%)', '₹${(invoice.taxTotal / 2).toStringAsFixed(2)}')],
            if (showSGST) ...[const SizedBox(height: 6), _buildTotalRow('SGST (${taxPerItem.toStringAsFixed(1)}%)', '₹${(invoice.taxTotal / 2).toStringAsFixed(2)}')],
            if (showIGST) ...[const SizedBox(height: 6), _buildTotalRow('IGST (${invoice.taxPercentage.toStringAsFixed(1)}%)', '₹${invoice.taxTotal.toStringAsFixed(2)}')],
            const Divider(height: 20, thickness: 1, color: Color(0xFFF1F5F9)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Grand Total', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
                Text('₹${invoice.grandTotal.toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: StyleResource.instance.styleMedium(fontSize: 12, color: AppColors.greyText)),
        Text(value, style: StyleResource.instance.styleSemiBold(fontSize: 12, color: isDiscount ? const Color(0xFFEF4444) : AppColors.secondary)),
      ],
    );
  }

  Widget _buildNotesSection(String notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NOTES / TERMS', style: StyleResource.instance.styleBold(fontSize: 9, color: AppColors.primary.withOpacity(0.6))),
        const SizedBox(height: 4),
        Text(notes, style: StyleResource.instance.styleRegular(fontSize: 11, color: AppColors.secondary)),
      ],
    );
  }

  Widget _buildAmountInWords(double grandTotal) {
    String words = 'Zero';
    try {
      words = InvoicePdfGenerator.toWords(grandTotal);
    } catch (_) {}

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.borderGrey.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AMOUNT IN WORDS', style: StyleResource.instance.styleBold(fontSize: 8, color: AppColors.primary.withOpacity(0.6))),
          const SizedBox(height: 4),
          Text('INR $words Only', style: StyleResource.instance.styleBold(fontSize: 11, color: AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _buildBankDetails(InvoiceModel invoice) {
    final seller = invoice.sellerDetails;
    if (seller == null || seller.bankDetails == null) return const SizedBox.shrink();

    final bank = seller.bankDetails;
    final hasBankInfo = (bank?.bankName ?? '').isNotEmpty || (bank?.accountNumber ?? '').isNotEmpty || (bank?.ifsc ?? '').isNotEmpty;
    if (!hasBankInfo) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BANK DETAILS', style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary.withOpacity(0.6))),
        const SizedBox(height: 8),
        if ((bank?.bankName ?? '').isNotEmpty) _buildBankRow('Bank Name', bank!.bankName!),
        if ((bank?.accountNumber ?? '').isNotEmpty) _buildBankRow('Account Number', bank!.accountNumber!),
        if ((bank?.ifsc ?? '').isNotEmpty) _buildBankRow('IFSC Code', bank!.ifsc!),
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

  Widget _buildProTip(InvoiceModel invoice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: AppRadius.card),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pro Tip', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
                Text('Ensure to share the Cloudinary PDF URL or download the invoice copy to share it instantly via WhatsApp or Email.', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionSheet(InvoiceModel invoice) {
    final statusUpper = (invoice.status ?? '').toUpperCase();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, -6))],
      ),
      child: Row(
        children: [
          if (statusUpper != 'PAID') ...[
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: () => controller.markAsPaid(),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Mark Paid'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  side: const BorderSide(color: Color(0xFF10B981)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              onPressed: () => controller.downloadInvoice(),
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Download PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => controller.shareInvoice(),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.ios_share, color: AppColors.secondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
