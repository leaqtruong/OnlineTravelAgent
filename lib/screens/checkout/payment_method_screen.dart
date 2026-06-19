import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../utils/app_utils.dart';

class PaymentMethod {
  final String id;
  final String name;
  final String type; // 'mastercard', 'visa', 'paypal', 'applepay', 'custom'
  final String? last4;
  final Widget logo;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.last4,
    required this.logo,
  });
}

class PaymentMethodScreen extends StatefulWidget {
  final double totalPrice;
  final Future<bool> Function() onPaymentSuccess;
  final String initialMethodId;

  const PaymentMethodScreen({
    super.key,
    required this.totalPrice,
    required this.onPaymentSuccess,
    this.initialMethodId = 'mastercard',
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late List<PaymentMethod> _methods;
  String _selectedMethodId = 'mastercard';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedMethodId = widget.initialMethodId;
    _methods = [
      PaymentMethod(
        id: 'mastercard',
        name: 'Master Card',
        type: 'mastercard',
        logo: _buildMasterCardLogo(),
      ),
      PaymentMethod(
        id: 'visa',
        name: 'Visa',
        type: 'visa',
        logo: _buildVisaLogo(),
      ),
      PaymentMethod(
        id: 'paypal',
        name: 'PayPal',
        type: 'paypal',
        logo: _buildPayPalLogo(),
      ),
      PaymentMethod(
        id: 'applepay',
        name: 'Apple Pay',
        type: 'applepay',
        logo: _buildApplePayLogo(),
      ),
      PaymentMethod(
        id: 'cash',
        name: 'Tiền mặt (Thanh toán khi khởi hành)',
        type: 'cash',
        logo: _buildCashLogo(),
      ),
    ];
  }

  // --- LOGO BUILDERS ---
  Widget _buildMasterCardLogo() {
    return SizedBox(
      width: 44,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFF79E1B).withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisaLogo() {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: const Text(
        'VISA',
        style: TextStyle(
          color: Color(0xFF1A1F71),
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPayPalLogo() {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD2E3FC)),
      ),
      alignment: Alignment.center,
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
          children: [
            TextSpan(text: 'Pay', style: TextStyle(color: Color(0xFF003087))),
            TextSpan(text: 'Pal', style: TextStyle(color: Color(0xFF0079C1))),
          ],
        ),
      ),
    );
  }

  Widget _buildApplePayLogo() {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apple, color: Colors.white, size: 14),
          SizedBox(width: 1),
          Text(
            'Pay',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashLogo() {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.payments_rounded,
        color: Color(0xFF4CAF50),
        size: 16,
      ),
    );
  }

  Widget _buildGenericCardLogo(String name) {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.credit_card,
        color: AppTheme.primaryBlue,
        size: 16,
      ),
    );
  }

  // --- ACTIONS ---
  void _addNewCard() {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thêm thẻ mới',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textBlack,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          nameController.dispose();
                          numberController.dispose();
                          expiryController.dispose();
                          cvvController.dispose();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Cardholder Name
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Tên trên thẻ',
                      hintText: 'NGUYEN VAN A',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Vui lòng nhập tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Card Number
                  TextFormField(
                    controller: numberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Số thẻ',
                      hintText: '4211 0000 0000 0000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.credit_card_outlined),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      _CardNumberFormatter(),
                    ],
                    validator: (val) {
                      if (val == null || val.replaceAll(' ', '').length < 16) {
                        return 'Số thẻ không hợp lệ (16 số)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Expiration & CVV
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: expiryController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Hạn dùng',
                            hintText: 'MM/YY',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today_outlined),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            _ExpiryFormatter(),
                          ],
                          validator: (val) {
                            if (val == null || val.length < 5) {
                              return 'Hạn dùng MM/YY';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: cvvController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mã CVV',
                            hintText: '***',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          validator: (val) {
                            if (val == null || val.length < 3) {
                              return 'CVV gồm 3 số';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final numStr = numberController.text.replaceAll(' ', '');
                          final last4 = numStr.substring(numStr.length - 4);
                          
                          // Determine card type based on number prefix
                          String type = 'custom';
                          String name = 'Thẻ liên kết';
                          Widget logo;
                          
                          if (numStr.startsWith('4')) {
                            type = 'visa';
                            name = 'Visa';
                            logo = _buildVisaLogo();
                          } else if (numStr.startsWith('5')) {
                            type = 'mastercard';
                            name = 'Master Card';
                            logo = _buildMasterCardLogo();
                          } else {
                            logo = _buildGenericCardLogo(name);
                          }

                          final newId = 'card_${DateTime.now().millisecondsSinceEpoch}';
                          final newCard = PaymentMethod(
                            id: newId,
                            name: '$name (••• $last4)',
                            type: type,
                            last4: last4,
                            logo: logo,
                          );

                          setState(() {
                            _methods.add(newCard);
                            _selectedMethodId = newId;
                          });

                          nameController.dispose();
                          numberController.dispose();
                          expiryController.dispose();
                          cvvController.dispose();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã thêm thẻ thành công!')),
                          );
                        }
                      },
                      child: const Text(
                        'Thêm thẻ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handlePay() async {
    setState(() => _isProcessing = true);
    try {
      final success = await widget.onPaymentSuccess();
      setState(() => _isProcessing = false);
      if (success && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanh toán thất bại, vui lòng thử lại')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi thanh toán: $e')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        );
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeIn),
        );

        return ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: opacity,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.all(28),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8EE),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFC2EED7), width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF07D95A),
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _selectedMethodId == 'cash'
                        ? 'Đặt tour thành công!'
                        : 'Thanh toán thành công!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedMethodId == 'cash'
                        ? 'Yêu cầu đặt tour của bạn đã được ghi nhận. Quý khách vui lòng chuẩn bị thanh toán bằng tiền mặt khi khởi hành chuyến đi.'
                        : 'Yêu cầu dịch vụ của bạn đã được xác nhận thành công. Bạn có thể kiểm tra chi tiết trong mục Chuyến đi.',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryBlue,
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          child: const Text(
                            'Về Trang Chủ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            // Navigate to My Trips (index 1 in bottom nav)
                            Navigator.pushNamed(context, '/my-trips');
                          },
                          child: const Text(
                            'Xem Chuyến Đi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    children: [
                      // List of cards
                      ..._methods.map((method) => _buildMethodItem(method)),
                      
                      const SizedBox(height: 16),
                      
                      // Add More Button
                      _buildAddMoreButton(),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                
                // Bottom payment bar
                _buildBottomBar(),
              ],
            ),
          ),
          
          // Fullscreen processing loader
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang xử lý thanh toán...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textBlack,
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

  Widget _buildMethodItem(PaymentMethod method) {
    final isSelected = _selectedMethodId == method.id;
    final selectedColor = AppTheme.primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedMethodId = method.id;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? selectedColor : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: selectedColor.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Logo on the left
                method.logo,
                const SizedBox(width: 16),
                
                // Name in the middle
                Expanded(
                  child: Text(
                    method.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textBlack,
                    ),
                  ),
                ),
                
                // Selection indicator on the right
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  )
                else
                  const SizedBox(
                    width: 20,
                    height: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _addNewCard,
        icon: const Icon(
          Icons.add_circle_outline_rounded,
          color: Color(0xFF94A3B8),
          size: 20,
        ),
        label: const Text(
          'Add More',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                formatVND(widget.totalPrice),
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: _handlePay,
              child: const Text(
                'Xác nhận & Thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- TEXT FORMATTERS FOR CARD FORM ---
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' '); // Add double space or single space
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
