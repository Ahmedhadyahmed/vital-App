import 'package:flutter/material.dart';

class PaymentMethod {
  final String id;
  final String type; // 'visa', 'mastercard', 'fawry'
  final String displayName;
  final String details;
  final IconData icon;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    required this.details,
    required this.icon,
  });
}

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  List<PaymentMethod> paymentMethods = [];

  void _addPaymentMethod(PaymentMethod method) {
    setState(() {
      paymentMethods.add(method);
    });
  }

  void _removePaymentMethod(String id) {
    setState(() {
      paymentMethods.removeWhere((method) => method.id == id);
    });
  }

  void _showPaymentMethodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentMethodSelector(
        onMethodSelected: (type) {
          Navigator.pop(context);
          _showPaymentDetailsDialog(type);
        },
      ),
    );
  }

  void _showPaymentDetailsDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => PaymentDetailsDialog(
        paymentType: type,
        onPaymentAdded: _addPaymentMethod,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        shadowColor: Colors.black12,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FD1C7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 40,
                    color: Color(0xFF4FD1C7),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  paymentMethods.isEmpty ? 'No Payment Methods' : 'Your Payment Methods',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  paymentMethods.isEmpty
                      ? 'Add your preferred payment methods for quick checkout'
                      : 'Manage your saved payment methods',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Payment Methods List or Empty State
          Expanded(
            child: paymentMethods.isEmpty
                ? _buildEmptyState()
                : _buildPaymentMethodsList(),
          ),

          // Add Payment Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showPaymentMethodSelector,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FD1C7),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: const Color(0xFF4FD1C7).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add New Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.credit_card_off,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Payment Methods Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Add your first payment method to get started with quick and secure payments',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: paymentMethods.length,
      itemBuilder: (context, index) {
        final method = paymentMethods[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getMethodColor(method.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  method.icon,
                  color: _getMethodColor(method.type),
                  size: 24,
                ),
              ),
              title: Text(
                method.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                method.details,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              trailing: IconButton(
                onPressed: () => _removePaymentMethod(method.id),
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red[400],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getMethodColor(String type) {
    switch (type) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'fawry':
        return const Color(0xFFFF6B35);
      default:
        return const Color(0xFF4FD1C7);
    }
  }
}

class PaymentMethodSelector extends StatelessWidget {
  final Function(String) onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Choose Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          _buildPaymentOption(
            context,
            'Visa',
            'Credit/Debit Card',
            Icons.credit_card,
            const Color(0xFF1A1F71),
                () => onMethodSelected('visa'),
          ),
          _buildPaymentOption(
            context,
            'Mastercard',
            'Credit/Debit Card',
            Icons.credit_card,
            const Color(0xFFEB001B),
                () => onMethodSelected('mastercard'),
          ),
          _buildPaymentOption(
            context,
            'Fawry',
            'Mobile Payment',
            Icons.phone_android,
            const Color(0xFFFF6B35),
                () => onMethodSelected('fawry'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class PaymentDetailsDialog extends StatefulWidget {
  final String paymentType;
  final Function(PaymentMethod) onPaymentAdded;

  const PaymentDetailsDialog({
    super.key,
    required this.paymentType,
    required this.onPaymentAdded,
  });

  @override
  State<PaymentDetailsDialog> createState() => _PaymentDetailsDialogState();
}

class _PaymentDetailsDialogState extends State<PaymentDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _addPaymentMethod() {
    if (_formKey.currentState!.validate()) {
      String displayName;
      String details;
      IconData icon;

      if (widget.paymentType == 'fawry') {
        displayName = 'Fawry';
        details = _phoneController.text;
        icon = Icons.phone_android;
      } else {
        displayName = widget.paymentType == 'visa' ? 'Visa' : 'Mastercard';
        final cardNumber = _cardNumberController.text;
        details = '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
        icon = Icons.credit_card;
      }

      final method = PaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: widget.paymentType,
        displayName: displayName,
        details: details,
        icon: icon,
      );

      widget.onPaymentAdded(method);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$displayName payment method added successfully!'),
          backgroundColor: const Color(0xFF4FD1C7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getMethodColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getMethodIcon(),
                    color: _getMethodColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Add ${_getMethodTitle()}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: widget.paymentType == 'fawry'
                  ? _buildFawryForm()
                  : _buildCardForm(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addPaymentMethod,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FD1C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Add Method',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFawryForm() {
    return Column(
      children: [
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            hintText: '+20 xxx xxx xxxx',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4FD1C7)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your mobile number';
            }
            if (value.length < 10) {
              return 'Please enter a valid mobile number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        TextFormField(
          controller: _cardHolderController,
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4FD1C7)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter cardholder name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4FD1C7)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            if (value.length < 16) {
              return 'Please enter a valid card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'MM/YY',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF4FD1C7)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF4FD1C7)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (value.length < 3) {
                    return 'Invalid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getMethodColor() {
    switch (widget.paymentType) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'fawry':
        return const Color(0xFFFF6B35);
      default:
        return const Color(0xFF4FD1C7);
    }
  }

  IconData _getMethodIcon() {
    switch (widget.paymentType) {
      case 'fawry':
        return Icons.phone_android;
      default:
        return Icons.credit_card;
    }
  }

  String _getMethodTitle() {
    switch (widget.paymentType) {
      case 'visa':
        return 'Visa Card';
      case 'mastercard':
        return 'Mastercard';
      case 'fawry':
        return 'Fawry';
      default:
        return 'Payment Method';
    }
  }
}