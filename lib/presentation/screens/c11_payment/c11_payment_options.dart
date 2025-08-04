import 'package:flutter/material.dart';

class PaymentOptions extends StatefulWidget {
  const PaymentOptions({super.key});

  @override
  State<PaymentOptions> createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  bool _showCardForm = false;
  bool _showAddButton = true;
  String? _selectedPaymentMethod;

  void _handlePaymentMethodClick(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });

    // Show sss message or navigate to payment processing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $method'),
        backgroundColor: const Color(0xFF27AE60),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleAddCard() {
    setState(() {
      _showCardForm = !_showCardForm;
      _showAddButton = !_showCardForm;
    });
  }

  void _handleSaveCard() {
    setState(() {
      _showCardForm = false;
      _showAddButton = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card saved successfully!'),
        backgroundColor: Color(0xFF27AE60),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handlePayNow() {
    if (_selectedPaymentMethod != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Processing payment via $_selectedPaymentMethod'),
          backgroundColor: const Color(0xFF3498DB),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method first'),
          backgroundColor: Color(0xFFE74C3C),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text(
              'Payment Options',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Section Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Add ₹150',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Offers Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('PAYMENT OFFERS (6)', 'View All'),
                  _buildPaymentOffers(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Preferred Payment Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('PREFERRED PAYMENT', null),
                  _buildUPISection(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Debit/Credit Cards Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('DEBIT/CREDIT CARDS', 'ADD'),
                  if (_showCardForm) _buildCardsSection(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Wallets Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('WALLETS', null),
                  _buildWalletsSection(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Net Banking Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('NET BANKING', 'View All'),
                  _buildNetBankingSection(),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, String? actionText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (title == 'PREFERRED PAYMENT')
                const Icon(
                  Icons.star_outline,
                  color: Color(0xFF2C3E50),
                  size: 20,
                ),
              if (title == 'PAYMENT OFFERS (6)')
                const Icon(
                  Icons.offline_pin_rounded,
                  color: Color(0xFF2C3E50),
                  size: 20,
                ),
              if (title == 'DEBIT/CREDIT CARDS')
                const Icon(
                  Icons.credit_card,
                  color: Color(0xFF2C3E50),
                  size: 20,
                ),
              if (title == 'WALLETS')
                const Icon(
                  Icons.wallet,
                  color: Color(0xFF2C3E50),
                  size: 20,
                ),
              if (title == 'NET BANKING')
                const Icon(
                  Icons.home,
                  color: Color(0xFF2C3E50),
                  size: 20,
                ),
              if (title == 'PREFERRED PAYMENT') const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (actionText != null)
            actionText == 'ADD'
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        _showCardForm = !_showCardForm;
                        _showAddButton = !_showCardForm;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                    child: Text(
                      _showCardForm ? 'HIDE' : 'ADD',
                      style: const TextStyle(
                        color: Color(0xFF3498DB),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: () {
                      // Handle "View All" action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('View all $title options'),
                          backgroundColor: const Color(0xFF3498DB),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                    child: Text(
                      actionText,
                      style: const TextStyle(
                        color: Color(0xFF3498DB),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
        ],
      ),
    );
  }

  Widget _buildPaymentOffers() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildOfferCard(
                'BHIM App', 'Up to ₹30 Cashback', const Color(0xFFFF6B35)),
            const SizedBox(width: 12),
            _buildOfferCard('CRED', 'Up to ₹', const Color(0xFF9B59B6)),
            const SizedBox(width: 12),
            _buildOfferCard(
                'Paytm', 'Up to ₹50 Cashback', const Color(0xFF00B9F1)),
            const SizedBox(width: 12),
            _buildOfferCard(
                'PhonePe', 'Up to ₹25 Cashback', const Color(0xFF5F259F)),
            const SizedBox(width: 12),
            _buildOfferCard(
                'Amazon Pay', 'Up to ₹40 Cashback', const Color(0xFFFF9900)),
            const SizedBox(width: 12),
            _buildOfferCard(
                'Mobikwik', 'Up to ₹20 Cashback', const Color(0xFF3498DB)),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(String title, String offer, Color color) {
    return GestureDetector(
      onTap: () => _handlePaymentMethodClick(title),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              const Color(0xFFE8F5E8), // Light green background like in image
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              width: 1,
              style: BorderStyle.solid),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: _getPaymentIcon(title),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  offer,
                  style: const TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPaymentIcon(String title) {
    switch (title) {
      case 'BHIM App':
        return const Icon(Icons.account_balance, color: Colors.white, size: 16);
      case 'CRED':
        return const Icon(Icons.credit_card, color: Colors.white, size: 16);
      case 'Paytm':
        return const Icon(Icons.payment, color: Colors.white, size: 16);
      case 'PhonePe':
        return const Icon(Icons.phone_android, color: Colors.white, size: 16);
      case 'Amazon Pay':
        return const Icon(Icons.shopping_cart, color: Colors.white, size: 16);
      case 'Mobikwik':
        return const Icon(Icons.account_balance_wallet,
            color: Colors.white, size: 16);
      default:
        return Text(
          title[0],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  Widget _getWalletIcon(String name) {
    switch (name) {
      case 'Amazon Pay':
        return const Icon(Icons.shopping_cart, color: Colors.white, size: 16);
      case 'Mobikwik':
        return const Icon(Icons.account_balance_wallet,
            color: Colors.white, size: 16);
      default:
        return Text(
          name[0],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  Widget _getBankIcon(String name) {
    switch (name) {
      case 'SBI':
        return const Icon(Icons.account_balance, color: Colors.white, size: 16);
      case 'ICICI':
        return const Icon(Icons.credit_card, color: Colors.white, size: 16);
      case 'Kotak':
        return const Icon(Icons.account_balance_wallet,
            color: Colors.white, size: 16);
      case 'Axis':
        return const Icon(Icons.payment, color: Colors.white, size: 16);
      default:
        return Text(
          name[0],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  Widget _buildUPISection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          // Google Pay Entry
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.g_mobiledata,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    Text(
                      'Google Pay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'ADD ₹150',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // PhonePe Entry
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF5F259F),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child:
                      Icon(Icons.phone_android, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    Text(
                      'PhonePe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2C3E50),
                    side: const BorderSide(color: Color(0xFFBDC3C7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'ADD ₹150',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pay by any UPI Entry
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.payment, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    Text(
                      'Pay by any UPI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2C3E50),
                    side: const BorderSide(color: Color(0xFFBDC3C7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'ADD ₹150',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: _showCardForm ? _buildCardForm() : const SizedBox.shrink(),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  Widget _buildCardForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBDC3C7), width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              maxLength: 16,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                labelStyle: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontSize: 14,
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFBDC3C7)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3498DB)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                counterText: '',
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2C3E50),
              ),
              validator: (value) {
                if (value == null ||
                    value.length != 16 ||
                    !RegExp(r'^\d{16}$').hasMatch(value)) {
                  return 'Enter a valid 16-digit card number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _expiryController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Expiry (MM/YY)',
                          labelStyle: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 14,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFBDC3C7)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF3498DB)),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C3E50),
                        ),
                        validator: (value) {
                          if (value == null ||
                              !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                            return 'Enter valid MM/YY';
                          }
                          final parts = value.split('/');
                          final month = int.tryParse(parts[0]) ?? 0;
                          final year = int.tryParse(parts[1]) ?? 0;
                          if (month < 1 || month > 12) return 'Invalid month';
                          final now = DateTime.now();
                          final expiryYear = 2000 + year;
                          final expiryDate = DateTime(expiryYear, month + 1, 0);
                          if (expiryDate.isBefore(now)) {
                            return 'Card expired';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        ' ',
                        style: TextStyle(
                          color: Color(0xFF95A5A6),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        obscureText: true, // 👈 This is the magic line
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          labelStyle: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 14,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFBDC3C7)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF3498DB)),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          counterText: '',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C3E50),
                        ),
                        validator: (value) {
                          if (value == null ||
                              !RegExp(r'^\d{3}$').hasMatch(value)) {
                            return 'Enter valid 3-digit CVV';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Will not be saved',
                        style: TextStyle(
                          color: Color(0xFF95A5A6),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Process data
                  print("Valid card details entered!");
                }
              },
              child: const Text("Submit"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWalletsSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          _buildWalletItem('Amazon Pay', 'pay', const Color(0xFFFF9900)),
          const SizedBox(height: 16),
          _buildWalletItem('Mobikwik', 'M', const Color(0xFF3498DB)),
        ],
      ),
    );
  }

  Widget _buildWalletItem(String name, String logo, Color color) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: _getWalletIcon(name),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => _handlePaymentMethodClick(name),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
          ),
          child: const Text(
            'LINK',
            style: TextStyle(
              color: Color(0xFF3498DB),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetBankingSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate how many banks can fit based on screen width
          final availableWidth =
              constraints.maxWidth - 40; // Account for padding
          final bankWidth = 88.0; // Updated width for cards
          final spacing = 8.0;
          final maxBanks =
              ((availableWidth + spacing) / (bankWidth + spacing)).floor();

          // Limit to 4 banks maximum
          final banksToShow = maxBanks.clamp(1, 4);

          // List of all available banks
          final allBanks = [
            {'name': 'SBI', 'color': const Color(0xFF2980B9)},
            {'name': 'ICICI', 'color': const Color(0xFFE74C3C)},
            {'name': 'Kotak', 'color': const Color(0xFF2C3E50)},
            {'name': 'Axis', 'color': const Color(0xFFE74C3C)},
            {'name': 'HDFC', 'color': const Color(0xFF27AE60)},
            {'name': 'PNB', 'color': const Color(0xFF8E44AD)},
          ];

          // Take only the first 'banksToShow' banks
          final banksToDisplay = allBanks.take(banksToShow).toList();

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: banksToDisplay
                .map((bank) => _buildBankLogo(
                    bank['name'] as String, bank['color'] as Color))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildBankLogo(String name, Color color) {
    return GestureDetector(
      onTap: () => _handlePaymentMethodClick(name),
      child: Container(
        width: 80,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: _getBankIcon(name),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getBankDisplayName(name),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getBankDisplayName(String name) {
    switch (name) {
      case 'SBI':
        return 'State Bank...';
      case 'ICICI':
        return 'ICICI Bank';
      case 'Kotak':
        return 'Kotak Mah...';
      case 'Axis':
        return 'Axis Bank';
      case 'HDFC':
        return 'HDFC Bank';
      case 'PNB':
        return 'PNB Bank';
      default:
        return name;
    }
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: Colors.grey,
              ),
              Text(
                'clever11',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            '100% Secure Transactions',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
