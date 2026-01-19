import 'dart:async';
import 'dart:math';
import '../models/chat_message_model.dart';

class AIAssistantService {
  static final AIAssistantService _instance = AIAssistantService._internal();
  factory AIAssistantService() => _instance;
  AIAssistantService._internal();

  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messageStream => _messageController.stream;

  final List<ChatMessage> _conversationHistory = [];
  List<ChatMessage> get conversationHistory => List.unmodifiable(_conversationHistory);
  
  String _locale = 'fr'; // Langue par défaut
  
  void setLocale(String locale) {
    _locale = locale;
  }

  // Base de connaissances JUFA - Français
  final Map<String, List<String>> _responsesFr = {
    'greeting': [
      'Bonjour ! Je suis Jufa AI, votre assistant personnel JUFA. Comment puis-je vous aider aujourd\'hui ? 🌟',
      'Salut ! Bienvenue sur JUFA, votre portefeuille mobile tout-en-un. Que souhaitez-vous faire ?',
      'Hello ! Je suis là pour vous guider dans l\'utilisation de JUFA. Posez-moi vos questions ! 😊',
    ],
    'jufa_info': [
      'JUFA est votre portefeuille mobile complet au Mali ! 🇲🇱\n\n✅ Transferts d\'argent instantanés\n✅ Paiements marchands\n✅ Carte Jufa virtuelle et physique\n✅ Marketplace or et argent (Nege)\n✅ Recharge de crédit\n✅ Sécurité biométrique\n\nQue voulez-vous découvrir ?',
      'JUFA vous offre une expérience bancaire mobile complète :\n\n💳 Carte Jufa pour vos paiements\n💰 Transferts rapides entre utilisateurs\n🛒 Marketplace Nege (or/argent)\n📱 Recharge airtime\n🔒 Sécurité maximale avec biométrie\n\nComment puis-je vous aider ?',
    ],
    'carte_jufa': [
      'La Carte Jufa est votre carte de paiement mobile ! 💳\n\n📱 Carte Virtuelle : Disponible immédiatement\n💳 Carte Physique : Livraison sous 5-7 jours\n\nAvantages :\n✅ Paiements en ligne sécurisés\n✅ Retraits aux distributeurs\n✅ Paiements chez les marchands\n✅ Gestion depuis l\'app\n\nVoulez-vous commander votre carte ?',
      'Avec la Carte Jufa, payez partout ! 🌍\n\n🔹 Virtuelle : Utilisez-la immédiatement pour vos achats en ligne\n🔹 Physique : Recevez-la chez vous pour vos paiements quotidiens\n\nSécurité :\n🔒 Code PIN personnalisé\n🔒 Authentification biométrique\n🔒 Blocage instantané depuis l\'app\n\nBesoin d\'aide pour l\'activer ?',
    ],
    'transfert': [
      'Transférer de l\'argent avec JUFA est simple ! 💸\n\n1️⃣ Cliquez sur "Transfert"\n2️⃣ Entrez le numéro (+223 XX XX XX XX)\n3️⃣ Saisissez le montant\n4️⃣ Authentifiez-vous (biométrie ou PIN)\n5️⃣ Confirmez !\n\n✅ Transfert instantané\n✅ Frais réduits\n✅ Sécurisé\n\nVoulez-vous faire un transfert ?',
      'Les transferts JUFA sont rapides et sécurisés ! ⚡\n\n💡 Astuce : Scannez le QR code du destinataire pour aller plus vite !\n\nCaractéristiques :\n✅ Instantané (moins de 5 secondes)\n✅ Authentification obligatoire\n✅ Confirmation par notification\n✅ Historique complet\n\nBesoin d\'aide pour un transfert ?',
    ],
    'nege_marketplace': [
      'Nege est le marketplace JUFA pour l\'or et l\'argent ! 🥇🥈\n\nAchetez et vendez :\n🔸 Or : 50 000 FCFA/gramme\n🔸 Argent : 800 FCFA/gramme\n\nComment ça marche ?\n1️⃣ Créez une offre de vente\n2️⃣ Fixez votre quantité\n3️⃣ Les acheteurs voient votre offre\n4️⃣ Transaction sécurisée via JUFA\n\nPrêt à investir dans les métaux précieux ?',
      'Investissez dans l\'or et l\'argent avec Nege ! 💎\n\n📊 Prix actuels :\n• Or : 50 000 FCFA/g\n• Argent : 800 FCFA/g\n\nAvantages :\n✅ Valeur refuge\n✅ Protection contre l\'inflation\n✅ Transactions sécurisées\n✅ Marketplace actif\n\nVoulez-vous voir les offres disponibles ?',
    ],
    'recharge': [
      'Rechargez votre crédit directement depuis JUFA ! 📱\n\nOpérateurs disponibles :\n📞 Orange Mali\n📞 Malitel\n📞 Telecel\n\nMontants : 500 à 50 000 FCFA\n⚡ Crédit instantané\n💰 Pas de frais supplémentaires\n\nQuel opérateur utilisez-vous ?',
      'Recharge de crédit ultra-rapide avec JUFA ! ⚡\n\n1️⃣ Sélectionnez votre opérateur\n2️⃣ Entrez le numéro\n3️⃣ Choisissez le montant\n4️⃣ Confirmez !\n\n✅ Crédit reçu en moins de 10 secondes\n✅ Historique des recharges\n✅ Recharges pour vos proches\n\nCommençons ?',
    ],
    'securite': [
      'Votre sécurité est notre priorité ! 🔒\n\nProtections JUFA :\n✅ Authentification biométrique (empreinte/Face ID)\n✅ Code PIN à 4 chiffres\n✅ Chiffrement des données\n✅ Notifications en temps réel\n✅ Blocage de carte instantané\n\nConseils :\n⚠️ Ne partagez jamais votre PIN\n⚠️ Activez la biométrie\n⚠️ Vérifiez chaque transaction\n\nBesoin de configurer votre sécurité ?',
      'JUFA protège votre argent 24/7 ! 🛡️\n\nFonctionnalités de sécurité :\n🔐 Authentification avant chaque transfert\n🔐 Détection de fraude automatique\n🔐 Historique complet des transactions\n🔐 Déconnexion automatique\n\nEn cas de problème :\n📞 Support 24/7\n🚨 Blocage de compte instantané\n💬 Chat en direct\n\nTout va bien avec votre compte ?',
    ],
    'qr_code': [
      'Les QR codes JUFA facilitent vos transactions ! 📱\n\n2 types de QR codes :\n\n📥 QR Dépôt (vert) :\nPour recevoir de l\'argent. Montrez-le à quelqu\'un qui veut vous payer.\n\n📤 QR Retrait (rouge) :\nPour retirer chez un agent JUFA. Scannez-le pour valider le retrait.\n\nAccès : Cliquez sur le bouton Scanner au centre !\n\nVoulez-vous voir vos QR codes ?',
      'Utilisez les QR codes pour des transactions rapides ! ⚡\n\nAvantages :\n✅ Pas besoin de taper le numéro\n✅ Zéro erreur\n✅ Ultra rapide\n✅ Sécurisé\n\nOù trouver vos QR codes ?\n👉 Bouton Scanner (au centre)\n👉 Onglet "Mes QR Codes"\n\nBesoin d\'aide pour scanner ?',
    ],
    'frais': [
      'Frais JUFA - Transparents et compétitifs ! 💰\n\n💸 Transferts entre utilisateurs JUFA : GRATUIT\n💳 Paiements marchands : 0,5%\n🏧 Retraits distributeurs : 500 FCFA\n📱 Recharge crédit : GRATUIT\n🥇 Transactions Nege : 1%\n\nPas de frais cachés !\nPas de frais d\'abonnement !\n\nD\'autres questions sur les tarifs ?',
    ],
    'balance': [
      'Consultez votre solde à tout moment ! 💰\n\nOù voir votre solde ?\n👉 Page d\'accueil (Dashboard)\n👉 En haut de l\'écran\n👉 Mis à jour en temps réel\n\nVous pouvez aussi voir :\n📊 Dépenses du mois\n📈 Revenus du mois\n📉 Graphiques de tendance\n\nVoulez-vous des conseils pour gérer votre budget ?',
    ],
    'help': [
      'Je peux vous aider avec JUFA ! 🤝\n\nSujets disponibles :\n💳 Carte Jufa (virtuelle/physique)\n💸 Transferts d\'argent\n🥇 Marketplace Nege (or/argent)\n📱 Recharge de crédit\n🔒 Sécurité et authentification\n📱 QR codes\n💰 Frais et tarifs\n📊 Gestion du solde\n\nQue voulez-vous savoir ?',
      'Besoin d\'aide avec JUFA ? Je suis là ! 😊\n\nServices JUFA :\n✅ Portefeuille mobile\n✅ Transferts instantanés\n✅ Carte de paiement\n✅ Marketplace métaux précieux\n✅ Recharge airtime\n✅ Sécurité maximale\n\nPosez-moi n\'importe quelle question sur JUFA !',
    ],
    'default': [
      'Intéressant ! Laissez-moi vous aider avec ça. Pouvez-vous préciser votre question sur JUFA ?',
      'Je suis là pour vous aider avec JUFA ! Voulez-vous en savoir plus sur les transferts, la carte Jufa, le marketplace Nege, ou autre chose ?',
      'Excellente question ! JUFA offre de nombreuses fonctionnalités. Que souhaitez-vous découvrir en particulier ?',
    ],
  };

