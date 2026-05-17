import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/style_resource.dart';
import '../../../../../core/utils/app_snackbar.dart';
import '../../../../../data/models/invoice_model.dart';
import '../../../../../routes/app_pages.dart';
import 'invoice_controller.dart';

class InvoiceScreen extends GetView<InvoiceController> {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: "Invoice",
      showBackButton: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.ADD_INVOICE),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: AppColors.white, size: 28),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            _buildSummaryCard(),
            const SizedBox(height: AppSpacing.md),
            _buildSearchBar(),
            const SizedBox(height: AppSpacing.md),
            _buildInvoicesHeader(),
            const SizedBox(height: AppSpacing.md),
            _buildInvoicesList(),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search by number, name, or phone...',
                hintStyle: StyleResource.instance.styleRegular(fontSize: 14, color: AppColors.greyText),
                border: InputBorder.none,
              ),
              style: StyleResource.instance.styleMedium(fontSize: 15, color: AppColors.black),
            ),
          ),
          Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.greyText, size: 18),
                    onPressed: () => controller.searchController.clear(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF3F51B5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: AppRadius.card,
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL REVENUE (PAID)', style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.white.withOpacity(0.8))),
                Icon(Icons.payments_outlined, color: AppColors.white.withOpacity(0.8), size: 24),
              ],
            ),
            const SizedBox(height: 6),
            Text('₹ ${controller.paidAmount.value.toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 28, color: AppColors.white)),
            const SizedBox(height: 16),
            Container(height: 1, color: AppColors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RECEIVABLE (PENDING)', style: StyleResource.instance.styleRegular(fontSize: 11, color: AppColors.white.withOpacity(0.7))),
                      const SizedBox(height: 4),
                      Text('₹ ${controller.pendingAmount.value.toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
                    ],
                  ),
                ),
                Container(width: 1, height: 35, color: AppColors.white.withOpacity(0.2)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL GENERATED', style: StyleResource.instance.styleRegular(fontSize: 11, color: AppColors.white.withOpacity(0.7))),
                      const SizedBox(height: 4),
                      Text('₹ ${controller.totalReceivable.value.toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Invoices', style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
        Obx(() => Text('${controller.filteredInvoices.length} of ${controller.invoiceCount.value} Total', style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.greyText))),
      ],
    );
  }

  Widget _buildInvoicesList() {
    return Obx(() {
      if (controller.isLoading.value && controller.allInvoices.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      if (controller.filteredInvoices.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined, size: 64, color: AppColors.greyText.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text('No Invoices Found', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary)),
                const SizedBox(height: 8),
                Text(
                  controller.searchQuery.value.isNotEmpty ? 'Try searching with another keyword' : 'Create your first invoice by tapping the + button',
                  textAlign: TextAlign.center,
                  style: StyleResource.instance.styleRegular(fontSize: 13, color: AppColors.greyText),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredInvoices.length,
        itemBuilder: (context, index) {
          final invoice = controller.filteredInvoices[index];
          return _buildInvoiceCard(invoice);
        },
      );
    });
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    final status = invoice.status ?? 'Pending';
    final statusUpper = status.toUpperCase();
    Color statusColor;
    Color bgColor;
    IconData statusIcon;

    if (statusUpper == 'PAID') {
      statusColor = const Color(0xFF10B981);
      bgColor = const Color(0xFFE6F4EA);
      statusIcon = Icons.check_circle_rounded;
    } else if (statusUpper == 'PENDING') {
      statusColor = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFFFF7ED);
      statusIcon = Icons.schedule_rounded;
    } else {
      statusColor = const Color(0xFFEF4444);
      bgColor = const Color(0xFFFEF2F2);
      statusIcon = Icons.error_outline_rounded;
    }

    final dateStr = invoice.date != null ? DateFormat('dd MMM yyyy').format(invoice.date!) : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [BoxShadow(color: const Color(0xff0f172a).withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: statusColor, width: 4)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.toNamed(Routes.INVOICE_PREVIEW, arguments: invoice),
              child: Padding(
                padding: const EdgeInsets.only(left: 14, top: 12, bottom: 12),
                child: Row(
                  children: [
                    // Left Section: Customer Info & Metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.buyerDetails?.name ?? 'Unknown Customer',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: StyleResource.instance.styleBold(fontSize: 15, color: const Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(invoice.invoiceNumber ?? 'INV-XXXX', style: StyleResource.instance.styleSemiBold(fontSize: 11, color: const Color(0xFF64748B))),
                              const SizedBox(width: 6),
                              const Icon(Icons.fiber_manual_record, size: 4, color: Color(0xFFCBD5E1)),
                              const SizedBox(width: 6),
                              Text(dateStr, style: StyleResource.instance.styleMedium(fontSize: 11, color: const Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Right Section: Amount & Status Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹ ${invoice.grandTotal.toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 10, color: statusColor),
                              const SizedBox(width: 3),
                              Text(status, style: StyleResource.instance.styleBold(fontSize: 9, color: statusColor)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 8),

                    // Far-Right Section: Quick Actions Popup Menu
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onSelected: (value) async {
                        if (value == 'preview') {
                          Get.toNamed(Routes.INVOICE_PREVIEW, arguments: invoice);
                        } else if (value == 'open_link' && invoice.pdfUrl != null) {
                          final Uri url = Uri.parse(invoice.pdfUrl!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            AppSnackbar.showError(title: 'Error', message: 'Could not open PDF link');
                          }
                        } else if (value == 'mark_paid') {
                          try {
                            if (invoice.id != null) {
                              await FirebaseFirestore.instance.collection('invoices').doc(invoice.id).update({'status': 'Paid'});
                              AppSnackbar.showSuccess(title: 'Updated', message: 'Invoice marked as Paid');
                            }
                          } catch (e) {
                            AppSnackbar.showError(title: 'Error', message: e.toString());
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'preview',
                          child: Row(children: [Icon(Icons.visibility_outlined, size: 18), SizedBox(width: 8), Text('View Invoice')]),
                        ),
                        if (statusUpper != 'PAID')
                          const PopupMenuItem(
                            value: 'mark_paid',
                            child: Row(children: [Icon(Icons.check_circle_outline, size: 18), SizedBox(width: 8), Text('Mark as Paid')]),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
