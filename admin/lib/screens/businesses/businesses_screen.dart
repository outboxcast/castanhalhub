import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_typography.dart';
import '../../providers/business_provider.dart';
import '../../widgets/app_scaffold.dart';
import 'business_form.dart';

class BusinessesScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const BusinessesScreen({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  State<BusinessesScreen> createState() => _BusinessesScreenState();
}

class _BusinessesScreenState extends State<BusinessesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BusinessProvider>().loadBusinesses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Gerenciamento de Lojas',
      currentIndex: widget.currentIndex,
      onItemSelected: widget.onItemSelected,
      actions: [
        ElevatedButton.icon(
          onPressed: () => _showBusinessForm(context),
          icon: const Icon(Icons.add_outlined),
          label: const Text('Nova Loja'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de pesquisa
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar lojas...',
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_outlined),
                        onPressed: () {
                          _searchController.clear();
                          context.read<BusinessProvider>().clearSearch();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
                if (value.isEmpty) {
                  context.read<BusinessProvider>().clearSearch();
                } else {
                  context.read<BusinessProvider>().searchBusinesses(value);
                }
              },
            ),
          ),

          // Tabela
          Expanded(
            child: Consumer<BusinessProvider>(
              builder: (context, businessProvider, _) {
                if (businessProvider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Carregando lojas...',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (businessProvider.error != null) {
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
                            'Erro ao carregar lojas',
                            style: AppTypography.headingSmall.copyWith(
                              color: AppColors.errorRed,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            businessProvider.error!,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              businessProvider.loadBusinesses();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (businessProvider.businesses.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhuma loja encontrada',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.lightText,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: Card(
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
                                  'Nome',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Categoria',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Telefone',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Premium',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Ações',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                            ],
                            rows: businessProvider.businesses
                                .map(
                                  (business) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          business['name'] ?? 'Sem nome',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.darkText,
                                              ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          business['category_name'] ?? 'N/A',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.lightText,
                                              ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          business['whatsapp_number'] ??
                                              'Não informado',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.lightText,
                                              ),
                                        ),
                                      ),
                                      DataCell(
                                        Transform.scale(
                                          scale: 0.8,
                                          child: Switch(
                                            value:
                                                business['is_premium'] ?? false,
                                            onChanged: (value) {
                                              businessProvider
                                                  .togglePremiumStatus(
                                                    id: business['id'],
                                                    currentStatus:
                                                        business['is_premium'] ??
                                                        false,
                                                  );
                                            },
                                            activeThumbColor: AppColors.premium,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 18,
                                              ),
                                              color: AppColors.accent,
                                              onPressed: () {
                                                _showBusinessForm(
                                                  context,
                                                  initialData: business,
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                              ),
                                              color: AppColors.errorRed,
                                              onPressed: () {
                                                _showDeleteConfirmation(
                                                  context,
                                                  business['id'],
                                                  business['name'],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Paginação
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: businessProvider.currentPage > 1
                              ? () {
                                  businessProvider.loadBusinesses(
                                    page: businessProvider.currentPage - 1,
                                  );
                                }
                              : null,
                        ),
                        Text(
                          'Página ${businessProvider.currentPage} de ${businessProvider.totalPages}',
                          style: AppTypography.bodyMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed:
                              businessProvider.currentPage <
                                  businessProvider.totalPages
                              ? () {
                                  businessProvider.loadBusinesses(
                                    page: businessProvider.currentPage + 1,
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showBusinessForm(
    BuildContext context, {
    Map<String, dynamic>? initialData,
  }) {
    showDialog(
      context: context,
      builder: (context) => BusinessFormDialog(initialData: initialData),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Loja?'),
        content: Text(
          'Tem certeza que deseja deletar a loja "$name"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<BusinessProvider>()
                  .deleteBusiness(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Loja deletada com sucesso!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text(
              'Deletar',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