  // Base de connaissances JUFA - English
  final Map<String, List<String>> _responsesEn = {
    'greeting': [
      'Hello! I\'m Jufa AI, your personal JUFA assistant. How can I help you today? 🌟',
      'Hi! Welcome to JUFA, your all-in-one mobile wallet. What would you like to do?',
      'Hello! I\'m here to guide you through using JUFA. Ask me your questions! 😊',
    ],
    'jufa_info': [
      'JUFA is your complete mobile wallet in Mali! 🇲🇱\n\n✅ Instant money transfers\n✅ Merchant payments\n✅ Virtual and physical Jufa Card\n✅ Gold and silver marketplace (Nege)\n✅ Airtime recharge\n✅ Biometric security\n\nWhat would you like to discover?',
      'JUFA offers you a complete mobile banking experience:\n\n💳 Jufa Card for your payments\n💰 Fast transfers between users\n🛒 Nege Marketplace (gold/silver)\n📱 Airtime recharge\n🔒 Maximum security with biometrics\n\nHow can I help you?',
    ],
    'carte_jufa': [
      'The Jufa Card is your mobile payment card! 💳\n\n📱 Virtual Card: Available immediately\n💳 Physical Card: Delivery in 5-7 days\n\nBenefits:\n✅ Secure online payments\n✅ ATM withdrawals\n✅ Merchant payments\n✅ Manage from the app\n\nWould you like to order your card?',
      'With the Jufa Card, pay everywhere! 🌍\n\n🔹 Virtual: Use it immediately for online purchases\n🔹 Physical: Receive it at home for daily payments\n\nSecurity:\n🔒 Personalized PIN code\n🔒 Biometric authentication\n🔒 Instant blocking from the app\n\nNeed help activating it?',
    ],
    'transfert': [
      'Transferring money with JUFA is simple! 💸\n\n1️⃣ Click on "Transfer"\n2️⃣ Enter the number (+223 XX XX XX XX)\n3️⃣ Enter the amount\n4️⃣ Authenticate (biometrics or PIN)\n5️⃣ Confirm!\n\n✅ Instant transfer\n✅ Low fees\n✅ Secure\n\nWould you like to make a transfer?',
      'JUFA transfers are fast and secure! ⚡\n\n💡 Tip: Scan the recipient\'s QR code to go faster!\n\nFeatures:\n✅ Instant (less than 5 seconds)\n✅ Mandatory authentication\n✅ Notification confirmation\n✅ Complete history\n\nNeed help with a transfer?',
    ],
    'nege_marketplace': [
      'Nege is the JUFA marketplace for gold and silver! 🥇🥈\n\nBuy and sell:\n🔸 Gold: 50,000 FCFA/gram\n🔸 Silver: 800 FCFA/gram\n\nHow does it work?\n1️⃣ Create a sale offer\n2️⃣ Set your quantity\n3️⃣ Buyers see your offer\n4️⃣ Secure transaction via JUFA\n\nReady to invest in precious metals?',
      'Invest in gold and silver with Nege! 💎\n\n📊 Current prices:\n• Gold: 50,000 FCFA/g\n• Silver: 800 FCFA/g\n\nBenefits:\n✅ Safe haven value\n✅ Inflation protection\n✅ Secure transactions\n✅ Active marketplace\n\nWould you like to see available offers?',
    ],
    'recharge': [
      'Recharge your airtime directly from JUFA! 📱\n\nAvailable operators:\n📞 Orange Mali\n📞 Malitel\n📞 Telecel\n\nAmounts: 500 to 50,000 FCFA\n⚡ Instant credit\n💰 No additional fees\n\nWhich operator do you use?',
      'Ultra-fast airtime recharge with JUFA! ⚡\n\n1️⃣ Select your operator\n2️⃣ Enter the number\n3️⃣ Choose the amount\n4️⃣ Confirm!\n\n✅ Credit received in less than 10 seconds\n✅ Recharge history\n✅ Recharge for your loved ones\n\nShall we start?',
    ],
    'securite': [
      'Your security is our priority! 🔒\n\nJUFA protections:\n✅ Biometric authentication (fingerprint/Face ID)\n✅ 4-digit PIN code\n✅ Data encryption\n✅ Real-time notifications\n✅ Instant card blocking\n\nTips:\n⚠️ Never share your PIN\n⚠️ Enable biometrics\n⚠️ Verify each transaction\n\nNeed to configure your security?',
      'JUFA protects your money 24/7! 🛡️\n\nSecurity features:\n🔐 Authentication before each transfer\n🔐 Automatic fraud detection\n🔐 Complete transaction history\n🔐 Automatic logout\n\nIn case of problem:\n📞 24/7 support\n🚨 Instant account blocking\n💬 Live chat\n\nIs everything okay with your account?',
    ],
    'qr_code': [
      'JUFA QR codes make your transactions easier! 📱\n\n2 types of QR codes:\n\n📥 Deposit QR (green):\nTo receive money. Show it to someone who wants to pay you.\n\n📤 Withdrawal QR (red):\nTo withdraw at a JUFA agent. Scan it to validate the withdrawal.\n\nAccess: Click the Scanner button in the center!\n\nWould you like to see your QR codes?',
      'Use QR codes for fast transactions! ⚡\n\nBenefits:\n✅ No need to type the number\n✅ Zero errors\n✅ Ultra fast\n✅ Secure\n\nWhere to find your QR codes?\n👉 Scanner button (center)\n👉 "My QR Codes" tab\n\nNeed help scanning?',
    ],
    'frais': [
      'JUFA Fees - Transparent and competitive! 💰\n\n💸 Transfers between JUFA users: FREE\n💳 Merchant payments: 0.5%\n🏧 ATM withdrawals: 500 FCFA\n📱 Airtime recharge: FREE\n🥇 Nege transactions: 1%\n\nNo hidden fees!\nNo subscription fees!\n\nAny other questions about pricing?',
    ],
    'balance': [
      'Check your balance anytime! 💰\n\nWhere to see your balance?\n👉 Home page (Dashboard)\n👉 Top of the screen\n👉 Updated in real time\n\nYou can also see:\n📊 Monthly expenses\n📈 Monthly income\n📉 Trend charts\n\nWould you like tips for managing your budget?',
    ],
    'help': [
      'I can help you with JUFA! 🤝\n\nAvailable topics:\n💳 Jufa Card (virtual/physical)\n💸 Money transfers\n🥇 Nege Marketplace (gold/silver)\n📱 Airtime recharge\n🔒 Security and authentication\n📱 QR codes\n💰 Fees and pricing\n📊 Balance management\n\nWhat would you like to know?',
      'Need help with JUFA? I\'m here! 😊\n\nJUFA services:\n✅ Mobile wallet\n✅ Instant transfers\n✅ Payment card\n✅ Precious metals marketplace\n✅ Airtime recharge\n✅ Maximum security\n\nAsk me any question about JUFA!',
    ],
    'default': [
      'Interesting! Let me help you with that. Can you clarify your question about JUFA?',
      'I\'m here to help you with JUFA! Would you like to know more about transfers, the Jufa Card, the Nege marketplace, or something else?',
      'Excellent question! JUFA offers many features. What would you like to discover in particular?',
    ],
  };

