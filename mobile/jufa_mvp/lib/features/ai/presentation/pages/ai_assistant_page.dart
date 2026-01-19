import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../navigation/presentation/widgets/bottom_navigation_widget.dart';
import '../../domain/models/chat_message_model.dart';
import '../../domain/services/ai_assistant_service.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final AIAssistantService _aiService = AIAssistantService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context);
      _aiService.setLocale(l10n.locale.languageCode);
    });
    _initializeChat();
    _aiService.messageStream.listen((message) {
      setState(() {
        if (message.isTyping) {
          _isTyping = true;
        } else {
          _isTyping = false;
          if (message.id != 'typing') {
            _messages.add(message);
          }
        }
      });
      _scrollToBottom();
    });
  }

  void _initializeChat() {
    // Message de bienvenue
    Future.delayed(const Duration(milliseconds: 500), () {
      final l10n = AppLocalizations.of(context);
      _aiService.sendMessage(l10n.translate('hello'));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // Mettre à jour la langue du service AI
    _aiService.setLocale(l10n.locale.languageCode);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '🤖',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jufa AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.translate('ai_assistant'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Input area
          _buildInputArea(l10n),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 4),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.sender == MessageSender.user;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text('🤖', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                if (message.quickReplies != null && message.quickReplies!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildQuickReplies(message.quickReplies!),
                ],
                
                const SizedBox(height: 4),
                Text(
                  Formatters.formatTime(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickReplies(List<QuickReply> quickReplies) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: quickReplies.map((reply) {
        return GestureDetector(
          onTap: () => _handleQuickReply(reply),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              reply.text,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.blueGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('🤖', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(200),
                const SizedBox(width: 4),
                _buildTypingDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(value),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: l10n.translate('type_message'),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: _sendMessage,
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _sendMessage(_messageController.text),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.blueGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    _aiService.sendMessage(text.trim());
    _messageController.clear();
  }

  void _handleQuickReply(QuickReply reply) {
    _aiService.sendQuickReply(reply);
  }

  void _showOptionsMenu() {
    final l10n = AppLocalizations.of(context);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text(l10n.translate('advanced_analytics')),
              onTap: () {
                Navigator.pop(context);
                context.push('/analytics');
              },
            ),
            ListTile(
              leading: Icon(Icons.insights),
              title: Text(l10n.translate('financial_insights')),
              onTap: () {
                Navigator.pop(context);
                _showInsightsDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text(l10n.translate('security_analysis')),
              onTap: () {
                Navigator.pop(context);
                _showSecurityAnalysis();
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text(l10n.translate('conversation_history')),
              onTap: () {
                Navigator.pop(context);
                _showConversationHistory();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInsightsDialog() async {
    final insights = await _aiService.getFinancialInsights();
    
    if (!mounted) return;
    
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('financial_insights')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInsightItem(l10n.translate('spending_trend'), insights['spending_trend'] == 'down' ? '📉 ${l10n.translate('down')}' : '📈 ${l10n.translate('up')}'),
              _buildInsightItem(l10n.translate('savings_rate'), '${(insights['savings_rate'] * 100).toStringAsFixed(1)}%'),
              _buildInsightItem(l10n.translate('top_category'), insights['top_category']),
              _buildInsightItem(l10n.translate('credit_score'), insights['credit_score'].toString()),
              _buildInsightItem(l10n.translate('fraud_risk'), insights['fraud_risk'] == 'low' ? '🟢 ${l10n.translate('low')}' : '🟡 ${l10n.translate('medium')}'),
              const SizedBox(height: 16),
              Text(
                '${l10n.translate('recommendation')}:',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(insights['recommendation']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: AppColors.primary)),
        ],
      ),
    );
  }

  void _showSecurityAnalysis() {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('security_analysis')),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🟢 ${l10n.translate('no_suspicious_activity')}'),
            SizedBox(height: 8),
            Text('🔒 ${l10n.translate('biometric_auth_active')}'),
            SizedBox(height: 8),
            Text('📱 ${l10n.translate('device_recognized')}'),
            SizedBox(height: 8),
            Text('🛡️ ${l10n.translate('transactions_encrypted')}'),
            SizedBox(height: 16),
            Text(l10n.translate('account_secure'), 
                 style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('perfect')),
          ),
        ],
      ),
    );
  }

  void _showConversationHistory() {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('history')),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return ListTile(
                leading: Icon(
                  message.sender == MessageSender.user ? Icons.person : Icons.smart_toy,
                  color: message.sender == MessageSender.user ? AppColors.primary : AppColors.info,
                ),
                title: Text(
                  message.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(Formatters.formatTime(message.timestamp)),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('close')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
