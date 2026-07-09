import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_typography.dart';
import '../../services/onesignal_service.dart';
import '../../widgets/app_scaffold.dart';

class NotificationsScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const NotificationsScreen({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedSegment = 'all';
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  final OneSignalService _oneSignalService = OneSignalService();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Hub de Notificações Push',
      currentIndex: widget.currentIndex,
      onItemSelected: widget.onItemSelected,
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formulário
            Expanded(
              flex: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Enviar Notificação',
                          style: AppTypography.headingSmall.copyWith(
                            color: AppColors.darkText,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Mensagens de sucesso/erro
                        if (_successMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _successMessage!,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_outlined),
                                  onPressed: () {
                                    setState(() => _successMessage = null);
                                  },
                                ),
                              ],
                            ),
                          ),

                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withValues(alpha: 0.1),
                              border: Border.all(
                                color: AppColors.errorRed.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.errorRed,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.errorRed,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_outlined),
                                  onPressed: () {
                                    setState(() => _errorMessage = null);
                                  },
                                ),
                              ],
                            ),
                          ),

                        // Título
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título da Notificação *',
                            hintText: 'Ex: Nova Promoção!',
                            prefixIcon: Icon(Icons.title_outlined),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Título é obrigatório';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Mensagem
                        TextFormField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            labelText: 'Mensagem/Corpo *',
                            hintText: 'Digite a mensagem da notificação...',
                            prefixIcon: Icon(Icons.message_outlined),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 4,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Mensagem é obrigatória';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Segmentação
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSegment,
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('Todos os Usuários'),
                            ),
                            DropdownMenuItem(
                              value: 'premium',
                              child: Text('Apenas Clientes Premium'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedSegment = value ?? 'all');
                          },
                          decoration: const InputDecoration(
                            labelText: 'Segmento *',
                            prefixIcon: Icon(Icons.people_outline),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Botão Enviar
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => _handleSendNotification(),
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.send_outlined),
                            label: Text(
                              _isLoading ? 'Enviando...' : 'Enviar Notificação',
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Informações
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '💡 Dicas',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Títulos concisos (até 65 caracteres) têm melhor taxa de abertura\n'
                                '• Mensagens claras e objetivas funcionam melhor\n'
                                '• Use segmentação para aumentar relevância\n'
                                '• Evite enviar notificações em horários de madrugada',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.darkText,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 32),

            // Informações de configuração
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuração OneSignal',
                            style: AppTypography.headingSmall.copyWith(
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildConfigInfo(
                            icon: Icons.vpn_key_outlined,
                            label: 'Rest API Key',
                            value: 'Configurado via variáveis de ambiente',
                          ),
                          const SizedBox(height: 12),
                          _buildConfigInfo(
                            icon: Icons.apps_outlined,
                            label: 'App ID',
                            value: 'Configurado via variáveis de ambiente',
                          ),
                          const SizedBox(height: 12),
                          _buildConfigInfo(
                            icon: Icons.done_outlined,
                            label: 'Status',
                            value: 'Pronto para envio',
                            isActive: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Variáveis de Ambiente',
                            style: AppTypography.headingSmall.copyWith(
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              border: Border.all(color: AppColors.borderColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ONESIGNAL_APP_ID=your_app_id',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontFamily: 'monospace',
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ONESIGNAL_REST_API_KEY=your_rest_api_key',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontFamily: 'monospace',
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigInfo({
    required IconData icon,
    required String label,
    required String value,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isActive ? AppColors.success : AppColors.accent).withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isActive ? AppColors.success : AppColors.accent,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.label.copyWith(color: AppColors.lightText),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _successMessage = null;
      _errorMessage = null;
    });

    try {
      // Validar que OneSignal foi inicializado
      // Nota: Na main.dart, você precisa chamar:
      // OneSignalService().initialize(
      //   appId: Platform.environment['ONESIGNAL_APP_ID'] ?? '',
      //   restApiKey: Platform.environment['ONESIGNAL_REST_API_KEY'] ?? '',
      // );

      final result = await _oneSignalService.sendNotification(
        title: _titleController.text,
        message: _messageController.text,
        segment: _selectedSegment,
      );

      if (result['success'] == true) {
        setState(() {
          _successMessage = result['message'];
          _isLoading = false;
        });

        // Limpar formulário após 2 segundos
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          _titleController.clear();
          _messageController.clear();
          setState(() => _selectedSegment = 'all');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
}