  final List<QuickReply> _commonQuickReplies = [
    QuickReply(id: '1', text: '� Carte Jufa', action: 'carte_jufa'),
    QuickReply(id: '2', text: '� Transfert', action: 'transfert'),
    QuickReply(id: '3', text: '🥇 Marketplace Nege', action: 'nege_marketplace'),
    QuickReply(id: '4', text: '� Recharge', action: 'recharge'),
    QuickReply(id: '5', text: '📱 QR Codes', action: 'qr_code'),
    QuickReply(id: '6', text: '🔒 Sécurité', action: 'securite'),
    QuickReply(id: '7', text: '💰 Frais', action: 'frais'),
    QuickReply(id: '8', text: '❓ Aide', action: 'help'),
  ];

  Future<void> sendMessage(String content, {MessageType type = MessageType.text}) async {
    // Message utilisateur
    final userMessage = ChatMessage(
      id: _generateId(),
      content: content,
      type: type,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    _conversationHistory.add(userMessage);
    _messageController.add(userMessage);

    // Simulation typing
    await _simulateTyping();

    // Réponse de l'IA
    final response = await _generateResponse(content);
    _conversationHistory.add(response);
    _messageController.add(response);
  }

  Future<void> sendQuickReply(QuickReply quickReply) async {
    await sendMessage(quickReply.text);
  }

  Future<ChatMessage> _generateResponse(String userInput) async {
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulation processing

    final category = _categorizeInput(userInput);
    final responses = _getResponsesForLocale(category);
    final responseText = responses[Random().nextInt(responses.length)];

    return ChatMessage(
      id: _generateId(),
      content: responseText,
      type: MessageType.text,
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      quickReplies: _getQuickRepliesForCategory(category),
    );
  }

  List<String> _getResponsesForLocale(String category) {
    final responsesMap = _locale == 'en' ? _responsesEn : _responsesFr;
    return responsesMap[category] ?? responsesMap['default']!;
  }

  String _categorizeInput(String input) {
    final lowerInput = input.toLowerCase();
    
    // Salutations
    if (lowerInput.contains('bonjour') || lowerInput.contains('salut') || lowerInput.contains('hello') || lowerInput.contains('bonsoir') || lowerInput.contains('hi')) {
      return 'greeting';
    }
    // JUFA général
    else if (lowerInput.contains('jufa') || lowerInput.contains('c\'est quoi') || lowerInput.contains('qu\'est-ce que')) {
      return 'jufa_info';
    }
    // Carte Jufa
    else if (lowerInput.contains('carte') || lowerInput.contains('card') || lowerInput.contains('virtuelle') || lowerInput.contains('physique')) {
      return 'carte_jufa';
    }
    // Transferts
    else if (lowerInput.contains('transfert') || lowerInput.contains('transfer') || lowerInput.contains('envoyer') || lowerInput.contains('envoi')) {
      return 'transfert';
    }
    // Nege Marketplace
    else if (lowerInput.contains('nege') || lowerInput.contains('or') || lowerInput.contains('argent') || lowerInput.contains('gold') || lowerInput.contains('silver') || lowerInput.contains('marketplace')) {
      return 'nege_marketplace';
    }
    // Recharge
    else if (lowerInput.contains('recharge') || lowerInput.contains('crédit') || lowerInput.contains('airtime') || lowerInput.contains('orange') || lowerInput.contains('malitel')) {
      return 'recharge';
    }
    // Sécurité
    else if (lowerInput.contains('sécurité') || lowerInput.contains('security') || lowerInput.contains('biométrie') || lowerInput.contains('pin') || lowerInput.contains('sécurisé')) {
      return 'securite';
    }
    // QR Codes
    else if (lowerInput.contains('qr') || lowerInput.contains('scanner') || lowerInput.contains('scan') || lowerInput.contains('code')) {
      return 'qr_code';
    }
    // Frais
    else if (lowerInput.contains('frais') || lowerInput.contains('tarif') || lowerInput.contains('prix') || lowerInput.contains('coût') || lowerInput.contains('combien')) {
      return 'frais';
    }
    // Solde
    else if (lowerInput.contains('solde') || lowerInput.contains('balance') || lowerInput.contains('compte')) {
      return 'balance';
    }
    // Aide
    else if (lowerInput.contains('aide') || lowerInput.contains('help') || lowerInput.contains('comment') || lowerInput.contains('besoin')) {
      return 'help';
    }
    
    return 'default';
  }

  List<QuickReply>? _getQuickRepliesForCategory(String category) {
    switch (category) {
      case 'greeting':
        return [
          QuickReply(id: 'g1', text: '💳 Carte Jufa', action: 'carte_jufa'),
          QuickReply(id: 'g2', text: '💸 Transfert', action: 'transfert'),
          QuickReply(id: 'g3', text: '🥇 Nege', action: 'nege_marketplace'),
          QuickReply(id: 'g4', text: '📱 Recharge', action: 'recharge'),
        ];
      case 'jufa_info':
        return [
          QuickReply(id: 'j1', text: '� Carte', action: 'carte_jufa'),
          QuickReply(id: 'j2', text: '💸 Transfert', action: 'transfert'),
          QuickReply(id: 'j3', text: '🥇 Marketplace', action: 'nege_marketplace'),
        ];
      case 'carte_jufa':
        return [
          QuickReply(id: 'c1', text: '📱 Virtuelle', action: 'carte_virtuelle'),
          QuickReply(id: 'c2', text: '� Physique', action: 'carte_physique'),
          QuickReply(id: 'c3', text: '🔒 Sécurité', action: 'securite'),
        ];
      case 'transfert':
        return [
          QuickReply(id: 't1', text: '📱 QR Code', action: 'qr_code'),
          QuickReply(id: 't2', text: '💰 Frais', action: 'frais'),
          QuickReply(id: 't3', text: '🔒 Sécurité', action: 'securite'),
        ];
      case 'nege_marketplace':
        return [
          QuickReply(id: 'n1', text: '🥇 Prix Or', action: 'prix_or'),
          QuickReply(id: 'n2', text: '🥈 Prix Argent', action: 'prix_argent'),
          QuickReply(id: 'n3', text: '� Frais', action: 'frais'),
        ];
      case 'recharge':
        return [
          QuickReply(id: 'r1', text: '📞 Orange', action: 'orange'),
          QuickReply(id: 'r2', text: '� Malitel', action: 'malitel'),
          QuickReply(id: 'r3', text: '💰 Frais', action: 'frais'),
        ];
      case 'securite':
        return [
          QuickReply(id: 's1', text: '🔐 Biométrie', action: 'biometrie'),
          QuickReply(id: 's2', text: '🔢 PIN', action: 'pin'),
          QuickReply(id: 's3', text: '🛡️ Protection', action: 'protection'),
        ];
      default:
        return _commonQuickReplies.take(4).toList();
    }
  }

  Future<void> _simulateTyping() async {
    final typingMessage = ChatMessage(
      id: 'typing',
      content: _locale == 'en' ? 'Jufa AI is typing...' : 'Jufa AI est en train d\'écrire...',
      type: MessageType.text,
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      isTyping: true,
    );

    _messageController.add(typingMessage);
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Analytics et insights
  Future<Map<String, dynamic>> getFinancialInsights() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'spending_trend': 'down', // up, down, stable
      'savings_rate': 0.23, // 23%
      'top_category': _locale == 'en' ? 'Transport' : 'Transport',
      'recommendation': _locale == 'en' 
        ? 'Reduce your transport expenses by 15% to save 25,000 FCFA/month'
        : 'Réduisez vos dépenses transport de 15% pour économiser 25 000 FCFA/mois',
      'fraud_risk': 'low', // low, medium, high
      'credit_score': 750,
      'next_goal_progress': 0.78, // 78%
    };
  }

