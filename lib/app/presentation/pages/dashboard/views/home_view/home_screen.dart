import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../res/assets_res.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/style_resource.dart';
import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          _buildAppBar(),
          const SizedBox(height: AppSpacing.lg),
          _buildGreeting(),
          const SizedBox(height: AppSpacing.lg),
          _buildBillingGrowthCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildSummaryRow(),
          const SizedBox(height: AppSpacing.lg),
          _buildQuickActions(),
          const SizedBox(height: AppSpacing.lg),
          _buildRecentActivityHeader(),
          const SizedBox(height: AppSpacing.sm),
          _buildRecentActivityList(),
          const SizedBox(height: AppSpacing.lg),
          _buildPromoBanner(),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex')),
        Text('Invoxa', style: StyleResource.instance.styleBold(fontSize: 20, color: AppColors.primary)),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 0)],
          ),
          child: const Icon(Icons.notifications_none, color: AppColors.secondary, size: 24),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('${controller.getGreeting()}, ${controller.userName.value}', style: StyleResource.instance.styleBold(fontSize: 24, color: AppColors.secondary))],
      ),
    );
  }

  Widget _buildBillingGrowthCard() {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
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
                  Text('Last 6 Months', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText.withOpacity(0.7))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text('+12%', style: StyleResource.instance.styleBold(fontSize: 12, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: AppColors.greyText, fontSize: 10);
                        switch (value.toInt()) {
                          case 0:
                            return const Text('JUL', style: style);
                          case 2:
                            return const Text('AUG', style: style);
                          case 4:
                            return const Text('SEP', style: style);
                          case 6:
                            return const Text('OCT', style: style);
                          case 8:
                            return const Text('NOV', style: style);
                          case 10:
                            return const Text('DEC', style: style);
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
                    spots: const [FlSpot(0, 1), FlSpot(2, 1.5), FlSpot(4, 1.2), FlSpot(6, 2), FlSpot(8, 2.2), FlSpot(10, 3)],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(title: 'TOTAL REVENUE', value: '\$42,850', trend: '+12%', hasTrendIcon: true),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildSummaryCard(title: 'PENDING', value: '\$12,400', subtitle: '8 invoices awaiting'),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({required String title, required String value, String? trend, String? subtitle, bool hasTrendIcon = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: StyleResource.instance.styleSemiBold(fontSize: 10, color: AppColors.greyText)),
              if (hasTrendIcon) const Icon(Icons.trending_up, color: AppColors.primary, size: 14),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: StyleResource.instance.styleBold(fontSize: 18, color: AppColors.secondary)),
          const SizedBox(height: 8),
          if (trend != null)
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(value: 0.7, backgroundColor: AppColors.borderGrey, color: AppColors.primary, minHeight: 4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(trend, style: StyleResource.instance.styleBold(fontSize: 10, color: AppColors.primary)),
              ],
            ),
          if (subtitle != null) Text(subtitle, style: StyleResource.instance.styleRegular(fontSize: 10, color: AppColors.greyText)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('QUICK ACTIONS', style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.greyText)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(icon: Icons.note_add_outlined, label: 'New Invoice', isPrimary: true),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildActionButton(icon: Icons.person_add_outlined, label: 'Add Client', isPrimary: false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: (isPrimary ? AppColors.primary : AppColors.black).withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isPrimary ? AppColors.white : AppColors.secondary, size: 20),
          const SizedBox(width: 8),
          Text(label, style: StyleResource.instance.styleSemiBold(fontSize: 14, color: isPrimary ? AppColors.white : AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _buildRecentActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('RECENT INVOICE', style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.greyText)),
        Text('View All', style: StyleResource.instance.styleSemiBold(fontSize: 12, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildRecentActivityList() {
    return Obx(
      () => Column(
        children: controller.recentActivities.map((activity) => _buildActivityItem(name: activity['name'], id: activity['id'], amount: activity['amount'], status: activity['status'])).toList(),
      ),
    );
  }

  Widget _buildActivityItem({required String name, required String id, required double amount, required String status}) {
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
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: AppRadius.card),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.secondary)),
                Text(id, style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.greyText)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${amount.toStringAsFixed(2)}', style: StyleResource.instance.styleSemiBold(fontSize: 14, color: AppColors.secondary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
                child: Text(status, style: StyleResource.instance.styleBold(fontSize: 10, color: statusColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        image: const DecorationImage(image: AssetImage(AssetsRes.SECTION___PROMOTIONAL_MAGIC_CARD), fit: BoxFit.fill),
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Automate your\nfinances', style: StyleResource.instance.styleBold(fontSize: 20, color: AppColors.white)),
          const SizedBox(height: 8),
          Text('Connect your bank account to sync transactions instantly with Invoxa Magic Sync.', style: StyleResource.instance.styleRegular(fontSize: 12, color: AppColors.white.withOpacity(0.9))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Get Started', style: StyleResource.instance.styleBold(fontSize: 14, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
