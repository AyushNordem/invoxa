import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';

import '../../../../../../res/assets_res.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/style_resource.dart';
import '../../../../../routes/app_pages.dart';
import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 50 + MediaQuery.of(context).padding.top),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 15, right: 15, bottom: 10),
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))],
            gradient: LinearGradient(colors: [AppColors.primaryLight, AppColors.white], begin: Alignment.centerLeft, end: Alignment.centerRight),
          ),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.getGreeting(), style: StyleResource.instance.styleMedium(fontSize: 13, color: AppColors.greyText)),
                      Text(
                        controller.userName.value,
                        style: StyleResource.instance.styleBold(fontSize: 22, color: AppColors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text('PREMIUM USER', style: StyleResource.instance.styleBold(fontSize: 9, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      child: Obx(() {
        if (controller.isLoading.value && controller.allInvoices.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildBillingGrowthCard(),
              const SizedBox(height: 24),
              _buildRecentActivityHeader(),
              const SizedBox(height: 12),
              _buildRecentActivityList(),
              const SizedBox(height: 20),
              _buildBusinessDetailsCard(),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryRow() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildSummaryCard(title: 'TOTAL REVENUE (PAID)', value: '₹${controller.paidAmount.value.toStringAsFixed(2)}', trend: '+${controller.billingGrowth.value.toStringAsFixed(0)}%', hasTrendIcon: true),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(title: 'PENDING COLLECTIONS', value: '₹${controller.pendingAmount.value.toStringAsFixed(2)}', subtitle: '${controller.allInvoices.where((i) => (i.status ?? "").toUpperCase() == "PENDING").length} waiting invoices'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String value, String? trend, String? subtitle, bool hasTrendIcon = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: StyleResource.instance.styleSemiBold(fontSize: 9, color: AppColors.greyText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasTrendIcon) const Icon(Icons.trending_up, color: AppColors.primary, size: 14),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: StyleResource.instance.styleBold(fontSize: 16, color: AppColors.secondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (trend != null)
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const LinearProgressIndicator(value: 0.75, backgroundColor: AppColors.borderGrey, color: AppColors.primary, minHeight: 4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(trend, style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary)),
              ],
            ),
          if (subtitle != null)
            Text(
              subtitle,
              style: StyleResource.instance.styleRegular(fontSize: 10, color: AppColors.greyText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('QUICK ACTIONS', style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.greyText)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(icon: Icons.note_add_outlined, label: 'New Invoice', isPrimary: true, onTap: () => Get.toNamed(Routes.ADD_INVOICE)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(icon: Icons.person_add_outlined, label: 'Add Client', isPrimary: false, onTap: () => Get.toNamed(Routes.ADD_CUSTOMER)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required bool isPrimary, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.white,
          borderRadius: AppRadius.card,
          boxShadow: [BoxShadow(color: (isPrimary ? AppColors.primary : AppColors.black).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          border: isPrimary ? null : Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? AppColors.white : AppColors.secondary, size: 18),
            const SizedBox(width: 8),
            Text(label, style: StyleResource.instance.styleSemiBold(fontSize: 13, color: isPrimary ? AppColors.white : AppColors.secondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingGrowthCard() {
    return Obx(() {
      final spots = controller.chartSpots;
      final months = controller.chartMonths;
      final growth = controller.billingGrowth.value;

      final isPositive = growth >= 0;
      final growthColor = isPositive ? AppColors.primary : const Color(0xFFEF4444);
      final growthBg = isPositive ? AppColors.primarySoft : const Color(0xFFFEF2F2);
      final growthIcon = isPositive ? Icons.trending_up : Icons.trending_down;

      // Calculate maxY dynamically with a nice safety ceiling
      double maxY = 100.0;
      for (var spot in spots) {
        if (spot.y > maxY) maxY = spot.y;
      }
      maxY = maxY == 0 ? 100.0 : maxY * 1.2; // 20% margin for breathing room

      return Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.card,
          boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BILLING GROWTH', style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.greyText)),
                    const SizedBox(height: 2),
                    Text('Last 6 Months Trend', style: StyleResource.instance.styleRegular(fontSize: 11, color: AppColors.greyText.withOpacity(0.7))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: growthBg, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Icon(growthIcon, color: growthColor, size: 12),
                      const SizedBox(width: 4),
                      Text('${isPositive ? "+" : ""}${growth.toStringAsFixed(0)}%', style: StyleResource.instance.styleBold(fontSize: 11, color: growthColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(color: AppColors.greyText, fontSize: 9, fontWeight: FontWeight.w500);
                          final index = value.toInt();
                          if (index >= 0 && index < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(months[index], style: style),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots.isNotEmpty ? spots : const [FlSpot(0, 0), FlSpot(1, 0), FlSpot(2, 0), FlSpot(3, 0), FlSpot(4, 0), FlSpot(5, 0)],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRecentActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('RECENT ACTIVITY', style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.greyText)),
        Text('Real-time Updates', style: StyleResource.instance.styleSemiBold(fontSize: 11, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildRecentActivityList() {
    return Obx(() {
      if (controller.recentInvoices.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.card,
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.description_outlined, size: 40, color: AppColors.greyText.withOpacity(0.4)),
                const SizedBox(height: 8),
                Text('No Invoices Yet', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.secondary)),
                const SizedBox(height: 4),
                Text('Create an invoice to get started!', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
              ],
            ),
          ),
        );
      }

      return Column(
        children: controller.recentInvoices.map((invoice) {
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                  style: StyleResource.instance.styleBold(fontSize: 14, color: const Color(0xFF1E293B)),
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
                              Text('₹${invoice.grandTotal.toStringAsFixed(2)}', style: StyleResource.instance.styleBold(fontSize: 15, color: AppColors.primary)),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildBusinessDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        image: const DecorationImage(image: AssetImage(AssetsRes.SECTION___PROMOTIONAL_MAGIC_CARD), fit: BoxFit.fill),
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Business Details',
                style: StyleResource.instance.styleBold(fontSize: 20, color: AppColors.white),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business_rounded, color: AppColors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your invoices legal and professional. Update your company branding, GSTIN, address, or banking details easily at any time.',
            style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.toNamed(Routes.BUSINESS_SETUP),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
            ),
            child: Text('Update Now', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