  // Prédictions
  Future<Map<String, dynamic>> getPredictions() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    return {
      'next_month_spending': 180000.0,
      'savings_potential': 45000.0,
      'goal_completion_date': DateTime.now().add(const Duration(days: 45)),
      'recommended_investment': 'Bitcoin',
      'risk_alerts': _locale == 'en' 
        ? ['Unusual expense expected on 25/10']
        : ['Dépense inhabituelle prévue le 25/10'],
    };
  }

  // Catégorisation automatique
  String categorizeTransaction(String description, double amount) {
    final desc = description.toLowerCase();
    
    if (desc.contains('restaurant') || desc.contains('food') || desc.contains('supermarché')) {
      return 'Alimentation';
    } else if (desc.contains('transport') || desc.contains('taxi') || desc.contains('bus')) {
      return 'Transport';
    } else if (desc.contains('shopping') || desc.contains('vêtement') || desc.contains('magasin')) {
      return 'Shopping';
    } else if (desc.contains('santé') || desc.contains('médecin') || desc.contains('pharmacie')) {
      return 'Santé';
    } else if (desc.contains('loisir') || desc.contains('cinéma') || desc.contains('sport')) {
      return 'Loisirs';
    } else if (amount > 100000) {
      return 'Gros achat';
    } else {
      return 'Autres';
    }
  }

  void dispose() {
    _messageController.close();
  }
}
