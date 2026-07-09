import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_typography.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/metric_card.dart';

class DashboardScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const DashboardScreen({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard',
      currentIndex: widget.currentIndex,
      onItemSelected: widget.onItemSelected,
      child: SingleChildScrollView(
        child: Consumer<DashboardProvider>(
          builder: (context, dashboardProvider, _) {
            if (dashboardProvider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Carregando dados...',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (dashboardProvider.error != null) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.errorRed.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.errorRed,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar dados',
                        style: AppTypography.headingSmall.copyWith(
                          color: AppColors.errorRed,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dashboardProvider.error!,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          dashboardProvider.loadDashboardData();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Grid de Métricas
                GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.0,
                  children: [
                    MetricCard(
                      title: 'Total de Empresas',
                      value: dashboardProvider.totalBusinesses.toString(),
                      icon: Icons.store_outlined,
                      iconColor: AppColors.accent,
                    ),
                    MetricCard(
                      title: 'Empresas Premium',
                      value: dashboardProvider.premiumBusinesses.toString(),
                      icon: Icons.grade,
                      iconColor: AppColors.premium,
                    ),
                    MetricCard(
                      title: 'Cliques WhatsApp',
                      value: dashboardProvider.totalWhatsappClicks.toString(),
                      icon: Icons.chat_outlined,
                      iconColor: AppColors.success,
                    ),
                    MetricCard(
                      title: 'Cliques Instagram',
                      value: dashboardProvider.totalInstagramClicks.toString(),
                      icon: Icons.image_outlined,
                      iconColor: AppColors.accent,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Cliques Recentes
                Text(
                  'Últimos Cliques Registrados',
                  style: AppTypography.headingSmall.copyWith(
                    color: AppColors.darkText,
                  ),
                ),

                const SizedBox(height: 16),

                if (dashboardProvider.recentClicks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Nenhum clique registrado ainda',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.lightText,
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        dataRowHeight: 56,
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.backgroundColor,
                        ),
                        columns: [
                          DataColumn(
                            label: Text(
                              'Empresa',
                              style: AppTypography.label.copyWith(
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Tipo de Clique',
                              style: AppTypography.label.copyWith(
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Data/Hora',
                              style: AppTypography.label.copyWith(
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                        ],
                        rows: dashboardProvider.recentClicks.take(10).map((
                          click,
                        ) {
                          final clickType = click['click_type'] ?? 'N/A';
                          final businessName =
                              click['business_name'] ?? 'Sem nome';
                          final clickedAt = click['created_at'] != null
                              ? _formatDateTime(click['created_at'])
                              : 'N/A';

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  businessName,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                              DataCell(
                                Chip(
                                  label: Text(clickType),
                                  backgroundColor: clickType == 'whatsapp'
                                      ? AppColors.success.withValues(alpha: 0.2)
                                      : AppColors.accent.withValues(alpha: 0.2),
                                  labelStyle: AppTypography.caption.copyWith(
                                    color: clickType == 'whatsapp'
                                        ? AppColors.success
                                        : AppColors.accent,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  clickedAt,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.lightText,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }
}
